---
layout: default
title:  Lanfeng Pan
---
<h1>Lanfeng Pan</h1>
<p>
  <span class="subtitle">PhD in Statistics</span>
</p>

I am currently PhD candidate in Statistics at Iowa State University under the direction of [Dr. Yehua Li](http://www.public.iastate.edu/~yehuali/). My research interests include High Performance Computing, False Discovery Rate Control, Clustering and Missing Data Analysis.

I completed my Master and Bachelor degree in Renmin University of China. My advisor of Master degree is Dr. Xiaolin Lyu.

The programming languages I use most are R and Julia. I have been using R for 8 years and Julia for 4 years. I use R for plotting and reporting as well as small projects. When need to do heavy computing, I will turn to Julia for higher performance.

[View CV in PDF](./about/LanfengPanCV.pdf).

<!-- <iframe src="http://lanfeng.me/about/LanfengPanCV.pdf" style="width:680px; height:1800px;" frameborder="0"></iframe>
-->

## Contact Me

* Email: [pan@iastate.edu](mailto:pan@iastate.edu)
* Homepage: [lanfeng.me](http://lanfeng.me/)

## Education

* Ph.D., Iowa State University, 2012 -- Now.
* Master, Renmin University of China, 2010 -- 2012.
* Bachelor, Renmin University of China, 2006 -- 2010.

## Research

* __PAN, L.__, LI, Y., HE, K., LI, Y. and LI, Y. (2016). Latent Gaussian Mixture Models For Nationwide Kidney Transplant Center Evaluation. *The Annals of Applied Statistics* (submitted).

* Research Assistant, 2014 -- Now.

<p style="padding-left:60px;">The project is evaluating the performance of certain health care facilities. In this project we propose generalized linear mixed model with Gaussian Mixture random effects. This method can deal with False Discovery Rate control problem when the facilities are very heterogeneous.
</p>

* Intern at Novartis Pharmaceuticals, NJ, May 2015 -- August 2015.

<p style="padding-left:60px;">
Project 1: Building <code class="highlighter-rouge">shiny</code> apps to help other statisticians to visualize and analyze their data.

Project 2: Modeling and visualizing labor investment in hundreds of pharmaceutical projects, detecting potential project delays and predicting future labor investments.
</p>

* First Place in the 15th Annual Data Mining Cup, May 2014.

<p style="padding-left:60px;">
One of the nine team members. The data was about online shopping. Task was to predict returning probability of a purchase given customer shopping records and item information. There were no explicitly useful feature available and all  records were correlated. We extracted every useful information by careful data transformation and grouping. We finally ended up with the lowest prediction error rate among teams all over the world.
</p>

* Agriculture Experiment Station Consulting Group, May 2014 -- July 2014.

<p style="padding-left:60px;">
Job was answering questions from random visitors from other departments. Need to communicate with the visitors to figure out their questions, help to summarize their question in statistical language and then guide them to the solutions.
</p>

* Teaching Assistant, August 2012 -- May 2014.

<p style="padding-left:60px;">
Worked as teaching assistant for STAT 341, 342, 447, 542 and 543. Major duties were answering questions, helping with homework and grading.
</p>

## Research Interests

* High Performance Computing
* Multiple Testing, False Discovery Rate Control
* Clustering, Subgroup Analysis
* Missing Data Analysis
* Nonparametrics
* Health Policy

## Skills

* 8 years experience with R
* 4 years experience with Julia
* 4 years experience with Linux Shell and git
* Some experience with Python
* Proficient with `shiny`, `ggplot2`, `knitr`, `rmarkdown` and $\TeX$

## Contributions
* Julia Package: `LatentGaussianMixtureModel.jl`. Fits a Generalized Linear Mixed Model with Gaussian mixture random effects, deciding the number of components for Gaussian mixture. And further conduct a multiple test to detect heterogeneity while control the False Discovery Rate.

* Julia Package: [`RFlavor.jl`](http://github.com/panlanfeng/RFlavor.jl). Implements a lot of useful and handy R functions in Julia. The purpose is to provide better statistical functions for Julia language as well as make it easy to translate R code into Julia.

* Julia Package: [`KernelEstimator.jl`](http://github.com/panlanfeng/KernelEstimator.jl). Implements kernel density estimation and kernel regression. In particular this package can deal with bounded kernel estimation using beta and gamma kernel and can choose bandwidth via cross valuation.

* Julia Package: [`GaussianMixtureTest.jl`](http://github.com/panlanfeng/GaussianMixtureTest.jl). Implements the Kasahara-Shimotsu Test to decide number of components in Gaussian Mixture Model. There is very few package in this area.

* Contribute to Julia Package: [`Yeppp.jl`](http://github.com/JuliaMath/Yeppp.jl). This package ports the [`Yeppp!`](http://www.yeppp.info/) library into Julia, significantly speeding up several basic arithmetic operations.

* Contribute to several core statistical packages in Julia community including  [`StatsBase.jl`](https://github.com/JuliaStats/StatsBase.jl), [`Rmath.jl`](https://github.com/JuliaStats/Rmath.jl), [`DataArrays.jl`](https://github.com/JuliaStats/DataArrays.jl) and [`KernelDensity.jl`](https://github.com/JuliaStats/KernelDensity.jl).

* R package: [`bignmf`](http://github.com/panlanfeng/bignmf). Solves the nonnegative matrix factorization problem using coordinate descent.

<br/><br/>

<!--
<div id="disqus_thread"></div>
<script>
    /**
     *  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
     *  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables
     */

    var disqus_config = function () {
        this.page.url = "{{site.url}}";  // Replace PAGE_URL with your page's canonical URL variable
        this.page.identifier = "/"; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
    };

    (function() {  // DON'T EDIT BELOW THIS LINE
        var d = document, s = d.createElement('script');

        s.src = '//lanfeng.disqus.com/embed.js';

        s.setAttribute('data-timestamp', +new Date());
        (d.head || d.body).appendChild(s);
    })();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript" rel="nofollow">comments powered by Disqus.</a></noscript>

-->
