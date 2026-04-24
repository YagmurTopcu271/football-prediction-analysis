# ⚽ Football Match Outcome Prediction

This project focuses on predicting football match outcomes (Home Win, Draw, Away Win) using historical match data, betting odds, and advanced performance metrics such as Expected Goals (xG) and PPDA.

The main objective is to compare different machine learning models and evaluate their predictive performance on real-world football data.

---

## 📊 Project Overview

Football matches are inherently uncertain, but statistical patterns such as team form, attacking strength, and betting market expectations can provide predictive signals.

This project builds a full machine learning pipeline including:

- Data collection from multiple Premier League seasons  
- Feature engineering (form, goal difference, xG, PPDA)  
- Multiple predictive models  
- Model evaluation and comparison  

---


---

## 🧠 Features Engineered

The following features were created to improve predictive performance:

- **Rolling form (last 5 matches)**
- **Goal difference trends**
- **Betting implied probabilities**
- **Expected Goals (xG) attack/defense strength**
- **PPDA (pressing intensity)**
- **Strength differentials between teams**

---

## 🤖 Models Used

The project compares multiple machine learning approaches:

- Multinomial Logistic Regression (baseline)
- Logistic Regression (binary classification)
- Random Forest (tree-based model)
- xG-enhanced models
- Draw-weighted adjustments

---

## 📈 Evaluation Metrics

Models are evaluated using:

- Accuracy
- Confusion Matrix
- Class-wise performance (Home / Draw / Away)
- Model comparison table

---

## 🏆 Key Results

- Betting odds are the strongest predictive feature group  
- xG features improve model robustness  
- Random Forest performs best overall  
- Draw prediction remains the most difficult class  

---

## 📊 Example Output

Model performance comparison is visualized in the R Markdown report:

- Accuracy comparison chart
- Confusion matrices
- Feature importance (Random Forest)



---

## 🚀 How to Run

1. Clone the repository
2. Open `football_prediction.Rproj`
3. Run scripts in order:
01_data_loading.R
02_feature_engineering.R
03_modeling.R
04_evaluation.R
football_prediction.Rmd
4. Knit the Rmd file


---

## 📌 Notes

- This project is for educational and analytical purposes.
- Model performance depends on feature quality and historical data coverage.

---

## 👤 Author

Yagmur Topcu


