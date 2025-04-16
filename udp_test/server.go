package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"time"
)

const (
	payloadSize = 1024 // Maximum is 1472
)

func makePayload(data int64, byteSize int) []byte {
	// Convert to byte slice
	dataBytes := make([]byte, byteSize)
	for i := 0; i < 8; i++ {
		dataBytes[i] = byte(data >> uint(56-i*8))
	}

	// Create payload with time bytes and padding zeros
	payload := make([]byte, payloadSize)
	copy(payload, dataBytes)
	// for i := len(dataBytes); i < payloadSize; i++ {
	// 	payload[i] = 'A'
	// }

	return payload
}

func main() {
	addrString := flag.String("addr", "0.0.0.0:8080", "Server IP address and port number")
	rate := flag.Int64("rate", 1, "Packet sends per second")
	filename := flag.String("file", "server.log", "Default trace filename")

	flag.Parse()

	log.Println("Server started and listening on ", *addrString)
	log.Printf("Send at %d packet/s\n", *rate)
	log.Println("Trace saved at ", *filename)

	serverAddr, err := net.ResolveUDPAddr("udp", *addrString)
	serverConn, err := net.ListenUDP("udp", serverAddr)
	if err != nil {
		log.Fatalf("Error listening on UDP: %v", err)
	}
	defer serverConn.Close()

	// Wait for the first packet from the client
	buffer := make([]byte, payloadSize)
	_, remoteAddr, err := serverConn.ReadFromUDP(buffer)
	if err != nil {
		log.Fatalf("Error reading from UDP: %v", err)
	}

	log.Printf("Received initial packet from %v", remoteAddr)

	// Configure the sending rate (packets per second)
	delay := time.Second / time.Duration(*rate)

	// Trace file
	f, err := os.OpenFile(*filename, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatalf("Error Opening file: %v", err)
	}
	defer f.Close()

	for {
		// Get current Unix time in milliseconds
		// currentTime := time.Now().UnixNano() / int64(time.Millisecond)
		currentTime := time.Now().UnixMilli()
		// fmt.Printf("current time: %d\n", currentTime)

		payload := makePayload(currentTime, 8)

		// Send the packet
		_, err = serverConn.WriteToUDP(payload, remoteAddr)
		if err != nil {
			log.Printf("Error writing to UDP: %v", err)
		}
		// else {
		//   log.Printf("Packet sent at %v with payload: %s", time.Now(), string(payload))
		// }

		// Write the line to the file
		_, err = fmt.Fprintf(f, "%d\n", currentTime)
		if err != nil {
			log.Printf("Error writing to file: %v", err)
		}

		// Delay to control the sending rate
		time.Sleep(delay)
	}
}
