//
//  CBAccountDetailController.m
//  Codebook
//
//  Created by YueCheng on 2021/1/8.
//

#import "CBAccountDetailController.h"
#import "CBCodeObject.h"
#import "CBNewAccountController.h"
#import "CBNavigationController.h"

@interface CBAccountDetailController ()

@property (nonatomic, strong) CBCodeObject *object;

@end

@implementation CBAccountDetailController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithObject:(CBCodeObject *)object {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.object = object;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editObject:) name:CBNewObjectNotification object:nil];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
}

#pragma mark - NSNotificationCenter
- (void)editObject:(NSNotification *)notification {
    NSDictionary *infoDictionary = notification.object;
    self.object = (CBCodeObject *)infoDictionary[@"new"];
    [self.tableView reloadData];
}

#pragma mark - Action
- (void)editAction:(UIBarButtonItem *)sender {
    CBNavigationController *navigation = [[CBNavigationController alloc] initWithRootViewController:[[CBNewAccountController alloc] initWithObject:self.object]];
    [self presentViewController:navigation animated:YES completion:nil];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifer = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifer];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    NSString *title = nil;
    NSString *detail = nil;
    switch (indexPath.row) {
        case 0:
            title = @"类型";
            detail = self.object.typeString;
            break;
        case 1:
            title = @"账号";
            detail = self.object.account;
            break;
        case 2:
            title = @"密码";
            detail = self.object.password;
            break;
        case 3:
            title = @"备注";
            detail = self.object.extra;
            break;
    }
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *copyString = nil;
    switch (indexPath.row) { 
        case 1:
            copyString = self.object.account;
            break;
        case 2:
            copyString = self.object.password;
            break;
    }
    
    if (copyString) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = copyString;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"已复制到剪切板" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGSize size = [cell.detailTextLabel sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds) - 92, CGFLOAT_MAX)];
    return size.height + 24 < 44 ? 44 : size.height + 24;
}

 

@end
