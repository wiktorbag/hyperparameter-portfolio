# Hyperparameter Portfolio Construction

This repository contains the implementation of my bachelor’s thesis, which focuses on constructing **hyperparameter portfolios** based on the methodology described in the paper *[Sequential Model-Free Hyperparameter Tuning](https://doi.org/10.1109/ICDM.2015.20)*.

## Project Overview

The goal of this project is to optimize hyperparameter selection by constructing portfolios of hyperparameters across multiple datasets and models based on *[MementoML: Performance of selected machine learning algorithm configurations on OpenML100 datasets](
https://doi.org/10.48550/arXiv.2008.13162)* . These portfolios represent a collection of hyperparameter configurations that achieve high performance when evaluated across various datasets.

## Files and Structure

- **`portfolios.csv`**  
  This file contains pre-constructed hyperparameter portfolios for models such as `gbm`, `glmnet`, `kknn`, and `randomForest`. Each column corresponds to a specific model, and the values represent the chosen hyperparameter configurations.

- **`functions.py`**  
  Contains all the necessary functions to:  
  - Rank hyperparameters across datasets.  
  - Construct hyperparameter portfolios using the *A-SMFO* algorithm.  

- **`main.py`**  
  This script demonstrates the usage of the functions defined in `functions.py` to process data, construct portfolios, and load the pre-constructed portfolios from `portfolios.csv`.

  ### `experiments/`

This folder houses the various experimental procedures and their outcomes, divided into two main subdirectories:

* **`analysis/`**: This directory contains the scripts and data related to the in-depth analysis of benchmark results. You'll find R scripts and Jupyter Notebooks used for processing and interpreting the experimental data.
    * **`analysis/plots/`**: Within the `analysis` folder, this subdirectory is dedicated to storing the visualizations and plots generated from the data analysis, providing insights into the experimental findings.

* **`benchmark/`**: This directory is dedicated to the evaluation of different hyperparameter optimization strategies. Here, you'll find the code and results for assessing the performance of hyperparameter portfolios, as well as comparisons against traditional methods like grid search and random search.


## Current Features

1. **Portfolio Construction**  
   Implements the algorithm from *Sequential Model-Free Hyperparameter Tuning* to sequentially select hyperparameters that optimize ranks across datasets.

2. **Portfolio Loading**  
   Easily load the pre-constructed portfolios from the portfolios folder to perform further experiments or analyses.

## Future Work
- Extend the portfolio construction to include additional models and datasets.  
- Explore alternative optimization strategies for hyperparameter selection.  
