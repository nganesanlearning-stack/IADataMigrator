public class AirflowJavaTask {
    public static void main(String[] args) {
        System.out.println("============================================================");
        System.out.println("Java Application Executed from Airflow DAG");
        System.out.println("============================================================");
        
        // Print execution timestamp
        System.out.println("Execution time: " + new java.util.Date());
        
        // Print Java environment information
        System.out.println("\nJava Environment:");
        System.out.println("- Java version: " + System.getProperty("java.version"));
        System.out.println("- Java home: " + System.getProperty("java.home"));
        System.out.println("- OS name: " + System.getProperty("os.name"));
        
        // Process command line arguments from Airflow
        System.out.println("\nCommand Line Arguments from Airflow:");
        if (args.length > 0) {
            for (int i = 0; i < args.length; i++) {
                System.out.println("  Arg[" + i + "]: " + args[i]);
            }
        } else {
            System.out.println("  No arguments provided");
        }
        
        // Simulate data processing
        System.out.println("\nProcessing data...");
        try {
            // Simulate some work
            int processedItems = processData(100);
            System.out.println("Successfully processed " + processedItems + " items.");
            
            // Sleep to simulate longer processing
            System.out.println("Finalizing processing...");
            Thread.sleep(2000);
            
        } catch (Exception e) {
            System.err.println("Error during processing: " + e.getMessage());
            System.exit(1);
        }
        
        System.out.println("\nJava application completed successfully!");
        System.out.println("============================================================");
    }
    
    /**
     * Simulates data processing with artificial computation
     */
    private static int processData(int itemCount) throws InterruptedException {
        System.out.println("Starting processing of " + itemCount + " items...");
        
        // Simulate processing time
        for (int i = 0; i < itemCount; i++) {
            if (i % 10 == 0) {
                System.out.println("  - Processed " + i + " of " + itemCount);
                Thread.sleep(200); // Small delay every 10 items
            }
            
            // Do some dummy calculation
            double result = 0;
            for (int j = 0; j < 100000; j++) {
                result += Math.sqrt(j * Math.PI);
            }
        }
        
        return itemCount;
    }
}
