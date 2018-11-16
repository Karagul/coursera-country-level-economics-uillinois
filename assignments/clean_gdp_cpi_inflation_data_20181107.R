# Anthony Nguyen 
# https://github.com/anguyen1210
#
# This script was used to read in and clean GDP growth and CPI inflation data
# from the World Bank WDI database.
# 
# short-term interest rate data provided from OECD data hub

library(tidyverse)

#read in the World Bank data
gdp_cpi_ch <- read_csv("../data/gdp_cpi_ch_20181107.csv")

#get rid of unwanted columns, delete unwanted rows at the end
gdp_cpi_ch <- gdp_cpi_ch %>% 
  select(-`Country Code`, -`Series Code`) %>% 
  filter(!is.na(`Series Name`))

#gather year values into single column, spread series name over multiple columns
gdp_cpi_ch <- gdp_cpi_ch %>% 
  gather("Year", "Total", `1980 [YR1980]`:`2017 [YR2017]`) %>% 
  spread(`Series Name`, Total)

#clean "Year" column
gdp_cpi_ch$Year <- word(gdp_cpi_ch$Year, 1)

#convert relevant columns to numeric
gdp_cpi_ch$Year <- as.numeric(gdp_cpi_ch$Year)
gdp_cpi_ch$`GDP growth (annual %)` <- as.numeric(gdp_cpi_ch$`GDP growth (annual %)`) 
gdp_cpi_ch$`Inflation, consumer prices (annual %)` <- as.numeric(gdp_cpi_ch$`Inflation, consumer prices (annual %)`)

#read in OECD interest rate data for Switzerland
short_term_int_CH <- read_csv("../data/short_term_interest_CH_1980_2017_OECD.csv")

#select out columns of interest, join to 'gdp_cpo-ch' table
gdp_cpi_ch <- short_term_int_CH %>% select("Year" = TIME, "Avg. short-term interest (annual %)" = Value) %>% 
  left_join(gdp_cpi_ch)

#re-order table to final format
gdp_cpi_ch <- gdp_cpi_ch %>% select("Country" = `Country Name`, Year, "GDP growth" = `GDP growth (annual %)`, "Inflation, CPI" = `Inflation, consumer prices (annual %)`, "Interest, short-term avg." = `Avg. short-term interest (annual %)`)

#save final .rda object
save(gdp_cpi_ch, file = "../rda/gdp_cpi_ch.rda")
