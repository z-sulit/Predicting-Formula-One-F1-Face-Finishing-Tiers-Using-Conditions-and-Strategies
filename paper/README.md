# Paper — F1 Finishing Tier Prediction

Overleaf project for the Multivariate Statistics paper.

## Overleaf Setup

1. **Compiler:** Menu → Compiler → **XeLaTeX** (required for Times New Roman)
2. **Upload everything** from this `paper/` folder into Overleaf, keeping the folder structure intact
3. `main.tex` is the master document — it pulls in all chapters automatically

## File Structure

| File | What It Is |
|------|-----------|
| `main.tex` | Master document — APA formatting, margins, fonts, TOC |
| `references.bib` | All citations. Add new references here, cite with `\textcite{key}` or `\parencite{key}` |
| `chapters/chapter1.tex` | Ch I: Introduction — Background, Problem, Purpose, Goals, Scope, Significance |
| `chapters/chapter2.tex` | Ch II: Literature Review — Theory, Existing Studies, Conceptual Framework, Research Gap, Definitions |
| `chapters/chapter3.tex` | Ch III: Methodology — Approach, Design, Sampling, Tools, Collection, Ethics, Credibility |
| `chapters/chapter4.tex` | Ch IV: Findings — All statistical tables, figures, hypothesis testing |
| `chapters/chapter5.tex` | Ch V: Discussion — Interpretation, Literature connection, Limitations, Practical impacts |
| `chapters/chapter6.tex` | Ch VI: Conclusion — Summary, Literature connection, Future directions, Recommendations |
| `chapters/appendix.tex` | Appendices — Raw R/Python outputs, dataset summary |
| `figures/` | PNG figures generated from data (6 figures) |

## 7-Chapter Structure

| Chapter | Title | Content |
|---------|-------|---------|
| I | Introduction | Background, Problem Statement, Research Purpose, Goals & Questions, Scope, Significance |
| II | Literature Review | Theoretical Foundation, Existing Studies (Foreign + Local), Conceptual Framework, Research Gap, Definition of Terms |
| III | Methodology | Research Approach, Design, Sampling, Tools & Instruments, Data Collection, Ethics, Credibility |
| IV | Findings | Key results, Data representation (tables + figures), Unexpected results, Hypothesis testing |
| V | Discussion | Interpreting results, Relating to literature, Study limitations, Practical impacts |
| VI | Conclusion | Summary, Connection to literature, Future research, Recommendations |
| VII | References/Bibliography | Auto-generated from `references.bib` (APA 7th, hanging indent) |

## Figures (generated from data)

| Figure | Description |
|--------|-------------|
| `fig1_class_distribution.png` | Class distribution bar chart (Podium / Point Scorer / No Points) |
| `fig2_vif.png` | VIF diagnostics bar chart with threshold line |
| `fig3_coefficients.png` | MLE coefficient plot by tier (significant = filled) |
| `fig4_confusion_matrix.png` | Confusion matrix heatmap from LOGO-CV |
| `fig5_gridposition_boxplot.png` | Grid position distribution by tier |
| `fig6_scatter_tierfuel.png` | Tire age vs fuel mass scatter colored by tier |

## What's Done

- [x] Full 7-chapter paper structure matching requirements
- [x] APA 7th formatting (1" margins, double spacing, 0.5" paragraph indent, page numbers top right)
- [x] All 6 statistical tables from the analysis
- [x] 6 data-generated figures in `figures/`
- [x] 20 references in `references.bib` (11 foreign, 5 local, 4 textbooks)
- [x] Ethics and Credibility sections in Methodology
- [x] Hypothesis testing and unexpected results in Findings

## What Needs Group Input

### References — verify and replace (HIGH PRIORITY)
The entries in `references.bib` are structurally correct but some author names, titles, and journals for the racing analytics papers are placeholders. **Each person should verify the papers they're citing actually exist, or replace them with real ones.**

Target: minimum 20 references, mix of foreign and local.

### Chapter II — RRL needs real sources
- Foreign studies section has placeholder citations — swap with actual papers you found
- Local studies section has 4 entries — verify or replace with real Philippine studies

### Title page
- Replace `[Instructor Name]` in `main.tex` with your professor's actual name

### Proofreading
- Read through all chapters for tone, consistency, and flow
- Check that Definition of Terms matches what the prof expects
- Verify Scope & Limitations covers everything

## Citation Cheat Sheet

```latex
% Author name in sentence:
\textcite{agresti2013} provides the theoretical foundation...

% Parenthetical citation:
(MLE; \parencite{hosmer2013})

% Add a new reference to references.bib:
@article{yourkey2024,
  author  = {Last, First},
  title   = {Title},
  journal = {Journal Name},
  year    = {2024},
  volume  = {1},
  pages   = {1--10},
}
```

## Formatting Specs

| Setting | Value |
|---------|-------|
| Font | Times New Roman 12pt |
| Spacing | Double |
| Margins | 1 inch all sides |
| Paragraph indent | 0.5 inch |
| Page numbers | Top right |
| Reference style | APA 7th, hanging indent 0.5" |

## Group

- Co, Jelliane B.
- Dampal, Justin G.
- Sulit, Lorenzo G.
