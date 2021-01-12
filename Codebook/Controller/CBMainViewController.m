//
//  CBMainViewController.m
//  Codebook
//
//  Created by YueCheng on 2021/1/8.
//

#import "CBMainViewController.h"
#import "CBSearchResultsController.h"
#import "CBNavigationController.h"
#import "CBNewAccountController.h"
#import "CBAccountDetailController.h"
#import "CBCodeObject.h"
#import "CBSettingController.h"
#import "CBAuthenticationController.h"

@interface CBMainViewController ()

@property (nonatomic, strong) UISearchController        *searchController;
@property (nonatomic, strong) CBSearchResultsController *searchResultsController;
@property (nonatomic, strong) NSMutableArray <CBCodeObject *>*dataSource;

@end

@implementation CBMainViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    self.navigationItem.title = @"密码";
    BOOL isEditing = self.tableView.isEditing;
    self.navigationController.navigationBar.prefersLargeTitles = !isEditing;
    self.navigationItem.searchController = isEditing ? nil : self.searchController;
    if (isEditing) {
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
        self.navigationItem.rightBarButtonItems = @[done];
    } else {
        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
        UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAction:)];
        UIBarButtonItem *set = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(setAction:)];
        self.navigationItem.rightBarButtonItems = @[add, delete, set];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newObject:) name:CBNewObjectNotification object:nil];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CBLocalAuthenticationEnabled]) {
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:[[CBAuthenticationController alloc] init]];
        navigation.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navigation animated:YES completion:nil];
    }
    [self.tableView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)]];
}

#pragma mark - NSNotificationCenter
- (void)newObject:(NSNotification *)notification {
    NSDictionary *infoDictionary = notification.object;
    CBCodeObject *newObject = infoDictionary[@"new"];
    id oldObject = infoDictionary[@"old"];
    if ([oldObject isKindOfClass:[CBCodeObject class]]) {
        [self.dataSource replaceObjectAtIndex:[self.dataSource indexOfObject:oldObject] withObject:newObject];
    } else {
        [self.dataSource addObject:newObject];
    }
    [self.tableView reloadData];
}

#pragma mark - Method
- (void)addAccount {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
    }
    CBNavigationController *navigation = [[CBNavigationController alloc] initWithRootViewController:[[CBNewAccountController alloc] init]];
    [self presentViewController:navigation animated:YES completion:nil];
}
 
#pragma mark - Action
- (void)longPressAction:(UILongPressGestureRecognizer *)sender {
    if (!self.tableView.editing) {
        [self.tableView setEditing:YES animated:YES];
        [self setupNavigationItems];
    }
}

- (void)doneAction:(UIBarButtonItem *)sender {
    [self.tableView setEditing:NO animated:YES];
    [self setupNavigationItems];
}

- (void)addAction:(UIBarButtonItem *)sender {
    [self addAccount];
}

- (void)deleteAction:(UIBarButtonItem *)sender {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除所有数据？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SAMKeychain deletePasswordForService:CBKeychainService account:CBKeychainAccount];
        [self reloadTableView];
    }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setAction:(UIBarButtonItem *)sender {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
    }
    CBNavigationController *navigation = [[CBNavigationController alloc] initWithRootViewController:[[CBSettingController alloc] init]];
    [self presentViewController:navigation animated:YES completion:nil];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifer = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifer];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    CBCodeObject *object = self.dataSource[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@", object.typeString, object.account];
    cell.detailTextLabel.text = object.extra;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBAccountDetailController *detail = [[CBAccountDetailController alloc] initWithObject:self.dataSource[indexPath.row]];
    [self.navigationController pushViewController:detail animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.dataSource exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [tableView reloadData];
    NSMutableArray *originalData = [[CBCodeObject allDictionarys] mutableCopy];
    [originalData exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [CBCodeObject saveAllData:originalData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        CBCodeObject *object = self.dataSource[indexPath.row];
        [object deleteCodeObject];
        [self.dataSource removeObject:object];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        completionHandler(YES);
    }];
    
    UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[action]];
    configuration.performsFirstActionWithFullSwipe = NO;
    
    return configuration;
}

#pragma mark - Method
- (void)reloadTableView {
    self.dataSource = nil;
    [self.tableView reloadData];
}

#pragma mark - Get
- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
        _searchController.searchResultsUpdater = self.searchResultsController;
        _searchController.searchBar.autocapitalizationType = 0;
        _searchController.obscuresBackgroundDuringPresentation = NO;
        _searchController.searchBar.scopeButtonTitles = @[@"App", @"网站", @"银行卡", @"其他"];
    }
    return _searchController;
}

- (CBSearchResultsController *)searchResultsController {
    if (!_searchResultsController) {
        _searchResultsController = [[CBSearchResultsController alloc] init];
        _searchResultsController.currentNavigationController = self.navigationController;
    }
    return _searchResultsController;
}

- (NSMutableArray<CBCodeObject *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithArray:[CBCodeObject allObjects]];
    }
    return _dataSource;
}

@end
