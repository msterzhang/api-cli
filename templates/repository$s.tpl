package repository

import "{{.App}}/api/models"

type {{.Model}}Repository interface {
	Save(models.{{.Model}}) (models.{{.Model}}, error)
	FindAll(page int,size int) ([]models.{{.Model}},int , error)
	FindByID(string) (models.{{.Model}}, error)
	UpdateByID(string, models.{{.Model}}) (int64, error)
	DeleteByID(string) (int64, error)
	Search(string,int,int) ([]models.{{.Model}}, int, error)
}

