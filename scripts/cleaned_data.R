library(dplyr)
library(tidyselect)
library(here)

#2017
employment_data <- readRDS("Employment2017.rds")

cleaned_data <- employment_data %>%
  select(
    Nation, Region, Division, State, CBSA, County, NAICS2, NAICS2_Name, NAICS3, NAICS3_Name, Establishments,
    matches("^(WHT|BLKT|HISPT|ASIANT|AIANT|NHOPIT|TOMRT|MT|FT)[1-9](1_2)?$")
  )

if (!dir.exists("../ma-4615-fa24-final-project-group-5/scripts")) {
  dir.create("../ma-4615-fa24-final-project-group-5/scripts", recursive = TRUE)
}

saveRDS(cleaned_data, "../ma-4615-fa24-final-project-group-5/scripts/Cleaned_Employment2017.rds")


#2022
employment_2022 <- readRDS("dataset/EEO1_2022_PUF.rds")

employment_2022 <- employment_2022 %>%
  rename_with(toupper)

cleaned_2022 <- employment_2022 %>%
  select(
    NATION, REGION, DIVISION, STATE, CBSA, COUNTY, NAICS2, NAICS2_NAME, NAICS3, NAICS3_NAME, ESTABLISHMENTS,
    matches("^(WHT|BLKT|HISPT|ASIANT|AIANT|NHOPIT|TOMRT|MT|FT)[1-9](_2)?$")
  )

if (!dir.exists("../ma-4615-fa24-final-project-group-5/scripts")) {
  dir.create("../ma-4615-fa24-final-project-group-5/scripts", recursive = TRUE)
}

saveRDS(cleaned_2022, "../ma-4615-fa24-final-project-group-5/scripts/Cleaned_Employment2022.rds")