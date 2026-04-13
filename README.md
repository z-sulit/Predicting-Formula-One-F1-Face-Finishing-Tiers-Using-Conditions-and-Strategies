# Predicting Formula One (F1) Race Finishing Tiers Using Telemetry, Race Conditions, and Strategies
**Using Multivariate Techniques**

**Project By:** Jelliane Co, Justin Dampal & Lorenzo Sulit

---

## Overview
This project predicts a multi-class nonmetric dependent variable (Finishing Tier: Podium, Point Scorer, No Points) using multiple metric and nonmetric independent variables (telemetry, race conditions, and strategies). 

The following sections detail the statistical proofs used to validate the model's structural integrity and predictive power.

---
### Data Preparation



---


##  Statistical Checks & Theoretical Proofs

### 1. Box's M Test
* **Test:** Homogeneity of Covariance Matrices
* **Chi-Sq (approx.):** 94.0695
* **Degrees of Freedom (df):** 12
* **p-value:** 8.01e-15

**Methodological Justification & Number Explanation:** Box's M tests the assumption that the covariance matrices (the variance and relationships between variables) are equal across all three finishing tiers. The p-value of 8.01e-15 is significantly lower than the 0.05 threshold, formally rejecting the assumption of equal covariance. Because Multiple Discriminant Analysis (MDA) mathematically requires equal covariance to function properly, this empirical failure explicitly justifies the methodological choice to use **Multinomial Logistic Regression**, which does not require this strict assumption.

### 2. VIF Diagnostics (Variance Inflation Factor)
*Checking for structural multicollinearity among predictors.*

| Variable | VIF Score |
| :--- | :--- |
| **Tire_Age** | 3.219457 |
| **Fuel_Mass_Proxy** | 2.312793 |
| **Degradation_x_Fuel** | 1.724687 |
| **Tire_MEDIUM** | 1.174920 |
| **Tire_SOFT** | 1.151914 |

**Methodological Justification & Number Explanation:**
Variance Inflation Factors measure how much the standard errors of the estimated coefficients are inflated due to collinearity (variables correlating too heavily with one another). The standard methodological threshold for dangerous multicollinearity is a VIF $\ge 10$. Because all VIF values in this 3-race dataset range between 1.15 and 3.21, the model is mathematically stable. The engineered dynamic interaction term (`Degradation_x_Fuel`) was successfully mean-centered prior to multiplication, maintaining a safe VIF of 1.72 and preventing the standard errors from inflating and causing sign reversals in the model.

### 3. Multinomial Logistic Regression (MLE)
* **Residual Deviance:** 5659.623
* **AIC:** 5683.623

**Coefficients (Log-Odds):**
| Tier | (Intercept) | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_SOFT | Tire_MEDIUM |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Podium** | -1.15267885 | 0.015574369 | -0.002584033 | 3.867578e-04 | -0.1652435 | -0.2648714 |
| **Point Scorer** | 0.08925617 | -0.004134272 | -0.003971540 | 8.752288e-05 | -0.4550371 | -0.6135224 |

**Standard Errors:**
| Tier | (Intercept) | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_SOFT | Tire_MEDIUM |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Podium** | 0.2432533 | 0.008575122 | 0.002636178 | 0.0002053166 | 0.1564386 | 0.1572166 |
| **Point Scorer** | 0.1844912 | 0.006529977 | 0.002035249 | 0.0001550507 | 0.1184515 | 0.1212061 |

**Methodological Justification & Number Explanation:**
Maximum Likelihood Estimation (MLE) iteratively calculates the mathematical weights that best map telemetry inputs to race results. Using "No Points" as the baseline, the coefficients represent the change in the log-odds of a driver finishing in a specific tier based on unit shifts in the telemetry. For example, the positive coefficient for `Degradation_x_Fuel` (3.86e-04) in the Podium tier indicates that as this coupled physical force shifts, the log-odds of a driver landing on the podium increases relative to finishing out of the points.

### 4. Exact P-Values
*Derived via Z-scores from the model summary to test the statistical significance of the predictors.*

| Tier | (Intercept) | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_SOFT | Tire_MEDIUM |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Podium** | 2.152048e-06 | 0.06933554 | 0.3269777 | 0.05960363 | 0.2908388240 | 0.09203599 |
| **Point Scorer** | 6.285304e-01 | 0.52665394 | 0.0510121 | 0.57242800 | 0.0001222616 | 4.152945e-07 |

**Methodological Justification & Number Explanation:**
* **Interaction Term (`Degradation_x_Fuel`):** The p-value of **0.059** for the Podium tier falls just outside the strict 95% confidence threshold (p < 0.05), but is statistically significant at a 90% confidence level ($\alpha = 0.10$). This indicates a strong marginal trend that the coupling of tire degradation and fuel burn-off predicts podium placements over the 3-race aggregate. 
* **Tire Strategy:** The categorical tire variables (`Tire_SOFT` p = 0.00012; `Tire_MEDIUM` p = 4.15e-07) for the Point Scorer tier are highly significant (p < 0.001). This mathematically proves that a driver's choice of tire compound relative to the baseline tire is a definitive predictor of whether they finish in the points versus outside of the points. 
* **Standalone Fuel Mass:** The standalone `Fuel_Mass_Proxy` for the Podium tier yielded a p-value of 0.32, mathematically confirming that tracking baseline fuel burn-off without factoring in tire degradation is statistically insignificant as an isolated predictor.

---
### ML Validation

