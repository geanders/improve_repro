library(readstata13)
library(dplyr)
library(readr)
library(forcats)
library(lubridate)
library(ggplot2)
library(scales)
library(tigris)
library(elevatr)
library(rayshader)
library(raster)
library(sf)

# Read in data (in a Stata 13 file)
pr_deaths <- read.dta13("data/1997-2014 DEFUNCIONES  GWU.DTA")

# Translate names of the columns we want to keep if needed
pr_deaths <- pr_deaths %>% 
  rename(birth_date = fechanacimiento,
         death_date = fechadefuncion,
         death_type = dthtype,
         cause_1 = Cause1,
         place_of_death = deathocc,
         est_age = edadcalculada)

# Reduce to certain columns
pr_deaths <- pr_deaths %>% 
  select(birth_date, death_date, sex, death_type, 
         cause_1, place_of_death, est_age)

# Translate values when needed
pr_deaths <- pr_deaths %>% 
  mutate(sex = fct_recode(sex,
                          male = "Masculino",
                          female = "Femenino"),
         death_type = fct_recode(death_type,
                                 natural = "No aplica o natural",
                                 accident = "Accidente",
                                 suicide = "Suicidio", 
                                 homicide = "Homicidio",
                                 "under investigation" = "Pendiente de investigar",
                                 undetermined = "No se pudo determinar",
                                 "legal intervention" = "Intervención legal"
                                 ))

# Limit to records with non-missing birth dates, death dates, and ages
pr_deaths <- pr_deaths %>% 
  filter(!is.na(birth_date)) %>% 
  filter(!is.na(death_date)) %>% 
  filter(!is.na(est_age))

# Time series of deaths by time
pr_deaths %>% 
  mutate(young = est_age < 65) %>% 
  group_by(death_date, young) %>% 
  count() %>% 
  ggplot(aes(x = death_date, y = n)) + 
  geom_point(alpha = 0.2) +
  geom_smooth(se = FALSE, method = "loess", span = 0.06) + 
  facet_wrap(~ young, ncol = 1, scales = "free_y")

# Top 10 causes of death 
icd_codes <- read_fwf("data/Section111ValidICD10-2019.txt",
                      fwf_widths(c(9, 60), c("code", "description")),
                      skip = 1, trim_ws = TRUE)

pr_deaths %>% 
  filter(cause_1 != "") %>% 
  mutate(young = case_when(
    est_age < 65 ~ "Under 65",
    est_age >= 65 ~ "65 or older",
    TRUE ~ NA_character_
  )) %>% 
  group_by(cause_1, young) %>% 
  count() %>% 
  group_by(young) %>% 
  arrange(desc(n)) %>% 
  slice(1:10) %>% 
  left_join(icd_codes, by = c("cause_1" = "code")) %>% 
  ggplot(aes(x = fct_reorder(description, n, .fun = sum), y = n)) + 
  geom_col() +
  facet_wrap(~ young, scales = "free_y", ncol = 1) + 
  coord_flip() +
  scale_y_continuous(name = "Total deaths", label = comma) + 
  scale_x_discrete(name = "")

# Map
pr_counties <- counties(state = "PR", cb = TRUE, class = "sf")

ggplot() + 
  geom_sf(data = pr_counties) + 
  geom_sf_text(data = pr_counties, aes(label = NAME))

# Map elevation
elev_counties <- c("Fajardo", "Ceiba", "Naguabo",
                   "Luquillo", "Rio Grande",
                   "Humacao", "Las Piedras",
                   "Juncos", "Canovanas", 
                   "Loiza")
east_pr_counties <- county_subdivisions(state = "PR", 
                                        county = elev_counties,
                                        cb = TRUE)
east_pr_elev <- east_pr_counties %>% 
  get_elev_raster(z = 9, clip = "bbox")
plot(east_pr_elev)
plot(east_pr_counties, add = TRUE)

pr_elev_mat <- matrix(extract(east_pr_elev, extent(east_pr_elev), buffer = 0),
                      nrow = ncol(east_pr_elev), 
                      ncol = nrow(east_pr_elev))
pr_elev_mat2 <- pmax(pr_elev_mat, 0)
pr_elev_mat2[pr_elev_mat2 > 1000] <- 0

pr_elev_mat2 %>%
  sphere_shade() %>%
  plot_3d(pr_elev_mat2, zscale = 40)
save_3dprint("east_pr_3d.stl", maxwidth = 4, unit = "in")

pr_elev_mat2 %>%
  sphere_shade(texture = "imhof1") %>%
  add_water(detect_water(pr_elev_mat2), color="imhof1") %>%
  add_shadow(ray_shade(pr_elev_mat2, zscale = 50, maxsearch = 300), 0.5) %>%
  plot_3d(pr_elev_mat2, zscale = 50, fov = 0, theta = 130,
          zoom = 0.2, phi = 15,
          windowsize = c(1000, 800))
