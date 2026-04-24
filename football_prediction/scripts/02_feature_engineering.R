# -----------------------------
# LIBRARIES
# -----------------------------
library(dplyr)
library(zoo)

# =========================================================
# 1. TEAM STRUCTURE (HOME / AWAY)
# =========================================================

home_data <- all_seasons %>%
  transmute(
    match_id, date, season,
    team = home_team,
    goals_scored = fthg,
    goals_conceded = ftag,
    result = ftr,
    home_win_odds = b365h,
    draw_odds = b365d,
    away_win_odds = b365a,
    home_away = "Home"
  )

away_data <- all_seasons %>%
  transmute(
    match_id, date, season,
    team = away_team,
    goals_scored = ftag,
    goals_conceded = fthg,
    result = ftr,
    home_win_odds = b365h,
    draw_odds = b365d,
    away_win_odds = b365a,
    home_away = "Away"
  )

team_data <- bind_rows(home_data, away_data) %>%
  arrange(team, date)

# =========================================================
# 2. BASIC PERFORMANCE FEATURES
# =========================================================

team_data <- team_data %>%
  mutate(
    match_result = case_when(
      goals_scored > goals_conceded ~ "Win",
      goals_scored < goals_conceded ~ "Loss",
      TRUE ~ "Draw"
    ),
    points = case_when(
      match_result == "Win" ~ 3,
      match_result == "Draw" ~ 1,
      TRUE ~ 0
    ),
    goal_diff = goals_scored - goals_conceded
  )

# =========================================================
# 3. ROLLING FORM FEATURES (POINTS + GD)
# =========================================================

team_data <- team_data %>%
  group_by(team) %>%
  arrange(date) %>%
  mutate(
    rolling_points_5 = rollapply(lag(points), 5, mean, fill = NA, align = "right"),
    rolling_gd = rollapply(lag(goal_diff), 5, mean, fill = NA, align = "right")
  ) %>%
  ungroup()

# =========================================================
# 4. BUILD MATCH-LEVEL FORM FEATURES
# =========================================================

home_form_df <- team_data %>%
  filter(home_away == "Home") %>%
  select(match_id,
         Home_form = rolling_points_5,
         Home_gd_form = rolling_gd)

away_form_df <- team_data %>%
  filter(home_away == "Away") %>%
  select(match_id,
         Away_form = rolling_points_5,
         Away_gd_form = rolling_gd)

match_data <- all_seasons %>%
  select(
    match_id, date, season,
    HomeTeam = home_team,
    AwayTeam = away_team,
    home_win_odds = b365h,
    draw_odds = b365d,
    away_win_odds = b365a,
    FTR = ftr
  ) %>%
  left_join(home_form_df, by = "match_id") %>%
  left_join(away_form_df, by = "match_id") %>%
  mutate(
    FTR = factor(FTR, levels = c("H", "D", "A")),
    form_diff = Home_form - Away_form,
    gd_diff = Home_gd_form - Away_gd_form,
    home_win = ifelse(FTR == "H", 1, 0)
  )

# =========================================================
# 5. BETTING FEATURES
# =========================================================

match_data <- match_data %>%
  mutate(
    p_home = 1 / home_win_odds,
    p_draw = 1 / draw_odds,
    p_away = 1 / away_win_odds
  )

# normalized probabilities
match_data <- match_data %>%
  mutate(
    total = p_home + p_draw + p_away,
    p_home = p_home / total,
    p_draw = p_draw / total,
    p_away = p_away / total
  )

# =========================================================
# 6. xG + PPDA FEATURES
# =========================================================

team_data <- team_data %>%
  left_join(
    xg_teams %>%
      select(team, date, xG, xGA, ppda_att, ppda_def),
    by = c("team", "date")
  )

team_data <- team_data %>%
  group_by(team) %>%
  arrange(date) %>%
  mutate(
    rolling_xg = rollapply(lag(xG), 5, mean, fill = NA, align = "right"),
    rolling_xga = rollapply(lag(xGA), 5, mean, fill = NA, align = "right")
  ) %>%
  ungroup()

# =========================================================
# 7. MATCH-LEVEL xG FEATURES
# =========================================================

home_xg_df <- team_data %>%
  filter(home_away == "Home") %>%
  select(match_id,
         Home_xg_form = rolling_xg,
         Home_xga_form = rolling_xga)

away_xg_df <- team_data %>%
  filter(home_away == "Away") %>%
  select(match_id,
         Away_xg_form = rolling_xg,
         Away_xga_form = rolling_xga)

match_data <- match_data %>%
  left_join(home_xg_df, by = "match_id") %>%
  left_join(away_xg_df, by = "match_id")

# =========================================================
# 8. DIFFERENCE FEATURES (FINAL ENGINEERING LAYER)
# =========================================================

match_data <- match_data %>%
  mutate(
    xg_diff = Home_xg_form - Away_xg_form,
    xga_diff = Home_xga_form - Away_xga_form,
    strength_diff = Home_form - Away_form,
    attack_vs_def = Home_xg_form - Away_xga_form,
    defense_vs_attack = Away_xg_form - Home_xga_form
  )

# =========================================================
# 9. PPDA FEATURES
# =========================================================

home_ppda_df <- team_data %>%
  filter(home_away == "Home") %>%
  select(match_id,
         Home_ppda_att = ppda_att)

away_ppda_df <- team_data %>%
  filter(home_away == "Away") %>%
  select(match_id,
         Away_ppda_att = ppda_att)

match_data <- match_data %>%
  left_join(home_ppda_df, by = "match_id") %>%
  left_join(away_ppda_df, by = "match_id") %>%
  mutate(
    ppda_diff = Home_ppda_att - Away_ppda_att
  )

#NA 

match_data <- match_data %>%
  filter(
    !is.na(Home_form),
    !is.na(Away_form),
    !is.na(form_diff),
    !is.na(xg_diff),
    !is.na(ppda_diff),
    !is.na(strength_diff)
  )