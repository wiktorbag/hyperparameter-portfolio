setwd("\\github\\results\\")
library(ggplot2)
library(reshape2) 

replace.nas <- function(df) {
  df[is.na(df)] <- 0.5
  df
}

get_column <- function(data, maxs, n=10){
  nor_err <- data.frame(matrix(ncol = n, nrow = nrow(data)))
  for(i in 1:n) {
    nor_err[, i] <- (data[, i] - maxs[i])
  }
  for(i in colnames(nor_err)){
    nor_err[[i]] <- cummax(nor_err[[i]])
  }
  column <- numeric(20)
  for(i in 1:20) {
    column[i] <- sum(nor_err[i, ])/10
  }
  column
  }

get_maxs <- function(df1, df2, df3){
  n <- ncol(df1)
  maxs <- numeric(n)
  for (i in 1:10) {
    maxs[i] <- max(df1[, i], df2[, i], df3[, i])
  }
  maxs
}

zrob_wykres <- function(random, gird, asmfo, titleStr){
  asmfo_data <- read.csv(random)
  grid_data <- read.csv(gird)
  rand_data <- read.csv(asmfo)
  
  asmfo_data <- replace.nas(asmfo_data)
  grid_data <- replace.nas(grid_data)
  rand_data <- replace.nas(rand_data)
  maxes <- get_maxs(asmfo_data, grid_data, rand_data)
  
  df <- data.frame(
    row = 1:nrow(asmfo_data),
    random = abs(get_column(rand_data, maxes)),
    grid = abs(get_column(grid_data, maxes)),
    asmfo = abs(get_column(asmfo_data, maxes))
  )
  df_long <- melt(df, id.vars = "row", variable.name = "Method", value.name = "Value")
  max_value <- ceiling(max(df_long$Value) * 100) / 100  
  
  hline_seq <- seq(0, max_value, by = 0.01)
  vline_seq <- seq(0, 20, by = 5)
  
  ggplot(df_long, aes(x = row, y = Value, color = Method, group = Method)) +
    geom_hline(yintercept = hline_seq, color = "gray85", linetype = "dashed", linewidth = 0.3) +
    geom_vline(xintercept = vline_seq, color = "gray85", linetype = "dashed", linewidth = 0.3) +
    geom_line(linewidth = 1.2) +  
    geom_point(size = 2) +  
    labs(
      title = titleStr,
      x = "Number of Trials",
      y = "Average performance loss"
    ) +
    theme_classic(base_size = 20) +  
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 22),  
      axis.title = element_text(face = "bold"), 
      axis.title.y = element_text(margin = margin(r = 13)), 
      legend.position = "top",  
      legend.title = element_blank()  
    ) +
    scale_color_manual(values = c("#2A9D8F", "#457B9D", "#E63946")) 
}


zrob_wykres("gbm_random.csv", "gbm_grid.csv", "gbmASMFOresults.csv", "gbm")
zrob_wykres("randomForest_random.csv", "randomForest_grid.csv", "randomForestASMFOresults.csv", "Random Forest")
zrob_wykres("kknn_random.csv", "kknn_grid.csv", "kknnASMFOresults.csv", "kknn")
zrob_wykres("glmnet_random.csv", "glmnet_grid.csv", "glmnetASMFOresults.csv", "glmnet")
