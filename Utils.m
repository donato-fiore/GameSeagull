#import "Utils.h"
#import <dlfcn.h>
#import "substrate.h"

uint64_t bh_memmem(const uint8_t* haystack, size_t hlen, const uint8_t* needle, size_t nlen) {
    size_t last, scan = 0;
    size_t bad_char_skip[UCHAR_MAX + 1];
    if (nlen <= 0 || !haystack || !needle) return 0;
    for (scan = 0; scan <= UCHAR_MAX; scan = scan + 1) bad_char_skip[scan] = nlen;
    
    last = nlen - 1;
    for (scan = 0; scan < last; scan = scan + 1)
        bad_char_skip[needle[scan]] = last - scan;

    while (hlen >= nlen) {
        for (scan = last; haystack[scan] == needle[scan]; scan = scan - 1) {
            if (scan == 0) return (uint64_t)haystack;
            if (*(uint32_t *)haystack == 0xd65f03c0) return 0; // reached ret
            if (*(uint32_t *)haystack == 0xd65f0fff) return 0; // reached retab
        }
        
        hlen -= bad_char_skip[haystack[last]];
        haystack += bad_char_skip[haystack[last]];
    }
    return 0;
}

int (*__LHPatchMemory)(const struct LHMemoryPatch *patches, int count);
int PatchMemory(const struct LHMemoryPatch *patches, int count) {
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        void* lhImage = dlopen((ROOT_PATH("/usr/lib/libhooker.dylib")), RTLD_NOW);
        if(lhImage) {
            __LHPatchMemory = (void*)dlsym(lhImage, "LHPatchMemory");
        }
    });

    if(__LHPatchMemory) {
        return __LHPatchMemory(patches, count);
    } else {
        for(int i = 0; i < count; i++)
        {
            struct LHMemoryPatch patch = patches[i];
            MSHookMemory(patch.destination, patch.data, patch.size);
        }
        return 0;
    }
}

void HookMemory(Class class, SEL selector, uint64_t offset, uint32_t data) {
	void *final_offset = (void *)[class instanceMethodForSelector:selector] + offset;
	struct LHMemoryPatch patch;
	patch.destination = final_offset;
	patch.data = &data;
	patch.size = sizeof(data);
	patch.options = NULL;

	PatchMemory(&patch, 1);
}

void alert(UIView* object, NSString *title, NSString *message) {
    UIViewController *vc = object.window.rootViewController;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [vc presentViewController:alert animated:YES completion:nil];
}

NSDictionary *getPreferences() {
    static NSDictionary *preferences;
    if (!preferences) {
        CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.fiore.gameseagull.prefs"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

        if (keyList) {
            preferences = (__bridge NSDictionary *)CFPreferencesCopyMultiple(keyList, CFSTR("com.fiore.gameseagull.prefs"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
            CFRelease(keyList);
        }

        if (!preferences) {
            preferences = [[NSDictionary alloc] initWithContentsOfFile:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.fiore.gameseagull.prefs.plist")];

        }
    }

    return preferences;
}

bool boolForKey(NSString *key) {
    if (!getPreferences()) return false;

    id val = getPreferences()[key];
    return val ? [val boolValue] : false;
}

UIButton *makeButton(NSString *title, CGRect frame, id target, SEL selector) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:frame];
    [button setBackgroundColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:.85]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 14;
    return button;
}

SCNVector3 getAimbotPos(int multiplier, int number) {
	if (multiplier == 1 && number == 25) {
		return SCNVector3Make(0.0, 0.325, 0.0);
	} else if (multiplier == 1 && number == 50) {
		return SCNVector3Make(0.0, 0.35, 0.0);
	}
	
	NSArray *points = @[
		@[
			@[@0.05, @0.5, @0.0],
			@[@0.2, @0.0, @0.0],
			@[@0.0, @0.0, @0.0],
			@[@0.2, @0.5, @0.0],
			@[@-0.05, @0.5, @0.0],
			@[@0.2, @0.35, @0.0],
			@[@-0.2, @0.0, @0.0],
			@[@-0.2, @0.3, @0.0],
			@[@-0.2, @0.5, @0.0],
			@[@0.2, @0.3, @0.0],
			@[@-0.2, @0.35, @0.0],
			@[@-0.1, @0.5, @0.0],
			@[@0.2, @0.4, @0.0],
			@[@-0.2, @0.4, @0.0],
			@[@0.2, @0.2, @0.0],
			@[@-0.2, @0.2, @0.0],
			@[@0.1, @0.0, @0.0],
			@[@0.1, @0.5, @0.0],
			@[@-0.1, @0.0, @0.0],
			@[@0.0, @0.5, @0.0]
		], @[
			@[@0.15, @0.815, @0.0],
			@[@0.26, @-0.05, @0.0],
			@[@0.0, @-0.145, @0.0],
			@[@0.4, @0.625, @0.0],
			@[@-0.15, @0.815, @0.0],
			@[@0.49, @0.35, @0.0],
			@[@-0.26, @-0.05, @0.0],
			@[@-0.47, @0.175, @0.0],
			@[@-0.4, @0.625, @0.0],
			@[@0.47, @0.175, @0.0],
			@[@-0.49, @0.35, @0.0],
			@[@-0.26, @0.75, @0.0],
			@[@0.47, @0.46, @0.0],
			@[@-0.47, @0.46, @0.0],
			@[@0.4, @0.05, @0.0],
			@[@-0.4, @0.05, @0.0],
			@[@0.15, @-0.125, @0.0],
			@[@0.26, @0.75, @0.0],
			@[@-0.15, @-0.125, @0.0],
			@[@0.0, @0.835, @0.0],
		],
		@[
			@[@0.1, @0.63, @0.0],
			@[@0.175, @0.1, @0.0],
			@[@0.0, @0.035, @0.0],
			@[@0.25, @0.53, @0.0],
			@[@-0.1, @0.63, @0.0],
			@[@0.3, @0.35, @0.0],
			@[@-0.175, @0.1, @0.0],
			@[@-0.28, @0.25, @0.0],
			@[@-0.25, @0.53, @0.0],
			@[@0.28, @0.25, @0.0],
			@[@-0.3, @0.35, @0.0],
			@[@-0.175, @0.59, @0.0],
			@[@0.28, @0.45, @0.0],
			@[@-0.28, @0.45, @0.0],
			@[@0.25, @0.16, @0.0],
			@[@-0.25, @0.16, @0.0],
			@[@0.1, @0.05, @0.0],
			@[@0.175, @0.59, @0.0],
			@[@-0.1, @0.05, @0.0],
			@[@0.0, @0.65, @0.0]
		]
	];

	NSArray *coords = points[multiplier - 1][number - 1];

	return SCNVector3Make([coords[0] floatValue], [coords[1] floatValue], [coords[2] floatValue]);
}