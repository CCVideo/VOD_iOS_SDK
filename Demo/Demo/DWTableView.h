#import <UIKit/UIKit.h>

#pragma mark UITableViewDataSource
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
typedef NSInteger(^DWTableViewNumberOfRowsInSectionBlock)(UITableView *tableView, NSInteger section);

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
typedef UITableViewCell *(^DWTableViewCellForRowAtIndexPathBlock)(UITableView *tableView, NSIndexPath *indexPath);
//typedef id(^DWTableViewCellForRowAtIndexPath_t)(UITableView *tableView, NSIndexPath *indexPath);

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
typedef NSInteger (^DWNumberOfSectionsInTableViewBlock)(UITableView * tableView);

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
typedef BOOL (^DWTableViewCanEditRowAtIndexPathBlock)(UITableView *tableView, NSIndexPath *indexPath);

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
typedef void (^DWTableViewCommitEditingStyleforRowAtIndexPathBlock)(UITableView * tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath);

#pragma mark UITableViewDelegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
typedef void(^DWTableViewDidSelectRowAtIndexPathBlock)(UITableView *tableView, NSIndexPath *indexPath);



@interface DWTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (copy, nonatomic)DWTableViewNumberOfRowsInSectionBlock tableViewNumberOfRowsInSection;
@property (copy, nonatomic)DWTableViewCellForRowAtIndexPathBlock tableViewCellForRowAtIndexPath;
@property (copy, nonatomic)DWTableViewDidSelectRowAtIndexPathBlock tableViewDidSelectRowAtIndexPath;
@property (copy, nonatomic)DWTableViewCanEditRowAtIndexPathBlock  tableViewCanEditRowAtIndexPath;
@property (copy, nonatomic)DWTableViewCommitEditingStyleforRowAtIndexPathBlock tableViewCommitEditingStyleforRowAtIndexPath;
@property (copy, nonatomic)DWNumberOfSectionsInTableViewBlock numberOfSectionsInTableView;

- (void)resetDelegate;

@end
