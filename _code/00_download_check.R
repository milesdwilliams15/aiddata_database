## can I download the data?
library(googlesheets4)
gs4_deauth()
id <- "1EsXsOV6S5mtZ8FVqYIeZTLlq-Vw6gDA4"
dt <- read_csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id))
## yes!