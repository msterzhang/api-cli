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
	"embed"
	"fmt"
	"github.com/urfave/cli"
	"io/ioutil"
	"log"
	"os"
	"regexp"
	"strings"
	"text/template"
)

var p, _ = os.Getwd()
var path = strings.Replace(p, "\\", "/", -1)

type AutoCurdModel struct {
	App   string
	Name  string
	Model string
}

func initMain() {
	var err error
	err = os.RemoveAll(path + "/api")
	err = os.Mkdir("api", os.ModePerm)
	err = os.Mkdir("auto", os.ModePerm)
	err = os.Mkdir("config", os.ModePerm)
	err = os.MkdirAll("api/controllers", os.ModePerm)
	err = os.MkdirAll("api/database", os.ModePerm)
	err = os.MkdirAll("api/models", os.ModePerm)
	err = os.MkdirAll("api/repository/crud", os.ModePerm)
	err = os.MkdirAll("api/security", os.ModePerm)
	err = os.MkdirAll("api/utils/channels", os.ModePerm)
	err = os.MkdirAll("api/utils/gpool", os.ModePerm)
	err = os.Remove(path + "/api/models/Models.go")
	if err != nil {
	}
}


//模板替换生成代码
func AutoCreatFile(data AutoCurdModel, putPath string, outPath string) {
	b, err := f.ReadFile(putPath)
	if err != nil {
		fmt.Print(err)
	}
	tmpl, err := template.New("test").Parse(string(b))
	if err != nil {
		panic(err)
	}
	fileName := strings.Replace(path+outPath, "$", data.Model, -1)
	err = os.Remove(fileName)
	if err != nil {

	}
	file, err := os.OpenFile(fileName, os.O_CREATE|os.O_WRONLY, 0755)
	err = tmpl.Execute(file, data)
	if err != nil {
		panic(err)
	}
}

//创建路由组代码
func AutoCreatFileServer(data []AutoCurdModel, putPath string, outPath string) {
	b, err := f.ReadFile(putPath)
	if err != nil {
		fmt.Print(err)
	}
	tmpl, err := template.New("foo").Parse(string(b))
	if err != nil {
		panic(err)
	}
	fileName := path + outPath
	err = os.Remove(fileName)
	if err != nil {

	}
	file, err := os.OpenFile(fileName, os.O_CREATE|os.O_WRONLY, 0755)
	err = tmpl.Execute(file, map[string]interface{}{"data": data, "App": data[0].App})
	if err != nil {
		panic(err)
	}
}

//
func FindModelsList(name string, file string) {
	b, err := ioutil.ReadFile(file)
	if err != nil {
		fmt.Print(err)
	}
	var re = regexp.MustCompile(`type (.*?) struct`)
	dataList := []AutoCurdModel{}
	for _, match := range re.FindAllString(string(b), -1) {
		v := re.FindStringSubmatch(match)[1]
		data := AutoCurdModel{App: name, Model: v, Name: strings.ToLower(v)}
		AutoCreat(data)
		dataList = append(dataList, data)
	}
	AutoCreatMain(dataList)
}

//生成主函数代码
func AutoCreatMain(dataList []AutoCurdModel) {
	//Server
	AutoCreatFileServer(dataList, "templates/server.tpl", "/api/server.go")
	//Load
	AutoCreatFileServer(dataList, "templates/load.tpl", "/auto/load.go")
}

//创建文件组
func AutoCreat(data AutoCurdModel) {
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
	AutoCreatFile(data, "templates/repository_$_crud.tpl", "/api/repository/crud/repository_$_crud.go")
	//Repository
	AutoCreatFile(data, "templates/repository_$s.tpl", "/api/repository/repository_$s.go")
	//Controllers
	AutoCreatFile(data, "templates/controllers_$s.tpl", "/api/controllers/controllers_$s.go")
}

func CopyConfig()  {
	content, err := f.ReadFile("templates/config.env")
	if err != nil {
		panic(err)
	}
	err = ioutil.WriteFile("config.env", content, 0644)
	if err != nil {
		panic(err)
	}
}

func CopyModels(file string)  {
	content, err := ioutil.ReadFile(file)
	if err != nil {
		panic(err)
	}
	err = ioutil.WriteFile(path+"/api/models/Models.go", content, 0644)
	if err != nil {
		panic(err)
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
				fmt.Println("参数错误！")
			} else {
				initMain()
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
