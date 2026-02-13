public class SimpleJavaApp {
    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("Simple Java Application Running in Airflow");
        System.out.println("========================================");
        
        System.out.println("\nSystem information:");
        System.out.println("- Java version: " + System.getProperty("java.version"));
        System.out.println("- Java vendor: " + System.getProperty("java.vendor"));
        System.out.println("- OS name: " + System.getProperty("os.name"));
        System.out.println("- User name: " + System.getProperty("user.name"));
        
        System.out.println("\nCommand line arguments:");
        if (args.length > 0) {
            for (int i = 0; i < args.length; i++) {
                System.out.println("  Arg[" + i + "]: " + args[i]);
            }
        } else {
            System.out.println("  No arguments provided");
        }
        
        // Simulate some work
        System.out.println("\nPerforming data processing...");
        long startTime = System.currentTimeMillis();
        
        // Simple processing loop
        int sum = 0;
        for (int i = 0; i < 10_000_000; i++) {
            sum += i;
        }
        
        long endTime = System.currentTimeMillis();
        System.out.println("Processing complete. Sum: " + sum);
        System.out.println("Processing time: " + (endTime - startTime) + " ms");
        
        System.out.println("\n========================================");
        System.out.println("Java Application Execution Complete");
        System.out.println("========================================");
    }
}
