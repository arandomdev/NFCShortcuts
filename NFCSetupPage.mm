#import "NFCSetupPage.h"
#import "NFCDetailPage.h"
extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

void detectedTags(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef data) {
	NSDictionary *userInfo = (__bridge NSDictionary *)data;
	NSString *uid = userInfo[@"data"][0][@"uid"];

	NFCSetupPage *controller = (__bridge NFCSetupPage *)observer;
	NSMutableDictionary *entrys = [[controller.userDefaults objectForKey:@"NFCShortcutsEntrys"] mutableCopy];
	NSArray *tags = entrys[controller.workflowName];
	if (!tags) {
		[entrys setObject:@[uid] forKey:controller.workflowName];
		[controller.userDefaults setObject:[entrys mutableCopy] forKey:@"NFCShortcutsEntrys"];
	}
	else if (![tags containsObject:uid]) {
		NSMutableArray *mutableTags = [tags mutableCopy];
		[mutableTags addObject:uid];
		[entrys setObject:[mutableTags copy] forKey:controller.workflowName];
		[controller.userDefaults setObject:[entrys mutableCopy] forKey:@"NFCShortcutsEntrys"];
	}

	dispatch_async(dispatch_get_main_queue(), ^{
  	[controller.tableView reloadData];
	});
}

@implementation NFCSetupPage
- (id)initWithName:(NSString *)name {
	self = [super init];

	if (self) {
		self.workflowName = name;
		self.userDefaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *entrys = [self.userDefaults objectForKey:@"NFCShortcutsEntrys"];
		if (!entrys) {
			[self.userDefaults setObject:[NSDictionary new] forKey:@"NFCShortcutsEntrys"];
		}

		CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
		CFNotificationCenterAddObserver(center, (__bridge void *)self, detectedTags, CFSTR("nfcbackground.newtag"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPage) name:UIApplicationDidEnterBackgroundNotification object:nil];
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}
- (void)dismissPage {
	CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
	CFNotificationCenterRemoveObserver(center, (__bridge void *)self, CFSTR("nfcbackground.newtag"), NULL);

	[self dismissDetailPageIfExists];
	[self dismissViewControllerAnimated:YES completion:nil];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSDictionary *entrys = [self.userDefaults objectForKey:@"NFCShortcutsEntrys"];
	if (section == 0) {
		NSArray *tags = entrys[self.workflowName];
		if (tags) {
			return tags.count;
		}
		else {
			return 0;
		}
	}
	else {
		return entrys.count;
	}
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NFCPageCells"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NFCPageCells"];
	}

	if (indexPath.section == 0) {
		NSString *uid = [self.userDefaults objectForKey:@"NFCShortcutsEntrys"][self.workflowName][indexPath.row];
		cell.textLabel.text = uid;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else {
		NSArray *entrys = [[[self.userDefaults objectForKey:@"NFCShortcutsEntrys"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		cell.textLabel.text = entrys[indexPath.row];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Scan a NFC enabled tag now to register this shortcut.";
	}
	else {
		return @"All registered shortcuts.";
	}
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
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
	else {
		return nil;
	}
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return UITableViewCellEditingStyleDelete;
	}
	else {
		return UITableViewCellEditingStyleNone;
	}
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSArray *entrys = [[[self.userDefaults objectForKey:@"NFCShortcutsEntrys"] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	NSString *name = entrys[indexPath.row];

	NFCDetailPage *detailPage = [[NFCDetailPage alloc] initWithName:name];
	detailPage.delegate = self;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailPage];
	[navController setToolbarHidden:YES animated:NO];

	UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:detailPage action:@selector(dismissPage)];
	detailPage.navigationItem.leftBarButtonItem = dismissButton;
	detailPage.navigationItem.title = name;
	[navController setNavigationBarHidden:NO];

	self.detailPage = navController;
	[self presentViewController:navController animated:YES completion:nil];
}
- (void)dismissDetailPageIfExists {
	if (self.detailPage) {
		[self.detailPage dismissViewControllerAnimated:YES completion:nil];
		self.detailPage = nil;
	}
}
@end
