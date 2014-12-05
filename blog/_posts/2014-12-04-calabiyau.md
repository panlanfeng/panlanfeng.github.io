---
layout: post
title:  Draw the Calabi Yau Manifold in R
author: <a href="http://chandlerzuo.github.io/">Chandler</a>
---

Perhaps one of the most intriguing scene in the movie "Interstellar" is when Matthew Mcconaughey falls into a five-dimensional space from where he sends messages to his daughter. The way Christopher Nolan presents the five-dimensional space is very eye-catching. Actually, it confused me for a while. The time dimension is represented by a bunch of stacks, each representing a time horizon, and when Matthew peeks through one stack, a three dimensional space unfolds. There are only four dimensions in total. Where is the fifth-dimension?

After a moment I was clear: the fifth-dimension is the "time" that Matthew is experiencing. As he browses through the stack of times, he himself is also passing through a time dimension, but this is different from the "time" represented by the stack. If this explanation is hard to understand, we can understand it another way. The world we are experiencing is four dimensional: three dimensions describing the locations of physical objects, and one time dimension that we are passing through. So although we are located in a four dimensional world, we can only "see" three dimensions. Taking this analogy, it is easy to understand Matthew's world: if he is located in a five dimensional world, he should only visualize four dimensional objects, so there is no need to plot the fifth dimension on the screen.

A blockbuster as it is, Interstellar is criticized by some people saying that its scientific elements are too out-dated. I tend to have the same feeling. Talking about general relativity would be a cool thing twenty years ago. As a 2014 movie, maybe Nolan could have added some new discoveries in theoretical physics. After all, general relativity was discovered over half a century ago. Nolan should have taken up the challenge to introduce some more complicated, up-to-date theories to the general audience. What I am saying is the [string theory](http://en.wikipedia.org/wiki/String_theory).

OK, I will stop digressing any further. The main purpose of this post is using R to draw a cool graph related to the string theory. One of the most interesting in string theory is that our world has far more than four dimensions - it has TEN. Besides the four dimensions we are famaliar with, there are six other dimensions that are curled and wrapped in a tiny little form, the so called [Calabi-Yau manifold](http://en.wikipedia.org/wiki/Calabi%E2%80%93Yau_manifold).

Perhaps there is no way to visualize a six-dimensional object. But we can always visualize its projection in a lower dimensional space. A popular method is introduced by [Andrew Hansen](http://www.cs.indiana.edu/~hanson/), who plots its shadow in the three dimensional space. As I searched online, there are codes in Matlab, Latex and Mathematica implementing his method. It is a little shame that nobody has done it in R. After all, R is a powerful graphic software.

So here is my work.

![](https://dl.dropboxusercontent.com/u/72368739/blog/calabi_yau_5.jpg) ![](https://dl.dropboxusercontent.com/u/72368739/blog/calabi_yau_5_side.jpg)
![](https://dl.dropboxusercontent.com/u/72368739/blog/calabi_yau_10.jpg) ![](https://dl.dropboxusercontent.com/u/72368739/blog/calabi_yau_10_side.jpg)


Here are the codes. That is all.

	library(plot3D)

	triple <- function(z, x, y, n) {
	    alpha <- pi / 3
	    I <- complex(1, 0, 1)
	    if(z == 0) {
	        z1 <- exp(2 * pi * I * x)
	        z2 <- 0
	    } else {
	        z1 = exp(2 * pi * I * x) * exp(log(cos(I * z)) * 2 / n)
	        z2 = exp(2 * pi * I * y ) * exp(log(-I * sin(I * z)) * 2 / n)
	    }
	  return(c(Re(z2), cos(alpha) * Im(z1) + sin(alpha) * Im(z2), Re(z1), (pi + Arg(z1)) / (2 * pi + Arg(z1) + Arg(z2))))
	}

	oneGrid <- function(x, y, m = 20, n) {
	    M <- mesh(seq(-1, 1, length.out = m),
	              seq(0, pi / 2, length.out = m))
		
	    dat <- apply(cbind(c(M$x), c(M$y)),
	                 1, function(w)
	                     triple(complex(1, w[1], w[2]), x, y, n))
	    x.mesh <- matrix(dat[1, ], nrow = m)
	    y.mesh <- matrix(dat[2, ], nrow = m)
	    z.mesh <- matrix(dat[3, ], nrow = m)
	    w.mesh <- matrix(dat[4, ], nrow = m)
	    return(list(x = x.mesh, y = y.mesh, z = z.mesh, w = w.mesh))
	}

	myColorRamp <- function(values) {
	    x <- colorRamp(c("purple", "green"))(values)
	    rgb(x[,1], x[,2], x[,3], maxColorValue = 255)
	}
	
	plotCalabiYau <- function(n, phi = 0, theta = 0) {
	    for(k in seq(n)) {
	        for(l in seq(n)) {
	            grid.dat <- oneGrid(k / n, (l + 0.5) / n, n = n)
	            scatter3D(x = c(grid.dat$x), y = c(grid.dat$y), z = c(grid.dat$z), col = NULL, cex = 0, surf = list(x = 	grid.dat$x, y = grid.dat$y, z = grid.dat$z, col = myColorRamp(grid.dat$w), alpha = 1), xlim = c(-1.8, 1.8), ylim = c(-1.8, 	1.8), zlim = c(-1.8, 1.8), add = !(k == 1 & l == 1), phi = phi, theta = theta, alpha = 0, colkey = FALSE, axes = FALSE, bty = 	"n")
	        }
	    }
	}
