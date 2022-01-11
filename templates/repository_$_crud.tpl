package crud

import (
	"errors"
	"{{.App}}/api/models"
	"{{.App}}/api/utils/channels"
	"github.com/jinzhu/gorm"
	"strconv"
)

// Repository{{.Model}}sCRUD is the struct for the {{.Model}} CRUD
type Repository{{.Model}}sCRUD struct {
	db *gorm.DB
}

// NewRepository{{.Model}}sCRUD returns a new repository with DB connection
func NewRepository{{.Model}}sCRUD(db *gorm.DB) *Repository{{.Model}}sCRUD {
	return &Repository{{.Model}}sCRUD{db}
}

// Save returns a new {{.Name}} created or an error
func (r *Repository{{.Model}}sCRUD) Save({{.Name}} models.{{.Model}}) (models.{{.Model}}, error) {
	var err error
	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)
		err = r.db.Debug().Model(&models.{{.Model}}{}).Create(&{{.Name}}).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)
	if channels.OK(done) {
		return {{.Name}}, nil
	}
	return models.{{.Model}}{}, err
}

// FindAll returns all the {{.Name}}s from the DB
func (r *Repository{{.Model}}sCRUD) FindAll(page int,size int) ([]models.{{.Model}}, int, error) {
	var err error
	var num int
	{{.Name}}s := []models.{{.Model}}{}
	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)
		result := r.db.Debug().Model(&models.{{.Model}}{}).Find(&{{.Name}}s)
		result.Count(&num)
        err = result.Limit(strconv.Itoa(size)).Offset(strconv.Itoa((page - 1) * size)).Order("-ID").Scan(&{{.Name}}s).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)
	if channels.OK(done) {
		return {{.Name}}s, num, nil
	}
	return nil, 0, err
}

// FindByID returns an {{.Name}} from the DB
func (r *Repository{{.Model}}sCRUD) FindByID(id string) (models.{{.Model}}, error) {
	var err error
	{{.Name}} := models.{{.Model}}{}
	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)
		err = r.db.Debug().Model(&models.{{.Model}}{}).Where("id = ?", id).Take(&{{.Name}}).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)
	if channels.OK(done) {
		return {{.Name}}, nil
	}

	if gorm.IsRecordNotFoundError(err) {
		return models.{{.Model}}{}, errors.New("{{.Model}} Not Found")
	}
	return models.{{.Model}}{}, err
}

// Update updates an {{.Name}} from the DB
func (r *Repository{{.Model}}sCRUD) UpdateByID(id string, {{.Name}} models.{{.Model}}) (int64, error) {
	var rs *gorm.DB
	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)
		rs = r.db.Debug().Model(&models.{{.Model}}{}).Where("id = ?", id).Update(&{{.Name}})
		ch <- true
	}(done)

	if channels.OK(done) {
		if rs.Error != nil {
			return 0, rs.Error
		}

		return rs.RowsAffected, nil
	}
	return 0, rs.Error
}

// Delete removes an {{.Name}} from the DB
func (r *Repository{{.Model}}sCRUD) DeleteByID(id string) (int64, error) {
	var rs *gorm.DB
	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)
		rs = r.db.Debug().Model(&models.{{.Model}}{}).Where("id = ?", id).Take(&models.{{.Model}}{}).Delete(&models.{{.Model}}{})
		ch <- true
	}(done)

	if channels.OK(done) {
		if rs.Error != nil {
			return 0, rs.Error
		}

		return rs.RowsAffected, nil
	}
	return 0, rs.Error
}

// Search removes an {{.Name}} from the DB
func (r *Repository{{.Model}}sCRUD) Search(q string, page int, size int) ([]models.{{.Model}}, int, error) {
	var err error
	var num int
	{{.Name}}s := []models.{{.Model}}{}
	done := make(chan bool)
	go func(ch chan<- bool) {
		defer close(ch)
		result := r.db.Debug().Model(&models.{{.Model}}{}).Where("key LIKE ?","%"+q+"%")
        result.Count(&num)
        err = result.Limit(strconv.Itoa(size)).Offset(strconv.Itoa((page - 1) * size)).Order("-updated_at").Scan(&{{.Name}}s).Error
		if err != nil {
			ch <- false
			return
		}
		ch <- true
	}(done)
	if channels.OK(done) {
		return {{.Name}}s, num, nil
	}
	if gorm.IsRecordNotFoundError(err) {
		return []models.{{.Model}}{}, 0, errors.New("{{.Model}}s Not Found")
	}
	return []models.{{.Model}}{}, 0, err
}

