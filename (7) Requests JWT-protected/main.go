package main

import (
	"fmt"
	"log"
	"net/http"
	"encoding/json"
	"github.com/gorilla/mux"
	"strings"
	
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
	"github.com/dgrijalva/jwt-go"
	
	"time"
)

var db *sql.DB
var createdJWT string

type PLang struct {
	ID int `json:"id,omitempty"`
	Name string `json:"name,omitempty"`
}

type User struct {
	Username string `json:"username,omitempty"`
	Password string `json:"password,omitempty"`
}

func GetPLanguageEndpoint(w http.ResponseWriter, req *http.Request) {
	params := mux.Vars(req)
	
	fmt.Println("GET", params["id"], time.Now(), "\n")
	
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
	fmt.Println("GET", time.Now())
	fmt.Println("Headers:", req.Header, "\n")
	
	pLangs := []PLang{}
	
	if(createdJWT == strings.Split(req.Header.Get("Authorization"), " ")[1]) {
		fmt.Println("JWTs are the same\n")
		
		rows, _ := db.Query("SELECT PLangID, Name FROM programming_languages")
		
		
		var pLangID int
		var pLangName string
		
		for rows.Next() {
			rows.Scan(&pLangID, &pLangName)
			pLangs = append(pLangs, PLang{ID: pLangID, Name: pLangName})
		}
		
		fmt.Println("GET pLangs:", pLangs)
		fmt.Println("pLangs length:", len(pLangs))
	} else {
		fmt.Println("JWTs are not the same")
		w.WriteHeader(http.StatusUnauthorized)
	}
	json.NewEncoder(w).Encode(&pLangs)
}

func AddPLanguageEndpoint(w http.ResponseWriter, req *http.Request) {
	if(createdJWT == strings.Split(req.Header.Get("Authorization"), " ")[1]) {
		var pLang PLang

		json.NewDecoder(req.Body).Decode(&pLang)
		
		fmt.Println("POST", time.Now(), "\n", pLang.ID, "\n", pLang.Name)	
		
		db.Exec("INSERT INTO `programming_languages`.`programming_languages`(Name) VALUES(?)", pLang.Name)
		
		GetPLanguagesEndpoint(w, req)
	} else {
		fmt.Println("JWTs are not the same")
		w.WriteHeader(http.StatusUnauthorized)
	}
}

func EditPLanguageEndpoint(w http.ResponseWriter, req *http.Request) {
	if(createdJWT == strings.Split(req.Header.Get("Authorization"), " ")[1]) {
		params := mux.Vars(req)
		
		var pLang PLang
		
		json.NewDecoder(req.Body).Decode(&pLang)
		
		fmt.Println("PUT", time.Now(), "\n", pLang.ID, "\n", pLang.Name, "\n")
		
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
	} else {
		fmt.Println("JWTs are not the same")
		w.WriteHeader(http.StatusUnauthorized)
	}
}

func DeletePLanguageEndpoint(w http.ResponseWriter, req *http.Request) {
	if(createdJWT == strings.Split(req.Header.Get("Authorization"), " ")[1]) {
		params := mux.Vars(req)
		
		fmt.Println("DELETE", params["id"], time.Now(), "\n")
		
		db.Exec("DELETE FROM programming_languages WHERE PLangID = ?", params["id"])
		
		GetPLanguagesEndpoint(w, req)
	} else {
		fmt.Println("JWTs are not the same")
		w.WriteHeader(http.StatusUnauthorized)
	}
}

func LoginEndpoint(w http.ResponseWriter, req *http.Request) {
	var user User
	
	fmt.Println(user.Username)
	fmt.Println(user.Password)

	json.NewDecoder(req.Body).Decode(&user)
	
	fmt.Println("Decoded body:")
	fmt.Println(user.Username)
	fmt.Println(user.Password)
	
	rows, errDB := db.Query("SELECT Username, Password FROM programming_languages.users WHERE Username = ? AND Password = ?", user.Username, user.Password)
	if(errDB != nil) {
		fmt.Println("Error querying database")
	}
	
	user.Username = ""
	user.Password = ""
	
	for rows.Next() {
		rows.Scan(&user.Username, &user.Password)
	}
	
	fmt.Println("Query result:")
	fmt.Println(user.Username)
	fmt.Println(user.Password)
	
	if user.Username != "" && user.Password != "" {
			fmt.Println("Found the user in the database")
			token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims {
				"username": user.Username,
				"userPermissionLevel": "0",
				})
			createdJWT, _ = token.SignedString([]byte("notReallyASecret"))
			w.Header().Set("Authorization", "Bearer " + createdJWT)
		} else {
			fmt.Println("No such user found")
		}
}

func main() {
	fmt.Println("A server\n")
	fmt.Println("Opening database")
	var errDB error 
	db, errDB = sql.Open("mysql", "root:password@tcp(localhost:3306)/programming_languages")
	if errDB == nil {
		fmt.Println("Database opened successfuly\n")
	} else {
		fmt.Println("Couldn't open database\n")
	}
	defer db.Close()
	
	router := mux.NewRouter()
	router.HandleFunc("/PLanguages/{id}", GetPLanguageEndpoint).Methods("GET")
	router.HandleFunc("/PLanguages", GetPLanguagesEndpoint).Methods("GET")
	router.HandleFunc("/PLanguages", AddPLanguageEndpoint).Methods("POST")
	router.HandleFunc("/PLanguages/{id}", DeletePLanguageEndpoint).Methods("DELETE")
	router.HandleFunc("/PLanguages/{id}", EditPLanguageEndpoint).Methods("PUT")
	router.HandleFunc("/login", LoginEndpoint).Methods("POST")
	
	log.Fatal(http.ListenAndServe(":8085", router))
}
