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

## Current Features

1. **Portfolio Construction**  
   Implements the algorithm from *Sequential Model-Free Hyperparameter Tuning* to sequentially select hyperparameters that optimize ranks across datasets.

2. **Portfolio Loading**  
   Easily load the pre-constructed portfolios from the portfolios folder to perform further experiments or analyses.

## Future Work

- Conduct experiments to evaluate the performance of the constructed portfolios on unseen datasets.  
- Extend the portfolio construction to include additional models and datasets.  
- Explore alternative optimization strategies for hyperparameter selection.  
- Visualize the performance of hyperparameter portfolios using detailed plots and comparisons.
