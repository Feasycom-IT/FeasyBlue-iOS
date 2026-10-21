//
//  SceneDelegate.m
//  FeasyWIFI
//

#import "SceneDelegate.h"
#import "AppDelegate.h"

@implementation SceneDelegate

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) return;

    // AppDelegate 在 didFinishLaunching 中已创建 window 和根控制器，这里挂到场景上
    UIWindow *window = [self appDelegate].window;
    if (!window) {
        window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
        [self appDelegate].window = window;
    }
    window.windowScene = (UIWindowScene *)scene;
    window.frame = ((UIWindowScene *)scene).coordinateSpace.bounds;
    self.window = window;
    [window makeKeyAndVisible];
}

- (void)sceneWillResignActive:(UIScene *)scene {
    [[self appDelegate] applicationWillResignActive:[UIApplication sharedApplication]];
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    [[self appDelegate] applicationDidBecomeActive:[UIApplication sharedApplication]];
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    [[self appDelegate] applicationWillEnterForeground:[UIApplication sharedApplication]];
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    [[self appDelegate] applicationDidEnterBackground:[UIApplication sharedApplication]];
}

@end
