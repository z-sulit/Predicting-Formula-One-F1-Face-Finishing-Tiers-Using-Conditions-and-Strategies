# Paper — F1 Finishing Tier Prediction

## Overleaf Setup

1. Go to [overleaf.com](https://www.overleaf.com) → New Project → Upload Project
2. Upload **everything** inside this `paper/` folder (keep folder structure)
3. Menu → Compiler → **XeLaTeX**
4. Click Recompile

## What Each File Does

- **`main.tex`** — Master document. Controls formatting, page numbers, TOC. Pulls in all chapters.
- **`references.bib`** — All 20 citations. Add/edit references here. Cite in-text with `\textcite{key}` or `\parencite{key}`.
- **`figures/`** — 6 PNG figures generated from the data. Already linked in Chapter IV.

### Chapters

| File | Chapter | What Goes Here |
|------|---------|----------------|
| `chapter1.tex` | I — Introduction | Background, Problem, Purpose, Goals, Scope, Significance |
| `chapter2.tex` | II — Literature Review | Theory, Foreign + Local studies, Conceptual Framework, Research Gap, Definitions |
| `chapter3.tex` | III — Methodology | Approach, Design, Sampling, Tools, Data Collection, Ethics, Credibility |
| `chapter4.tex` | IV — Findings | Statistical tables, figures, hypothesis testing |
| `chapter5.tex` | V — Discussion | Interpretation, Literature connection, Limitations, Practical impacts |
| `chapter6.tex` | VI — Conclusion | Summary, Future research, Recommendations |
| `appendix.tex` | Appendices | Raw R/Python output, dataset tables |

## Formatting (APA 7th)

- Font: Times New Roman 12pt
- Spacing: Double
- Margins: 1 inch all sides
- Paragraph indent: 0.5 inch
- Page numbers: top right
- References: APA 7th, hanging indent, alphabetically sorted

## What Needs Work

### [ ] Replace `[Instructor Name]` in `main.tex`
Open `main.tex`, find `[Instructor Name]` on the title page, replace with your professor's name.

### [ ] Verify references
The `references.bib` file has 20 entries. Some are real textbooks (Agresti, Hosmer, Tabachnick, Hair, Field). The F1 analytics papers and Philippine studies are structurally correct but may need to be swapped with actual sources you and your groupmates found. Check each one.

### [ ] Add real figures if needed
The 6 figures in `figures/` are auto-generated from the data. If your prof wants additional diagrams (conceptual framework diagram, process flow, etc.), drop PNGs into `figures/` and add `\begin{figure}...\end{figure}` blocks in the appropriate chapter.

### [ ] Proofread
Read through all chapters for flow and consistency. Check that the Definition of Terms matches what your prof expects.

## Group

- Co, Jelliane B.
- Dampal, Justin G.
- Sulit, Lorenzo G.
