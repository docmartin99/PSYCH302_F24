library(fs)
library(yaml)
library(stringr)
library(zip)

# Function to add YAML features and remove download button
add_yaml_features_and_remove_button <- function(file_path, new_features) {
  content <- readLines(file_path, warn = FALSE)
  yaml_start <- which(content == "---")[1]
  yaml_end <- which(content == "---")[2]
  
  if (is.na(yaml_end)) {
    warning(paste("No YAML found in", file_path))
    return(content)
  }
  
  existing_yaml <- yaml.load(paste(content[(yaml_start + 1):(yaml_end - 1)], collapse = "\n"))
  updated_yaml <- modifyList(existing_yaml, new_features, keep.null = TRUE)
  updated_yaml_str <- as.yaml(updated_yaml)
  
  if (yaml_end < length(content)) {
    content_without_button <- content[(yaml_end + 1):length(content)]
    button_start <- which(grepl("<a.*class=\"button-download\"", content_without_button))
    button_end <- which(grepl("</a>", content_without_button))
    
    if (length(button_start) > 0 && length(button_end) > 0) {
      button_end <- button_end[button_end > button_start][1]
      if (!is.na(button_end)) {
        content_without_button <- content_without_button[-(button_start:button_end)]
      }
    }
  } else {
    content_without_button <- character(0)
  }
  
  new_content <- c(
    "---",
    strsplit(updated_yaml_str, "\n")[[1]],
    "---",
    content_without_button
  )
  
  return(new_content)
}

# Function to zip a folder
zip_folder <- function(folder_path, output_zip_name) {
  if (!dir.exists(folder_path)) {
    stop("The specified folder does not exist.")
  }
  
  output_zip_path <- file.path(dirname(folder_path), output_zip_name)
  base_dir <- basename(folder_path)
  files_to_zip <- list.files(base_dir, recursive = TRUE, full.names = TRUE, all.files = TRUE)
  relative_paths <- sub(paste0("^", base_dir, "/"), "", files_to_zip)
  
  cat("Files to zip:\n")
  print(relative_paths)
  
  non_existent_files <- files_to_zip[!file.exists(files_to_zip)]
  if (length(non_existent_files) > 0) {
    cat("\nWarning: The following files do not exist:\n")
    print(non_existent_files)
    files_to_zip <- files_to_zip[file.exists(files_to_zip)]
    relative_paths <- relative_paths[file.exists(files_to_zip)]
  }
  
  files_for_zip <- setNames(files_to_zip, relative_paths)
  
  tryCatch({
    zip(zipfile = output_zip_name, files = files_for_zip)
    cat("\nFolder successfully zipped to:", output_zip_path, "\n")
  }, error = function(e) {
    cat("\nError during zipping:", e$message, "\n")
  })
}

# Main script
source_dirs <- c("./Workbooks", "./Practice", "./R_Resources", "./Application_Activities")
yaml_to_add <- list(
  format = list(
    html = list(
      self_contained = TRUE
    )
  )
)

for(i in 1:length(source_dirs)){
  dest_dir <- paste("./Student_Work", str_remove_all(source_dirs[i], "./"), sep='/')
  dir_create(dest_dir)
  
  qmd_files <- dir_ls(source_dirs[i], glob = "*.qmd")
  
  for (file in qmd_files) {
    dest_file <- path(dest_dir, path_file(file))
    file_copy(file, dest_file, overwrite = TRUE)
    new_content <- add_yaml_features_and_remove_button(dest_file, yaml_to_add)
    writeLines(new_content, dest_file)
    cat("Processed:", path_file(file), "\n")
  }
  
  cat("All files have been copied, modified, and had download buttons removed.\n")
}

# Zip the Student_Work folder
folder_to_zip <- "./Student_Work"
zip_file_name <- "Student_Work_zip.zip"
tryCatch({
  zip_folder(folder_to_zip, zip_file_name)
}, error = function(e) {
  cat("Error:", e$message, "\n")
})