#import "NFCDetailPage.h"

@implementation NFCDetailPage
- (id)initWithName:(NSString *)name {
	self = [super init];

	if (self) {
		self.workflowName = name;
		self.userDefaults = [NSUserDefaults standardUserDefaults];

	}
	return self;
}
- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	[self.view addSubview:self.tableView];
}
- (void)dismissPage {
	[self.delegate.tableView reloadData];
	[self.delegate dismissDetailPageIfExists];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *tags = [self.userDefaults objectForKey:@"NFCShortcutsEntrys"][self.workflowName];
	return tags.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NFCDetailCells"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NFCDetailCells"];
	}

	NSString *uid = [self.userDefaults objectForKey:@"NFCShortcutsEntrys"][self.workflowName][indexPath.row];
	cell.textLabel.text = uid;
	return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Registered Tags";
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
	UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
		NSMutableArray *tags = [[self.userDefaults objectForKey:@"NFCShortcutsEntrys"][self.workflowName] mutableCopy];
		[tags removeObjectAtIndex:indexPath.row];

		NSMutableDictionary *entrys = [[self.userDefaults objectForKey:@"NFCShortcutsEntrys"] mutableCopy];
		if (tags.count == 0){
			[entrys removeObjectForKey:self.workflowName];
			[self.userDefaults setObject:[entrys copy] forKey:@"NFCShortcutsEntrys"];
		}
		else {
			[entrys setObject:tags forKey:self.workflowName];
			[self.userDefaults setObject:[entrys copy] forKey:@"NFCShortcutsEntrys"];
		}

		[self.tableView reloadData];

		completionHandler(YES);
	}];

	UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
	return config;
}
@end
