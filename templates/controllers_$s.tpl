package controllers

import (
	"{{.App}}/api/database"
	"{{.App}}/api/models"
	"{{.App}}/api/repository"
	"{{.App}}/api/repository/crud"
	"strconv"
	"github.com/gin-gonic/gin"
)


func Create{{.Model}}(c *gin.Context) {
	{{.Name}} := models.{{.Model}}{}
	err := c.ShouldBind(&{{.Name}})
	if err != nil {
		c.JSON(200, gin.H{"code": 201, "msg": "创建失败,表单解析出错！", "data": {{.Name}}})
		return
	}
	db := database.NewDb()
	repo := crud.NewRepository{{.Model}}sCRUD(db)
	func({{.Name}}Repository repository.{{.Model}}Repository) {
		{{.Name}}, err := {{.Name}}Repository.Save({{.Name}})
		if err != nil {
			c.JSON(200, gin.H{"code": 201, "msg": "创建失败！", "data": {{.Name}}})
			return
		}
		c.JSON(200, gin.H{"code": 200, "msg": "创建成功！", "data": {{.Name}}})
	}(repo)
}


func Delete{{.Model}}ById(c *gin.Context) {
	id := c.Query("id")
	db := database.NewDb()
	repo := crud.NewRepository{{.Model}}sCRUD(db)
	func({{.Name}}Repository repository.{{.Model}}Repository) {
		{{.Name}}, err := {{.Name}}Repository.DeleteByID(id)
		if err != nil {
			c.JSON(200, gin.H{"code": 201, "msg": "没有查询到资源！", "data": {{.Name}}})
			return
		}
		c.JSON(200, gin.H{"code": 200, "msg": "删除资源成功！", "data": {{.Name}}})
	}(repo)
}

func Update{{.Model}}ById(c *gin.Context) {
	id := c.Query("id")
	{{.Name}} := models.{{.Model}}{}
	err := c.ShouldBind(&{{.Name}})
	if err != nil {
		c.JSON(200, gin.H{"code": 201, "msg": "创建失败,表单解析出错！", "data": {{.Name}}})
		return
	}
	db := database.NewDb()
	repo := crud.NewRepository{{.Model}}sCRUD(db)
	func({{.Name}}Repository repository.{{.Model}}Repository) {
		{{.Name}}, err := {{.Name}}Repository.UpdateByID(id, {{.Name}})
		if err != nil {
			c.JSON(200, gin.H{"code": 201, "msg": "没有查询到资源！", "data": {{.Name}}})
			return
		}
		c.JSON(200, gin.H{"code": 200, "msg": "更新资源成功！", "data": {{.Name}}})
	}(repo)
}


func Get{{.Model}}ById(c *gin.Context) {
	id := c.Query("id")
	db := database.NewDb()
	repo := crud.NewRepository{{.Model}}sCRUD(db)
	func({{.Name}}Repository repository.{{.Model}}Repository) {
		{{.Name}}, err := {{.Name}}Repository.FindByID(id)
		if err != nil {
			c.JSON(200, gin.H{"code": 201, "msg": "没有查询到资源！", "data": {{.Name}}})
			return
		}
		c.JSON(200, gin.H{"code": 200, "msg": "查询资源成功！", "data": {{.Name}}})
	}(repo)
}


func Get{{.Model}}List(c *gin.Context) {
	page, errPage := strconv.Atoi(c.Query("page"))
	size, errSize := strconv.Atoi(c.Query("size"))
	if errPage != nil {
		page = 1
	}
	if errSize != nil {
		size = 8
	}
	db := database.NewDb()
	repo := crud.NewRepository{{.Model}}sCRUD(db)
	func({{.Name}}Repository repository.{{.Model}}Repository) {
		{{.Name}}s, num, err := {{.Name}}Repository.FindAll(page,size)
		if err != nil {
			c.JSON(200, gin.H{"code": 201, "msg": "没有查询到资源！", "data": {{.Name}}s, "num": num})
			return
		}
		c.JSON(200, gin.H{"code": 200, "msg": "查询资源成功！", "data": {{.Name}}s, "num": num})
	}(repo)
}

func Search{{.Model}}(c *gin.Context) {
	q:=c.Query("q")
	if len(q)==0{
		c.JSON(200, gin.H{"code": 201, "msg": "参数错误！", "data":""})
		return
	}
	page, errPage := strconv.Atoi(c.Query("page"))
    	size, errSize := strconv.Atoi(c.Query("size"))
    	if errPage != nil {
    		page = 1
    	}
    	if errSize != nil {
    		size = 8
    }
	db := database.NewDb()
	repo := crud.NewRepository{{.Model}}sCRUD(db)
	func({{.Name}}Repository repository.{{.Model}}Repository) {
		{{.Name}}s, num, err := {{.Name}}Repository.Search(q, page, size)
		if err != nil {
			c.JSON(200, gin.H{"code": 201, "msg": "没有查询到资源！", "data": {{.Name}}s, "num": num})
			return
		}
		c.JSON(200, gin.H{"code": 200, "msg": "查询资源成功！", "data": {{.Name}}s, "num": num})
	}(repo)
}