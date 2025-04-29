setwd("\\github\\results\\")
library(ggplot2)
library(reshape2) 
library(dplyr)
library(tidyr)
library(gridExtra)

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



make_data_ranks <- function(asmfo, rand, grid){
  n <- length(rand[["X53"]])
  
  asmfo <- asmfo[, colnames(grid)]
  asmfo <- replace.nas(asmfo)
  grid <- replace.nas(grid)
  rand <- replace.nas(rand)
  
  rand_ranks <- data.frame(matrix(ncol = 0, nrow = n))  
  grid_ranks <- data.frame(matrix(ncol = 0, nrow = n))
  as_ranks <- data.frame(matrix(ncol = 0, nrow = n))
  
  for(id in colnames(rand_glmnet)){
    all_values <- c(rand[[id]], grid[[id]], asmfo[[id]])
    ranked_values <- rank(-all_values, ties.method = "min") 
    n <- length(rand_glmnet[[id]])
    rand_ranks[[id]] <- ranked_values[1:n]
    grid_ranks[[id]] <- ranked_values[(n + 1):(2 * n)]
    as_ranks[[id]] <- ranked_values[(2 * n + 1):(3 * n)]
  }
  
  mean_ranks_rand <- mean_ranks_grid <- mean_ranks_as <- numeric(n)
  for(i in 1:n){
    mean_ranks_rand[i] <- sum(rand_ranks[i, ])/10
    mean_ranks_grid[i] <- sum(grid_ranks[i, ])/10
    mean_ranks_as[i] <- sum(as_ranks[i, ])/10
  }
  
  df <- data.frame(
    Row = 1:length(mean_ranks_rand),
    mean_ranks_rand,
    mean_ranks_grid,
    mean_ranks_as
  )
  
  # Compute cumulative mean for each vector
  df <- df %>%
    mutate(
      random = cumsum(mean_ranks_rand) / Row,
      grid = cumsum(mean_ranks_grid) / Row,
      asmfo = cumsum(mean_ranks_as) / Row
    )
  return(df)
}

create_cumulative_plot <- function(df, titleStr) {
  # Convert cumulative mean data to long format for ggplot
  df_cum_long <- df %>%
    pivot_longer(cols = c(random, grid, asmfo),
                 names_to = "CumulativeMethod", values_to = "CumulativeMean")
  
  # Get max value for horizontal lines
  max_value <- ceiling(max(df_cum_long$CumulativeMean) * 100) / 100  
  
  # Define sequences for grid lines
  hline_seq <- seq(20, max_value, by = 5)
  vline_seq <- seq(1, 20, by = 5)
  
  # Cumulative Mean Trends Plot
  p <- ggplot(df_cum_long, aes(x = Row, y = CumulativeMean, color = CumulativeMethod, group = CumulativeMethod)) +
    # Grid lines
    geom_hline(yintercept = hline_seq, color = "gray85", linetype = "dashed", linewidth = 0.3) +
    geom_vline(xintercept = vline_seq, color = "gray85", linetype = "dashed", linewidth = 0.3) +
    
    # Main plot
    geom_line(linewidth = 1.2) +  
    geom_point(size = 2) +  
    
    # Labels
    labs(
      title = titleStr,
      x = "Number of Trials",
      y = "Cumulative mean rank"
    ) +
    
    # Theme
    theme_classic(base_size = 20) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 22),
      axis.title = element_text(face = "bold"),
      axis.title.y = element_text(margin = margin(r = 13)),
      legend.position = "top",
      legend.title = element_blank()
    ) +
    
    # Custom Colors
    scale_color_manual(values = c("#E63946", "#457B9D", "#2A9D8F"))  
  
  return(p)
}


asmfo_glmnet <- read.csv("glmnetASMFOresults.csv")
grid_glmnet <- read.csv("glmnet_grid.csv")
rand_glmnet <- read.csv("glmnet_random.csv")
asmfo_rf <- read.csv("randomForestASMFOresults.csv")
grid_rf <- read.csv("randomForest_grid.csv")
rand_rf <- read.csv("randomForest_random.csv")
asmfo_kknn <- read.csv("kknnASMFOresults.csv")
grid_kknn <- read.csv("kknn_grid.csv")
rand_kknn <- read.csv("kknn_random.csv")
asmfo_gbm <- read.csv("gbmASMFOresults.csv")
grid_gbm <- read.csv("gbm_grid.csv")
rand_gbm <- read.csv("gbm_random.csv")

glmnet_df <- make_data_ranks(asmfo_glmnet, rand_glmnet, grid_glmnet)
gbm_df <- make_data_ranks(asmfo_gbm, rand_gbm, grid_gbm)
randomForest_df <- make_data_ranks(asmfo_rf, rand_rf, grid_rf)
kknn_df <- make_data_ranks(asmfo_kknn, rand_kknn, grid_kknn)

# Generate plots
p_glmnet <- create_cumulative_plot(glmnet_df, "glmnet")
p_gbm <- create_cumulative_plot(gbm_df, "gbm")
p_rf <- create_cumulative_plot(randomForest_df, "randomForest")
p_kknn <- create_cumulative_plot(kknn_df, "kknn")

# Arrange plots in a 2x2 grid
grid.arrange(p_glmnet, p_gbm, p_rf, p_kknn, ncol = 2)
