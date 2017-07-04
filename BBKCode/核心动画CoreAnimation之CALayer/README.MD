
[toc]
# iOS CALayer与iOS动画 讲解及使用
```
参考文章：
CoreAnimation初探(一) —— 图形学基础
http://www.cocoachina.com/ios/20170221/18734.html
http://www.jianshu.com/p/c2570dee26eb
```
## 1.关于CoreAnimation
CoreAnimation是苹果提供的一套基于绘图的动画框架，下图是官方文档中给出的体系结构。

<center> ![CoreAnimation所在的位置](http://cc.cocimg.com/api/uploads/20170220/1487569298620491.png) </center>
<center> <font color = cyan>图1-1 CoreAnimation所在的位置</font> </center>

从图中可以看出，最底层是图形硬件(GPU)；上层是OpenGL和CoreGraphics，提供一些接口来访问GPU；再上层的CoreAnimation在此基础上封装了一套动画的API。最上面的UIKit属于应用层，处理与用户的交互。所以，学习CoreAnimation也会涉及一些图形学的知识，了解这些有助于我们更顺手的使用以及更高效的解决问题。
## 2.初识CALayer

CoreAnimation属于QuartzCore框架，Quartz原本是macOS的Darwin核心之上的绘图技术。在iOS中，我们所看到的视图UIView是通过QuartzCore中的CALayer显示出来的，我们讨论的动画效果也是加在这个CALayer上的。
`下面主要的内容是：
CALayer(图层类)和CAAnimation(动画类)的内容和关系
以及他们实现的一个重要协议CAMediaTiming`

>CALayer图层类是CoreAnimation的基础，它提供了一套抽象概念。CALayer是整个图层类的基础，它是所有核心动画图层的父类

### 1.CALayer
为什么UIView要加一层Layer来负责显示呢？我们知道QuartzCore是跨iOS和macOS平台的，而UIView属于UIKit是iOS开发使用的，在macOS中对应AppKit里的NSView。这是因为macOS是基于鼠标指针操作的系统，与iOS的多点触控有本质的区别。虽然iOS在交互上与macOS有所不同，但在显示层面却可以使用同一套技术。
每一个UIView都有个属性layer、默认为CALayer类型，也可以使用自定义的Layer
```
/* view的leyer，view是layer的代理 */
@property(nonatomic,readonly,strong) CALayer  *layer;
```
可以想象我们看到的View其实都是它的layer，下面我们通过CALayer中的集合相关的属性来认识它：

* bounds:图层的bounds是一个CGRect的值，指定图层的大小（bounds.size)和原点(bounds.origin)

* position：指定图层的位置(相对于父图层而言)

* anchorPoint：锚点指定了position在当前图层中的位置，坐标范围0~1。position点的值是相对于父图层的，而这个position到底位于当前图层的什么地方，是由锚点决定的。(默认在图层的中心，即锚点为(0.5,0.5) )

* transform：指定图层的几何变换，类型为上篇说过的CATransform3D

这些属性的注释最后都有一句Animatable，就是说我们可以通过改变这些属性来实现动画。默认地，我们修改这些属性都会导致图层从旧值动画显示为新值，称为隐式动画。
注意到frame的注释里面是没有Animatable的。事实上，我们可以理解为图层的frame并不是一个真实的属性：当我们读取frame时，会根据图层position、bounds、anchorPoint和transform的值计算出它的frame；而当我们设置frame时，图层会根据anchorPoint改变position和bounds。也就是说frame本身并没有被保存。

> 图层不但给自己提供可视化的内容和管理动画，而且充当了其他图层的容器类，构建图层层次结构

图层树类似于UIView的层次结构，一个view实例拥有父视图(superView)和子视图(subView)；同样一个layer也有父图层(superLayer)和子图层(subLayer)。我们可以直接在view的layer上添加子layer达到一些显示效果，但这些单独的layer无法像UIView那样进行交互响应。

### 2.CAAnimation
CALayer提供以下方法来管理动画：
```
- (void)addAnimation:(CAAnimation*)anim forKey:(nullable NSString*)key;

- (void)removeAllAnimations;

- (void)removeAnimationForKey:(NSString*)key;

- (nullable NSArray<NSString*>*)animationKeys;

- (nullable CAAnimation*)animationForKey:(NSString*)key;
```
CAAnimation是动画基类，我们常用的CABasicAnimation和CAKeyframeAnimation都继承于CAPropertyAnimation即属性动画。属性动画通过改变layer的可动画属性(位置、大小等)实现动画效果。CABasicAnimation可以看做有两个关键帧的CAKeyframeAnimation，通过插值形成一条通过各关键帧的动画路径。但CABasicAnimation更加灵活一些：

```
@interface CABasicAnimation : CAPropertyAnimation
@property(nullable, strong) id fromValue;
@property(nullable, strong) id toValue;
@property(nullable, strong) id byValue;
@end
```

**我们可以通过上面三个值来规定CABasicAnimation的动画起止状态**

* 这三个属性都是可选的，通常给定其中一个或者两个，以下是官方建议的使用方式
给定fromValue和toValue，将在两者之间进行插值 *
*  给定fromValue和byValue，将在fromValue和fromValue+byValue之间插值 *
* 给定byValue和toValue，将在toValue-byValue和toValue之间插值 *
* 仅给定fromValue，将在fromValue和当前值之间插值 *
* 仅给定toValue，将在当前值和toValue之间插值 *
* 仅给定byValue，将在当前值和当前值+byValue之间插值 *

在CAKeyframeAnimation中，除了给定各关键帧之外还可以指定关键帧之间的时间和时间函数：
```
@interface CAKeyframeAnimation : CAPropertyAnimation

@property(nullable, copy) NSArray *values;
@property(nullable, copy) NSArray<NSNumber *> *keyTimes;
/* 时间函数有线性、淡入、淡出等简单效果，还可以指定一条三次贝塞尔曲线 */
@property(nullable, copy) NSArray<CAMediaTimingFunction *> *timingFunctions;

@end
```
到这我们已经能够感觉到，所谓动画实际上就是在不同的时间显示不同画面，时间在走进而形成连续变化的效果。所以，动画的关键就是对时间的控制。

### 3.CAMediaTiming
CAMediaTiming是CoreAnimation中一个非常重要的协议，CALayer和CAAnimation都实现了它来对时间进行管理。
协议定义了8个属性，通过它们来控制时间，这些属性大都见名知意：
```
@protocol CAMediaTiming

@property CFTimeInterval beginTime;
@property CFTimeInterval duration;
@proterty float speed;
/* timeOffset时间的偏移量，用它可以实现动画的暂停、继续等效果*/
@proterty CFTimeInterval timeOffset;
@property float repeatCount;
@property CFTimeInterval repeatDuration;
/* autoreverses为true时时间结束后会原路返回，默认为false */
@property BOOL autoreverses;
/* fillMode填充模式，有4种，见下 */
@property(copy) NSString *fillMode;

@end
```
下面这张图形象的说明了这些属性是如何灵活的进行动画时间控制的：
![动画时间控制图片](http://upload-images.jianshu.io/upload_images/3087964-d86f0ca2bb518b41.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/720)
<center><font color = cyan>图2-1 动画时间控制</font></center>

需要注意的是，CALayer也实现了CAMediaTiming协议，也就是说如果我们将layer的speed设置为2，那么加到这个layer上的动画都会以两倍速执行。

上面从图层、动画和时间控制的关系上简单认识了CALayer、属性动画和动画时间控制，了解属性动画是根据时间在各关键帧之间进行插值，随时间连续改变layer的某动画属性来实现的。

## 3.UIView与CALayer动画原理


下面从以下两点结合具体代码来探索下CoreAnimation的一些原理
>1.UIView动画实现原理
>2.展示层(presentationLayer)和模型层(modelLayer)

***

### 1.UIView动画实现原理
UIView提供了一系列UIViewAnimationWithBlocks，我们只需要把改变可动画属性的代码放在animations的block中即可实现动画效果，比如：


```
[UIView animateWithDuration:1 animations:^(void){
if (_testView.bounds.size.width > 150)
{
_testView.bounds = CGRectMake(0, 0, 100, 100);
}
else
{
_testView.bounds = CGRectMake(0, 0, 200, 200);
}
} completion:^(BOOL finished){
NSLog(@"%d",finished);
}];
```
效果如下：
<center>![](http://upload-images.jianshu.io/upload_images/3087964-3261d5e8b47c014c.gif?imageMogr2/auto-orient/strip)
</center>
<center><font color = cyan>图3-1 动画效果</font></center>
之前说过，UIView对象持有一个CALayer，真正来做动画的是这个layer，UIView只是对它做了一层封装，可以通过一个简单的实验验证一下：我们写一个MyTestLayer类继承CALayer，并重写它的set方法；再写一个MyTestView类继承UIView，重写它的layerClass方法指定图层类为MyTestLayer：

```
@interface MyTestLayer : CALayer
@end
@implementation MyTestLayer
- (void)setBounds:(CGRect)bounds
{
NSLog(@"----layer setBounds");
[super setBounds:bounds];
NSLog(@"----layer setBounds end");
}
...
@end

@interface MyTestView : UIView
- (void)setBounds:(CGRect)bounds
{
NSLog(@"----view setBounds");
[super setBounds:bounds];
NSLog(@"----view setBounds end");
}
...
+(Class)layerClass
{
return [MyTestLayer class];
}
@end

```

当我们给view设置bounds时，getter、setter的调用顺序是这样的：
![](http://upload-images.jianshu.io/upload_images/3087964-c4f2207f0724e085.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/650)
<font color = cyan>图3-2 getter、setter的调用顺序</font>
也就是说，在view的setBounds方法中，会调用layer的setBounds；同样view的getBounds也会调用layer的getBounds。其他属性也会得到相同的结论。那么动画又是怎么产生的呢？当我们layer的属性发生变化时，会调用代理方法actionForLayer: forKey: 来获得这次属性变化的动画方案，而view就是它所持有的layer的代理：

```
@interface CALayer : NSObject <NSCoding, CAMediaTiming>
...
@property(nullable, weak) id <CALayerDelegate> delegate;
...
@end

@protocol CALayerDelegate <NSObject>
@optional
...
/* If defined, called by the default implementation of the
* -actionForKey: method. Should return an object implementating the
* CAAction protocol. May return 'nil' if the delegate doesn't specify
* a behavior for the current event. Returning the null object (i.e.
* '[NSNull null]') explicitly forces no further search. (I.e. the
* +defaultActionForKey: method will not be called.) */
- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event;
...
@end
```

注释中说明，该方法返回一个实现了CAAction的对象，通常是一个动画对象；当返回nil时执行默认的隐式动画，返回null时不执行动画。还是上面那个改变bounds的动画，我们在MyTestView中重写actionForLayer:方法

```
- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
id<CAAction> action = [super actionForLayer:layer forKey:event];
return action;
}
```

观察它的返回值：
<center>![](http://upload-images.jianshu.io/upload_images/3087964-304bc3f988bc0c85.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/800)</center>

是一个内部使用的_UIViewAddtiveAnimationAction对象，其中包含一个CABassicAnimation，默认fillMode为both，默认时间函数为淡入淡出，只包含fromValue(即动画之前的值，会在这个值和当前值(block中修改过后的值)之间做动画)。我们可以尝试在重写的这个方法中强制返回nil，会发现我们不写任何动画的代码直接改变属性也将产生一个默认0.25s的隐式动画，这和上面的注释描述是一致的。

**如果两个动画重叠在一起会是什么效果呢？**

还是最开始的例子，我们添加两个相同的UIView动画，一个时间为3s，一个时间为1s，并打印finished的值和两个动画的持续时间。先执行3s的动画，当它还没有结束时加上一个1s的动画，可以先看下实际效果：
<center>![-w300](http://upload-images.jianshu.io/upload_images/3087964-a494074a040e76f0.gif?imageMogr2/auto-orient/strip)</center>
<center>![](http://upload-images.jianshu.io/upload_images/3087964-a0b2e78344b62a35.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/650)</center>

很明显，两个动画的finished都为true且时间也是我们设置好的3s和1s。也就是说第二个动画并不会打断第一个动画的执行，而是将动画进行了叠加。我们先来观察一下运行效果：

* 最开始方块的bounds为(100,100)，点击执行3s动画，bounds变为(200,200)，并开始展示变大的动画；

* 动画过程中(假设到了(120,120))，点击1s动画，由于这时真实bounds已经是(200,200)了，所以bounds将变回100，并产生一个fromValue为(200,200)的动画。
<center>![](http://upload-images.jianshu.io/upload_images/3087964-f537caafaea919d0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/650)
</center>

但此时方块并没有从200开始，而是马上开始变小，并明显变到一个比100更小的值。

* 1s动画结束，finished为1，耗时1s。此时屏幕上的方块是一个比100还要小的状态，又缓缓变回到100—3s动画结束，finished为1，耗时3s，方块最终停在(100,100)的大小。

从这个现象我们可以猜想UIView动画的叠加方式：当我们通过改变View属性实现动画时，这个属性的值是会立即改变的，动画只是展示出来的效果。当动画还未结束时如果对同个属性又加上另一个动画，两个动画会从当前展示的状态开始进行叠加，并最终停在view的真实位置。
举个通俗点的例子，我们8点从家出发，要在9点到达学校，我们按照正常的步速行走，这可以理解为一个动画；假如我们半路突然想到忘记带书包了，需要回家拿书包（相当于又添加了一个动画），这时我们肯定需要加快步速，当我们拿到书包时相当于第二个动画结束了，但我们上学这个动画还要继续执行，我们要以合适的速度继续往学校赶，保证在9点准时到达终点—学校。

所以刚才那个方块为什么会有一个比100还小的过程就不难理解了：当第二个动画加上去的时候，由于它是一个1s由200变为100的动画，肯定要比3s动画执行的快，而且是从120的位置开始执行的，所以一定会朝反方向变化到比100还小；1s动画结束后，又会以适当的速度在3s的时间点回到最终位置(100,100)。当然叠加后的整个过程在内部实现中可能是根据时间函数已经计算好的。

这么做或许是为了让动画显得更流畅平滑，那么既然我们设置属性值是立即生效的，动画只是看上去的效果，那刚才叠加的时刻屏幕展示上的位置(120,120)又是什么呢？这就是本篇要讨论的下一个话题。
<br>
<br>


### 2.展示层(presentationLayer)和模型层(modelLayer)

我们知道UIView动画其实是layer层做的，而view是对layer的一层封装，我们对view的bounds等这些属性的操作其实都是对它所持有的layer进行操作，我们做一个简单的实验—在UIView动画的block中改变view的bounds后，分别查看下view和layer的bounds的实际值：

```
_testView.bounds = CGRectMake(0, 0, 100, 100);
[UIView animateWithDuration:1 animations:^(void){
_testView.bounds = CGRectMake(0, 0, 200, 200);
} completion:nil];
```

赋值完成后我们分别打印view，layer的bounds：
![](http://upload-images.jianshu.io/upload_images/3087964-ec89056d3ab65266.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/650)
都已经变成了(200,200)，这是肯定的，之前已经验证过set view的bounds实际上就是set 它的layer的bounds。可动画不是layer实现的么？layer也已经到达终点了，它是怎么将动画展示出来的呢？
这里就要提到CALayer的两个实例方法presentationLayer和modelLayer：

```
@interface CALayer : NSObject <NSCoding, CAMediaTiming>
...
/* 以下参考官方api注释 */
/* presentationLayer
* 返回一个layer的拷贝，如果有任何活动动画时，包含当前状态的所有layer属性
* 实际上是逼近当前状态的近似值。
* 尝试以任何方式修改返回的结果都是未定义的。
* 返回值的sublayers 、mask、superlayer是当前layer的这些属性的presentationLayer
*/
- (nullable instancetype)presentationLayer;

/* modelLayer
* 对presentationLayer调用，返回当前模型值。
* 对非presentationLayer调用，返回本身。
* 在生成表示层的事务完成后调用此方法的结果未定义。
*/
- (instancetype)modelLayer;
...
```
从注释不难看出，这个presentationLayer即是我们看到的屏幕上展示的状态，而modelLayer就是我们设置完立即生效的真实状态，我们动画开始后延迟0.1s分别打印layer，layer.presentationLayer，layer.modelLayer和layer.presentationLayer.modelLayer :
![](http://upload-images.jianshu.io/upload_images/3087964-9800e3bc141a2dee.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)
明显，layer.presentationLayer是动画当前状态的值，而layer.modelLayer 和 layer.presentationLayer.modelLayer 都是layer本身。

到这里，CALayer动画的原理基本清晰了，当有动画加入时，presentationLayer会不断的(从按某种插值或逼近得到的动画路径上)取值来进行展示，当动画结束被移除时则取modelLayer的状态展示。这也是为什么我们用CABasicAnimation时，设定当前值为fromValue时动画执行结束又会回到起点的原因，实际上动画结束并不是回到起点而是到了modelLayer的位置。

虽然我们可以使用fillMode控制它结束时保持状态，但这种方法在动画执行完之后并没有将动画从渲染树中移除(因为我们需要设置animation.removedOnCompletion = NO才能让fillMode生效)。如果我们想让动画停在终点，更合理的办法是一开始就将layer设置成终点状态，其实前文提到的UIView的block动画就是这么做的。

如果我们一开始就将layer设置成终点状态再加入动画，会不会造成动画在终点位置闪一下呢？其实是不会的，因为我们看到的实际上是presentationLayer，而我们修改layer的属性，presentationLayer是不会立即改变的：

```
MyTestView *view = [[MyTestView alloc]initWithFrame:CGRectMake(200, 200, 100, 100)];
[self.view addSubview:view];

view.center = CGPointMake(1000, 1000);

dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((1/60) * NSEC_PER_SEC)), dispatchQueue, ^{
NSLog(@"presentationLayer %@ y %f",view.layer.presentationLayer, view.layer.presentationLayer.position.y);
NSLog(@"layer.modelLayer %@ y %f",view.layer.modelLayer,view.layer.modelLayer.position.y);
});
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((1/20) * NSEC_PER_SEC)), dispatchQueue, ^{
NSLog(@"presentationLayer %@ y %f",view.layer.presentationLayer, view.layer.presentationLayer.position.y);
NSLog(@"layer.modelLayer %@ y %f",view.layer.modelLayer,view.layer.modelLayer.position.y);
});

```

在上面代码中我们改变view的center，modelLayer是立即改变的因为它就是layer本身。但presentationLayer是没有变的，我们尝试延迟一定时间再去取presentationLayer，发现它是在一个很短的时间之后才发生变化的，这个时间跟具体设备的屏幕刷新频率有关。也就是说我们给layer设置属性后，当下次屏幕刷新时，presentationLayer才会获取新值进行绘制。因为我们不可能对每一次属性修改都进行一次绘制，而是将这些修改保存在model层，当下次屏幕刷新时再统一取model层的值重绘。
如果我们添加了动画，并将modelLayer设置到终点位置，下次屏幕刷新时，presentationLayer会优先从动画中取值来绘制，所以并不会造成在终点位置闪一下。

-


__总结__

*	UIView持有一个CALayer负责展示，view是这个layer的delegate。改变view的属性实际上是在改变它持有的layer的属性，layer属性发生改变时会调用代理方法actionForLayer: forKey: 来得知此次变化是否需要动画。对同一个属性叠加动画会从当前展示状态开始叠加并最终停在modelLayer的真实位置。
* 	CALayer内部控制两个属性presentationLayer和modelLayer，modelLayer为当前layer真实的状态，presentationLayer为当前layer在屏幕上展示的状态。presentationLayer会在每次屏幕刷新时更新状态，如果有动画则根据动画获取当前状态进行绘制，动画移除后则取modelLayer的状态。


[Demo代码地址](https://github.com/Shizq5509/CADemo)



## 4.初探CALayer属性
**view和layer的关系**
![UIView和layer的关系图](http://cc.cocimg.com/api/uploads/20161204/1480865231251244.png)
<center><font color = cyan>图4-1 UIView和layer的关系图</font></center>
**CALayer属性表如下**
![CALayer属性图](http://cc.cocimg.com/api/uploads/20161204/1480865249159649.png)
<center><font color = cyan>图4-2 CALayer属性图</font></center>
**CALayer和UIView的区别**

* 1.UIView是UIKit的(只能iOS使用)，CALayer是QuartzCore的(iOS和mac os通用)
* 2.UIView继承UIResponder,CALayer继承NSObject,UIView比CALayer多了一个事件处理的功能，也就是说，CALayer不能处理用户的触摸事件，而UIView可以
* 3.UIView来自CALayer，是CALayer的高层实现和封装，UIView的所有特性来源于CALayer支持
* 4.CABasicAnimation，CAAnimation，CAKeyframeAnimation等动画类都需要加到CALayer上



其实UIView之所以能显示在屏幕上，完全是因为它内部的一个图层，在创建UIView对象时，UIView内部会自动创建一个图层(即CALayer对象)，通过UIView的layer属性可以访问这个层。
```
@property(nonatomic,readonly,retain) CALayer *layer;
```
当UIView需要显示到屏幕上时，会调用drawRect:方法进行绘图，并且会将所有内容绘制在自己的图层上，绘图完毕后，系统会将图层拷贝到屏幕上，于是就完成了UIView的显示
换句话说，UIView本身不具备显示的功能，是它内部的层才有显示功能


```
//
//  LayerTransformViewController.m
//  核心动画CoreAnimation之CALayer
//
//  Created by zxx_mbp on 2017/7/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "LayerTransformViewController.h"

@interface LayerTransformViewController ()

@end

@implementation LayerTransformViewController

- (void)viewDidLoad {
[super viewDidLoad];
self.view.backgroundColor = [UIColor whiteColor];
[self 图层内容和内容模式_01];
}

#pragma mark - 仿射变换

- (void)仿射变换_07 {



CALayer* layer = [CALayer layer];
layer.frame = CGRectMake(60, 60, 200, 300);
layer.backgroundColor = [UIColor redColor].CGColor;
[self.view.layer addSublayer:layer];
//设置层内容
layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"logo"].CGImage);
//X轴旋转45°
//layer.transform = CATransform3DMakeRotation(45*(M_PI)/180.0, 1, 0, 0);
//旋转45° 度数 x y z
//layer.transform = CATransform3DMakeRotation(90*(M_PI)/180.0, 1, 0, 0);

//CATransform3DMakeRotation(<#CGFloat angle#>, <#CGFloat x#>, <#CGFloat y#>, <#CGFloat z#>);3D旋转
//CATransform3DTranslate(<#CATransform3D t#>, <#CGFloat tx#>, <#CGFloat ty#>, <#CGFloat tz#>);3D位移
//CATransform3DMakeScale(<#CGFloat sx#>, <#CGFloat sy#>, <#CGFloat sz#>);3D缩放
//CATransform3DMakeTranslation(<#CGFloat tx#>, <#CGFloat ty#>, <#CGFloat tz#>)

//仿射变换
layer.affineTransform = CGAffineTransformMakeRotation(45*(M_PI)/180);
}

#pragma mark - 剪切图片的一部分
- (void)剪切图片的一部分_06
{
int width = 80;
int height = 100;
int sapce = 3;
for(int i = 0; i < 9; i++)
{
UIView *view = [[UIView alloc] init];
view.frame = CGRectMake(60 + (width + sapce) * (i%3), 80 + (height + sapce) * (i/3), width, height);
view.backgroundColor = [UIColor redColor];
//设置层的内容
view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"logo"].CGImage);
//设置图片剪切的范围  [0,1]  contentsRect 图层显示内容的大小和位置
view.layer.contentsRect = CGRectMake(1.0/3.0 * (i%3), 1.0/3.0 * (i/3), 1.0/3.0, 1.0/3.0);
[self.view addSubview:view];
/*
1：（0，0，1/3,1/3）
2: (1/3,0，1/3,1/3)
3: (2/3,0，1/3,1/3)
*/
}
}

#pragma mark - 图层添加边框和圆角
- (void)图层添加边框和圆角_05
{
CALayer *layer = [CALayer layer];
layer.frame = CGRectMake(60, 60, 100, 100);
layer.backgroundColor = [UIColor redColor].CGColor;
[self.view.layer addSublayer:layer];
//边框颜色
layer.borderColor = [UIColor greenColor].CGColor;
//边框宽度
layer.borderWidth = 3;
//圆角
layer.cornerRadius = 10;
}

#pragma mark - 剪切超过父图层的部分
- (void)剪切超过父图层的部分_04
{
CALayer *layer = [CALayer layer];
layer.frame = CGRectMake(60, 60, 100, 100);
layer.backgroundColor = [UIColor redColor].CGColor;
[self.view.layer addSublayer:layer];
CALayer *layer2 = [CALayer layer];
layer2.frame = CGRectMake(30, 30, 100, 100);
layer2.backgroundColor = [UIColor blueColor].CGColor;
[layer addSublayer:layer2];
//剪切超过父图层的部分
layer.masksToBounds = YES;
}

#pragma mark - 阴影路径
- (void)阴影路径_03 {
CALayer *layer = [CALayer layer];
layer.frame = CGRectMake(60, 60, 100, 100);
layer.backgroundColor = [UIColor redColor].CGColor;
[self.view.layer addSublayer:layer];
//1表明不透明，注意：设置阴影当前值不能为0，默认是0
layer.shadowOpacity = 1.0;
//阴影颜色
layer.shadowColor = [UIColor yellowColor].CGColor;
//创建路径
CGMutablePathRef path = CGPathCreateMutable();
//椭圆
CGPathAddEllipseInRect(path, NULL, CGRectMake(0, 0, 200, 200));
layer.shadowPath = path;
CGPathRelease(path);
}

#pragma mark - 添加阴影_02
- (void)层的阴影_02 {
CALayer *layer = [CALayer layer];
layer.frame = CGRectMake(60, 60, 100, 100);
layer.backgroundColor = [UIColor redColor].CGColor;
[self.view.layer addSublayer:layer];
layer.shadowOpacity = 0.9;
layer.shadowColor = [UIColor yellowColor].CGColor;
//阴影偏移 ->x正 ->-x负 ，y同理
layer.shadowOffset = CGSizeMake(10, -10);
//阴影的圆角半径
layer.shadowRadius = 10;
}

#pragma mark - 图层内容和内容模式_01
- (void)图层内容和内容模式_01 {
CALayer *layer = [CALayer layer];
layer.frame = CGRectMake(20, 20, 100, 100);
layer.backgroundColor = [UIColor redColor].CGColor;
[self.view.layer addSublayer:layer];
//设置层内容
layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"logo"].CGImage);
//内容模式，类似于UIImageView的contentMode。默认是填充整个区域 kCAGravityResize
//kCAGravityResizeAspectFill 这个会向左边靠 贴到view的边边上
//kCAGravityResizeAspect 这个好像就是按比例了 反正是长方形
layer.contentsGravity = kCAGravityResizeAspect;
//设置控制器视图的背景图片 性能很高。 /
self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"logo"].CGImage);
}
@end
```
代码见：[demo](https://github.com/cheerszhou/BBKCode/blob/master/BBKCode/核心动画CoreAnimation之CALayer/核心动画CoreAnimation之CALayer/LayerTransformViewController.m)

## 5.CALayer的探究应用——进度条
demo的效果图
<center>![](http://cc.cocimg.com/api/uploads/20160318/1458282313872937.gif)</center>

### 常规做法
如上图所示，进度条并不是单纯的线性增长，在50%之前，每一次进度增加，进度条就会在y轴上面偏移一段距离，直到增长到一半进度的时候偏移位置达到顶点，然后随着进度继续增加，y轴的偏移越来越小，直到变回一条直线。从实现角度而言，使用CAShapeLayer然后在每次进度改变的时候更新其path值就能够实现。如果使用CAShapeLayer的方式，我们需要创建两个实例对象，一个放在下面作为进度条背景，另一个在上面随着进度改变而改变。图示如下：
<center>![](http://cc.cocimg.com/api/uploads/20160318/1458282391577497.png)</center>
每次进度发生改变的时候，我们都要根据当前进度计算出进度坐标位置，然后更新两个图层的path，代码如下：

```
- (void)updatePath
{
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint: CGPointMake(25, 150)];
    [path addLineToPoint: CGPointMake((CGRectGetWidth([UIScreen mainScreen].bounds) - 50) * _progress + 25, 150 + (25.f * (1 - fabs(_progress - 0.5) * 2)))];
    [path addLineToPoint: CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 25, 150)];
    self.background.path = path.CGPath;
    self.top.path = path.CGPath;
    self.top.strokeEnd = _progress;
}
```
事实上，使用这种方式实现进度效果的时候，进度会比直接在当前上下文绘制的响应上要慢上几帧，即是我们肉眼可以看到这种延时更新的效果，是不利于用户体验的。其次，我们需要额外创建一个背景图层，在内存上有了额外的花销。
### 自定义layer
这小节我们要通过自定义CALayer的子类来实现上面的进度条效果，我们需要对外开放progress属性。每次这个值发生改变的时候我们要调用[self setNeedsDisplay]来重新绘制进度条

```
@property(nonatomic, assign) CGFloat progress;
```
重写setter方法，检测进度值范围以及重新绘制进度条

```
- (void)setProgress: (CGFloat)progress
{
    _progress = MIN(1.f, MAX(0.f, progress));
    [self setNeedsDisplay];
}

```
重新回顾一下进度条，我们可以把进度条分成两条线，分别是绿色的已完成进度条和灰色的进度条。根据进度条的不同，分为<0.5,>0.5三种状态：

<center>![](http://cc.cocimg.com/api/uploads/20160318/1458282461809909.png)</center>

从上图可知，在进度达到一半的时候，我们的进度条在Y轴上的偏移量达到最大值。因此，我们应当定义一个最大偏移值MAX_OFFSET。

```
#define MAX_OFFSET 25.f
```
另一方面，当前进度条的y轴偏移量是根据进度按比例进行偏移的。在我们改变进度_progress的时候，重新绘制进度条。下面是绿色进度条的绘制

```
- (void)drawInContext: (CGContextRef)ctx
{
    CGFloat offsetX = _origin.x + MAX_LENGTH * _progress;
    CGFloat offsetY = _origin.y + _maxOffset * (1 - fabs((_progress - 0.5f) * 2));
 
 
    CGMutablePathRef mPath = CGPathCreateMutable();
    CGPathMoveToPoint(mPath, NULL, _origin.x, _origin.y);
    CGPathAddLineToPoint(mPath, NULL, offsetX, offsetY);
 
    CGContextAddPath(ctx, mPath);
    CGContextSetStrokeColorWithColor(ctx, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(ctx, 5.f);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextStrokePath(ctx);
 
    CGPathRelease(mPath);
}

```
ps: 这里存在一个很重要的问题，自定义的layer必须加在我们自定义的view上面，才能实现drawInContext：方法进行不断的重绘。关于coreGraphics相关方法的更多使用，请参考[iOS开发系列-打造自己的‘美图秀秀’](http://www.cnblogs.com/kenshincui/p/3959951.html)。

第二部分的灰色线条基于当前偏移的坐标为起点进行绘制，在这里有两个小陷阱：
•	不熟练的开发者很容易直接把绘制灰色线条的代码放在上面这段代码的后面。这样会导致灰色线条在绿色线条后面绘制而将绿色线条遮住了一部分使得绿色线条端末非圆形。

•	没有对_progress的值进行判断。当_progress为0时，上面的代码也会在线条左侧生成一个绿色小圆点，这是不准确的。

因此，我们在确定好当前进度对应的偏移坐标时，应该直接绘制灰色线条，再绘制绿色进度条。在绘制绿色线条前应当对_progress进行一次判断

```
- (void)drawInContext: (CGContextRef)ctx
{
    CGFloat offsetX = _origin.x + MAX_LENGTH * _progress;
    CGFloat offsetY = _origin.y + _maxOffset * (1 - fabs((_progress - 0.5f) * 2));
 
    CGMutablePathRef mPath = CGPathCreateMutable();
    CGPathMoveToPoint(mPath, NULL, offsetX, offsetY);
    CGPathAddLineToPoint(mPath, NULL, _origin.x + MAX_LENGTH, _origin.y);
 
    CGContextAddPath(ctx, mPath);
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(ctx, 5.f);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextStrokePath(ctx);
    CGPathRelease(mPath);
 
    if (_progress != 0.f) {
        mPath = CGPathCreateMutable();
        CGPathMoveToPoint(mPath, NULL, _origin.x, _origin.y);
        CGPathAddLineToPoint(mPath, NULL, offsetX, offsetY);
 
        CGContextAddPath(ctx, mPath);
        CGContextSetStrokeColorWithColor(ctx, [UIColor greenColor].CGColor);
        CGContextSetLineWidth(ctx, 5.f);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextStrokePath(ctx);
        CGPathRelease(mPath);
    }
}

```
这时候在controller里面加上一个UISlider拖拉来控制你的进度条进度，看看是不是想要的效果完成了。

### 扩展
上面我们在实现绘制的时候，对填充色彩颜色是写死的，这样不利于代码扩展。回顾CAShapeLayer，在继承CALayer的基础上添加了fillColor、strokeColor等类似属性，我们可以通过添加类似的成员属性来完成封装，这里我们需要为进度条添加两个属性，分别表示进度条颜色跟背景颜色

```
@property(nonatomic, assign) CGColorRef backgroundColor;
@property(nonatomic, assign) CGColorRef strokeColor;
```
我们在设置颜色的时候直接传入color.CGColor就可以完成赋值了，我们把上面的设置颜色代码分别改成下面所示后重新运行

```
CGContextSetStrokeColorWithColor(ctx, _backgroundColor);
CGContextSetStrokeColorWithColor(ctx, _strokeColor);
```
有的朋友们会发现一个坑爹的事情，崩溃了，出现了EXC_BAD_ACCESS错误——如果你使用系统提供的[UIColor xxxColor].CGColor，那么这里不会出问题。这是因为我们增加的两个属性为assign类型，在我们使用这个color的时候，它早就被释放了。由这里我们可以看到两件事情：

*	CAShapeLayer会对非对象且属于coreGraphics的属性进行桥接或者引用操作

*	[UIColor xxxColor]方法返回的对象应该是全局或者静态对象。为了节省内存消耗，应该是使用懒加载方式。有必要的情况下，可以不调用这些方法来实现优化内存的效果


因此，我们应该重写这两个属性的setter方法来实现引用（欢迎来到MRC）

```
- (void)setStrokeColor: (CGColorRef)strokeColor
{
    CGColorRelease(_strokeColor);
    _strokeColor = strokeColor;
    CGColorRetain(_strokeColor);
    [self setNeedsDisplay];
}
```
除此之外，CAShapeLayer还有一个有趣的属性<font color = red>***strokeEnd***</font>，这个属性决定了整个图层有多少部分需要被渲染的。想查看这个属性的看官们可以在最开始的常规代码中为layer设置这个属性，然后你会发现这时候不管我们的progress设置为多少，进度条的绿色部分总是等同于strokeEnd。效果如下图所示
<center>![](http://cc.cocimg.com/api/uploads/20160318/1458282871836899.png)</center>
可以看到，基于strokeEnd进行绘制的时候，界面的绘制难度更加复杂了。但是我们同样可以把这个拆分，分为两种情况
#### 1、strokeEnd>progress
这个情况对应图中上面两个图，当然，在progress=1跟progress=0的状态是一样的。可以看到，当progress不为零的时候，进度条分为三部分：

•	偏移点左侧的绿色线条
•	右侧多出的绿色线条
•	最后的灰色线条

交接点的y坐标应当是由strokeEnd超出progress的百分比部分除以当前右侧总长度占线条总长度的百分比，如下图所示
<center>![](http://cc.cocimg.com/api/uploads/20160318/1458282906156877.png)</center>
因此我们需要判断两个坐标点，其中偏移点按照上面代码一样根据progress得出，计算背景色和进度颜色交接点的代码如下：

```
CGFloat contactX = _origin.x + MAX_LENGTH * _strokeEnd;
CGFloat contactY = _origin.y + (offsetY - _origin.y) * ((1 - (_strokeEnd - _progress) / (1 - _progress)));
```
#### 2、strokeEnd<=progress
这时候就对应下面的两张图了，同样的，我们可以把进度条拆分成三部分：
•	最左侧的绿色进度条

•	处于进度条和偏移点中间的背景颜色条

•	右侧的背景颜色条

按照上面的图解方式进行分析，相当于把右侧的位置信息放到了左侧，我们可以轻易的得出颜色交接点坐标的计算方式

```
CGFloat contactX = _origin.x + MAX_LENGTH * _strokeEnd;
CGFloat contactY = (offsetY - _origin.y) * (_progress == 0 ?: _strokeEnd / _progress) + _origin.y;
```
有了上面的解析计算，drawInContext的代码如下

```
- (void)drawInContext: (CGContextRef)ctx
{
CGFloat offsetX = _origin.x + MAX_LENGTH * _progress;
CGFloat offsetY = _origin.y + _maxOffset * (1 - fabs(_progress - 0.5f) * 2);
CGFloat contactX = 25.f + MAX_LENGTH * _strokeEnd;
CGFloat contactY = _origin.y + _maxOffset * (1 - fabs(_strokeEnd - 0.5f) * 2);

CGRect textRect = CGRectOffset(_textRect, MAX_LENGTH * _progress, _maxOffset * (1 - fabs(_progress - 0.5f) * 2));
if (_report) {
_report((NSUInteger)(_progress * 100), textRect, _strokeColor);
}
CGMutablePathRef linePath = CGPathCreateMutable();

//绘制背景线条
if (_strokeEnd > _progress) {
CGFloat scale =  _progress == 0 ?: (1 - (_strokeEnd - _progress) / (1 - _progress));
contactY = _origin.y + (offsetY - _origin.y) * scale;
CGPathMoveToPoint(linePath, NULL, contactX, contactY);
} else {
CGFloat scale = _progress == 0 ?: _strokeEnd / _progress;
contactY = (offsetY - _origin.y) * scale + _origin.y;
CGPathMoveToPoint(linePath, NULL, contactX, contactY);
CGPathAddLineToPoint(linePath, NULL, offsetX, offsetY);
}
CGPathAddLineToPoint(linePath, NULL, _origin.x + MAX_LENGTH, _origin.y);
[self setPath: linePath onContext: ctx color: [UIColor colorWithRed: 204/255.f green: 204/255.f blue: 204/255.f alpha: 1.f].CGColor];

CGPathRelease(linePath);
linePath = CGPathCreateMutable();

//绘制进度线条
if (_progress != 0.f) {
CGPathMoveToPoint(linePath, NULL, _origin.x, _origin.y);
if (_strokeEnd > _progress) { CGPathAddLineToPoint(linePath, NULL, offsetX, offsetY); }
CGPathAddLineToPoint(linePath, NULL, contactX, contactY);
} else {
if (_strokeEnd != 1.f && _strokeEnd != 0.f) {
CGPathMoveToPoint(linePath, NULL, _origin.x, _origin.y);
CGPathAddLineToPoint(linePath, NULL, contactX, contactY);
}
}
[self setPath: linePath onContext: ctx color: [UIColor colorWithRed: 66/255.f green: 1.f blue: 66/255.f alpha: 1.f].CGColor];
CGPathRelease(linePath);
}
```

我们把添加CGPathRef以及设置线条颜色、大小等参数的代码封装成setPath: onContext: color方法，以此来减少代码量。coreAnimation以及coreGraphics作为最核心的框架之一，有很多值得我们去探索的特性，这些特性是怎么实现的对我们来说是一个迷，但是我们可以尝试去探索这些特性。
[demo代码](https://github.com/cheerszhou/BBKCode/tree/master/BBKCode/%E6%A0%B8%E5%BF%83%E5%8A%A8%E7%94%BBCoreAnimation%E4%B9%8BCALayer%E5%BA%94%E7%94%A8/%E6%A0%B8%E5%BF%83%E5%8A%A8%E7%94%BBCoreAnimation%E4%B9%8BCALayer%E5%BA%94%E7%94%A8)


## 6.使用CALayer的Mask实现注水动画效果
Core Animation一直是iOS比较有意思的一个主题，使用Core Animation可以实现非常平滑的炫酷动画。Core animtion的API是较高级的封装，使用便捷，使得我们免于自己使用OpenGL实现动画。
下面主要介绍如何使用CALayer的mask实现一个双向注水动画
<center>![](http://cc.cocimg.com/api/uploads/20150930/1443580919386081.gif)</center>

***了解CALayer的mask***
```
@property(strong) CALayer *mask;
```
mask实际上layer内容的一个遮罩。
如果我们把mask是透明的，实际看到的layer是完全透明的，也就是说只有mask的内容不透明的部分和layer叠加
<center>![](http://cc.cocimg.com/api/uploads/20150930/1443580967238392.jpg)</center>

实现思路：设计的思路参考[<font color = purple>基于Core Animation的KTV歌词视图的平滑实现</font>](http://www.iwangke.me/2014/10/06/how-to-implement-a-core-animation-based-60-fps-ktv-lyrics-view/),[Facebook Shimmer](https://github.com/facebook/Shimmer)

flow 在View上重叠放置两个UIImageView: grayHead&greenHead，默认greenHead会遮挡住grayHead。
为greenHead设置一个mask，这个mask不是普通的mask，它由两个subLayer:maskLayerUp maskLayerDown组成。
默认情况下，subLayer都显示在mask内容之外，此时mask实际上透明的，由此greenHead也是透明的。
现在我们希望greenHead从左上角和右下角慢慢显示内容，那么我们只需要从两个方向为greenHead填充内容就可以了.

创建mask

```
- (CALayer *)greenHeadMaskLayer
{
    CALayer *mask = [CALayer layer];
    mask.frame = self.greenHead.bounds;
     
    self.maskLayerUp = [CAShapeLayer layer];
    self.maskLayerUp.bounds = CGRectMake(0, 0, 30.0f, 30.0f);
    self.maskLayerUp.fillColor = [UIColor greenColor].CGColor; // Any color but clear will be OK
    self.maskLayerUp.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(15.0f, 15.0f)
                                                           radius:15.0f
                                                       startAngle:0
                                                         endAngle:2*M_PI
                                                        clockwise:YES].CGPath;
    self.maskLayerUp.opacity = 0.8f;
    self.maskLayerUp.position = CGPointMake(-5.0f, -5.0f);
    [mask addSublayer:self.maskLayerUp];
     
    self.maskLayerDown = [CAShapeLayer layer];
    self.maskLayerDown.bounds = CGRectMake(0, 0, 30.0f, 30.0f);
    self.maskLayerDown.fillColor = [UIColor greenColor].CGColor; // Any color but clear will be OK
    self.maskLayerDown.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(15.0f, 15.0f)
                                                             radius:15.0f
                                                         startAngle:0
                                                           endAngle:2*M_PI
                                                          clockwise:YES].CGPath;
    self.maskLayerDown.position = CGPointMake(35.0f, 35.0f);
    [mask addSublayer:self.maskLayerDown];
    return mask;
}

```
做动画

```
- (void)startGreenHeadAnimation
{
    CABasicAnimation *downAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    downAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(-5.0f, -5.0f)];
    downAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(10.0f, 10.0f)];
    downAnimation.duration = duration;
    [self.maskLayerUp addAnimation:downAnimation forKey:@"downAnimation"];
     
    CABasicAnimation *upAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    upAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(35.0f, 35.0f)];
    upAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(20.0f, 20.0f)];
    upAnimation.duration = duration;
    [self.maskLayerDown addAnimation:upAnimation forKey:@"upAnimation"];
}

```
__小结__
CALayer提供另外一种操作UI的手段，虽然它提供的API比UIView较底层，但它能提供更加丰富的功能和更高的性能(CALayer的动画是在专门的线程渲染的)。涉及到复杂且性能要求高的UI界面，CALayer的作用就比较明显了，比如AsyncDisplayKit。
_通过本片文章，我们其实也能看出CALayer的一个用处，通常我们处理圆角时会直接去修改CALayer的cornerRadius，但这种做法性能比较差，尤其是放在列表里的时候，现在我们有了mask，这样我们可以直接改变layer的mask，而不会影响到图形渲染的性能。_
[代码](https://github.com/cheerszhou/BBKCode/tree/master/BBKCode/%E6%A0%B8%E5%BF%83%E5%8A%A8%E7%94%BB%E4%B9%8BCALayer%E7%9A%84Mask%E5%AE%9E%E7%8E%B0%E6%B3%A8%E6%B0%B4%E5%8A%A8%E7%94%BB%E6%95%88%E6%9E%9C)

## 7.为啥有了CALayer了还要UIView
UIView继承自UIResponder，主要特点是可以响应触摸事件。而CALayer实际的图层内容管理。大家干的的事情不一样，是两个东西，大家的存在互不影响，理所当然。
__UILayer__
假设有一个UIView和CALayer集合体UILayer这个UILayer是一个全能的Layer，可以负责管理显示内容，也能处理触摸事件
但由于iOS系统的更新，所以你要不断修改维护UILayer，比如iOS3.2版本增加手势识别、iOS4引入了Block语法、iOS6增加AutoLayout特性、iOS7的UI得改头换面，每次都要打开巨长的UILayer从头改到脚。这样的维护成本太高了。
__分析__
所以，在这份理所当然的SDK的背后，蕴藏着大牛门几十年的设计智慧。当中应该能够看到很多门道。这次就UIView和CALayer来分析，就可以得出一些东西。

* 机制与策略分离
* 更多的不可变
* 各司其职
* 漏的更少

#### 机制与策略分离
Unix内核设计的一个主要思想是——提供(Mechanism)机制而不是策略(Policy)。编程问题都可以抽离出机制和策略部分。机制一旦实现，就会很少更改，但策略会经常得到优化。例如原子可以看做是机制，而各种原子的组成就是一种策略。CALayer也可以看做是一种机制，提供图层绘制，你们可以翻开CALayer的头文件看看，基本上是没怎么变过的，而UIView可以看做是策略，变动很多。越是底层，越是机制，越是机制就越是稳定。机制与策略分离，可以使得需要修改的代码更少，特别是底层代码，这样可以提高系统的稳定性。
#### 更多的不可变
稳定给你的是什么感觉？坚固？不可形变？稳定其实就是不可变。一个系统不可变的东西越多，越是稳定。所以机制恰是满足这个不可变的因素的。构建一个系统有一个指导思想就是尽量抽取不可变的东西和可变的东西分离。水是成不了万丈高楼的，坚固的混凝土才可以。更少的修改，意味着更少的bug的几率。
#### 各司其职
即使能力再大也不能把说有事情都干了，万一哪一天不行了呢，那就是突然什么都不能干了。所以仅仅是基于分散风险原则也不应该出现全能类。各司其职，相互合作，把可控粒度降到最低，这样也可以是系统更稳定，更易修改。
#### 漏的更少
接口应该面向大众的，按照八二原则，其实20%的接口就可以满足80%的需求，剩下的80%应该隐藏在背后。因为漏的少总是安全的，不是吗。剩下的80%专家接口可以隐藏与深层次。比如UIView遮蔽了大部分的CALayer接口，抽取构造出更易用的frame和动画实现，这样上手更容易。



## 8.iOS开发之让你的应用“动”起来
### 概览
在iOS中随处都可以看到绚丽的动画效果，实现这些动画的过程并不复杂，今天将带大家一窥iOS动画全貌。在这里你可以看到iOS中如何使用图层精简非交互式绘图，如何通过核心动画创建基础动画、关键帧动画、动画组、转场动画，如何通过UIView的装饰方法对这些动画操作进行简化等。在今天的文章里您可以看到动画操作在iOS中是如何简单和高效，很多原来想做但是苦于没有思路的动画在iOS中将变得越发简单
### CALayer
#### 一、CALayer简介
在介绍动画操作之前我们必须先来了解一个动画中常用的对象CALayer。CALayer包含在QuartzCore框架中，这是一个跨平台的框架，既可以用在iOS中又可以用在Mac OS X中。在使用Core Animation开发动画的本质就是将CALayer中的内容转化为位图从而供硬件操作，所以要熟练掌握动画操作必须先来熟悉CALayer。

当利用drawRect:方法绘图的本质就是绘制到了UIView的layer（属性）中。但是在Core Animation中我们操作更多的则不再是UIView而是直接面对CALayer。下图描绘了CALayer和UIView的关系，在UIView中有一个layer属性作为根图层，根图层上可以放其他子图层，在UIView中所有能够看到的内容都包含在layer中：见图4-1
#### 二、CALayer常用属性
在iOS中CALayer的设计主要是了为了内容展示和动画操作，CALayer本身并不包含在UIKit中，它不能响应事件。由于CALayer在设计之初就考虑它的动画操作功能，CALayer很多属性在修改时都能形成动画效果，这种属性称为“隐式动画属性”。但是对于UIView的根图层而言属性的修改并不形成动画效果，因为很多情况下根图层更多的充当容器的做用，如果它的属性变动形成动画效果会直接影响子图层。另外，UIView的根图层创建工作完全由iOS负责完成，无法重新创建，但是可以往根图层中添加子图层或移除子图层。见图4-2

__注意__

* 隐式属性动画的本质是这些属性的变动默认隐含了CABasicAnimation动画实现，详情大家可以参照Xcode帮助文档中“Animatable Properties”一节。
* 在CALayer中很少使用frame属性，因为frame本身不支持动画效果，通常使用bounds和position代替。
* CALayer中透明度使用opacity表示而不是alpha；中心点使用position表示而不是center。
* anchorPoint属性是图层的锚点，范围在（0~1,0~1）表示在x、y轴的比例，这个点永远可以同position（中心点）重合，当图层中心点固定后，调整anchorPoint即可达到调整图层显示位置的作用（因为它永远和position重合）
* 为了进一步说明anchorPoint的作用，假设有一个层大小100*100，现在中心点位置（50,50），由此可以得出frame（0,0,100,100）。上面说过anchorPoint默认为（0.5,0.5），同中心点position重合，此时使用图形描述如图1；当修改anchorPoint为（0,0），此时锚点处于图层左上角，但是中心点poition并不会改变，因此图层会向右下角移动，如图2；然后修改anchorPoint为（1,1,），position还是保持位置不变，锚点处于图层右下角，此时图层如图3。
* <center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022101632_1.png)</center>

下面通过一个简单的例子演示一下上面几个属性，程序初始化阶段我们定义一个正方形，但是圆角路径调整为正方形边长的一般，使其看起来是一个圆形，在点击屏幕的时候修改图层的属性形成动画效果（注意在程序中没有直接修改UIView的layer属性，因为根图层无法形成动画效果）：

```
//
//  CALayerDefaultAnimationVC.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/5/31.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "CALayerDefaultAnimationVC.h"
#define kWidth 50.0

@interface CALayerDefaultAnimationVC ()
@property (nonatomic, strong) CALayer *thisLayer;
@end

@implementation CALayerDefaultAnimationVC

- (void)viewDidLoad {
self.title = @"CALayer隐式动画";
[super viewDidLoad];
[self drawMyLayer];
}

#pragma mark - 绘制图层
- (void)drawMyLayer {
CGSize size = [UIScreen mainScreen].bounds.size;
//获取根图层
CALayer* layer = [[CALayer alloc]init];
//设置背景颜色，由于QuartzCore是跨平台框架，无法直接使用UIColor
layer.backgroundColor = [UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0].CGColor;
//设置中心点
layer.position = CGPointMake(size.width/2, size.height/2 );
//设置大小
layer.bounds = CGRectMake(0, 0, kWidth, kWidth);
//设置圆角，当圆角半径等于矩形的一半时看起来就是一个圆形
layer.cornerRadius = kWidth/2;
//设置阴影
layer.shadowColor = [UIColor grayColor].CGColor;
layer.shadowOffset = CGSizeMake(2, 2);
layer.shadowOpacity = 0.9f;
//设置锚点
//layer.anchorPoint =  CGPointMake(0, 0);
//layer.anchorPoint = CGPointMake(1, 1);
[self.view.layer addSublayer:layer];
self.thisLayer = layer;
}

#pragma mark - 点击放大
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
UITouch *touch = [touches anyObject];
CGPoint position = [touch locationInView:self.view];
CALayer* layer = [self.view.layer.sublayers lastObject];
CGFloat width = layer.bounds.size.width;
if (width == kWidth) {
width = 4*kWidth;
layer.backgroundColor = [UIColor colorWithRed:1. green:0.1 blue:0.7 alpha:1.0].CGColor;
}else {
width = kWidth;
layer.backgroundColor = [UIColor colorWithRed:0 green:146/255. blue:1.0 alpha:1.0].CGColor;
}
layer.position = position;
layer.bounds = CGRectMake(0, 0, width, width);
NSLog(@"point:%@",NSStringFromCGPoint(position));
}

- (void)didReceiveMemoryWarning {
[super didReceiveMemoryWarning];
// Dispose of any resources that can be recreated.
}



@end
```
运行效果
![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022102112_1.gif)
#### 三、CALayer绘图
当调用UIView的drawRect:方法绘制图形、图像，这种方式本质还是在图层中绘制，但是这里会着重介绍一下如何直接在图层中绘图。在图层中绘图的方式跟原来基本没有区别，只是drawRect:方法是由UIKit组件进行调用，因此里面可以使用一些UIKit封装的方法进行绘图，而直接绘制到图层的方法由于并非UIKit直接调用因此只能用原生的Core Graphics方法绘制。
图层绘图有两种方法，不管使用哪种方法绘制完必须调用图层的setNeedDisplay方法（注意是图层的方法，不是UIView的方法，前面我们介绍过UIView也有此方法）

* 通过图层代理drawLayer:inContext:方法绘制
* 通过自定义图层drawInContext:方法

##### 通过代理方法绘制图
过代理方法进行图层绘图只要指定图层的代理，然后在代理对象中重写-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx方法即可。需要注意这个方法虽然是代理方法但是不用手动实现CALayerDelegate，因为CALayer定义中给NSObject做了分类扩展，所有的NSObject都包含这个方法。另外设置完代理后必须要调用图层的setNeedDisplay方法，否则绘制的内容无法显示。
下面的代码演示了在一个自定义图层绘制一张图像并将图像设置成圆形，这种效果在很多应用中很常见，如最新版的手机QQ头像就是这种效果：

```
//
//  CALayerDrawInRect.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/5/31.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "CALayerDrawInRect.h"
#import <QuartzCore/QuartzCore.h>
#define PHOTO_HEIGHT 150

@interface CALayerDrawInRect ()<CALayerDelegate>
@property (nonatomic, strong) CALayer *myLayer;
@end

@implementation CALayerDrawInRect

- (void)viewDidLoad {
[super viewDidLoad];
self.title = @"CALayer绘图";

[self base];
}

- (void)base {
//自定义图层
CALayer *layer = [[CALayer alloc]init];
layer.bounds = CGRectMake(0, 0, PHOTO_HEIGHT, PHOTO_HEIGHT);
layer.position = CGPointMake(160, 200);
layer.cornerRadius = PHOTO_HEIGHT/2.0;
//注意仅仅设置圆角，对于图形而言可以正常显示，但是对于图层中绘制的图片无法正确显示
//如果想要正确显示则必须设置masksToBounds=YES，剪切子图层
layer.masksToBounds = YES;
//阴影效果无法和masksToBounds同时使用，因为masksToBounds的目的就是剪切外边框，
//而阴影效果刚好在外边框

//layer.shadowColor=[UIColor grayColor].CGColor;
//layer.shadowOffset=CGSizeMake(2, 2);
//layer.shadowOpacity=1;

//设置边框
layer.borderColor = [UIColor cyanColor].CGColor;
layer.borderWidth = 2;
//设置图层代理
layer.delegate = self;
//设置图层到根图层
[self.view.layer addSublayer:layer];
//调用图层setNeedDisplay,否则代理方法不会被调用
[layer setNeedsDisplay];
}

- (void)dealloc {
self.myLayer.delegate = nil;
NSLog(@"I'm Clearing");
}
#pragma mark - 绘制图形、图像到图层，注意参数中的ctx是图层的图形上下文，其中绘图位置也是相对图层而言的
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
CGContextSaveGState(ctx);
//解决图形上文形变，图片倒立的问题

CGContextScaleCTM(ctx, 1, -1);
CGContextTranslateCTM(ctx, 0, -PHOTO_HEIGHT);
UIImage* image = [UIImage imageNamed:@"girls.jpg"];
CGContextDrawImage(ctx, CGRectMake(0, 0, PHOTO_HEIGHT, PHOTO_HEIGHT), image.CGImage);
CGContextRestoreGState(ctx);
}


@end

```

运行效果
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022102210_1.jpg)</center>

使用代理方法绘制图形、图像时在drawLayer:inContext:方法中可以通过事件参数获得绘制的图层和图形上下文。在这个方法中绘图时所有的位置都是相对于图层而言的，图形上下文指的也是当前图层的图形上下文。
需要注意的是上面代码中绘制图片圆形裁切效果时如果不设置masksToBounds是无法显示圆形，但是对于其他图形却没有这个限制。原因就是当绘制一张图片到图层上的时候会重新创建一个图层添加到当前图层，这样一来如果设置了圆角之后虽然底图层有圆角效果，但是子图层还是矩形，只有设置了masksToBounds为YES让子图层按底图层剪切才能显示圆角效果。同样的，有些朋友经常在网上提问说为什么使用UIImageView的layer设置圆角后图片无法显示圆角，只有设置masksToBounds才能出现效果，也是类似的问题。
**扩展1--带阴影效果的圆形图片裁剪**
如果设置了masksToBounds=YES之后确实可以显示图片圆角效果，但遗憾的是设置了这个属性之后就无法设置阴影效果。因为masksToBounds=YES就意味着外边框不能显示，而阴影恰恰作为外边框绘制的，这样两个设置就产生了矛盾。要解决这个问题不妨换个思路:使用两个大小一样的图层，下面的图层负责绘制阴影，上面的图层用来显示图片。

```
//
//  CALayerDrawInRect.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/5/31.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "CALayerDrawInRect.h"
#import <QuartzCore/QuartzCore.h>
#define PHOTO_HEIGHT 150

@interface CALayerDrawInRect ()<CALayerDelegate>
@property (nonatomic, strong) CALayer *myLayer;
@end

@implementation CALayerDrawInRect

- (void)viewDidLoad {
[super viewDidLoad];
self.title = @"CALayer绘图";

[self extension_1];
}

- (void)extension_1 {
CGPoint position = CGPointMake(160, 200);
CGRect bounds = CGRectMake(0, 0, PHOTO_HEIGHT, PHOTO_HEIGHT);
CGFloat cornerRadius = PHOTO_HEIGHT/2;
CGFloat borderWidth = 2;

//阴影图层
CALayer* layerShadow = [[CALayer alloc]init];
layerShadow.bounds = bounds;
layerShadow.position = position;
layerShadow.cornerRadius = cornerRadius;
layerShadow.shadowColor = [UIColor grayColor].CGColor;
layerShadow.shadowOffset = CGSizeMake(2, 1);
layerShadow.borderColor = [UIColor grayColor].CGColor;
layerShadow.shadowOpacity = 1;
layerShadow.backgroundColor = [UIColor cyanColor].CGColor;
layerShadow.borderWidth = borderWidth;
[self.view.layer addSublayer:layerShadow];

//容器图层
CALayer* layer = [[CALayer alloc]init];
layer.bounds = bounds;
layer.position = position;
layer.backgroundColor = [UIColor redColor].CGColor;
layer.cornerRadius = cornerRadius;
layer.masksToBounds = YES;
layer.borderWidth = borderWidth;
layer.borderColor = [UIColor whiteColor].CGColor;

//设置图层代理
layer.delegate = self;
[self.view.layer addSublayer:layer];
self.myLayer = layer;
//调用图层setNeedDisplay，否则代理不会被调用
[layer setNeedsDisplay];
}

- (void)base {
//自定义图层
CALayer *layer = [[CALayer alloc]init];
layer.bounds = CGRectMake(0, 0, PHOTO_HEIGHT, PHOTO_HEIGHT);
layer.position = CGPointMake(160, 200);
layer.cornerRadius = PHOTO_HEIGHT/2.0;
//注意仅仅设置圆角，对于图形而言可以正常显示，但是对于图层中绘制的图片无法正确显示
//如果想要正确显示则必须设置masksToBounds=YES，剪切子图层
layer.masksToBounds = YES;
//阴影效果无法和masksToBounds同时使用，因为masksToBounds的目的就是剪切外边框，
//而阴影效果刚好在外边框

//layer.shadowColor=[UIColor grayColor].CGColor;
//layer.shadowOffset=CGSizeMake(2, 2);
//layer.shadowOpacity=1;

//设置边框
layer.borderColor = [UIColor cyanColor].CGColor;
layer.borderWidth = 2;
//设置图层代理
layer.delegate = self;
//设置图层到根图层
[self.view.layer addSublayer:layer];
//调用图层setNeedDisplay,否则代理方法不会被调用
[layer setNeedsDisplay];
}

- (void)dealloc {
self.myLayer.delegate = nil;
NSLog(@"I'm Clearing");
}
#pragma mark - 绘制图形、图像到图层，注意参数中的ctx是图层的图形上下文，其中绘图位置也是相对图层而言的
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
CGContextSaveGState(ctx);
//解决图形上文形变，图片倒立的问题

CGContextScaleCTM(ctx, 1, -1);
CGContextTranslateCTM(ctx, 0, -PHOTO_HEIGHT);
UIImage* image = [UIImage imageNamed:@"girls.jpg"];
CGContextDrawImage(ctx, CGRectMake(0, 0, PHOTO_HEIGHT, PHOTO_HEIGHT), image.CGImage);
CGContextRestoreGState(ctx);
}


@end

```


运行效果
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022102309_1.jpg)</center>

**扩展2--图层的形变**
从上面代码中大家不难发现使用Core Graphics绘制图片时会倒立显示，对图层的图形上下文进行了反转。在前一篇文章中也采用了类似的方法去解决这个问题，但是在那篇文章中也提到过如果直接让图像沿着x轴旋转180度同样可以达到正确显示的目的，只是当时的旋转靠图形上下文还无法绕x轴旋转。今天学习了图层之后，其实可以控制图层直接旋转而不用借助于图形上下文的形变操作，而且这么操作起来会更加简单和直观。对于上面的程序，只需要设置图层的transform属性即可。需要注意的是transform是CATransform3D类型，形变可以在三个维度上进行，使用方法和前面介绍的二维形变是类似的，而且都有对应的形变设置方法（如：CATransform3DMakeTranslation()、CATransform3DMakeScale()、CATransform3DMakeRotation()）。下面的代码通过CATransform3DMakeRotation()方法在x轴旋转180度解决倒立问题：

```
//
//  CALayerDrawInRect.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/5/31.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "CALayerDrawInRect.h"
#import <QuartzCore/QuartzCore.h>
#define PHOTO_HEIGHT 150

@interface CALayerDrawInRect ()<CALayerDelegate>
@property (nonatomic, strong) CALayer *myLayer;
@end

@implementation CALayerDrawInRect

- (void)viewDidLoad {
[super viewDidLoad];
self.title = @"CALayer绘图";

[self extension_2];
}

- (void)extension_2 {

CGPoint position = CGPointMake(160, 200);
CGRect bounds = CGRectMake(0, 0, PHOTO_HEIGHT, PHOTO_HEIGHT);
CGFloat cornerRadius = PHOTO_HEIGHT/2;
CGFloat borderWidth = 2;

//阴影图层
CALayer* layerShadow = [[CALayer alloc]init];
layerShadow.bounds = bounds;
layerShadow.position = position;
layerShadow.cornerRadius = cornerRadius;
layerShadow.shadowColor = [UIColor grayColor].CGColor;
layerShadow.shadowOffset = CGSizeMake(2, 1);
layerShadow.borderColor = [UIColor grayColor].CGColor;
layerShadow.shadowOpacity = 1;
layerShadow.backgroundColor = [UIColor cyanColor].CGColor;
layerShadow.borderWidth = borderWidth;
[self.view.layer addSublayer:layerShadow];

//容器图层
CALayer *layer = [[CALayer alloc]    init];
layer.bounds = bounds;
layer.position = position;
layer.backgroundColor = [UIColor redColor].CGColor;
layer.cornerRadius = cornerRadius;
layer.masksToBounds = YES;
layer.borderColor = [UIColor whiteColor].CGColor;
//设置内容(注意转换成CGImage）
UIImage* iamge = [UIImage imageNamed:@"girls.jpg"];
[layer setContents:(id)iamge.CGImage];

//使用变换CATransform3D
[layer setValue:@(M_PI) forKey:@"transform.rotation.x"];
[self.view.layer addSublayer:layer];

}
- (void)extension_1 {
CGPoint position = CGPointMake(160, 200);
CGRect bounds = CGRectMake(0, 0, PHOTO_HEIGHT, PHOTO_HEIGHT);
CGFloat cornerRadius = PHOTO_HEIGHT/2;
CGFloat borderWidth = 2;

//阴影图层
CALayer* layerShadow = [[CALayer alloc]init];
layerShadow.bounds = bounds;
layerShadow.position = position;
layerShadow.cornerRadius = cornerRadius;
layerShadow.shadowColor = [UIColor grayColor].CGColor;
layerShadow.shadowOffset = CGSizeMake(2, 1);
layerShadow.borderColor = [UIColor grayColor].CGColor;
layerShadow.shadowOpacity = 1;
layerShadow.backgroundColor = [UIColor cyanColor].CGColor;
layerShadow.borderWidth = borderWidth;
[self.view.layer addSublayer:layerShadow];

//容器图层
CALayer* layer = [[CALayer alloc]init];
layer.bounds = bounds;
layer.position = position;
layer.backgroundColor = [UIColor redColor].CGColor;
layer.cornerRadius = cornerRadius;
layer.masksToBounds = YES;
layer.borderWidth = borderWidth;
layer.borderColor = [UIColor whiteColor].CGColor;

//设置图层代理
layer.delegate = self;
[self.view.layer addSublayer:layer];
self.myLayer = layer;
//调用图层setNeedDisplay，否则代理不会被调用
[layer setNeedsDisplay];
}

- (void)base {
//自定义图层
CALayer *layer = [[CALayer alloc]init];
layer.bounds = CGRectMake(0, 0, PHOTO_HEIGHT, PHOTO_HEIGHT);
layer.position = CGPointMake(160, 200);
layer.cornerRadius = PHOTO_HEIGHT/2.0;
//注意仅仅设置圆角，对于图形而言可以正常显示，但是对于图层中绘制的图片无法正确显示
//如果想要正确显示则必须设置masksToBounds=YES，剪切子图层
layer.masksToBounds = YES;
//阴影效果无法和masksToBounds同时使用，因为masksToBounds的目的就是剪切外边框，
//而阴影效果刚好在外边框

//layer.shadowColor=[UIColor grayColor].CGColor;
//layer.shadowOffset=CGSizeMake(2, 2);
//layer.shadowOpacity=1;

//设置边框
layer.borderColor = [UIColor cyanColor].CGColor;
layer.borderWidth = 2;
//设置图层代理
layer.delegate = self;
//设置图层到根图层
[self.view.layer addSublayer:layer];
//调用图层setNeedDisplay,否则代理方法不会被调用
[layer setNeedsDisplay];
}

- (void)dealloc {
self.myLayer.delegate = nil;
NSLog(@"I'm Clearing");
}
#pragma mark - 绘制图形、图像到图层，注意参数中的ctx是图层的图形上下文，其中绘图位置也是相对图层而言的
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
UIImage* image = [UIImage imageNamed:@"girls.jpg"];
CGContextDrawImage(ctx, CGRectMake(0, 0, PHOTO_HEIGHT, PHOTO_HEIGHT), image.CGImage);

}


@end

```
事实上如果仅仅就显示一张图片在图层中当然没有必要那么麻烦，直接设置图层contents就可以了，不牵涉到绘图也就没有倒立的问题了。

```
//
//  图层内容设置
//  CALayer
//
//  Created by Kenshin Cui on 14-3-22.
//  Copyright (c) 2014年 Kenshin Cui. All rights reserved.
//
 
#import "KCMainViewController.h"
#define PHOTO_HEIGHT 150
 
@interface KCMainViewController ()
 
@end
 
@implementation KCMainViewController
 
- (void)viewDidLoad {
    [super viewDidLoad];
    CGPoint position= CGPointMake(160, 200);
    CGRect bounds=CGRectMake(0, 0, PHOTO_HEIGHT, PHOTO_HEIGHT);
    CGFloat cornerRadius=PHOTO_HEIGHT/2;
    CGFloat borderWidth=2;
     
    //阴影图层
    CALayer *layerShadow=[[CALayer alloc]init];
    layerShadow.bounds=bounds;
    layerShadow.position=position;
    layerShadow.cornerRadius=cornerRadius;
    layerShadow.shadowColor=[UIColor grayColor].CGColor;
    layerShadow.shadowOffset=CGSizeMake(2, 1);
    layerShadow.shadowOpacity=1;
    layerShadow.borderColor=[UIColor whiteColor].CGColor;
    layerShadow.borderWidth=borderWidth;
    [self.view.layer addSublayer:layerShadow];
     
    //容器图层
    CALayer *layer=[[CALayer alloc]init];
    layer.bounds=bounds;
    layer.position=position;
    layer.backgroundColor=[UIColor redColor].CGColor;
    layer.cornerRadius=cornerRadius;
    layer.masksToBounds=YES;
    layer.borderColor=[UIColor whiteColor].CGColor;
    layer.borderWidth=borderWidth;
    //设置内容（注意这里一定要转换为CGImage）
    UIImage *image=[UIImage imageNamed:@"photo.jpg"];
//    layer.contents=(id)image.CGImage;
    [layer setContents:(id)image.CGImage];
     
    //添加图层到根图层
    [self.view.layer addSublayer:layer];
}
 
@end

```
既然如此为什么还大费周章的说形变呢，因为形变对于动画有特殊的意义。在动画开发中形变往往不是直接设置transform，而是通过keyPath进行设置。这种方法设置形变的本质和前面没有区别，只是利用了KVC可以动态修改其属性值而已，但是这种方式在动画中确实很常用的，因为它可以很方便的将几种形变组合到一起使用。同样是解决动画旋转问题，只要将前面的旋转代码改为下面的代码即可：
`[layer setValue:@M_PI forKeyPath:@"transform.rotation.x"];`
当然，通过key path设置形变参数就需要了解有哪些key path可以设置，这里就不再一一列举，大家可以参照Xcode帮助文档中“CATransform3D Key Paths”一节，里面描述的很详细。

##### 使用自定义图层绘图
在自定义图层中绘图时只要自己编写一个类继承于CALayer然后在drawInContext:中绘图即可。同前面在代理方法绘图一样，要显示图层中绘制的内容也要调用图层的setNeedDisplay方法，否则drawInContext方法将不会调用。
前面的文章中曾经说过，在使用Quartz 2D在UIView中绘制图形的本质也是绘制到图层中，为了说明这个问题下面演示自定义图层绘图时没有直接在视图控制器中调用自定义图层，而是在一个UIView将自定义图层添加到UIView的根图层中（例子中的UIView跟自定义图层绘图没有直接关系）。从下面的代码中可以看到：UIView在显示时其根图层会自动创建一个CGContextRef（CALayer本质使用的是位图上下文），同时调用图层代理（UIView创建图层会自动设置图层代理为其自身）的draw: inContext:方法并将图形上下文作为参数传递给这个方法。而在UIView的draw:inContext:方法中会调用其drawRect:方法，在drawRect:方法中使用UIGraphicsGetCurrentContext()方法得到的上下文正是前面创建的上下文。

*ZXCALayer.m*

```
//
//  ZXCALayer.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ZXCALayer.h"

@implementation ZXCALayer
- (void)drawInContext:(CGContextRef)ctx {
CGContextSetRGBFillColor(ctx, 135.0/255.0, 232.0/255.0, 84.0/255.0, 1);
CGContextSetRGBStrokeColor(ctx, 135.0/255.0, 232.0/255.0, 84.0/255.0, 1);

//star drawing
CGContextMoveToPoint(ctx, 94.5, 33.5);

CGContextAddLineToPoint(ctx,104.02, 47.39);
CGContextAddLineToPoint(ctx,120.18, 52.16);
CGContextAddLineToPoint(ctx,109.91, 65.51);
CGContextAddLineToPoint(ctx,110.37, 82.34);
CGContextAddLineToPoint(ctx,94.5, 76.7);
CGContextAddLineToPoint(ctx,78.63, 82.34);
CGContextAddLineToPoint(ctx,79.09, 65.51);
CGContextAddLineToPoint(ctx,68.82, 52.16);
CGContextAddLineToPoint(ctx,84.98, 47.39);
CGContextClosePath(ctx);

CGContextDrawPath(ctx, kCGPathFillStroke);
}
@end

```
*ZXView.m*

```
//
//  ZXView.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "ZXView.h"
#import "ZXCALayer.h"

@implementation ZXView
- (instancetype)initWithFrame:(CGRect)frame {
if (self=[super initWithFrame:frame]) {
ZXCALayer* layer = [[ZXCALayer alloc]init];
layer.bounds = CGRectMake(0, 0, 185, 185);
layer.position = CGPointMake(160, 284);
layer.backgroundColor = [UIColor colorWithRed:0 green:146/255.0 blue:1.0 alpha:1.0].CGColor;

//显示图层
[layer setNeedsDisplay];
[self.layer addSublayer:layer];
}
return self;
}

- (void)drawRect:(CGRect)rect {
[super drawRect:rect];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
[super drawLayer:layer inContext:ctx];
}

@end

```
*CustomLayerDrawInRectVC.m*

```
//
//  CustomLayerDrawInRectVC.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "CustomLayerDrawInRectVC.h"
#import "ZXView.h"
@interface CustomLayerDrawInRectVC ()

@end

@implementation CustomLayerDrawInRectVC

- (void)viewDidLoad {
[super viewDidLoad];
// Do any additional setup after loading the view.
ZXView* view = [[ZXView alloc]initWithFrame:[UIScreen mainScreen].bounds];
view.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249/255.0 alpha:1];
[self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
[super didReceiveMemoryWarning];
// Dispose of any resources that can be recreated.
}



@end
```
运行效果
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022102740_1.jpg)</center>

### Core Animation
大家都知道在iOS中实现一个动画相当简单，只要调用UIView的块代码即可实现一个动画效果，这在其他系统开发中基本不可能实现。下面通过一个简单的UIView进行一个图片放大动画效果演示：

```
- (void)viewDidLoad {
    [super viewDidLoad];
     
    UIImage *image=[UIImage imageNamed:@"open2.png"];
    UIImageView *imageView=[[UIImageView alloc]init];
    imageView.image=image;
    imageView.frame=CGRectMake(120, 140, 80, 80);
    [self.view addSubview:imageView];
     
    //两秒后开始一个持续一分钟的动画
    [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        imageView.frame=CGRectMake(80, 100, 160, 160);
    } completion:nil];
}

```
使用上面UIView封装的方法进行动画设置固然十分方便，但是具体动画如何实现我们是不清楚的，而且上面的代码还有一些问题是无法解决的，例如：*如何控制动画的暂停？如何进行动画的组合？*

这里就需要了解iOS的核心动画Core Animation（包含在Quartz Core框架中）。在iOS中核心动画分为几类：

1.	基础动画、
2. 关键帧动画、
3. 动画组、
4. 转场动画。各个类的关系大致如下：

<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022102913_1.png)</center>
**CAAnimation:**核心动画的基础类，不能直接使用，负责动画运行时间、速度的控制，本身实现了CAMediaTiming协议。

**CAPropertyAnimation:**属性动画的基类（通过属性进行动画设置，注意是可动画属性），不能直接使用。

**CAAnimationGroup：**动画组，动画组是一种组合模式设计，可以通过组合动画组来进行所有动画行为的统一控制，组中的所有动画效果可以并发执行。

**CATransition:**转场动画，通过滤镜进行动画效果设置。

**CABasicAnimation:**基础动画，通过属性修改进行动画参数控制，只有初始状态和结束状态。

**CAKeyframeAnimation:**关键帧动画，同样是通过属性进行动画参数控制，但是同基础动画不同的是它可以有多个状态控制。

基础动画、关键帧动画都属于属性动画，就是通过修改属性值产生动画效果，开发人员只需要设置初始值和结束值，中间的过程动画（又叫“补间动画”）由系统自动计算产生。和基础动画不同的是关键帧动画可以设置多个属性值，每两个属性中间的补间动画由系统自动完成，因此从这个角度而言基础动画又可以看成是有两个关键帧的关键帧动画。

#### 基础动画
在开发过程中很多情况下通过基础动画就可以满足开发需求，前面例子中使用的UIView代码块进行图像放大缩小的演示动画也是基础动画（在iOS7中UIView也对关键帧动画进行了封装），只是UIView装饰方法隐藏了更多的细节。如果不使用UIView封装的方法，动画创建一般分为以下几步：

1.	初始化动画并设置动画属性
2. 设置动画属性初始值（可以省略）、结束值以及其他动画属性
3. 给图层添加动画
下面以一个移动动画为例进行演示，在这个例子中点击屏幕哪个位置落花将飞向哪里

```
#import "KCMainViewController.h"
@interface KCMainViewController (){
    CALayer *_layer;
}
@end
@implementation KCMainViewController
- (void)viewDidLoad {
    [super viewDidLoad];
     
    //设置背景(注意这个图片其实在根图层)
    UIImage *backgroundImage=[UIImage imageNamed:@"background.jpg"];
    self.view.backgroundColor=[UIColor colorWithPatternImage:backgroundImage];
     
    //自定义一个图层
    _layer=[[CALayer alloc]init];
    _layer.bounds=CGRectMake(0, 0, 10, 20);
    _layer.position=CGPointMake(50, 150);
    _layer.contents=(id)[UIImage imageNamed:@"petal.png"].CGImage;
    [self.view.layer addSublayer:_layer];
}
#pragma mark 移动动画
-(void)translatonAnimation:(CGPoint)location{
    //1.创建动画并指定动画属性
    CABasicAnimation *basicAnimation=[CABasicAnimation animationWithKeyPath:@"position"];
     
    //2.设置动画属性初始值和结束值
//    basicAnimation.fromValue=[NSNumber numberWithInteger:50];//可以不设置，默认为图层初始状态
    basicAnimation.toValue=[NSValue valueWithCGPoint:location];
     
    //设置其他动画属性
    basicAnimation.duration=5.0;//动画时间5秒
    //basicAnimation.repeatCount=HUGE_VALF;//设置重复次数,HUGE_VALF可看做无穷大，起到循环动画的效果
    //    basicAnimation.removedOnCompletion=NO;//运行一次是否移除动画
     
    //3.添加动画到图层，注意key相当于给动画进行命名，以后获得该动画时可以使用此名称获取
    [_layer addAnimation:basicAnimation forKey:@"KCBasicAnimation_Translation"];
}
#pragma mark 点击事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=touches.anyObject;
    CGPoint location= [touch locationInView:self.view];
    //创建并开始动画
    [self translatonAnimation:location];
}
@end
```
运行效果
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022103123_1.gif)</center>
前面说过图层动画的本质就是将图层内部的内容转化为位图经硬件操作形成一种动画效果，其实图层本身并没有任何的变化。上面的动画中图层并没有因为动画效果而改变它的位置（对于缩放动画其大小也是不会改变的），所以动画完成之后图层还是在原来的显示位置没有任何变化，如果这个图层在一个UIView中你会发现在UIView移动过程中你要触发UIView的点击事件也只能点击原来的位置（即使它已经运动到了别的位置），因为它的位置从来没有变过。当然解决这个问题方法比较多，这里不妨在动画完成之后重新设置它的位置。

```
#import "KCMainViewController.h"
@interface KCMainViewController (){
    CALayer *_layer;
}
@end
@implementation KCMainViewController
- (void)viewDidLoad {
    [super viewDidLoad];
     
    //设置背景(注意这个图片其实在根图层)
    UIImage *backgroundImage=[UIImage imageNamed:@"background.jpg"];
    self.view.backgroundColor=[UIColor colorWithPatternImage:backgroundImage];
     
    //自定义一个图层
    _layer=[[CALayer alloc]init];
    _layer.bounds=CGRectMake(0, 0, 10, 20);
    _layer.position=CGPointMake(50, 150);
    _layer.contents=(id)[UIImage imageNamed:@"petal.png"].CGImage;
    [self.view.layer addSublayer:_layer];
}
#pragma mark 移动动画
-(void)translatonAnimation:(CGPoint)location{
    //1.创建动画并指定动画属性
    CABasicAnimation *basicAnimation=[CABasicAnimation animationWithKeyPath:@"position"];
     
    //2.设置动画属性初始值和结束值
//    basicAnimation.fromValue=[NSNumber numberWithInteger:50];//可以不设置，默认为图层初始状态
    basicAnimation.toValue=[NSValue valueWithCGPoint:location];
     
    //设置其他动画属性
    basicAnimation.duration=5.0;//动画时间5秒
    //basicAnimation.repeatCount=HUGE_VALF;//设置重复次数,HUGE_VALF可看做无穷大，起到循环动画的效果
    //    basicAnimation.removedOnCompletion=NO;//运行一次是否移除动画
    basicAnimation.delegate=self;
    //存储当前位置在动画结束后使用
    [basicAnimation setValue:[NSValue valueWithCGPoint:location] forKey:@"KCBasicAnimationLocation"];
     
    //3.添加动画到图层，注意key相当于给动画进行命名，以后获得该动画时可以使用此名称获取
    [_layer addAnimation:basicAnimation forKey:@"KCBasicAnimation_Translation"];
}
#pragma mark 点击事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=touches.anyObject;
    CGPoint location= [touch locationInView:self.view];
    //创建并开始动画
    [self translatonAnimation:location];
}
#pragma mark - 动画代理方法
#pragma mark 动画开始
-(void)animationDidStart:(CAAnimation *)anim{
    NSLog(@"animation(%@) start.\r_layer.frame=%@",anim,NSStringFromCGRect(_layer.frame));
    NSLog(@"%@",[_layer animationForKey:@"KCBasicAnimation_Translation"]);//通过前面的设置的key获得动画
}
#pragma mark 动画结束
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSLog(@"animation(%@) stop.\r_layer.frame=%@",anim,NSStringFromCGRect(_layer.frame));
    _layer.position=[[anim valueForKey:@"KCBasicAnimationLocation"] CGPointValue];
}
@end

```
上面通过给动画设置一个代理去监听动画的开始和结束事件，在动画开始前给动画添加一个自定义属性“KCBasicAnimationLocation”存储动画终点位置，然后在动画结束后设置动画的位置为终点位置。

如果运行上面的代码大家可能会发现另外一个问题，那就是动画运行完成后会重新从起始点运动到终点。这个问题产生的原因就是前面提到的，对于非根图层，设置图层的可动画属性（在动画结束后重新设置了position，而position是可动画属性）会产生动画效果。解决这个问题有两种办法：关闭图层隐式动画、设置动画图层为根图层。显然这里不能采取后者，因为根图层当前已经作为动画的背景。

要关闭隐式动画需要用到动画事务CATransaction，在事务内将隐式动画关闭，例如上面的代码可以改为：

```
#pragma mark 动画结束
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSLog(@"animation(%@) stop.\r_layer.frame=%@",anim,NSStringFromCGRect(_layer.frame));
    //开启事务
    [CATransaction begin];
    //禁用隐式动画
    [CATransaction setDisableActions:YES];
     
    _layer.position=[[anim valueForKey:@"KCBasicAnimationLocation"] CGPointValue];
     
    //提交事务
    [CATransaction commit];
}

```
<font color = red>**补充**</font>
>上面通过在animationDidStop中重新设置动画的位置主要为了说明隐式动画关闭和动画事件之间传参的内容，发现这种方式有可能在动画运行完之后出现从原点瞬间回到终点的过程，最早在调试的时候没有发现这个问题，其实解决这个问题并不难，首先必须设置fromValue，其次在动画开始前设置动画position为终点位置（当然也必须关闭隐式动画）。但是这里主要还是出于学习的目的，真正开发的时候做平移动画直接使用隐式动画即可，没有必要那么麻烦。

当然上面的动画还显得有些生硬，因为落花飘散的时候可能不仅仅是自由落体运动，本身由于空气阻力、外界风力还会造成落花在空中的旋转、摇摆等，这里不妨给图层添加一个旋转的动画。对于图层的旋转前面已经演示过怎么通过key path设置图层旋转的内容了，在这里需要强调一下，图层的形变都是基于锚点进行的。例如旋转，旋转的中心点就是图层的锚点。

```
#import "KCMainViewController.h"
 
@interface KCMainViewController (){
    CALayer *_layer;
}
 
@end
 
@implementation KCMainViewController
 
- (void)viewDidLoad {
    [super viewDidLoad];
     
    //设置背景(注意这个图片其实在根图层)
    UIImage *backgroundImage=[UIImage imageNamed:@"background.jpg"];
    self.view.backgroundColor=[UIColor colorWithPatternImage:backgroundImage];
     
    //自定义一个图层
    _layer=[[CALayer alloc]init];
    _layer.bounds=CGRectMake(0, 0, 10, 20);
    _layer.position=CGPointMake(50, 150);
    _layer.anchorPoint=CGPointMake(0.5, 0.6);//设置锚点
    _layer.contents=(id)[UIImage imageNamed:@"petal.png"].CGImage;
    [self.view.layer addSublayer:_layer];
}
 
 
#pragma mark 移动动画
-(void)translatonAnimation:(CGPoint)location{
    //1.创建动画并指定动画属性
    CABasicAnimation *basicAnimation=[CABasicAnimation animationWithKeyPath:@"position"];
     
    //2.设置动画属性初始值、结束值
//    basicAnimation.fromValue=[NSNumber numberWithInteger:50];//可以不设置，默认为图层初始状态
    basicAnimation.toValue=[NSValue valueWithCGPoint:location];
     
    //设置其他动画属性
    basicAnimation.duration=5.0;//动画时间5秒
    //basicAnimation.repeatCount=HUGE_VALF;//设置重复次数,HUGE_VALF可看做无穷大，起到循环动画的效果
    //    basicAnimation.removedOnCompletion=NO;//运行一次是否移除动画
    basicAnimation.delegate=self;
    //存储当前位置在动画结束后使用
    [basicAnimation setValue:[NSValue valueWithCGPoint:location] forKey:@"KCBasicAnimationLocation"];
     
    //3.添加动画到图层，注意key相当于给动画进行命名，以后获得该图层时可以使用此名称获取
    [_layer addAnimation:basicAnimation forKey:@"KCBasicAnimation_Translation"];
}
 
#pragma mark 旋转动画
-(void)rotationAnimation{
    //1.创建动画并指定动画属性
    CABasicAnimation *basicAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
     
    //2.设置动画属性初始值、结束值
//    basicAnimation.fromValue=[NSNumber numberWithInt:M_PI_2];
    basicAnimation.toValue=[NSNumber numberWithFloat:M_PI_2*3];
     
    //设置其他动画属性
    basicAnimation.duration=6.0;
    basicAnimation.autoreverses=true;//旋转后再旋转到原来的位置
     
     
    //4.添加动画到图层，注意key相当于给动画进行命名，以后获得该动画时可以使用此名称获取
    [_layer addAnimation:basicAnimation forKey:@"KCBasicAnimation_Rotation"];
}
 
#pragma mark 点击事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=touches.anyObject;
    CGPoint location= [touch locationInView:self.view];
    //创建并开始动画
    [self translatonAnimation:location];
     
    [self rotationAnimation];
}
 
#pragma mark - 动画代理方法
#pragma mark 动画开始
-(void)animationDidStart:(CAAnimation *)anim{
    NSLog(@"animation(%@) start.\r_layer.frame=%@",anim,NSStringFromCGRect(_layer.frame));
    NSLog(@"%@",[_layer animationForKey:@"KCBasicAnimation_Translation"]);//通过前面的设置的key获得动画
}
 
#pragma mark 动画结束
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSLog(@"animation(%@) stop.\r_layer.frame=%@",anim,NSStringFromCGRect(_layer.frame));
    //开启事务
    [CATransaction begin];
    //禁用隐式动画
    [CATransaction setDisableActions:YES];
     
    _layer.position=[[anim valueForKey:@"KCBasicAnimationLocation"] CGPointValue];
     
    //提交事务
    [CATransaction commit];
}
@end

```
上面代码中结合两种动画操作，需要注意的是只给移动动画设置了代理，在旋转动画中并没有设置代理，否则代理方法会执行两遍。由于旋转动画会无限循环执行（上面设置了重复次数无穷大），并且两个动画的执行时间没有必然的关系，这样一来移动停止后可能还在旋转，为了让移动动画停止后旋转动画，停止就需要使用到动画的暂停和恢复方法。

核心动画的运行有一个媒体时间的概念，假设将一个旋转动画设置旋转一周用时60秒的话，那么当动画旋转90度后媒体时间就是15秒。如果此时要将动画暂停只需要让媒体时间偏移量设置为15秒即可，并把动画运行速度设置为0使其停止运动。类似的，如果又过了60秒后需要恢复动画（此时媒体时间为75秒），这时只要将动画开始开始时间设置为当前媒体时间75秒减去暂停时的时间（也就是之前定格动画时的偏移量）15秒（开始时间=75-15=60秒），那么动画就会重新计算60秒后的状态再开始运行，与此同时将偏移量重新设置为0并且把运行速度设置1。这个过程中真正起到暂停动画和恢复动画的其实是动画速度的调整，媒体时间偏移量以及恢复时的开始时间设置主要为了让动画更加连贯。

下面的代码演示了移动动画结束后旋转动画暂停，并且当再次点击动画时旋转恢复的过程(注意在移动过程中如果再次点击屏幕可以暂停移动和旋转动画，再次点击可以恢复两种动画。但是当移动结束后触发了移动动画的完成事件如果再次点击屏幕则只能恢复旋转动画，因为此时移动动画已经结束而不是暂停，无法再恢复)。

```
//
//  BaseAnimeVC.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "BaseAnimeVC.h"

@interface BaseAnimeVC ()<CAAnimationDelegate>
@property (nonatomic, strong) CALayer *layer;
@end

@implementation BaseAnimeVC

- (void)viewDidLoad {
[super viewDidLoad];
//设置背景（注意这个图片其实在根图层）
UIImage* backgroundImage = [UIImage imageNamed:@"bg.jpg"];
self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];

//自定义一个图层
self.layer = [[CALayer alloc]init];
self.layer.bounds= CGRectMake(0, 0, 10, 20);
self.layer.position = CGPointMake(50, 150);
self.layer.contents = (id)[UIImage imageNamed:@"雪"].CGImage;
[self.view.layer addSublayer:self.layer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
UITouch* touch = [touches anyObject];
CGPoint position = [touch locationInView:self.view];
CAAnimation *animation = [self.layer animationForKey:@"ZXBasicAnimation_rotation"];
//创建并开始动画
if (animation) {
if (self.layer.speed == 0) {
[self animationResume];
}else{
[self animationPause];
}
}else{

[self translationAnimation:position];
[self rotationAnimation];
}
}

- (void)animationPause {
//取得指定图层动画的媒体时间，后面参数用于指定子图层，这里不需要
CFTimeInterval interval = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
//设置时间偏移量，保证暂停时停留在旋转的位置
self.layer.timeOffset = interval;
//速度设置为零，暂停动画
self.layer.speed = 0;
}

- (void)animationResume {
//获取暂停的时间
CFTimeInterval beginTime = CACurrentMediaTime() - self.layer.timeOffset;
//设置偏移量
self.layer.timeOffset = 0;
//设置开始时间
self.layer.beginTime = beginTime;
//设置动画速度，开始运动
self.layer.speed = 1.0;

}


#pragma mark - 移动动画
- (void)translationAnimation:(CGPoint)location {
//1.创建动画并指定动画属性
CABasicAnimation *basicAnim = [CABasicAnimation animationWithKeyPath:@"position"];
//2.设置动画属性初始值和结束值
//basicAnim.fromValue = [NSValue valueWithCGPoint:self.layer.position];
basicAnim.toValue = [NSValue valueWithCGPoint:location];
basicAnim.duration = 1.0;
basicAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
basicAnim.removedOnCompletion = NO;


//设置代理
basicAnim.delegate = self;
//self.layer.position = location;
//存储当前位置工动画结束后使用
[basicAnim setValue:[NSValue valueWithCGPoint:location] forKey:@"ZXBasicAnimationEndValue"];
//3.添加动画到图层，注意key相当于给动画进行命名，以后获得改动画时可以使用此名称获取
[self.layer addAnimation:basicAnim forKey:@"ZXBasicAnimation_Translation"];
}

#pragma mark - 旋转动画
- (void)rotationAnimation {
//创建动画并指定动画属性
CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];

//设置动画初始值和结束值
basicAnimation.toValue = [NSNumber numberWithFloat:M_PI];

//设置其动画属性
basicAnimation.duration = 1.0;
basicAnimation.autoreverses = true;
basicAnimation.repeatCount = HUGE_VAL;
basicAnimation.removedOnCompletion = NO;


[self.layer addAnimation:basicAnimation forKey:@"ZXBasicAnimation_rotation"];
}

#pragma mark - CAAnimationDelegate
//动画开始
- (void)animationDidStart:(CAAnimation *)anim {
NSLog(@"animation(%@) start.\r_layer.frame=%@",anim,NSStringFromCGRect(_layer.frame));
NSLog(@"%@",[_layer animationForKey:@"ZXBasicAnimation_Translation"]);//通过前面的设置的key获得动画
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
NSLog(@"animation(%@) stop.\r_layer.frame=%@",anim,NSStringFromCGRect(_layer.frame));
//_layer.position=[[anim valueForKey:@"ZXBasicAnimationEndValue"] CGPointValue];
//代码运行到此处会发现另一问题：<#动画运行完成后会重新从起始点运动到终点#>
/*
问题产生的原因是：
对于非根图层，设置图层的可动画属性（在动画结束后重新设置了position，而position是可动画属性）会产生动画效果。
解决这个问题有两种办法：
关闭图层隐式动画、设置动画图层为根图层。显然这里不能采取后者，因为根图层当前已经作为动画的背景。
*/

//要关闭隐式动画需要用到动画事务CATransaction，在事务内讲隐式动画关闭，列如上面的代码可以改为：
//开启事务
[CATransaction begin];
//禁用隐式动画
[CATransaction setDisableActions:YES];

self.layer.position = [[anim valueForKey:@"ZXBasicAnimationEndValue"] CGPointValue];

//提交事务
[CATransaction commit];

//暂停旋转动画
[self animationPause];
}



@end

```
运行效果
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022103439_1.gif)</center>

**<font color = red>注意：</font>**
动画暂停针对的是图层而不是图层中的某个动画。
要做无限循环的动画，动画的removedOnCompletion属性必须设置为NO，否则运行一次动画就会销毁。


#### 关键帧动画
熟悉flash开发的朋友对于关键帧动画应该不陌生，这种动画方式在flash开发中经常用到。关键帧动画就是在动画控制过程中开发者指定主要的动画状态，至于各个状态间动画如何进行则由系统自动运算补充（每两个关键帧之间系统形成的动画称为“补间动画”），这种动画的好处就是开发者不用逐个控制每个动画帧，而只要关心几个关键帧的状态即可。
关键帧动画开发分为两种形式：一种是通过设置不同的属性值进行关键帧控制，另一种是通过绘制路径进行关键帧控制。后者优先级高于前者，如果设置了路径则属性值就不再起作用。
对于前面的落花动画效果而言其实落花的过程并不自然，很显然实际生活中它不可能沿着直线下落，这里我们不妨通过关键帧动画的values属性控制它在下落过程中的属性。假设下落过程如图
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022110324_1.jpg)</center>
在这里需要设置四个关键帧（如图中四个关键点），具体代码如下（动画创建过程同基本动画基本完全一致）：

```
//
//  KeyFrameAnimationVC.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "KeyFrameAnimationVC.h"

@interface KeyFrameAnimationVC ()
@property (nonatomic, strong) CALayer *layer;
@end

@implementation KeyFrameAnimationVC

- (void)viewDidLoad {
[super viewDidLoad];
//设置背景（注意这个图片其实在根图层）
UIImage* backgroundImage = [UIImage imageNamed:@"bg.jpg"];
self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];

//自定义一个图层
self.layer = [[CALayer alloc]init];
self.layer.bounds= CGRectMake(0, 0, 10, 20);
self.layer.position = CGPointMake(50, 150);
self.layer.contents = (id)[UIImage imageNamed:@"雪"].CGImage;
[self.view.layer addSublayer:self.layer];

//创建动画
[self translationAnimation_values];
//[self translationAnimation_path];
}
- (void)translationAnimation_values {
//1.创建关键帧动画并设置动画属性
CAKeyframeAnimation* keyFrameAnimation =[CAKeyframeAnimation animationWithKeyPath:@"position"];

//2.设置关键帧，这里有四个关键帧
NSValue* key1 = [NSValue valueWithCGPoint:self.layer.position];//对于关键帧动画初始值不能省略
NSValue* key2 = [NSValue valueWithCGPoint:CGPointMake(80, 220)];
NSValue* key3 = [NSValue valueWithCGPoint:CGPointMake(45, 320)];
NSValue* key4 = [NSValue valueWithCGPoint:CGPointMake(75, 420)];
//设置其他属性
keyFrameAnimation.values = @[key1,key2,key3,key4];
keyFrameAnimation.duration = 7;
//keyFrameAnimation.beginTime = CACurrentMediaTime() + 2;//设置延迟2秒执行
keyFrameAnimation.keyTimes = @[@(2/7.0),@(5.5/7),@(6.25/7),@1.0];

//3.添加动画到图层，添加动画后就会行动画
[self.layer addAnimation:keyFrameAnimation forKey:@"myAnimation"];

}


@end

```

运行效果(注意运行结束没有设置图层位置为动画运动结束位置)：
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022103703_1.gif)</center>
上面的方式固然比前面使用基础动画效果要好一些，但其实还是存在问题，那就是落花飞落的路径是直线的，当然这个直线是根据程序中设置的四个关键帧自动形成的，那么如何让它沿着曲线飘落呢？这就是第二种类型的关键帧动画，通过描绘路径进行关键帧动画控制。假设让落花沿着下面的曲线路径飘落：
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022110410_1.jpg)</center>
当然，这是一条贝塞尔曲线，学习了前篇文章之后相信对于这类曲线应该并不陌生，下面是具体实现代码：

```
//
//  KeyFrameAnimationVC.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "KeyFrameAnimationVC.h"

@interface KeyFrameAnimationVC ()
@property (nonatomic, strong) CALayer *layer;
@end

@implementation KeyFrameAnimationVC

- (void)viewDidLoad {
[super viewDidLoad];
//设置背景（注意这个图片其实在根图层）
UIImage* backgroundImage = [UIImage imageNamed:@"bg.jpg"];
self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];

//自定义一个图层
self.layer = [[CALayer alloc]init];
self.layer.bounds= CGRectMake(0, 0, 10, 20);
self.layer.position = CGPointMake(50, 150);
self.layer.contents = (id)[UIImage imageNamed:@"雪"].CGImage;
[self.view.layer addSublayer:self.layer];

//创建动画
[self translationAnimation_path];
}


- (void)translationAnimation_path {

//1.创建关键帧动画并设置动画属性
CAKeyframeAnimation* keyFrameAnimation =[CAKeyframeAnimation animationWithKeyPath:@"position"];

//2.设置路径
//贝塞尔曲线
CGMutablePathRef path = CGPathCreateMutable();
CGPathMoveToPoint(path, NULL, self.layer.position.x, self.layer.position.y);
CGPathAddCurveToPoint(path, NULL, 160, 280, -30, 300, 55, 400);//绘制二次贝塞尔曲线
keyFrameAnimation.path = path;
CGPathRelease(path);


keyFrameAnimation.duration = 5.0;
keyFrameAnimation.beginTime = CACurrentMediaTime() + 2;//设置延迟2秒执行


//3.添加动画到图层，添加动画后就会行动画
[self.layer addAnimation:keyFrameAnimation forKey:@"myAnimation"];

}


@end

```

运行效果(注意运行结束没有设置图层位置为动画运动结束位置)：
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022103818_1.gif)</center>
看起来动画不会那么生硬了，但是这里需要注意，对于路径类型的关键帧动画系统是从描绘路径的位置开始路径，直到路径结束。如果上面的路径不是贝塞尔曲线而是矩形路径那么它会从矩形的左上角开始运行，顺时针一周回到左上角；如果指定的路径是一个椭圆，那么动画运行的路径是从椭圆右侧开始（0度）顺时针一周回到右侧。

**<font color = red>补充：其他属性</font>**
在关键帧动画中还有一些动画属性初学者往往比较容易混淆，这里专门针对这些属性做一下介绍。

keyTimes：各个关键帧的时间控制。前面使用values设置了四个关键帧，默认情况下每两帧之间的间隔为:8/(4-1)秒。如果想要控制动画从第一帧到第二针占用时间4秒，从第二帧到第三帧时间为2秒，而从第三帧到第四帧时间2秒的话，就可以通过keyTimes进行设置。keyTimes中存储的是时间占用比例点，此时可以设置keyTimes的值为0.0，0.5，0.75，1.0（当然必须转换为NSNumber），也就是说1到2帧运行到总时间的50%，2到3帧运行到总时间的75%，3到4帧运行到8秒结束。
caculationMode：动画计算模式。还拿上面keyValues动画举例，之所以1到2帧能形成连贯性动画而不是直接从第1帧经过8/3秒到第2帧是因为动画模式是连续的（值为kCAAnimationLinear，这是计算模式的默认值）；而如果指定了动画模式为kCAAnimationDiscrete离散的那么你会看到动画从第1帧经过8/3秒直接到第2帧，中间没有任何过渡。其他动画模式还有：kCAAnimationPaced（均匀执行，会忽略keyTimes）、kCAAnimationCubic（平滑执行，对于位置变动关键帧动画运行轨迹更平滑）、kCAAnimationCubicPaced（平滑均匀执行）。
下图描绘出了几种动画模式的关系（横坐标是运行时间，纵坐标是动画属性[例如位置、透明度等]）：
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022103916_1.png)</center>

#### 动画组
实际开发中一个物体的运动往往是复合运动，单一属性的运动情况比较少，但恰恰属性动画每次进行动画设置时一次只能设置一个属性进行动画控制(不管是基础动画还是关键帧动画都是如此)，这样一来要做一个复合运动的动画就必须创建多个属性动画进行组合。对于一两种动画的组合或许处理起来还比较容易，但是对于更多动画的组合控制往往会变得很麻烦，动画组的产生就是基于这样一种情况而产生的。动画组是一系列动画的组合，凡是添加到动画组中的动画都受控于动画组，**这样一来各类动画公共的行为就可以统一进行控制而不必单独设置，而且放到动画组中的各个动画可以并发执行，共同构建出复杂的动画效果。**
前面关键帧动画部分，路径动画看起来效果虽然很流畅，但是落花本身的旋转运动没有了，这里不妨将基础动画部分的旋转动画和路径关键帧动画进行组合使得整个动画看起来更加的和谐、顺畅。




```
//
//  AnimationGroupVC.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "AnimationGroupVC.h"

@interface AnimationGroupVC ()<CAAnimationDelegate>
@property (nonatomic, strong) CALayer *layer;
@end

@implementation AnimationGroupVC

- (void)viewDidLoad {
[super viewDidLoad];
//设置背景（注意这个图片其实在根图层）
UIImage* backgroundImage = [UIImage imageNamed:@"bg.jpg"];
self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];

//自定义一个图层
self.layer = [[CALayer alloc]init];
self.layer.bounds= CGRectMake(0, 0, 10, 20);
self.layer.position = CGPointMake(50, 150);
self.layer.contents = (id)[UIImage imageNamed:@"雪"].CGImage;
[self.view.layer addSublayer:self.layer];

//创建动画
[self groupAnimation];

}

#pragma mark - 添加基础旋转动画
- (CABasicAnimation*)rotationAnimation {
CABasicAnimation* basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
CGFloat toValue = M_PI_2*3;

basicAnimation.toValue = [NSNumber numberWithFloat:toValue];
basicAnimation.autoreverses = YES;
basicAnimation.repeatCount = HUGE_VAL;
basicAnimation.removedOnCompletion = NO;

[basicAnimation setValue:[NSNumber numberWithFloat:toValue] forKey:@"ZXBaiscAnimationProperty_toValue"];
return basicAnimation;
}
#pragma mark - 添加关键帧移动动画
- (CAKeyframeAnimation*)translationAnimation {
CAKeyframeAnimation* keyframeAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
CGPoint endPoint = CGPointMake(55, 400);
CGMutablePathRef path = CGPathCreateMutable();
CGPathMoveToPoint(path, NULL, self.layer.position.x, self.layer.position.y);
CGPathAddCurveToPoint(path, NULL, 160, 280, -30, 300, endPoint.x, endPoint.y);
keyframeAnim.path = path;
CGPathRelease(path);
[keyframeAnim setValue:[NSValue valueWithCGPoint:endPoint] forKey:@"ZXKeyFrameAnimationProperty_endPosition"];

return keyframeAnim;
}
#pragma mark - 创建动画组
- (void)groupAnimation {
//1.创建动画组
CAAnimationGroup* animationGroup = [CAAnimationGroup animation];

//2.设置组中的动画和其他属性
CABasicAnimation* basicAnimation = [self rotationAnimation];
CAKeyframeAnimation* keyFrameAnimation = [self translationAnimation];
animationGroup.animations = @[basicAnimation,keyFrameAnimation];

animationGroup.delegate = self;
animationGroup.duration = 10.0;//设置动画时间，如果动画组中动画已经设置过动画属性则不再生效
animationGroup.beginTime = CACurrentMediaTime() + 5;//延迟5秒执行

//3.给图层添加动画
[self.layer addAnimation:animationGroup forKey:nil];
}
#pragma mark - 代理方法
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
CAAnimationGroup* animationGroup = (CAAnimationGroup*)anim;
CABasicAnimation* basicAnimation = (CABasicAnimation*)animationGroup.animations[0];
CAKeyframeAnimation* keyFrameAnimation = (CAKeyframeAnimation*)animationGroup.animations[1];
CGFloat toValue = [[basicAnimation valueForKey:@"ZXBaiscAnimationProperty_toValue"] floatValue];
CGPoint endPoint = [[keyFrameAnimation valueForKey:@"ZXKeyFrameAnimationProperty_endPosition"] CGPointValue];

[CATransaction begin];
[CATransaction setDisableActions:YES];
//设置动画的最终状态
self.layer.position = endPoint;
self.layer.transform = CATransform3DMakeRotation(toValue, 0, 0, 1);
[CATransaction commit];

}


@end

```

运行效果：
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022104025_1.gif)</center>

#### 转场动画
转场动画就是从一个场景以动画的形式过渡到另一个场景。转场动画的使用一般分为以下几个步骤：

* 创建转场动画
* 设置转场动类型、子类型（可选）及其他属性
* 设置转场后的新视图并添加动画到图层

下表列出了常用的转场类型(注意私有API是苹果官方没有公开的动画类型，但是目前通过仍然可以使用)：
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022104125_1.jpg)</center>
另外对于支持方向设置的动画类型还包含子类型：
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022104212_1.jpg)</center>
在前面的文章[“iOS开发系列--无限循环的图片浏览器”中为了使用UIScrollView](http://www.cnblogs.com/kenshincui/p/3913885.html)做无限循环图片浏览器花费了不少时间在性能优化上面，这里使用转场动画利用一个UIImageView实现一个漂亮的无限循环图片浏览器。

```
//
//  TransitionAnimationVC.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/1.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "TransitionAnimationVC.h"

#define kImageCount 8
@interface TransitionAnimationVC ()
@property (nonatomic, strong) UIImageView *myImageView;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation TransitionAnimationVC

- (void)viewDidLoad {
[super viewDidLoad];
self.myImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
self.myImageView.image = [UIImage imageNamed:@"01.png"];
self.myImageView.contentMode = UIViewContentModeScaleAspectFit;
[self.view addSubview:_myImageView];
//添加手势
UISwipeGestureRecognizer* leftSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipe:)];
leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
[self.view addGestureRecognizer:leftSwipeGesture];

UISwipeGestureRecognizer* rightSwipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipe:)];
rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
[self.view addGestureRecognizer:rightSwipeGesture];
}


#pragma mark - 向左滑动浏览下张图片
- (void)leftSwipe:(UISwipeGestureRecognizer*)gesture {
[self transitionAnimtion:YES];
}

#pragma mark - 向右滑动浏览上张图片
- (void)rightSwipe:(UISwipeGestureRecognizer*)gesture {
[self transitionAnimtion:NO];
}

#pragma mark - 添加转场动画

- (void)transitionAnimtion:(BOOL)flag {
//1.创建转场动画对象
CATransition* transition = [[CATransition alloc]init];

//2.设置动画类型，注意对于苹果官方没有公开的动画类型只能使用字符串，并没有对应的常亮使用
transition.type = @"cube";
//设置子类型
if (flag) {
transition.subtype = kCATransitionFromRight;
}else {
transition.subtype = kCATransitionFromLeft;
}

//设置动画时长
transition.duration = 1.0f;

//3.设置转场动画后,给新视图添加转场动画
self.myImageView.image = [self getImage:flag];
[self.myImageView.layer addAnimation:transition forKey:@"abc"];
}

- (UIImage*)getImage:(BOOL)flag {
if (flag) {
self.currentIndex = (self.currentIndex + 1)%kImageCount + 1;

}else {
self.currentIndex = (self.currentIndex - 1 + kImageCount)%kImageCount + 1;
}
return [UIImage imageNamed:[NSString stringWithFormat:@"0%ld.png",self.currentIndex]];

}

@end

```
运行效果：
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022105011_1.gif)</center>
代码十分简单，但是效果和性能却很惊人。当然演示代码有限，其他动画类型大家可以自己实现，效果都很绚丽。

#### 逐帧动画
前面介绍了核心动画中大部分动画类型，但是做过动画处理的朋友都知道，在动画制作中还有一种动画类型“逐帧动画”。说到逐帧动画相信很多朋友第一个想到的就是UIImageView，通过设置UIImageView的animationImages属性，然后调用它的startAnimating方法去播放这组图片。当然这种方法在某些场景下是可以达到逐帧的动画效果，但是它也存在着很大的性能问题，并且这种方法一旦设置完图片中间的过程就无法控制了。当然，也许有朋友会想到利用iOS的定时器NSTimer定时更新图片来达到逐帧动画的效果。这种方式确实可以解决UIImageView一次性加载大量图片的问题，而且让播放过程可控，唯一的缺点就是定时器方法调用有时可能会因为当前系统执行某种比较占用时间的任务造成动画连续性出现问题。
虽然在核心动画没有直接提供逐帧动画类型，但是却提供了用于完成逐帧动画的相关对象CADisplayLink。CADisplayLink是一个计时器，但是同NSTimer不同的是，CADisplayLink的刷新周期同屏幕完全一致。例如在iOS中屏幕刷新周期是60次/秒，CADisplayLink刷新周期同屏幕刷新一致也是60次/秒，这样一来使用它完成的逐帧动画（又称为“时钟动画”）完全感觉不到动画的停滞情况。
在iOS开篇“IOS开发系列--IOS程序开发概览”中就曾说过：iOS程序在运行后就进入一个消息循环中（这个消息循环称为“主运行循环”），整个程序相当于进入一个死循环中，始终等待用户输入。将CADisplayLink加入到主运行循环队列后，它的时钟周期就和主运行循环保持一致，而主运行循环周期就是屏幕刷新周期。在CADisplayLink加入到主运行循环队列后就会循环调用目标方法，在这个方法中更新视图内容就可以完成逐帧动画。
当然这里不得不强调的是逐帧动画性能势必较低，但是对于一些事物的运动又不得不选择使用逐帧动画，例如人的运动，这是一个高度复杂的运动，基本动画、关键帧动画是不可能解决的。所大家一定要注意在循环方法中尽可能的降低算法复杂度，同时保证循环过程中内存峰值尽可能低。下面以一个鱼的运动为例为大家演示一下逐帧动画。

```
//
//  CADisplaylinkAnimationVC.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/2.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "CADisplaylinkAnimationVC.h"

@interface CADisplaylinkAnimationVC ()
@property (nonatomic, strong) CALayer *fishLayer;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableArray *images;
@end

@implementation CADisplaylinkAnimationVC

- (void)viewDidLoad {
[super viewDidLoad];
//设置背景
self.view.backgroundColor = [UIColor blackColor];

//创建图像显示图层
self.fishLayer = [[CALayer alloc]init];
self.fishLayer.bounds = CGRectMake(0, 0, 250, 250);
self.fishLayer.position = CGPointMake(160, 150);
self.fishLayer.contents = (id)[UIImage imageNamed:@"timg_0001"].CGImage;
self.fishLayer.backgroundColor = [UIColor redColor].CGColor;
[self.view.layer addSublayer:self.fishLayer];




//由于鱼的图片在循环中会不断创建，而几张图片相对较小
//与其在循环中不断创建UIImage不如直接将所有图片缓存起来
self.images = [NSMutableArray array];
for (int i = 0; i < 8; i++) {
NSString* imageName = [NSString stringWithFormat:@"timg_000%i.png",i];
UIImage* image = [UIImage imageNamed:imageName];
[self.images addObject:image];
}

//定义时钟对象
CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(stepFish)];
//将时钟对象加入到主运行循环RunLoop中
[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];


UIImageView* animImageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 400, 250, 250 )];
animImageView.animationImages = self.images;
animImageView.animationDuration = 0.8;
[animImageView startAnimating];

[self.view addSubview:animImageView];

}

#pragma mark 每次屏幕刷新就会执行一次此方法(每秒接近60次)
- (void)stepFish {
//定义一个变量记录执行的次数
static int s = 0;
//每秒行6次
if (++s%6==0) {
UIImage* image = self.images[self.index];
self.fishLayer.contents = (id)image.CGImage;
self.index = (self.index+1)%8;
}
}

@end

```
运行效果：
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022105126_1.gif)</center>
**注意：**上面仅仅演示了逐帧动画的过程，事实上结合其他动画类型可以让整条鱼游动起来，这里不再赘述。


### UIView动画封装
有了前面核心动画的知识，相信大家开发出一般的动画效果应该不在话下。在核心动画开篇也给大家说过，其实UIView本身对于基本动画和关键帧动画、转场动画都有相应的封装，在对动画细节没有特殊要求的情况下使用起来也要简单的多。可以说在日常开发中90%以上的情况使用UIView的动画封装方法都可以搞定，因此在熟悉了核心动画的原理之后还是有必要给大家简单介绍一下UIView中各类动画使用方法的。由于前面核心动画内容已经进行过详细介绍，学习UIView的封装方法根本是小菜一碟，这里对于一些细节就不再赘述了。

#### 基础动画
基础动画部分和前面的基础动画演示相对应，演示点击屏幕落叶飘落到鼠标点击位置的过程。注意根据前面介绍的隐式动画知识其实非根图层直接设置终点位置不需要使用UIView的动画方法也可以实现动画效果，因此这里落花不再放到图层中而是放到了一个UIImageView中。下面的代码演示了通过block和静态方法实现动画控制的过程：

```
//
//  AnimationFromUIView.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/2.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "AnimationFromUIView.h"

@interface AnimationFromUIView (){
UIImageView* _imageView;
UIImageView* _ball;
}

@end

@implementation AnimationFromUIView

- (void)viewDidLoad {
[super viewDidLoad];
//设置背景
UIImage* background = [UIImage imageNamed:@"bg.jpg"];
self.view.backgroundColor = [UIColor colorWithPatternImage:background];

//创建图像显示空间
_imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"timg_0000.png"]];
_imageView.center = CGPointMake(50, 150);
[self.view addSubview:_imageView];

_ball = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blackBall.png"]];
_ball.center = self.view.center;
[self.view addSubview:_ball];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
UITouch * touch = [touches anyObject];
CGPoint location = [touch locationInView:self.view];
[self startBasicAnimate:location];

[self startSpringAnimate:location];

}


- (void)uiViewOpitons {
/*
补充--动画设置参数

在动画方法中有一个option参数，UIViewAnimationOptions类型，它是一个枚举类型，动画参数分为三类，可以组合使用：

1.常规动画属性设置（可以同时选择多个进行设置）

UIViewAnimationOptionLayoutSubviews：动画过程中保证子视图跟随运动。

UIViewAnimationOptionAllowUserInteraction：动画过程中允许用户交互。

UIViewAnimationOptionBeginFromCurrentState：所有视图从当前状态开始运行。

UIViewAnimationOptionRepeat：重复运行动画。

UIViewAnimationOptionAutoreverse ：动画运行到结束点后仍然以动画方式回到初始点。

UIViewAnimationOptionOverrideInheritedDuration：忽略嵌套动画时间设置。

UIViewAnimationOptionOverrideInheritedCurve：忽略嵌套动画速度设置。

UIViewAnimationOptionAllowAnimatedContent：动画过程中重绘视图（注意仅仅适用于转场动画）。

UIViewAnimationOptionShowHideTransitionViews：视图切换时直接隐藏旧视图、显示新视图，而不是将旧视图从父视图移除（仅仅适用于转场动画）

UIViewAnimationOptionOverrideInheritedOptions ：不继承父动画设置或动画类型。

2.动画速度控制（可从其中选择一个设置）

UIViewAnimationOptionCurveEaseInOut：动画先缓慢，然后逐渐加速。

UIViewAnimationOptionCurveEaseIn ：动画逐渐变慢。

UIViewAnimationOptionCurveEaseOut：动画逐渐加速。

UIViewAnimationOptionCurveLinear ：动画匀速执行，默认值。

3.转场类型（仅适用于转场动画设置，可以从中选择一个进行设置，基本动画、关键帧动画不需要设置）

UIViewAnimationOptionTransitionNone：没有转场动画效果。

UIViewAnimationOptionTransitionFlipFromLeft ：从左侧翻转效果。

UIViewAnimationOptionTransitionFlipFromRight：从右侧翻转效果。

UIViewAnimationOptionTransitionCurlUp：向后翻页的动画过渡效果。

UIViewAnimationOptionTransitionCurlDown ：向前翻页的动画过渡效果。

UIViewAnimationOptionTransitionCrossDissolve：旧视图溶解消失显示下一个新视图的效果。

UIViewAnimationOptionTransitionFlipFromTop ：从上方翻转效果。

UIViewAnimationOptionTransitionFlipFromBottom：从底部翻转效果。
*/
}


- (void)startSpringAnimate:(CGPoint)location {
//创建阻尼动画
//damping:阻尼,范围0-1，阻尼越接近于0，弹性效果越明显
//velocity:弹性复位的速度
[UIView animateWithDuration:1.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
_ball.center = location;
} completion:nil];

}


- (void)startBasicAnimate:(CGPoint)location {
//方法1；block方法
/*
开始动画，UIView的动画方法执行完后动画会停留在重点位置，而不需要进行任何特殊处理
duration：执行时间
delay：延迟时间
option:动画设置，列如自动恢复，匀速运动等
completion:动画完成回调方法
*/

//    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//        _imageView.center = location;
//    } completion:^(BOOL finished) {
//        NSLog(@"animate is end");
//    }];

//方法2:静态方法
//开始动画
[UIView beginAnimations:@"ZXBasicAnimation" context:nil];
[UIView setAnimationDuration:1.5];
//[UIView setAnimationDelay:1.0];//设置延迟
//[UIView setAnimationRepeatAutoreverses:NO];//是否回复
//[UIView setAnimationRepeatCount:10];//重复次数
//[UIView setAnimationStartDate:(NSDate *)];//设置动画开始运行的时间
//[UIView setAnimationDelegate:self];//设置代理
//[UIView setAnimationWillStartSelector:(SEL)];//设置动画开始运动的执行方法
//[UIView setAnimationDidStopSelector:(SEL)];//设置动画运行结束后的执行方法

_imageView.center = location;

//开始动画
[UIView commitAnimations];

}
@end

```
**补充--弹簧动画效果**
由于在iOS开发中弹性动画使用很普遍，所以在iOS7苹果官方直接提供了一个方法用于弹性动画开发，下面简单的演示一下：

```
#import "KCMainViewController.h"
 
@interface KCMainViewController (){
 
    UIImageView *_imageView;
}
 
@end
 
@implementation KCMainViewController
 
- (void)viewDidLoad {
    [super viewDidLoad];
     
    //创建图像显示控件
    _imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ball.png"]];
    _imageView.center=CGPointMake(160, 50);
    [self.view addSubview:_imageView];
}
 
#pragma mark 点击事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=touches.anyObject;
    CGPoint location= [touch locationInView:self.view];
    /*创建弹性动画
     damping:阻尼，范围0-1，阻尼越接近于0，弹性效果越明显
     velocity:弹性复位的速度
    */
    [UIView animateWithDuration:5.0 delay:0 usingSpringWithDamping:0.1 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
        _imageView.center=location; //CGPointMake(160, 284);
    } completion:nil];
}
@end

```
运行效果
<center>![](http://www.cocoachina.com/cms/uploads/allimg/141022/4196_141022105345_1.gif)</center>

#### 关键帧动画
从iOS7开始UIView动画中封装了关键帧动画，下面就来看一下如何使用UIView封装方法进行关键帧动画控制，这里实现前面关键帧动画部分对于落花的控制。

```
//
//  KeyFrameAnimationFromUIView.m
//  核心动画CoreAnimation和图层CALayer的使用举例Demo
//
//  Created by zxx_mbp on 2017/6/2.
//  Copyright © 2017年 zxx_mbp. All rights reserved.
//

#import "KeyFrameAnimationFromUIView.h"

@interface KeyFrameAnimationFromUIView (){
UIImageView* _imageView;
}

@end

@implementation KeyFrameAnimationFromUIView

- (void)viewDidLoad {
[super viewDidLoad];
//设置背景
UIImage* background = [UIImage imageNamed:@"bg.jpg"];
self.view.backgroundColor = [UIColor colorWithPatternImage:background];

//创建显示控件
_imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blackBall"]];
_imageView.center = CGPointMake(50, 150);
[self.view addSubview:_imageView];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//关键帧动画，options

[UIView animateKeyframesWithDuration:5.0 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
//第二关键帧（准确的说第一个关键帧是开始位置）：从0秒开始持续50%的时间，也就是5*0.5 = 2.5秒
[UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
_imageView.center = CGPointMake(80, 220);
}];

//第三帧，从0.5*5.0秒开始，持续时间：5.0*0.25 = 1.25秒
[UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.25 animations:^{
_imageView.center = CGPointMake(40, 300);
}];

//第四帧，从0.75*5.0秒开始，持续时间：5.0*0.25秒
[UIView addKeyframeWithRelativeStartTime:0.75f relativeDuration:0.25 animations:^{
_imageView.center = CGPointMake(67, 400);
}];
} completion:^(BOOL finished) {
NSLog(@"animation ended");
}];


/*
options 的补充
UIViewKeyframeAnimationOptionCalculationModeLinear：连续运算模式。

UIViewKeyframeAnimationOptionCalculationModeDiscrete ：离散运算模式。

UIViewKeyframeAnimationOptionCalculationModePaced：均匀执行运算模式。

UIViewKeyframeAnimationOptionCalculationModeCubic：平滑运算模式。

UIViewKeyframeAnimationOptionCalculationModeCubicPaced：平滑均匀运算模式。
*/
}


@end

```
***注意：***前面说过关键帧动画有两种形式，上面演示的是属性值关键帧动画，路径关键帧动画目前UIView还不支持

#### 转场动画
从iOS4.0开始，UIView直接封装了转场动画，使用起来同样很简单。

```
#import "KCMainViewController.h"
#define IMAGE_COUNT 5
 
@interface KCMainViewController (){
    UIImageView *_imageView;
    int _currentIndex;
}
 
@end
 
@implementation KCMainViewController
 
- (void)viewDidLoad {
    [super viewDidLoad];
     
    //定义图片控件
    _imageView=[[UIImageView alloc]init];
    _imageView.frame=[UIScreen mainScreen].applicationFrame;
    _imageView.contentMode=UIViewContentModeScaleAspectFit;
    _imageView.image=[UIImage imageNamed:@"0.jpg"];//默认图片
    [self.view addSubview:_imageView];
    //添加手势
    UISwipeGestureRecognizer *leftSwipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipe:)];
    leftSwipeGesture.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipeGesture];
     
    UISwipeGestureRecognizer *rightSwipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipe:)];
    rightSwipeGesture.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGesture];
}
#pragma mark 向左滑动浏览下一张图片
-(void)leftSwipe:(UISwipeGestureRecognizer *)gesture{
    [self transitionAnimation:YES];
}
 
#pragma mark 向右滑动浏览上一张图片
-(void)rightSwipe:(UISwipeGestureRecognizer *)gesture{
    [self transitionAnimation:NO];
}
 
#pragma mark 转场动画
-(void)transitionAnimation:(BOOL)isNext{
    UIViewAnimationOptions option;
    if (isNext) {
        option=UIViewAnimationOptionCurveLinear|UIViewAnimationOptionTransitionFlipFromRight;
    }else{
        option=UIViewAnimationOptionCurveLinear|UIViewAnimationOptionTransitionFlipFromLeft;
    }
     
    [UIView transitionWithView:_imageView duration:1.0 options:option animations:^{
        _imageView.image=[self getImage:isNext];
    } completion:nil];
}
 
#pragma mark 取得当前图片
-(UIImage *)getImage:(BOOL)isNext{
    if (isNext) {
        _currentIndex=(_currentIndex+1)%IMAGE_COUNT;
    }else{
        _currentIndex=(_currentIndex-1+IMAGE_COUNT)%IMAGE_COUNT;
    }
    NSString *imageName=[NSString stringWithFormat:@"%i.jpg",_currentIndex];
    return [UIImage imageNamed:imageName];
}
@end

```
上面的转场动画演示中，其实仅仅有一个视图UIImageView做转场动画，每次转场通过切换UIImageView的内容而已。如果有两个完全不同的视图，并且每个视图布局都很复杂，此时要在这两个视图之间进行转场可以使用+ (void)transitionFromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion NS_AVAILABLE_IOS(4_0)方法进行两个视图间的转场，需要注意的是默认情况下转出的视图会从父视图移除，转入后重新添加，可以通过UIViewAnimationOptionShowHideTransitionViews参数设置，设置此参数后转出的视图会隐藏（不会移除）转入后再显示。

**注意：**转场动画设置参数完全同基本动画参数设置；同直接使用转场动画不同的是使用UIView的装饰方法进行转场动画其动画效果较少，因为这里无法直接使用私有API。


