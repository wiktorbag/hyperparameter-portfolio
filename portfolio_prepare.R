library("mlr")
portfolio_auc <- read.table("portfolios_auc.csv", header=TRUE, sep = ",")

write.portfolio <- function(param.indexes, portfolio, file.name){
  portfolio0 <- as.data.frame(portfolio)
  colnames(portfolio0) <- "hp_conf_index"
  selected_params <- param.indexes[param.indexes$param_index %in% portfolio, ]
  portfolio_aucc <- merge(portfolio0, selected_params, by.x = "hp_conf_index", by.y = "param_index")
  portfolio_aucc <- portfolio_aucc[match(portfolio, portfolio_aucc$hp_conf_index), ]
  write.csv(portfolio_aucc, file = file.name, row.names = FALSE)
}

#gbm
gbm.param.indexes <-  read.table("archive\\parameters\\gbm_params.csv", header=TRUE, sep = ",")
write.portfolio(gbm.param.indexes, portfolio_auc$gbm, "portfolio_auc_gbm.csv")

#kknn
kknn.param.indexes <-  read.table("archive\\parameters\\kknn_params.csv", header=TRUE, sep = ",")
write.portfolio(kknn.param.indexes, portfolio_auc$kknn, "portfolio_auc_kknn.csv")

#randomForest
rf.param.indexes <-  read.table("archive\\parameters\\gbm_params.csv", header=TRUE, sep = ",")
write.portfolio(rf.param.indexes, portfolio_auc$randomForest, "portfolio_auc_randomForest.csv")

#glmnet
glmnet.param.indexes <-  read.table("archive\\parameters\\glmnet_params.csv", header=TRUE, sep = ",")
write.portfolio(glmnet.param.indexes, portfolio_auc$glmnet, "portfolio_auc_glmnet.csv")
