//
//  CBAccountDetailController.h
//  Codebook
//
//  Created by YueCheng on 2021/1/8.
//

#import "CBTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class CBCodeObject;
@interface CBAccountDetailController : CBTableViewController

- (instancetype)initWithObject:(CBCodeObject *)object;

@end

NS_ASSUME_NONNULL_END
