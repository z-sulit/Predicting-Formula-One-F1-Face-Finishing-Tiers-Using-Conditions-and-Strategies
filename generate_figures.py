import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import LeaveOneGroupOut
from sklearn.metrics import confusion_matrix, classification_report, accuracy_score
import warnings
warnings.filterwarnings("ignore")

plt.rcParams.update({
    'font.family': 'Times New Roman',
    'font.size': 12,
    'axes.titlesize': 14,
    'axes.labelsize': 12,
    'xtick.labelsize': 10,
    'ytick.labelsize': 10,
    'figure.dpi': 300,
})

OUT = 'paper/figures/'
df = pd.read_csv('f1_clean_data.csv')
df = df.dropna(subset=['Finishing_Tier'])

# ---- Figure 1: Class Distribution ----
fig, ax = plt.subplots(figsize=(8, 5))
order = ['Podium', 'Point Scorer', 'No Points']
counts = df['Finishing_Tier'].value_counts().reindex(order)
colors = ['#FFD700', '#C0C0C0', '#CD7F32']
bars = ax.bar(order, counts.values, color=colors, edgecolor='black', linewidth=0.8)
for bar, val in zip(bars, counts.values):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 20,
            f'{val}\n({val/len(df)*100:.1f}%)', ha='center', va='bottom', fontsize=11)
ax.set_ylabel('Number of Laps')
ax.set_xlabel('Finishing Tier')
ax.set_title('Figure 1: Distribution of Lap Observations by Finishing Tier')
ax.set_ylim(0, max(counts.values) * 1.2)
plt.tight_layout()
plt.savefig(f'{OUT}fig1_class_distribution.png', dpi=300, bbox_inches='tight')
plt.close()
print("Figure 1 saved.")

# ---- Figure 2: VIF Bar Chart ----
vif_data = {
    'Variable': ['GridPosition', 'Tire_Age', 'Fuel_Mass_Proxy',
                 'Degradation_x_Fuel', 'Tire_MEDIUM', 'Tire_SOFT'],
    'VIF': [1.007456, 3.219551, 2.314596, 1.724701, 1.181336, 1.155771]
}
vif_df = pd.DataFrame(vif_data)

fig, ax = plt.subplots(figsize=(8, 5))
bars = ax.barh(vif_df['Variable'], vif_df['VIF'], color='#4C72B0', edgecolor='black', linewidth=0.8)
ax.axvline(x=10, color='red', linestyle='--', linewidth=1.5, label='Threshold (VIF = 10)')
for bar, val in zip(bars, vif_df['VIF']):
    ax.text(val + 0.15, bar.get_y() + bar.get_height()/2, f'{val:.2f}', va='center', fontsize=10)
ax.set_xlabel('Variance Inflation Factor (VIF)')
ax.set_title('Figure 2: VIF Diagnostics for Multicollinearity')
ax.set_xlim(0, 12)
ax.legend()
plt.tight_layout()
plt.savefig(f'{OUT}fig2_vif.png', dpi=300, bbox_inches='tight')
plt.close()
print("Figure 2 saved.")

# ---- Figure 3: MLE Coefficient Plot (Podium tier) ----
coef_data = {
    'Predictor': ['Intercept', 'GridPosition', 'Tire_Age',
                  'Fuel_Mass_Proxy', 'Deg_x_Fuel', 'Tire_MEDIUM', 'Tire_SOFT'],
    'Podium': [4.856516, -0.7977605, 0.029083324, -0.014936022, 0.0008256694, 0.2267218, 0.2424192],
    'PointScorer': [2.922957, -0.2270777, -0.003556666, -0.008448375, 0.0002182545, -0.4600896, -0.2538360],
}
# p-values
pvals = {
    'Podium': [0.0000, 0.0000, 0.0328, 0.0009, 0.0095, 0.3883, 0.3764],
    'PointScorer': [0.0000, 0.0000, 0.6337, 0.0003, 0.2174, 0.0008, 0.0540],
}

fig, axes = plt.subplots(1, 2, figsize=(14, 6), sharey=True)

for ax, tier, color, title in [
    (axes[0], 'Podium', '#E74C3C', 'Podium vs. No Points'),
    (axes[1], 'PointScorer', '#3498DB', 'Point Scorer vs. No Points')
]:
    coefs = coef_data[tier]
    pv = pvals[tier]
    colors_bar = [color if p < 0.05 else '#BDC3C7' for p in pv]
    bars = ax.barh(coef_data['Predictor'], coefs, color=colors_bar, edgecolor='black', linewidth=0.8)
    ax.axvline(x=0, color='black', linewidth=0.8)
    for bar, val, p in zip(bars, coefs, pv):
        sig = '*' if p < 0.05 else '**' if p < 0.01 else ''
        xpos = val + 0.05 if val >= 0 else val - 0.05
        ha = 'left' if val >= 0 else 'right'
        ax.text(xpos, bar.get_y() + bar.get_height()/2,
                f'{val:.4f}{sig}', va='center', ha=ha, fontsize=9)
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xlabel('Log-Odds Coefficient')

fig.suptitle('Figure 3: Multinomial Logistic Regression Coefficients\n(Filled = significant at p < 0.05)',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig(f'{OUT}fig3_coefficients.png', dpi=300, bbox_inches='tight')
plt.close()
print("Figure 3 saved.")

# ---- Figure 4: Confusion Matrix (LOGO-CV) ----
tire_cols = [col for col in df.columns if col.startswith('Tire_') and col not in ['Tire_Age', 'Tire_Age.1']]
base_features = ['GridPosition', 'Tire_Age', 'Fuel_Mass_Proxy'] + tire_cols
X = df[base_features]
y = df['Finishing_Tier']
groups = df['Race_ID']

model = LogisticRegression(solver='saga', max_iter=1000, class_weight='balanced')
logo = LeaveOneGroupOut()

all_y_true = []
all_y_pred = []

for train_index, test_index in logo.split(X, y, groups):
    X_train, X_test = X.iloc[train_index].copy(), X.iloc[test_index].copy()
    y_train, y_test = y.iloc[train_index], y.iloc[test_index]

    train_mean_tire = X_train['Tire_Age'].mean()
    train_mean_fuel = X_train['Fuel_Mass_Proxy'].mean()
    X_train['Degradation_x_Fuel'] = (X_train['Tire_Age'] - train_mean_tire) * (X_train['Fuel_Mass_Proxy'] - train_mean_fuel)
    X_test['Degradation_x_Fuel'] = (X_test['Tire_Age'] - train_mean_tire) * (X_test['Fuel_Mass_Proxy'] - train_mean_fuel)

    model.fit(X_train, y_train)
    predictions = model.predict(X_test)
    all_y_true.extend(y_test)
    all_y_pred.extend(predictions)

labels = ['No Points', 'Podium', 'Point Scorer']
cm = confusion_matrix(all_y_true, all_y_pred, labels=labels)

fig, ax = plt.subplots(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=labels, yticklabels=labels,
            ax=ax, linewidths=0.5, linecolor='gray', annot_kws={'size': 14})
ax.set_xlabel('Predicted Tier')
ax.set_ylabel('Actual Tier')
ax.set_title('Figure 4: Confusion Matrix — LOGO-CV (Accuracy: 62.36%)', fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig(f'{OUT}fig4_confusion_matrix.png', dpi=300, bbox_inches='tight')
plt.close()
print("Figure 4 saved.")

# ---- Figure 5: Grid Position vs Tier (Boxplot) ----
fig, ax = plt.subplots(figsize=(8, 5))
tier_order = ['Podium', 'Point Scorer', 'No Points']
palette = {'Podium': '#FFD700', 'Point Scorer': '#C0C0C0', 'No Points': '#CD7F32'}
sns.boxplot(data=df, x='Finishing_Tier', y='GridPosition', order=tier_order, palette=palette, ax=ax)
ax.set_xlabel('Finishing Tier')
ax.set_ylabel('Grid Position')
ax.set_title('Figure 5: Grid Position Distribution by Finishing Tier')
ax.invert_yaxis()
plt.tight_layout()
plt.savefig(f'{OUT}fig5_gridposition_boxplot.png', dpi=300, bbox_inches='tight')
plt.close()
print("Figure 5 saved.")

# ---- Figure 6: Tire Age vs Fuel Mass colored by Tier ----
fig, ax = plt.subplots(figsize=(8, 6))
for tier, color, marker in [('Podium', '#FFD700', 'o'), ('Point Scorer', '#C0C0C0', 's'), ('No Points', '#CD7F32', '^')]:
    subset = df[df['Finishing_Tier'] == tier].sample(n=min(400, len(df[df['Finishing_Tier'] == tier])), random_state=42)
    ax.scatter(subset['Fuel_Mass_Proxy'], subset['Tire_Age'], c=color, marker=marker,
               label=tier, alpha=0.5, edgecolors='black', linewidths=0.3, s=20)
ax.set_xlabel('Fuel Mass Proxy (kg)')
ax.set_ylabel('Tire Age (laps)')
ax.set_title('Figure 6: Tire Age vs. Fuel Mass Proxy by Finishing Tier')
ax.legend()
plt.tight_layout()
plt.savefig(f'{OUT}fig6_scatter_tierfuel.png', dpi=300, bbox_inches='tight')
plt.close()
print("Figure 6 saved.")

print("\nAll figures generated successfully.")
