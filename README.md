This repository contains an R project with the following subfolders and files around the paper titled "Sample Paper":

## Raw data
- The folder "corpus", which contains the BROWN TEI files (in TEI-compliant xml).
This folder is **not** tracked by git.

## Processed data
- brown_files.tsv: a tab-separated file with 15 rows and 4 columns summarizing information
about the registers in the Brown corpus.
- register-analysis.tsv: a tab-separated file with one row per Brown file and one column per factor for the factor analysis.

## Scripts
- data-collection.R: the R script that reads the BROWN TEI files and generates the matrix
for factor analysis. The dataframe (before converting to a matrix) is stored as "register-analysis.tsv".

## Quarto
- sample-paper.qmd: the source Quarto file of the paper.
- sample-paper.html, sample-paper.docx, sample-paper.pdf: the output in different formats.

## Helpers
- bibliography.bib:, the bibtex file for literature references
- packages.bib: the bibtex file for packages, written by `write_bib()` in sample-paper.qmd (after creating a blank file.)
- unified-style-sheet-for-linguistics.csl: the stylesheet for references
- template.docx: a reference document for the word styles.
