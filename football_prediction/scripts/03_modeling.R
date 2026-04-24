# -----------------------------
# LIBRARIES
# -----------------------------
library(nnet)
library(randomForest)
library(dplyr)

# -----------------------------
# TRAIN / TEST SPLIT
# -----------------------------
train <- match_data %>% filter(season != "2024/2025")
test  <- match_data %>% filter(season == "2024/2025")

# -----------------------------
# CLASS WEIGHTS (FOR MULTINOMIAL MODELS)
# -----------------------------
class_counts <- table(train$FTR)
weights <- as.numeric(1 / class_counts[as.character(train$FTR)])

# =========================================================
# 1. MULTINOMIAL LOGISTIC REGRESSION (BASIC)
# =========================================================
model1 <- multinom(
  FTR ~ Home_form + Away_form + form_diff,
  data = train
)

pred1 <- predict(model1, test)

# =========================================================
# 2. MULTINOMIAL + ODDS
# =========================================================
model2 <- multinom(
  FTR ~ Home_form + Away_form + form_diff +
    home_win_odds + draw_odds + away_win_odds,
  data = train
)

pred2 <- predict(model2, test)

# =========================================================
# 3. MULTINOMIAL + ODDS + WEIGHTS + GD FEATURES
# =========================================================
model_final <- multinom(
  FTR ~ Home_form + Away_form + form_diff +
    home_win_odds + draw_odds + away_win_odds +
    Home_gd_form + Away_gd_form + gd_diff,
  data = train,
  weights = weights,
  trace = FALSE
)

pred_final <- predict(model_final, test)

# =========================================================
# 4. MULTINOMIAL + xG FEATURES
# =========================================================
model_xg <- multinom(
  FTR ~ Home_form + Away_form + form_diff +
    home_win_odds + draw_odds + away_win_odds +
    Home_xg_form + Away_xg_form + xg_diff +
    Home_xga_form + Away_xga_form + xga_diff,
  data = train,
  weights = weights,
  trace = FALSE
)

pred_xg <- predict(model_xg, test)

# =========================================================
# 5. BINARY LOGISTIC MODELS
# =========================================================

# create binary target
match_data <- match_data %>%
  mutate(
    home_win = ifelse(FTR == "H", 1, 0)
  )

train <- match_data %>% filter(season != "2024/2025")
test  <- match_data %>% filter(season == "2024/2025")

model_bin1 <- glm(
  home_win ~ Home_form + Away_form + form_diff,
  data = train,
  family = "binomial"
)

model_bin2 <- glm(
  home_win ~ Home_form + Away_form + form_diff + p_home,
  data = train,
  family = "binomial"
)

prob1 <- predict(model_bin1, test, type = "response")
prob2 <- predict(model_bin2, test, type = "response")

pred_bin1 <- ifelse(prob1 > 0.5, 1, 0)
pred_bin2 <- ifelse(prob2 > 0.5, 1, 0)

# =========================================================
# 6. RANDOM FOREST MODEL
# =========================================================

rf_model <- randomForest(
  as.factor(FTR) ~ Home_form + Away_form + form_diff +
    p_home + p_draw + p_away +
    xg_diff +
    ppda_diff +
    strength_diff,
  data = train,
  ntree = 300
)

pred_rf <- predict(rf_model, test)