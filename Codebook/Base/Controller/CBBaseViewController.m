//
//  CBBaseViewController.m
//  Codebook
//
//  Created by YueCheng on 2021/1/8.
//

#import "CBBaseViewController.h"

@interface CBBaseViewController ()

@end

@implementation CBBaseViewController
 
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self initSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupNavigationItems];
}


- (void)didInitialize {
    
}

@end

@implementation CBBaseViewController (CBSubclassingHooks)

- (void)initSubviews {
    // 子类重写
}

- (void)setupNavigationItems {
    // 子类重写
}

@end
