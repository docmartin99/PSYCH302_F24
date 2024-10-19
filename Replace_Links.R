# Replace "Downloads" with "Student_Work" in qmd files

# Set the working directory to your Quarto project root if needed
# setwd("/path/to/your/quarto/project")

# Define the old and new terms
old_term <- "../Images/"
new_term <- "https://github.com/byuistats/Math221D_Cannon/raw/master/Images/"

# Get all qmd files in the project and its subdirectories
qmd_files <- list.files(pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE)

# Function to replace terms in a file
replace_terms <- function(file_path) {
  # Read the file content
  content <- readLines(file_path, warn = FALSE)
  
  # Replace the term
  content_new <- gsub(paste0("\\b", old_term, "\\b"), new_term, content, perl = TRUE)
  
  # Check if any changes were made
  if (!identical(content, content_new)) {
    # Write the modified content back to the file
    writeLines(content_new, file_path)
    cat("Updated:", file_path, "\n")
  } else {
    cat("No changes in:", file_path, "\n")
  }
}

# Apply the function to all qmd files
lapply(qmd_files, replace_terms)

cat("Term replacement complete.\n")


########


# Load required library
library(fs)

# Set the directory path (current working directory by default)
dir_path <- getwd()

# Find all .qmd files in the directory
qmd_files <- dir_ls(dir_path, recurse = TRUE, regexp = "\\.qmd$")

# Define the old and new image paths
old_path <- "https://github.com/byuistats/Math221D_Course/blob/main"
new_path <- ".."

# Function to replace the image path in a file
replace_image_path <- function(file_path) {
  # Read the file content
  content <- readLines(file_path)
  
  # Replace the old path with the new path
  updated_content <- gsub(old_path, new_path, content, fixed = TRUE)
  
  # Check if any changes were made
  if (!identical(content, updated_content)) {
    # Write the updated content back to the file
    writeLines(updated_content, file_path)
    cat("Updated:", file_path, "\n")
  } else {
    cat("No changes needed in:", file_path, "\n")
  }
}

# Apply the replacement function to all .qmd files
lapply(qmd_files, replace_image_path)

cat("All .qmd files have been processed.\n")
