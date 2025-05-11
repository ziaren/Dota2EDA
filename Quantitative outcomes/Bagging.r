library(caret)
library(randomForest)

set.seed(1)

n        <- nrow(df)
train_i  <- sample(seq_len(n), size = 0.9 * n)
df_train <- df[train_i, ]
df_test  <- df[-train_i, ]

p <- ncol(df_train) - 1


ctrl <- trainControl(
  method = "cv",
  number = 10,
  verboseIter = TRUE
)

bag_rf_cv <- train(
  duration ~ region
           + Strength_picked_r + Strength_picked_d
           + Agility_picked_r  + Agility_picked_d
           + Intelligence_picked_r + Intelligence_picked_d
           + Universal_picked_r    + Universal_picked_d
           + first_blood_time
           + dire_score + radiant_score  
           + poly(exp_15min, 2)           
           + teamfight_duration + teamfight_frequency
           + Tteamfight_deaths,
  data       = df_train,
  method     = "rf",
  tuneGrid   = data.frame(mtry = p),
  ntree      = 100,
  importance = TRUE,
  trControl  = ctrl
)

bag_rf_cv$results

varImp(bag_rf_cv)

pred_test    <- predict(bag_rf_cv, newdata = df_test)
test_mse     <- mean((pred_test - df_test$duration)^2)
test_r2      <- 1 - sum((pred_test - df_test$duration)^2) /
                   sum((df_test$duration - mean(df_test$duration))^2)

cat("Hold‑out Test MSE  =", round(test_mse, 2), "\n")
cat("Hold‑out Test R²   =", round(test_r2,  3), "\n")
