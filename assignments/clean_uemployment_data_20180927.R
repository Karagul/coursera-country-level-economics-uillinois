# Anthony Nguyen 
# https://github.com/anguyen1210
#
# This script was used to read in and clean data sets on  unemployment from the 
# Swiss Economic Affairs office and the World Bank's World Development Indicators
# Database.  

library(tidyverse)

#the unemployment data is super messy, so I did a quick hack on excel to get the column headers more manageable for munging
ue_seco <- read_delim("../data/Amstat-SECO_2_1_Taux_de_chomage_20180926_HACK.csv",
                      ";", escape_double = FALSE, trim_ws = TRUE)

#the vacancy data we can read in as is
job_vacancies_SECO <- read_delim("data/Amstat-SECO_1_1_Places_vacantes_20180926.csv",
                                 ";", escape_double = FALSE, trim_ws = TRUE)

#pivot data frame and re-arrange column names before gather and spread
names(ue_seco) <- c("Date", "Measures", "Male", "Female", "Total")
ue_seco <- ue_seco %>% gather("Gender", "Value", Male:Total)
ue_seco <- ue_seco %>% spread(Measures, Value)
names(ue_seco) <- c("Date", "Gender", "Tot.unemployed", "Coefficient", "Pct.unemployed")

#remove blank rows at the bottom
ue_seco <- head(ue_seco, -3)

#convert relevant columns to numeric
ue_seco$Tot.unemployed <- str_replace_all(ue_seco$Tot.unemployed, "'","")
ue_seco$Tot.unemployed <- as.numeric(ue_seco$Tot.unemployed)
ue_seco$Pct.unemployed <- as.array(ue_seco$Pct.unemployed)

#split Date column, select final columns
ue_seco <- ue_seco %>% mutate(Month = word(Date, 1), Year = word(Date, 2)) %>% 
  select(Year, Month, Gender, Tot.unemployed, Pct.unemployed)

#save final data frame
save(ue_seco, file = "../rda/ue_seco.rda")

#pivot relevant columns and rows, filter out unwanted ones
jv_seco <- job_vacancies_SECO %>% 
  gather("DATE", "Job_vacancies", `Janvier 2004`:`Décembre 2017_2`) %>% 
  select(DATE, Job_vacancies) %>%
  filter(!str_detect(Job_vacancies, "Places")) %>% filter(!str_detect(DATE, "_")) %>% 
  mutate(Month = word(DATE, 1), Year = word(DATE, 2))

#clean and then convert Job_vacancies column to numeric
jv_seco$Job_vacancies <- str_replace_all(jv_seco$Job_vacancies, "'","")
jv_seco$Job_vacancies <- as.numeric(jv_seco$Job_vacancies)

#drop extraneous column and re-order
jv_seco <-jv_seco %>% select(Year, Month, Job_vacancies)

#save final data frame
save(jv_seco, file = "../rda/jv_seco.rda")

#read in the World Bank data
Wdi_extract <- read_csv("../data/WB_WDI_Data_extract_20180925.csv")

#get rid of unwanted column, delete unwanted rows at the end
wdi_extract <- wdi_extract %>% 
  select(-`Series Code`) %>% 
  filter(!is.na(`Series Name`))

#gather year values into single column, spread series name over multiple columns
wdi_extract <- wdi_extract %>% 
  gather("Year", "Total", `2000 [YR2000]`:`2017 [YR2017]`) %>% 
  spread(`Series Name`, Total)

#clean "Year" column
wdi_extract$Year <- word(WDI_extract$Year, 1)

#remove the "Coverage of Social Protection..." column as its blank
wdi_extract <- wdi_extract %>% select(-`Coverage of social protection and labor programs (% of population)`)

save(wdi_extract, file = "../rda/wdi_extract.rda")
