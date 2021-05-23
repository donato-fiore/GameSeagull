#import <SpriteKit/SpriteKit.h>
#import <SpriteKit/SKView.h>
#import <UIKit/UIKit.h>

static BOOL windHack;
static BOOL trajectoryHack;
static BOOL tankWind;
static BOOL dartHack;
static int dartMode;

#define PLIST_PATH "/var/mobile/Library/Preferences/com.kermit.gameseagullprefs.plist"
#define boolValueForKey(key) [[[NSDictionary dictionaryWithContentsOfFile:@(PLIST_PATH)] valueForKey:key] boolValue]
#define valueForKey(key) [[[NSDictionary dictionaryWithContentsOfFile:@(PLIST_PATH)] valueForKey:key] intValue]

static void loadPrefs() {
    windHack = boolValueForKey(@"archeryNoWind");
    trajectoryHack = boolValueForKey(@"showTrajectory");
    tankWind = boolValueForKey(@"tankNoWind");
    dartHack = boolValueForKey(@"oneDart");
    dartMode = valueForKey(@"dartMode");
}

%hook ArcheryScene
-(void)setWind:(float)arg1 angle:(float)arg2 {
    loadPrefs();
    if(!windHack) return %orig;
    if(windHack) return %orig(.0, .0);
}
%end

%hook PoolBall
-(BOOL)isStripes {
    loadPrefs();
    if(trajectoryHack) return true;
    return %orig;
    
}
-(BOOL)isSolid {
    loadPrefs();
    if(trajectoryHack) return true;
    return %orig;
}
%end

%hook TanksWind
-(void)setWind:(float)arg1 {
    loadPrefs();
    if(!tankWind) return %orig;
    if(tankWind) return %orig(.0);
}
%end

%hook DartsScene
-(void)showScore2:(int)arg1 full_score:(int)arg2 multi:(int)arg3 pos:(CGPoint)arg4 send_pos:(CGPoint)arg5 {
    loadPrefs();
    int num;
    if(dartMode == 1) {
        num = 101;
    } else if(dartMode == 2) {
        num = 201;
    } else if(dartMode == 3) {
        num = 301;
    }
    if(!dartHack) return %orig;
    if(dartHack) return %orig(arg1, num, arg3, arg4, arg5);
}
%end

%ctor {
    %init(ArcheryScene = objc_getClass("ArcheryScene"), PoolBall = objc_getClass("PoolBall"), TanksWind = objc_getClass("TanksWind") DartsScene = objc_getClass("DartsScene"));
}
