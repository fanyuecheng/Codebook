//
//  CBNewAccountController.m
//  Codebook
//
//  Created by YueCheng on 2021/1/8.
//

#import "CBNewAccountController.h"
#import "CBCodeObject.h"

@interface CBNewAccountController () <UITextFieldDelegate>

@property (nonatomic, strong) CBCodeObject *originalObject;
@property (nonatomic, strong) CBCodeObject *codeObject;
@property (nonatomic, strong) UIScrollView *accountAccessoryView;

@end

@implementation CBNewAccountController

- (instancetype)initWithObject:(CBCodeObject *)object {
    if (self = [super init]) {
        self.originalObject = object;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose target:self action:@selector(closeAction:)];
}

#pragma mark - Action
- (void)doneAction:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    
    BOOL success = [self.codeObject saveCodeObject];
    if (success) {
        if (self.originalObject) {
            [self.originalObject deleteCodeObject];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:CBNewObjectNotification
                                                            object:@{@"new" : self.codeObject,
                                                                     @"old" : self.originalObject ? self.originalObject : [NSNull null],
                                                                     @"type" : self.originalObject ? @"edit" : @"creat"}
                                                          userInfo:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tayeAction:(UISegmentedControl *)sender {
    self.codeObject.type = sender.selectedSegmentIndex;
}

- (void)accountAction:(UIButton *)sender {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    ((UITextField *)[cell.contentView viewWithTag:1000]).text = sender.currentTitle;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    switch (indexPath.row) {
        case 0:
            self.codeObject.account = textField.text;
            break;
        case 1:
            self.codeObject.password = textField.text;
            break;
        case 2:
            self.codeObject.extra = textField.text;
            break;
        default:
            break;
    }
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifer = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifer];
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    }
    
    UITextField *textField = [cell.contentView viewWithTag:1000];
    if (!textField) {
        textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(tableView.bounds) - 30, CGRectGetHeight(cell.bounds))];
        textField.tag = 1000;
        textField.delegate = self;
        UILabel *leftView = [[UILabel alloc] init];
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.leftView = leftView;
        [cell.contentView addSubview:textField];
    }
    
    [cell.contentView addSubview:textField];

    NSString *title = nil;
    NSString *detail = nil;
    UIView *accountAccessoryView = nil;
    switch (indexPath.row) {
        case 0:
            title = @"账号：";
            detail = self.codeObject.account;
            accountAccessoryView = self.accountAccessoryView;
            break;
        case 1:
            title = @"密码：";
            detail = self.codeObject.password;
            break;
        case 2:
            title = @"备注：";
            detail = self.codeObject.extra;
            break;
        default:
            break;
    }
    ((UILabel *)textField.leftView).text = title;
    [textField.leftView sizeToFit];
    textField.text = detail;
    textField.inputAccessoryView = accountAccessoryView;
      
    return cell;
}
 
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 50)];
    header.backgroundColor = [UIColor whiteColor];
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[@"App", @"网站", @"银行卡", @"其他"]];
    control.selectedSegmentIndex = self.codeObject.type;
    control.frame = CGRectMake(15, 10, CGRectGetWidth(tableView.bounds) - 30, 30);
    [control addTarget:self action:@selector(tayeAction:) forControlEvents:UIControlEventValueChanged];
    [header addSubview:control];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Method
- (UIScrollView *)accountAccessoryView {
    if (!_accountAccessoryView) {
        NSArray *accounts = [CBCodeObject commonAccounts];
        
        if (accounts.count) {
            _accountAccessoryView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
            _accountAccessoryView.showsHorizontalScrollIndicator = NO;
            _accountAccessoryView.backgroundColor = [UIColor whiteColor];
            
            __block UIButton *lastButton = nil;
            [accounts enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIButton *button = [[UIButton alloc] init];
                button.layer.cornerRadius = 4;
                button.layer.masksToBounds = YES;
                button.titleLabel.font = [UIFont systemFontOfSize:14];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [button setTitle:obj forState:UIControlStateNormal];
                button.backgroundColor = [UIColor systemGray6Color];
                [button addTarget:self action:@selector(accountAction:) forControlEvents:UIControlEventTouchUpInside];
                [button sizeToFit];
                [_accountAccessoryView addSubview:button];
                button.frame = CGRectMake(lastButton ? CGRectGetMaxX(lastButton.frame) + 10 : 15, (44 - CGRectGetHeight(button.bounds)) * 0.5, CGRectGetWidth(button.bounds) + 10, CGRectGetHeight(button.bounds));
                lastButton = button;
            }];
            _accountAccessoryView.contentSize = CGSizeMake(CGRectGetMaxX(lastButton.frame) + 15, 0);
        }
    }
    return _accountAccessoryView;
}

#pragma mark - Get
- (CBCodeObject *)codeObject {
    if (!_codeObject) {
        _codeObject = [[CBCodeObject alloc] init];
    }
    return _codeObject;
}

- (void)setOriginalObject:(CBCodeObject *)originalObject {
    _originalObject = originalObject;
    
    self.codeObject.type = originalObject.type;
    self.codeObject.account = originalObject.account;
    self.codeObject.password = originalObject.password;
    self.codeObject.extra = originalObject.extra;
    [self.tableView reloadData];
}

@end
