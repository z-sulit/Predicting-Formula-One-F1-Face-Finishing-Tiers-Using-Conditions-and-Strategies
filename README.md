# Predicting F1 Race Finishing Tiers Using Telemetry, Race Conditions, and Strategies
**Multivariate Statistical Analysis**

**Project By:** Jelliane Co, Justin Dampal & Lorenzo Sulit

---

## Overview

This project predicts a driver's finishing tier — Podium, Point Scorer, or No Points — using lap telemetry, race conditions, and strategy variables. The sections below walk through each statistical check used to validate the model's structure and predictive power.

---

## Data Preparation

### 1. Data ingestion & multi-race stacking

We pulled race data from the **2023 Bahrain, Saudi Arabian, and Australian Grands Prix** using the `FastF1` API. Three races gave us coverage across meaningfully different track types — permanent, street, and parkland circuits — so the model isn't just learning one layout. Every lap from every driver across all three events was stacked into a single dataframe to give MLE enough observations to work with.

### 2. Defining the target variable

`Finishing_Tier` is a three-class non-metric variable mapped from final race classifications:

- **Podium:** Positions 1–3
- **Point Scorer:** Positions 4–10
- **No Points:** Positions 11 and below

### 3. DNF protocol

Drivers who retired mid-race needed special handling. By merging `session.results` with lap data, we flagged any driver with a status of "Retired" or a classified position of "R" and reassigned all their completed laps to the **No Points** tier. Without this step, a driver running P2 pace before a mechanical failure would contaminate the Podium cluster with telemetry from someone who never finished.

### 4. Feature engineering & interaction modeling

Three metric predictors were built to represent the physics of race strategy:

- **Fuel Mass Proxy:** Exact fuel loads are proprietary, so we engineered a linear burn-off proxy starting at 110 kg and decreasing to 0 kg based on total laps completed per race.
- **Tire Age:** Pulled directly from `TyreLife` to capture rubber degradation over a stint.
- **Degradation × Fuel (interaction term):** Tire Age multiplied by Fuel Mass, mean-centered before multiplication. Mean-centering prevents structural multicollinearity and lets us interpret the coefficient as the *combined* effect of both forces — not just their individual contributions.

### 5. Categorical encoding (k-1 dummies)

Tire compound choices are non-metric, so we used dummy variable encoding. Following the k-1 rule, we dropped the first alphabetical compound as the baseline and created binary indicators for `Tire_SOFT` and `Tire_MEDIUM`. This sidesteps the dummy variable trap and lets us read each coefficient as the compound's effect relative to a fixed reference.

### 6. Baseline pace anchoring

`GridPosition` was included as a control variable. Its job is to absorb the baseline aerodynamic and engine capability of the car, so the remaining coefficients can reflect what the *driver and strategy* contributed — not just which team they drove for.

**Result:** The processed dataset (`f1_clean_data.csv`) has 2,880 observations across three circuits.

---

## Statistical Checks & Theoretical Proofs

### 1. Box's M test — homogeneity of covariance matrices

| Statistic | Value |
| :--- | :--- |
| Chi-sq (approx.) | 160.419 |
| Degrees of Freedom | 20 |
| p-value | < 2.2e-16 |

Box's M tests whether the covariance matrices are equal across all three finishing tiers. The p-value is effectively zero, which formally rejects that assumption. This matters for method selection: Multiple Discriminant Analysis requires equal covariance to work correctly, and this result disqualifies it. **Multinomial Logistic Regression** was chosen specifically because it doesn't carry that requirement.

### 2. VIF diagnostics — multicollinearity check

| Variable | VIF Score |
| :--- | :--- |
| GridPosition | 1.007456 |
| Tire_Age | 3.219551 |
| Fuel_Mass_Proxy | 2.314596 |
| Degradation_x_Fuel | 1.724701 |
| Tire_MEDIUM | 1.181336 |
| Tire_SOFT | 1.155771 |

VIF measures how much a predictor's standard error inflates because of its correlation with other predictors. The threshold for problematic multicollinearity is typically VIF ≥ 10. Everything here falls between 1.00 and 3.22, so the predictors are structurally independent. The near-perfect VIF of 1.007 for `GridPosition` is worth noting: it confirms that starting position and tire degradation are mathematically unrelated, which is exactly what we'd expect physically.

### 3. Multinomial logistic regression (MLE)

**Model fit:**
- Residual Deviance: 3821.657
- AIC: 3849.657

**Coefficients (log-odds):**

| Tier | Intercept | GridPosition | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_MEDIUM | Tire_SOFT |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Podium | 4.856516 | -0.7977605 | 0.029083324 | -0.014936022 | 0.0008256694 | 0.2267218 | 0.2424192 |
| Point Scorer | 2.922957 | -0.2270777 | -0.003556666 | -0.008448375 | 0.0002182545 | -0.4600896 | -0.2538360 |

**Standard errors:**

| Tier | Intercept | GridPosition | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_MEDIUM | Tire_SOFT |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Podium | 0.4205836 | 0.03466782 | 0.013625445 | 0.004508500 | 0.0003181667 | 0.2628297 | 0.2740445 |
| Point Scorer | 0.2511281 | 0.01071908 | 0.007463093 | 0.002314867 | 0.0001769331 | 0.1376122 | 0.1317377 |

MLE finds the coefficient weights that best map our telemetry inputs to race results. "No Points" is the baseline, so all coefficients reflect log-odds relative to that tier. The negative sign on `GridPosition` (-0.80 for Podium) reads exactly as expected: as the grid number goes up (further back on the grid), the log-odds of a podium finish drop sharply.

### 4. Exact p-values

| Tier | Intercept | GridPosition | Tire_Age | Fuel_Mass_Proxy | Degradation_x_Fuel | Tire_MEDIUM | Tire_SOFT |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Podium | 0.0000 | 0.0000 | 0.0328 | 0.0009 | 0.0095 | 0.3883 | 0.3764 |
| Point Scorer | 0.0000 | 0.0000 | 0.6337 | 0.0003 | 0.2174 | 0.0008 | 0.0540 |

Two results stand out:

- **GridPosition (p = 0.000 for both tiers):** Starting position is overwhelmingly significant, confirming it's doing its job as a baseline control.
- **Degradation_x_Fuel (p = 0.009 for the Podium tier):** With grid position controlling for raw car pace, the interaction term achieves significance at α < 0.01. The coupling of tire degradation and fuel burn is a distinct, measurable predictor of podium finishes — not just noise.

---

## Machine learning validation

To test how well the statistical equation holds up on unseen data, we ran a **Multinomial Logistic Regression** with **Leave-One-Group-Out Cross-Validation (LOGO-CV)** across the three races.

`GridPosition` was kept in as a control variable, and `class_weight='balanced'` was applied to stop the model from defaulting to "No Points" predictions just because that class dominates the dataset.

### Final classification report (LOGO-CV)

**Overall Accuracy: 62.36%**

| Tier | Precision | Recall | F1-Score | Support (laps) |
| :--- | :--- | :--- | :--- | :--- |
| No Points | 0.74 | 0.67 | 0.70 | 1468 |
| Podium | 0.57 | 0.89 | 0.69 | 429 |
| Point Scorer | 0.49 | 0.45 | 0.47 | 983 |

### What the numbers mean

**Podium recall (0.89):** The model correctly identified 89% of all actual podium-finishing laps. Anchored by grid position, the tire wear and fuel coupling picks up top-tier performance signatures reliably across circuits it hasn't seen.

**Podium precision (0.57):** When the model predicts a podium lap, it's right 57% of the time. The control for starting pace prevents the model from just predicting "Podium" for any fast car regardless of team — the predictions are grounded in what the car can physically do from that grid slot.

**Midfield identification (0.45 recall):** The model caught 45% of point-scoring laps. The F1 midfield is genuinely harder to model — DRS trains, traffic, and track position create a lot of variance that telemetry alone can't fully explain. 45% is still well above chance for a three-class problem.

---

## Conclusion

Race outcomes in F1 aren't purely a function of car pace. By modeling the physical relationship between compound selection, tire degradation, and fuel burn, the structural equation captures something real — and the LOGO-CV results confirm it generalizes beyond the training circuits. Grid position sets the baseline. Telemetry defines the strategic execution. Their mathematical intersection predicts who ends up on the podium.
