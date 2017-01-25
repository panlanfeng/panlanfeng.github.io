## Step 1 Read data set
rm(list = ls())
## Download data from url <- "https://archive.ics.uci.edu/ml/machine-learning-databases/00350/default%20of%20credit%20card%20clients.xls" and convert it to csv format
destfile <- "~/Downloads/default_data.csv"
dat <- read.csv(destfile)

## convert the marriage status into dummy variables
dummy_marriage <- model.matrix(~ MARRIAGE - 1,
                               data = within(dat, MARRIAGE <- factor(MARRIAGE)))
dat$MARRIAGE <- NULL
dat <- cbind(dat, dummy_marriage[, -1])

## Step 2: split into training and test sets
library(xgboost)

predictors <- names(dat)[!names(dat) %in% c('ID', 'default.payment.next.month')]
train.index <- sample(seq(nrow(dat)), as.integer(nrow(dat) * 0.7))
tune.index <- sample(train.index, as.integer(length(train.index) * 0.7))
train.index <- setdiff(train.index, tune.index)
test.index <- setdiff(seq(nrow(dat)), c(train.index, tune.index))
xgb.train.dat <- xgb.DMatrix(data = as.matrix(dat[train.index, predictors]), label = dat$default.payment.next.month[train.index])
xgb.tune.dat <- xgb.DMatrix(data = as.matrix(dat[tune.index, predictors]), label = dat$default.payment.next.month[tune.index])
xgb.test.dat <- xgb.DMatrix(data = as.matrix(dat[test.index, predictors]), label = dat$default.payment.next.month[test.index])

## Step 3: fit two xgboost models

mod1 <- xgboost(data = xgb.train.dat, objective = 'binary:logistic', nrounds = 100, verbose = 0,
                params = list(subsample = 0.3, col_subsample_bytree = 0.1, eta = 0.1))
mod2 <- xgboost(data = xgb.train.dat, objective = 'binary:logistic', nrounds = 100, verbose = 0,
                params = list(subsample = 0.4, col_subsample_bytree = 0.2, eta = 0.1))

pred.mod1.tune <- predict(mod1, newdata = xgb.tune.dat)
pred.mod2.tune <- predict(mod2, newdata = xgb.tune.dat)

## visualize the prediction v.s. the true label in tuning
library(ggplot2)
plot.dir <- '~/Dropbox/public/blog/rocpool2/'

jpeg(file.path(plot.dir, 'scatter_pred_tune.jpg'), height = 400, width = 400)
plot.index <- sample(length(pred.mod1.tune), 3000)
ggplot() + geom_point(aes(x = pred.mod1.tune[plot.index], y = pred.mod2.tune[plot.index])) + xlab('Model 1') + ylab('Model 2') + ggtitle('Tuning Set Prediction')
dev.off()

plot.dat <- data.frame(label = as.factor(rep(dat$default.payment.next.month[tune.index], 2)),
                       predict = c(pred.mod1.tune, pred.mod2.tune),
                       model = rep(c('Model 1', 'Model 2'), each = length(tune.index)))

jpeg(file.path(plot.dir, 'boxplot_pred_tune.jpg'), height = 400, width = 400)
ggplot(data = plot.dat, aes(x = label, y = predict, fill = model)) + geom_boxplot() + theme(legend.position = 'bottom')
dev.off()

## Step 4: Compute ROC curves for each model

url.source <- 'https://dl.dropboxusercontent.com/u/72368739/blog/rocpool2/source.R'
source(url.source)

roc.mod1 <- roc(pred.mod1.tune, dat$default.payment.next.month[tune.index])
roc.mod2 <- roc(pred.mod2.tune, dat$default.payment.next.month[tune.index])

roc.models <- data.frame(ID = rep(dat$ID[tune.index], 2),
                         fpr = c(roc.mod1$fpr, roc.mod2$fpr),
                         tpr = c(roc.mod1$tpr, roc.mod2$tpr),
                         model = rep(c('Model 1', 'Model 2'), each = nrow(roc.mod1)),
                         prob = c(roc.mod1$prob, roc.mod2$prob))

jpeg(file.path(plot.dir, 'roc_models.jpg'), height = 400, width = 400)
ggplot(data = roc.models, aes(x = fpr, y = tpr, linetype = model)) + geom_line() + theme(legend.position = 'bottom') + ggtitle("ROC on the Tuning Set") + xlab("False Positive Rate") + ylab("True Positive Rate")
dev.off()

jpeg(file.path(plot.dir, 'fpr_tune.jpg'), height = 400, width = 400)
ggplot(data = roc.models, aes(x = prob, y = fpr, linetype = model)) + geom_line() + theme(legend.position = 'bottom') + ggtitle("FPR on the Tuning Set") + ylab("False Positive Rate") + xlab("Estimated Probability")
dev.off()

jpeg(file.path(plot.dir, 'tpr_tune.jpg'), height = 400, width = 400)
ggplot(data = roc.models, aes(x = prob, y = tpr, linetype = model)) + geom_line() + theme(legend.position = 'bottom') + ggtitle("TPR on the Tuning Set") + ylab("Talse Positive Rate") + xlab("Estimated Probability")
dev.off()

## Step 5 Create bi-model TPR/FPR graphs
library(plot3D)

roc.2models <- roc.surface(cbind(pred.mod1.tune,
                                 pred.mod2.tune),
                           dat$default.payment.next.month[tune.index])

jpeg(file.path(plot.dir, 'tpr_surface_tune.jpg'), height = 400, width = 400)
surf3D(x = matrix(rep(roc.2models$data.grid$prob1, each = length(roc.2models$data.grid$prob2)), nrow = 100),
       y = matrix(rep(roc.2models$data.grid$prob2, length(roc.2models$data.grid$prob1)), nrow = 100),
       z = matrix(roc.2models$data.grid$tpr, nrow = 100),
       border = NA, bty = 'b2',
       col.axis = 'black', theta = 120, xlab = 'Model 1 Probability', ylab = 'Model 2 Probability', zlab = 'True Positive Rate', axes = TRUE,
       phi = 10)
dev.off()
jpeg(file.path(plot.dir, 'fpr_surface_tune.jpg'), height = 400, width = 400)
surf3D(x = matrix(rep(roc.2models$data.grid$prob1, each = length(roc.2models$data.grid$prob2)), nrow = 100),
       y = matrix(rep(roc.2models$data.grid$prob2, length(roc.2models$data.grid$prob1)), nrow = 100),
       z = matrix(roc.2models$data.grid$fpr, nrow = 100),
       border = NA, bty = 'b2',
       col.axis = 'black', theta = 120, xlab = 'Model 1 Probability', ylab = 'Model 2 Probability', zlab = 'False Positive Rate', axes = TRUE,
       phi = 10)
dev.off()

## Get the best solution track
library(data.table)

dat.fpr.tpr <- data.table(roc.2models$data)
dat.fpr.tpr[, rnk := rank(-tpr, ties.method = 'first'), by = fpr]

jpeg(file.path(plot.dir, 'decision_path_noisy.jpg'), height = 400, width = 400)
ggplot(data = dat.fpr.tpr[rnk == 1], aes(x = pred.mod1.tune, y = pred.mod2.tune)) + geom_line() + xlab('Model 1 Probability') + ylab('Model 2 Probability')
dev.off()

save(list = ls(), file = '~/Dropbox/public/blog/rocpool2/cache.RData')

load('~/Dropbox/public/blog/rocpool2/cache.RData')

## Step 6 We can get the optimal solution via Dijkastra's algorithm
library(Rcpp)
sourceCpp('~/Dropbox/public/blog/rocpool2/dijkastra.cpp')

best.path <- dijkastra(roc.2models$data.grid$fpr, 
                       roc.2models$data.grid$tpr)

test.fpr <- matrix(c(0, 1, 1, 1, 2, 4, 3, 3, 4), nrow = 3)
test.tpr <- matrix(c(0, 1, 3, 2, 4, 8, 4, 6, 30), nrow = 3)
dijkastra(test.fpr, test.tpr)

jpeg(file.path(plot.dir, 'optimal_prob_path.jpg'), height = 400, width = 400)
plot.dat <- data.frame(Prob1 = roc.2models$data.grid$prob1[best.path[, 1]],
                       Prob2 = roc.2models$data.grid$prob2[best.path[, 2]])
ggplot(data = plot.dat[rev(seq(nrow(plot.dat))), ], aes(x = Prob1, y = Prob2)) + 
  geom_line() + xlab('Model 1 Probability') + ylab('Model 2 Probability')
dev.off()

roc.compare <- data.frame(
  fpr = c(roc.2models$data.grid$fpr[best.path],
          roc.2models$data.grid$fpr[100, ],
          roc.2models$data.grid$fpr[, 100]),
  tpr = c(roc.2models$data.grid$tpr[best.path],
          roc.2models$data.grid$tpr[100, ],
          roc.2models$data.grid$tpr[, 100]),
  method = rep(c('Pool', 'Model 2', 'Model 1'), c(199, 100, 100)))

jpeg(file.path(plot.dir, 'ROC_tune.jpg'), height = 400, width = 400)
ggplot(data = roc.compare, aes(x = fpr, y = tpr, color = method)) + geom_line() + xlab('False Positive Rate') +
  ylab('True Positive Rate') + theme(legend.position = 'bottom') + ggtitle('Tuning Set ROC')
dev.off()

## Step 7 Get the ordering for the testing data set
dat.path <- plot.dat

prob.mod1.test <- predict(mod1, newdata = xgb.test.dat)
prob.mod2.test <- predict(mod2, newdata = xgb.test.dat)

prob.test <- cbind(prob.mod1.test, prob.mod2.test)
test.set.order <- order.test.set(prob.test, dat.path)

roc.test <- roc(-test.set.order, dat$default.payment.next.month[test.index])
roc.mod1.test <- roc(prob.mod1.test, dat$default.payment.next.month[test.index])
roc.mod2.test <- roc(prob.mod2.test, dat$default.payment.next.month[test.index])
roc.test$method <- 'Pool'
roc.mod1.test$method <- "Model 1"
roc.mod2.test$method <- 'Model 2'

roc.test.all <- data.frame(rbind(roc.test[, c('fpr', 'tpr', 'method')],
                                 roc.mod1.test[, c('fpr', 'tpr', 'method')],
                                 roc.mod2.test[, c('fpr', 'tpr', 'method')]))

jpeg(file.path(plot.dir, 'roc_test.jpg'), height = 400, width = 400)
ggplot(data = roc.test.all, aes(x = fpr, y = tpr, color = method)) + geom_line() + ggtitle('Testing Set ROC') +
  xlab('False Positive Rate') + ylab('True Positive Rate') + theme(legend.position = 'bottom')
dev.off()

library(pROC)
auc(dat$default.payment.next.month[test.index], prob.mod1.test)
auc(dat$default.payment.next.month[test.index], prob.mod2.test)
auc(dat$default.payment.next.month[test.index], -test.set.order)
