//
//  CBTableViewController.h
//  Codebook
//
//  Created by YueCheng on 2021/1/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBTableViewController : UITableViewController

- (void)didInitialize NS_REQUIRES_SUPER;

@end

@interface CBTableViewController (CBSubclassingHooks)

- (void)setupNavigationItems NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
