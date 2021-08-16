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

@interface AnagramsScene : GameScene
- (void)revealWords:(BOOL)arg1 ;
@end

@interface AnagramsWordList : SKNode {
	NSString* words_string;
}
@end

@interface GameIcon : UIView {}
-(void)setWins:(int)arg1 ;
-(NSString *)name ;
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

UIButton *anagramsButton;

-(void)startGame {
    if(boolForKey(@"anagrams")) {
        anagramsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [anagramsButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 50, 10.0f, 100.0f, 40.f)];
        [anagramsButton setBackgroundColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:.85]];
        [anagramsButton setTitle:@"Reveal Words" forState:UIControlStateNormal];
        [anagramsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [anagramsButton addTarget:self action:@selector(anagramsShow) forControlEvents:UIControlEventTouchUpInside];
        anagramsButton.layer.cornerRadius = 14;

        [self.view addSubview:anagramsButton];
    }
    %orig;
}

-(void)toResult {
    if(boolForKey(@"anagrams")) {
        [anagramsButton removeFromSuperview];
    }
    %orig;
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

}
%end

// Win Spoofer
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




%ctor {
    %init;
}
