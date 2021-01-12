//
//  CBSettingController.m
//  Codebook
//
//  Created by 米画师 on 2021/1/11.
//

#import "CBSettingController.h"
#import "CBCodeObject.h"
 
NSString *const CBLocalAuthenticationEnabled = @"CBLocalAuthenticationEnabled";

@interface CBSettingController ()

@end

@implementation CBSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
     
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
 
    self.title = @"设置";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose target:self action:@selector(closeAction:)];
}

#pragma mark - Method
- (void)exportJSON {
    NSString *localPath = [CBCodeObject savePasswordListToLocal];
    if (localPath) {
        [self dismissViewControllerAnimated:YES completion:^{
            NSArray *activityItems = @[[NSURL fileURLWithPath:localPath]];
            UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            activity.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                [[NSFileManager defaultManager] removeItemAtPath:localPath error:nil];
            };
            [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:activity animated:YES completion:nil];
        }];
    }
}

#pragma mark - Action
- (void)closeAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchAction:(UISwitch *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:sender.isOn forKey:CBLocalAuthenticationEnabled];
    [userDefaults synchronize];
}
 

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifer = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifer];
        UISwitch *accessoryView = [[UISwitch alloc] init];
        [accessoryView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = accessoryView;
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"使用TouchID 或者 FaceID";
            cell.accessoryView.hidden = NO;
            ((UISwitch *)cell.accessoryView).on = [[NSUserDefaults standardUserDefaults] boolForKey:CBLocalAuthenticationEnabled];
            break;
            
        default:
            cell.textLabel.text = @"导出json文本";
            cell.accessoryView.hidden = YES;
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        [self exportJSON];
    }
}

@end
