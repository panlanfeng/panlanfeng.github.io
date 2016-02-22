---
layout: post
title:  Some ideas about grammar of statistics language
author: <a href="http://panlanfeng.github.com/">Lanfeng</a>
---

Many problems, such as some in Philosophy, are difficult because it is hard to state them clearly. A powerful language system improves people's ability to solve complicated problems. 

R is almost a statistics language. Sometimes it helps to think in R commands. For example, `pnorm(2.5, 2, 4)`, `qt(.975, 20)` is more intuitive than mathematical notations. And `by`, `*ply` functions will help to think about matrix computations. 

It is a good idea to melt programming language and mathematical language together. Sentences, or code can help to understand and can be run at the same time. This requires a programming language to be very expressive. R is far from enough.  

I want R to support `dat[x1==1, ]`. It's better than `dat[dat$x1==1, ]`. And also I hope I can use  `|` as conditioning, for example `mean(y|x)` where `x` is a category vector. I don't know how to implement this two functions in R.

There is no sum of squares function in R. In linear model, this is the most basic function. So I write a few piece of codes to make life easier, such as functions to calculate `MS(y|x) = [E(y|x) - E(y)] ^ 2`.

In the following code, `MS(y|x)` is `ss(project(y, x)) / (nleves(x) - 1)`.  

~~~ R
#compute sum of squares
ss=function(x, na.rm=FALSE){
    sum((x - mean(x)) ^ 2, na.rm=na.rm)
}

# Compute the projection of y given x. Currently y can only be numeric.
# Note: When calculating the ss for interaction terms, we need to remove the contribution of linear parts. 

project=function(y, x){
    if(!is.numeric(y))
        print("sorry, method for project factors is still under developing")
    if(is.character(x))
        x <- as.factor(x)
    if(is.list(x)){
        x=interaction(x, sep="")
    }
    if(is.factor(x)){
        projected.values <- tapply(y, x, mean)
        projection <- x
        levels(projection) <- projected.values
        projection <- as.numeric(as.character(projection))
        return(projection)
    }
    if(is.numeric(x)){
        x = as.matrix(x)
        y = as.matrix(y)
        return(x %*% solve(crossprod(x)) %*% t(x) %*% y)
    }
}
~~~
