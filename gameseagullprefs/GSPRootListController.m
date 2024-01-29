#import "GSPRootListController.h"

#ifdef ROOTLESS
@import CepheiPrefs.Swift;
#else
@import Preferences.PSSpecifier;
@import CepheiPrefs.HBAppearanceSettings;
#endif

@implementation GSPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
		appearanceSettings.tintColor = TINT_COLOR;
		self.hb_appearanceSettings = appearanceSettings;

		self.applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:[self class] action:@selector(apply)];
		self.applyButton.tintColor = TINT_COLOR;
		self.navigationItem.rightBarButtonItem = self.applyButton;
	}

	return self;
}

extern char **environ;
+ (void)apply {
	const char *args[] = {
		[ROOT_PATH_NS(@"/usr/bin/killall") UTF8String],
		"MobileSMS",
		NULL
	};
	pid_t pid = -1;
	posix_spawn(&pid, args[0], NULL, NULL, (char *const *)args, environ);
}

@end

@implementation GSPWinSpooferController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"WinSpoofer" target:self];
	}

	return _specifiers;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		self.keyboardDownButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"keyboard.chevron.compact.down"] style:UIBarButtonItemStylePlain target:self action:@selector(keyboardDown)];
		self.keyboardDownButton.tintColor = TINT_COLOR;
		self.navigationItem.rightBarButtonItem = self.keyboardDownButton;
	}

	return self;
}

- (void)keyboardDown {
	[self.view endEditing:true];
	[GSPRootListController apply];
}

@end

@implementation GSPWinSpooferCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier  {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

    if (self) {
		LSBundleProxy *bundleProxy = [LSBundleProxy bundleProxyForIdentifier:@"com.gamerdelights.gamepigeon.ext"];
		NSString *winsDataPath = [NSString stringWithFormat:@"%@/Library/Preferences/com.gamerdelights.gamepigeon.ext.plist", bundleProxy.dataContainerURL.path];
		NSDictionary *winsData = [NSDictionary dictionaryWithContentsOfFile:winsDataPath];
		NSString *wins = [NSString stringWithFormat:@"%@", [winsData objectForKey:[NSString stringWithFormat:@"%@_wins", specifier.properties[@"key"]]]];
		if ([wins length] < 1) wins = @"0";

		[self setPlaceholderText:wins];

		for (UIView *subview in self.contentView.subviews) {
			if ([subview isKindOfClass:[UITextField class]]) {
				UITextField *input = (UITextField *)subview;
				input.textAlignment = NSTextAlignmentRight;
			}
		}
	}
	
	return self;
}

@end