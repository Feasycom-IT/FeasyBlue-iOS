
#ifndef MacroDefinition_h
#define MacroDefinition_h

// 获取self.view的宽高
#define KQWIDTH  self.view.frame.size.width
#define KQHEIGHT self.view.frame.size.height

// 按钮宽高和间距
#define BUTTON_WIDTH  150
#define BUTTON_HEIGHT 60
#define SPACE         50

// navigationbar高度
#define KQNAVIGATIONHEIGHT    64
#define KQNAVIGATIONHEIGHT_X  88
#define KQTABBARHEIGHT        49
#define KQTABBARHEIGHT_X      84


//在360这台路由器下测试：3000 = 600~700KB,    4000 = 800~900KB ,   5000 = 1.1M   ,6000 = 1.5M，6000以上也会限制在1.5M。


// 分包大小
#define PACKAGE_LENGTH 14600

// 设置随机颜色
#define KQRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]
// 设置RGB颜色/设置RGBA颜色
#define KQRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define KQRGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(r)/255.0 blue:(r)/255.0 alpha:a]

// 自定义高效率的 NSLog
#ifdef DEBUG
#define KQLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define KQLog(...)
#endif

// 弱引用/强引用
#define KQWeakSelf(type)  __weak typeof(type) weak##type = type;
#define KQStrongSelf(type)  __strong typeof(type) type = weak##type;

// 获取图片资源
#define KQGetImage(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]

// 单例
// .h
#define KQSINGLETON_INTERFACE(class) + (instancetype)shared##class;
// .m
#define KQSINGLETON_IMPLEMENTATION(class) \
static class *_instance; \
+ (instancetype)shared##class \
{ \
if (_instance == nil) { \
_instance = [[class alloc] init]; \
} \
return _instance; \
}

// 判断当前的iPhone设备/系统版本
//判断是否为iPhone
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

//判断是否为iPad
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//判断是否为ipod
#define IS_IPOD ([[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])

// 判断是否为 iPhone 5SE
#define iPhone5SE [[UIScreen mainScreen] bounds].size.width == 320.0f && [[UIScreen mainScreen] bounds].size.height == 568.0f

// 判断是否为iPhone 6/6s
#define iPhone6_6s [[UIScreen mainScreen] bounds].size.width == 375.0f && [[UIScreen mainScreen] bounds].size.height == 667.0f

// 判断是否为iPhone 6Plus/6sPlus
#define iPhone6Plus_6sPlus [[UIScreen mainScreen] bounds].size.width == 414.0f && [[UIScreen mainScreen] bounds].size.height == 736.0f

// 判断是否为iPhone X
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

//获取系统版本
#define IOS_SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//判断 iOS 8 或更高的系统版本
#define IOS_VERSION_8_OR_LATER (([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)? (YES):(NO))

//15.判断是真机还是模拟器
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

// GCD宏定义
//GCD - 一次性执行
#define KQDISPATCH_ONCE_BLOCK(onceBlock) static dispatch_once_t onceToken; dispatch_once(&onceToken, onceBlock);
//GCD - 在Main线程上运行
#define KQDISPATCH_MAIN_THREAD(mainQueueBlock) dispatch_async(dispatch_get_main_queue(), mainQueueBlock);
//GCD - 开启异步线程
#define KQDISPATCH_GLOBAL_QUEUE_DEFAULT(globalQueueBlock) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), globalQueueBlocl);
////GCD - 开启异步线程
//#define KQDISPATCH_ASYNC(threadName,asynBlock) dispatch_async(dispatch_queue_create("threadName", DISPATCH_QUEUE_SERIAL), asynBlock);

#endif /* MacroDefinition_h */
