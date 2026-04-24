# -----------------------------
# LIBRARIES
# -----------------------------
library(readxl)
library(janitor)
library(dplyr)
library(purrr)
library(jsonlite)
library(here)

# -----------------------------
# MATCH DATA (EXCEL FILES)
# -----------------------------

df1 <- read_excel(here::here("data", "futbol.xlsx"), sheet = "E0 (3)") %>%
  clean_names()
df2 <- read_excel(here::here("data", "futbol.xlsx"), sheet = "E0 (4)") %>%
  clean_names()
df3 <- read_excel(here::here("data", "futbol.xlsx"), sheet = "E0 (5)") %>%
  clean_names()
df4 <- read_excel(here::here("data", "futbol.xlsx"), sheet = "E0 (6)") %>%
  clean_names()




common_cols <- c(
  "season","date","home_team","away_team",
  "fthg","ftag","ftr",
  "b365h","b365d","b365a"
)

df1 <- df1 %>% mutate(season = "2024/2025") %>% select(any_of(common_cols))
df2 <- df2 %>% mutate(season = "2023/2024") %>% select(any_of(common_cols))
df3 <- df3 %>% mutate(season = "2022/2023") %>% select(any_of(common_cols))
df4 <- df4 %>% mutate(season = "2021/2022") %>% select(any_of(common_cols))

all_seasons <- bind_rows(df4, df3, df2, df1) %>%
  mutate(
    date = as.Date(date, format = "%d/%m/%Y")
  ) %>%
  arrange(date, season) %>%
  mutate(match_id = row_number())

# -----------------------------
# XG DATA (RAW IMPORT ONLY)
# -----------------------------
files <- c(
  "data/21.json",
  "data/22.json",
  "data/23.json",
  "data/24.json"
)

xg_teams <- map_dfr(files, function(file) {
  season_data <- fromJSON(file, simplifyVector = TRUE)
  
  map_dfr(season_data$teams, function(team_obj) {
    bind_rows(team_obj$history) %>%
      mutate(team = team_obj$title)
  })
})

# -----------------------------
# BASIC CLEANING ONLY (NO FEATURES)
# -----------------------------
xg_teams <- xg_teams %>%
  mutate(
    date = as.Date(substr(date, 1, 10)),
    xG = as.numeric(xG),
    xGA = as.numeric(xGA),
    ppda_att = as.numeric(ppda$att),
    ppda_def = as.numeric(ppda$def),
    home_away = case_when(
      h_a == "h" ~ "Home",
      h_a == "a" ~ "Away",
      TRUE ~ NA_character_
    )
  ) %>%
  select(-ppda, -ppda_allowed)

# -----------------------------
# TEAM NAME STANDARDIZATION
# -----------------------------
xg_teams <- xg_teams %>%
  mutate(team = recode(team,
                       "Manchester United" = "Man United",
                       "Manchester City"   = "Man City",
                       "Newcastle United"  = "Newcastle",
                       "Nottingham Forest" = "Nott'm Forest",
                       "Wolverhampton Wanderers" = "Wolves"
  ))