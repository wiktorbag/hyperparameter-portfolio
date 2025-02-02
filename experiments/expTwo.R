# This all is still in development stage. Some codes are pointless and stored for memory of losses, so that bad decisions do not repeat.

library(farff)
library("mlr3")
library("mlr")
library("randomForest")
library("mlr3extralearners")
# Reading ARFF file
arff_data <- readARFF("irish.arff")
data <- na.omit(arff_data)

############################################
####     ASMFO OPTIMIZATION RESULTS     ####
############################################

lrn <- lrn("classif.randomForest")
portfolio_auc_randomForest <- read.table("portfolio_auc_randomForest.csv", header=TRUE, sep = ",")
data[[ncol(data)]] <- as.factor(data[[ncol(data)]])


split.test.train <- function(data){
  set.seed(1)  
  n <- nrow(data)
  sample(seq_len(n), size = 0.8 * n)
  
  # train_indices <- split.test.train(data)
  # train_data <- data[train_indices, ]
  # test_data <- data[-train_indices, ]
  
}

get.ith.auc <- function(i, portfolio_auc, model, data, task){
  
  learner <- lrn(model)
  row_as_list <- as.list(portfolio_auc[i, -1])
  learner$param_set$values = row_as_list
  learner$predict_type <- "prob"
  
  cv5 <- rsmp("cv", folds = 5)
  rr <- mlr3::resample(task= task, learner=learner,resampling = cv5)
  rr$aggregate(msr("classif.auc"))
}

# portfolio_auc <- portfolio_auc_randomForest
# task <- TaskClassif$new(id = "irish", backend = data, target = colnames(data)[1])
# get.ith.auc(1, portfolio_auc, model, data, task)
# 
# train_indices <- split.test.train(data)
# train_data <- data[train_indices, ]
# test_data <- data[-train_indices, ]


n <- 20
irish_aucs <- numeric(n)
portfolio_auc <- portfolio_auc_randomForest
model <- "classif.randomForest"
task <- TaskClassif$new(id = "irish", backend = data, target = colnames(data)[1])
for(i in 1:n){
  irish_aucs_rf[i] <- get.ith.auc(i, portfolio_auc, model, data, task)
}




portfolio_auc_glmnet <- read.table("portfolio_auc_glmnet.csv", header=TRUE, sep = ",")
n <- 20
irish_aucs_glmnet <- numeric(n)
i <- 1
for(i in 1:n){
  #irish_aucs_glmnet[i] <- get.ith.auc(i, portfolio_auc_glmnet, "classif.glmnet", data, task)
  learner <- lrn("classif.glmnet")
  row_as_list <- as.list(portfolio_auc_glmnet[i, -1])
  learner$param_set$values = row_as_list
  learner$predict_type <- "prob"
  
  cv5 <- rsmp("cv", folds = 5)
  rr <- mlr3::resample(task= task, learner=learner,resampling = cv5)
  rr$aggregate(msr("classif.auc")) # Problem z glmnet - wartości nie są wszystkie numeryczne
}



install.packages("gbm")
library("gbm")
portfolio_auc_gbm <- read.table("portfolio_auc_gbm.csv", header=TRUE, sep = ",")
n <- 20
irish_aucs_gbm <- numeric(n)
for(i in 1:n){
  irish_aucs_gbm[i] <- get.ith.auc(i, portfolio_auc_gbm, "classif.gbm", data, task)
}

install.packages("kknn")
library("kknn")
portfolio_auc_kknn <- read.table("portfolio_auc_kknn.csv", header=TRUE, sep = ",")
n <- 20
irish_aucs_kknn <- numeric(n)
for(i in 1:n){
  irish_aucs_kknn[i] <- get.ith.auc(i, portfolio_auc_kknn, "classif.kknn", data, task)
}

asfmo_search <- function(task, data, model, portfolio_name, n=20) {
  portfolio_auc <- read.table(portfolio_name, header=TRUE, sep = ",")
  aucs <- numeric(n)
  for(i in 1:n){
    aucs[i] <- get.ith.auc(i, portfolio_auc, model, data, task)
  }
  aucs
}

irish_aucs_gbm_1 <- asfmo_search(task, data, "classif.gbm", "portfolio_auc_gbm.csv")
# coś nie działa calssif.kknn

############################################
##  RANDOM SEARCH OPTIMIZATION RESULTS    ##
############################################

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
  cbind(random_params, aucs_rand)
}
irish_aucs_rf_rand <- random_search(task, data, "classif.randomForest")
irish_aucs_gbm_rand <- random_search(task, data, "classif.gbm")
irish_aucs_kknn_rand <- random_search(task, data, "classif.kknn")

############################################
###  GRID SEARCH OPTIMIZATION RESULTS    ###
############################################

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
  grid_subset <- grid[1:20, ]
  return(grid_subset)
}

grid_search <- function(task, data, model, n = 20) {
  grid <- generate_grid(model)
  aucs_grid <- numeric(n)
  for(i in 1:n){
    aucs_grid[i] <- get.ith.auc(i, grid, model, data, task)
  }
  cbind(grid, aucs_grid)
}

irish_aucs_rf_grid <- grid_search(task, data, "classif.randomForest")
irish_aucs_gbm_grid <- grid_search(task, data, "classif.gbm")
irish_aucs_kknn_grid <- grid_search(task, data, "classif.kknn")

