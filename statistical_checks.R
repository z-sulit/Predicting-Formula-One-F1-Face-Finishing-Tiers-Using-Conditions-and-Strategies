library(heplots)
library(car)
library(nnet)

df <- read.csv("f1_clean_data.csv")

df$Finishing_Tier <- as.factor(df$Finishing_Tier)
df$Finishing_Tier <- relevel(df$Finishing_Tier, ref = "No Points")

continuous_vars <- df[, c("Tire_Age", "Fuel_Mass_Proxy", "Degradation_x_Fuel")]

cat("\nBOX'S M TEST\n")
box_m_result <- boxM(continuous_vars, df$Finishing_Tier)
print(box_m_result)

# DYNAMIC FORMULA BUILDER
# Find all column names that start with "Tire_"
all_tire_matches <- grep("^Tire_", colnames(df), value = TRUE)
tire_cols <- setdiff(all_tire_matches, "Tire_Age")

# Combine continuous variables with the clean tire dummy variables
predictors <- c("Tire_Age", "Fuel_Mass_Proxy", "Degradation_x_Fuel", tire_cols)

# Structural Multicollinearity: VIF Check
cat("\nVIF DIAGNOSTICS\n")
vif_model <- lm(as.numeric(Finishing_Tier) ~ Tire_Age + Fuel_Mass_Proxy + Degradation_x_Fuel + Tire_SOFT + Tire_MEDIUM, data = df)

vif_output <- vif(vif_model)
print(vif_output)

# Model Estimation: Multinomial Logistic Regression !!!<--
cat("\n--- MULTINOMIAL LOGISTIC REGRESSION (MLE) ---\n")
mnl_model <- multinom(Finishing_Tier ~ Tire_Age + Fuel_Mass_Proxy + Degradation_x_Fuel + Tire_SOFT + Tire_MEDIUM, data = df)

summary(mnl_model)

# fetch p-values
z_scores <- summary(mnl_model)$coefficients / summary(mnl_model)$standard.errors
p_values <- (1 - pnorm(abs(z_scores), 0, 1)) * 2

cat("\nEXACT P-VALUES\n")
print(p_values)
