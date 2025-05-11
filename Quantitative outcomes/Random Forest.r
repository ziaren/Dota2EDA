rf_cv <- train(
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
  ntree      = 500,
  importance = TRUE,
  trControl  = ctrl
)

print(rf_cv$results)
print(varImp(rf_cv))
pred_data <- predict(rf_cv, newdata = df_test)
mse_test  <- mean((pred_holdout - df_test$duration)^2)
rmse_test <- sqrt(mse_holdout)
r2_test   <- 1 - sum((pred_holdout - df_test$duration)^2) /
                   sum((df_test$duration - mean(df_test$duration))^2)

cat("Test RMSE =", round(rmse_test, 2), "\n")
cat("Test R²   =", round(r2_test,   3), "\n")
