library(dplyr)
library(tidyselect)
library(here)

employment_data <- readRDS("Employment2017.rds")

cleaned_data <- employment_data %>%
  select(
    Nation, Region, Division, State, CBSA, County, NAICS2, NAICS2_Name, NAICS3, NAICS3_Name, Establishments,
    matches("^WHT_([1-9]|1_2)$"),
    matches("^BLKT_([1-9]|1_2)$"),
    matches("^HISPT_([1-9]|1_2)$"),
    matches("^ASIANT_([1-9]|1_2)$"),
    matches("^AIANT_([1-9]|1_2)$"),
    matches("^NHOPIT_([1-9]|1_2)$"),
    matches("^TOMRT_([1-9]|1_2)$"),
    matches("^MT_([1-9]|1_2)$"),
    matches("^FT_([1-9]|1_2)$")
  )

if (!dir.exists("../ma-4615-fa24-final-project-group-5/dataset")) {
  dir.create("../ma-4615-fa24-final-project-group-5/dataset", recursive = TRUE)
}

saveRDS(cleaned_dataset, "../ma-4615-fa24-final-project-group-5/dataset/Cleaned_Employment2017.rds")