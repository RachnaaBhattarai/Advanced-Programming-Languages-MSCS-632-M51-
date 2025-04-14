import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.ReentrantLock;
import java.io.FileWriter;
import java.io.IOException;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

public class DataProcessingSystem {
    // Shared Queue and Lock
    private static final Queue<String> taskQueue = new LinkedList<>();
    private static final ReentrantLock queueLock = new ReentrantLock();
    private static final String OUTPUT_FILE = "output.txt";
    
    // Logger setup
    private static final Logger logger = Logger.getLogger(DataProcessingSystem.class.getName());
    
    static {
        try {
            // Configure file logging
            FileHandler fileHandler = new FileHandler("system.log", true);
            fileHandler.setFormatter(new SimpleFormatter());
            logger.addHandler(fileHandler);
            logger.setLevel(Level.INFO);
        } catch (IOException e) {
            System.err.println("Failed to set up logging: " + e.getMessage());
        }
    }

    // Worker Thread Class
    static class Worker implements Runnable {
        private final int workerId;
        private int tasksCompleted = 0;

        public Worker(int workerId) {
            this.workerId = workerId;
        }

        @Override
        public void run() {
            logger.info("Worker " + workerId + " started");
            
            try {
                while (true) {
                    String task = getTaskFromQueue();
                    if (task == null) {
                        logger.info("Worker " + workerId + " found no more tasks in queue, exiting");
                        break; // No more tasks, exit the loop
                    }
                    
                    logger.info("Worker " + workerId + " is processing task: " + task);
                    
                    try {
                        // Simulate task processing with delay
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        logger.log(Level.WARNING, "Worker " + workerId + " was interrupted during processing: " + e.getMessage(), e);
                        Thread.currentThread().interrupt(); // Restore interrupted status
                        break;
                    }
                    
                    String result = "Worker " + workerId + " completed task: " + task;
                    tasksCompleted++;

                    // Save results to shared output
                    try {
                        saveResult(result);
                    } catch (IOException e) {
                        logger.log(Level.SEVERE, "Worker " + workerId + " encountered error while writing results: " + e.getMessage(), e);
                    }
                }
            } catch (Exception e) {
                logger.log(Level.SEVERE, "Worker " + workerId + " encountered unexpected error: " + e.getMessage(), e);
            } finally {
                logger.info("Worker " + workerId + " completed " + tasksCompleted + " tasks and is terminating");
            }
        }

        private String getTaskFromQueue() {
            queueLock.lock();
            try {
                return taskQueue.poll(); // Retrieve and remove the task from the queue
            } finally {
                queueLock.unlock();
            }
        }

        private void saveResult(String result) throws IOException {
            synchronized (OUTPUT_FILE) {
                FileWriter writer = null;
                try {
                    writer = new FileWriter(OUTPUT_FILE, true);
                    writer.write(result + "\n");
                    logger.fine("Successfully wrote result to file: " + result);
                } catch (IOException e) {
                    logger.log(Level.SEVERE, "Error writing to output file: " + e.getMessage(), e);
                    throw e; // Re-throw to handle in the calling method
                } finally {
                    if (writer != null) {
                        try {
                            writer.close();
                        } catch (IOException e) {
                            logger.log(Level.WARNING, "Error closing file writer: " + e.getMessage(), e);
                        }
                    }
                }
            }
        }
    }

    // Add tasks to queue
    public static boolean addTask(String task) {
        if (task == null || task.isEmpty()) {
            logger.warning("Attempted to add null or empty task to queue");
            return false;
        }
        
        queueLock.lock();
        try {
            boolean result = taskQueue.offer(task); // Add task to the queue
            if (result) {
                logger.info("Added task to queue: " + task);
            } else {
                logger.warning("Failed to add task to queue: " + task);
            }
            return result;
        } finally {
            queueLock.unlock();
        }
    }

    public static void main(String[] args) {
        logger.info("Data Processing System starting up");
        
        // Adding tasks to the queue
        logger.info("Adding tasks to the queue");
        for (int i = 1; i <= 10; i++) {
            addTask("Task " + i);
        }

        // ExecutorService for managing worker threads
        int numWorkers = 5;
        logger.info("Creating executor service with " + numWorkers + " workers");
        ExecutorService executorService = Executors.newFixedThreadPool(numWorkers);

        // Creating and starting worker threads
        for (int i = 1; i <= numWorkers; i++) {
            executorService.submit(new Worker(i));
        }

        // Shutdown executor service properly
        logger.info("All workers submitted, initiating graceful shutdown");
        executorService.shutdown();
        
        try {
            // Wait for all tasks to complete or timeout
            boolean terminated = executorService.awaitTermination(30, TimeUnit.SECONDS);
            if (terminated) {
                logger.info("All workers completed successfully");
            } else {
                logger.warning("Timeout reached while waiting for workers to complete");
                // Force shutdown if timeout occurs
                executorService.shutdownNow();
            }
        } catch (InterruptedException e) {
            logger.log(Level.SEVERE, "Main thread was interrupted while waiting for workers: " + e.getMessage(), e);
            // Force shutdown if interrupted
            executorService.shutdownNow();
            Thread.currentThread().interrupt(); // Restore interrupted status
        }
        
        logger.info("Data Processing System shutting down");
    }
}