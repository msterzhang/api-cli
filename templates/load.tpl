package auto

import (
	"database/sql"
	"log"
	"{{.App}}/api/database"
	"{{.App}}/api/models"
	"{{.App}}/config"
)

func init() {
	db, err := sql.Open(config.DBDRIVER, config.DBDATAURL)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()
	_, err = db.Exec("CREATE DATABASE " + config.DBNAME + " default character set utf8mb4 collate utf8mb4_general_ci")
	if err != nil {
		log.Println("数据库已存在!")
		InitDatabase()
		return
	}
	log.Println("数据库创建成功！",err)
	InitDatabase()
}

func InitDatabase()  {
	err := database.InitDb()
	if err != nil {
		log.Fatal("Gorm初始化数据库失败！报错：" + err.Error())
	}
}

func Load() {
    var err error
	db := database.NewDb()
	{{range .data}}
	err = db.Debug().AutoMigrate(&models.{{.Model}}{},)
	if err != nil {
		log.Fatal(err)
	}
	{{end}}
}
