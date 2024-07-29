# Replace "Downloads" with "Student_Work" in qmd files

# Set the working directory to your Quarto project root if needed
# setwd("/path/to/your/quarto/project")

# Define the old and new terms
old_term <- "Downloads"
new_term <- "Student_Work"

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
