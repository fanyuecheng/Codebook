//
//  CBSearchResultsController.m
//  Codebook
//
//  Created by YueCheng on 2021/1/8.
//

#import "CBSearchResultsController.h"
#import "CBAccountDetailController.h"
#import "CBCodeObject.h"

@interface CBSearchResultsController ()

@property (nonatomic, strong) NSMutableArray *resultArray;

@end

@implementation CBSearchResultsController

- (void)viewDidLoad {
    [super viewDidLoad];
 
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifer = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifer];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    CBCodeObject *object = self.resultArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@", object.typeString, object.account];
    cell.detailTextLabel.text = object.extra; 
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBAccountDetailController *detail = [[CBAccountDetailController alloc] initWithObject:self.resultArray[indexPath.row]];
    [self.currentNavigationController pushViewController:detail animated:YES];
}
 
#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSInteger index = searchController.searchBar.selectedScopeButtonIndex;
    NSArray *objectArray = [self objectArrayWithIndex:index];
    NSString *searchKey = searchController.searchBar.text;
    
    if (self.resultArray.count > 0) {
        [self.resultArray removeAllObjects];
    }
  
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"account CONTAINS[c] %@ or extra CONTAINS[c] %@", searchKey, searchKey];
    NSArray *filteredArray = [objectArray filteredArrayUsingPredicate:predicate];
    if (filteredArray.count) {
        [self.resultArray addObjectsFromArray:filteredArray];
    }
 
    [self.tableView reloadData];
}

#pragma mark - Method
- (NSArray *)objectArrayWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return [CBCodeObject allAppObjects];
            break;
        case 1:
            return [CBCodeObject allWebObjects];
            break;
        case 2:
            return [CBCodeObject allBankObjects];
            break;
        default:
            return [CBCodeObject allOtherObjects];
            break;
    }
}

#pragma mark - Get
- (NSMutableArray *)resultArray {
    if (!_resultArray) {
        _resultArray = [NSMutableArray array];
    }
    return _resultArray;
}

@end
