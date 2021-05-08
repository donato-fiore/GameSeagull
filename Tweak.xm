#import <SpriteKit/SpriteKit.h>
#import <SpriteKit/SKView.h>

static BOOL windHack;

#define PLIST_PATH "/var/mobile/Library/Preferences/com.kermit.gameseagullprefs.plist"
#define boolValueForKey(key) [[[NSDictionary dictionaryWithContentsOfFile:@(PLIST_PATH)] valueForKey:key] boolValue]
#define valueForKey(key) [[NSDictionary dictionaryWithContentsOfFile:@(PLIST_PATH)] valueForKey:key]

static void loadPrefs() {
    windHack = boolValueForKey(@"archeryNoWind");
}

%hook ArcheryScene
-(void)setWind:(float)arg1 angle:(float)arg2 {
    loadPrefs();
    if(!windHack) return %orig;
    if(windHack) return %orig(.0, .0);
}
%end

%ctor {
    %init(ArcheryScene = objc_getClass("ArcheryScene"));
    
}