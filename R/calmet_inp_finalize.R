#' Finalize and generate CALMET input files
#' @description This function sets the input and output filenames for CALMET model runs generates one or a series of CALMET.INP files.
#' @param calmet_inp the absolute path and filename for the working CALMET input file.
#' @param get_filenames_from_wd 
#' @param geodat the name of the intended GEO.DAT file.
#' @param srfdat the name of the intended SURF.DAT file.
#' @param clddat the name of the intended CLOUD.DAT file.
#' @param prcdat the name of the intended PRECIP.DAT file.
#' @param wtdat the name of the intended WT.DAT file.
#' @param metlst 
#' @param metdat 
#' @param pacdat the name of the created PACOUT.DAT file.
#' @param lcfiles 
#' @param nusta 
#' @param nowsta 
#' @param nm3d 
#' @param nigf 
#' @param updat 
#' @param seadat 
#' @param m3ddat 
#' @param igfdat 
#' @param diadat the name of the intended DIAG.DAT file.
#' @param prgdat 
#' @param tstprt 
#' @param tstout 
#' @param tstkin 
#' @param tstfrd 
#' @param tstslp 
#' @param dcstgd 
#' @export calmet_inp_finalize

calmet_inp_finalize <- function(calmet_inp = "calmet_template.txt",
                                get_filenames_from_wd = TRUE,
                                geodat = NULL,
                                srfdat = NULL,
                                clddat = NULL,
                                prcdat = NULL,
                                wtdat = NULL,
                                metlst = NULL,
                                metdat = NULL,
                                pacdat = NULL,
                                nusta = NULL,
                                nowsta = NULL,
                                nm3d = NULL,
                                nigf = NULL,
                                updat = NULL,
                                seadat = NULL,
                                m3ddat = NULL,
                                igfdat = NULL,
                                diadat = NULL,
                                prgdat = NULL,
                                tstprt = NULL,
                                tstout = NULL,
                                tstkin = NULL,
                                tstfrd = NULL,
                                tstslp = NULL,
                                dcstgd = NULL,
                                lcfiles = TRUE){
  
  # Read in the working calmet.inp file as a character vector
  calmet_inp_working <- readLines(calmet_inp, warn = FALSE)
  
  # Transform TRUE or FALSE value for lcfiles to string
  lcfiles <- ifelse(lcfiles == TRUE, "T", "F")
  
  # Get file information from working folder if the option is taken
  if (get_filenames_from_wd == TRUE){
    
    # Generate a list of GEO.DAT files that are available in folder
    geodat_files <- list.files(pattern = "geo--.*")
    
    # Determine number of GEO.DAT files available in folder
    number_geodat_year <- length(geodat_files)
    
    # If there is at least one GEO.DAT file, provide a TRUE value for the geodat object
    if (number_geodat_year > 0) geodat <- TRUE
    if (number_geodat_year == 0) geodat <- FALSE
    
    # The number of GEO.DAT files will dictate the number of CALMET input files
    # that need to be generated per year
    number_srfdat_per_year <- number_geodat_year
    
    # Generate a list of SURF.DAT files that are available in folder
    srfdat_files <- list.files(pattern = "surf--.*")
    
    # Determine the number of SURF.DAT files, each representing a year's worth
    # of data
    number_srfdat_years <- length(srfdat_files)
    
    # Create a vector object of the SURF.DAT years
    for (i in 1:length(srfdat_files)){
      if (i == 1) srfdat_years <- vector(mode = "numeric", length = 0)
      
      srfdat_yr <- as.numeric(gsub(".*-[0-9]*x[0-9]*x[0-9]*--([0-9][0-9][0-9][0-9]).txt",
                                   "\\1", srfdat_files[i]))
      srfdat_years <- c(srfdat_years, srfdat_yr)
    }
    
    # If there is at least one SURF.DAT file, provide a TRUE value for the srfdat object
    if (number_srfdat_years > 0) srfdat <- TRUE
    if (number_srfdat_years == 0) srfdat <- FALSE
    
    # Determine the total number of CALMET.INP files that need to be made
    number_calmet_input_files_to_make <- number_srfdat_per_year * number_srfdat_years
    
    # Generate a list of CLOUD.DAT files that are available in folder
    clddat_files <- list.files(pattern = "cloud--.*")
    
    # Determine number of CLOUD.DAT files available in folder
    number_clddat_files <- length(clddat_files)
    
    # If there is at least one CLOUD.DAT file, provide a TRUE value for the clddat object
    if (number_clddat_files > 0) clddat <- TRUE
    if (number_clddat_files == 0) clddat <- FALSE
    
    # Generate a list of PRECIP.DAT files that are available in folder
    prcdat_files <- list.files(pattern = "precip--.*")
    
    # Determine number of PRECIP.DAT files available in folder
    number_prcdat_files <- length(prcdat_files)
    
    # If there is at least one PRECIP.DAT file, provide a TRUE value for the prcdat object
    if (number_prcdat_files > 0) prcdat <- TRUE
    if (number_prcdat_files == 0) prcdat <- FALSE
    
    # Generate a list of WT.DAT files that are available in folder
    wtdat_files <- list.files(pattern = "wt--.*")
    
    # Determine number of WT.DAT files available in folder
    number_wtdat_files <- length(wtdat_files)
    
    # If there is at least one WT.DAT file, provide a TRUE value for the wtdat object
    if (number_wtdat_files > 0) wtdat <- TRUE
    if (number_wtdat_files == 0) wtdat <- FALSE
    
    # Determine whether a CALMET/CALGRID-type output file (CALMET.DAT) is desired or if
    # a MESOPUFF-II-type output file (PACOUT.DAT) is desired
    if (as.numeric(gsub(".*([0-9])..", "\\1",
                        calmet_inp_working[grep("IFORMO",
                                                calmet_inp_working)])) == 1){
      metdat <- TRUE
      metlst <- TRUE
      pacdat <- FALSE
    } else if (as.numeric(gsub(".*([0-9])..", "\\1",
                               calmet_inp_working[grep("IFORMO",
                                                       calmet_inp_working)])) == 2){
      metdat <- FALSE
      metlst <- FALSE
      pacdat <- TRUE
    }
    
    # Set the number of upper air stations to 1 if an UP.DAT file exists
    if (number_geodat_year > 0){
      nusta <- 1
      updat <- TRUE
    }
    if (number_geodat_year == 0){
      nusta <- 0
      updat <- FALSE
    }
    
    # Generate a list of MM4, MM5, and 3D.DAT files that are available in folder
    mm4_files <- list.files(pattern = "mm4--.*")
    mm5_files <- list.files(pattern = "mm5--.*")
    threeddat_files <- list.files(pattern = "3ddat--.*")
    
    # Get combined number of MM4, MM5, and 3D.DAT files available in folder
    nm3d <-
      length(mm4_files) +
      length(mm5_files) +
      length(threeddat_files)
    
    # Generate a list of IGF-CALMET.DAT files that are available in folder
    igf_calmet_files <- list.files(pattern = "igf-calmet--.*")
    
    # Get number of IGF-CALMET.DAT files available in folder
    nigf <- length(igf_calmet_files)
    
    # Generate a list of SEA.DAT files that are available in folder
    seadat_files <- list.files(pattern = "sea--.*")
    
    # Determine number of SEA.DAT files available in folder
    number_seadat_files <- length(seadat_files)
        
    # Set the number of overweater stations if one or several SEA.DAT files exist
    if (number_seadat_files > 0){
      nowsta <- number_seadat_files
      seadat <- TRUE
    }
    if (number_seadat_files == 0){
      nowsta <- 0
      seadat <- FALSE
    }
    
    # Determine whether one or several MM4, MM5, or 3D.DAT files exist
    if (nm3d > 0){
      m3ddat <- TRUE
    }
    if (nm3d == 0){
      m3ddat <- FALSE
    }
    
    # Determine whether one or several IGF-CALMET.DAT files exist
    if (nigf > 0){
      igfdat <- TRUE
    }
    if (nigf == 0){
      igfdat <- FALSE
    }
    
    # Set other CALMET modelling files to missing
    diadat <- FALSE
    prgdat <- FALSE
    tstprt <- FALSE
    tstout <- FALSE
    tstkin <- FALSE
    tstfrd <- FALSE
    tstslp <- FALSE
    dcstgd <- FALSE
    
    # Generate a vector list of calmet.inp keywords
    keywords <- c("GEODAT", "SRFDAT", "CLDDAT", "PRCDAT", "WTDAT", "METLST", "METDAT",
                  "PACDAT", "LCFILES", "NUSTA", "NOWSTA", "NM3D", "NIGF", "UPDAT",
                  "SEADAT", "M3DDAT", "IGFDAT", "DIADAT", "PRGDAT", "TSTPRT", "TSTOUT",
                  "TSTKIN", "TSTFRD", "TSTSLP", "DCSTGD")
    
    # Generate a vector list of the formatted replacements
    replacements <- c(geodat, srfdat, clddat, prcdat, wtdat, metlst, metdat,
                      pacdat, lcfiles, nusta, nowsta, nm3d, nigf, updat,
                      seadat, m3ddat, igfdat, diadat, prgdat, tstprt, tstout,
                      tstkin, tstfrd, tstslp, dcstgd)
    
    # Modify all parameters in working calmet.inp vector
    calmet_inp_working <- replace_in_inp(inp_file_working = calmet_inp_working,
                                         keyword = keywords,
                                         replacement = replacements)
    
    # Write the output to the same working calmet.inp file
    writeLines(calmet_inp_working, con = calmet_inp)
    
    # Read in the working calmet.inp file as a character vector
    calmet_inp_working <- readLines(calmet_inp, warn = FALSE)

    # Determine which keywords contain the 'FALSE' indicator and prepare
    # those lines for writing with asterisks
    asterisk_lines <- grep("FALSE", calmet_inp_working)
    
    # Take those FALSE value lines and disable them using asterisks
    calmet_inp_working[asterisk_lines] <-
      gsub("!", "\\*", gsub("FALSE", "", calmet_inp_working[asterisk_lines]))
    
    # Write the output to the same working calmet.inp file
    writeLines(calmet_inp_working, con = calmet_inp)
    
    # Read in the working calmet.inp file as a character vector
    calmet_inp_working <- readLines(calmet_inp, warn = FALSE)
    
    # Determine the filenames for all required CALMET input files
    for (i in 1:number_calmet_input_files_to_make){
      if (i == 1) calmet_inp_filenames <- vector(mode = "character", length = 0)
      for (j in 1:length(srfdat_years)){
        # Generate filename 
        filename <- gsub("geo", "calmet_in", geodat_files[i])
        filename <- gsub("(.*)--(.*).txt",
                         paste("\\1--", srfdat_years[j], "-\\2.txt", sep = ''),
                         filename)
        calmet_inp_filenames <- c(calmet_inp_filenames, filename)
      }
    }
    
    # Generate separate CALMET input files for different seasons across
    # different years
    for (i in 1:length(calmet_inp_filenames)){
      
      # Read in the working calmet.inp file as a character vector
      calmet_inp_working <- readLines(calmet_inp, warn = FALSE)
      
      # Obtain a filename stub that all subsequent filenames will use
      file_stub <- gsub("calmet_in", "",
                        gsub("(calmet_in--.*)", "\\1",
                             calmet_inp_filenames[i]))
      
      # Determine which of the lines in 'calmet_inp_working' contain
      # 'TRUE' strings (used as a marker for replacement with a filename)
      true_fields_indices <- grep("TRUE", calmet_inp_working)
      true_fields_values <- grep("TRUE", calmet_inp_working, value = TRUE)
      
      for (j in 1:length(true_fields_indices)){
        
        if (length(grep("GEODAT", true_fields_values[j])) == 1){
          calmet_inp_working[true_fields_indices[j]] <- 
            paste("! GEODAT = geo", gsub("^(.*--)[0-9][0-9][0-9][0-9]-(.*)", "\\1\\2", file_stub),
                  " !", sep = '')
        }
        
        if (length(grep("SRFDAT", true_fields_values[j])) == 1){
          calmet_inp_working[true_fields_indices[j]] <- 
            paste("! SRFDAT = surf", gsub("(.*)--([0-9][0-9][0-9][0-9]).*.txt",
                               "\\1--\\2.txt", file_stub), " !", sep = '')
        }
        
        if (length(grep("UPDAT", true_fields_values[j])) == 1){
          calmet_inp_working[true_fields_indices[j]] <- 
            paste("! UPDAT = up", gsub("(.*)--([0-9][0-9][0-9][0-9]).*.txt",
                             "\\1--\\2.txt", file_stub), " !", sep = '')
        }
        
        if (length(grep("METDAT", true_fields_values[j])) == 1){
          calmet_inp_working[true_fields_indices[j]] <- 
            paste("! METDAT = calmet_out",
                  gsub("txt$", "dat", file_stub), " !", sep = '')
        }
        
        if (length(grep("METLST", true_fields_values[j])) == 1){
          calmet_inp_working[true_fields_indices[j]] <- 
            paste("! METLST = calmet_out",
                  gsub("txt$", "lst", file_stub), " !", sep = '')
        }
        
      }
      
      # Read in line 4 of relevant GEO.DAT file
      geo_header_dates <- 
        readLines(paste("geo--",
                        gsub("^--(.*)--[0-9][0-9][0-9][0-9](.*).txt",
                             paste("\\1-", "\\2.txt", sep = ''),
                             file_stub),
                        sep = ''), warn = FALSE)[4]
      
      # Determine year for input file
      begin_end_year <- as.numeric(gsub("^--.*--([0-9][0-9][0-9][0-9]).*",
                                        "\\1", file_stub))
      
      # Determine beginning month for input file
      begin_month <- as.numeric(gsub(".*\\(([0-9][0-9]).*",
                                     "\\1",
                                     geo_header_dates))
      
      # Determine beginning day for input file
      begin_day <- as.numeric(gsub(".*\\([0-9][0-9] ([0-9][0-9]).*",
                                   "\\1",
                                   geo_header_dates))
      
      # Determine ending month for input file
      end_month <- as.numeric(gsub(".*\\([0-9][0-9] [0-9][0-9] - ([0-9][0-9]).*",
                                   "\\1",
                                   geo_header_dates))
      
      # Determine ending day for input file
      end_day <- as.numeric(gsub(".*\\([0-9][0-9] [0-9][0-9] - [0-9][0-9] ([0-9][0-9]).*",
                                 "\\1",
                                 geo_header_dates))
      
      # Make replacement to beginning year
      calmet_inp_working <- replace_in_inp(inp_file_working = calmet_inp_working,
                                           keyword = "IBYR",
                                           replacement = begin_end_year)
      
      # Make replacement to beginning month
      calmet_inp_working <- replace_in_inp(inp_file_working = calmet_inp_working,
                                           keyword = "IBMO",
                                           replacement = begin_month) 
      
      # Make replacement to beginning day
      calmet_inp_working <- replace_in_inp(inp_file_working = calmet_inp_working,
                                           keyword = "IBDY",
                                           replacement = begin_day)
      
      # Make replacement to beginning hour
      calmet_inp_working <- replace_in_inp(inp_file_working = calmet_inp_working,
                                           keyword = "IBHR",
                                           replacement = 0)
      
      # Make replacement to ending year
      calmet_inp_working <- replace_in_inp(inp_file_working = calmet_inp_working,
                                           keyword = "IEYR",
                                           replacement = begin_end_year)
      
      # Make replacement to ending month
      calmet_inp_working <- replace_in_inp(inp_file_working = calmet_inp_working,
                                           keyword = "IEMO",
                                           replacement = end_month) 
      
      # Make replacement to ending day
      calmet_inp_working <- replace_in_inp(inp_file_working = calmet_inp_working,
                                           keyword = "IEDY",
                                           replacement = end_day)
      
      # Make replacement to ending hour
      calmet_inp_working <- replace_in_inp(inp_file_working = calmet_inp_working,
                                           keyword = "IEHR",
                                           replacement = 24)
      
      # Write the modified 'calmet_inp_working' vector object as
      # a CALMET input file
      writeLines(calmet_inp_working,
                 con = paste("calmet_in",
                             gsub(".txt$", ".txt", file_stub), sep = ''))
      
    }
    
  }
  
  # Remove the "calmet_template.txt" file from the working folder
  file.remove("calmet_template.txt")
  
}
