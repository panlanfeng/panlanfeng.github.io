---
layout: post
title: Simulation Study Comparing Several Estimators Using Propsensity Scores
author: <a href="http://panlanfeng.github.com/">Lanfeng</a>
---

```
using Distributions
using GLM
using DataFrames

srand(2016)
n = 200
x = rand(Normal(2, 1), n)
X = [ones(n) x]
y = 1 .+ x .+ 0.5(x .- 1).^2 + randn(n)
ϕ = [-1, 0.5]
p = Float64[1/(1+exp(-(ϕ[1] + x[i]*ϕ[2]))) for i in 1:n]
δ = Int[rand(Binomial(1, p[i])) for i in 1:n];
```

Maximum estimate of $\phi$


```
xdata=DataFrame(X=x, Y=δ)
missingmodel = glm(Y~X, xdata, Binomial(), LogitLink())
ϕhat = coef(missingmodel)
δhat = predict(missingmodel);
```

## Propensity Score Adjusted Estimator


```
θ₁ = sum(δ .* y ./ δhat) / sum(δ ./ δhat)
```

    4.008805542249221


The variance estimator is $\hat{V}(\hat{\theta}_1) = A_{11}^{-1}(B_{11} - B_{12}B_{22}^{-1}B_{21})A_{11}^{-1}$


```
A11 = mean(δ ./ δhat)
B11 = 1/n^2 * sum(δ .* (y .- θ₁).^2 ./ δhat.^2)
B12 = 1/n^2 .* [sum(δ .* (1./δhat .- 1)), sum(δ .* x .* (1./δhat .- 1))]
B22 = 1/n^2 .* [sum(δ .* (1./δhat .- 1)) sum(δ .* x .* (1./δhat .- 1)); 
        sum(δ .* x .* (1./δhat .- 1)) sum(δ .* x.^2 .* (1./δhat .- 1))]
V̂₁ = (1/A11 * (B11 - B12'*inv(B22)*B12) * 1/A11)[1]

```




    0.03965886667067411



## Pseudo Optimal Regression Estimator


```
X̄ps = [mean(δ ./ δhat), mean(δ .* x ./ δhat);]
ȳps = mean(δ .* y ./ δhat)
x̄ = mean(x)
Σ = diagm(δ .* (1 .- δhat)./ (δhat.^2))
B̂ = inv( X' *  Σ * X ) * X' * Σ * y

θ₂ = (ȳps + ([1, x̄] - X̄ps)' * B̂)[1]
```




    3.9673804634913994



The linearization of $\hat{\theta}_2(\hat{B})$ will be exactly the same as $\hat{\theta}_2(B)$ while 
$$\hat{\theta}_2(B) = \frac{1}{n}\sum (\frac{\delta_i}{\hat{\pi_i}} (y_i - x_i B) + x_i B)$$


```
d = δ ./ δhat .* y .+ X * B̂ - δ ./ δhat .* (X * B̂)
V̂₂ = var(d) / n
```




    0.03238932760840901



## Optimal Regression Estimator


```
Xaug = [X δhat δhat.*x]
B̂star = inv( Xaug' *  Σ * Xaug ) * Xaug' * Σ * y
θ₃ = (ȳps + ([1, x̄] - X̄ps)' * B̂star[1:2])[1]
```




    4.040848232597155



$\hat{\theta}_3 = \frac{1}{n}\sum \hat{\eta}_i$ where 

$$\hat{\eta}_i = \pmb{x}_i\hat{B} + \frac{\delta_i}{\hat{\pi}_i}(y_i - \pmb{x}_i\hat{B})$$ 

and 
$$\hat{V}(\hat{\theta}_3) = \frac{1}{n(n-1)}\sum (\hat{\eta}_i - \bar{\hat{\eta}}_n)^2$$


```
η = Xaug * B̂star
η = η .+ δ ./ δhat .* (y .- η)
V̂₃ = var(η) / n
```




    0.03143577339037315



## Regression Weight Estimator


```
Z = [1./δhat ones(n) x]
Σ = diagm(δ)
θ₄ = (mean(Z, 1) * inv(Z' * Σ * Z) * Z' * Σ * y)[1]
```




    4.060885610354695



Linearize $\hat{\theta}_4$ as $\frac{1}{n}\sum d_i$ where 
$$d_i = x_i'\beta + \delta_i w_i (y_i - x_i\beta).$$
The variance estimator can be obtained as 
$$\frac{1}{n(n-1)}\sum (\hat{d}_i - \bar{\hat{d}}_n)^2$$


```
w = mean(Z, 1) * inv(Z' * Σ * Z) * Z'
d = Z * inv(Z' * Σ * Z) * Z' * Σ * y 
d = d .+ n .* δ .* w[:]  .* (y .- d)
V̂₄ = var(d) / n 
```




    0.03329209637511619



## Repeat for 2000 Times


```
nB = 2000
θ = zeros(nB)
θ₁ = zeros(nB)
θ₂ = zeros(nB)
θ₃ = zeros(nB)
θ₄ = zeros(nB)
V̂₁ = zeros(nB)
V̂₂ = zeros(nB)
V̂₃ = zeros(nB)
V̂₄ = zeros(nB)

for b in 1:nB
    n = 200
    x = rand(Normal(2, 1), n)
    X = [ones(n) x]
    y = 1 .+ x .+ 0.5(x .- 1).^2 + randn(n)
    ϕ = [-1, 0.5]
    p = Float64[1/(1+exp(-(ϕ[1] + x[i]*ϕ[2]))) for i in 1:n]
    # δ = Bool[ifelse(rand(Binomial(1, prob[i])), true, false) for i in 1:n]
    δ = Int[rand(Binomial(1, p[i])) for i in 1:n];
 
    θ[b] = mean(y)
    xdata=DataFrame(X=x, Y=δ)
    missingmodel = glm(Y~X, xdata, Binomial(), LogitLink())
    ϕhat = coef(missingmodel)
    δhat = predict(missingmodel);
    θ₁[b] = sum(δ .* y ./ δhat) / sum(δ ./ δhat)
    A11 = mean(δ ./ δhat)
    B11 = 1/n^2 * sum(δ .* (y .- θ₁[b]).^2 ./ δhat.^2)
    B12 = 1/n^2 .* [sum(δ .* (1./δhat .- 1)), sum(δ .* x .* (1./δhat .- 1))]
    B22 = 1/n^2 .* [sum(δ .* (1./δhat .- 1))      sum(δ .* x .* (1./δhat .- 1)); 
                    sum(δ .* x .* (1./δhat .- 1)) sum(δ .* x.^2 .* (1./δhat .- 1))]
    V̂₁[b] = (1/A11 * (B11 - B12'*inv(B22)*B12) * 1/A11)[1]

    
    
    X̄ps = [mean(δ ./ δhat), mean(δ .* x ./ δhat);]
    ȳps = mean(δ .* y ./ δhat)
    x̄ = mean(x)
    Σ = diagm(δ .* (1 .- δhat)./ (δhat.^2))
    B̂ = inv( X' *  Σ *X ) * X' * Σ * y
    θ₂[b] = (ȳps + ([1, x̄] - X̄ps)' * B̂)[1]
    d = δ ./ δhat .* y .+ X * B̂ - δ ./ δhat .* (X * B̂)
    V̂₂[b] = var(d) / n
    
    Xaug = [X δhat δhat.*x]
    B̂star = inv( Xaug' *  Σ * Xaug ) * Xaug' * Σ * y
    θ₃[b] = (ȳps + ([1, x̄] - X̄ps)' * B̂star[1:2])[1]
    η = Xaug * B̂star
    η = η .+ δ ./ δhat .* (y .- η)
    V̂₃[b] = var(η) / n
    
    Z = [1./δhat ones(n) x]
    Σ = diagm(δ)
    θ₄[b] = (mean(Z, 1) * inv(Z' * Σ * Z) * Z' * Σ * y)[1]
    w = mean(Z, 1) * inv(Z' * Σ * Z) * Z'
    d = Z * inv(Z' * Σ * Z) * Z' * Σ * y 
    d = d .+ n .* δ .* w[:]  .* (y .- d)
    V̂₄[b] = var(d) / n 
end

z=mean(θ₁ .- 4.0)./(std(θ₁)) * sqrt(nB)
p1 = min(cdf(Normal(), z), 1 - cdf(Normal(), z))*2

z=mean(θ₂ .- 4.0)./(std(θ₂)) * sqrt(nB)
p2= min(cdf(Normal(), z), 1 - cdf(Normal(), z))*2

z=mean(θ₃ .- 4.0)./(std(θ₃)) * sqrt(nB)
p3 = min(cdf(Normal(), z), 1 - cdf(Normal(), z)) * 2

z=mean(θ₄ .- 4.0)./(std(θ₄)) * sqrt(nB)
p4 = min(cdf(Normal(), z), 1 - cdf(Normal(), z)) * 2

nothing

```


```
df = DataFrame( mean =[mean(θ₁), mean(θ₂), mean(θ₃), mean(θ₄);], std =[std(θ₁), std(θ₂), std(θ₃), std(θ₄);], 
pvalue=[p1, p2, p3, p4;])
df
```




<table class="data-frame"><tr><th></th><th>mean</th><th>std</th><th>pvalue</th></tr><tr><th>1</th><td>4.0001779998688365</td><td>0.18189949768370509</td><td>0.9650936342257621</td></tr><tr><th>2</th><td>3.995364054614855</td><td>0.18867866556211033</td><td>0.2718422186321925</td></tr><tr><th>3</th><td>3.9974294040022587</td><td>0.18120384703127426</td><td>0.5258024283482636</td></tr><tr><th>4</th><td>4.0110064597476365</td><td>0.18368198826605206</td><td>0.0073674724179728646</td></tr></table>




```
using RCall
g=globalEnv
g[:theta1] = θ₁
g[:theta2] = θ₂
g[:theta3] = θ₃
g[:theta4] = θ₄
rprint("""
par(mfrow=c(2, 2))
hist(theta1, main="", xlab=expression(theta[1]))
abline(v=mean(theta1), col="red", lwd=2)
hist(theta2, main="", xlab=expression(theta[2]))
abline(v=mean(theta2), col="red", lwd=2)
hist(theta3, main="", xlab=expression(theta[3]))
abline(v=mean(theta3), col="red", lwd=2)
hist(theta4, main="", xlab=expression(theta[4]))
abline(v=mean(theta4), col="red", lwd=2)
NULL
""")
```


![png](LanfengPan522HW4_files/LanfengPan522HW4_23_0.png)


    NULL


As shown by the T test, $\theta_4$ is biased. 

## Relative Bias of the Variance Estimators

The Monte Carlo relative bias of the variance estimators are


```
[mean(V̂₁) / var(θ₁) - 1 mean(V̂₂) / var(θ₂) - 1 mean(V̂₃) / var(θ₃) - 1 mean(V̂₄) / var(θ₄) - 1] 
```


    1x4 Array{Float64,2}:
     0.563667  0.00443602  0.00936936  0.00868535



The relative biases of the first estimator is non negligible. 
