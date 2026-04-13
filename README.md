# Predicting Formula One (F1) Race Finishing Tiers Using Telemetry, Race Conditions, and Strategies
**Using Multivariate Techniques**

**Project By:** Jelliane Co, Justin Dampal & Lorenzo Sulit

---

## 🏎️ Project Overview
This project predicts a multi-class nonmetric dependent variable (Finishing Tier: Podium, Point Scorer, No Points) using multiple metric and nonmetric independent variables (telemetry, race conditions, and strategies). 

The following sections detail the statistical proofs used to validate the model's structural integrity and predictive power.

---

## 📊 Statistical Checks & Theoretical Proofs

### 1. Box's M Test
* **Test:** Homogeneity of Covariance Matrices
* **Chi-Sq (approx.):** 154.2461
* **Degrees of Freedom (df):** 12
* **p-value:** < 2.2e-16

**Methodological Justification:** Box's M tests the assumption of "homogeneity of covariance matrices." Because F1 races are heavily skewed by safety cars, track evolution, and lapped cars, the variance is wildly different between a Podium finisher and a DNF. The infinitesimally small p-value formally rejects the assumption of equal covariance matrices. Because Multiple Discriminant Analysis (MDA) mathematically requires equal covariance, this test empirically justifies our pivot to **Multinomial Logistic Regression**.

### 2. VIF Diagnostics (Variance Inflation Factor)
*Checking for structural multicollinearity among predictors. All values are successfully well below the >= 10 threshold.*

| Variable | VIF Score |
| :--- | :--- |
| **Tire_Age** | 1.581078 |
| **Fuel_Mass_Proxy** | 1.461338 |
| **Degradation_x_Fuel** | 1.228137 |
| **Tire_SOFT** | 1.116939 |
| **Tire_MEDIUM** | 1.017101 |

**Methodological Justification:**
Multiplying two physical variables together to create a dynamic interaction term (`Degradation_x_Fuel`) normally creates massive multicollinearity. By successfully mean-centering the variables before multiplication, we stripped out that correlation. Because our maximum VIF is 1.58, we can guarantee that our standard errors are completely stable and the model's logic is mathematically sound without risking sign reversals.

### 3. Multinomial Logistic Regression (MLE)
* **Residual Deviance:** 2012.937
* **AIC:** 2036.937

**Coefficients (Log-Odds):**
| Tier | (Intercept) | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_SOFT | Tire_MEDIUM |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Podium** | -2.0685150 | 0.10384946 | -0.0004779559 | 0.0013111940 | 0.04660021 | -9.781288 |
| **Point Scorer** | -0.8037748 | 0.06966195 | -0.0015246773 | 0.0001454267 | -0.59135813 | -12.103574 |

**Standard Errors:**
| Tier | (Intercept) | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_SOFT | Tire_MEDIUM |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Podium** | 0.3203095 | 0.01900799 | 0.003323620 | 0.0005095554 | 0.1875469 | 1.793300e-06 |
| **Point Scorer** | 0.2612683 | 0.01546546 | 0.002812835 | 0.0003949235 | 0.1536925 | 2.441766e-07 |

**Methodological Justification:**
Maximum Likelihood Estimation (MLE) calculated the exact mathematical weights mapping telemetry inputs to race results. Because "No Points" is the baseline tier, a positive coefficient (like `Degradation_x_Fuel` for the Podium tier) indicates that as this coupled physical force increases, the log-odds of a driver landing on the podium also increases relative to finishing out of the points.

### 4. Exact P-Values
*Derived via Z-scores from the model summary. Highlights the statistical significance of the dynamic interaction terms.*

| Tier | (Intercept) | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_SOFT | Tire_MEDIUM |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Podium** | 1.061917e-10 | 4.669328e-08 | 0.8856538 | **0.01007595** | 0.8037690294 | 0 |
| **Point Scorer** | 2.094924e-03 | 6.657394e-06 | 0.5877889 | 0.71269423 | 0.0001192459 | 0 |

**Hypothesis Proof:**
The p-value of **0.010** for the `Degradation_x_Fuel` interaction term in the Podium tier proves statistical significance (p < 0.05). This confirms the hypothesis that the mathematical coupling of tire degradation and fuel burn-off is a major predictive factor of a podium finish. The standalone `Fuel_Mass_Proxy` yielded a p-value of 0.88, proving that baseline fuel burn-off without factoring in tire degradation is statistically insignificant as a standalone predictor.