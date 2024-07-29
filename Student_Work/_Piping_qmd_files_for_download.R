library(fs)
library(yaml)
library(stringr)

source_dirs <- c("./Workbooks", "./Practice", "./R_Resources", "./Application_Activities")

for(i in 1:length(source_dirs)){
  
  # Define source and destination directories
  dest_dir <- paste("./Student_Work", str_remove_all(source_dirs[i], "./"), sep='/')
  
  # Create the destination directory if it doesn't exist
  dir_create(dest_dir)
  
  yaml_to_add <- list(
    format = list(
      html = list(
        self_contained = TRUE
        # Add any other features you want here
      )
    )
  )
  
  add_yaml_features_and_remove_button <- function(file_path, new_features) {
    # Read the file content
    content <- readLines(file_path, warn = FALSE)
    
    # Find the YAML section
    yaml_start <- which(content == "---")[1]
    yaml_end <- which(content == "---")[2]
    
    if (is.na(yaml_end)) {
      warning(paste("No YAML found in", file_path))
      return(content)
    }
    
    # Extract and parse the existing YAML
    existing_yaml <- yaml.load(paste(content[(yaml_start + 1):(yaml_end - 1)], collapse = "\n"))
    
    # Merge the new features with the existing YAML
    updated_yaml <- modifyList(existing_yaml, new_features, keep.null = TRUE)
    
    # Convert the updated YAML back to string
    updated_yaml_str <- as.yaml(updated_yaml)
    
    # Remove the download button
    if (yaml_end < length(content)) {
      content_without_button <- content[(yaml_end + 1):length(content)]
      
      # Find start and end indices of the button
      button_start <- which(grepl("<a.*class=\"button-download\"", content_without_button))
      button_end <- which(grepl("</a>", content_without_button))
      
      # Remove the button if found
      if (length(button_start) > 0 && length(button_end) > 0) {
        button_end <- button_end[button_end > button_start][1]  # Find the first closing tag after the opening tag
        if (!is.na(button_end)) {
          content_without_button <- content_without_button[-(button_start:button_end)]
        }
      }
    } else {
      content_without_button <- character(0)  # Empty vector if there's no content after YAML
    }
    
    # Reconstruct the file content
    new_content <- c(
      "---",
      strsplit(updated_yaml_str, "\n")[[1]],
      "---",
      content_without_button
    )
    
    return(new_content)
  }
  
  # Get list of qmd files
  qmd_files <- dir_ls(source_dirs[i], glob = "*.qmd")
  
  # Process each file
  for (file in qmd_files) {
    # Construct destination file path
    dest_file <- path(dest_dir, path_file(file))
    
    # Copy the file
    file_copy(file, dest_file, overwrite = TRUE)
    
    # Add YAML features to the copied file and remove download button
    new_content <- add_yaml_features_and_remove_button(dest_file, yaml_to_add)
    
    # Write the new content back to the file
    writeLines(new_content, dest_file)
    
    cat("Processed:", path_file(file), "\n")
  }
  
  cat("All files have been copied, modified, and had download buttons removed.\n")
}
