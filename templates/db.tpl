package database

import (
	_ "github.com/go-sql-driver/mysql"
	"github.com/jinzhu/gorm"
	"{{.App}}/config"
	"time"
)


var db *gorm.DB

func NewDb() *gorm.DB {
	return db
}

func InitDb() error {
	var err error
	db, err = gorm.Open(config.DBDRIVER, config.DBURL)
	if err != nil {
		return err
	}
	db.SingularTable(true)
	db.DB().SetConnMaxLifetime(1 * time.Second)
	db.DB().SetMaxIdleConns(20)
	db.DB().SetMaxOpenConns(1)
	db.SingularTable(true)
	db.LogMode(true)
	return nil
}

