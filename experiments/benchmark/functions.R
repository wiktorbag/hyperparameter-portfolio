library(farff)
library("mlr3")
library("mlr")
library("randomForest")
library("mlr3extralearners")
library("mlr3learners")
library(fastDummies)
## functions for evaluation of hyperparmeter portfolios constructed using ASMFO

get.ith.auc <- function(i, portfolio_auc, model, data, task) {
  result <- tryCatch({
    # Define learner and other processing steps
    learner <- lrn(model)
    row_as_list <- as.list(portfolio_auc[i, -1, drop = FALSE])
    learner$param_set$values <- row_as_list
    learner$predict_type <- "prob"
    
    # Set up cross-validation
    cv5 <- rsmp("cv", folds = 5)
    
    # Perform resampling and calculate AUC
    rr <- mlr3::resample(task = task, learner = learner, resampling = cv5)
    
    # Return the AUC score
    rr$aggregate(msr("classif.auc"))
  }, error = function(e) {
    
    print(paste("Error:", e$message))
    return(NaN)
  })
  
  return(result)
}

asfmo_search <- function(task, data, model, portfolio_name, n=20) {
  portfolio_auc <- read.table(portfolio_name, header=TRUE, sep = ",")
  aucs <- numeric(n)
  for(i in 1:n){
    aucs[i] <- get.ith.auc(i, portfolio_auc, model, data, task)
  }
  aucs
}

write.asmfo.results <- function(tasks, datasets, ids, model, portfolio_name, name.file, n=20) {
  setwd("github\\hyperparameter-portfolio\\portfolios")
  df <- data.frame(matrix(ncol = 0, nrow = n))  
  for (id in ids) {
    df[[id]] <- asfmo_search(tasks[[id]], datasets[[id]], model, portfolio_name, n)
  }
  setwd("github\\hyperparameter-portfolio\\results")
  write.csv(df, name.file , row.names = FALSE)
}

## functions for evaluation of random search 

generate_random_params <- function(n_rows = 20, model) {
  # Initialize an empty data frame to store unique rows
  sampled_params_df <- data.frame()
  
  while (nrow(sampled_params_df) < n_rows) {
    # Generate a single row of parameters
    if(model == "classif.randomForest") {
      new_row <- data.frame(
        hp_conf_index = 1,
        ntree = round(2^runif(1, log2(100), log2(10086))),
        nodesize = round(runif(1, 1, 5)),
        replace = sample(c(TRUE, FALSE), size = 1)
      )
    }
    if(model == "classif.gbm") {
      new_row <- data.frame(
        hp_conf_index = 1,
        n.trees = round(2^runif(1, log2(100), log2(10086))),
        interaction.depth = round(runif(1, 1, 5)),
        n.minobsinnode = round(runif(1, 2, 25)),
        shrinkage = 10^runif(1, log10(0.001), log10(0.1)),
        bag.fraction = runif(1, 0.2, 1)
      )
    }
    if(model == "classif.kknn") {
      new_row <- data.frame(
        hp_conf_index = 1,
        k = round(runif(1, 1, 30)) 
      )
    }
    if(model == "classif.glmnet") {
      new_row <- data.frame(
        hp_conf_index = 1,
        alpha = runif(1, 0, 1), 
        lambda = 10^runif(1, log10(1e-4), log10(1e1))  # Lambda from 0.0001 to 10
      )
    }
    # Check for uniqueness and add if not a duplicate
    if (!any(duplicated(rbind(sampled_params_df, new_row)))) {
      sampled_params_df <- rbind(sampled_params_df, new_row)
    }
  }
  
  return(sampled_params_df)
}


random_search <- function(task, data, model, n = 20) {
  random_params <- generate_random_params(n_rows = n, model)
  aucs_rand <- numeric(n)
  for(i in 1:n){
    aucs_rand[i] <- get.ith.auc(i, random_params, model, data, task)
  }
  cbind(random_params, aucs_rand)[, -1]
}

## functions for evaluation of grid search 
generate_grid <- function(model) {
  if (model == "classif.randomForest") {
    # Generate the grid
    grid <- expand.grid(
      hp_conf_index = 1,
      ntree = c(120, 800, 4000),
      nodesize = seq(1, 4, by = 1),
      replace = c(TRUE, FALSE)
    )
  }
  
  if (model == "classif.gbm") {
    grid <- expand.grid(
      hp_conf_index = 1,
      n.trees = c(120, 800, 4000),
      interaction.depth = c(2, 4),
      n.minobsinnode = c(5, 15),
      shrinkage = c(0.001, 0.1)
    )
  }
  
  if (model == "classif.kknn") {
    grid <- expand.grid(
      hp_conf_index = 1,
      k = seq(1, 20, by = 1)
    )
  }
  if(model == "classif.glmnet") {
    grid <- expand.grid(
      hp_conf_index = 1,
      alpha = c(0, 0.2, 0.5, 1), 
      lambda = c(0.001, 0.01, 0.1, 1, 10)
    )
  }
  grid_subset <- grid[1:20, ]
  return(grid_subset)
}

grid_search <- function(task, data, model, n = 20) {
  grid <- generate_grid(model)
  aucs_grid <- numeric(n)
  for(i in 1:n){
    aucs_grid[i] <- get.ith.auc(i, grid, model, data, task)
  }
  cbind(grid, aucs_grid)[, -1]
}

write.results <- function(tasks, datasets, ids, model, type, name.file, n=20) {
  df <- data.frame(matrix(ncol = 0, nrow = n))  
  for (id in ids) {
    if(type == "random") {
      dataset <- random_search(tasks[[id]], datasets[[id]], model, n)
      df[[id]] <- dataset[, ncol(dataset)]
    } else {
      dataset <- grid_search(tasks[[id]], datasets[[id]], model, n)
      df[[id]] <- dataset[, ncol(dataset)]
    }
  }
  setwd("github\\results")
  write.csv(df, name.file , row.names = FALSE)
}

## for datasets preparations
one.hot.encode <- function(df) {
  non_numeric_cols <- names(df)[sapply(df, function(col) !is.numeric(col))]
  df_fastdummies <- dummy_cols(df, select_columns = non_numeric_cols, remove_selected_columns = TRUE, remove_first_dummy = TRUE)
  df_fastdummies
}
