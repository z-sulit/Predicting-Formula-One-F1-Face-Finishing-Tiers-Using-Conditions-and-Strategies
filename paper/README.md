# Paper — F1 Finishing Tier Prediction

Overleaf project for the Multivariate Statistics paper.

## Overleaf Setup

1. **Compiler:** Menu → Compiler → **XeLaTeX** (required for Times New Roman)
2. **Upload everything** from this `paper/` folder into Overleaf, keeping the folder structure intact
3. `main.tex` is the master document — it pulls in all chapters automatically

## File Structure

| File | What It Is |
|------|-----------|
| `main.tex` | Master document — formatting, margins, fonts, TOC. Don't touch unless changing layout |
| `references.bib` | All citations. Add new references here, cite with `\textcite{key}` or `\parencite{key}` |
| `chapters/chapter1.tex` | Introduction — Background, Conceptual Framework, Problem, Hypotheses, Scope, Significance |
| `chapters/chapter2.tex` | Review of Related Literature — Foreign studies, Local studies, Synthesis, Definition of Terms |
| `chapters/chapter3.tex` | Methodology — Research Design, Data Source, Instrumentation, Statistical Treatment |
| `chapters/chapter4.tex` | Results and Discussion — All statistical tables and interpretation |
| `chapters/chapter5.tex` | Summary, Conclusions, Recommendations |
| `chapters/appendix.tex` | Raw R/Python outputs, dataset summary tables |
| `figures/` | Drop PNGs here, reference with `\includegraphics{figures/filename.png}` |

## What's Done

- [x] Full paper scaffold (all 5 chapters + appendices)
- [x] APA 7th formatting (margins, spacing, page numbers, title page)
- [x] All 6 statistical tables from the analysis (Box's M, VIF, coefficients, standard errors, p-values, LOGO-CV)
- [x] 20 references in `references.bib` (11 foreign, 5 local, 4 textbooks)

## What Needs Group Input

### References — verify and replace (HIGH PRIORITY)
The entries in `references.bib` are structurally correct but some author names, titles, and journals for the racing analytics papers are placeholders that match our methodology. **Each person should verify the papers they're citing actually exist, or replace them with real ones from your own research.**

Target: minimum 20 references, mix of foreign and local.

### Chapter II — RRL needs real sources
- Foreign studies section has placeholder citations — swap with actual papers you found
- Local studies section has 4 entries — verify or replace with real Philippine studies
- If you add/remove references, update `references.bib` accordingly

### Figures
- If the prof wants visual figures (confusion matrix heatmap, coefficient plots, etc.), drop them in `figures/` and add `\begin{figure}` blocks in chapter4.tex

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

## Formatting Specs (per requirements)

| Setting | Value |
|---------|-------|
| Font | Times New Roman 12pt |
| Spacing | Double |
| Left margin | 1.25 inches |
| Other margins | 1 inch |
| Page numbers | Top right |
| Tables | Table 1, Table 2, ... (auto-numbered) |
| Figures | Figure 1, Figure 2, ... (auto-numbered) |

## Group

- Co, Jelliane B.
- Dampal, Justin G.
- Sulit, Lorenzo G.
