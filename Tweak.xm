#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import <SpriteKit/SKView.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SCNView.h>
#import <SpriteKit/SKNode.h>
#import <SceneKit/SceneKit.h>

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.donato.gameseagullprefs.plist"

@interface GameScene : SKScene {}
@end

@interface BeerView : SCNView {
    NSMutableArray* cups;
}
@end

@interface HuntScene : GameScene
- (void)revealWords:(BOOL)arg1 ;
@end

@interface AnagramsScene : GameScene {
    NSMutableArray* blocks;
}
- (void)revealWords:(BOOL)arg1 ;
-(void)enterWord;
-(void)thingAt:(NSArray *)words wordsArr:(NSMutableArray *)wordsArr blocks:(NSMutableArray *)blocks fromIndex:(int)index;
-(void)fillArr;
@end

@interface AnagramsWordList : SKNode {
	NSString* words_string;
}
@end

@interface GameIcon : UIView {}
-(void)setWins:(int)arg1 ;
-(NSString *)name ;
-(NSString *)_id;
@end

@interface SeaShip : SKNode
@property (retain) SKSpriteNode * sprite; 
@end

@interface SeaScene : GameScene {
    NSMutableArray* ships;
}
@end

BOOL boolForKey(NSString *key) {
    static NSUserDefaults *prefs;
    if (prefs == nil) {
        prefs = [[NSUserDefaults alloc] initWithSuiteName:PLIST_PATH];
    }
    NSNumber *value = [prefs objectForKey:key] ?: @YES;
    return [value boolValue];
}

int valueForKey(NSString *key) {
    static NSUserDefaults *prefs;
    if (prefs == nil) {
        prefs = [[NSUserDefaults alloc] initWithSuiteName:PLIST_PATH];
    }
    NSNumber *value = [prefs objectForKey:key];
    return [value intValue];
}



// Archery
%hook ArcheryScene
-(void)setWind:(float)arg1 angle:(float)arg2 {
    if(boolForKey(@"archeryNoWind")) {
        %orig(0.0, 0.0);
    } else {
        %orig;
    }
}
%end



// 8 ball
%hook PoolBall
-(BOOL)isStripes {
    if(boolForKey(@"showTrajectory")) {
        return true;
    }
    return %orig;
}
-(BOOL)isSolid {
    if(boolForKey(@"showTrajectory")) {
        return true;
    }
    return %orig;
}
%end

%hook PoolScene
// 1 is 8 ball 2 is 8ball+ 3 is 9ball
-(void)didMoveToView:(id)arg1 {
    %orig;
    if(boolForKey(@"noHardMode")) {
        MSHookIvar<NSString*>(self, "mode") = @"n";
    }    
}
%end

%hook PoolScene2
-(void)didMoveToView:(id)arg1 {
    %orig;
    if(boolForKey(@"noHardMode")) {
        MSHookIvar<NSString*>(self, "mode") = @"n";
    }
}
%end
%hook PoolScene3
-(void)didMoveToView:(id)arg1 {
    %orig;
    if(boolForKey(@"noHardMode")) {
        MSHookIvar<NSString*>(self, "mode") = @"n";
    }
}
%end


// Tanks
%hook TanksWind
-(void)setWind:(float)arg1 {
    if(boolForKey(@"tankNoWind")) {
        return %orig(0.0);
    }
    return %orig;
}
%end



// Darts
%hook DartsScene
-(void)showScore2:(int)arg1 full_score:(int)arg2 multi:(int)arg3 pos:(CGPoint)arg4 send_pos:(CGPoint)arg5 {
    int dartMode = valueForKey(@"dartMode");
    int num;
    if(dartMode == 1) {
        num = 101;
    } else if(dartMode == 2) {
        num = 201;
    } else if(dartMode == 3) {
        num = 301;
    }
    if(boolForKey(@"oneDart")) {
        return %orig(arg1, num, arg3, arg4, arg5);
    } else {
        %orig;
    }
}
%end



// Mini golf
%hook GolfBall
-(BOOL)inside {
    if(boolForKey(@"holeInOne")) {
        return true;
    }
    return %orig;
}
-(BOOL)hole {
    if(boolForKey(@"holeInOne")) {
        return true;
    }
    return %orig;
}
%end



// Cup Pong
%hook BeerView
-(void)killCup:(id)arg1 {
    if(boolForKey(@"cupInOne")) {
        for(int i = 0; i < [[self valueForKey:@"cups"] count]; i++) {
            %orig([self valueForKey:@"cups"][i]);
        } 
    } else {
        %orig;
    }
}
%end

@interface AnagramsBlock : SKNode {
	SKLabelNode* letter;
}
@end

// Anagrams
%hook AnagramsScene

UIButton *anagramsButton;
UIButton *autoAnagramsButton;
-(void)startGame {
    if(boolForKey(@"wordReveal")) {
        anagramsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [anagramsButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 110, 10.0f, 100.0f, 40.f)];
        [anagramsButton setBackgroundColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:.85]];
        [anagramsButton setTitle:@"Reveal Words" forState:UIControlStateNormal];
        [anagramsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [anagramsButton addTarget:self action:@selector(anagramsShow) forControlEvents:UIControlEventTouchUpInside];
        anagramsButton.layer.cornerRadius = 14;

        [self.view addSubview:anagramsButton];
    }

    if(boolForKey(@"autoAnagrams")) {
        autoAnagramsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [autoAnagramsButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 + 5, 10.0f, 100.0f, 40.f)];
        [autoAnagramsButton setBackgroundColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:.85]];
        [autoAnagramsButton setTitle:@"Auto" forState:UIControlStateNormal];
        [autoAnagramsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [autoAnagramsButton addTarget:self action:@selector(fillArr) forControlEvents:UIControlEventTouchUpInside];
        autoAnagramsButton.layer.cornerRadius = 14;

        [self.view addSubview:autoAnagramsButton];

    }
    
    %orig;
}

-(void)toResult {
    if(boolForKey(@"anagrams")) {
        [anagramsButton removeFromSuperview];
    }

    if(boolForKey(@"autoAnagrams")) {
        [autoAnagramsButton removeFromSuperview];
    }
    %orig;
}

%new
-(void)thingAt:(NSArray *)words wordsArr:(NSMutableArray *)wordsArr blocks:(NSMutableArray *)blocks fromIndex:(int)index {
    NSString *word = words[index];
    for(int i = 0; i < [word length]; i++) {
        for(int j = 0; j < [blocks count]; j++) {
            if([[blocks[j] valueForKey:@"letter"] isEqual:[NSString stringWithFormat:@"%c", [word characterAtIndex:i]]]) {
                [wordsArr addObject:blocks[j]];
                break;
            }
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .17 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self enterWord];
        [wordsArr removeAllObjects];
        if (([words count] - 1) == index) {
            return;
        }
        [self thingAt:words wordsArr:wordsArr blocks:blocks fromIndex:index + 1];
     });
}

%new
-(void)fillArr {
    [self revealWords:YES];
    NSArray *words = [[[[self valueForKey:@"wordList"] valueForKey:@"words_string"] stringByReplacingOccurrencesOfString:@"?" withString:@""] componentsSeparatedByString:@"|"];
    if ([words count] == 0) {
        return;
    }
    NSMutableArray* wordsArr = MSHookIvar<NSMutableArray*>(self, "answer");
    NSMutableArray* blocks = MSHookIvar<NSMutableArray*>(self, "blocks");
    [self thingAt:words wordsArr:wordsArr blocks:blocks fromIndex:0];
}
%new
-(void)anagramsShow {
    NSMutableString *wordsString = [[NSMutableString alloc] init];
    [self revealWords:YES];
    NSArray *word = [[[[self valueForKey:@"wordList"] valueForKey:@"words_string"] stringByReplacingOccurrencesOfString:@"?" withString:@""] componentsSeparatedByString:@"|"];
    UIViewController *vc = self.view.window.rootViewController;

    for(int i = 0; i < [word count]; i++) {
        [wordsString appendString:[NSString stringWithFormat:@"%@\n", word[i]]];
    }
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Words"
                        message:[NSString stringWithString:wordsString]
                        preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    [vc presentViewController:alert animated:YES completion:nil];
    NSLog(@"PENIS %@", vc);
}
%end



// Win Spoofer
%hook GameIcon
-(void)setWins:(int)arg1 {
    NSString *_id = [self _id];
    %orig(valueForKey(_id) ?: arg1);
}
%end



// Word Hunt
%hook HuntScene

UIButton *huntButton;
-(void)startGame {
    if(boolForKey(@"anagrams")) {
        huntButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [huntButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 50, 10.0f, 100.0f, 40.f)];
        [huntButton setBackgroundColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:.85]];
        [huntButton setTitle:@"Reveal Words" forState:UIControlStateNormal];
        [huntButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [huntButton addTarget:self action:@selector(huntShow) forControlEvents:UIControlEventTouchUpInside];
        huntButton.layer.cornerRadius = 14;

        [self.view addSubview:huntButton];
    }
    %orig;
}

-(void)toResult {
    if(boolForKey(@"anagrams")) {
        [huntButton removeFromSuperview];
    }
    %orig;
}

%new
-(void)huntShow {
    NSMutableString *wordsString = [[NSMutableString alloc] init];
    [self revealWords:YES];
    NSArray *word = [[[[self valueForKey:@"wordList"] valueForKey:@"words_string"] stringByReplacingOccurrencesOfString:@"?" withString:@""] componentsSeparatedByString:@"|"];
    UIViewController *vc = self.view.window.rootViewController;

    for(int i = 0; i < [word count]; i++) {
        [wordsString appendString:[NSString stringWithFormat:@"%@\n", word[i]]];
    }
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Words"
                        message:[NSString stringWithString:wordsString]
                        preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    [vc presentViewController:alert animated:YES completion:nil];

}
%end


// Sea Battle
%hook SeaScene
-(void)update:(double)arg1 {
    %orig;
    if(boolForKey(@"seeShips")) {
        for(SeaShip* ship in [self valueForKey:@"ships"]) {
            ship.sprite.hidden = false;
        }
    }
    
}
%end

%ctor {
    %init;
}