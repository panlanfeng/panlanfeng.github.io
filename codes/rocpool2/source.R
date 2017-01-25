roc <- function(prob, label) {
    label <- label[order(prob, decreasing = TRUE)]
    dat <- data.frame(n = seq(length(label)),
                      tp = cumsum(label),
                      tn = cumsum(1 - label))
    dat$fpr <- dat$tn / sum(1-label)
    dat$tpr <- dat$tp / sum(label)
    dat$label <- label
    dat$prob <- sort(prob, decreasing = TRUE)
    return(dat)
}

plot.roc <- function(dat, illustrate = FALSE) {
    return(ggplot(data = dat, aes(x = fpr, y = tpr)) + geom_line() + labs(x = 'False Positive Rate', y = 'True Positive Rate') + geom_abline(intercept = 0, slope = 1, linetype = 2))
}

plot.gamma <- function(prob, label) {
    dat <- gamma.func(prob, label)
    i <- which.min(abs(dat$gamma - 1))[1]
    return(ggplot(data = dat) + geom_line(aes(x = fpr, y = tpr), color = 1) + geom_line(aes(x = x, y = y), color = 'red', linetype = 2) + geom_abline(intercept = dat$y[i] - dat$gamma[i] * dat$x[i], slope = dat$gamma[i], color = 'blue') + labs(x = 'False Positive Rate', y = 'True Positive Rate') + geom_abline(intercept = 0, slope = 1, linetype = 2))
}

gamma.func <- function(prob, label) {
    dat <- roc(prob, label)
    fpr <- c(dat$fpr)
    tpr <- c(dat$tpr)
    smoothed <- lowess(fpr, tpr, f = 0.1)
    rr <- rank(smoothed$x)
    uniq.id <- c()
    uniq.rank <- c()
    for(i in seq_along(rr)) {
        if(!rr[i] %in% uniq.rank) {
            uniq.id <- c(uniq.id, i)
            uniq.rank <- c(uniq.rank, rr[i])
        }
    }
    g.score <- diff(c(0, smoothed$y[uniq.id])) / diff(c(0, smoothed$x[uniq.id]))
    names(g.score) <- uniq.rank
    dat$gamma <- g.score[as.character(rr)]
    for(i in seq_along(dat$gamma)) {
        dat$gamma[i] <- min(dat$gamma[seq(i)])
    }
    dat$gamma[dat$gamma == Inf] <- max(dat$gamma[dat$gamma != Inf])
    dat$x <- smoothed$x
    dat$y <- smoothed$y
    return(dat)
}

tpr.fpr.at.prob.pair <- function(prob, raw.prob, label) {
    n.tpr <- apply(prob, 1, function(x) sum(label * ((raw.prob[, 1] >= x[1] & raw.prob[, 2] >= x[2]))))
    n.fpr <- apply(prob, 1, function(x) sum((1 - label) * ((raw.prob[, 1] >= x[1] & raw.prob[, 2] >= x[2]))))
    tpr <- n.tpr / sum(label)
    fpr <- n.fpr / sum(1 - label)
    return(data.frame(cbind(prob, tpr, fpr)))
}

roc.surface <- function(prob, label, n.inter = 100) {
    prob <- unique(raw.prob <- prob)
    prob.grid <- expand.grid(x = (prob1 <- quantile(unique(prob[, 1]), rev(seq(n.inter)) / n.inter)),
                             y = (prob2 <- quantile(unique(prob[, 2]), rev(seq(n.inter)) / n.inter)))
    ## prob.grid <- expand.grid(x = (prob1 <- unique(prob[, 1])), y = (prob2 <- unique(prob[, 2])))
    
    data.grid <- tpr.fpr.at.prob.pair(prob.grid, raw.prob, label)
    return(list(data = tpr.fpr.at.prob.pair(prob, raw.prob, label),
                data.grid = list(prob1 = prob1,
                                 prob2 = prob2,
                                 fpr = matrix(data.grid$fpr, nrow = n.inter),
                                 tpr = matrix(data.grid$tpr, nrow = n.inter))))
}

tpr.fpr.search <- function(dat) {
    ## dat should have four columns: prob1, prob2, tpr, fpr
    names(dat) <- c('prob1', 'prob2', 'tpr', 'fpr')
    idx <- c()
    id.eligible <- seq(nrow(dat))
    while(length(id.eligible) > 0) {
        ids.fpr <- id.eligible[which.min(dat$fpr[id.eligible])]
        id.tpr <- ids.fpr[which.max(dat$tpr[ids.fpr])[1]]
        idx <- c(idx, id.tpr)
        id.eligible <- intersect(which(dat$prob1 <= dat$prob1[id.tpr]),
                                 which(dat$prob2 <= dat$prob2[id.tpr]))
        id.eligible <- setdiff(id.eligible, id.tpr)
        message("Eligible set: ", length(id.eligible))
        print(dat[id.tpr, ])
    }
    return(dat[idx, ])
}

order.test.set <- function(prob.test, prob.path) {
  get.first <- function(x) {
    idx <- which(prob.path[, 1] <= x[1] & prob.path[, 2] <= x[2])
    if(length(idx) > 0) {
      return(min(idx))
    }
    return(nrow(prob.test) + 1)
  }
  ret <- apply(prob.test, 1, get.first)
  return(ret)
}

