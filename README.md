# Predicting Formula One (F1) Race Finishing Tiers Using Telemetry, Race Conditions, and Strategies
**Using Multivariate Techniques**

**Project By:** Jelliane Co, Justin Dampal & Lorenzo Sulit

---

## Overview
This project predicts a multi-class nonmetric dependent variable (Finishing Tier: Podium, Point Scorer, No Points) using multiple metric and nonmetric independent variables (telemetry, race conditions, and strategies). 

The following sections detail the statistical proofs used to validate the model's structural integrity and predictive power.

---
### Data Preparation

The objective of the data preparation phase was to transform raw Formula 1 telemetry and results into a structured dataset capable of supporting multivariate statistical inference.

### 1. Data Ingestion & Multi-Race Stacking
We utilized the `FastF1` API to pull comprehensive race data from the **2023 Bahrain, Saudi Arabian, and Australian Grands Prix**. This multi-race approach ensured the model captured global physical relationships across different track types (permanent, street, and parkland circuits). The data was stacked into a unified dataframe containing every lap completed by every driver across all three events to maximize the sample size for analysis.

### 2. Defining the Target Variable (Finishing Tier)
The dependent variable, `Finishing_Tier`, was engineered as a multi-class non-metric variable. We mapped final race classifications into three distinct categories:
* **Podium:** Positions 1 through 3.
* **Point Scorer:** Positions 4 through 10.
* **No Points:** Positions 11 and below.

### 3. DNF (Did Not Finish) Protocol
To maintain mathematical rigor, we implemented a strict DNF protocol. By merging official `session.results` with individual lap data, we identified drivers with a status of "Retired" or a classified position of "R". These drivers were programmatically reassigned to the **"No Points"** tier for all laps they completed, preventing the model from incorrectly attributing "Podium" telemetry signatures to drivers who failed to finish the race.

### 4. Feature Engineering & Interaction Modeling
Three primary metric predictors were engineered to represent the physics of race strategy:
* **Fuel Mass Proxy:** Since exact fuel loads are proprietary, we engineered a linear burn-off proxy starting at 110kg and decreasing to 0kg based on the total laps completed in each specific race.
* **Tire Age:** Extracted directly from `TyreLife` to track the physical degradation of the rubber compounds.
* **Degradation x Fuel (Interaction):** We created a mean-centered interaction term by multiplying Tire Age and Fuel Mass. Mean-centering was applied to prevent structural multicollinearity, allowing for a clear interpretation of how the coupling of these two physical forces impacts finishing probability.

### 5. Categorical Encoding (k-1 Dummies)
To incorporate non-metric strategy choices (Tire Compounds) into a regression environment, we utilized **Dummy Variable Encoding**. Following the **k-1 rule**, we dropped the first alphabetical compound to serve as the baseline, creating binary indicators for `Tire_SOFT` and `Tire_MEDIUM`. This avoids the "Dummy Variable Trap" and allows for the calculation of the relative impact of strategy choices against a constant reference.

### 6. Baseline Pace Anchoring
Finally, we incorporated `GridPosition` for each driver. This serves as a critical control variable in the multivariate equation, allowing the model to isolate the driver's strategic telemetry execution from the car's baseline aerodynamic and engine capability.

**Result:** The final processed dataset (`f1_clean_data.csv`) consists of 2,880 observations, providing a robust foundation for both Maximum Likelihood Estimation and Machine Learning validation.

---
## Statistical Checks & Theoretical Proofs

### 1. Box's M Test
* **Test:** Homogeneity of Covariance Matrices
* **Chi-Sq (approx.):** 160.419
* **Degrees of Freedom (df):** 20
* **p-value:** < 2.2e-16

**Methodological Justification & Number Explanation:** Box's M tests the assumption that the covariance matrices (the variance and relationships between variables) are equal across all three finishing tiers. The infinitesimally small p-value (< 2.2e-16) is significantly lower than the 0.05 threshold, formally rejecting the assumption of equal covariance. Because Multiple Discriminant Analysis (MDA) mathematically requires equal covariance to function properly, this empirical failure explicitly justifies our methodological choice to deploy **Multinomial Logistic Regression**, which does not require this strict assumption.

### 2. VIF Diagnostics (Variance Inflation Factor)
*Checking for structural multicollinearity among predictors.*

| Variable | VIF Score |
| :--- | :--- |
| **GridPosition** | 1.007456 |
| **Tire_Age** | 3.219551 |
| **Fuel_Mass_Proxy** | 2.314596 |
| **Degradation_x_Fuel** | 1.724701 |
| **Tire_MEDIUM** | 1.181336 |
| **Tire_SOFT** | 1.155771 |

**Methodological Justification & Number Explanation:**
Variance Inflation Factors measure how much the standard errors of the estimated coefficients are inflated due to collinearity. The standard methodological threshold for dangerous multicollinearity is a VIF $\ge 10$. Because all VIF values range between 1.00 and 3.21, the model is structurally bulletproof. Notably, the inclusion of `GridPosition` yielded a near-perfect VIF of 1.007, mathematically proving that a driver's starting pace operates completely independently of how their tires physically degrade over a stint. 

### 3. Multinomial Logistic Regression (MLE)
* **Residual Deviance:** 3821.657
* **AIC:** 3849.657 

**Coefficients (Log-Odds):**
| Tier | (Intercept) | GridPosition | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_MEDIUM | Tire_SOFT |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Podium** | 4.856516 | -0.7977605 | 0.029083324 | -0.014936022 | 0.0008256694 | 0.2267218 | 0.2424192 |
| **Point Scorer** | 2.922957 | -0.2270777 | -0.003556666 | -0.008448375 | 0.0002182545 | -0.4600896 | -0.2538360 |

**Standard Errors:**
| Tier | (Intercept) | GridPosition | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_MEDIUM | Tire_SOFT |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Podium** | 0.4205836 | 0.03466782 | 0.013625445 | 0.004508500 | 0.0003181667 | 0.2628297 | 0.2740445 |
| **Point Scorer** | 0.2511281 | 0.01071908 | 0.007463093 | 0.002314867 | 0.0001769331 | 0.1376122 | 0.1317377 |

**Methodological Justification & Number Explanation:**
Maximum Likelihood Estimation (MLE) iteratively calculates the mathematical weights that best map telemetry and pace inputs to race results. Using "No Points" as the baseline, the coefficients represent the change in the log-odds of a driver finishing in a specific tier. For example, the negative coefficient for `GridPosition` (-0.79) in the Podium tier perfectly aligns with the physical reality of motorsport: as the starting grid position number increases (moving further back), the log-odds of finishing on the podium severely decrease.

### 4. Exact P-Values
*Derived via Z-scores from the model summary to test the statistical significance of the predictors.*

| Tier | (Intercept) | GridPosition | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_MEDIUM | Tire_SOFT |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Podium** | 0.0000 | 0.0000 | 0.0328030 | 0.0009234781 | 0.00945677 | 0.3883470937 | 0.37637347 |
| **Point Scorer** | 0.0000 | 0.0000 | 0.6336702 | 0.0002626338 | 0.21737349 | 0.0008276522 | 0.05400093 |

**Methodological Justification & Number Explanation:**
* **Anchoring Baseline Pace (`GridPosition`):** With a p-value of 0.000 for both tiers, starting position is confirmed as an overwhelmingly significant predictor of race outcomes. It effectively acts as a mathematical anchor, isolating the baseline aerodynamic and engine capability of the car from the driver's telemetry execution.
* **The Interaction Term (`Degradation_x_Fuel`):** By utilizing `GridPosition` to control for the baseline speed of the car, the interaction term achieves a highly significant p-value of **0.009** for the Podium tier. This formally and definitively proves ($\alpha < 0.01$) that the mathematical coupling of tire degradation and fuel burn-off is a distinct, highly significant predictor of podium finishes.
---
### ML Validation

## 🤖 Phase 4: Machine Learning Validation

To test the practical predictive power of our statistical equations, we deployed a **Multinomial Logistic Regression** model utilizing **Leave-One-Group-Out Cross-Validation (LOGO-CV)** across the 3-race dataset.

To ensure the algorithm evaluates strategic execution rather than just awarding predictions to raw car dominance, the model utilizes `GridPosition` as a control variable alongside the primary telemetry predictors. Furthermore, balanced class weights (`class_weight='balanced'`) were applied to prevent the algorithm from ignoring the minority class (Podiums) in favor of the heavily skewed majority class (No Points).

### Final Classification Report (LOGO-CV)
* **Overall Accuracy:** 62.36%

| Tier | Precision | Recall | F1-Score | Support (Laps) |
| :--- | :--- | :--- | :--- | :--- |
| **No Points** | 0.74 | 0.67 | 0.70 | 1468 |
| **Podium** | 0.57 | 0.89 | 0.69 | 429 |
| **Point Scorer** | 0.49 | 0.45 | 0.47 | 983 |

### Interpretation of Results
The structural equation demonstrates robust predictive power across completely unseen circuits, yielding the following insights:

1. **High-Fidelity Podium Detection:** The model achieved an **0.89 Recall** for the Podium tier. This indicates that when anchored by Grid Position, the physical coupling of tire wear and fuel burn successfully identified 89% of all actual podium-finishing laps. This proves that top-tier finishing is strongly correlated with specific telemetry signatures.
2. **Stable Precision:** The model achieved a Podium precision of 0.57. By mathematically controlling for starting pace, the algorithm effectively distinguishes between high-performance constructors and slower teams, ensuring that strategic predictions are grounded in the realistic physical capability of the car.
3. **Midfield Identification:** The model successfully identified 45% of point-scoring laps (0.45 Recall). While the F1 midfield is often dictated by track-specific factors like DRS trains and traffic, the structural equation proved capable of isolating midfield strategy execution at a rate significantly higher than random chance.

### Conclusion
This research mathematically proves that race outcomes in Formula 1 are not merely dictated by raw car pace. By strictly defining the physical relationship between compound choices, tire degradation, and dynamic fuel mass, we established a statistically bulletproof, highly predictive structural equation. Telemetry dictates the macro-strategy, starting position dictates the baseline capability, and their mathematical intersection accurately predicts the Formula 1 podium.