Figure reproduction for symbolic Bayesian transport
This repository contains precomputed plot data and MATLAB code for redrawing selected figures associated with A graph-based symbolic Bayesian framework to predict chaotic transport under uncertainty by David Canales and Seur Gi Jo in Chaos.
The data contain the two-dimensional trajectory curves, symbolic-class probabilities, and position and velocity error curves used in the selected plots. The MATLAB script reads these values and renders the figures. For inquiries about the code used to generate the underlying data, please contact the corresponding author, David Canales (canaled4@erau.edu).
Reproduce the figures
Open this folder in MATLAB and run:
```matlab
reproduce\_figures()
```
To redraw only the two symbolic-class probability plots, run:
```matlab
reproduce\_figures(\[27, 28])
```
The script reads `data/case1\_plot\_data.mat` and `data/case2\_plot\_data.mat` and writes PNG files to `reproduced\_figures/`. Use the MATLAB release that produced the original figures for the closest match in fonts and layout.
Figure index
The output filenames use the numbers assigned by the original plotting script. The paper groups some of these plots into multipanel figures.
Output numbers	Content	Paper figure
01	Case 1 prior trajectory ensemble	Fig. 1
02–09	Case 1 trajectory classes	Figs. 15 and 16 panels
10	Case 2 prior trajectory ensemble	Additional companion plot
11–18	Case 2 trajectory classes	Figs. 17 and 18 panels
27–28	Case 1 and Case 2 symbolic-class probabilities	Fig. 19 panels
29–30	Case 1 and Case 2 position and velocity error comparisons	Figs. 20 and 21
