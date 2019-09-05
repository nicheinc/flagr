flagr <- function(program_name="", trailingOnly=TRUE) {
  flagenv <- environment()
  valid_types <- c("character", "complex", "double", "integer", "logical")

  # Validate program_name
  if (is.na(program_name) || is.null(program_name)) {
    stop(paste0("Invalid program name"))
  }
  if (!can_convert(value=program_name, type="character")) {
    stop(paste0("Invalid program name, must be character type"))
  }

  # Set default program name if not provided
  # Default is the name of the directory
  # e.g. if we're in ~/src/github.com/nicheinc
  # then this will return nicheinc
  if (program_name == "") {
    program_name = regmatches(
      getwd(),
      regexpr("^.*/", getwd()),
      invert=TRUE
    )[[1]][2]
  }

  # Extract command-line arguments
  flagenv$args <- commandArgs(trailingOnly)
  flagenv$n_args <- length(flagenv$args)
  flagenv$flag_list <- list(program_name=program_name)

  # Add help to the list of possible flags
  flagenv$flag_list$help <- list(
    name = "help (h)",
    type = "logical",
    description = "Show usage",
    default = FALSE
  )

  get_flags <- function() {
    flagenv$flag_list
  }

  add_flag <- function(
    name="flagname",
    type="logical",
    description="A flag",
    default=TRUE
  ) {
    # Check provided data type is valid / supported
    if (!(type %in% valid_types)) {
      stop(paste("Data type must be one of:", paste(valid_types, collapse=",")))
    }

    # Check that default can be converted to expected data type
    if (!can_convert(value=default, type=type)) {
      stop(paste("Default value cannot be converted to", type))
    }

    # Add flag to environment
    flagenv$flag_list[[name]] <- list(
      name=name,
      type=type,
      default=default,
      description=description
    )

    # Pull the flag and its value(s) out of the argument string
    x <- extract_flag(name)

    # Return the default value if no flag was extracted
    if (is.null(x)) {
      return(convert_type(value=default, type=type))
    }

    # Remove the name of the flag from the flag token string
    # e.g., the token string -flagname value will be trimmed to value
    flag_pattern <- paste0("^-(-)?", name, "(=)?")
    value <- gsub(flag_pattern, "", x)

    # If no value was given for the flag use the default value
    value <- value[value != ""]
    if (length(value) == 0) {
      return(convert_type(value=default, type=type))
    }

    # Convert multiple supported values for logical type into a value that can
    # be converted to an appropriate logical
    if (type == "logical") {
      value <- gsub("(t(rue)?|1)$", "TRUE", value, ignore.case=TRUE)
      value <- gsub("(f(alse)?|0)$", "FALSE", value, ignore.case=TRUE)
    }

    # Convert value to type and return
    value <- convert_type(value=value, type=type)
    return(value)
  }

  extract_flag <- function(flag_name) {
    flag_slots <- which(grepl("^-(-)?", flagenv$args))
    flag_pattern <- paste0("^-(-)?", flag_name)

    # Determine where the flag pattern starts
    start_idx <- which(grepl(flag_pattern, flagenv$args))

    if (length(start_idx) == 0) {
      return(NULL)
    }

    # Determine where the flag pattern ends
    end_idx <- flag_slots[which(flag_slots == start_idx) + 1]

    if (is.na(end_idx)) {
      # The flag is the last one supplied
      flag <- flagenv$args[start_idx:flagenv$n_args]
    } else {
      end_idx <- end_idx - 1
      flag <- flagenv$args[start_idx:end_idx]
    }

    return(flag)
  }

  parse <- function() {
    if (!is.null(extract_flag("(h|(help))$"))) {
      return(help())
    }
  }

  # Show usage / help message
  help <- function() {
    flags <- flagenv$flag_list
    pretty <- paste0("\nUsage of ", flags$program_name, ":\n")
    idx <- which(names(flags) == "program_name")

    # Construct (pretty!) usage string for each flag
    flag_strings <- vapply(
      flags[-idx],
      function(flag) {
        paste0(
          "-", flag$name, " ", flag$type, "\n    ",
          flag$description, " (default ", flag$default, ")\n"
        )
      },
      character(1)
    )

    # Concatenate the usage strings
    flag_string <- paste(flag_strings, collapse="")

    # Print help message and exit
    cat(paste0(pretty, flag_string, "\n"))
    quit()
  }
}

can_convert <- function(value="", type="character") {
  # Construct function to attempt to convert value to type
  # eg. as.character() will convert its value to character
  conv <- eval(parse(text=paste0("as.", type)))

  # Attempt to convert value to type
  # Note that value can, in general, be a vector of atomic types
  # Any element of value that cannot be converted to type gets
  # coerced to NA
  has_na <- any(is.na(suppressWarnings(conv(value))))

  # If no NAs exist, then we can convert value to type
  return(!has_na)
}

convert_type <- function(value="", type="character") {
  if (!can_convert(value, type)) {
    stop(paste0("Unable to convert ", value, " to ", type))
  }

  # Construct function to convert value to type
  conv <- eval(parse(text=paste0("as.", type)))
  
  # Return converted value
  return(conv(value))
}
