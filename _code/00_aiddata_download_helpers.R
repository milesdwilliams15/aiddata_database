######################
## Download Helpers ##
######################


# setup -------------------------------------------------------------------
library(dplyr)
installed.packages() |>
  as_tibble() |>
  pull(Package) -> your_packages
have_googlesheets4 <- "googlesheets4" %in% your_packages

if(have_googlesheets4) {
  library(googlesheets4)
  gs4_deauth()
} else {
  message("You don't have {googlesheets4}. It's being installed for you.")
  install.packages("googlesheets4")
  library(googlesheets4)
  gs4_deauth()
}


# get_donorrecipientyear --------------------------------------------------

get_donorrecipientyear <- function(
    subset_years = NULL
) {
  id <- "1EsXsOV6S5mtZ8FVqYIeZTLlq-Vw6gDA4"
  dt <- read_csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id))
  
  if(is.null(subset_years)) {
    dt # return
  } else {
    dt |>
      filter(
        year %in% subset_years
      ) # return
  }
}

## test
# dt <- get_donorrecipientyear(subset_years = 1999)


# get_donorrecipientsectoryear --------------------------------------------


get_donorrecipientsectoryear <- function(
    subset_years = NULL
) {
  id <- "1EaqUZWipV1Dopfm998gsB_LSK7def8jR"
  dt <- read_csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id))
  
  if(is.null(subset_years)) {
    dt # return
  } else {
    dt |>
      filter(
        year %in% subset_years
      ) # return
  }
}

## test
# dt <- get_donorrecipientsectoryear(subset_years = 1999)


# get_donorrecipientpurposeyear -------------------------------------------

get_donorrecipientpurposeyear <- function(
    subset_years = NULL
) {
  id <- "1Ea8p5zAfOXE_flfbgNce4FwbqTvpkUos"
  dt <- read_csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id))
  
  if(is.null(subset_years)) {
    dt # return
  } else {
    dt |>
      filter(
        year %in% subset_years
      ) # return
  }
}

## test
# dt <- get_donorrecipientpurposeyear(subset_years = 1999)


# get_aiddata -------------------------------------------------------------

get_aiddata <- function(
    level = c("total", "sector", "purpose"),
    subset_years = NULL
) {
  if(!(level %in%  c("total", "sector", "purpose"))) stop(
    "Pick one of 'total', 'sector', or 'purpose' for option level."
  )
  level <- level[1]
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
  read_csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id))
}

## test
# view_codes()
