package main

import ( 
	"fmt"
	"html"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello, this is a simple web server, it only responds with this message")
	})

	log.Fatal(http.ListenAndServe(":8080", nil))
}
