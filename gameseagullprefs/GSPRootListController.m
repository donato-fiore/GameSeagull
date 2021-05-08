#include "GSPRootListController.h"

@implementation GSPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}
-(void)sourceCode {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/donato-fiore/GameSeagull"]];
}

@end
