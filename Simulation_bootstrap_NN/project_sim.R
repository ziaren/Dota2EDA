#%%%%%%%%%%%%%%%%---- Doing Bias Variance trade off ----- %%%%%%%%%%%%%%%%%%#
library(dplyr)
library(tidyr)
library(tidyverse)
library(ggplot2)
library(plotly)
library(leaps)
library(fGarch)
library(GGally)


df <- read.csv("C:/Users/Jerry Bodman/Desktop/Homework files/630finaldata.csv")
str(df)

new_df <- df %>%
  mutate(radiant_win_bool = (ifelse(radiant_win=="TRUE",1,0)))


df_fin <- new_df[, !names(new_df) %in% c("match_id", "radiant_win","leagueid", "radiant_team_id", "dire_team_id")]


##simualting from the multivariate normal distribution (sampling)
sim_mat <- mvtnorm::rmvnorm(nrow(df_fin), sigma = cor(df_fin))
hist(sim_mat[ , 1])
hist(sim_mat[,2])

# transform the generated data to uniform
sim_unif <- pnorm(sim_mat)

# Now each margin is uniform:
hist(sim_unif[ , 1])
hist(sim_unif[ , 2])

# Not identical, but still similar!
cor(sim_mat)
cor(sim_unif)

# Lastly, apply a quantile function to each margin:
sim <- df_fin

# 1.region

sim$region <- quantile(df_fin$region, probs = sim_unif[, 1], type = 8)


# And compare the marginal histograms of the original and simulated data sets:
hist(df_fin$region, col = rgb(1, 0, 0, 0.5), , )
hist(sim$region, col = rgb(0, 0, 1, 0.5), add = TRUE)


#2. duration

sparam <- MASS::fitdistr(df_fin$duration, "Negative Binomial")
sim$duration <- qnbinom(sim_unif[, 2], size = sparam$estimate["size"], mu = sparam$estimate["mu"])

sparam <- MASS::fitdistr(df_fin$duration, "lognormal")
sim$duration <- round(qlnorm(sim_unif[,2], meanlog = sparam$estimate["meanlog"], sdlog = sparam$estimate["sdlog"]))

sim$duration <- quantile(df_fin$duration, probs = sim_unif[, 2], type = 8)


# And compare the marginal histograms of the original and simulated data sets:
hist(df_fin$duration, col = rgb(1, 0, 0, 0.5), , )
hist(sim$duration, col = rgb(0, 0, 1, 0.5), add = TRUE)




#3. first_blood_time

snorm_fit <- snormFit(df_fin$first_blood_time)
sim$first_blood_time <-
  qsnorm(
    sim_unif[ , 3], 
    mean = snorm_fit$par["mean"], 
    sd = snorm_fit$par["sd"], 
    xi = snorm_fit$par["xi"]
  )


# And compare the marginal histograms of the original and simulated data sets:
hist(df_fin$first_blood_time, col = rgb(1, 0, 0, 0.5))
hist(sim$first_blood_time, col = rgb(0, 0, 1, 0.5), add = TRUE)


#4. dire_score  [4-7]

sim$dire_score <- qnorm(sim_unif[,4],mean = mean(df_fin$dire_score), sd = sd(df_fin$dire_score))

# And compare the marginal histograms of the original and simulated data sets:
hist(df_fin$dire_score, col = rgb(1, 0, 0, 0.5))
hist(sim$dire_score, col = rgb(0, 0, 1, 0.5), add = TRUE)

#5. radiant_score

sim$radiant_score <- qnorm(sim_unif[,5],mean = mean(df_fin$radiant_score), sd = sd(df_fin$radiant_score))

# And compare the marginal histograms of the original and simulated data sets:
hist(df_fin$radiant_score, col = rgb(1, 0, 0, 0.5))
hist(sim$radiant_score, col = rgb(0, 0, 1, 0.5), add = TRUE)

#6. exp_15min

sim$exp_15min <- qnorm(sim_unif[,6],mean = mean(df_fin$exp_15min), sd = sd(df_fin$exp_15min))

# And compare the marginal histograms of the original and simulated data sets:
hist(df_fin$exp_15min, col = rgb(1, 0, 0, 0.5))
hist(sim$exp_15min, col = rgb(0, 0, 1, 0.5), add = TRUE)

#7. teamfight_duration

sim$teamfight_duration <- qnorm(sim_unif[,7],mean = mean(df_fin$teamfight_duration), sd = sd(df_fin$teamfight_duration))

# And compare the marginal histograms of the original and simulated data sets:
hist(df_fin$teamfight_duration, col = rgb(1, 0, 0, 0.5))
hist(sim$teamfight_duration, col = rgb(0, 0, 1, 0.5), add = TRUE)


#8 Tteamfight_deaths

sim$Tteamfight_deaths <- quantile(df_fin$Tteamfight_deaths, probs = sim_unif[, 8], type = 8)


# And compare the marginal histograms of the original and simulated data sets:
hist(df_fin$Tteamfight_deaths, col = rgb(1, 0, 0, 0.5), , )
hist(sim$Tteamfight_deaths, col = rgb(0, 0, 1, 0.5), add = TRUE)

#9 teamfight_frequency

sparam <- MASS::fitdistr(df_fin$teamfight_frequency,"Poisson")
sim$teamfight_frequency <- qpois(sim_unif[,9],lambda =sparam$estimate["lambda"] )

# And compare the marginal histograms of the original and simulated data sets:
hist(df_fin$teamfight_frequency, col = rgb(1, 0, 0, 0.5), , )
hist(sim$teamfight_frequency, col = rgb(0, 0, 1, 0.5), add = TRUE)


#10 Strength_picked_r [10-18]

probs <- table(df_fin$Strength_picked_r) / nrow(df_fin)
# Cumulative:
cum_probs <- cumsum(probs)
# Add zero:
cum_probs <- c(0, cum_probs)
# So we need to split the data at 0.5:
cut(x = sim_unif[ , 10], breaks = cum_probs)
# Take it as the same integers from which we created the margin:
sim$Strength_picked_r <- as.integer(cut(x = sim_unif[ , 10], breaks = cum_probs))-1
hist(df_fin$Strength_picked_r, col = rgb(1, 0, 0, 0.5))
hist(sim$Strength_picked_r, col = rgb(0, 0, 1, 0.5), add = TRUE)

#11 Strength_picked_d

probs <- table(df_fin$Strength_picked_d) / nrow(df_fin)
# Cumulative:
cum_probs <- cumsum(probs)
# Add zero:
cum_probs <- c(0, cum_probs)
# So we need to split the data at 0.5:
cut(x = sim_unif[ , 11], breaks = cum_probs)
# Take it as the same integers from which we created the margin:
sim$Strength_picked_d <- as.integer(cut(x = sim_unif[ , 11], breaks = cum_probs))-1
hist(df_fin$Strength_picked_d, col = rgb(1, 0, 0, 0.5))
hist(sim$Strength_picked_d, col = rgb(0, 0, 1, 0.5), add = TRUE)


#12 Agility_picked_r

probs <- table(df_fin$Agility_picked_r) / nrow(df_fin)
# Cumulative:
cum_probs <- cumsum(probs)
# Add zero:
cum_probs <- c(0, cum_probs)
# So we need to split the data at 0.5:
cut(x = sim_unif[ , 12], breaks = cum_probs)
# Take it as the same integers from which we created the margin:
sim$Agility_picked_r <- as.integer(cut(x = sim_unif[ , 12], breaks = cum_probs))-1
hist(df_fin$Agility_picked_r, col = rgb(1, 0, 0, 0.5))
hist(sim$Agility_picked_r, col = rgb(0, 0, 1, 0.5), add = TRUE)


#13 Agility_picked_d

probs <- table(df_fin$Agility_picked_d) / nrow(df_fin)
# Cumulative:
cum_probs <- cumsum(probs)
# Add zero:
cum_probs <- c(0, cum_probs)
# So we need to split the data at 0.5:
cut(x = sim_unif[ , 13], breaks = cum_probs)
# Take it as the same integers from which we created the margin:
sim$Agility_picked_d <- as.integer(cut(x = sim_unif[ , 13], breaks = cum_probs))-1
hist(df_fin$Agility_picked_d, col = rgb(1, 0, 0, 0.5))
hist(sim$Agility_picked_d, col = rgb(0, 0, 1, 0.5), add = TRUE)


#14 Intelligence_picked_r

probs <- table(df_fin$Intelligence_picked_r) / nrow(df_fin)
# Cumulative:
cum_probs <- cumsum(probs)
# Add zero:
cum_probs <- c(0, cum_probs)
# So we need to split the data at 0.5:
cut(x = sim_unif[ , 14], breaks = cum_probs)
# Take it as the same integers from which we created the margin:
sim$Intelligence_picked_r <- as.integer(cut(x = sim_unif[ , 14], breaks = cum_probs))-1
hist(df_fin$Intelligence_picked_r, col = rgb(1, 0, 0, 0.5))
hist(sim$Intelligence_picked_r, col = rgb(0, 0, 1, 0.5), add = TRUE)


#15 Intelligence_picked_d

probs <- table(df_fin$Intelligence_picked_d) / nrow(df_fin)
# Cumulative:
cum_probs <- cumsum(probs)
# Add zero:
cum_probs <- c(0, cum_probs)
# So we need to split the data at 0.5:
cut(x = sim_unif[ , 15], breaks = cum_probs)
# Take it as the same integers from which we created the margin:
sim$Intelligence_picked_d <- as.integer(cut(x = sim_unif[ , 15], breaks = cum_probs))-1
hist(df_fin$Intelligence_picked_d, col = rgb(1, 0, 0, 0.5))
hist(sim$Intelligence_picked_d, col = rgb(0, 0, 1, 0.5), add = TRUE)

#16 Universal_picked_r

probs <- table(df_fin$Universal_picked_r) / nrow(df_fin)
# Cumulative:
cum_probs <- cumsum(probs)
# Add zero:
cum_probs <- c(0, cum_probs)
# So we need to split the data at 0.5:
cut(x = sim_unif[ , 17], breaks = cum_probs)
# Take it as the same integers from which we created the margin:
sim$Universal_picked_r <- as.integer(cut(x = sim_unif[ , 17], breaks = cum_probs))-1
hist(df_fin$Universal_picked_r, col = rgb(1, 0, 0, 0.5))
hist(sim$Universal_picked_r, col = rgb(0, 0, 1, 0.5), add = TRUE)


#17 Universal_picked_d

probs <- table(df_fin$Universal_picked_d) / nrow(df_fin)
# Cumulative:
cum_probs <- cumsum(probs)
# Add zero:
cum_probs <- c(0, cum_probs)
# So we need to split the data at 0.5:
cut(x = sim_unif[ , 17], breaks = cum_probs)
# Take it as the same integers from which we created the margin:
sim$Universal_picked_d <- as.integer(cut(x = sim_unif[ , 17], breaks = cum_probs))-1
hist(df_fin$Universal_picked_d, col = rgb(1, 0, 0, 0.5))
hist(sim$Universal_picked_d, col = rgb(0, 0, 1, 0.5), add = TRUE)

#18

probs <- table(df_fin$radiant_win_bool) / nrow(df_fin)
# Cumulative:
cum_probs <- cumsum(probs)
# Add zero:
cum_probs <- c(0, cum_probs)
# So we need to split the data at 0.5:
cut(x = sim_unif[ , 18], breaks = cum_probs)
# Take it as the same integers from which we created the margin:
#sim$radiant_win_bool <- as.integer(cut(x = sim_unif[ , 18], breaks = cum_probs))-1
sim[,18] <- as.integer(cut(x = sim_unif[ , 18], breaks = cum_probs))-1
hist(df_fin$radiant_win_bool, col = rgb(1, 0, 0, 0.5))
hist(sim$radiant_win_bool, col = rgb(0, 0, 1, 0.5), add = TRUE)








simdata <- function(df_fin){
  
  sim_mat <- mvtnorm::rmvnorm(nrow(df_fin), sigma = cor(df_fin))
  sim_unif <- pnorm(sim_mat)
  sim <- df_fin
  
  mid_set <- 5:7
  st_set <- c(1,2,4,8)
  last_set <- 10:18
  
  for (i in 1:ncol(df_fin)) {
    if (i %in% last_set) {
      
      probs <- table(df_fin[,i]) / nrow(df_fin)
      # Cumulative:
      cum_probs <- cumsum(probs)
      # Add zero:
      cum_probs <- c(0, cum_probs)
      # Take it as the same integers from which we created the margin:
      sim[,i] <- as.integer(cut(x = sim_unif[ , i], breaks = cum_probs))-1
      
    } else if (i %in% st_set) {
      sim[, i] <- quantile(df_fin[, i], probs = sim_unif[, i], type = 8)
      
    } else if (i %in% mid_set) {
      sim[, i]<- qnorm(sim_unif[, i],mean = mean(df_fin[, i]), sd = sd(df_fin[, i]))
      
    } else if(i==9){
      sparam <- MASS::fitdistr(df_fin[, i],"Poisson")
      sim[, i] <- qpois(sim_unif[,9],lambda =sparam$estimate["lambda"] )
      
    } else {
      snorm_fit <- snormFit(df_fin[, i])
      sim[, i] <-
        qsnorm(
          sim_unif[ , i], 
          mean = snorm_fit$par["mean"], 
          sd = snorm_fit$par["sd"], 
          xi = snorm_fit$par["xi"]
        )
    }
  }
  
  return(sim)
  
}


nsim <- simdata(df_fin)



### ------------------ bias-variance simulation ----------
library(glmnet)
library(ggplot2)
library(reshape2)


set.seed(123)
# Bias-Variance Trade-off -----
train_indices <- sample(1:NROW(df_fin), size = 0.9 * NROW(df_fin), replace = FALSE)
train_data <- df_fin[train_indices, ]
test_data <- df_fin[-train_indices, ]
sns <- simdata(train_data)


X_test <- model.matrix(duration ~ ., data = test_data)[, -1]
y_test <- test_data$duration
# We'll repeat the simulation 100 times:
B <- 100 


lambda_grid <- 10^seq(10, -2, length = 100) 





n_test <- nrow(X_test)
pred_matrix <- array(NA, dim = c(n_test, length(lambda_grid), B))

# -------- STEP 3: Simulate, train, predict --------
for (b in 1:B) {
  sim_data <- simdata(train_data)  # Simulate from training set
  
  X_sim <- model.matrix(duration ~ ., data = sim_data)[, -1]
  y_sim <- sim_data$duration
  
  ridge_model <- glmnet(X_sim, y_sim, alpha = 0, lambda = lambda_grid, standardize = TRUE)
  preds <- predict(ridge_model, newx = X_test)  # Predict on fixed test set
  
  #pred_matrix[, , b] <- preds
  pred_matrix[, , b] <- as.matrix(preds)
  
}

# -------- STEP 4: Compute Bias², Variance, and MSE --------
bias2 <- variance <- mse <- numeric(length(lambda_grid))

for (j in 1:length(lambda_grid)) {
  preds_j <- pred_matrix[, j, ]  # Predictions for λ_j across B models
  
  avg_pred <- rowMeans(preds_j)
  bias2[j] <- mean((avg_pred - y_test)^2)
  variance[j] <- mean(apply(preds_j, 1, var))
  #mse[j] <- mean(colMeans((t(preds_j) - y_test)^2))  # Proper MSE averaging
  mse[j] <- mean(apply(preds_j, 2, function(p) mean((p - y_test)^2)))
  
  
}

# -------- STEP 5: Plot Results --------
df_plot <- data.frame(
  Lambda = lambda_grid,
  Bias2 = bias2,
  Variance = variance,
  MSE = mse
)

df_long <- melt(df_plot, id.vars = "Lambda")

ggplot(df_long, aes(x = log10(Lambda), y = value, color = variable)) +
  geom_line(size = 1.2) +
  labs(
    title = "Bias-Variance Tradeoff (Ridge Regression)",
    x = "log10(Lambda) → Simpler Models Rightward",
    y = "Error"
  ) +
  theme_minimal()


# Data frame for all results (we need to average over MSE / bias / var for each x over many datasets,
# so we need to store all the predictions as a first step, then compute point-wise MSE / bias / var 
# and average over those)

# Important difference between this and the previous simulation:
# Here, we need to compute the variance and bias for each point. So
# we can't just sample a training dataset, compute a statistic (MSE)
# save it, and repeat. We need to save ALL predictions from all training
# datasets, and post-hoc compute the variance for each point across all datasets.

###----------------########
# Lets get lasso
pred_matrix_lasso <- array(NA, dim = c(n_test, length(lambda_grid), B))

# Simulation loop
for (b in 1:B) {
  sim_data <- simdata(train_data)  # your custom function
  X_sim <- model.matrix(duration ~ ., data = sim_data)[, -1]
  y_sim <- sim_data$duration
  
  lasso_model <- glmnet(X_sim, y_sim, alpha = 1, lambda = lambda_grid, standardize = TRUE)
  preds <- predict(lasso_model, newx = X_test)
  pred_matrix_lasso[, , b] <- as.matrix(preds)
}

# Bias², Variance, MSE
bias2 <- variance <- mse <- numeric(length(lambda_grid))

for (j in 1:length(lambda_grid)) {
  preds_j <- pred_matrix_lasso[, j, ]
  
  avg_pred <- rowMeans(preds_j)
  bias2[j] <- mean((avg_pred - y_test)^2)
  variance[j] <- mean(apply(preds_j, 1, var))
  mse[j] <- mean(apply(preds_j, 2, function(p) mean((p - y_test)^2)))
}

# Plot
df_plot_lasso <- data.frame(
  Lambda = lambda_grid,
  Bias2 = bias2,
  Variance = variance,
  MSE = mse
)

df_long_lasso <- melt(df_plot_lasso, id.vars = "Lambda")

ggplot(df_long_lasso, aes(x = log10(Lambda), y = value, color = variable)) +
  geom_line(size = 1.2) +
  labs(
    title = "Bias-Variance Tradeoff (Lasso Regression)",
    x = "log10(Lambda)",
    y = "Error"
  ) +
  theme_minimal()


###-------- bootstrap approach

set.seed(123)

N <- nrow(train_data)
M <- 5000

# Fit once to get all coefficient names (including intercept)
fit0 <- glm(radiant_win_bool ~ ., family = "binomial", data = train_data)
coef_names <- names(coef(fit0))

# Initialize matrix to store coefficients
coeff_estimates <- matrix(NA, nrow = M, ncol = length(coef_names))
colnames(coeff_estimates) <- coef_names

# Bootstrap loop
for (i in 1:M) {
  sample_indices <- sample(N, N, replace = TRUE)
  boot_fit <- glm(radiant_win_bool ~ ., family = "binomial", data = train_data[sample_indices, ])
  coeff_estimates[i, ] <- coef(boot_fit)
}

# Compute 95% percentile-based CI
ci <- apply(coeff_estimates, 2, quantile, probs = c(0.025, 0.975))
ci_df <- as.data.frame(t(ci))
colnames(ci_df) <- c("Lower", "Upper")
ci_df$Coefficient <- rownames(ci_df)

print(ci_df)
summary(fit0)





#### -------------------------------- ##
##      ----- NEURAL NETS -----
## ---------------------------------- ##
library(keras)
class_train <- train_data %>% select(-duration)
class_test <- test_data %>% select(-duration)
train_Y <- class_train$radiant_win_bool
test_Y <- class_test$radiant_win_bool


# Use model.matrix to create design matrix (one-hot encoding for categorical variables)
train_X <- model.matrix(radiant_win_bool ~ ., data = class_train)[, -1]
test_X <- model.matrix(radiant_win_bool ~ ., data = class_test)[, -1]

# Normalize features
train_X <- scale(train_X)
test_X <- scale(test_X)

# Convert targets to matrices
train_Y <- as.matrix(train_Y)
test_Y <- as.matrix(test_Y)

modellr <- keras_model_sequential() %>%
  layer_dense(units = 64, activation = "relu", input_shape = ncol(train_X)) %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 32, activation = "relu") %>%
  layer_dense(units = 1, activation = "sigmoid")
summary(modellr)


# We fit the model just as before.
modellr %>% 
  compile(
    loss = "binary_crossentropy",
    optimizer = 'adam', 
    metrics = c("accuracy", "AUC")
  )



modellr %>% 
  fit(
    train_X, 
    train_Y, 
    epochs = 30,
    batch_size = 128, 
    validation_split = 0.2
  )

# Predict probabilities
pred_probs <- modellr %>% predict(test_X)

# Convert to class labels (threshold at 0.5)
pred_class <- ifelse(pred_probs > 0.5, 1, 0)

# Compute test error
error_lr <- mean(pred_class != test_Y)
print(paste("Test Error (Neural Net):", round(error_lr, 4)))


#### -------------------------------- ##
## Prediction ##
pred_train <- train_data %>% select(-radiant_win_bool)
pred_test <- test_data %>% select(-radiant_win_bool)

ptrain_Y <- pred_train$duration
ptest_Y <- pred_test$duration

# Create design matrices
ptrain_X <- model.matrix(duration ~ ., data = pred_train)[, -1]
ptest_X <- model.matrix(duration ~ ., data = pred_test)[, -1]

# Normalize features
ptrain_X <- scale(ptrain_X)
ptest_X <- scale(ptest_X)

# Convert targets to matrices
ptrain_Y <- as.matrix(ptrain_Y)
ptest_Y <- as.matrix(ptest_Y)

# Build model for regression
modellr <- keras_model_sequential() %>%
  layer_dense(units = 64, activation = "relu", input_shape = ncol(ptrain_X)) %>%
  layer_dropout(rate = 0.5) %>%
  layer_dense(units = 32, activation = "relu") %>%
  layer_dense(units = 1)  # No activation for regression

summary(modellr)

# Compile model
modellr %>% compile(
  loss = "mean_squared_error",
  optimizer = "adam",
  metrics = c("mean_absolute_error")
)

# Train model
modellr %>% fit(
  ptrain_X,
  ptrain_Y,
  epochs = 30,
  batch_size = 128,
  validation_split = 0.2
)

# Predict on test set
preds <- modellr %>% predict(ptest_X)

# Compute Mean Squared Error
error_lr <- mean((preds - ptest_Y)^2)
print(paste("Test MSE (Neural Net):", round(error_lr, 4)))


