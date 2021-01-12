//
//  AppDelegate.m
//  Codebook
//
//  Created by YueCheng on 2021/1/8.
//

#import "AppDelegate.h"
#import "CBNavigationController.h"
#import "CBMainViewController.h"


@interface AppDelegate ()

@property (nonatomic, strong) CBMainViewController *mainViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application
performActionForShortcutItem:(nonnull UIApplicationShortcutItem *)shortcutItem
  completionHandler:(nonnull void (^)(BOOL))completionHandler {
    if ([shortcutItem.type isEqualToString:@"add"]) {
        [self.mainViewController addAccount];
    }
}

#pragma mark - Get

- (UIWindow *)window {
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _window.backgroundColor = [UIColor whiteColor];
        _window.rootViewController = [[CBNavigationController alloc] initWithRootViewController:self.mainViewController];
    }
    return _window;
}

- (CBMainViewController *)mainViewController {
    if (!_mainViewController) {
        _mainViewController = [[CBMainViewController alloc] init];
    }
    return _mainViewController;
}


@end
