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
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20 + 52 + 10, 0, CGRectGetWidth(tableView.bounds) - 20 - 52 - 10 - 15, CGRectGetHeight(cell.bounds))];
        textField.tag = 1000;
        textField.delegate = self;
        [cell.contentView addSubview:textField];
    }

    NSString *title = nil;
    NSString *detail = nil;
    switch (indexPath.row) {
        case 0:
            title = @"账号：";
            detail = self.codeObject.account;
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
    cell.textLabel.text = title;
    ((UITextField *)[cell viewWithTag:1000]).text = detail;
      
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
