#import "DWTableView.h"

@interface DWTableView ()

@end

@implementation DWTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)resetDelegate
{
    self.delegate = self;
    self.dataSource = self;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableViewNumberOfRowsInSection) {
        return self.tableViewNumberOfRowsInSection(tableView, section);
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath* )indexPath
{
    if (self.tableViewCellForRowAtIndexPath) {
        return self.tableViewCellForRowAtIndexPath(tableView, indexPath);
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.numberOfSectionsInTableView) {
        return self.numberOfSectionsInTableView(tableView);
    }
    
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewCanEditRowAtIndexPath) {
        return self.tableViewCanEditRowAtIndexPath(tableView, indexPath);
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewCommitEditingStyleforRowAtIndexPath) {
        return self.tableViewCommitEditingStyleforRowAtIndexPath(tableView, editingStyle, indexPath);
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewDidSelectRowAtIndexPath) {
        self.tableViewDidSelectRowAtIndexPath(tableView, indexPath);
    }
}

@end
