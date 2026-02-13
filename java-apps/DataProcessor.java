public class DataProcessor {
    public static void main(String[] args) {
        System.out.println("=== Data Processing Application ===");
        
        if (args.length < 2) {
            System.err.println("Usage: java DataProcessor <input_file> <output_file>");
            System.exit(1);
        }
        
        String inputFile = args[0];
        String outputFile = args[1];
        
        System.out.println("Input file: " + inputFile);
        System.out.println("Output file: " + outputFile);
        System.out.println("Processing started at: " + new java.util.Date());
        
        try {
            // Simulate data processing
            Thread.sleep(3000);
            
            // Create output file with processed data
            java.io.FileWriter writer = new java.io.FileWriter(outputFile);
            writer.write("Processed data from: " + inputFile + "\n");
            writer.write("Processing timestamp: " + System.currentTimeMillis() + "\n");
            writer.write("Status: SUCCESS\n");
            writer.close();
            
            System.out.println("Data processing completed successfully!");
            System.out.println("Output written to: " + outputFile);
            
        } catch (Exception e) {
            System.err.println("Error during processing: " + e.getMessage());
            System.exit(1);
        }
    }
}
