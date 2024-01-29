@import CepheiPrefs.HBRootListController;
@import Foundation;
@import Preferences.PSEditableTableCell;

#import <CepheiPrefs/PSListController+HBTintAdditions.h>

#import "spawn.h"
#import "../Utils.h"

#define TINT_COLOR [UIColor colorWithRed: 1.00 green: 0.60 blue: 0.69 alpha: 1.00]

@interface GSPRootListController : HBListController
@property (nonatomic, retain) UIBarButtonItem *applyButton;
@end

@interface GSPWinSpooferController : HBListController
@property (nonatomic, retain) UIBarButtonItem *keyboardDownButton;
@end

@interface GSPWinSpooferCell : PSEditableTableCell
@end

@interface LSBundleProxy : NSObject
@property(readonly) NSURL * dataContainerURL;
+ (id)bundleProxyForIdentifier:(id)arg1;
@end

@interface PSEditableTableCell ()
- (void)setPlaceholderText:(NSString *)arg1;
@end
