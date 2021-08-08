#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import <SpriteKit/SKView.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SCNView.h>
#import <SpriteKit/SKNode.h>

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.donato.gameseagullprefs.plist"

@interface GameScene : SKScene {}
@end

@interface AnagramsScene : GameScene {
	NSDictionary* dict;
    NSString* letters;
}
- (NSString*)alphabetize:(NSString*)letters;
- (SKLabelNode *)noodleNode;
@end

@interface GameIcon : UIView {}
-(void)setWins:(int)arg1 ;
-(NSString *)name ;
@end

@interface BeerView : SCNView {
    NSMutableArray* cups;
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



// Anagrams
%hook AnagramsScene

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];

    NSMutableString *wordsString = [[NSMutableString alloc]init];
    NSString *gameLetters = [self valueForKey:@"letters"];
    NSDictionary *wordDict = [self valueForKey:@"dict"];

    if ([node.name isEqualToString:@"buttonNode"]) {
        UIViewController *vc = self.view.window.rootViewController;
        
        for(NSString* key in wordDict) {
            if([[self alphabetize:gameLetters] containsString:[self alphabetize:wordDict[key]]]) {
                [wordsString appendString:[NSString stringWithFormat:@"%@\n", wordDict[key]]];
            }
        }
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Words"
                           message:[NSString stringWithString:wordsString]
                           preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {}];

        [alert addAction:defaultAction];
        [vc presentViewController:alert animated:YES completion:nil];
    }
    %orig;
}

-(void)startGame {
    if(boolForKey(@"anagrams")) {
        [self addChild: [self noodleNode]];
    }
    %orig;
}

-(void)toResult {
    if(boolForKey(@"anagrams")) {
        [self enumerateChildNodesWithName:@"buttonNode" usingBlock:^(SKNode *node, BOOL *stop) {[node removeFromParent];}];
    }
    %orig;
}

%new
-(NSString*)alphabetize:(NSString*)letters {
    NSMutableArray *charArray = [NSMutableArray arrayWithCapacity:letters.length];
    for (int i = 0; i < letters.length; ++i) {
        NSString *charStr = [letters substringWithRange:NSMakeRange(i, 1)];
        [charArray addObject:charStr];
    }
    return (NSString*)[[charArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] componentsJoinedByString:@""];
}

%new
- (SKLabelNode *)noodleNode
{
    SKLabelNode *buttonNode = [SKLabelNode labelNodeWithText:@"Reveal Words"];
    buttonNode.fontColor = [UIColor colorWithRed:0.40 green:0.31 blue:0.65 alpha:1.0];
    buttonNode.fontName = @"Helvetica";
    buttonNode.fontSize = 20;
    buttonNode.position = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 410.0);
    buttonNode.name = @"buttonNode";//how the node is identified later
    buttonNode.zPosition = 1.0;
    return buttonNode;
}
%end

%hook GameIcon
-(void)setWins:(int)arg1 {
    NSString *name = [self name];
    if([name isEqual:@"8 Ball"]) {
        %orig(valueForKey(@"pool_wins") ?: arg1);
    } else if([name isEqual:@"Sea Battle"]) {
        %orig(valueForKey(@"sea_wins") ?: arg1);
    } else if([name isEqual:@"Basketball"]) {
        %orig(valueForKey(@"basketball_wins") ?: arg1);
    } else if([name isEqual:@"Archery"]) {
        %orig(valueForKey(@"archery_wins") ?: arg1);
    } else if([name isEqual:@"Anagrams"]) {
        %orig(valueForKey(@"anagrams_wins") ?: arg1);
    } else if([name isEqual:@"Word Hunt"]) {
        %orig(valueForKey(@"hunt_wins") ?: arg1);
    } else if([name isEqual:@"Word Bites"]) {
        %orig(valueForKey(@"wordbites_wins") ?: arg1);
    } else if([name isEqual:@"Darts"]) {
        %orig(valueForKey(@"darts_wins") ?: arg1);
    } else if([name isEqual:@"Cup Pong"]) {
        %orig(valueForKey(@"cup_wins") ?: arg1);
    } else if([name isEqual:@"Mini Golf"]) {
        %orig(valueForKey(@"golf_wins") ?: arg1);
    } else if([name isEqual:@"Knockout"]) {
        %orig(valueForKey(@"knock_wins") ?: arg1);
    } else if([name isEqual:@"CRAZY 8"]) {
        %orig(valueForKey(@"crazy_wins") ?: arg1);
    } else if([name isEqual:@"Four in a Row"]) {
        %orig(valueForKey(@"connect_wins") ?: arg1);
    } else if([name isEqual:@"Paintball"]) {
        %orig(valueForKey(@"paint_wins") ?: arg1);
    } else if([name isEqual:@"Shuffleboard"]) {
        %orig(valueForKey(@"shuffle_wins") ?: arg1);
    } else if([name isEqual:@"Tanks"]) {
        %orig(valueForKey(@"tanks_wins") ?: arg1);
    } else if([name isEqual:@"Filler"]) {
        %orig(valueForKey(@"fill_wins") ?: arg1);
    } else if([name isEqual:@"Checkers"]) {
        %orig(valueForKey(@"checkers_wins") ?: arg1);
    } else if([name isEqual:@"Chess"]) {
        %orig(valueForKey(@"chess_wins") ?: arg1);
    } else if([name isEqual:@"Mancala"]) {
        %orig(valueForKey(@"mancala_wins") ?: arg1);
    } else if([name isEqual:@"Dots & Boxes"]) {
        %orig(valueForKey(@"dots_wins") ?: arg1);
    } else if([name isEqual:@"Gomoku"]) {
        %orig(valueForKey(@"renju_wins") ?: arg1);
    } else if([name isEqual:@"Reversi"]) {
        %orig(valueForKey(@"reversi_wins") ?: arg1);
    } else if([name isEqual:@"9 Ball"]) {
        %orig(valueForKey(@"pool2_wins") ?: arg1);
    } else if([name isEqual:@"20 Questions"]) {
        %orig(valueForKey(@"questions_wins") ?: arg1);
    } else if([name isEqual:@"Word Games"]) {
        %orig((valueForKey(@"anagrams_wins") + valueForKey(@"wordbites_wins") + valueForKey(@"hunt_wins")) ?: arg1);
    }
}
%end



%ctor {
    %init;
}