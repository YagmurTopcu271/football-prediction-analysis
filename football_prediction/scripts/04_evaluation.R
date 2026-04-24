# -----------------------------
# LIBRARIES
# -----------------------------
library(dplyr)
library(caret)



# =========================================================
# 1. MULTINOMIAL MODELS EVALUATION
# =========================================================

# Accuracy function
acc <- function(pred, actual) {
  mean(pred == actual)
}

# ---- Model 1 ----
acc_m1 <- acc(pred1, test$FTR)
cm_m1  <- table(Predicted = pred1, Actual = test$FTR)

# ---- Model 2 ----
acc_m2 <- acc(pred2, test$FTR)
cm_m2  <- table(Predicted = pred2, Actual = test$FTR)

# ---- Final Model ----
acc_final <- acc(pred_final, test$FTR)
cm_final  <- table(Predicted = pred_final, Actual = test$FTR)

# ---- xG Model ----
acc_xg <- acc(pred_xg, test$FTR)
cm_xg  <- table(Predicted = pred_xg, Actual = test$FTR)



# =========================================================
# 2. RANDOM FOREST EVALUATION
# =========================================================

acc_rf <- acc(pred_rf, test$FTR)
cm_rf  <- table(Predicted = pred_rf, Actual = test$FTR)

# =========================================================
# 3. DRAW BOOSTED RF (FINAL IMPROVEMENT)
# =========================================================

rf_prob <- predict(rf_model, test, type = "prob")

pred_rf_draw <- ifelse(
  rf_prob[, "D"] > 0.30,
  "D",
  colnames(rf_prob)[apply(rf_prob, 1, which.max)]
)

acc_rf_draw <- acc(pred_rf_draw, test$FTR)
cm_rf_draw  <- table(Predicted = pred_rf_draw, Actual = test$FTR)

# =========================================================
# 4. MODEL COMPARISON TABLE
# =========================================================

results <- data.frame(
  Model = c(
    "Multinom (Form)",
    "Multinom (Odds)",
    "Multinom (Final)",
    "Multinom (xG)",
    "Random Forest",
    "RF + Draw Boost"
  ),
  Accuracy = c(
    acc_m1,
    acc_m2,
    acc_final,
    acc_xg,
    acc_rf,
    acc_rf_draw
  )
)

results <- results %>%
  arrange(desc(Accuracy))

print(results)

# =========================================================
# 5. BEST MODEL SUMMARY
# =========================================================

best_model <- results$Model[1]
best_acc <- results$Accuracy[1]

cat("\nBEST MODEL:", best_model, "\n")
cat("BEST ACCURACY:", best_acc, "\n")

# =========================================================
# 6. OPTIONAL: CONFUSION MATRIX OF BEST MODEL
# =========================================================

if (best_model == "Random Forest") {
  print(cm_rf)
} else if (best_model == "RF + Draw Boost") {
  print(cm_rf_draw)
} else if (best_model == "Multinom (xG)") {
  print(cm_xg)
} else if (best_model == "Multinom (Final)") {
  print(cm_final)
}