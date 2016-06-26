---
layout: post
title: Nonparametric Kernel Estimation and Regression in Julia
author: <a href="http://panlanfeng.github.io/">Lanfeng</a>
---

In term of Nonparametric density estimation and local regression, I would strongly recommend the package `KernelEstimator` because I developed it.

Comparing to the `KernelDensity` from JuliaStat group, `KernelEstimator` provides more flexible kernels. In `KernelEstimator`, kernel is just a function but in `KernelDensity` kernel has to be of type `Distribution` with a closed form character function. `KernelDensity` use Fourier transformation to reduce the computing complexity and it is much more efficient. However the price to pay is it can only be used in very limited situations. It is not wise to equal kernel with density function. 

 1. Kernel may not be a meaningful density function, such Epanechnikov kernel is not an interesting distribution. However to define a distribution corresponding to Epanechnikov kernel, we still have to define its `rand`, `cdf`, `logpdf` and `quantile` methods.

 2. A density function may not have a simple character function form

 3. A kernel may not necessary be a density. When we estimate a cumulative density function, the kernel to use should also be in the CDF form.
 
 4. A kernel does not have to be nonnegative. Certain kernel with negative value can also be used to estimate density as long as it satisfies some conditions. Search [Bias Reduced Kernel].
 
In addition Fourier transformation assume the kernel keeps unchanged on all the data points except for a shift in mean. But the shape of some kernel can also be different at difference data points. Such as `Beta` and `Gamma` kernel.

And also Fourier transformation approach make the prediction on an arbitrary point difficult. It is designed to predict on some grid points in an interval. To predict on an arbitrary $$x$$ it has to do an interpolation.

The most proud feature of `KernelEstimator` is it provides Beta kernel and Gamma kernel for bounded density estimation. 

## Why Boundary Matters

Usually kernel does not matter. However there is an exception when the data is bounded. When the domain of $$x$$ is bounded and the density of close to the boundary is large, the regular kernel estimation will suffer boundary biases. Think of this, to estimate the density near the boundary we have to have data there. Then the kernel function will have part of its density leaking outside of the boundary. That means we are underestimating the true density. Cutting off at the boundary and cumulating all the leaked density at one point at the boundary does not help.

See an example of $$\chi^2(2)$$. The red density using normal density is very wiggly and has large error near 0. The blue density using gamma density fits the truth closely. Both density estimation obtain their bandwidth via cross validation.

![](https://ctaerg-ch3301.files.1drv.com/y3mrk52xfimk54uOn44typ8vhjTuasHBf3szwow8hmFYb7cnU1cKdw0T3ggUN4sKG4xrp3pBUuwYVjFU9djTs16ol8xwX0ixKLW1YswHEXYs7LZ_887K6MV-O_CesXZ4jDy6F_CeW5Z9sz9IA6pr2eNaslTFoUsNgvLbpe8s-lWUV0?width=480&height=480&cropmode=none)

If manually increase the bandwidth of normal kernel, the variance is much smaller but the bias near the boundary gets larger.

![](https://a9aerg-ch3302.files.1drv.com/y3mdm5rSwpc07QYb7AoNBVFeUVX9kalakxeMvkuJtmsCX81mOFpt3X6S3uOr-vGDwQos-57v85Z66vnGfHXxEh5Pq6UuEpwqVkkzxqQwq75BF-QefwLx-1kmC7KFnEi14LHJ2d43HbANAMgEqevw5kjP8wv1larMxm90FJWMUkzcrk?width=480&height=480&cropmode=none)


Similar problem also exist in kernel regression. 

## How to use

The sample code of previous example

~~~ Julia
using Distributions, KernelEstimator, RCall

x = rand(Chisq(2), 1000)
xs = linspace(0.01, 10, 500)
dentrue = pdf(Chisq(2), xs)
dengamma = kerneldensity(x, xeval=xs, kernel=gammakernel, lb=0.0)
dennormal = kerneldensity(x, xeval=xs)
dennormal2 = kerneldensity(x, xeval=xs, h=.3)

@rput xs dentrue dengamma dennormal dennormal2
rprint("""
png("~/Downloads/gamma_normal.png")
plot(xs, dentrue, type="l", lwd=3)
lines(xs, dengamma, lwd=2, col="blue")
lines(xs, dennormal, lwd=2, lty=2, col="red")
#lines(xs, dennormal2, lwd=2, lty=3, col="yellow")
legend("topright", c("Truth", "Gamma Kernel", "Normal kernel"), 
lwd=c(3,2,2,2), lty=c(1,1,2,3), col=c("black", "blue", "red"))
dev.off()
""")
~~~

The basic usage is just 

~~~ Julia
kerneldensity(x)
~~~~

This will default using Gaussian Kernel with no boundaries and choose bandwidth via cross validation. We can specify where to evaluate the density by specifying `xeval`. The default value of `xeval` is `x` because the first purpose of kernel density is predicting not plotting. 

The kernel choices are `gaussiankernel`, `betakernel`, `gammakernel` and `ekernel`. `ekernel` is for Epanechnikov kernel which is the best kernel in theory. `betakernel` is used when data are two sides bounded while `gammakernel` is used when data is one side bounded.

If data is bounded, `lb` and `ub` are to set the lower and upper bound. If both are set to be finite values, then `betakernel` is used ignoring the user's specification. If only one is set to be a finite value then `gammakernel` is used no matter what user sets the `kernel` to be.

## Kernel Regression

Local constant and local linear regression are provided. Usage can be as simple as 

~~~ julia
y=2 .* x.^2 + rand(Normal(), 500)
yfit0=localconstant(x, y, xeval=xeval)
yfit1=locallinear(x, y, xeval=xeval)
yfit0=npr(x, y, xeval=xeval, reg=localconstant)
yfit1=npr(x, y, xeval=xeval, reg=locallinear)
~~~

`gammakernel` and `betakernel` are also provided in kernel regression since boundary of $$x$$ effects the prediction on $$y$$.

In addition the confidence band can be obtained using 

~~~ julia
cb=bootstrapCB(x, y, xeval=xeval)
~~~
