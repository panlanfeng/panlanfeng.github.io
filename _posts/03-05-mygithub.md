---
layout: post
title:  这两天与Github的斗争
author: <a href="http://panlanfeng.github.com/">Lanfeng</a>
---

虽然我不怎么写博客，为了附庸风雅还是特想玩一下。好多[静态博客](https://github.com/mojombo/jekyll/wiki/sites)都好好看哪，比如[Julia](http://julialang.org/)，本博客直接抄袭了人家的劳动成果。 
这里总结一下无历史负担的人快速搭建静态博客的过程。如果有历史负担，比如需要把以前的博客导入，请等待[著名网友](yixuan.github.com)的终极教程出炉。

* 首先你要了解下[markdown](http://daringfireball.net/projects/markdown/)，简单来说就是一套方便的用文本文件排版出网页的语法。搭建好博客后就可以用这套语法方便的写东西了。其实如果你愿意用HTML直接写的话也是可以的。

* 注册[Github](https://github.com)，在网站上创建目录 USERNAME.github.com(记住这里必须是你的用户名 + "github.com"，我之前就很二的以为任意目录名都可以。) 

* 安装github，设置ssh key等。参加github的帮助。

*  打开github bash，转到某个目录下，比如E:/blog，用下面命令把别人的网站架构偷过来。 
code 
    $ git clone https://github.com/plusjade/jekyll-bootstrap.git USERNAME.github.com  
    $ cd USERNAME.github.com  
    $ git remote set-url origin git@github.com:USERNAME/USERNAME.github.com.git  
    $ git push origin master  

  把里面的CNAME文件改成你的地址，比如Username.github.com。 

* 如果顺利，到这里你的网站已经搭好了，不过内容完全是山寨的。等熟悉了网站的架构与内容之间的关系，你就可以随心所欲的定制你自己的博客了。如果你要写博客，转到你的_post目录下，新建一个md格式的文件，在里面刷刷刷写，然后 
code 
    $ git add . 
    $ git commit -am "my 10000th blog" 
    $ git remote add origin git@github.com:Username/username.github.com.git 
    $ git push origin master   
 
  你的博客就发表了

如果在windows下使用的还要注意文件要用utf-8编码，切记切记！

##参考文献
[jekyllbootstrap](http://jekyllbootstrap.com/)
