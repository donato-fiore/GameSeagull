#include "GSPRootListController.h"
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import <CepheiPrefs/HBRootListController.h>

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
        appearanceSettings.tintColor = [UIColor colorWithRed:1.0f green:0.81f blue:0.86f alpha:1];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
        self.hb_appearanceSettings = appearanceSettings;
    }
    return self;
}

-(void)github {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/donato-fiore/GameSeagull"]];
}

- (void)apply:(id)sender {
	pid_t pid;
	const char *args[] = {"sh", "-c", "killall MobileSMS", NULL};
	posix_spawn(&pid, "/bin/sh", NULL, NULL, (char *const *)args, NULL);
}

@end

@implementation WinSpooferController
@synthesize doneButton;
- (void)viewDidLoad {
	[super viewDidLoad];

	UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
    done.frame = CGRectMake(0,0,30,30);
    done.layer.cornerRadius = done.frame.size.height / 2;
    done.layer.masksToBounds = YES;
    [done setImage:[UIImage systemImageNamed:@"keyboard.chevron.compact.down"] forState:UIControlStateNormal];
    [done addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    
    doneButton = [[UIBarButtonItem alloc] initWithCustomView:done];
    
    self.navigationItem.rightBarButtonItems = @[doneButton];
}
- (void)loadView {
	[super loadView];
	((UITableView *)[self table]).keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"WinSpoofing" target:self];
	}
	return _specifiers;
}
- (void)dismiss:(id)sender {
	[self.view endEditing:YES];
}
@end
