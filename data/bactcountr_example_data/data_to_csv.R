library(tidyverse)

load("data/bactcountr_example_data/CFU_data.rda")

cfu_data <- CFU_data %>% 
  filter(organ == "Spleen") %>% 
  select(-organ) %>% 
  mutate(replicate = paste(group, replicate, sep = "-"))

write_csv(cfu_data, file = "data/bactcountr_example_data/cfu_data.csv")
