# =============================================================================
# Phase 3: Statistical Validation & Theoretical Proof
# Dataset: 2023 Bahrain GP -- f1_clean_data.csv
# Goal:
#   1. Fail the Proportional Odds assumption -> justify pivot to Logistic Regression
#   2. Confirm robust standard errors are safe (Breusch-Pagan test)
#   3. Generate baseline multinomial logistic regression coefficients
# =============================================================================

# --- 0. Install & Load Required Packages ------------------------------------
packages <- c("MASS", "brant", "lmtest", "sandwich", "nnet")
new_pkgs  <- packages[!(packages %in% installed.packages()[, "Package"])]
if (length(new_pkgs)) install.packages(new_pkgs, repos = "https://cloud.r-project.org")

library(MASS)      # polr() - ordered logistic (needed for Brant test)
library(brant)     # brant() - Brant Test for proportional odds assumption
library(lmtest)    # bptest() - Breusch-Pagan heteroscedasticity test
library(sandwich)  # vcovHC() - robust (HC3) standard errors
library(nnet)      # multinom() - multinomial logistic regression

# --- 1. Load & Prepare Data -------------------------------------------------
df <- read.csv("f1_clean_data.csv", stringsAsFactors = FALSE)

cat("=== DATA OVERVIEW ===\n")
cat("Rows:", nrow(df), "| Cols:", ncol(df), "\n")
print(table(df$Finishing_Tier))

# Ordered factor for polr() / Brant test
df$Finishing_Tier_ord <- factor(
  df$Finishing_Tier,
  levels  = c("No Points", "Point Scorer", "Podium"),
  ordered = TRUE
)

# Unordered factor, reference = "No Points", for multinom()
df$Finishing_Tier <- relevel(factor(df$Finishing_Tier), ref = "No Points")

# --- 2. BRANT TEST: Proportional Odds (Parallel Lines Assumption) -----------
# H0: Proportional odds hold -- each predictor has the SAME effect at every
#     threshold. p < 0.05 on ANY predictor FAILS the assumption, making
#     Ordinal Logistic invalid and Multinomial Logistic the correct choice.

cat("\n=== BRANT TEST (Proportional Odds Assumption) ===\n")
cat("H0: Parallel lines hold across all outcome thresholds.\n")
cat("p < 0.05 on any predictor -> assumption VIOLATED -> pivot justified.\n\n")

ordinal_model <- polr(
  Finishing_Tier_ord ~ Tire_Age + Fuel_Mass_Proxy + Degradation_x_Fuel +
    Tire_MEDIUM + Tire_SOFT,
  data   = df,
  Hess   = TRUE,
  method = "logistic"
)

brant_result <- brant(ordinal_model)
print(brant_result)

cat("\n>>> INTERPRETATION:\n")
if (any(brant_result[, "p-value"] < 0.05, na.rm = TRUE)) {
  cat("RESULT : Proportional odds assumption VIOLATED (p < 0.05 detected).\n")
  cat("DECISION: Pivot to Multinomial Logistic Regression is JUSTIFIED.\n")
} else {
  cat("RESULT : Proportional odds assumption holds.\n")
  cat("DECISION: Consider Ordinal Logistic Regression instead.\n")
}

# --- 3. BREUSCH-PAGAN TEST: Robust Standard Errors --------------------------
# Fit a linear probability proxy model to test for heteroscedasticity.
# p < 0.05 -> heteroscedastic residuals -> HC3 robust SEs are required.

cat("\n=== BREUSCH-PAGAN TEST (Heteroscedasticity Check) ===\n")
cat("H0: Residuals are homoscedastic (constant variance).\n")
cat("p < 0.05 -> heteroscedasticity detected -> robust SEs needed.\n\n")

df$tier_numeric <- as.numeric(df$Finishing_Tier)

lm_proxy <- lm(
  tier_numeric ~ Tire_Age + Fuel_Mass_Proxy + Degradation_x_Fuel +
    Tire_MEDIUM + Tire_SOFT,
  data = df
)

bp_test <- bptest(lm_proxy)
print(bp_test)

cat("\n>>> INTERPRETATION:\n")
if (bp_test$p.value < 0.05) {
  cat("RESULT : Heteroscedasticity DETECTED (p =", round(bp_test$p.value, 4), ").\n")
  cat("ACTION : HC3 robust standard errors will be applied.\n")
} else {
  cat("RESULT : No significant heteroscedasticity (p =", round(bp_test$p.value, 4), ").\n")
  cat("ACTION : Standard errors are safe as-is.\n")
}

cat("\n--- HC3 Robust Standard Errors (Linear Proxy) ---\n")
robust_se <- sqrt(diag(vcovHC(lm_proxy, type = "HC3")))
print(round(robust_se, 5))

# --- 4. BASELINE MODEL: Multinomial Logistic Regression ---------------------
# Reference class: "No Points"
# Outputs log-odds and odds ratios for Point Scorer and Podium vs No Points.

cat("\n=== BASELINE MULTINOMIAL LOGISTIC REGRESSION ===\n")
cat("Reference class : 'No Points'\n")
cat("Comparisons     : Point Scorer vs No Points | Podium vs No Points\n\n")

multinom_model <- multinom(
  Finishing_Tier ~ Tire_Age + Fuel_Mass_Proxy + Degradation_x_Fuel +
    Tire_MEDIUM + Tire_SOFT,
  data  = df,
  trace = FALSE
)

cat("--- Coefficients (Log-Odds) ---\n")
print(coef(multinom_model))

cat("\n--- Odds Ratios (exp of coefficients) ---\n")
print(round(exp(coef(multinom_model)), 4))

cat("\n--- Full Model Summary ---\n")
print(summary(multinom_model))

# --- 5. PHASE SUMMARY -------------------------------------------------------
cat("\n=== PHASE 3 COMPLETE ===\n")
cat("[v] Brant Test     -> Proportional odds tested\n")
cat("[v] Breusch-Pagan  -> Heteroscedasticity assessed, robust SEs confirmed\n")
cat("[v] Multinomial LR -> Baseline coefficients generated\n")
cat("Next: Phase 4 -- Cross-Race Generalization & Model Tuning\n")
