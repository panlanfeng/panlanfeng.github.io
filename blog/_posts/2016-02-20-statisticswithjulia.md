---
layout: post
title: Statistics using Julia
author: <a href="http://panlanfeng.github.com/">Lanfeng</a>
---

Although still in alpha stage, Julia is already quite usable. It does not have so many packages as R yet but the basic recipes, such as distributions and optimization, are ready. This is enough for research usage because most of time the existing packages does not fit into the purpose. We need to reimplement our own methods any way.

In this post I will introduce some packages and features essential for statistical research.

## Distributions

The `Distributions` is an excellent package providing quite amount of typical distributions. Distributions are of type `Distribution`. There are common interface to `Distribution`, such as `pdf`, `logpdf`, `cdf`, `loglikelihood`, `entropy` and `quantile`... For example the following code generates $$1000$$ random number from Gaussian mixture model and calculate the log-likelihood.

~~~ julia
using Distributions
m = MixtureModel(Normal, [(-2.0, 1.2), 
    (0.0, 1.0), (3.0, 2.5)], [0.2, 0.5, 0.3])
x = rand(m, 1000)
loglikelihood(m, x)
~~~

The density functions of `Distributions` are imported from another package `StatsFuns` which use the `Rmath` library. A problem with `Rmath` is it only provide scalar density function which can be inefficient when we are evaluating on a vector of values. For example, to obtain the log-likelihood a Beta distribution on $$10000$$ data points the Beta function will be calculated for $$10000$$ times. When I was developing the `KernelEstimator` package, I realized writing the kernel function in pure Julia can be more efficient than using `Rmath`. In addition, it is possible to optimize the `exp` and `log` in vector case using `Yeppp` package. Hope one day the density functions in `StatsFuns` be rewritten in julia instead of importing `Rmath`.



## Plotting

There is no very handy plotting package in Julia right now. The `Gadfly` is ambitious but the fact is its lengthy grammar, slow plotting and unsatisfactory graph for displaying in formal situations. `PyPlot` is flexible but I am not familiar with its usage. Most of the time I send the data to R via `RCall` and use the `plot` from `base` or `ggplot2`. For example

~~~ julia
using Distributions, RCall
m = MixtureModel(Normal, [(-2.0, 1.2), 
    (0.0, 1.0), (3.0, 2.5)], [0.2, 0.5, 0.3])
xs = linspace(-5,6, 500)
den = pdf(m, xs)
@rput xs, den
rprint("""
plot(xs, den, type="l")
""")
~~~

`RCall` is definitely more than just plotting. It can start an R session, sending data from julia to R via `@rput` and fetching from R via `@rget`. That allow us to call the large amount of available R packages within julia.

## Parallel Computing

 Julia has its own parallel computing framework. Starting Julia with 
 
~~~~~ bash
julia -p 4
~~~~~

 will attach 4 workers if a computer has more than 4 processes. Then we can do parallel computing via the `pmap` function or the `@parallel` macro. For example, in `GaussianMixtureTest` I want to find out the largest log-likelihood among several possible $$\tau$$ values

~~~~~ julia
using Distributions
import GaussianMixtureTest
@everywhere using GaussianMixtureTest
x = rand(Normal(), 1000)
vtau = [.5, .3, .1;]
@parallel (max) for i in 1:3
    re=gmm(x, 2, tau = vtau[i], taufixed=true)
    re[4]
end
~~~~~
 
## Parallel on Linux Cluster
 
 Parallel computing within a single computer can only use a few processes. But a typical simulation study may have to be repeated for thousands times while each simulation may take several hours. In this case several hundred processes are needed. It is possible for julia to combine workers or processes across many nodes. For example in a PBS system, we can start julia with 160 workers in the following way. First request 10 nodes and 16 processes on each,

~~~~~ 
qsub -I -l nodes=10:ppn=16
~~~~~

 Then start julia with

~~~
julia --machinefile=$PBS_NODEFILE
~~~

 This will attach all requested processes into julia. The amazing thing is the 160 processes appear no difference with the 4 local processes started by `julia -p 4` in a single computer to the user. Or in other words it can run in parallel across several computers without using MPI and thus code running locally will run on linux serve without any change. 
 
 Here is an example of repeating a hypothesis test for 160 times and see its asymptotic distribution. The following code first defines a function to do the simulation and uses `pmap` to run it on all workers.
     
~~~ julia
import GaussianMixtureTest, Distributions
@everywhere using GaussianMixtureTest, Distributions
@everywhere function brun(b::Int)
    srand(b)
    mu_true = [-2.0858,-1.4879]
    wi_true = [0.0828,0.9172]
    sigmas_true = [0.6735,0.2931]
    n = 282
    m = MixtureModel(map((u, v) -> Normal(u, v),
     mu_true, sigmas_true), wi_true)
    x = rand(m, n)
    T1, P = GaussianMixtureTest.kstest(x, 2)
    T1
end
Tvec = pmap(brun, 1:160)
~~~~~

## More

There are some other useful packages, such as numerical optimization packages `Optim` or `NLopt`, numerical integration package `Cubature` and Gauss Quadrature calculation package `FastGaussQuadrature`.

Given all these useful packages and julia's amazing speed, everyone who want to develop some statistical method from scratch should have a try in julia.
