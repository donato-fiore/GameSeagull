#import <Preferences/PSListController.h>
#import <CepheiPrefs/HBListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import "spawn.h"

@interface GSPRootListController : PSListController
@end

@interface WinSpooferController : PSListController
@property(nonatomic, retain) UIBarButtonItem *doneButton;
@end