# Compile the paper (run from the paper/ directory)
# Requires: xelatex, biber

all: main.pdf

main.pdf: main.tex chapters/*.tex references.bib
	xelatex main.tex
	biber main
	xelatex main.tex
	xelatex main.tex

clean:
	rm -f main.aux main.bbl main.blg main.log main.out main.pdf main.run.xml main.toc

.PHONY: all clean
