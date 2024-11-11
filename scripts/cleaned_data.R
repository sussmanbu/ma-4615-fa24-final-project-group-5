library(dplyr)
library(tidyselect)
library(here)

employment_data <- readRDS("Employment2017.rds")

cleaned_data <- employment_data %>%
  select(
    Nation, Region, Division, State, CBSA, County, NAICS2, NAICS2_Name, NAICS3, NAICS3_Name, Establishments,
    matches("^(WHT|BLKT|HISPT|ASIANT|AIANT|NHOPIT|TOMRT|MT|FT)[1-9](1_2)?$")
  )

# Ensure the directory exists, then save the cleaned data
if (!dir.exists("../ma-4615-fa24-final-project-group-5/dataset")) {
  dir.create("../ma-4615-fa24-final-project-group-5/dataset", recursive = TRUE)
}

saveRDS(cleaned_data, "../ma-4615-fa24-final-project-group-5/dataset/Cleaned_Employment2017.rds")