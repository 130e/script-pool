package main

import (
	"encoding/binary"
  "flag"
	"fmt"
	"log"
	"net"
	"os"
	"time"
)

func main() {
	addrString := flag.String("addr", "0.0.0.0:8080", "Server IP address and port number")
	filename := flag.String("file", "client.log", "Default trace filename")

	flag.Parse()

	log.Println("Server address ", *addrString)
	log.Println("Trace saved at ", *filename)
	// Create a UDP client
	serverAddr, err := net.ResolveUDPAddr("udp", *addrString)
	if err != nil {
		log.Fatalf("Error resolving UDP address: %v", err)
		return
	}

	clientConn, err := net.DialUDP("udp", nil, serverAddr)
	if err != nil {
		log.Fatalf("Error dialing UDP: %v", err)
		return
	}
	defer clientConn.Close()

	// Trace file
	f, err := os.OpenFile(*filename, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatalf("Error Opening file: %v", err)
	}
	defer f.Close()

	// Send a message to the server
	message := []byte("Hello from client!")
	_, err = clientConn.Write(message)
	if err != nil {
		fmt.Println("Error writing to UDP:", err)
		return
	}

	// Start receiving flooding
	buffer := make([]byte, 1024)
	for {
		_, _, err := clientConn.ReadFromUDP(buffer)
		if err != nil {
			log.Printf("Error reading from UDP: %v", err)
			return
		}

		sendTimeMs := int64(binary.BigEndian.Uint64(buffer[:8]))
		currentTime := time.Now().UnixMilli()

		// Write the line to the file
		_, err = fmt.Fprintf(f, "%d,%d\n", sendTimeMs, currentTime)
		if err != nil {
			log.Printf("Error writing to file: %v", err)
		}
		// fmt.Printf("Received response from server: %s\n", string(buffer[:n]))
	}
}
