library(tigris)
library(sf)
library(ggplot2)
library(readr)
library(magrittr)
library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)

# fl_counties <- counties(state = "FL", cb = TRUE, class = "sf")
# save(fl_counties, file = "data/fl_counties.RData")
load("data/fl_counties.RData")
st_bbox(fl_counties)

fl_accidents <- read_csv("data/FARS2017NationalCSV/accident.csv")
fl_accidents %<>% 
  rename_all(str_to_lower) %>% 
  select(state, county, day, month, year, latitude, longitud, fatals) %>% 
  filter(state == 12) %>% 
  mutate(county = str_pad(county, width = 3, pad = "0")) %>% 
  unite(col = fips, c(state, county), sep = "") %>% 
  unite(col = date, c(month, day, year), sep = "-") %>% 
  mutate(date = mdy(date)) %>% 
  filter(date >= mdy("9-7-2017") & date <= mdy("9-13-2017"))
write_csv(fl_accidents, "data/fl_accidents.csv")

irma_week_accs <- fl_accidents %>% 
  group_by(fips) %>% 
  summarize(fatals = sum(fatals))

irma_accs <- fl_counties %>% 
  full_join(irma_week_accs, by = c("GEOID" = "fips")) %>% 
  mutate(fatals = ifelse(is.na(fatals), 0, fatals))

fl_accidents <- fl_accidents %>% 
  st_as_sf(coords = c("longitud", "latitude")) %>% 
  st_set_crs(st_crs(irma_accs))

irma_track <- st_read("data/al112017_best_track", 
                      layer = "al112017_lin") %>% 
  st_transform(crs = st_crs(irma_accs))

ggplot() + 
  geom_sf(data = irma_accs, aes(fill = fatals)) + 
  geom_sf(data = irma_track, color = "red", size = 1.5) + 
  coord_sf(xlim = c(-88, -80), ylim = c(24.5, 31.5)) +
  theme(axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.background = element_rect(fill = "aliceblue")) +
  scale_fill_viridis_c() + 
  labs(fill = "Fatalities") + 
  ggtitle("Motor vehicle fatalities in Florida counties during Irma")

leaflet() %>% 
  addTiles() %>% 
  fitBounds(lng1 = -88, lng2 = -80, lat1 = 24.5, lat2 = 31.5) %>% 
  addMarkers(data = fl_accidents) %>% 
  addPolylines(data = irma_track, color = "red") 
