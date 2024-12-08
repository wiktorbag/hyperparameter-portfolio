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

############################################
##  RANDOM SEARCH OPTIMIZATION RESULTS    ##
############################################

random_search_rf <- function(task, data, model, param_range, folds = 5){
  learner <- lrn(model, predict_type = "prob")
  resampling <- rsmp("cv", folds = folds)
  param_range <- list(
    ntree = c(100, 10086),
    nodesize = c(1, 5),
    replace = c(TRUE, FALSE)
  )
  
  learner$param_set$values <- params
  
}
