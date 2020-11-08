package main

import ( 
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello, this is a simple web server, it only responds with this message\n")
	})

	log.Fatal(http.ListenAndServe(":8080", nil))
}
