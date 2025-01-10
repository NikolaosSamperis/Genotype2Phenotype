# Define the function to process the CSV file
process_procedures_csv <- function(file_path) {
  # Read the CSV file as raw lines
  csv_lines <- readLines(file_path)
  
  # Process each line
  processed_data <- lapply(csv_lines, function(line) {
    # Split the line by ","
    split_line <- strsplit(line, ",")[[1]]
    
    # If there are more than 4 elements, process accordingly
    if (length(split_line) > 4) {
      name <- trimws(split_line[1])  # First element 
      isMandatory <- trimws(split_line[length(split_line) - 1])  # Second last element
      impcParameterOrigId <- trimws(split_line[length(split_line)])  # Last element
      # Remaining elements as description
      description <- trimws(paste(split_line[2:(length(split_line) - 2)], collapse = ",")) 
    }
    else if (length(split_line) == 4) {
      name <- trimws(split_line[1])  
      description <- trimws(split_line[2]) 
      isMandatory <- trimws(split_line[3])
      impcParameterOrigId <- trimws(split_line[4])
    }
    else {
      print(split_line)
    }
    
    # Remove leading numbers from the name
    name <- trimws(gsub("^\\d+\\s+", "", name))
    
    # Return as a named list
    return(list(
      name = name,
      description = description,
      isMandatory = isMandatory,
      impcParameterOrigId = impcParameterOrigId
    ))
  })
  
  # Remove the header if present (optional: depends on your file structure)
  processed_data <- processed_data[-1]
  
  # Convert the processed data into a dataframe
  df <- do.call(rbind, lapply(processed_data, as.data.frame))
  rownames(df) <- NULL
  
  # Return the dataframe
  return(df)
}


# Define the function to process the CSV file
process_parameters_csv <- function(file_path) {
  # Read the CSV file as raw lines
  csv_lines <- readLines(file_path)
  
  # Remove the first line if it's the header
  csv_lines <- csv_lines[-1]
  
  # Process each line
  processed_data <- lapply(csv_lines, function(line) {
    raw_data <- sub('^".*" "(.*)"$', '\\1', line)
    # Remove extra quotes (if any)
    raw_data <- gsub('"', '', raw_data)  
    
    split_line <- strsplit(raw_data, ",")[[1]]
    # If there are more than 4 elements, process accordingly
    if (length(split_line) > 4) {
      impcParameterOrigId <- trimws(split_line[1])  
      name <- trimws(split_line[2])  
      parameter_id <- tolower(trimws(split_line[length(split_line)]))
      # Remaining elements as description
      description <- trimws(paste(split_line[3:(length(split_line) - 1)], collapse = ",")) 
    }
    else if (length(split_line) == 4) {
      impcParameterOrigId <- trimws(split_line[1])  
      name <- trimws(split_line[2]) 
      description <- trimws(split_line[3])
      parameter_id <- tolower(trimws(split_line[4]))
    }
    else {
      print(split_line) # To catch incorrectly formatted lines
    }
    
    # Return as a named list
    return(list(
      impcParameterOrigId = impcParameterOrigId,
      name = name,
      description = description,
      parameter_id = parameter_id
    ))
  })
  
  # Convert the processed data into a dataframe
  df <- do.call(rbind, lapply(processed_data, as.data.frame))
  rownames(df) <- NULL
  
  # Return the dataframe
  return(df)
}
  

# Define the function to process the CSV file
process_diseases_csv <- function(file_path) {
  # Read the CSV file as raw lines
  csv_lines <- readLines(file_path)
  
  # Remove the first line if it's the header
  csv_lines <- csv_lines[-1]
  
  # Process each line
  processed_data <- lapply(csv_lines, function(line) {
    # Use regular expression to extract the part inside the quotes (after the first space)
    raw_data <- sub('^".*" "(.*)"$', '\\1', line)
    
    # Remove extra quotes (if any)
    raw_data <- gsub('"', '', raw_data)  # Remove quotes from start and end
    
    split_line <- strsplit(raw_data, ",")[[1]]
    # Check if there are exactly 4 elements
    # If there are more than 4 elements, process accordingly
    if (length(split_line) > 4) {
      disease_id <- trimws(split_line[1])  
      gene_accession_id <- tolower(trimws(split_line[length(split_line) - 1]))
      phenodigm_score <- trimws(split_line[length(split_line)]) 
      # Remaining elements as disease_term
      disease_term <- trimws(paste(split_line[2:(length(split_line) - 2)], collapse = ",")) 
    }
    else if (length(split_line) == 4) {
      disease_id <- trimws(split_line[1])  
      disease_term <- trimws(split_line[2]) 
      gene_accession_id <- tolower(trimws(split_line[3]))
      phenodigm_score <- trimws(split_line[4])
    }
    else {
      print(split_line)
    }
      
    # Return as a named list
    return(list(
      disease_id = disease_id,
      disease_term = disease_term,
      gene_accession_id = gene_accession_id,
      phenodigm_score = phenodigm_score
    ))
  })
  
  # Convert the processed data into a dataframe
  df <- do.call(rbind, lapply(processed_data, as.data.frame))
  rownames(df) <- NULL
  
  df <- df %>%
    group_by(gene_accession_id) %>%
    filter(phenodigm_score == max(phenodigm_score)) %>%
    ungroup()
  
  # Return the dataframe
  return(df)
}
