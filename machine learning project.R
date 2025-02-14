# Loading Data
df = read.csv('/home/fahim/Documents/processed_cleveland.csv', header=T)

# About the data
head(df)
dim(df)
names(df)

library(dplyr)
df2 = df %>% select(age,sex,cp,trestbps,chol,fbs,thalach,exang,oldpeak,slope)

# Dividing training/test data
set.seed (1)
train = sample (1: nrow(df2), nrow(df2)*0.8)
df.test = df2[-train , ]


# Random Forest
library(randomForest)
set.seed(1)
df.test = df2[-train , "thalach"]
rf.df = randomForest(thalach ~ ., data = df2 ,subset = train , mtry = 3, importance = TRUE)
yhat.rf = predict(rf.df , newdata = df2[-train , ])
mean (( yhat.rf - df.test)^2)

#R^2 calculation
SSE = sum((df.test-yhat.rf)^2)
SST = sum((df.test-mean(df.test))^2)
R_squared = 1-(SSE/SST)
R_squared

plot(df.test, yhat.rf , pch=16, ylab = "Actual", xlab="Prediction", main = "RandomForest")
abline (0, 1)


importance(rf.df )

varImpPlot(rf.df)



#BART
set.seed(1)
library(BART)
x <- df2[, c(1:6,8:10)]
y <- df2[, "thalach"]
xtrain <- x[train , ]
ytrain <- y[train]
xtest <- x[-train , ]
ytest <- y[-train]
set.seed (1)
bartfit <- gbart(xtrain , ytrain , x.test = xtest)
yhat.bart <- bartfit$yhat.test.mean
mean (( ytest - yhat.bart)^2)

plot(ytest, yhat.bart, pch=16, ylab = "Actual", xlab="Prediction", main = "BART")
abline (0, 1)

# Now we can check how many times each variable appeared in the collection of trees
ord <- order(bartfit$varcount.mean , decreasing = T)
bartfit$varcount.mean[ord]

#R^2 calculation
SSE = sum((ytest-yhat.bart)^2)
SST = sum((ytest-mean(ytest))^2)
R_squared = 1-(SSE/SST)
R_squared


#Multiple Linear Regression
set.seed(1)
library(caTools)
sampleSplit <- sample.split(Y=df2$thalach, SplitRatio=0.8)
trainSet <- subset(x=df2, sampleSplit==TRUE)
testSet <- subset(x=df2, sampleSplit==FALSE)
m2 <- lm(formula=thalach ~ ., data=trainSet)
summary(m2)

library(knitr)
kable(round(summary(m2)$coef, digits =3),
      booktabs = TRUE,
      caption = "Summary of Multiple Linear Regression.")

set.seed(1)
preds <- predict(m2, testSet)
modelEval <- cbind(testSet$thalach, preds)
colnames(modelEval) <- c("Actual", "Predicted")
modelEval <- as.data.frame(modelEval)
mse <- mean((modelEval$Actual - modelEval$Predicted)^2)
mse
rmse <- sqrt(mse)
rmse

plot(modelEval$Actual , modelEval$Predicted, pch=16, ylab = "Actual", xlab="Prediction", main = "Multiple Linear Regression")
abline (0, 1)

par(mfrow = c(2,2))
plot(m2)












