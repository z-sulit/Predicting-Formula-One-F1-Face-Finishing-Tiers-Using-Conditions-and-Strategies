library(heplots)

data <- read.csv("f1_clean_data.csv")

# Convert the dependent variable to a factor and set the baseline
df$Finishing_Tier <- as.factor(df$Finishing_Tier)
df$Finishing_Tier <- relevel(df$Finishing_Tier, ref = "No Points")

#Methodological Pivot: Box's M Test

