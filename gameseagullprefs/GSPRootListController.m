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
- (void)apply:(id)sender {
	pid_t pid;
	const char *args[] = {"sh", "-c", "killall MobileSMS", NULL};
	posix_spawn(&pid, "/bin/sh", NULL, NULL, (char *const *)args, NULL);
}
@end
