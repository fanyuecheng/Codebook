//
//  CBBaseViewController.h
//  Codebook
//
//  Created by YueCheng on 2021/1/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBBaseViewController : UIViewController

- (void)didInitialize NS_REQUIRES_SUPER;

@end

@interface CBBaseViewController (CBSubclassingHooks)
 
- (void)initSubviews NS_REQUIRES_SUPER;

- (void)setupNavigationItems NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
