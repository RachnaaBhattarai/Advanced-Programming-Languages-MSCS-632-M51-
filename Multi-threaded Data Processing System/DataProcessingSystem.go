package main

import (
	"fmt"
	"log"
	"os"
	"sync"
	"time"
)

const outputFile = "output.txt"

// DataProcessingSystem manages a task queue and worker pool
type DataProcessingSystem struct {
	taskQueue  chan string
	queueMutex sync.Mutex
	fileMutex  sync.Mutex
	logger     *log.Logger
}

// NewDataProcessingSystem creates a new processing system
func NewDataProcessingSystem(queueSize int) *DataProcessingSystem {
	// Create a logger that writes to stderr
	logger := log.New(os.Stderr, "", log.Ldate|log.Ltime)
	
	return &DataProcessingSystem{
		taskQueue: make(chan string, queueSize),
		logger:    logger,
	}
}

// Worker processes tasks from the queue
func (dps *DataProcessingSystem) Worker(workerId int, wg *sync.WaitGroup) {
	defer wg.Done()
	dps.logger.Printf("Worker %d started\n", workerId)
	
	taskCount := 0
	for task := range dps.taskQueue {
		dps.logger.Printf("Worker %d is processing task: %s\n", workerId, task)
		
		// Simulate task processing with delay
		time.Sleep(1 * time.Second)
		
		result := fmt.Sprintf("Worker %d completed task: %s", workerId, task)
		taskCount++
		
		// Save results to shared output
		err := dps.saveResult(result)
		if err != nil {
			dps.logger.Printf("ERROR: Worker %d encountered error while writing results: %v\n", workerId, err)
		}
	}
	
	dps.logger.Printf("Worker %d completed %d tasks and is terminating\n", workerId, taskCount)
}

// saveResult writes the result to the output file
func (dps *DataProcessingSystem) saveResult(result string) error {
	dps.fileMutex.Lock()
	defer dps.fileMutex.Unlock()
	
	file, err := os.OpenFile(outputFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return fmt.Errorf("failed to open output file: %w", err)
	}
	defer file.Close()
	
	_, err = file.WriteString(result + "\n")
	if err != nil {
		return fmt.Errorf("failed to write to output file: %w", err)
	}
	
	return nil
}

// AddTask adds a task to the queue with error handling for closed channel
func (dps *DataProcessingSystem) AddTask(task string) error {
	defer func() {
		if r := recover(); r != nil {
			dps.logger.Printf("ERROR: Failed to add task - queue may be closed: %v\n", r)
		}
	}()
	
	dps.taskQueue <- task
	return nil
}

// CloseQueue signals that no more tasks will be added
func (dps *DataProcessingSystem) CloseQueue() {
	dps.logger.Println("Closing task queue, no more tasks will be accepted")
	close(dps.taskQueue)
}

func main() {
	// Set up logging to file and console
	logFile, err := os.OpenFile("system.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to open log file: %v\n", err)
		return
	}
	defer logFile.Close()
	
	log.SetOutput(logFile)
	log.Println("Data Processing System starting up")
	
	// Create the processing system with a buffered channel
	dps := NewDataProcessingSystem(10)
	
	// Adding tasks to the queue
	log.Println("Adding tasks to the queue")
	for i := 1; i <= 10; i++ {
		taskName := fmt.Sprintf("Task %d", i)
		err := dps.AddTask(taskName)
		if err != nil {
			log.Printf("Failed to add task %s: %v\n", taskName, err)
		}
	}
	
	// Signal that we're done adding tasks
	dps.CloseQueue()
	
	// Create wait group to wait for all workers to complete
	var wg sync.WaitGroup
	
	// Number of worker goroutines
	numWorkers := 5
	log.Printf("Starting %d worker goroutines\n", numWorkers)
	wg.Add(numWorkers)
	
	// Start worker goroutines
	for i := 1; i <= numWorkers; i++ {
		go dps.Worker(i, &wg)
	}
	
	// Wait for all workers to finish
	log.Println("Waiting for all workers to complete")
	wg.Wait()
	log.Println("All workers have completed, system shutting down")
}