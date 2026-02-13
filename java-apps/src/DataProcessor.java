package com.example;

public class DataProcessor {
    public static void main(String[] args) {
        System.out.println("===== Java Application in Airflow =====");
        System.out.println("Processing data...");
        
        // Process arguments if provided
        if (args.length > 0) {
            System.out.println("Arguments received:");
            for (int i = 0; i < args.length; i++) {
                System.out.println("  Arg " + i + ": " + args[i]);
            }
        } else {
            System.out.println("No arguments provided.");
        }
        
        // Simulate processing
        try {
            System.out.println("Starting data processing task...");
            Thread.sleep(2000); // Simulate work
            System.out.println("Data processing completed successfully!");
        } catch (InterruptedException e) {
            System.err.println("Processing interrupted: " + e.getMessage());
            System.exit(1);
        }
        
        System.out.println("Java application execution completed.");
    }
}
