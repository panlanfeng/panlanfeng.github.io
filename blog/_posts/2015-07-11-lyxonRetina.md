###Build lyx from source with qt5 on Mac

The stable lyx release looks terrible on retina screen. The on working version 2.2 will support high resolution display but it will not be available in a short time. Building from source is the only option if one cannot bear with the blurry font.  

Download the lyx source and install qt5.

       git clone git://git.lyx.org/lyx
      brew install qt5
      
Some other library may be needed, such as libmagic, automake, autoconf and gettext. 
      
      brew install libmagic
      
Create an empty folder `build` under the directory where you put lyx on. Go to `build` and run 

      ../lyx/autogen.sh
      ../lyx/configure -with-version-suffix=-2.X --enable-qt5  --enable-cxx11 CPPFLAGS=-I/usr/local/opt/qt5/include LDFLAGS=-L/usr/local/opt/qt5/lib

Or 
      ../lyx/autogen.sh
      ../lyx/configure -with-version-suffix=-2.X --enable-qt5 --with-qt-dir=/usr/local/opt/qt5 --with-qt-includes=/usr/local/opt/qt5/include --with-qt-libraries=/usr/local/opt/qt5/lib --enable-cxx11   
      
`--enable-qt5` may not be required if you don't have both qt4 and qt5 installed. `--enable-cxx11` is added to avoid the error of ambiguous `next`. `--with-version-suffix` adds a suffix on the App name so you can still keep a stable version lyx. 

For the first time, you need to start lyx by running

    /Applications/LyX-2.X.app/Contents/MacOS/lyx

After that it works well. The font looks nice. The math equations are better but still a little blurred. 

My system is OS X 10.10.4. The discussion [here](http://www.mail-archive.com/lyx-devel@lists.lyx.org/msg188282.html) helps me to figure out options needed by configure.
