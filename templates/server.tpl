package api

import (
	"fmt"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"{{.App}}/api/controllers"
	"{{.App}}/auto"
	"{{.App}}/config"
	"time"
)

func init() {
	auto.Load()
}


func Run() {
	// Disable Console Color, you don't need console color when writing the logs to file.
	gin.DisableConsoleColor()

	// Logging to a file.
	//f, _ := os.Create("gin.log")
	//gin.DefaultWriter = io.MultiWriter(f)
	//gin.SetMode(gin.ReleaseMode)

	//系统初始化
	r := gin.Default()
	r.Use(cors.New(cors.Config{
		AllowOriginFunc:  func(origin string) bool { return true },
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "PATCH"},
		AllowHeaders:     []string{"Origin", "Content-Length", "Content-Type"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	//网络测试
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})
	{{range .data}}
    {{.Name}} := r.Group("/v1/api/{{.Name}}")
    {{.Name}}.POST("/create", controllers.Create{{.Model}})
    {{.Name}}.POST("/update", controllers.Update{{.Model}}ById)
    {{.Name}}.POST("/delete", controllers.Delete{{.Model}}ById)
    {{.Name}}.POST("/id", controllers.Get{{.Model}}ById)
    {{.Name}}.POST("/list", controllers.Get{{.Model}}List)
    {{.Name}}.POST("/search", controllers.Search{{.Model}})
    {{end}}
	r.Run(fmt.Sprintf(":%d", config.PORT))

}
