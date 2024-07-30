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
  
  # Change working directory to the parent of the folder to be zipped
  #old_wd <- setwd(dirname(folder_path))
  #on.exit(setwd(old_wd), add = TRUE)  # Ensure we change back to the original directory
  
  # Get the base directory name
  base_dir <- basename(folder_path)
  
  # Get all files in the folder (including subdirectories) using relative paths
  files_to_zip <- list.files(base_dir, recursive = TRUE, full.names = TRUE, all.files = TRUE)
  
  # Create relative paths for the files (removing the base directory from the start)
  relative_paths <- sub(paste0("^", base_dir, "/"), "", files_to_zip)
  
  # Print debugging information
  cat("Files to zip:\n")
  print(relative_paths)
  
  # Check if all files exist
  non_existent_files <- files_to_zip[!file.exists(files_to_zip)]
  if (length(non_existent_files) > 0) {
    cat("\nWarning: The following files do not exist:\n")
    print(non_existent_files)
    files_to_zip <- files_to_zip[file.exists(files_to_zip)]
    relative_paths <- relative_paths[file.exists(files_to_zip)]
  }
  
  # Create a named vector for zip function
  files_for_zip <- setNames(files_to_zip, relative_paths)
  
  # Zip the folder
  tryCatch({
    zip(zipfile = output_zip_name, files = files_for_zip)
    cat("\nFolder successfully zipped to:", output_zip_path, "\n")
  }, error = function(e) {
    cat("\nError during zipping:", e$message, "\n")
  })
}

# Example usage
#folder_to_zip <- here::here("Student_Work")
folder_to_zip <- "./Student_Work"
zip_file_name <- "Student_Work_zip.zip"

tryCatch({
  zip_folder(folder_to_zip, zip_file_name)
}, error = function(e) {
  cat("Error:", e$message, "\n")
})