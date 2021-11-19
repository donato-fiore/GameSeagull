#include <Preferences/PSListController.h>
#include <CepheiPrefs/HBListController.h>
#include <CepheiPrefs/HBAppearanceSettings.h>
#include <Cephei/HBPreferences.h>
#include "spawn.h"

@interface GSPRootListController : PSListController
@property (nonatomic, retain) UIBarButtonItem *applyButton;
@end

@interface WinSpooferController : PSListController
@property(nonatomic, retain) UIBarButtonItem *doneButton;
@end