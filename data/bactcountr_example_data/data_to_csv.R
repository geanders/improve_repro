library(tidyverse)

# First version---scenario of recording data in tidy format

load("data/bactcountr_example_data/CFU_raw_formatted.rda")

cfu_data_tidy <- CFU_raw_formatted %>% 
  filter(organ == "Spleen") %>% 
  select(-organ) %>% 
  mutate(replicate = paste(group, replicate, sep = "-"))

write_csv(cfu_data, file = "data/bactcountr_example_data/cfu_data_tidy.csv")

# Second version---tidy data after reading it in

load("data/bactcountr_example_data/CFU_data.rda")

cfu_data <- CFU_data %>% 
  filter(organ == "Spleen") %>% 
  select(-organ) %>% 
  mutate(replicate = paste(group, replicate, sep = "-"))

write_csv(cfu_data, file = "data/bactcountr_example_data/cfu_data.csv")
