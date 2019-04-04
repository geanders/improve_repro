library(readxl)
library(dplyr)
library(stringr)
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(viridis)
library(purrr)
library(ggrepel)

shipwrecks <- read_excel("data/AWOIS_Wrecks.xls") %>% 
  rename_all(str_to_lower)# %>% 
  #filter(!is.na(yearsunk))

# Plot locations
north_america <- ne_countries(scale = "medium", continent = "north america", 
                              returnclass = "sf")

ggplot() + 
  geom_sf(data = north_america) + 
  geom_point(data = shipwrecks, aes(x = londec, y = latdec),
             color = "red", alpha = 0.2) + 
  coord_sf(xlim = c(-80, -70), ylim = c(34, 42), expand = FALSE)

nc_north_sw <- shipwrecks %>% 
  filter(-80 < londec & londec < -70) %>% 
  filter(34 < latdec & latdec < 42)

ggplot() + 
  geom_sf(data = north_america) + 
  geom_point(data = nc_north_sw,
             aes(x = londec, y = latdec, color = yearsunk)) + 
  coord_sf(xlim = c(-80, -70), ylim = c(34, 42), expand = FALSE) + 
  scale_color_viridis()

# Shipwrecks by year
nc_north_sw %>% 
  group_by(yearsunk) %>% 
  count() %>% 
  ggplot(aes(x = yearsunk, y = n)) + 
  geom_rect(aes(xmin = 1940.5, xmax = 1944.5, ymin = 0, ymax = 5.1),
            fill = "red", alpha = 0.2) +
  geom_rect(aes(xmin = 1919.5, xmax = 1933.5, ymin = 0, ymax = 5.1),
            fill = "red", alpha = 0.2) +
  geom_bar(stat = "identity") 

# Map by time period
nc_north_sw <- nc_north_sw %>% 
  mutate(timeperiod = case_when(
    1940 <= yearsunk & yearsunk <= 1944 ~ "World War II",
    1919 <= yearsunk & yearsunk <= 1933 ~ "Prohibition",
    TRUE ~ "Other"
  ))

ggplot() + 
  geom_sf(data = north_america) + 
  geom_point(data = nc_north_sw,
             aes(x = londec, y = latdec, color = depth)) + 
  coord_sf(xlim = c(-80, -70), ylim = c(34, 42), expand = FALSE) + 
  facet_wrap(~ timeperiod)

ggplot() + 
  geom_sf(data = north_america) + 
  geom_point(data = filter(nc_north_sw, timeperiod == "Prohibition"),
             aes(x = londec, y = latdec),
             color = "red", alpha = 0.5) + 
  coord_sf(xlim = c(-80, -70), ylim = c(34, 42), expand = FALSE) +
  geom_label_repel(data = filter(nc_north_sw, timeperiod == "Prohibition"),
                  aes(x = londec, y = latdec, label = vesslterms),
                  alpha = 0.5)

# Norfolk-area wrecks
norfolk_sw <- shipwrecks %>% 
  filter(-76.75 < londec & londec < -76) %>% 
  filter(36.7 < latdec & latdec < 37.4)

ggplot() + 
  geom_sf(data = north_america) + 
  geom_point(data = norfolk_sw,
             aes(x = londec, y = latdec,
                 color = feature_type),
             alpha = 0.5) + 
  coord_sf(xlim = c(-76.75, -76), ylim = c(36.7, 37.4), expand = FALSE) 

norfolk_sw <- shipwrecks %>% 
  filter(-76.6 < londec & londec < -76) %>% 
  filter(36.8 < latdec & latdec < 37.2)

ggplot() + 
  geom_sf(data = north_america) + 
  geom_point(data = filter(norfolk_sw, vesslterms != "UNKNOWN"),
             aes(x = londec, y = latdec,
                 color = feature_type),
             alpha = 0.5) + 
  coord_sf(xlim = c(-76.6, -76), ylim = c(36.8, 37.2), expand = FALSE) +
  geom_label_repel(data = filter(norfolk_sw, vesslterms != "UNKNOWN"),
                   aes(x = londec, y = latdec, label = vesslterms),
                   alpha = 0.5, size = 2) + 
  theme(legend.position = "bottom")
