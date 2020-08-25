#import "NFCSetupPage.h"

@interface WFWorkflowSettingsViewController : UIViewController
- (id)workflow;
@end

%hook WFWorkflowSettingsViewController
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 6) {
		UITableViewCell *cell = [[UITableViewCell alloc] init];
		cell.textLabel.text = @"Add to NFC";
		cell.textLabel.textColor = [[UIColor alloc] initWithRed:0 green:0.478 blue:1 alpha:1];
		return cell;
	}
	else {
		return %orig;
	}
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 6) {
		NSString *name = [[self workflow] name];
		NFCSetupPage *nfcPage = [[NFCSetupPage alloc] initWithName:name];

		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:nfcPage];
		[navController setToolbarHidden:YES animated:NO];

		UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:nfcPage action:@selector(dismissPage)];
		nfcPage.navigationItem.leftBarButtonItem = dismissButton;
		nfcPage.navigationItem.title = @"NFC Setup";
		[navController setNavigationBarHidden:NO];

		[self presentViewController:navController animated:YES completion:nil];
	}
	else  {
		%orig;
	}
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 6) {
		return 1;
	}
	else {
		return %orig;
	}
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 6) {
		return @"Run this shortcut by using a NFC enabled tag.";
	}
	else {
		return %orig;
	}
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return %orig + 1;
}
%end
