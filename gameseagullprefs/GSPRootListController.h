#include <CepheiPrefs/CepheiPrefs.h>
#include <Cephei/HBPreferences.h>
#include "spawn.h"

@interface GSPRootListController : HBListController
@property (nonatomic, retain) UIBarButtonItem *applyButton;
@end

@interface WinSpooferController : HBListController
@property(nonatomic, retain) UIBarButtonItem *doneButton;
@end
