# Load the required libraries
library(zip)
library(here)

# Function to zip a folder
zip_folder <- function(folder_path, output_zip_name) {
  # Check if the folder exists
  if (!dir.exists(folder_path)) {
    stop("The specified folder does not exist.")
  }
  
  # Get the full path for the output zip file
  output_zip_path <- file.path(dirname(folder_path), output_zip_name)
  
  # Change working directory to the folder to be zipped
  old_wd <- setwd(folder_path)
  on.exit(setwd(old_wd), add = TRUE)  # Ensure we change back to the original directory
  
  # Get all files in the folder (including subdirectories) using relative paths
  files_to_zip <- list.files(".", recursive = TRUE, full.names = FALSE, all.files = TRUE)
  
  # Print debugging information
  cat("Files to zip:\n")
  print(files_to_zip)
  
  # Check if all files exist
  non_existent_files <- files_to_zip[!file.exists(files_to_zip)]
  if (length(non_existent_files) > 0) {
    cat("\nWarning: The following files do not exist:\n")
    print(non_existent_files)
    files_to_zip <- files_to_zip[file.exists(files_to_zip)]
  }
  
  # Zip the folder
  tryCatch({
    zip(zipfile = output_zip_name, files = files_to_zip)
    cat("\nFolder successfully zipped to:", output_zip_path, "\n")
  }, error = function(e) {
    cat("\nError during zipping:", e$message, "\n")
  })
}

# Example usage
folder_to_zip <- here::here("Student_Work")
zip_file_name <- "../Student_Work.zip"

tryCatch({
  zip_folder(folder_to_zip, zip_file_name)
}, error = function(e) {
  cat("Error:", e$message, "\n")
})