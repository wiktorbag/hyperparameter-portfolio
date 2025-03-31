library(farff)
library("mlr3")
library("mlr")
library("randomForest")
library("mlr3extralearners")
library("mlr3learners")
library(fastDummies)
source("functions.R")

datasets <- list()
tasks <- list()


arff_data <- readARFF("irish.arff")
data <- na.omit(arff_data)
data <- one.hot.encode(data)
data[[3]] <- as.factor(data[[3]])
colnames(data) <- gsub("-", ".", colnames(data))
task <- TaskClassif$new(id = "irish", backend = data, target = colnames(data)[3])

datasets[["451"]] <- data
tasks[["451"]] <- task

arff_data <- readARFF("FOREX_nzdusd-day-High.arff")
data_41830 <- na.omit(arff_data[, -1])
data_41830 <- one.hot.encode(data_41830)
colnames(data_41830)[ncol(data_41830)] <- "Class"
data_41830[[ncol(data_41830)]] <- as.factor(data_41830[[ncol(data_41830)]])
task41830 <- TaskClassif$new(id = "41830", backend = data_41830, target = "Class")

datasets[["41830"]] <- data_41830
tasks[["41830"]] <- task41830

arff_data <- readARFF("FOREX_usdjpy-day-High.arff")
data_41797 <- na.omit(arff_data[, -1])
data_41797 <- one.hot.encode(data_41797)
colnames(data_41797)[ncol(data_41797)] <- "Class"
data_41797[[ncol(data_41797)]] <- as.factor(data_41797[[ncol(data_41797)]])
task41797 <- TaskClassif$new(id = "41797", backend = data_41797, target = "Class")

datasets[["41797"]] <- data_41797
tasks[["41797"]] <- task41797

arff_data <- readARFF("dataset.arff")[, -4]
colnames(arff_data)[3] = "targett"
colnames(arff_data)[4] = "ff"
arff_data$targett <- ifelse(arff_data$targett == "FERROVIAIRE", 1, 0)
arff_data$date <- as.integer(gsub("-", "", arff_data$date))
data_42882 <- na.omit(arff_data)
data_42882[[3]] <- as.factor(data_42882[[3]])
task_42882 <- TaskClassif$new(id = "42882", backend = data_42882, target = "targett")

datasets[["42882"]] <- data_42882
tasks[["42882"]] <- task_42882


arff_data <- readARFF("file27543e702e3f.arff")
data_40589 <- na.omit(arff_data[,58:78 ])
data_40589 <- one.hot.encode(data_40589)
colnames(data_40589)[ncol(data_40589)] <- "angry.aggresive"
data_40589[[ncol(data_40589)]] <- as.factor(data_40589[[ncol(data_40589)]])
task40589 <- TaskClassif$new(id = "40589", backend = data_40589, target = "angry.aggresive")

datasets[["40589"]] <- data_40589
tasks[["40589"]] <- task40589


arff_data <- readARFF("dataset_43_haberman.arff")
data_43 <- na.omit(arff_data)
colnames(data_43)
data_43[] <- lapply(data_43, function(x) if(is.factor(x)) as.numeric(as.character(x)) else x)
data_43[[ncol(data_43)]] <- as.factor(data_43[[ncol(data_43)]])
task43 <- TaskClassif$new(id = "43", backend = data_43, target = "Survival_status")

datasets[["43"]] <- data_43
tasks[["43"]] <- task43


arff_data <- readARFF("dataset_53_heart-statlog.arff")
data_53 <- na.omit(arff_data)
data_53 <- one.hot.encode(data_53)
colnames(data_53)[ncol(data_53)] <- "class"
data_53[[ncol(data_53)]] <- as.factor(data_53[[ncol(data_53)]])
task53 <- as_task_classif(data_53, target = "class")

datasets[["53"]] <- data_53
tasks[["53"]] <- task53


arff_data <- readARFF("dataset_56_vote.arff")
data_56 <- na.omit(arff_data)
colnames(data_56) <- gsub("-", ".", colnames(data_56))
data_56 <- one.hot.encode(data_56)
colnames(data_56)[ncol(data_56)] <- "Class"
data_56[[ncol(data_56)]] <- as.factor(data_56[[ncol(data_56)]])
task56 <- TaskClassif$new(id = "56", backend = data_56, target = "Class")

datasets[["56"]] <- data_56
tasks[["56"]] <- task56


arff_data <- readARFF("dataset_13_breast-cancer.arff")
data_13 <- na.omit(arff_data)
colnames(data_13)
data_13 <- one.hot.encode(data_13)
colnames(data_13)[ncol(data_13)] <- "Class"
data_13[[ncol(data_13)]] <- as.factor(data_13[[ncol(data_13)]])
colnames(data_13) <- gsub("-", ".", colnames(data_13))
task13 <- TaskClassif$new(id = "13", backend = data_13, target = "Class")

datasets[["13"]] <- data_13
tasks[["13"]] <- task13


arff_data <- readARFF("dataset_55_hepatitis.arff")
data_55 <- na.omit(arff_data)
colnames(data_55)
data_55 <- one.hot.encode(data_55)
colnames(data_55)[ncol(data_55)] <- "Class"
data_55[[ncol(data_55)]] <- as.factor(data_55[[ncol(data_55)]])
task55 <- TaskClassif$new(id = "55", backend = data_55, target = "Class")

datasets[["55"]] <- data_55
tasks[["55"]] <- task55


ids <- c("13", "53", "56", "55", "41830", "451", "41797", "42882", "40589", "43")
models <- c("classif.randomForest", "classif.gbm", "classif.kknn", "classif.glmnet")
types <- c("random", "grid")

  
for (model in models) {
    for (type in types) {
      name.file <- paste0(gsub("^classif\\.", "", model), "_", type, ".csv")
      write.results(tasks, datasets, ids, model, type, name.file, n = 20)
    }
}
write.asmfo.results(tasks, datasets, ids, "classif.randomForest", "portfolio_auc_randomForest.csv", "randomForestASMFOresults.csv")
write.asmfo.results(tasks, datasets, ids, "classif.kknn", "portfolio_auc_kknn.csv", "kknnASMFOresults.csv")
write.asmfo.results(tasks, datasets, ids, "classif.gbm", "portfolio_auc_gbm.csv", "gbmASMFOresults.csv")
write.asmfo.results(tasks, datasets, ids, "classif.glmnet", "portfolio_auc_glmnet.csv", "glmnetASMFOresults.csv")
