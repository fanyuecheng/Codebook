//
//  CBAuthenticationController.m
//  Codebook
//
//  Created by 米画师 on 2021/1/11.
//

#import "CBAuthenticationController.h"
#import "CBLocalAuthentication.h"
 
@interface CBAuthenticationController ()

@property (nonatomic, strong) UIButton *authenticateButton;

@end

@implementation CBAuthenticationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self authenticateAction:nil];
}

- (void)initSubviews {
    [super initSubviews];
    
    [self.view addSubview:self.authenticateButton];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.title = @"验证登录";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.authenticateButton.frame = self.view.bounds;
}

#pragma mark - Action
- (void)authenticateAction:(UIButton *)sender {
    [[CBLocalAuthentication sharedInstance] authenticationWithDescribe:@"开始验证" stateBlock:^(NSError * _Nonnull error) {
        if (!error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - Get
- (UIButton *)authenticateButton {
    if (!_authenticateButton) {
        _authenticateButton = [[UIButton alloc] init];
        [_authenticateButton setTitle:@"开始验证" forState:UIControlStateNormal];
        [_authenticateButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
        [_authenticateButton addTarget:self action:@selector(authenticateAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _authenticateButton;
}

@end
