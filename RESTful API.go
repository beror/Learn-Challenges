package main

import (
	"fmt"
	"log"
	"net/http"
	"encoding/json"
	"github.com/gorilla/mux"
	
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
)

var db *sql.DB

type PLang struct {
	ID int `json:"id,omitempty"`
	Name string `json:"name,omitempty"`
}

func GetPLanguageEndpoint(w http.ResponseWriter, req *http.Request) {
	params := mux.Vars(req)
	rows, _ := db.Query("SELECT PLangID, Name FROM programming_languages WHERE PLangID = ?", params["id"])
	
	for rows.Next() {
		var pLang PLang
		rows.Scan(&pLang.ID, &pLang.Name)
		json.NewEncoder(w).Encode(&pLang)
		return
	}
	
	json.NewEncoder(w).Encode(&PLang{})
}

func GetPLanguagesEndpoint(w http.ResponseWriter, req *http.Request) {
	rows, _ := db.Query("SELECT PLangID, Name FROM programming_languages")
	
	var pLangs []PLang
	var pLangID int
	var pLangName string
	
	for rows.Next() {
		rows.Scan(&pLangID, &pLangName)
		pLangs = append(pLangs, PLang{ID: pLangID, Name: pLangName})
	}
	
	json.NewEncoder(w).Encode(&pLangs)
}

func AddPLanguageEndpoint(w http.ResponseWriter, req *http.Request) {
	var pLang PLang

	json.NewDecoder(req.Body).Decode(&pLang)
	
	db.Exec("INSERT INTO `programming_languages`.`programming_languages`(Name) VALUES(?)", pLang.Name)
	
	GetPLanguagesEndpoint(w, req)
}

func EditPLanguageEndpoint(w http.ResponseWriter, req *http.Request) {
	params := mux.Vars(req)
	
	var pLang PLang
	
	json.NewDecoder(req.Body).Decode(&pLang)
	
	
	stmt := "UPDATE programming_languages SET "
	presentParamsCounter := 0
	if pLang.ID != 0 {
		stmt += "PLangID = ?"
		presentParamsCounter++
	}
	if pLang.Name != "" {
		if presentParamsCounter >= 1 {
			stmt += ", Name = ?"
		} else {
			stmt += "Name = ?"
		}
		presentParamsCounter++
	}
	stmt += "WHERE PLangID = ?"
	
	db.Exec("UPDATE programming_languages SET PLangID = ?, Name = ? WHERE PLangID = ?", pLang.ID, pLang.Name, params["id"])
	
	rows, _ := db.Query("SELECT PLangID, Name FROM programming_languages WHERE PLangID = ?", pLang.ID)
	
	for rows.Next() {
		rows.Scan(&pLang.ID, &pLang.Name) //should pLang be used this way (one purpose at the beginning, another one here)?
		json.NewEncoder(w).Encode(&pLang)
	}
}

func DeletePLanguageEndpoint(w http.ResponseWriter, req *http.Request) {
	params := mux.Vars(req)
	
	db.Exec("DELETE FROM programming_languages WHERE PLangID = ?", params["id"])
	
	GetPLanguagesEndpoint(w, req)
}

func main() {
	fmt.Println("A server\n")
	fmt.Println("Opening database")
	var errDB error 
	db, errDB = sql.Open("mysql", "root:password@tcp(localhost:3306)/programming_languages")
	if errDB == nil {
		fmt.Println("Database opened successfuly")
	}
	defer db.Close()
	
	router := mux.NewRouter()
	router.HandleFunc("/PLanguages/{id}", GetPLanguageEndpoint).Methods("GET")
	router.HandleFunc("/PLanguages", GetPLanguagesEndpoint).Methods("GET")
	router.HandleFunc("/PLanguages", AddPLanguageEndpoint).Methods("POST")
	router.HandleFunc("/PLanguages/{id}", DeletePLanguageEndpoint).Methods("DELETE")
	router.HandleFunc("/PLanguages/{id}", EditPLanguageEndpoint).Methods("PUT")
	
	log.Fatal(http.ListenAndServe(":8085", router))
}