@interface SpringBoard
+ (id)sharedApplication;
- (void)applicationOpenURL:(NSURL *)arg1;
@end

@interface SBApplicationInfo
-(NSUserDefaults *)userDefaults;
@end

@interface SBApplication
-(SBApplicationInfo *)info;
@end

@interface SBApplicationController
+(id)sharedInstance;
-(SBApplication *)applicationWithBundleIdentifier:(NSString *)arg1;
@end

@interface SBLockStateAggregator
+(id)sharedInstance;
-(unsigned long long)lockState;
@end

@interface SBMainWorkspace
+(id)sharedInstance;
-(void)_attemptUnlockToApplication:(id)arg1 showPasscode:(BOOL)arg2 origin:(id)arg3 givenOrigin:(id)arg4 options:(id)arg5 completion:(/*^block*/id)arg6;
@end


extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

void detectedTags(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef data) {
	NSDictionary *userInfo = (__bridge NSDictionary *)data;
	NSString *uid = userInfo[@"data"][0][@"uid"];

	SBApplication *shortcutsApp = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:@"is.workflow.my.app"];
	NSDictionary *entrys = [[[shortcutsApp info] userDefaults] objectForKey:@"NFCShortcutsEntrys"];
	if (!entrys) {
		return;
	}

	for (NSString *name in entrys) {
		if ([entrys[name] containsObject:uid]) {
			NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"shortcuts://run-shortcut?name=%@", [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

			if ([[%c(SBLockStateAggregator) sharedInstance] lockState]) {
				[[%c(SBMainWorkspace) sharedInstance] _attemptUnlockToApplication:shortcutsApp showPasscode:YES origin:nil givenOrigin:nil options:nil completion:^(bool finished) {
					if (finished) {
						[[%c(SpringBoard) sharedApplication] applicationOpenURL:url];
					}
				}];
			}
			else {
				[[%c(SpringBoard) sharedApplication] applicationOpenURL:url];
			}
		}
	}
}

%hook SpringBoard
-(id)init {
	id orig = %orig;

	CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
	CFNotificationCenterAddObserver(center, (__bridge void *)orig, detectedTags, CFSTR("nfcbackground.newtag"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	return orig;
}
%end
