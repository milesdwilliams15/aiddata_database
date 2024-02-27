######################
## Download Helpers ##
######################


# setup -------------------------------------------------------------------

## make sure you have the necessary packages
your_packages <- installed.packages() |>
  rownames()
have_readr <- "readr" %in% your_packages
have_dplyr <- "dplyr" %in% your_packages
have_tidyr <- "tidyr" %in% your_packages
if(!have_readr) {
  cat("\nYou don't have {readr}. It is being installed for you.\n")
  install.packages("readr")
}
if(!have_dplyr) {
  cat("\nYou don't have {dplyr}. It is being installed for you.\n")
  install.packages("dplyr")
}
if(!have_tidyr) {
  cat("\nYou don't have {tidyr}. It is being installed for you.\n")
  install.packages("tidyr")
}

# get_donorrecipientyear --------------------------------------------------

get_donorrecipientyear <- function(
    subset_years = NULL
) {
  ## spread sheet id
  id <- "1EsXsOV6S5mtZ8FVqYIeZTLlq-Vw6gDA4"
  
  ## should data be subset by years first?
  if(is.null(subset_years)) {
    readr::read_csv(
      sprintf("https://docs.google.com/uc?id=%s&export=download", id)
    ) -> dt
  } else {
    readr::read_csv_chunked(
      sprintf("https://docs.google.com/uc?id=%s&export=download", id),
      callback = DataFrameCallback$new(
        function(x, pos) subset(x, year %in% subset_years)
      )
    ) -> dt
  }
  
  dt ## return
}

## test
# dt <- get_donorrecipientyear(subset_years = 1999)


# get_donorrecipientsectoryear --------------------------------------------


get_donorrecipientsectoryear <- function(
    subset_years = NULL
) {
  id <- "1EaqUZWipV1Dopfm998gsB_LSK7def8jR"
  ## should data be subset by years first?
  if(is.null(subset_years)) {
    readr::read_csv(
      sprintf("https://docs.google.com/uc?id=%s&export=download", id)
    ) -> dt
  } else {
    readr::read_csv_chunked(
      sprintf("https://docs.google.com/uc?id=%s&export=download", id),
      callback = DataFrameCallback$new(
        function(x, pos) subset(x, year %in% subset_years)
      )
    ) -> dt
  }
  
  dt ## return
}

## test
# dt <- get_donorrecipientsectoryear(subset_years = 1999)


# get_donorrecipientpurposeyear -------------------------------------------

get_donorrecipientpurposeyear <- function(
    subset_years = NULL
) {
  id <- "1Ea8p5zAfOXE_flfbgNce4FwbqTvpkUos"
  
  ## should data be subset by years first?
  if(is.null(subset_years)) {
    readr::read_csv(
      sprintf("https://docs.google.com/uc?id=%s&export=download", id)
    ) -> dt
  } else {
    readr::read_csv_chunked(
      sprintf("https://docs.google.com/uc?id=%s&export=download", id),
      callback = DataFrameCallback$new(
        function(x, pos) subset(x, year %in% subset_years)
      )
    ) -> dt
  }
  
  dt ## return
}

## test
# dt <- get_donorrecipientpurposeyear(subset_years = 1999)


# get_aiddata -------------------------------------------------------------

get_aiddata <- function(
    level = c("total", "sector", "purpose"),
    subset_years = NULL
) {
  level <- level[1]
  if(!(level %in%  c("total", "sector", "purpose"))) stop(
    "Pick one of 'total', 'sector', or 'purpose' for option level."
  )
  if(level == "total") {
    dt <- get_donorrecipientyear(subset_years)
  } else if(level == "sector") {
    dt <- get_donorrecipientsectoryear(subset_years)
  } else {
    dt <- get_donorrecipientpurposeyear(subset_years)
  }
  dt # return the data
}


# look at sector and purpose codes ----------------------------------------

view_codes <- function() {
  id <- "1EnuQPVlilNILvT7nhYq35hxqhmKynlDq"
  readr::read_csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id))
}

## test
# view_codes()


# create full set of un-directed donor-recipient dyads --------------------

add_full_dyads <- function(data) {
  ## shorten data name
  dt        <- data
  
  ## detect the level of the data
  level_sec <- exists("dt$crs_sector_code")
  level_prp <- exists("dt$crs_purpose_code")
  
  ## if level is total bilateral aid
  if(!level_sec & !level_prp) {
    
    ## grid of all possible combinations
    tidyr::expand_grid(
      donor = unique(dt$donor),
      recipient = unique(dt$recipient),
      year = unique(dt$year)
    ) |>
      
      ## join the aid data
      dplyr::left_join(
        dt, 
        by = c("donor", "recipient", "year") 
      ) |>
      
      ## fix missing country codes
      dplyr::group_by(donor) |>
      dplyr::mutate(
        dplyr::across(
          ccode_d:isocode_d,
          ~ ifelse(
            all(is.na(.x)),
            NA_integer_,
            max(.x, na.rm = T)
          ) 
        )
      ) |>
      dplyr::group_by(recipient) |>
      dplyr::mutate(
        dplyr::across(
          ccode_r:isocode_r,
          ~ ifelse(
            all(is.na(.x)),
            NA_integer_,
            max(.x, na.rm = T)
          ) 
        )
      ) |>
      
      ## drop donors that have all NA for aid in a year
      dplyr::group_by(donor, year) |>
      dplyr::mutate(
        drop_donor = all(is.na(commitment_2011_constant))
      ) |>
      dplyr::ungroup() |>
      dplyr::filter(!drop_donor) |>
      dplyr::select(-drop_donor) |>
      
      ## drop recipients that have all NA for aid in a year
      dplyr::group_by(recipient, year) |>
      dplyr::mutate(
        drop_recipient = all(is.na(commitment_2011_constant))
      ) |>
      dplyr::ungroup() |>
      dplyr::filter(!drop_recipient) |>
      dplyr::select(-drop_recipient) |>
      
      ## set NA aid values to zero
      dplyr::mutate(
        commitment_2011_contant = tidyr::replace_na(
          commitment_2011_constant, 0
        )
      ) ## return
    
  } else if(level_sec) {
    
    ## grid of all possible combinations
    tidyr::expand_grid(
      donor = unique(dt$donor),
      recipient = unique(dt$recipient),
      crs_sector_name = unique(dt$crs_sector_name),
      year = unique(dt$year)
    ) |>
      
      ## join the aid data
      dplyr::left_join(
        dt, 
        by = c("donor", "recipient", "crs_sector_name", "year") 
      ) |>
      
      ## fix missing country codes
      dplyr::group_by(donor) |>
      dplyr::mutate(
        dplyr::across(
          ccode_d:isocode_d,
          ~ ifelse(
            all(is.na(.x)),
            NA_integer_,
            max(.x, na.rm = T)
          ) 
        )
      ) |>
      dplyr::group_by(recipient) |>
      dplyr::mutate(
        dplyr::across(
          ccode_r:isocode_r,
          ~ ifelse(
            all(is.na(.x)),
            NA_integer_,
            max(.x, na.rm = T)
          ) 
        )
      ) |>
      
      ## fix missing sector codes
      dplyr::group_by(crs_sector_name) |>
      dplyr::mutate(
        crs_sector_code = ifelse(
          all(is.na(crs_sector_code)),
          NA_integer_,
          max(crs_sector_code, na.rm = T)
        )
      ) |>
      
      ## drop donors that have all NA for aid in a year
      dplyr::group_by(donor, year) |>
      dplyr::mutate(
        drop_donor = all(is.na(commitment_2011_constant))
      ) |>
      dplyr::ungroup() |>
      dplyr::filter(!drop_donor) |>
      dplyr::select(-drop_donor) |>
      
      ## drop recipients that have all NA for aid in a year
      dplyr::group_by(recipient, year) |>
      dplyr::mutate(
        drop_recipient = all(is.na(commitment_2011_constant))
      ) |>
      dplyr::ungroup() |>
      dplyr::filter(!drop_recipient) |>
      dplyr::select(-drop_recipient) |>
      
      ## drop sectors that have all NA for aid in a year
      dplyr::group_by(crs_sector_name, year) |>
      dplyr::mutate(
        drop_sector = all(is.na(commitment_2011_constant))
      ) |>
      dplyr::ungroup() |>
      dplyr::filter(!drop_sector) |>
      dplyr::select(-drop_sector) |>
      
      ## set NA aid values to zero
      dplyr::mutate(
        commitment_2011_contant = tidyr::replace_na(
          commitment_2011_constant, 0
        )
      ) ## return
    
  } else {
    
    ## grid of all possible combinations
    tidyr::expand_grid(
      donor = unique(dt$donor),
      recipient = unique(dt$recipient),
      crs_purpose_name = unique(dt$crs_purpose_name),
      year = unique(dt$year)
    ) |>
      
      ## join the aid data
      dplyr::left_join(
        dt, 
        by = c("donor", "recipient", "crs_purpose_name", "year") 
      ) |>
      
      ## fix missing country codes
      dplyr::group_by(donor) |>
      dplyr::mutate(
        dplyr::across(
          ccode_d:isocode_d,
          ~ ifelse(
            all(is.na(.x)),
            NA_integer_,
            max(.x, na.rm = T)
          ) 
        )
      ) |>
      dplyr::group_by(recipient) |>
      dplyr::mutate(
        dplyr::across(
          ccode_r:isocode_r,
          ~ ifelse(
            all(is.na(.x)),
            NA_integer_,
            max(.x, na.rm = T)
          ) 
        )
      ) |>
      
      ## fix missing purpose codes
      dplyr::group_by(crs_purpose_name) |>
      dplyr::mutate(
        crs_purpose_code = ifelse(
          all(is.na(crs_purpose_code)),
          NA_integer_,
          max(crs_purpose_code, na.rm = T)
        )
      ) |>
      
      ## drop donors that have all NA for aid in a year
      dplyr::group_by(donor, year) |>
      dplyr::mutate(
        drop_donor = all(is.na(commitment_2011_constant))
      ) |>
      dplyr::ungroup() |>
      dplyr::filter(!drop_donor) |>
      dplyr::select(-drop_donor) |>
      
      ## drop recipients that have all NA for aid in a year
      dplyr::group_by(recipient, year) |>
      dplyr::mutate(
        drop_recipient = all(is.na(commitment_2011_constant))
      ) |>
      dplyr::ungroup() |>
      dplyr::filter(!drop_recipient) |>
      dplyr::select(-drop_recipient) |>
      
      ## drop purposes that have all NA for aid in a year
      dplyr::group_by(crs_purpose_name, year) |>
      dplyr::mutate(
        drop_purpose = all(is.na(commitment_2011_constant))
      ) |>
      dplyr::ungroup() |>
      dplyr::filter(!drop_purpose) |>
      dplyr::select(-drop_purpose) |>
      
      ## set NA aid values to zero
      dplyr::mutate(
        commitment_2011_contant = tidyr::replace_na(
          commitment_2011_constant, 0
        )
      ) ## return
    
  }
}
