#import <Preferences/PSListController.h>
#import <CepheiPrefs/HBListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import <CepheiPrefs/HBRootListController.h>

@interface GSPRootListController : PSListController
@property (nonatomic, retain) UIBarButtonItem *applyButton;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIImageView *iconView;
-(void)apply;
@end

@interface WinSpooferController : PSListController
@property(nonatomic, retain) UIBarButtonItem *doneButton;
@end