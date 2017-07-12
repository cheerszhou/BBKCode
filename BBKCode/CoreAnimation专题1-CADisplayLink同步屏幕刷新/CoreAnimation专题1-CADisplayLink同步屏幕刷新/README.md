# iOS CoreAnimation专题


[toc]
## 原理篇
### 一、CALayer与UIView之间的关系
#### 观点
UIView负责处理用户交互，负责绘制内容的则是它持有的那个CALayer，我们访问和设置UIView的这些负责显示的属性实际上访问和设置的都是这个CALayer对应的属性，UIView只是将这些操作封装起来了而已。
#### 论证
为了证实我们上面的结论，我们将通过一个具体的实验来看看UIView和它持有的这个CALayer之间是怎样进行交互的。
我们新建一个类，继承自UIView，取名为TestAnimationView。我们在这个类中重写一些方法来看看系统在我们取值和赋值的时候干了些什么。为了弄清楚UIView和其持有的那个layer之间的关系，我们需要把这个类的layer改为我们自己定义的一个layer，所以我们在这个类中声明一个私有的类TestAnimationLayer，接下来重写TestAnimationView的+layerClass方法：

```
+ (Class)layerClass {
return [TestAnimationLayer class];
}
```
这个方法将会指定这个UIView被初始化出来之后其自动创建并持有的这个layer的类。 
接下来我们为View和layer重写几个方法：

```
@interface TestAnimationLayer : CALayer

@end

@implementation TestAnimationLayer

- (void)setFrame:(CGRect)frame{
[super setFrame:frame];
}

- (void)setPosition:(CGPoint)position{
[super setPosition:position];
}

- (void)setBounds:(CGRect)bounds{
[super setBounds:bounds];
}

- (CGPoint)position{
return [super position];
}

@end

@implementation TestAnimationView

- (instancetype)init{
self = [super init];
if (self) {

}
return self;
}

- (CGPoint)center{
return [super center];
}

- (void)setFrame:(CGRect)frame{
[super setFrame:frame];
}
- (void)setCenter:(CGPoint)center{
[super setCenter:center];
}
- (void)setBounds:(CGRect)bounds{
[super setBounds:bounds];
}

+ (Class)layerClass{
return [TestAnimationLayer class];
}

@end
```
在各个方法中打好断点，接下来我们在Controller中调用一下：

```
TestAnimationView * view = [[TestAnimationView alloc] init];
```
然后运行我们的程序，等待断点进入。程序运行起来后停下来的第一个断点：
![](http://img.blog.csdn.net/20151209154349659)
此时调用栈中：
![](http://img.blog.csdn.net/20151209154411268)
我们点击调试的step over执行到第45行（此时刚执行完第44行，也就是调用了super init方法），此时调用栈中：
![](http://img.blog.csdn.net/20151209154438804)
可以看到super init这个方法里面调用了5个方法依次为：

```
-[UIView init]
-[UIView initWithFrame:]
UIViewCommonInitWithFrame
-[UIView _createLayerWithFrame:]
-[TestAnimationLayer setBounds:]

```
可以知道的信息：UIView的子类在调用super init的时候，UIView在它自己的init方法中会调用initWithFrame：方法，这个方法中实际上调用了一个私有函数叫做UIViewCommonInitWithFrame，然后又调用了_createLayerWithFrame:，这个方法读名字的话就知道它是干嘛用的了。创建完layer后又会让这个layer调用setBounds：方法，当然，此时断点会进到我们自己的layer类中的setBounds方法里面：
![](http://img.blog.csdn.net/20151209154558973)
接着我们点击continue program execution让程序从当前断点继续执行下去，然后停在了UIView的setFrame方法这里：
![](http://img.blog.csdn.net/20151209154616137)
说明了在UIView的init方法中，它真正的调用顺序是这样的：

```
-[UIView init]
-[UIView initWithFrame:]
UIViewCommonInitWithFrame
-[UIView _createLayerWithFrame:]
-[TestAnimationLayer setBounds:]
-[TestAnimationView setFrame:]

```
它会先创建layer，然后给layer的bounds赋值，最后才给自己的frame赋值。 
我们继续执行，发现程序停在了center的getter这里：
![](http://img.blog.csdn.net/20151209154719872)
奇怪，为什么setFrame会去调用center，实际上如果你去重写bounds的getter你会发现它还会进到bounds的getter中，说明UIView的frame实际上是由center 和bounds来决定的，可能UIView中并没有frame这个实例变量，frame的getter和setter都是在操作center和bounds而已。 
我们继续执行，发现代码居然停在了layer的position的getter方法里面：
![](http://img.blog.csdn.net/20151209154736522)
你猜怎么着，原来UIView的center的getter方法只是简单的去获取自己持有的那个layer的position然后返回。关于这个，我们待会会做一个更深入的实验。
继续执行，然后断点又停在了layer的setFrame方法里面，然后会发现layer会在setFrame方法中调用自己的setPosition和setBounds。 
所以当我们给一个UIView设置frame的时候，这个view首先调用自己layer的setFrame方法，而在layer的setFrame方法里实际上又调用了setBounds和setPosition，说明layer的frame这个属性实际上并没有实例变量，它的setter和getter仅仅是去调用其bounds和position的setter和getter而已，也就是说frame实际上是由bounds和position来决定的（实际上还有anchorPoint，这里没有加到实验中来，大家可以自己试一试）。而UIView的frame并没有调用UIView的center和bounds的setter和getter，它仅仅是去调用其持有的layer的frame的setter和getter而已。
这样我们就证明了UIView只是一个简单的控制器而已，它不负责任何的内容绘制，我们对它的各种负责绘制的属性（Geometry属性和backgroundColor等）访问和赋值实际上都是在跟layer打交道。
为了进一步证明，我们在controller中再加几行代码：

```
TestAnimationView * view = [[TestAnimationView alloc] init];
view.layer.position = CGPointMake(80, 80);
NSLog(@"%@",NSStringFromCGPoint(view.center));

```
我们对layer的属性直接赋值，然后去访问view的对应的属性（这里是layer的position对应view的center）。同样的在TestAnimationView中打满断点，然后在外面的这里打上断点：
![](http://img.blog.csdn.net/20151209154820011)
因为我们调用init方法的时候会调用大量TestAnimationView中的方法，当上面第一个断点进来后再执行代码就保证了接下来的断点断的是我们对Layer的position赋值的操作（第二个断点的意义同第一个断点）。
运行直到断点卡到上面的第一个断点处，然后点击Continue program execution，会发现直接进入layer的setPosition方法，接着就进入了上面的第二个断点。继续运行会发现断点进入了view的center方法，然后又进到了Layer的position方法里。
也就是说，我们在调用setPosition的时候并没有去调用view的任何方法而对view的center进行访问时view直接又去调用了其持有的那个layer的position的getter。继续运行发现打印的结果就是{80,80}，我们没有调用view的setCenter方法但是调用getCenter却返回了正确的值，再次证明了我们访问View的属性实际上就是访问了其持有的那个layer对应的属性。
由此我们甚至可以猜测出UIView和CALayer在Geometry类目中的各个属性的setter和getter的实现代码：

```
@interface TestAnimationLayer : CALayer

@end

@implementation TestAnimationLayer

- (CGRect)frame{
return frameWithCenterAndBounds([self bounds], [self position]);
}

- (void)setFrame:(CGRect)frame{
[self setBounds:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, frame.size.width, frame.size.height)];
[self setPosition:CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2)];
}

CGRect frameWithCenterAndBounds(CGRect bounds, CGPoint center){
CGFloat width = CGRectGetWidth(bounds);
CGFloat height = CGRectGetHeight(bounds);
return CGRectMake(center.x - width/2, center.y - height/2, width, height);
}

@end

@implementation TestAnimationView

- (instancetype)init{
self = [super init];
if (self) {

}
return self;
}

- (CGPoint)center{
return [[self layer] position];
}

- (CGRect)bounds{
return [[self layer] bounds];
}

- (CGRect)frame{
return [[self layer] frame];
}

- (void)setFrame:(CGRect)frame{
[[self layer] setFrame:frame];
}

- (void)setCenter:(CGPoint)center{
[[self layer] setPosition:center];
}

- (void)setBounds:(CGRect)bounds{
[[self layer] setBounds:bounds];
}

+ (Class)layerClass{
return [TestAnimationLayer class];
}

@end

```
#### 总结
CALayer作为一个跨平台框架（OS X和iOS）QuatzCore的类，负责MAC和iPhone（ipad等设备）上绘制所有的显示内容。而iOS系统为了处理用户交互事件（触屏操作）用UIView封装了一次CALayer，UIView本身负责处理交互事件，其持有一个Layer，用来负责绘制这个View的内容。而我们对UIView的和绘制相关的属性赋值和访问的时候（frame、backgroundColor等）UIView实际上是直接调用其Layer对应的属性（frame对应frame，center对应position等）的getter和setter。

### 二、UIView block动画实现原理
#### CALayer的可动画属性
CALayer拥有大量的属性，如果大家按住cmd点进CALayer的头文件中看的话，会发现很多的属性的注释中，最后会有一个词叫做Animatable，直译过来是可动画的。下面的截图只是CALayer众多可动画属性中的一部分（注意frame并不是可动画的属性）：

```
/** Geometry and layer hierarchy properties. **/

/* The bounds of the layer. Defaults to CGRectZero. Animatable. */
@property CGRect bounds;

/* The position in the superlayer that the anchor point of the layer's
* bounds rect is aligned to. Defaults to the zero point. Animatable. */
@property CGPoint position;

/* The Z component of the layer's position in its superlayer. Defaults
* to zero. Animatable. */
@property CGFloat zPosition;

/* Defines the anchor point of the layer's bounds rect, as a point in
* normalized layer coordinates - '(0, 0)' is the bottom left corner of
* the bounds rect, '(1, 1)' is the top right corner. Defaults to
* '(0.5, 0.5)', i.e. the center of the bounds rect. Animatable. */
@property CGPoint anchorPoint;

/* The Z component of the layer's anchor point (i.e. reference point for
* position and transform). Defaults to zero. Animatable. */
@property CGFloat anchorPointZ;

/* A transform applied to the layer relative to the anchor point of its
* bounds rect. Defaults to the identity transform. Animatable. */
@property CATransform3D transform;
....
```
如果一个属性被标记为Animatable，那么它具有以下两个特点：
> 1、直接对它赋值可能产生隐式动画；
> 2、我们的CAAnimation的keyPath可以设置为这个属性的名字。

当我们直接对可动画属性赋值的时候，由于有隐式动画存在的可能，CALayer首先会判断此时有没有隐式动画被触发。它会让它的delegate（没错CALayer拥有一个属性叫做delegate）调用actionForLayer:forKey:来获取一个返回值，这个返回值在声明的时候是一个id对象，当然在运行时它可能是任何对象。这时CALayer拿到返回值，将进行判断：如果返回的对象是一个nil，则进行默认的隐式动画；如果返回的对象是一个[NSNull null] ，则CALayer不会做任何动画；如果是一个正确的实现了CAAction协议的对象，则CALayer用这个对象来生成一个CAAnimation，并加到自己身上进行动画。

根据上面的描述，我们可以进一步完善我们上一章中重写的CALayer的属性的setter方法，拿position作例子：

```
- (void)setPosition:(CGPoint)position{
//    [super setPosition:position];
if ([self.delegate respondsToSelector:@selector(actionForLayer:forKey:)]) {
id obj = [self.delegate actionForLayer:self forKey:@"position"];
if (!obj) {
// 隐式动画
} else if ([obj isKindOfClass:[NSNull class]]) {
// 直接重绘（无动画）
} else {
// 使用obj生成CAAnimation
CAAnimation * animation;
[self addAnimation:animation forKey:nil];
}
}
// 隐式动画
}

```
#### UIView的block动画
有趣的是，如果这个CALayer被一个UIView所持有，那么这个CALayer的delegate就是持有它的那个UIView，结合上一章讲的CALayer的各个属性是如何与UIView交互的，大家应该可以思考出这样的问题：为什么同样的一行代码在block里面就有动画在block外面就没动画，就像下面这样：

```
// 这样写没有动画
view.center = CGPointMake(80, 80);
[UIView animateWithDuration:1.25 animations:^{
// 写在block里面就有动画
view.center = CGPointMake(80, 80);
}];
```
既然UIView就是CALayer的delegate，那么actionForLayer:forKey:方法就是由UIView来实现的。所以UIView可以相当灵活的控制动画的产生。
当我们对UIView的一个属性赋值的时候，它只是简单的调用了它持有的那个CALayer的对应的属性的setter方法而已，根据上面的可动画属性的特点，CALayer会让它的delegate（也就是这个UIView）调用actionForLayer:forKey:方法。实际上结果大家都应该能想得到：在UIView的动画block外面，UIView的这个方法将返回NSNull，而在block里面，UIView将返回一个正确的CAAction对象（这里将不深究UIView是如何判断此时setter的调用是在动画block外面还是里面的）。
为了证明这个结论，我们将继续进行实验：

```

NSLog(@"%@",[view.layer.delegate actionForLayer:view.layer forKey:@"position"]);

[UIView animateWithDuration:1.25 animations:^{
NSLog(@"%@",[view.layer.delegate actionForLayer:view.layer forKey:@"position"]);
}];

```
我们分别在block外面和block里面打印actionForLayer:forKey:方法的返回值，看看它究竟是什么玩意:
![](http://img.blog.csdn.net/20151210111735996)
打印发现，我们的结论是正确的：在block外面，这个方法将返回一个NSNull（是尖括号的null，nil打印出来是圆括号的null），而在block里面返回了一个叫做UIViewAdditiveAnimationAction类的对象，这个类是一个私有类，遵循了苹果一罐的命名规范： xxAction，一定就是一个实现了CAAction协议的对象了。
这也就说明了为什么我们对一个view的center赋值，如果这行代码在动画block里面，就会有动画，在block外面则没有动画。
#### 注意
1、 如果你的代码大概是这样的：

```
view.center = CGPointMake(80, 80);
[UIView animateWithDuration:1.25 animations:^{
view.center = CGPointMake(80, 80);
} completion:^(BOOL finished) {
NSLog(@"aaa");
}];

```
那么completion里面的block将会瞬间被调用而不是1.25秒之后调用，因为你这样写的动画是没有意义的（从一个地方移动到这个地方），所以就没有动画产生，也就是动画一开始就结束了。
2、 如果你的代码大概是这样的：

```
[UIView animateWithDuration:1.25 animations:^{
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
view.center = CGPointMake(80, 80);
});
} completion:^(BOOL finished) {
NSLog(@"aaa");
}];

```
也就是在动画block里面延迟调用一段代码，同样是没有卵用的，completionBlock将会直接被调用，因为当animateWithDuration…这个类方法被调用的时候animationBlock里面没有任何与动画相关的代码（view.center = CGPointMake(80, 80);这行代码被延迟调用了），UIView就认为你没有在里面写东西，那么肯定就没有动画了。接着两秒后，视图就瞬移了，因为当view.center = CGPointMake(80, 80);真正被调用的时候，animateWithDuration…这个方法早就返回了，这次调用肯定发生在动画block之外。

#### 再次深入
我们继续深入探究一下，看看动画是怎样被加到CALayer上的。
还记得我们上一章中用来做实验的一个UIView一个私有的CALayer么，这里我们继续使用它们来完成我们的实验。
找到我们的TestAnimationView和它的私有CALayer：TestAnimationLayer。在TestAnimationView中重写方法：
```
- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event{
id<CAAction> obj = [super actionForLayer:layer forKey:event];
NSLog(@"%@",obj);
return obj;
}
```
打好断点，然后在TestAnimationLayer中重写方法：

```
- (void)addAnimation:(CAAnimation *)anim forKey:(NSString *)key{
[super addAnimation:anim forKey:key];
NSLog(@"%@",[anim debugDescription]);
}

```
同样打好断点。接下来在ViewController中调用一下：

```
- (void)viewDidLoad {
[super viewDidLoad];
TestAnimationView * view = [[TestAnimationView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
[self.view addSubview:view];

[UIView animateWithDuration:1.25 animations:^{
view.center = CGPointMake(80, 80);
} completion:^(BOOL finished) {
NSLog(@"aaa");
}];
}

```
在view.center = CGPointMake(80, 80);这里打断点，然后运行。
一开始断点会疯狂的进入actionForLayer方法，因为我们调用initWithFrame的时候view会调用createLayerWithFrame:（见上一章），如果大家打印event参数，会发现在createLayerWithFrame:方法中，系统会依次给layer的以下几个属性赋值：bounds, opaque, contentsScale, rasterizationScale, position，所以actionForLayer:forKey:方法会被调用5次，这5次是在动画block外面调用的，所以我们会发现obj打印出来都是NSNull。
接下来断点会进入到动画block里面，继续执行，肯定就又会进入actionForLayer:forKey:方法，事实也是如此，并且这次打印obj，出来的就是那个实现了CAAction协议的私有类了。我们再次继续执行，这时断点会进入到TestAnimationLayer中的addAnimation方法中。调用NSLog(@”%@”,[anim debugDescription]);后我们会打印出这样的内容：
![](http://img.blog.csdn.net/20151210112135242)
***没错，UIView将CAAction返回给layer后，layer使用这个对象生成了一个CABasicAnimation并且调用了[self addAnimation..]。***通过这个CABasicAnimation对象的信息我们可以知道很多东西：
> 首先是additive这个属性为true（它默认为false），这就导致了fromValue和toValue的值显得似乎很奇怪。关于additive干了什么事情，我们在后面的章节将会提到。

> 接下来是delegate，CAAnimation将在动画结束后回调它delegate的animationDidStop方法，我们发现这个delegate又是一个私有类，因为我们在调用UIView动画的时候设置了completionBlock，也就是动画结束后要调用的block，所以UIView会将这个私有delegate的信息放进CAAction对象中告知CALayer动画结束后我要干事情（调用这个block）。

> 关于fillMode和timingFunction我们将在探究动画时间的时候来详细对它进行讲解。这里你会发现timingFunction默认的是easeInEaseOut，也就是淡入淡出效果。
> 
> keyPath被设置为了position，那是因为我们在动画block中是对center赋值，对应到layer中就是position了。

#### 总结
CALayer中有大量属性在注释的时候标记了Animatable，表示这个属性是可动画的。可动画的属性具有两个特点：1、直接对它赋值可能产生隐式动画；2、我们的CAAnimation的keyPath可以设置为这个属性的名字。

当我们对这些属性赋值的时候，layer会让它的delegate调用actionForLayer:forKey:方法获取一个返回值，这个返回值可能是这样几种情况：1、是一个nil，则layer会走自己的隐式动画；2、是一个NSNull，则layer不会做任何动画；3、是一个实现了CAAction协议的对象，则layer会用这个对象生成一个CABasicAnimation加到自己身上执行动画。

有趣的是，如果一个UIView持有一个CALayer，那么这个layer的delegate就是这个view。当我们对view的一个属性，比如center赋值的时候，view同时会去对layer的position赋值。这时layer会让它的delegate（就是这个view）调用actionForLayer:forKey:方法，UIView在这个方法中是这样实现的：如果这次调用发生在[UIView animateWithDuration:animations:]的动画block里面，则UIView生成一个CAAction对象，返回给layer。如果没有发生在这个block外面，则返回NSNull。这也就说明了为什么我们对一个view的center赋值，如果这行代码在动画block里面，就会有动画，在block外面则没有动画。


### 三、CALayer的模型层与展示层
#### 前言
上一章中我们介绍了CALayer的可动画属性，然后研究了UIView的block动画实现原理。这一章我们将深入CALayer内部，通过简单的CABasicAnimation动画来探究CALayer的两个非常重要的属性：presentationLayer和modelLayer。
#### 让我们从一个改变位置的动画开始
我们可以使用CABasicAnimation来实现各种动画，假如我们想让一个视图从一个位置动画地移动到另一个位置，我们的代码可能会这样写：

```
CABasicAnimation * animation = [CABasicAnimation animation];
animation.keyPath = @"position";
animation.duration = 2;
animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(80, 80)];
animation.toValue = [NSValue valueWithCGPoint:CGPointMake(200, 300)];
[view.layer addAnimation:animation forKey:nil];
```
也就是指定了动画的四要素：动什么（keyPath）、动多久（duration）、从什么样子开始（fromValue）、动到什么样子（toValue）。这样CABasicAnimation就能在duration内对keyPath指定的属性从fromValue到toValue之间进行插值（关于插值我们在技巧篇会详细讲解，这里你只需要知道CABasicAnimation是一帧一帧在重新绘制视图的）。然后我们将动画施加于view的layer，这样它就会按照我们的四要素进行动画了。
完整的代码如下：

```
- (void)viewDidLoad {
[super viewDidLoad];
self.view.backgroundColor = [UIColor whiteColor];
UIView * view = [[UIView alloc] initWithFrame:CGRectMake(80, 80, 100, 100)];
view.backgroundColor = [UIColor blueColor];
[self.view addSubview:view];
CABasicAnimation * animation = [CABasicAnimation animation];
animation.keyPath = @"position";
animation.duration = 2;
animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(80, 80)];
animation.toValue = [NSValue valueWithCGPoint:CGPointMake(200, 300)];
[view.layer addAnimation:animation forKey:nil];
}

```
注意到fromValue和我们初始化view时的center不一样。 
我们运行一下将会有如下效果：
![](http://img.blog.csdn.net/20151223165138882)
#### 举个栗子说明presentationLayer和modelLayer
从前有一个瞎子和一个瘸子，瘸子看得见路，但是不能自己走，瞎子能自己走，但是他看不见路。于是他们想到了一个办法：瞎子背着瘸子，这样瘸子就指挥瞎子如何走路，瞎子负责走路，每走一步，瞎子都会停下来听从瘸子的指挥，这样他们就不紧不慢的走向了目的地。

在CALayer内部也有一个瞎子和一个瘸子：presentationLayer（以下简称P）和modelLayer（以下简称M）。presentationLayer负责走路（绘制内容），而modelLayer负责看路（如何绘制）。

P有这样的特点：
> 1、我们看到的一切，都是P的内容； 
> 2、P只在下次屏幕刷新时才会进行绘制。
M有这样的特点：
> 1、我们我们对CALayer的各种绘图属性进行赋值和访问实际上都是访问的M的属性，比如bounds、backgroundColor、position等； 
> 2、对这些属性进行赋值，不会影响P，也就是不会影响绘制内容。 你可以把M理解成一个隐身的家伙，只有P才能感知它的存在。

那么为什么我们对M的属性进行赋值，“与此同时”视图的显示状态就会发生改变呢？

如果我们用t0表示我们对属性进行赋值的时刻，t1表示下次屏幕刷新的时刻，t0到t1之间的间隔相当短（小于1/60秒），我们的人眼根本察觉不到这样的间隔时间存在，所以我们的感觉就是：赋值和界面绘制是同时进行的。然而实际上，赋值和界面绘制之间有一个t1-t0的时间间隔。

所以总结以上信息，我们可以知道P和M是这样进行交互的：当下次屏幕刷新信号到来时（屏幕重绘时），P为了绘制内容到屏幕上，它会去找M要各种它需要的用来绘制的属性，然后用这些属性的信息来绘制。
直到屏幕刷新信号到来才进行绘制，这种方式能够极大提高绘制效率。考虑这样一种情况，如果连续写了以下三行代码：view.frame = …; view.backgounrdColor = …; view.center = …;，如果每次赋值就会导致屏幕的重绘，这样就会有三次重绘，也就是GPU会执行三次绘制操作。而如果我们先把绘制信息存起来，当需要绘制的时候（屏幕刷新）再用这些信息去重绘，GPU就只会执行一次绘制操作。如果不能理解这样做的优势，我们将会在实战篇讲述如何提高性能的时候再次带大家了解绘图机制，也就是你看到的一切究竟是如何被显示出来的。

上面三行代码，只是对M的属性赋值了而已，没有任何的绘制操作，当下次屏幕刷新信号到来时，P才会去找M要这些属性，进行一次绘制。执行这三次赋值（执行三行代码）所需的时间远远小于两次屏幕刷新的间隔，所以这样三行代码是一定能够在下次绘制开始前执行完的。也就是说，当我们写了这三行代码后，视图的显示内容不会改变三次，而只会改变一次。

如果我们继续按照瞎子和瘸子的理论进行下去，P背着M，如果我们在下次屏幕刷新前（P走下一步之前）对M进行了三次操作：把M移动到点1，把M移动到点2，把M移动到点3。那么下次屏幕刷新时，P会直接问M“你在哪啊”，M说我在点3呢，你这样这样走过来，于是P就屁颠屁颠的按照M的指挥跑到点3去了，它是不会先跑到点1再跑到点2再跑到点3的。
#### CAAnimation对presentationLayer的控制
P这个瞎子背着M这个瘸子，他们互帮互助，完成各种显示的逻辑。每当屏幕刷新的时候，如果没有其他的信息告诉P它应该如何绘制，那么P就只能去问M，然后回到M的状态。

这样一个平衡会在一个CAAnimation被加到CALayer上后会被打破。当我们调用了layer的addAnimation方法后，一个CAAnimation（以下简称A）就控制了P，就相当于A一脚把M从P身上踹了下来然后自己爬了上去（不要想歪）。

现在P要如何显示就完全由A来控制了，因为A被指定了在duration中从fromValue变到toValue。所以在动画的持续时间内，M被丢在了原地，P则背着A到处跑（毕竟P是个瞎子，根本不知道他脑袋顶上的家伙是谁），每一步该如何走都是A通过插值计算出来的（通过duration、from、to就能计算任意时刻P的状态了）。
动画结束后，默认情况A就被移除了，这时候P身上啥也没有了。那么在下一次屏幕刷新的时候，没有其他的信息告诉P它应该如何绘制，所以它就又开口了“M你在哪里啊”，M说“劳资在这里”（在动画过程当中它就没被动过，除非你手动设置了M的值），“你怎么跑那里去了”，“要你管，快给我滚过来”（真是一对好CP）。于是P就屁颠屁颠的滚到M那里去了，所以动画结束后，你会看到视图又回去了。

如果想要P在动画结束后就停在当前状态而不回到M的状态，我们就需要给A设置两个属性，一个是A.removedOnCompletion = NO;表示动画结束后A依然影响着P，另一个是A.fillMode = kCAFillModeForwards，（关于fillMode到底干了什么我们将在下一章详细进行讲解），这两行代码将会让A控制住P在动画结束后保持不变（不会回到M的状态），我们一开始的代码就会写成这个样子：

```
- (void)viewDidLoad {
[super viewDidLoad];
self.view.backgroundColor = [UIColor whiteColor];
UIView * view = [[UIView alloc] initWithFrame:CGRectMake(80, 80, 100, 100)];
view.backgroundColor = [UIColor blueColor];
[self.view addSubview:view];
CABasicAnimation * animation = [CABasicAnimation animation];
animation.keyPath = @"position";
animation.duration = 2;
animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(80, 80)];
animation.toValue = [NSValue valueWithCGPoint:CGPointMake(200, 300)];
animation.removedOnCompletion = NO;
animation.fillMode = kCAFillModeForwards;
[view.layer addAnimation:animation forKey:nil];
}

```
运行一下，我们的动画终于停在了终点处，就像这样：
![](http://img.blog.csdn.net/20151223165652502)
#### 模型与显示的同步
我们可以通过设置removedOnCompletion = NO以及fillMode来让动画结束后保持状态，但是此时我们的P和M不同步，我们看到的P是toValue的状态，而M则还是自己原来的状态。举个栗子，我们初始化一个view，它的状态为1，我们给它的layer加个动画，from是0，to是2，设置fillMode为kCAFillModeForewards，则动画结束后P的状态是2，M的状态是1，这可能会导致一些问题出现。比如你点P所在的位置点不动，因为响应点击的是M。所以我们应该让P和M同步。

在CABasicAnimation的文档中写了这样一句话：如果不设置toValue，则CABasicAnimation会从fromValue到M的值之间进行插值。也就是说，如果不设置toValue，则CABasicAnimation会把M的值作为toValue，所以我们就可以在加动画的时候只设置fromValue，再手动修改M的值到你想要动画停止的那个状态就保持同步了。

我们可以扩展到任意的CAAnimation对象，比如CAKeyFrameAnimation，都可以通过设置M的值到动画结束的状态来保持P和M的同步。
所以我们的代码可能就会写成这样：

```
(void)viewDidLoad {
[super viewDidLoad];
self.view.backgroundColor = [UIColor whiteColor];
UIView * view = [[UIView alloc] initWithFrame:CGRectMake(80, 80, 100, 100)];
view.center = CGPointMake(200, 300);
view.backgroundColor = [UIColor blueColor];
[self.view addSubview:view];
CABasicAnimation * animation = [CABasicAnimation animation];
animation.keyPath = @"position";
animation.duration = 2;
animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(80, 80)];
//    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(200, 300)];
//    animation.removedOnCompletion = NO;
//    animation.fillMode = kCAFillModeForwards; 
[view.layer addAnimation:animation forKey:nil];
}

```
当我们写view.center = CGPointMake(200, 300);的时候，只是对M赋值，再次强调，它不会影响P的显示，而当P想要显示的时候，它已经被A控制了，所以P会从一开始就在80,80那里然后动画地移动到200,300，不会出现先在200,300那里闪一下的情况。 
运行一下，效果就是这样：
![](http://img.blog.csdn.net/20151223165812366)
#### 总结
在CALayer内部，它控制着两个属性：presentationLayer(以下称为P)和modelLayer（以下称为M）。P只负责显示，M只负责数据的存储和获取。我们对layer的各种属性赋值比如frame，实际上是直接对M的属性赋值，而P将在每一次屏幕刷新的时候回到M的状态。比如此时M的状态是1，P的状态也是1，然后我们把M的状态改为2，那么此时P还没有过去，也就是我们看到的状态P还是1，在下一次屏幕刷新的时候P才变为2。而我们几乎感知不到两次屏幕刷新之间的间隙，所以感觉就是我们一对M赋值，P就过去了。

P就像是瞎子，M就像是瘸子，瞎子背着瘸子，瞎子每走一步（也就是每次屏幕刷新的时候）都要去问瘸子应该怎样走（这里的走路就是绘制内容到屏幕上），瘸子没法走，只能指挥瞎子背着自己走。可以简单的理解为：一般情况下，任意时刻P都会回到M的状态。

而当一个CAAnimation（以下称为A）加到了layer上面后，A就把M从P身上挤下去了。现在P背着的是A，P同样在每次屏幕刷新的时候去问他背着的那个家伙，A就指挥它从fromValue到toValue来改变值。而动画结束后，A会自动被移除，这时P没有了指挥，就只能大喊“M你在哪”，M说我还在原地没动呢，于是P就顺声回到M的位置了。这就是为什么动画结束后我们看到这个视图又回到了原来的位置，是因为我们看到在移动的是P，而指挥它移动的是A，M永远停在原来的位置没有动，动画结束后A被移除，P就回到了M的怀里。

动画结束后，P会回到M的状态（当然这是有前提的，因为动画已经被移除了，我们可以设置fillMode来继续影响P），但是这通常都不是我们动画想要的效果。我们通常想要的是，动画结束后，视图就停在结束的地方，并且此时我去访问该视图的属性（也就是M的属性），也应该就是当前看到的那个样子。按照官方文档的描述，我们的CAAnimation动画都可以通过设置modelLayer到动画结束的状态来实现P和M的同步。


### 四、动画时间控制
#### 前言
这一章虽然叫做动画时间控制，然而我们并不会去深入到一般的动画时间中，我们将讨论的是CoreAnimation框架是如何来控制时间的。 
#### CAMediaTiming协议
动画所有跟时间相关的属性（duration, beginTime, repeatCount等）都来自于CAMediaTiming协议，它由CABasicAnimation和CAKeyframeAnimation的父类CAAnimation实现。协议一共定义了8个属性，通过这8个属性就能完全地控制动画时间。每个属性的文档只有短短几句话，当然你也可以通过阅读这些文档并且手动进行试验来进行学习，不过我认为更容易让人理解的方式是将时间可视化。
#### 可视化的CAMediaTiming协议
为了向你们展示不同的时间相关属性，包括这个属性自己单独使用的效果以及和其他属性混合使用的效果，我将执行一个从橘黄色到蓝色转换的动画。下图展示了从动画开始到动画结束的进程（橘色到蓝色），每一格代表一秒，时间线上任意一点对应到图上的颜色就是视图在这一瞬间的颜色。比如，duration这个属性将被如下进行可视化展示：

##### duration
duration设置为1.5秒，所以动画将耗费1秒加上1秒的一半来从橘色完全变为蓝色。
![](http://img.blog.csdn.net/20160607171805289)
> 图一.     将duration设为1.5秒
默认地，CAAnimation将会在动画完成后被移除，这在上面同样被可视化出来了，一旦动画到达了结束值，它就会被从layer上移除，所以layer的背景色将会返回到modelLayer的状态（见上一章：CALayer的模型层与展示层）。在这个可视化例子中，layer本身的背景色是白色，所以你看到的上图的可视化效果中，在1.5秒后的额外的2.5秒钟的时间里layer的背景色回到了白色。
##### beginTime
如果我们将动画的beginTime加入到可视化效果中就能看到更多的情形。
![](http://img.blog.csdn.net/20160607171902211)
> 图二. 将duration设为1.5秒，将开始时间设为1.0秒
将动画持续时间设为1.5秒，开始时间设为当前时间（CACurrentMediaTime()）加上1秒所以动画将在2.5秒后结束。在动画被加到layer上之后它将等待1秒然后再开始（相当于动画延迟时间为1秒）。
##### fillMode
如果要让动画在开始之前（延迟的这段时间内）显示fromValue的状态，你可以设置动画向后填充：设置fillMode为kCAFillModeBackwards。
![](http://img.blog.csdn.net/20160607171951696)
> 图三、填充模式可以用来在动画开始之前显示fromValue。

##### autoreverses
将使动画先正常走，完了以后反着从结束值回到起始值（所有动画属性都会反过来，比如动画速度，如果正常的是先快后慢，则反过来后变成先慢后快）。
![](http://img.blog.csdn.net/20160607172030447)
> 图四. Autoreverse将使动画在结束后又回到动画开始的状态

##### repeatCount
相比之下，repeatCount可以让动画重复执行两次（首次动画结束后再执行一次，正如你下面将看到的）或者任意多次（你甚至可以将重复次数设置为小数，比如设置为1.5，这样第二次动画只执行到一半）。一旦动画到达结束值，它将立即返回到起始值并且重新开始。
![](http://img.blog.csdn.net/20160607172100057)
> 图五、repeatCount让动画在结束后再次执行

##### repeatDuration
类似于repeatCount，但是极少会使用。它简单地在给定的持续时间内重复执行动画（下面设置为2秒）。如果repeatDuration比动画持续时间小，那么动画将提前结束（repeatDuration到达后就结束）
![](http://img.blog.csdn.net/20160607172220666)
> 图七. 把几个属性结合起来用

##### speed
这是一个非常有意思的时间相关的属性。如果把动画的duration设置为3秒，而speed设置为2，动画将会在1.5秒结束，因为它以两倍速在执行。
![](http://img.blog.csdn.net/20160607172247541)
> 图八. Speed设置为2将会使动画的速度变为2倍所以3秒的动画将只用1.5秒就能执行完

speed属性的强大之处来自以下两个特点： 
**1、 动画速度是有层级关系的 
2、 CAAnimation并不是唯一的实现了CAMediaTiming协议的类。**

#### 动画速度的分层表示
一个动画的speed为1.5，它同时是一个speed为2的动画组的一个动画成员，则它将以3倍速度被执行。
#### CAMediaTiming协议的其他实现
CAAnimation实现了CAMediaTiming协议，然而CoreAnimation最基本的类：CALayer也实现了CAMediaTiming协议。这意味着你可以给一个CALayer设置speed为2，那么所有加到它上面的动画都将以两倍速执行。这同样符合动画时间层级，比如你把一个speed为3的动画加到一个speed为0.5的layer上，则这个动画将以1.5倍速度执行。

控制动画和layer的速度同样可以用来暂停动画，你只需要把speed设为0就行了。结合timeOffset属性，就可以通过一个外部的控制器（比如一个UISlider）来控制动画了，我们将在这一章较后的内容中进行讲解。
##### timeOffset
timeOffset这个属性啊，一开始看起来挺奇怪的，光看名字的话，看起来应该是一个用来控制动画时间进程（计算动画当前状态）的属性。下面这个可视化展示了一个持续时间为3秒，动画时间偏移量为1秒的动画。
![](http://img.blog.csdn.net/20160607172354404)
> 图9.你可以偏移整个动画但是动画还是会走完全部过程

这个动画将从正常动画（timeOffset为0的状态）的第一秒开始执行，直到两秒后它完全变蓝，然后它一下子跳回最开始的状态（橙色）再执行一秒。就像是我们把正常动画的第一秒给剪下来粘贴到动画最后一样。
这个属性实际上并不会自己单独使用，而会结合一个暂停动画（speed=0）一起使用来控制动画的“当前时间”。暂停的动画将会在第一帧卡住，然后通过改变timeOffset来随意控制动画进程，因为如上图所示，动画的第一帧就是timeOffset指定的那一帧。

举个例子：比如一个改变位置的动画，让一个视图从(0,0)移动到(100,100)，持续时间为1秒。如果先暂停动画，然后设置timeOffset为0.5，那么首先动画会卡在“第一帧”，而第一帧由timeOffset决定，也就是动画正常运作时间进行到0.5秒的那一帧就是“第一帧”，这时候动画就会停在(50,50)的地方。注意timeOffset是具体的秒数而不是百分比。

#### 更多的动画时间可视化插图
![](http://img.blog.csdn.net/20160607172421557)


#### 控制动画时间
结合使用speed和timeOffset属性可以轻松控制一个动画当前显示的内容。为了方便起见，我将把动画持续时间设为1秒。timeOffset/duration这个分数的值表示动画进行的百分比，把duration设为1的话，在数值上timeOffset就等于动画进程百分比了。

##### Slider
我们首先创建一个CABasicAnimation来创建一个改变layer背景颜色的动画并把它添加到layer上，然后把layer的speed属性设为0来暂停动画。

```
CABasicAnimation *changeColor =
[CABasicAnimation animationWithKeyPath:@"backgroundColor"];
changeColor.fromValue = (id)[UIColor orangeColor].CGColor;
changeColor.toValue   = (id)[UIColor blueColor].CGColor;
changeColor.duration  = 1.0; // For convenience

[self.myLayer addAnimation:changeColor
forKey:@"Change color"];

self.myLayer.speed = 0.0; // Pause the animation

```
然后在slider被拖动的action方法中，我们把slider的当前值（默认0到1，刚好也是动画timeOffset的范围）设为layer的timeOffset的值。

```
- (IBAction)sliderChanged:(UISlider *)sender {
self.myLayer.timeOffset = sender.value; // Update "current time"
}

```
这样的效果就像我们通过拖动一个slider来改变一个layer的背景颜色：
![](http://img.blog.csdn.net/20160607172601324)

#### 关于fillMode和Ease的补充
以上对于fillMode的说明比较简单，而且在动画的时间控制中还有一个比较重要的类：CAMediaTimingFunction，将在这里比较详细为大家进行讲解

##### fillMode
这个概念如果用文字来描述是比较难理解的，所以我将启用我的灵魂画板来讲解这个概念。

为了更好的理解，我们首先定义四个时间点：t0表示动画被加到layer上的一刻；t1表示动画开始的一刻；t2表示动画结束的一刻；t3表示动画从layer上移除的一刻（这四个时间点也可以叫做动画的生命周期）。

这里有少年可能会问，呐，动画加到layer上不就是动画开始的时候么？你忘记考虑延迟了！如果没有延迟，那么t0和t1确实是同一个时刻，但是一旦动画有了延迟，那么t0和t1就相差一个延迟了。同样的道理，默认情况下，动画一旦结束就会从layer上自动移除，也就是默认情况下t2和t3也是同一时刻，但是如果我们设置了removedOnCompletion = false，那么t3就会无限向前延伸直到我们手动调用layer的removeAnimation方法。

我们来写一个简单的动画，比如修改透明度的动画。modelLayer的属性一开始是0.5，然后我们写一个动画把透明度从0修改为1，持续时间1秒并设置一个1秒的延迟（t0-t1、t1到t2都相差1秒），动画结束后不立即移除动画。 

如果你想在视图一出现就开始动画，请把动画写到viewDidAppear里面，不要写到viewDidLoad里面。

```
- (void)viewDidAppear:(BOOL)animated{
CALayer * layer = [CALayer layer];
layer.frame = CGRectMake(100, 100, 200, 200);
layer.opacity = 0.5;
layer.backgroundColor = [UIColor yellowColor].CGColor;
[self.view.layer addSublayer:layer];

CABasicAnimation * animation = [CABasicAnimation animation];
animation.keyPath = @"opacity";
animation.fromValue = @0;
animation.toValue = @1;
animation.duration = 1;
animation.beginTime = CACurrentMediaTime() + 1;
animation.removedOnCompletion = false;
[layer addAnimation:animation forKey:@"opacity"];
}

```
好了，那么我们一副草稿图来表示动画过程中P（presentationLayer）和M（modelLayer）的属性的值。在灵魂画板中，因为0.5这个数字画起来太麻烦了，我就同时扩大两倍，在灵魂画板中的1就是0.5，2就是1。根据P和M的规则，M肯定在整个过程中的值都是0.5（在灵魂画板中表现为1），而P在t0到t1由于动画并没有被告知如何影响P，所以会保持M的状态也就是0.5，然后在t1到t2（动画开始到动画结束）从0到1进行插值，到了t2动画结束，此时动画不知道如何影响P，所以P保持M的状态也就是回到0.5：
![](http://img.blog.csdn.net/20160607172811184)
这是一般情况，大家可以运行看一下结果：在开始的一秒（t0-t1：延迟的过程）整个layer是一个透明度为0.5的状态，延迟结束，开始动画（t1-t2），这一秒中layer会一下子闪到透明度为0的状态然后动画的变到透明度为1的状态。动画结束后（t2-t3），P回到M的状态，变为0.5的透明度状态。 

现在我们加上fillMode 
我们设置fillMode为向前填充：

```
animation.fillMode = kCAFillModeForwards;
```
这里有两个概念：向前、填充。

什么是向前，向前就是朝着时间的正方向。

那么填充又是什么呢？因为t2到t3这段时间动画并不知道如何影响P，所以对于这段时间来讲，P的状态应该是“空”的，如果是空，那么P就会保持M的状态。而填充，就是把P的这些“空”的状态用具体的值填起来。由于我们的动画的keypath是opacity，所以就会对P的opacity在t2-t3这段时间进行填充，而填充的规则是“向前”，也就是“t2向t3填充”，说直白一点，就是t2到t3这个时间段P的opacity的值就一直保持t2的时候P的opacity的值，实际上就是动画的toValue的值。

如图：
![](http://img.blog.csdn.net/20160607172851176)
这样的话，直到动画被移除，P都会保持toValue也就是透明度为1的状态，效果就是动画结束后不会闪回动画开始之前的那个状态而保持结束值的状态。

这样一来，向后填充就比较好理解了：

向后填充是t0到t1，由于向后是时间的负方向，所以就是P的状态在t0到t1这段时间由t1向t0填充，也就是t0到t1的时间段P保持t1时刻的状态也就是fromValue的状态。这样设置的效果就是在延迟的时间里面P保持fromValue的状态，就避免了动画一开始P从M的状态就闪到fromValue的状态：

```
animation.fillMode = kCAFillModeBackwards;

```
![](http://img.blog.csdn.net/20160607172915997)
如果既想向前填充又想向后填充，那么久把fillMode设置为both：

```
animation.fillMode = kCAFillModeBoth;
```


##### Ease
关于ease效果，在CAAnimation中表现为timingFunction这个属性，它需要设置一个CAMediaTimingFunction对象，实际上是指定了一个曲线，作为s-t函数图像，s是竖轴，代表动画的进程，0表示动画开始，1表示动画结束；t是横轴，代表动画当前的时间，0表示开始的时候，1表示结束的时候。曲线上一点的切线斜率表示这一时刻的动画速度。可以高中物理的直线运动的位移-时间图像。 

系统自带了几种ease效果，可以通过代码来实现，使用functionWithName:这个类方法来通过函数名字来指定函数曲线:

```
CA_EXTERN NSString * const kCAMediaTimingFunctionLinear
__OSX_AVAILABLE_STARTING (__MAC_10_5, __IPHONE_2_0);
CA_EXTERN NSString * const kCAMediaTimingFunctionEaseIn
__OSX_AVAILABLE_STARTING (__MAC_10_5, __IPHONE_2_0);
CA_EXTERN NSString * const kCAMediaTimingFunctionEaseOut
__OSX_AVAILABLE_STARTING (__MAC_10_5, __IPHONE_2_0);
CA_EXTERN NSString * const kCAMediaTimingFunctionEaseInEaseOut
__OSX_AVAILABLE_STARTING (__MAC_10_5, __IPHONE_2_0);
CA_EXTERN NSString * const kCAMediaTimingFunctionDefault
__OSX_AVAILABLE_STARTING (__MAC_10_6, __IPHONE_3_0);

```
每个名字的函数图像在网上随处可见，如果简单的来理解，那么Linear就表示线性的，也就是s-t图像是一条直线，明显就是匀速运动了；EaseIn表示淡入，也就是匀加速启动，或者理解为先慢后快；EaseOut表示淡出，也就是匀减速停止，或者理解为先快后慢。EaseInEaseOut就是既有淡入效果也有淡出效果。Default是一种平滑启动平滑结束的过程，类似EaseInEaseOut，但是效果没那么显著。
除了functionWithName，系统允许我们使用一条贝塞尔曲线作为函数图像：

```
+(instancetype)functionWithControlPoints:(float)c1x :(float)c1y :(float)c2x :(float)c2y;

```
这个方法有四个参数，前两个参数表示贝塞尔曲线的第一个控制点，后两个参数表示贝塞尔曲线的第二个控制点。起点是(0,0)而终点是(1,1)，所以是一条三阶贝塞尔曲线。注意到函数的定义域和值域都是[0,1]，所以控制点的x和y的值要计算好。关于贝塞尔曲线如果不太了解，可以在维基百科这里获得公式和表现形式：http://en.wikipedia.org/wiki/Bezier_curve#Generalization
## 技巧篇
### 一、CADisplayLink –同步屏幕刷新的神器
#### iOS绘图系统
虽然CoreAnimation框架的名字和苹果官方文档的简介中都是一个关于动画的框架，但是它在iOS和OS X系统体系结构中扮演的角色却是一个绘图的角色。

[官方文档](https://developer.apple.com/library/prerelease/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html)

系统体系结构：
![](http://img.blog.csdn.net/20160803113408607)

可以看到，最上面一层是是应用层（UI层），直接和用户打交道（UIKit框架也就是干这件事的），而真正的绘图层则在下面一层，绿色的这一层。绘图层由3个部分组成：最上面是CoreAnimation，是面向对象的。往下就是更底层的东西了：OpenGL和CoreGraphics，它们提供了统一的接口来访问绘图硬件。而绘图硬件则是绘图真正发生的地方。那我们就可以这样来理解这个体系结构：真正干事的是绘图硬件（通常是GPU），也就是最下面那一块，它负责把像素画到屏幕上。而我们为了命令它画图（如何绘制）需要有方法能访问到它，当然这种硬件层面的东西肯定不能直接访问的，操作系统一定会做限制（如果不加以限制的话可能一些错误的操作将导致系统故障），这里就和面向对象的封装很像了，操作系统封装了硬件层，只提供简单的能够由开发者直接访问的接口，而不同的硬件可能有不同的封装方式，直接访问起来势必相当麻烦（我们的代码需要适配不同的硬件），于是就有了OpenGL，它统一了所有绘图硬件的接口，我们使用OpenGL提供的同一套API就能控制任意的绘图硬件了。而OpenGL虽然很强大，但是很少会用到它一些复杂的功能，而简单的功能也是C语言不太好使用，所以具体地针对ios和OS X系统，苹果为我们封装了OpenGL，没错这就是CoreAnimation。

所以大家可以体会一下，实际上CoreAnimation虽然表面上更多的是提供了动画的功能，但是动画是基于绘图的，所以完全可以把CoreAnimation框架当做一个用来绘图的框架来处理。它直接提供的动画接口实际上是相当少的，而大量的提供了辅助动画的API，我们这里将用到一个大杀器：CADisplayLink。
#### FPS
首先我们从FPS的概念入手来帮助理解CADisplayLink。这里的FPS不是第一人称射击游戏，而是frame per second，也就是帧率，表示屏幕每秒钟刷新多少次。如果帧率为60，表示屏幕每秒刷新60次，并不代表每1/60秒刷新一次，只能表示在1秒钟的时间内屏幕会刷新60次，每次屏幕刷新的间隔并不一定是平均的。
#### 绘制动画
动画是一系列静态图片以极快的速度进行切换形成的，这个速度要快到人眼察觉不出其中的间隙（两张图片切换之间的间隔时间），具体地，这个切换频率必须大于人眼的刷新频率：每秒钟60次。也就是说，如果屏幕刷新频率大于每秒钟60次，那么我们人眼就感受不到两帧图片切换之间的间隙，所以我们感觉起来这些切换就是“连续”的，这就是动画的产生。也就是说，动画实际上就是以尽量大于60fps的速度在多张静态图片之间进行快速切换。
#### CADisplayLink
我们的屏幕每时每刻都在以>60fps的帧率进行刷新，每次刷新都会根据最新的绘制信息重绘屏幕上显示的内容，这样你才能顺利的看见各种动画，比如一个UITableView的滚动效果。CADisplayLink提供了API，每当屏幕刷新的时候，系统会回调我们向CADisplayLink注册的一个方法，也就是说，我们可以在屏幕每次刷新的时候调用一个我们自己的方法。基于上面对绘制动画的认识，肯定我们就能够像系统那样一帧一帧地画动画了。
#### 构建CADisplayLink
构建一个CADispalyLink非常的简单，我们先提供一个回调方法：
```
- (void)onDisplayLink:(CADisplayLink *)displayLink{
NSLog(@"display link callback");
}
```
接下来我们初始化一个displayLink，只有一个便利构造方法：

```
CADisplayLink * displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];

```
通过target-action的形式来向系统注册回调，然后向runloop中添加displayLink。这里要注意一下runloop中mode的概念。
> 一个runloop只能在某一个mode中跑，runloop可以在多个mode之间进行切换，默认的，系统提供了两个mode：NSDefaultRunloopMode和UITrackingRunloopMode。正常情况下是default，但是如果一个scrollView滑动的时候（UITableView是scrollView的子类）runloop就会切换到
> UITrackingRunloopMode，这时候所有往default里面添加的内容都没法跑起来了。这也是为什么，如果使用NSTimer的schedule方法来调度timer，当一个tableView滚动的时候timer会停止，就是因为schedule将把timer添加进default，而tableView滚动的时候runloop切换到了UITrackingRunloopMode，此时default中的timer就跑不起来了。

我们的CADisplayLink应该在这两种情况都能跑，所以我们可以这样来添加：

```
[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:UITrackingRunLoopMode];
```
这样就把displayLink添加进了两种mode，无论runloop处于哪种mode，我们的displayLink都能被系统调度。这里其实还有一种写法：

```
[displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
```
NSRunLoopCommonModes后面多了一个s，表示mode的复数形式，意味着多个mode，这里表示向所有被注册为common的mode中添加displayLink。实际上，NSDefaultRunloopMode和UITrackingRunloopMode都被系统注册成了common，所以这样写的效果和前一种是一样的，你在自己使用runloop的时候也可以自定义mode，然后把它注册成为common。

一旦我们把displayLink添加进了runloop，它就已经准备好进行回调了，每当屏幕刷新的时候，就会调用我们注册的回调方法。运行我们的程序，就会发现控制台开始疯狂的进行打印输出。NSLog是日志打印，所以能提供该次打印的系统时间，看看两次打印的间隔，是不是差不多在1/60秒左右。
#### 线性插值
为了实现基于CADisplayLink的动画，我们首先要弄清一个概念：插值。插值在不同的地方有不同的解释。大家思考一下，我们现在要自己在每一帧进行重绘来实现动画，想象这样一个动画：让一个质点从(10,20)点移动到(300,400)，持续时间2.78秒。我们要做的是，在每一次屏幕刷新的时候根据当前已经经历的时间（从动画开始到当前时间）计算出该质点的坐标点并更新它的坐标，也就是我们要解决的是：对于任意时刻t，质点的坐标是多少？

这里我们将引入线性插值，我们把问题改一下：你现在距离家f米，学校距离家t米，现在你要从当前的位置匀速走到学校，整个过程将持续d秒，问：当时间经过△t后，你距离家多远?

这是一道很简单的匀速直线运动问题，首先根据距离和持续时间来获得速度：
`v = (t-f)/d`
然后用速度乘以已经经过的时间来获得当前移动的距离：
`△s = v△t = (t-f)/d * △t`
最后再用已经移动的距离加上初始的距离得到当前距离家有多远：
`s = △s + f =  (t-f)/d * △t + f`
我们把上面的公式稍微变一下形：
`s = f + (t-f) * (△t/d)` 
这里令`p = △t/d`就有：
`s = f + (t-f) * p`
这就是线性插值的公式：
`value = from + (to - from) * percent`
from表示起始值，to表示目标值，percent表示当前过程占总过程的百分比（上个例子中就是当前已经经历的时间占总时间的百分比所以是△t/d），这个公式成立的前提是变化是线性的，也就是匀速变化，所以叫做线性插值。

有了这个公式，我们回到代码上面来，使用CADisplayLink加上线性插值来计算每帧所需的数据以实现一个匀速动画

#### 基于CADisplayLink的动画
我们已经构建好了CADisplayLink，剩下的只需要添加一个视图然后在CADisplayLink的回调方法中改变视图的坐标就行了，很明显，这个视图应该使用成员变量或者属性来声明。

```
@property (nonatomic, strong) UIView * myView;
```
实现属性的getter方法

```
- (UIView *)myView{
if (!_myView) {
_myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
_myView.backgroundColor = [UIColor yellowColor];
}
return _myView;
}
```
在viewDidLoad中添加：
```
[self.view addSubview:self.myView];
```
接下来我们用一个私有方法来实现线性插值的公式：
```
- (CGFloat)_interpolateFrom:(CGFloat)from to:(CGFloat)to percent:(CGFloat)percent{
return from + (to - from) * percent;
}
```
然后在onDisplayLink方法中解决以下问题：
1、 计算当前经历的时间 

2、 当前时间占总时间的百分比 

3、 利用线性插值计算当前的坐标 

4、 更新视图的坐标

首先是如何计算当前经历的时间，由于每次调用onDisplayLink的间隔都不是平均的，我们就不能通过调用次数乘以间隔来得到当前经历的时间，只能用当前时刻减去动画开始的时刻，所以我们声明一个属性用来记录动画开始的时刻：

```
@property (nonatomic, assign) NSTimeInterval beginTime;
```
在把CADisplayLink添加进runloop的代码后面赋值：
```
self.beginTime = CACurrentMediaTime();
```
这样我们就可以在onDisplayLink方法里面这样获取动画经历的时间了：
```
NSTimeInterval currentTime = CACurrentMediaTime() - self.beginTime;
```
然后计算出百分比，我们先在方法开头定义出动画的起始值、终止值、持续时间：
```
CGPoint fromPoint = CGPointMake(10, 20);
CGPoint toPoint = CGPointMake(300, 400);
NSTimeInterval duration = 2.78;
```
这样的话百分比就是：
```
CGFloat percent = currentTime / duration;
```
然后使用线性插值来计算视图的x和y，直接调用公式即可：
```
CGFloat x = [self _interpolateFrom:fromPoint.x to:toPoint.x percent:percent];
CGFloat y = [self _interpolateFrom:fromPoint.y to:toPoint.y percent:percent];
```
接下来直接使用计算结果来更新视图的center：
```
self.myView.center = CGPointMake(x, y);
```
然后运行就能看见，视图如我们所愿的以动画的形式开始移动了（这里由于我的录制gif软件的原因，动画看起来有点卡帧，实际上动画是相当平滑的）。 
![](http://img.blog.csdn.net/20160803114256108)
但是有一个问题：动画根本停不下来！这是由于我们没有停止CADisplayLink，所以onDisplayLink会不停地调用，所以当percent超过1的时候，视图会朝着我们既定的方向继续移动。

正确的停止CADisplayLink的方式是这样的：在计算出percent之后进行判断
```
if (percent > 1) {
percent = 1;
[displayLink invalidate];
}
```
如果少了percent = 1这一行，就会造成一个很小的误差，但是千万不能小看这个误差，我们应该杜绝任何误差的产生。 
再次运行： 
我们的视图就停在了(300,400)的位置
![](http://img.blog.csdn.net/20160803114318619)


#### 非线性的插值
刚才的动画是基于线性插值来实现的，也就是匀速变化，如果我们要实现类似ease效果的变速运动应该如何来做呢？这里对大家的数学能力有一定挑战了。
我们先来看一个easeIn的效果，easeIn的s-t图像大概是这样的：
![](http://img.blog.csdn.net/20160803114340979)
首先要搞清楚x和y分别代表什么。为了让我们的函数能在任意一种动画情况中使用，我们把定义域和值域都设置为[0,1]，那么x代表的就是动画时间的进程了，y代表的就是动画值的进程。进程的意思表示当前值占总进度的百分比，比如考虑这样一个函数 y = f(x) = x^2 （抛物线函数，拥有easeIn的效果，也就是点的斜率随着x的增大而增大），其中一个点（0.5, 0.25）代表的就是当动画时间进行到50%的时候，动画进程执行了25%
> 如果对动画进程还有不清楚的地方，考虑上面一个动画的例子，视图的center.x从10变为300，也就是f=10, to=300，那么动画进程s就等于视图的x已经改变的值(x-f)除以x一共可以改变的值(t-f)也就是s= (x-f)/(t-f)

那么我们就建立了一个从动画时间进程p到动画值进程s的一个映射（函数）： 
s = f(p)，这个映射只要满足其图像上面的点的斜率随着p的增大而增大就能达到easeIn的效果了，因为点的斜率就代表这一时刻动画的速度，比如s = f(p) = p^2 就满足这一easeIn的条件。
这样我们就有了两个方程：
`s = (x-f)/(t-f) ① 
s = f(p) ②`
那我们就解得动画当前值x和时间进程p的关系
`x = f(p) * (t-f) + f`
其中f(p)是一个缓冲函数，满足值域和定义域均为[0,1]，你可以任意修改f(p)的表达式来达到各种不同的变速效果。仔细观察就能发现，当f(p)=p时，就是线性插值，这样我们就可以通过时间来求出p后，把p作用于缓冲函数f(p)，返回的值再带进线性插值的公式，就能算出我们的动画值了，而匀速动画的缓冲函数恰好就是`f(p)=p`。
如果你想实现匀加速动画，恰好匀加速s-t映射就是一个二次函数：`s = 1/2at^2 + v0t`，其中初速度v0 = 0，那么我们的缓冲函数`f(p) = 1/2ap^2`。
现在我们可以将代码修改一下以达到一个easeIn的效果。
首先定义一个easeIn的缓冲函数：
```
- (CGFloat)easeIn:(CGFloat)p{
return p*p;
}
```
然后在回调中作用于percent，将回调方法修改为：

```
- (void)onDisplayLink:(CADisplayLink *)displayLink{
CGPoint fromPoint = CGPointMake(10, 20);
CGPoint toPoint = CGPointMake(300, 400);
NSTimeInterval duration = 2.78;
NSTimeInterval currentTime = CACurrentMediaTime() - self.beginTime;

CGFloat percent = currentTime / duration;
if (percent > 1) {
percent = 1;
[displayLink invalidate];
}
percent = [self easeIn:percent];
CGFloat x = [self _interpolateFrom:fromPoint.x to:toPoint.x percent:percent];
CGFloat y = [self _interpolateFrom:fromPoint.y to:toPoint.y percent:percent];

self.myView.center = CGPointMake(x, y);
}
```
这样我们就有了一个匀速加速启动的效果了，运行看看:
![](http://img.blog.csdn.net/20160803114541750)

以上就是我们这次关于CADisplayLink的全部内容，我们使用它来实现了一个基于帧重绘的动画，并且我们深入研究了插值和easeIn效果的数学实现。我们将在实践篇中再用一篇来看看CADisplayLink的另一种用法：利用系统自带的一些动画效果实现更多的动画。



### 二、CAShapeLayer with Bezier Path - Layer世界的神奇画笔
#### 前言
CALayer是CoreAnimation框架中的核心类，动画是基于绘图的，连图都绘不了还动个毛的画！而CALayer就是来解决绘图问题的。

CoreAnimation框架为我们实现了许多CALayer的子类，它们用来解决特定的问题，比如CATextLayer可以用来显示富文本，CAGradientLayer用来绘制颜色的线性渐变效果。既然它们都是CALayer的子类，它们就拥有CALayer所有的特点：可动画属性、隐式动画、transform变形等。

#### 所有的CALayer子类
在CoreAnimation框架中的所有的CALayer的子类如下所示：
> CAShapeLayer，用来根据路径绘制矢量图形
> CATextLayer，绘制文字信息
> CATransformLayer，使用单独的图层创建3D图形
> CAGradientLayer，绘制线性渐变色
> CAReplicatorLayer，高效地创建多个相似的图层并施加相似的效果或动画
> CAScrollLayer，没有交互效果的滚动图层，没有滚动边界，可以任意滚动上面的图层内容
> CATiledLayer，将大图裁剪成多个小图以提高内存和性能
> CAEmitterLayer，各种炫酷的粒子效果
> CAEAGLLayer，用来显示任意的OpenGL图形
> AVPlayerLayer，用来播放视频

而我们在开发中使用频率最高的就是CAShapeLayer，我们将结合贝塞尔曲线详细讲解其使用。其他Specialized Layer请参阅这篇翻译的[文章](https://zsisme.gitbooks.io/ios-/content/index.html)
#### CAShapeLayer
CAShapeLayer是一个通过矢量图形而不是bitmap（位图）来绘制的CALayer子类。你指定诸如颜色和线宽等属性，用CGPath来定义想要绘制的图形，最后CAShapeLayer就自动渲染出来了。当然，你也可以用Core Graphics直接向原始的CALyer的内容中绘制一个路径，相比直下，使用CAShapeLayer有以下一些优点：
> 渲染快速。CAShapeLayer使用了硬件加速，绘制同一图形会比用Core Graphics快很多。
> 
> 高效使用内存。一个CAShapeLayer不需要像普通CALayer一样创建一个寄宿图形（backing image），所以无论有多大，都不会占用太多的内存。
> 
> 不会被图层边界剪裁掉。一个CAShapeLayer可以在边界之外绘制。你的图层路径不会像在使用Core Graphics的普通CALayer一样被剪裁掉。
> 
> 不会出现像素化。当你给CAShapeLayer做3D变换时，它不像一个有寄宿图的普通图层一样变得像素化。

#### 矢量图简介
在图形世界中有两种图形：位图(bitmap)和矢量图(vector)

位图是通过排列像素点来构造的，像素点的信息包括颜色+透明度(ARGB)，颜色通过RGB来表示，所以一个像素一共有4个信息(透明度、R、G、B)，每个信息的取值范围是0-255，也就是一共256个数，刚好可以用8位二进制来表示，所以每个像素点的信息通常通过32位（4字节）编码来表示，这种位图叫做32位位图，而一些位图没有Alpha通道，这样的位图每个像素点只有RGB信息，只需要24位就可以表示一个像素点的信息。
位图在进行变形（缩放、3D旋转等）时会重新绘制每个像素点的信息，所以会造成图形的模糊。
值得一提的是，对于GPU而言，它绘制位图的效率是相当高的，所以如果你要提高绘制效率，可以想办法把复杂的绘制内容转换成位图数据，然后丢给GPU进行渲染，比如使用CoreText来绘制文字。
关于位图，这里不做更详细的介绍。

**矢量图**
矢量图是通过对多个点进行布局然后按照一定规则进行连线后形成的图形。矢量图的信息总共只有两个：点属性和线属性。点属性包括点的坐标、连线顺序等；线属性包括线宽、描线颜色等。

每当矢量图进行变形的时候，只会把所有的点进行重新布局，然后重新按点属性和线属性进行连线。所以每次变形都不会影响线宽，也不会让图变得模糊。

如何重新布局是通过把所有点坐标转换成矩阵信息，然后通过矩阵乘法重新计算新的矩阵，再把矩阵转换回点信息。比如要对一个矢量图进行旋转，就先把这个矢量图所有的点转换成一个矩阵（x,y,0），然后乘以旋转矩阵：

```
( 
cosa   sina  0
-sina  cosa  0
0     0      1   )

```
得到新的矩阵（x·cosa-y·sina, x·sina+y·cosa, 0） 
然后把这个矩阵转换成点坐标（x·cosa-y·sina, x·sina+y·cosa）这就是新的点了。对矢量图所有的点进行这样的操作后，然后重新连线，出现的新的图形就是旋转后的矢量图了。
关于矩阵计算和自定义矢量图的绘制，可以查看我的这个Git项目：[DHVectorDiagram](https://github.com/DHUsesAll/DHVectorDiagram)



#### 构建CAShapeLayer
构建一个CAShapeLayer非常简单，对于所有CALayer的子类，它们的初始化都是一个简单的便利构造，像这样：

```
CAShapeLayer * shapeLayer = [CAShapeLayer layer];
```

像普通的CALayer一样，接下来你可以设置它的frame、背景颜色、寄宿图等，当然我们的CAShapeLayer肯定不是一个普通的layer，它是用来绘制矢量图的，通过传递给它的对象一个CGPathRef，CAShapeLayer就能以矢量图的形式将这个路径所表示的信息绘制出来。
在让CAShapeLayer渲染之前，我们可以先设置好线属性，比如我们设置线宽和描线颜色：

```
shapeLayer.lineWidth = 5;
shapeLayer.strokeColor = [UIColor redColor].CGColor;
```
> stroke是描线的意思，我们后面还会接触到strokeStart和strokeEnd等更多的描线属性。

设置好了渲染信息后，我们可以构造一个路径来让CAShapeLayer帮我们绘制出来，这里我们先直接使用UIKit里面的贝塞尔曲线来构造一个简单的矩形路径：
```
UIBezierPath * path = [UIBezierPath    bezierPathWithRect:CGRectMake(0,0,40,40)];
```
这里需要注意的是，路径的坐标是相对于shapeLayer的左上角
然后把它的CGPath属性赋值给shapeLayer：
```
shapeLayer.path = path.CGPath;
```

最后把shapeLayer加到层级上来显示：
```
[self.view.layer addSublayer:shapeLayer];
```

运行一下会发现，我们的红色方框确实是画出来了，但是中间被填充成了黑色。这是因为CAShapeLayer的fillColor属性默认为黑色，fillColor表示的是填充颜色，将一个CAShapeLayer的路径的所有封闭区间填充成该颜色，如果你不想要填充的效果，你可以设置其为透明色：
```
shapeLayer.fillColor = [UIColor clearColor].CGColor
```

#### UIBezierPath
在UIKit框架中苹果用面向对象为我们封装了一个用来表示抽象贝塞尔曲线的类：UIBezierPath。我们可以使用它来很方便的表示一条曲线。
UIBezierPath实际上是广义上的曲线，它可以用来构造各种各样的曲线，比如我们之前使用过的表示一个矩形的线，接下来我们来看看它能构造哪些曲线出来。
##### 直接构造
UIBezierPath提供了直接构造某种曲线的方法
```
// 构造一个空的曲线
path = [UIBezierPath bezierPath];

// 构造一个矩形
path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 40, 40)];

// 构造一个矩形内切圆
path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 40, 40)];
```
> 所以如果要快速构造一个圆形出来的话，直接用正方形的内切圆就行了。如果传入的是一个长方形，那么构造出来的将是一个椭圆。

```
// 构造一个圆角矩形
path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 40, 40) cornerRadius:3];
```
你也可以使用这种方式构造一个圆形，只需要设置圆角半径为正方形边长的一半即可。
```
// 构造一个圆角矩形并指定哪几个角是圆角
// 比如这里指定左下角和右上角这两个角变圆
path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(10, 10, 140, 200) byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(90, 100)];
```

> 这个方法的第三个参数传入的是一个CGSize，它的width成员就是你要设置的圆角半径，height有什么用我目前还没弄明白。值得注意的是，如果你设置的半径大于其宽或高的一半，那么系统会自动帮我们修正到一个不错的效果，你们可以试一试

```
// 构造一段圆弧
path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(200, 200) radius:100 startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
```
第一个参数center表示的是圆弧的圆心
第二个参数radius表示圆弧的半径
第三个参数startAngle表示的是圆弧的起始点
第四个参数endAngle表示的是圆弧的终止点
第五个参数clockwise表示是否以顺时针的方向连接起始点和终止点
注意startAngle和endAngle所代表的只是两个点，0则表示圆的最右边那个点，所以如果是π/2
的话就表示圆上最下面那个点。
最终将会从起始点到终止点连一段圆弧出来，最后一个参数决定了这次连接是顺时针的还是逆时针的。具体如图所示
![](http://img.blog.csdn.net/20160809113225989)


##### 迭代构造
所有的UIBezierPath对象都能够通过对其添加子曲线来变得更为复杂。UIBezierPath通过控制一支虚拟的画笔来勾勒出各种你想要的形状。

想象你手里拿着一支用来绘制贝塞尔路径的笔，现在你想画出一条折线，应该怎么画呢？没错，先把笔放到一个地方，然后画一条线，然后笔不离开继续画一条线。
把笔放到一个地方可以通过调用moveToPoint方法，画一条线则调用addLineToPoint方法，比如像这样来画一个直角：
```
UIBezierPath * path = [UIBezierPath bezierPath];
// 把笔放在10,10的位置
[path moveToPoint:CGPointMake(10, 10)];
// 将笔移动到100,10的位置，路过的地方将会留下一条路径
[path addLineToPoint:CGPointMake(100, 10)];
// 笔现在已经在100,10的位置了，然后再画一条线到100,100
[path addLineToPoint:CGPointMake(100, 100)];

shapeLayer.path = path.CGPath;
```

这样画的效果是“一横一竖”，像个“7”。注意我们在画的过程中并没有再次调用moveToPoint，一旦调用了moveToPoint就相当于当前绘制点移动到了这个方法的参数指定的点。
任何贝塞尔曲线都可以随时添加各种子路径
比如你用直接构造法画了一个圆，然后想在里面再画一条横线，你可以这样做：
```
// 直接构造一个圆出来
UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(30, 30, 200, 200)];

// 画一条横线
[path moveToPoint:CGPointMake(30, 130)];
[path addLineToPoint:CGPointMake(230, 130)];

shapeLayer.path = path.CGPath;
```
![](http://img.blog.csdn.net/20160809113303474)

除了使用move和add方法来添加新的路径外，还可以使用appendPath方法来拼接子路径。上面的效果还可以这样来实现：
```
// 直接构造一个圆出来
UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(30, 30, 200, 200)];

// 构造一个子路径
UIBezierPath * subpath = [UIBezierPath bezierPath];

// 画一条横线
[subpath moveToPoint:CGPointMake(30, 130)];
[subpath addLineToPoint:CGPointMake(230, 130)];

// 拼接路径
// 把subpath拼接到path上
[path appendPath:subpath];

shapeLayer.path = path.CGPath;
```

除了可以使用addLineToPoint来在当前路径上添加直线外，还可以添加曲线。

```
// 添加一段圆弧
// 构造一个空的路径
UIBezierPath * path = [UIBezierPath bezierPath];
// 添加一段圆弧
// 注意我们没有调用moveToPoint，这样我们的笔就直接从圆弧的起始点画到结束点
// 你们可以试试看在下面这行代码之前调用moveToPoint会发生什么事情
[path addArcWithCenter:CGPointMake(200, 200) radius:100 startAngle:0 endAngle:M_PI clockwise:YES];
// 现在我们的笔处在endAngle所代表的点（简单计算一下，圆心200,200，半径100，endAngle是π，那么结束点就是100,200），如果我们继续添加直线的话，就会直接从结束点开始画
[path addLineToPoint:CGPointMake(120, 20)];
```
![](http://img.blog.csdn.net/20160809113319374)

我们还可以添加正统的贝塞尔曲线
```
UIBezierPath * path = [UIBezierPath bezierPath];
// 将笔置于40,40
[path moveToPoint:CGPointMake(40, 40)];
// 从40,40到300,200画一条贝塞尔曲线，其控制点为120,360，也就是说P0是40,40，P1是120,360，P3是300,200
[path addQuadCurveToPoint:CGPointMake(300, 200) controlPoint:CGPointMake(120, 360)];
```
![](http://img.blog.csdn.net/20160809113329155)
一个控制点的贝塞尔曲线是二阶贝塞尔曲线，系统还提供了三阶贝塞尔曲线的实现：
```
UIBezierPath * path = [UIBezierPath bezierPath];

[path moveToPoint:CGPointMake(40, 40)];

[path addCurveToPoint:CGPointMake(350, 600) controlPoint1:CGPointMake(10, 220) controlPoint2:CGPointMake(380, 380)];
```
![](http://img.blog.csdn.net/20160809113340437)
这就是系统提供了所有构造UIBezierPath的方法了。

##### 函数图像构造
现在我们想要画一条sin曲线（正弦曲线），应该怎么画呢？这里就要发挥我们自己的聪明才智了。
在数学上我们的函数图像都是一系列满足函数表达式的连续的点，而计算机是没法处理“连续”的（比如数字音频没法处理模拟信号，只能用采样的方式以数字信号的形式进行离散处理），所以我们可以使用上一章我们逐帧绘制动画的方法，通过“足够近的离散的点”来模拟一条连续的曲线。
我们考虑任何一个函数 y = f(x)，要怎样画出它的图像呢？我们按照离散的思想，肯定是每隔一个足够短的距离取一个点，然后把这些点全部拼接到一起就行了。
好现在我们至少有实现的思路了，就拿y = f(x) = sinx开刀吧。
```
- (void)viewDidLoad {
[super viewDidLoad];

// 使用一个shapeLayer来显示函数图像
CAShapeLayer * shapeLayer = [CAShapeLayer layer];
shapeLayer.strokeColor = [UIColor redColor].CGColor;
shapeLayer.lineWidth = 5;
shapeLayer.fillColor = [UIColor clearColor].CGColor;

// 构造函数图像

CGFloat width = CGRectGetWidth(self.view.bounds);
CGFloat height = CGRectGetHeight(self.view.bounds);

// 先构造一个空的路径
UIBezierPath * path = [UIBezierPath bezierPath];
// 第一个点需要moveToPoint，所以放到for循环之前来
// 当x=0的时候sinx=0
[path moveToPoint:CGPointMake(0, 0)];

for (int i = 1; i < width; i++) {

CGPoint point = CGPointMake(i, sin(i));

[path addLineToPoint:point];

}

shapeLayer.path = path.CGPath;
[self.view.layer addSublayer:shapeLayer];

}
```
看起来似乎是没有问题的，运行看一下效果:
![](http://img.blog.csdn.net/20160809113356069)

上面的代码我们犯了两个错误：

> UIKit的坐标系y轴正方向向下，而正规的用来画函数图像的直角坐标系y轴正方向是向上的
> 
> y = sin(x)的值域是[-1,1]，周期是2π，如果我们直接使用这样的值域和周期在画路径，那么这里的[-1,1]就是像素大小，整个图像的高度画出来就俩像素的高度。


第一个问题可以通过用参考系高度减去函数计算出来的y来得到最终要画到屏幕上面的y，这里的参考系是屏幕，所以我们最终画到屏幕上的y’ = height - y。


第二个问题可以通过对函数图像进行变形操作（拉伸和平移），现在我们想把值域变为[0,height]，周期变为100，应该怎样操作呢？

> 值域：先把y值变为原来的height/2倍，这样值域就变成了[-height/2, height/2]，然后再加上height/2，值域就变成了[0,height]，这样操作的结果就相当于函数图像垂直方向拉伸了height/2倍并且向上平移了height/2的高度
> 
> 周期：相当于函数图像水平方向拉伸 100/(2π)倍，那么传进函数表达式的x就应该变为原来的2π/100倍，也就是说我们应该使用sin(2πx/100)来代替sin(x)作为函数表达式。


所以我们将上面构造路径的代码修改为：
```
UIBezierPath * path = [UIBezierPath bezierPath];
// 第一个点需要moveToPoint，所以放到for循环之前来
// 根据新的函数图像，当x=0的时候f(x)=height/2
[path moveToPoint:CGPointMake(0, height/2)];

for (int i = 1; i < width; i++) {

// 对sinx图像进行变形
CGFloat y = height/2 * sin(2 * M_PI * i / 100) + height/2;
// 解决坐标轴方向相反的问题
CGPoint point = CGPointMake(i, height - y);

[path addLineToPoint:point];

}
```
![](http://img.blog.csdn.net/20160809113410718)

#### CAShapeLayer的可动画属性
作为CALayer大家族中的一员，CAShapeLayer拥有许多它自己的可动画属性，我们来几个比较关键的属性，剩下的属性大家可以点进CAShapeLayer的类声明里面进行查看。
##### strokeStart
strokeStart是一个被标记为Animatable的属性，它表示描线开始的地方占总路径的百分比，默认值是0，取值范围[0,1]。

比如你从(0,0)点画了一条直线到(100,0)，(moveToPoint:(0,0);addLineToPoint:(100,0))，那么当strokeStart = 0.5的话，画出来的线就相当于从(50,0)画到(100,0)。

注意，如果你是从(100,0)画到了(0,0)，那么绘制开始的点是(100,0)，当strokeStart = 0.5的时候，画出来的线就相当于从(50,0)画到(0,0)。
我们来画一段圆弧并为strokeStart添加动画来试一试

```
- (void)viewDidLoad {
[super viewDidLoad];

// 构造一个圆弧路径，从圆的底部顺时针画到圆的右部（3/4圆）

CAShapeLayer * shapeLayer = [CAShapeLayer layer];
shapeLayer.strokeColor = [UIColor redColor].CGColor;
shapeLayer.lineWidth = 5;
shapeLayer.fillColor = [UIColor clearColor].CGColor;
[self.view.layer addSublayer:shapeLayer];

UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(200, 200) radius:100 startAngle:M_PI_2 endAngle:0 clockwise:YES];

shapeLayer.path = path.CGPath;

// 为strokeStart添加动画

CABasicAnimation * animation = [CABasicAnimation animation];
animation.keyPath = @"strokeStart";
animation.duration = 3;
animation.fromValue = @0;

// 直接修改modelLayer的属性来代替toValue，见原理篇第四篇
// 这样shapeLayer的strokeStart属性就会在3秒内从0变到1，可以观察动画的过程和你自己想象的是否一致

// 添加一个延迟这样看得更明白些
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
shapeLayer.strokeStart = 1;
[shapeLayer addAnimation:animation forKey:nil];
});
}

```
![](http://img.blog.csdn.net/20160809113431898)
##### strokeEnd
类似于strokeStart，只不过它代表了绘制结束的地方站总路径的百分比，默认值是1，取值范围是[0,1]。如果小于等于strokeStart，则绘制不出任何内容。你们可以把它和strokeStart联系起来对比认识。 

我们把上面的动画代码中的keyPath改为@”strokeEnd”然后删掉shapeLayer.strokeStart = 1;这一行。再运行看看
![](http://img.blog.csdn.net/20160809113449687)
##### path
有意思的是，path这个属性也被标记为了Animatable。可动画的路径，可能会比较难以想象是怎样的效果，我们用一个例子来进行说明。

如果我们要实现这样的一个动画：
![](http://img.blog.csdn.net/20160809113458515)
实际上就是我们用一个填充颜色为橙色的shapeLayer将它的路径按如下做变化：
![](http://img.blog.csdn.net/20160809113513040)
所以我们只需要一个CABasicAnimation，from左边的路径to右边的路径，CABasicAnimation就自动帮我们插值计算出中间的每帧的路径并动画显示出来了。
```
- (void)viewDidLoad {
[super viewDidLoad];

CAShapeLayer * shapeLayer = [CAShapeLayer layer];
shapeLayer.fillColor = [UIColor orangeColor].CGColor;
[self.view.layer addSublayer:shapeLayer];

// 构造fromPath
UIBezierPath * fromPath = [UIBezierPath bezierPath];
// 从左上角开始画
[fromPath moveToPoint:CGPointZero];

// 因为我的模拟器是6plus，所以屏幕宽度是414

// 向下拉一条直线
[fromPath addLineToPoint:CGPointMake(0, 400)];
// 向右拉一条曲线，因为是向下弯的并且是从中间开始弯的，所以控制点的x是宽度的一半，y比起始点和结束点的y要大
[fromPath addQuadCurveToPoint:CGPointMake(414, 400) controlPoint:CGPointMake(207, 600)];

// 向上拉一条直线
[fromPath addLineToPoint:CGPointMake(414, 0)];
// 封闭路径，会从当前点向整个路径的起始点连一条线
[fromPath closePath];

shapeLayer.path = fromPath.CGPath;

// 构造toPath
UIBezierPath * toPath = [UIBezierPath bezierPath];

// 同样从左上角开始画
[toPath moveToPoint:CGPointZero];
// 向下拉一条线，要拉到屏幕外
[toPath addLineToPoint:CGPointMake(0, 836)];
// 向右拉一条曲线，同样因为弯的地方在正中间并且是向上弯，所以控制点的x是宽的一半，y比起始点和结束点的y要小
[toPath addQuadCurveToPoint:CGPointMake(414, 836) controlPoint:CGPointMake(207, 736)];
// 再向上拉一条线
[toPath addLineToPoint:CGPointMake(414, 0)];
// 封闭路径
[toPath closePath];

// 构造动画
CABasicAnimation * animation = [CABasicAnimation animation];
animation.keyPath = @"path";
animation.duration = 5;

// fromValue应该是一个CGPathRef（因为path属性就是一个CGPathRef），它是一个结构体指针，使用桥接把结构体指针转换成OC的对象类型
animation.fromValue = (__bridge id)fromPath.CGPath;

// 同样添加一个延迟来方便我们查看效果
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
// 直接修改modelLayer的值来代替toValue
shapeLayer.path = toPath.CGPath;
[shapeLayer addAnimation:animation forKey:nil];
});
}
```

### 三、Layer Masking - 图层蒙版
#### 什么是蒙版
我们知道，如果你想要显示一个图层的内容，需要将其加到图层的层级上
```
- [CALayer addSublayer:]
```

> 当然你还可以通过将一个CALayer的内容通过位图的形式渲染进CoreGraphics绘图上下文来进行一些其他的操作。

当你需要将一个CALayer的内容变成圆角的时候，你可以通过设置cornerRadius来很方便的实现，但是如果你想要一个CALayer的内容被剪裁成任意形状应该如何是好呢？

你当然可以通过使用一张拥有alpha属性的PNG图片来直接绘制，但是这样做的话就没有动态特性了，比如剪裁形状和要剪裁的图片本身都是用户指定的，这样的话就必须用编程来动态实现了。

如果你使用过Photoshop，这个问题你肯定知道可以创建一个图层蒙版来实现。而在CoreAnimation中，框架同样为我们提供了这样的功能，CALayer拥有一个属性叫做mask，作为这个CALayer对象的蒙版，mask本身也是一个CALayer，比如：
```
CALayer * layer = [CALayer layer];
CALayer * maskLayer = [CALayer layer];
layer.mask = maskLayer;
```

这样的话，maskLayer就成为了layer的蒙版，maskLayer类似于一个子图层，相对于父图层（即拥有该属性的图层，在这里就是layer）布局，但是它却不是一个普通的子图层。maskLayer并不会直接绘制在父图层之上，它只是定义了父图层的“可视部分”。

想象maskLayer是一张纸，盖在了layer上，那么layer能显示出来的内容，就是maskLayer“不是透明的部分”的内容。mask属性就像是一个饼干切割机，mask图层实心的部分会被保留下来，其他的（透明的部分）则会被抛弃。如图
![](http://img.blog.csdn.net/20160812091842446)
为了更好的理解蒙版的“留下不透明部分的内容”的特性，我们来看个例子。

我们自己来用PS创建一张PNG图片作为蒙版，打开PS软件，创建一个300*300的画布，创建一个带有透明背景png形状图：
![](http://img.blog.csdn.net/20160812091904205)
接下来我们使用代码来进行显示：
```
- (void)viewDidLoad {
[super viewDidLoad];

CALayer * layer = [CALayer layer];
layer.frame = CGRectMake(80, 80, 300, 300);
// 直接设置layer的contents属性，它可以是一张图片的内容，但是我们的layer同样不认识UIKit下面的UIImage，它只接收CGImageRef，所以使用桥接来进行强转
layer.contents = (__bridge id)[UIImage imageNamed:@"content.png"].CGImage;
[self.view.layer addSublayer:layer];
}
```

运行效果：
￼![](http://img.blog.csdn.net/20160812091914478)
接下来我们为layer加上蒙版：
```
- (void)viewDidLoad {
[super viewDidLoad];

CALayer * layer = [CALayer layer];
layer.frame = CGRectMake(80, 80, 300, 300);
// 直接设置layer的contents属性，它可以是一张图片的内容，但是我们的layer同样不认识UIKit下面的UIImage，它只接收CGImageRef，所以使用桥接来进行强转
layer.contents = (__bridge id)[UIImage imageNamed:@"content.png"].CGImage;
[self.view.layer addSublayer:layer];

CALayer * maskLayer = [CALayer layer];
// 蒙版的坐标是基于它所影响的那个图层的坐标系
maskLayer.frame = CGRectMake(0, 0, 300, 300);

maskLayer.contents = (__bridge id)[UIImage imageNamed:@"mask.png"].CGImage;
// 将maskLayer作为layer的蒙版
layer.mask = maskLayer;

}
```
运行效果：
![](http://img.blog.csdn.net/20160812092551489)
layer中，只有maskLayer有内容的部分被留下来了，其余部分都被挖走了。


#### CAShapeLayer + mask
在实际的开发中，我们经常会使用一个CAShapeLayer绘制出某个形状，然后将它作为另一个图层的蒙版来实现一些炫酷的效果。比如我们将layer剪裁成一滴水的形状。

首先我们需要创建一个“一滴水”的形状的路径，这个路径将作用于我们的maskLayer（这里的maskLayer是一个CAShapeLayer），所以路径的坐标也应该相对于maskLayer将要作用的那个图层的坐标（也就是如路径上的(0,0)点就是maskLayer将要作用的那个图层的(0,0)点）。

我们大概会画这样一个形状出来
![](http://img.blog.csdn.net/20160812092020917)

橙色部分可以通过addLineToPoint来绘制，蓝色部分则需要通过addArc来绘制圆弧或者addQuadCurve来绘制一个二阶贝塞尔曲线，我们这里使用二阶贝塞尔曲线更加灵活一些。
```
- (void)viewDidLoad {
[super viewDidLoad];

CALayer * layer = [CALayer layer];
layer.frame = CGRectMake(80, 80, 300, 300);
// 直接设置layer的contents属性，它可以是一张图片的内容，但是我们的layer同样不认识UIKit下面的UIImage，它只接收CGImageRef，所以使用桥接来进行强转
layer.contents = (__bridge id)[UIImage imageNamed:@"content.png"].CGImage;
[self.view.layer addSublayer:layer];


UIBezierPath * bezierPath = [UIBezierPath bezierPath];

// 起始点在(图片宽的一半,0)的位置
[bezierPath moveToPoint:CGPointMake(150, 0)];

// 大概估算一下x和y的值
[bezierPath addLineToPoint:CGPointMake(40, 150)];

// 向右拉一条二阶贝塞尔曲线，控制点在中部偏下
[bezierPath addQuadCurveToPoint:CGPointMake(260, 150) controlPoint:CGPointMake(150, 300)];

// 闭合曲线，这样就会从当前点(150,300)到起始点(150,0)连线来进行闭合
[bezierPath closePath];

// 构造蒙版图层
CAShapeLayer * maskLayer = [CAShapeLayer layer];
maskLayer.path = bezierPath.CGPath;
// 因为maskLayer的填充颜色默认是存在的，所以可以直接作为蒙版
layer.mask = maskLayer;
}
```
运行效果：
![](http://img.blog.csdn.net/20160812091957229)
现在我们把上面代码中的maskLayer的设置改一下：
```
// 构造蒙版图层
CAShapeLayer * maskLayer = [CAShapeLayer layer];
maskLayer.path = bezierPath.CGPath;
// 因为maskLayer的填充颜色默认是存在的，所以可以直接作为蒙版
layer.mask = maskLayer;

// 填充颜色为透明，填充内容将不再作为蒙版内容
maskLayer.fillColor = [UIColor clearColor].CGColor;
// 任意颜色，只要不透明就行，描线颜色就将作为蒙版内容
maskLayer.strokeColor = [UIColor redColor].CGColor;

maskLayer.lineWidth = 30;
```
效果变成了这样：
![](http://img.blog.csdn.net/20160812092646083)
这就是蒙版的“使被蒙版的图层只留下蒙版不透明部分的内容”的特性


#### 为蒙版创建动画
CALayer的蒙版可以是任何CALayer的子类，既然是CALayer的子类，当然可以拥有动画效果了。
我们为上面的maskLayer添加一个strokeEnd的动画来试一试效果。接着上面的代码添加如下动画代码：
```
CABasicAnimation * animation = [CABasicAnimation animation];
animation.keyPath = @"strokeEnd";
animation.duration = 3;
animation.fromValue = @0;
// 由于maskLayer默认的strokeEnd就是1，所以这里不再需要重新设置modelLayer的属性

[maskLayer addAnimation:animation forKey:nil];
```
运行效果：
![](http://img.blog.csdn.net/20160812092056425)
在动画的每一帧都满足蒙版的“使被蒙版的图层只留下蒙版不透明部分的内容”的特性

所以你完全可以大开脑洞来为你的界面添加各种意想不到的效果，我们将在实战篇使用蒙版动画来实现一些其他的效果。

#### 总结
蒙版这一章的内容比较简单，主要是让大家知道有蒙版这个东西

蒙版是作用是为一个CALayer（包括其子类）对象抠出某个形状的内容来显示，其满足“被蒙版的图层只留下蒙版不透明部分的内容”，蒙版可以是任何CALayer的子类，用的比较多的蒙版是CAShapeLayer，因为它能画出各种形状。

一旦理解了蒙版的这个特性，剩下的就只需要脑洞了。

### 四、平面向量 - 优雅的绘图指挥家
平面向量是在二维平面内既有方向(direction)又有大小(magnitude)的量，物理学中也称作矢量，与之相对的是只有大小、没有方向的数量（标量）。
大家可以忽略本章所有出现的代码，因为它们实际上就在这里。
那么向量和我们的绘图又有怎样的关系呢？
具体内容请看[该文章](http://blog.csdn.net/u013282174/article/details/68062940)
## 参考文章
[参考文章](http://blog.csdn.net/u013282174/article/details/50252455)




