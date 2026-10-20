//
//  GetImage.h
//  PuBar
//
//  Created by wenyewei on 18-7-2.
//  Copyright (c) 2015年 wenyewei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//常用动画
typedef enum {
    GenerallyAnimationSliderFormLeft = 0 ,//从左边缘 直线 进入（相对其父类而言）
    GenerallyAnimationSliderFormRight ,//从右边缘 直线 进入（相对其父类而言）
    GenerallyAnimationSliderFormTop ,//从上边缘 直线 进入（相对其父类而言）
    GenerallyAnimationSliderFormBottom ,//从下边缘 直线 进入（相对其父类而言）
    
    GenerallyAnimationSliderToLeft,//直线动画到左侧（相对其父类而言）
    GenerallyAnimationSliderToRight,//直线动画到右侧 （相对其父类而言）
    GenerallyAnimationSliderToTop,//直线动画到上边缘 （相对其父类而言）
    GenerallyAnimationSliderToBottom,//直线动画到下边缘 （相对其父类而言）
    
    GenerallyAnimationFallIn,//从大到小，transform由1.5变到1
    GenerallyAnimationFallOut,//从小到大，transform由1变到1.5
    
    GenerallyAnimationPopIn,//从大到小，transform由1变到0.1 alpha由1变到0
    GenerallyAnimationPopOut,//由小到大，transform由0.1变到1 alpha由0变到1
    
    GenerallyAnimationFallSliderFormLeft,//从左侧侧滑进入，transform由0.1变到1
    GenerallyAnimationFallSliderFormRight,//从右侧侧滑进入，transform由0.1变到1
    GenerallyAnimationFallSliderFormTop,//从顶部侧滑进入，transform由0.1变到1
    GenerallyAnimationFallSliderFormBottom,//从下部侧滑进入，transform由0.1变到1
    
    GenerallyAnimationConverLayerFormLeft,//从左到右 遮罩
    GenerallyAnimationConverLayerFormRight,//从右到左 遮罩
    GenerallyAnimationConverLayerFormTop,//从上往下 遮罩
    GenerallyAnimationConverLayerFormBottom,//从下往上 遮罩
    GenerallyAnimationConverLayerFormCenter,//从中央扩散 遮罩
    
    GenerallyAnimationFadeIn,//淡隐淡出,出现
    GenerallyAnimationFadeOut,//消失
}GenerallyAnimationEnum;


//日志打印 可以关闭日志打印，提升运行效率
#define ONLOG 1 //日志打印开关
#if ONLOG
#define MMLog( s, ... ) NSLog( @"[%@:%d] %@", [[NSString stringWithUTF8String:__FILE__] \
lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define MMLog( s, ... )
#endif

//自定义调试项
#define DEBUGTAG 1 //调试开关
#define LABELCOLOR RGBSTRING(@"515152")  //字体颜色
#define BLUECOLOR RGBSTRING(@"4283D8")   //App主题蓝色

//1080*1920 PSD兼容比例宏
//#define PSDSCALE 0.2949
//750*1334 PSD兼容比例宏
#define PSDSCALE 0.4267
#define PSDSCALE_X PSDSCALE*GETSCALE_X
#define PSDSCALE_Y PSDSCALE*GETSCALE_Y

//导航栏高度
#define NAVIGATIONBARHEIGHT 64
//状态栏高度
#define STATUSBARHEIGHT 20
//tabbar高度
#define TABBARHEIGHT 49

//多语言项 需要主动切换多语言时可用
#define AppFontSize @"appfontsize"
#define AppLanguage @"appLanguage"
#define MMLocalizedString(key, comment) [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:@"" table:nil]

//系统版本
#define DEVICE_VERSION  [[UIDevice currentDevice].systemVersion floatValue]

//状态栏菊花
#define ShowNetActivity  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]
#define HiddenNetActivity     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]

//系统单例
#define UserDefaults  [NSUserDefaults standardUserDefaults]
#define NotificationCenter  [NSNotificationCenter defaultCenter]
#define SharedApplication  [UIApplication sharedApplication]
#define APPDelegate     [[UIApplication sharedApplication] delegate]
#define FileManager [NSFileManager defaultManager]

//获取图片
#define GETNCIMAGE(NAME)    [Header getTheImageNoCache:(NAME)]      //读取图片（不缓存）&& name 图片全名
#define GETYCIMAGE(NAME)    [Header getTheImageWithCache:(NAME)]    //读取图片（缓存）&& name 图片全名
#define GETTABIMAGE(NAME)   [Header getTheOriginalImage:(NAME)]     //获取原图

//兼容比例宏
#define GETRECT(_X_,_Y_,_WIDTH_,_HEIGHT_) [Header getFrameWithX:_X_ Y:_Y_ Width:_WIDTH_ Height:_HEIGHT_]
#define GETSCALE_X  [Header getScaleX]
#define GETSCALE_Y  [Header getScaleY]

//设备判断宏
#define IS_Phone4S ([[UIScreen mainScreen]bounds].size.height == 480.0)
#define IS_Phone6 ([[UIScreen mainScreen]bounds].size.height == 667.0)
#define IS_Phone6_Plus ([[UIScreen mainScreen]bounds].size.height == 736.0)

//获得视图相关
#define VIEW_W(_VIEW_)  (_VIEW_.frame.size.width)
#define VIEW_H(_VIEW_)  (_VIEW_.frame.size.height)
#define VIEW_X(_VIEW_)  (_VIEW_.frame.origin.x)
#define VIEW_Y(_VIEW_)  (_VIEW_.frame.origin.y)
#define VIEW_H_Y(_VIEW_)  (_VIEW_.frame.origin.y + _VIEW_.frame.size.height)
#define VIEW_W_X(_VIEW_)  (_VIEW_.frame.size.width + _VIEW_.frame.origin.x)
//APP沙盒路径 Document
#define DOCUMENT  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define CACHES [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
//千分位加逗号分隔
#define ThousandsSeparatorString(_str_) [Header thousandsSeparatorString:(_str_)]
//获取文本size
#define GETLABELSIZE(_str,_font,_contraint) [Header getContentHightWithContent:_str font:_font constraint:_contraint]
//格式化字符串
#define FORMATSTRING(str) [Header formateString:str]


//判断dic是否存在key
#define VALUEFORKEY(_dic,_key) [Header DicValueForKey:_dic key:_key]
//取数组对象
#define OBJECTATINDEX(_array,_index) [Header getObjcAtIndex:(_index) array:(_array)]
//获得当前屏幕尺寸
#define SCREEN_HEIGHT [Header screenHeight]
#define SCREEN_HEIGHT_4s [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_BOUNDS [[UIScreen mainScreen] bounds]
//获取RGB颜色
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define RGBSTRING(rs) [Header colorWithHexString:(rs)]
//透明色
#define CLEARCOLOR [UIColor clearColor]
//字符串去空格
#define WHITESPACE(str) [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
// 是否是英文环境
#define ISENLAN [Header isEnglish]
//ios7
#define ISIOS7 [[UIDevice currentDevice].systemVersion floatValue] < 8.0
//NSData转字典
#define DATATODIC(_data) [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil]
//时间 yyyy-MM-dd HH:mm:ss
#define NOWTIMESTR(date_format) [Header getNowTime:(date_format)]
#define TIMESTAMP_TO_TIMESTRING(timestamp,date_format) [Header getDateWithTimestamp:(timestamp) format:(date_format)]
#define FORMATEDATE(_date,_formate) [Header formateDataWith:(_date) formate:(_formate)]
//摇一摇
#define ROCKVIEW(rv) [Header rockView:(rv)]
//格式化URL字符串
#define FORMATRUL(str) [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
//设置行间距
#define LINESPACING(str,spc,cor,fs) [Header setTheLineSpacing:(str) lineSpacing:(spc) color:(cor) font:(fs)]

@interface Header : NSObject
+ (NSString *)thousandsSeparatorString:(NSString *)string;

+ (UIImageView *)gifAnimationWithView:(UIView *)view;
+ (void)gifRemoveAnimationWithView:(UIImageView *)loadView;

+ (UIImage *)getTheImageNoCache:(NSString *)name;

+ (UIImage *)getTheImageWithCache:(NSString *)name;

+ (UIImage *)getTheOriginalImage:(NSString *)name;

+ (CGRect)getFrameWithX:(CGFloat)X Y:(CGFloat)Y Width:(CGFloat)width Height:(CGFloat)height;

+ (CGFloat)getScaleX;

+ (CGFloat)getScaleY;

+ (CGFloat)irScaleX;

+ (CGFloat)irScaleY;

+ (CGSize)getContentHightWithContent:(NSString *)content font:(UIFont *)font constraint:(CGSize)constraint;

+ (NSString *)formateString:(id)object;

+ (void)generyallyAnimationWithView:(UIView *)animationView animationType:(GenerallyAnimationEnum)animationType duration:(float)animationTime delayTime:(float)delayTime finishedBlock: (void (^)(void))completion;

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

+ (id )DicValueForKey:(NSDictionary *)dic key:(NSString *)key;

+ (NSString *)getNowTime:(NSString *)date_format;

+ (NSString *)getDateWithTimestamp:(NSTimeInterval)time format:(NSString *)date_format;

+ (NSString *)formateDataWith:(NSDate *)date formate:(NSString *)fromate;

+ (void)rockView:(UIView *)view;

+ (BOOL)isEnglish;

+ (CGFloat)screenHeight;

+ (UIColor *) colorWithHexString: (NSString *)color;

+ (NSMutableAttributedString *)setTheLineSpacing:(NSString *)title lineSpacing:(CGFloat)space color:(UIColor *)color font:(CGFloat )fontSize;

+ (id)getObjcAtIndex:(NSUInteger)index array:(NSArray *)array;



@end
