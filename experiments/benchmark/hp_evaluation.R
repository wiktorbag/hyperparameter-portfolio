source("functions.R") 
ids <- c("13", "53", "56", "55", "41830", "451", "41797", "42882", "40589", "43")

write.asmfo.results(tasks, datasets, ids, "classif.randomForest", "portfolio_auc_randomForest.csv", "randomForestASMFOresults.csv")
write.asmfo.results(tasks, datasets, ids, "classif.kknn", "portfolio_auc_kknn.csv", "kknnASMFOresults.csv")
write.asmfo.results(tasks, datasets, ids, "classif.gbm", "portfolio_auc_gbm.csv", "gbmASMFOresults.csv")
write.asmfo.results(tasks, datasets, ids, "classif.glmnet", "portfolio_auc_glmnet.csv", "glmnetASMFOresults.csv")
