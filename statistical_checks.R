library(heplots)
library(car)
library(nnet)

df <- read.csv("f1_clean_data.csv")

df$Finishing_Tier <- as.factor(df$Finishing_Tier)
df$Finishing_Tier <- relevel(df$Finishing_Tier, ref = "No Points")

# Added GridPosition to the continuous variables for covariance testing
continuous_vars <- df[, c("GridPosition", "Tire_Age", "Fuel_Mass_Proxy", "Degradation_x_Fuel")]

cat("\nBOX'S M TEST\n")
box_m_result <- boxM(continuous_vars, df$Finishing_Tier)
print(box_m_result)

# DYNAMIC FORMULA BUILDER
all_tire_matches <- grep("^Tire_", colnames(df), value = TRUE)
tire_cols <- setdiff(all_tire_matches, "Tire_Age")

# Combine all predictors including GridPosition
predictors <- c("GridPosition", "Tire_Age", "Fuel_Mass_Proxy", "Degradation_x_Fuel", tire_cols)

cat("\nVIF DIAGNOSTICS\n")
vif_formula <- as.formula(paste("as.numeric(Finishing_Tier) ~", paste(predictors, collapse = " + ")))
vif_model <- lm(vif_formula, data = df)

vif_output <- vif(vif_model)
print(vif_output)

cat("\nMULTINOMIAL LOGISTIC REGRESSION (MLE)\n")
mnl_formula <- as.formula(paste("Finishing_Tier ~", paste(predictors, collapse = " + ")))
mnl_model <- multinom(mnl_formula, data = df)

summary(mnl_model)

z_scores <- summary(mnl_model)$coefficients / summary(mnl_model)$standard.errors
p_values <- (1 - pnorm(abs(z_scores), 0, 1)) * 2

cat("\nEXACT P-VALUES\n")
print(p_values)
