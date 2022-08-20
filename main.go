/*
* @Time    : 2020年10月15日 10:47:17
* @Author  : root
* @Project : AutoGin
* @File    : main.go
* @Software: GoLand
* @Describe:
 */
package main

import (
	"api-cli/models"
	"embed"
	"io/ioutil"
	"log"
	"os"
	"regexp"
	"strings"
	"text/template"

	"github.com/urfave/cli"
)

var p, _ = os.Getwd()
var path = strings.Replace(p, "\\", "/", -1)

func FileExist(path string) bool {
	_, err := os.Lstat(path)
	return !os.IsNotExist(err)
}

// 初始化目录
func initPath() {
	var err error
	os.RemoveAll(path + "/api")
	os.Mkdir("api", os.ModePerm)
	os.Mkdir("auto", os.ModePerm)
	os.Mkdir("config", os.ModePerm)
	os.MkdirAll("api/controllers", os.ModePerm)
	os.MkdirAll("api/database", os.ModePerm)
	os.MkdirAll("api/models", os.ModePerm)
	os.MkdirAll("api/repository/crud", os.ModePerm)
	os.MkdirAll("api/security", os.ModePerm)
	os.MkdirAll("api/utils/channels", os.ModePerm)
	os.MkdirAll("api/utils/gpool", os.ModePerm)
	modelFile := path + "/api/models/Models.go"
	if FileExist(modelFile) {
		err = os.Remove(modelFile)
		if err != nil {
			log.Fatal(err)
		}
	}
}

//模板替换生成代码
func AutoCreatFile(data models.AutoCurdModel, putPath string, outPath string) {
	b, err := f.ReadFile(putPath)
	if err != nil {
		log.Fatal(err)
	}
	tmpl, err := template.New("test").Parse(string(b))
	if err != nil {
		log.Fatal(err)
	}
	fileName := strings.Replace(path+outPath, "$", data.Model, -1)
	if FileExist(fileName) {
		err = os.Remove(fileName)
		if err != nil {
			log.Fatal(err)
		}
	}
	file, err := os.OpenFile(fileName, os.O_CREATE|os.O_WRONLY, 0755)
	if err != nil {
		log.Fatal(err)
	}
	err = tmpl.Execute(file, data)
	if err != nil {
		log.Fatal(err)
	}
}

//创建路由组代码
func AutoCreatFileServer(data []models.AutoCurdModel, putPath string, outPath string) {
	b, err := f.ReadFile(putPath)
	if err != nil {
		log.Fatal(err)
	}
	tmpl, err := template.New("foo").Parse(string(b))
	if err != nil {
		log.Fatal(err)
	}
	fileName := path + outPath
	if FileExist(fileName) {
		err = os.Remove(fileName)
		if err != nil {
			log.Fatal(err)
		}
	}
	file, err := os.OpenFile(fileName, os.O_CREATE|os.O_WRONLY, 0755)
	if err != nil {
		log.Fatal(err)
	}
	err = tmpl.Execute(file, map[string]interface{}{"data": data, "App": data[0].App})
	if err != nil {
		log.Fatal(err)
	}
}

func FindModelsList(name string, file string) {
	b, err := ioutil.ReadFile(file)
	if err != nil {
		log.Fatal(err)
	}
	var re = regexp.MustCompile(`type (.*?) struct`)
	dataList := []models.AutoCurdModel{}
	for _, match := range re.FindAllString(string(b), -1) {
		v := re.FindStringSubmatch(match)[1]
		data := models.AutoCurdModel{App: name, Model: v, Name: strings.ToLower(v)}
		AutoCreat(data)
		dataList = append(dataList, data)
	}
	AutoCreatMain(dataList)
}

//生成主函数代码
func AutoCreatMain(dataList []models.AutoCurdModel) {
	//Server
	AutoCreatFileServer(dataList, "templates/server.tpl", "/api/server.go")
	//Load
	AutoCreatFileServer(dataList, "templates/load.tpl", "/auto/load.go")
}

//创建文件组
func AutoCreat(data models.AutoCurdModel) {
	//Main
	AutoCreatFile(data, "templates/main.tpl", "/main.go")
	//Database
	AutoCreatFile(data, "templates/db.tpl", "/api/database/db.go")
	//Security
	AutoCreatFile(data, "templates/password.tpl", "/api/security/password.go")
	//Utils
	AutoCreatFile(data, "templates/channels.tpl", "/api/utils/channels/channels.go")
	AutoCreatFile(data, "templates/gpool.tpl", "/api/utils/gpool/gpool.go")
	//Config
	AutoCreatFile(data, "templates/config.tpl", "/config/config.go")
	//Crud
	AutoCreatFile(data, "templates/repository$Crud.tpl", "/api/repository/crud/repository$Crud.go")
	//Repository
	AutoCreatFile(data, "templates/repository$s.tpl", "/api/repository/repository$s.go")
	//Controllers
	AutoCreatFile(data, "templates/controller$s.tpl", "/api/controllers/controller$s.go")
}

func CopyConfig() {
	content, err := f.ReadFile("templates/config.env")
	if err != nil {
		log.Fatal(err)
	}
	err = ioutil.WriteFile("config.env", content, 0644)
	if err != nil {
		log.Fatal(err)
	}
}

func CopyModels(file string) {
	content, err := ioutil.ReadFile(file)
	if err != nil {
		log.Fatal(err)
	}
	err = ioutil.WriteFile(path+"/api/models/Models.go", content, 0644)
	if err != nil {
		log.Fatal(err)
	}
}

//go:embed templates
var f embed.FS

func main() {
	app := &cli.App{
		Name:  "api-cli",
		Usage: "gin后端api生成工具!",
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:  "name, n",
				Usage: "项目名称。",
			},
			&cli.StringFlag{
				Name:  "file, f",
				Usage: "指定model文件,使用绝对路径。",
			},
		},
		Action: func(c *cli.Context) error {
			name := c.String("n")
			file := c.String("f")
			if len(name) == 0 && len(file) == 0 {
				log.Fatal("参数错误！")
			} else {
				initPath()
				FindModelsList(name, file)
				CopyModels(file)
				CopyConfig()
			}
			return nil
		},
	}
	err := app.Run(os.Args)
	if err != nil {
		log.Fatal(err)
	}
}
