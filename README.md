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


## Statistical Checks & Theoretical Proofs

### 1. Box's M Test
* **Test:** Homogeneity of Covariance Matrices
* **Chi-Sq (approx.):** 359.1542
* **Degrees of Freedom (df):** 12
* **p-value:** < 2.2e-16

**Methodological Justification:** Box's M tests the assumption of "homogeneity of covariance matrices." Because F1 races are heavily skewed by safety cars, track evolution, and lapped cars, the variance is wildly different between a Podium finisher and a DNF. The infinitesimally small p-value formally rejects the assumption of equal covariance matrices. Because Multiple Discriminant Analysis (MDA) mathematically requires equal covariance, this empirical failure firmly justifies our pivot to **Multinomial Logistic Regression**.

### 2. VIF Diagnostics (Variance Inflation Factor)
*Checking for structural multicollinearity among predictors.*

| Variable | VIF Score |
| :--- | :--- |
| **Tire_Age** | 10.862611 |
| **Fuel_Mass_Proxy** | 10.181348 |
| **Degradation_x_Fuel** | 1.425668 |
| **Tire_MEDIUM** | 1.259465 |
| **Tire_SOFT** | 1.236735 |

**Methodological Justification:**
While the main effects (`Tire_Age` and `Fuel_Mass_Proxy`) exhibited marginal multicollinearity (VIF ~10) due to their naturally coupled physical progression over a race distance, the engineered dynamic interaction term (`Degradation_x_Fuel`) remained highly stable with a VIF of 1.42. Because the main effects retained extreme statistical significance (p < 0.001) despite the inflated standard errors, the collinearity did not wash out their predictive validity. 

### 3. Multinomial Logistic Regression (MLE)
* **Residual Deviance:** 1670.047
* **AIC:** 1694.047

**Coefficients (Log-Odds):**
| Tier | (Intercept) | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_SOFT | Tire_MEDIUM |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Podium** | 3.266345 | -0.09615675 | -0.04412648 | -0.0005901679 | -3.922122 | -0.4963780 |
| **Point Scorer** | 3.312938 | -0.08885883 | -0.04057293 | -0.0004312872 | -13.528397 | -0.7852067 |

**Standard Errors:**
| Tier | (Intercept) | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_SOFT | Tire_MEDIUM |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Podium** | 0.5808099 | 0.01372058 | 0.006392277 | 0.0002804612 | 0.6645552 | 0.2887642 |
| **Point Scorer** | 0.8280538 | 0.01792484 | 0.008639517 | 0.0002551117 | 3.660437e-05 | 0.2762700 |

**Methodological Justification:**
Maximum Likelihood Estimation (MLE) calculated the exact mathematical weights mapping telemetry inputs to race results across multiple circuits. Using "No Points" as the baseline tier, these coefficients represent the change in the log-odds of a driver finishing in a specific tier based on telemetry shifts.

### 4. Exact P-Values
*Derived via Z-scores from the model summary. Highlights the statistical significance of the dynamic interaction terms across multiple circuits.*

| Tier | (Intercept) | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_SOFT | Tire_MEDIUM |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Podium** | 1.868273e-08 | 2.413847e-12 | 5.088152e-12 | **0.03535435** | 3.593926e-09 | 0.085619258 |
| **Point Scorer** | 6.310913e-05 | 7.147916e-07 | 2.650419e-06 | 0.09091663 | 0.000000 | 0.004480738 |

**Hypothesis Proof:**
The p-value of **0.035** for the `Degradation_x_Fuel` interaction term in the Podium tier proves statistical significance (p < 0.05). This formally validates the hypothesis that the mathematical coupling of tire degradation and fuel burn-off is a defining, predictive factor of a podium finish, even when tested against the variance of multiple track layouts and conditions.


### ML Validation

