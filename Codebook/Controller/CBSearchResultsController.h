//
//  CBSearchResultsController.h
//  Codebook
//
//  Created by YueCheng on 2021/1/8.
//

#import "CBTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CBSearchResultsController : CBTableViewController <UISearchResultsUpdating>

@property (nonatomic, weak) UINavigationController *currentNavigationController;

@end

NS_ASSUME_NONNULL_END
