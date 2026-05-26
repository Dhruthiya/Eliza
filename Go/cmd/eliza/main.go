package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	"eliza-go/internal/engine"
	"eliza-go/internal/script"
	elizaweb "eliza-go/internal/web"
)

func main() {
	var (
		webMode       bool
		dataPath      string
		port          int
		deterministic bool
	)

	flag.BoolVar(&webMode, "web", false, "run the web server")
	flag.StringVar(&dataPath, "data", "", "path to ELIZA data directory")
	flag.IntVar(&port, "port", 4000, "port for web server")
	flag.BoolVar(&deterministic, "deterministic", false, "disable random greeting/final selection")
	flag.Parse()

	loadedScript, err := script.LoadScript(dataPath)
	if err != nil {
		log.Fatalf("failed to load ELIZA script: %v", err)
	}

	eliza := engine.New(loadedScript, deterministic)

	if webMode {
		root, err := script.ResolveProjectRoot()
		if err != nil {
			log.Fatalf("failed to resolve project root: %v", err)
		}

		server := elizaweb.NewServer(eliza, root)
		if err := server.ListenAndServe(port); err != nil {
			log.Fatal(err)
		}
		return
	}

	runCLI(eliza)
}

func runCLI(eliza *engine.Engine) {
	reader := bufio.NewReader(os.Stdin)

	fmt.Println()
	fmt.Println("=== ELIZA - The Original Chatbot ===")
	fmt.Println()
	fmt.Printf("ELIZA: %s\n\n", eliza.InitialGreeting())

	for {
		fmt.Print("YOU: ")
		input, err := reader.ReadString('\n')
		if err != nil {
			fmt.Println()
			return
		}
		input = strings.TrimSpace(input)

		response, quit, err := eliza.Transform(input)
		if err != nil {
			log.Fatalf("transform failed: %v", err)
		}

		fmt.Printf("ELIZA: %s\n\n", response)
		if quit {
			fmt.Println("Goodbye!")
			return
		}
	}
}
