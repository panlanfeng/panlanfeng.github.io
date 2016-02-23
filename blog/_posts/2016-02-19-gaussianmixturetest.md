---
layout: post
title: The Naughty Gaussian Mixture Model
author: <a href="http://panlanfeng.github.com/">Lanfeng</a>
---

Usually the convergence rate of maximum likelihood estimation is $n^{-1/2}$. And the log-likelihood ratio between two nested model is $\chi^2$ with degree of freedom corresponding to the difference in length of parameter. However the proof of these two results requires Fisher regularity conditions being satisfied. We tend to ignore those conditions, pretending they are always satisfied. Most of time this is not an issue since most conventional models are well behaved. However naughty models always exist, for example Gaussian mixture model. This fact is surprising because Gaussian mixture model is such simple and conventional.

Define 

$$
g(x \mid \theta) = \pi_1f(x\mid \mu_1, \sigma_1)+(1-\pi)f(x\mid\mu_2, \sigma_2).
$$

The truth is Gaussian mixture model has three undesired properties [3]:

 - __Unbounded likelihood__ when $0<\pi_1<1$ and $\sigma_1→0$
 
 - __Loss of strong identifiability__ because the second order derivative of normal density w.r.t. $\mu$ is exactly equal to its derivative w.r.t. $\sigma^2$
 
 -  __Infinite  Fisher information__ when $\pi_1=0$ and $$\sigma_2^2 > 2\sigma_1^2$$


The first properties prevents us from any meaning full m.l.e.. Some narrows the parameter space into $$\{\theta\mid\sigma_1/\sigma_2>\epsilon\}$$ where $\epsilon$ is some small positive constant. These restriction can ensure consistency of m.l.e.. However there is a better way. Chen2008 add a penalty to the log-likelihood and obtain consistency while preserving the original parameter space. The penalty term is defined as  

$$
p(\sigma^2) = -a_n (\hat{\sigma}^2/\sigma^2 + \log(\sigma^2/\hat{\sigma}^2) -1).
$$

Even if we have consistency, the second property prevent us from obtaining $n^{-1/2}$ convergence rate. The fact is when we know the number of components, root n consistency is still feasible. But if we are fitting a model with $C+1$ components while the true number of components is $C$, we can only have $n^{-1/4}$ convergence rate for $\mu$ and $\sigma$. Even worse in the case we assume $\sigma_1 = \sigma_2$, we can only have $n^{-1/8}$ for $\mu$.

Naturally we come up with conducting a log-likelihood ratio test to decide number of components. Unfortunately the third property fails the log-likelihood ratio test. 

For example, if we want to test $H_0:$ one component model v.s. $H_1:$ two components model. We are actually testing two parts: $H_{01}:(\mu_1,\sigma_1)=(\mu_2,\sigma_2)$ and $H_{02}: \pi(1-\pi)=0$. $H_{02}$ is where the traditional l.r.t. fails.

We can still do an EM test on $H_{01}$. By expanding the log-likelihood around the true parameter with fixed $\pi_1$ for 9 times and we can still obtain a quadratic form. The asymptotic distribution of l.r.t. will be $\chi^2(2)$. The Taylor expansion is most accurate at $\pi_1=0.5$. 

So we can conduct EM test on  $H_0: \theta \in \Theta_C$ in the following two ways.

 - __Chen's EM test__. Maximize $pl(\theta)$ over $\theta\in \Theta_C$. Then maximize $pl(\theta)$ over $\theta\in \Theta_{2C}$ with $\pi_1=\pi_2,\pi_3=\pi_4,\ldots,\pi_{2C-1}=\pi_{2C}$. Then 
 $$2(l(\hat{\theta}_{2C})-l(\hat{\theta}_{C}))$$
  distributes as $\chi^2(2C)$.
 
 - __Kasahara-Shimotsu's modified EM test__. Maximize $pl(\theta)$ over $\theta\in \Theta_{C+1;c}$ with $\pi_c=\pi_{c+1}$. Repeat for $c=1,2,\ldots,C$. Then the statistic  $$2(\max_{c}l(\hat{\theta}_{C+1;c})-l(\hat{\theta}_{C}))$$
  distributes as the maximum of C dependent $\chi^2(2)$ random variables. The asymptotic distribution has no closed form and needs to be obtained via simulation.

Both tests need some additional steps to increase the test power.

Here I repeat the Kasahra-Shimotsu's modified EM test on 100 random data generated from a normal distribution and show in the first figure how the density of 100 test statistics match the asymptotic distribution. The second figure is when $x$ are generated from two components mixture.

![](https://bdaerg-ch3302.files.1drv.com/y3mAtYxON0JkPEzYdNUSRJ1IIaNCu3wmYPu36onmb1UjqaZN9VvCYJIApjHIEueIBrYdGxOD_esEtIUNlbhVKz2-tHRnX54uoNpPhPwptwUnQmw8ogDaKk-CnBbRE_9LguQa8Nwl95Bktwp8tpfbF3k8ZRU85lb2UvUxC-MxRhyUS4?width=480&height=480&cropmode=none)

![](https://bnaerg-ch3302.files.1drv.com/y3m_kMtcnGWaf3WK0GLYpYLdOHws-A-15TueZSn7Spe-PiowUaq2tqXOMQ9LzJidhcowyXRGwXBdGhOSOf8ITaQ_P1-5xrAEl7xky41f_NAmZsOfTg1pvJABoVDJGePEnd6fyo-jI59gGcHGMmqPV78YyzhAEriZSBVD_zqLSBoK3c?width=480&height=480&cropmode=none)


Gaussian mixture model is a fundamental tool that can be nested into many more complicated models. Such as in generalized linear mixed model with Gaussian mixture random effects. In this case when the regression response is discrete, the first and third properties goes away. But the asymptotic distribution of its l.r.t. is still unknown. The interesting thing is although the second property prevent from $n^{-1/2}$ convergence rate on mixture parameters, the fixed effect still has $n^{-1/2}$ consistency. This has some kind of similarity to the semi-parametric model and deserve further investigation. 

Some argues why bother, why not just avoid Gaussian mixture model since it has so many undesired properties and stay inside the safe area. I would say it is the traditional theory being too fragile that even such a simple model can fail it.

## References
1. Chen, J., 1995. Optimal Rate of Convergence for Finite Mixture Models. _the Annals of Statistics_, 23, pp.221–233.
2. Chen, J., Tan, X. & Zhang, R., 2008. Inference for Normal Mixtures in Mean and Variance. _Statistica Sinica_, 18, pp.443–465.
3. Chen, J. & Li, P., 2009. Hypothesis Test for Normal Mixture Models: The EM Approach. _the Annals of Statistics_, 37(5 A), pp.2523–2542.
4. Chen, J., Li, P. & Fu, Y., 2012. Inference on the Order of a Normal Mixture. _Journal of the American Statistical Association_, 107(499), pp.1096–1105.
5. Kasahara, H. & Shimotsu, K., 2015. Testing the Number of Components in Normal Mixture Regression Models. _Journal of the American Statistical Association_ (to appear), pp.1–33. 


   
    
