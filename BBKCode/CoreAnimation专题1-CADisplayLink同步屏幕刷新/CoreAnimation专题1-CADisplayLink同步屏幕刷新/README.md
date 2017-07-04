#  iOS CoreAnimation专题1CADisplayLink–同步屏幕刷新的神器

## iOS绘图系统
虽然CoreAnimation框架的名字和苹果官方文档的简介中都是一个关于动画的框架，但是它在iOS和OS X系统体系结构中扮演的角色却是一个绘图的角色。
[官方文档](https://developer.apple.com/library/prerelease/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html)

系统体系结构：
<center>![](http://img.blog.csdn.net/20160803113408607)</center>
可以看到，最上面一层是是应用层（UI层），直接和用户打交道（UIKit框架也就是干这件事的），而真正的绘图层则在下面一层，绿色的这一层。绘图层由3个部分组成：最上面是CoreAnimation，是面向对象的。往下就是更底层的东西了：OpenGL和CoreGraphics，它们提供了统一的接口来访问绘图硬件。而绘图硬件则是绘图真正发生的地方。那我们就可以这样来理解这个体系结构：真正干事的是绘图硬件（通常是GPU），也就是最下面那一块，它负责把像素画到屏幕上。而我们为了命令它画图（如何绘制）需要有方法能访问到它，当然这种硬件层面的东西肯定不能直接访问的，操作系统一定会做限制（如果不加以限制的话可能一些错误的操作将导致系统故障），这里就和面向对象的封装很像了，操作系统封装了硬件层，只提供简单的能够由开发者直接访问的接口，而不同的硬件可能有不同的封装方式，直接访问起来势必相当麻烦（我们的代码需要适配不同的硬件），于是就有了OpenGL，它统一了所有绘图硬件的接口，我们使用OpenGL提供的同一套API就能控制任意的绘图硬件了。而OpenGL虽然很强大，但是很少会用到它一些复杂的功能，而简单的功能也是C语言不太好使用，所以具体地针对iOS和OS X系统，苹果为我们封装了OpenGL，没错这就是CoreAnimation。

