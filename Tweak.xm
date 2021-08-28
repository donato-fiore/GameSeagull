#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import <SceneKit/SceneKit.h>
#import <SpriteKit/SKView.h>
#import <SceneKit/SCNView.h>
#import <SpriteKit/SKNode.h>
#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>

HBPreferences *preferences;

#import <substrate.h>
#include <mach-o/dyld.h>

@interface GameScene : SKScene
@end

@interface PoolScene : GameScene {
    SKShapeNode* canvas;
}
@end

@interface PoolScene2 : GameScene {
    SKShapeNode* canvas;
}
@end

@interface PoolScene3 : GameScene {
    SKShapeNode* canvas;
}
@end

@interface BeerView : SCNView {
    NSMutableArray* cups;
}
@end

@interface DartsScene : GameScene {
    NSString* mode;
}
@end

@interface HuntScene : GameScene
-(void)revealWords:(BOOL)arg1 ;
@end

@interface AnagramsScene : GameScene {
    NSMutableArray* blocks;
}
-(void)revealWords:(BOOL)arg1 ;
-(void)enterWord;
-(void)thingAt:(NSArray *)words wordsArr:(NSMutableArray *)wordsArr blocks:(NSMutableArray *)blocks fromIndex:(int)index;
-(void)fillArr;
@end

@interface AnagramsWordList : SKNode {
	NSString* words_string;
}
@end

@interface GameIcon : UIView
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

@interface PaintTire : SKNode
@property (strong) SKSpriteNode *target;
@property (strong) SKSpriteNode *move;
@property (strong) SKSpriteNode *enemy;
-(void)showEnemy:(long long)arg1 ;
-(void)removeChildAtIndex:(NSUInteger)index;
@end

@interface PaintScene : GameScene {
    PaintTire *enemy;
	PaintTire *target2;
	PaintTire *target;
}
-(void)showEnemy;
-(void)playReplay;
-(void)hit_him;
-(void)meShoot;
// %new
-(void)showEnemyButtonPressed;
@end

BOOL done = YES;


// Archery
%hook ArcheryScene
-(void)setWind:(float)arg1 angle:(float)arg2 {
    if([preferences boolForKey:@"archeryNoWind"]) {
        %orig(0.0, 0.0);
    } else {
        %orig;
    }
}
%end

// Paint Ball
%hook PaintScene
-(void)didMoveToView:(id)arg1 {
    %orig;

    if (![preferences boolForKey:@"showEnemy"]) return;

    UIButton *show = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    // I'll change this later to use constraints and not frames
    [show setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 100, 10.0f, 100.0f, 40.f)];
    [show setBackgroundColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:.85]];
    [show setTitle:@"Show Enemy" forState:UIControlStateNormal];
    [show setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [show addTarget:self action:@selector(showEnemyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    show.layer.cornerRadius = 14;

    [self.view addSubview:show];
}
-(void)playReplay {
    %orig;
    done = NO;
    // hacky way to make sure we don't show the enemy while the replay is playing
    // otherwise you're stuck with one of the images and it doesn't go away
    // the replays are roughly 7 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6.83*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        done = YES;
    });
}
%new
-(void)showEnemyButtonPressed {
    if (!done) return;
    done = NO;
    [MSHookIvar<PaintTire*>(self, "enemy") showEnemy:0];
    SKNode *person = [MSHookIvar<PaintTire*>(self, "enemy") children][0];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        SKAction *goAway = [SKAction moveTo:CGPointMake(0,100) duration:0.33];
        [person runAction:goAway];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.33*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [MSHookIvar<PaintTire*>(self, "enemy") removeChildrenInArray:@[person]];
        });
        done = YES;
    });
}
%end



// 8 ball
// for extended pool lines code, go to %ctor at the end of the file.
%hook PoolBall
-(BOOL)isStripes {
    if([preferences boolForKey:@"showTrajectory"]) {
        return true;
    }
    return %orig;
}
-(BOOL)isSolid {
    if([preferences boolForKey:@"showTrajectory"]) {
        return true;
    }
    return %orig;
}
%end



%hook PoolScene
// 1 is 8 ball 2 is 8ball+ 3 is 9ball
int _currentColorHue = 0;


-(void)didMoveToView:(id)arg1 {
    %orig;
    if([preferences boolForKey:@"noHardMode"]) {
        MSHookIvar<NSString*>(self, "mode") = @"n";
    }
}

-(void)update:(double)arg1 {
    %orig;
    if([preferences boolForKey:@"rgbLine"]) {
        SKShapeNode* canvas = [self valueForKey:@"canvas"];
        _currentColorHue++;
        if (_currentColorHue > 360) {
            _currentColorHue = 0;
        }
        canvas.strokeColor = [[UIColor alloc] initWithHue:_currentColorHue/360.0f saturation:1 brightness:1 alpha:1];
    }
}
%end

%hook PoolScene2
-(void)didMoveToView:(id)arg1 {
    %orig;
    if([preferences boolForKey:@"noHardMode"]) {
        MSHookIvar<NSString*>(self, "mode") = @"n";
    }
}
-(void)update:(double)arg1 {
    %orig;
    if([preferences boolForKey:@"rgbLine"]) {
        SKShapeNode* canvas = [self valueForKey:@"canvas"];
        _currentColorHue++;
        if (_currentColorHue > 360)
        {
            _currentColorHue = 0;
        }
        canvas.strokeColor = [[UIColor alloc] initWithHue:_currentColorHue/360.0f saturation:1 brightness:1 alpha:1];
    }
}
%end

%hook PoolScene3
-(void)didMoveToView:(id)arg1 {
    %orig;
    if([preferences boolForKey:@"noHardMode"]) {
        MSHookIvar<NSString*>(self, "mode") = @"n";
    }
}
-(void)update:(double)arg1 {
    %orig;
    if([preferences boolForKey:@"rgbLine"]) {
        SKShapeNode* canvas = [self valueForKey:@"canvas"];
        _currentColorHue++;
        if (_currentColorHue > 360)
        {
            _currentColorHue = 0;
        }
        canvas.strokeColor = [[UIColor alloc] initWithHue:_currentColorHue/360.0f saturation:1 brightness:1 alpha:1];
    }
}
%end


// Tanks
%hook TanksWind
-(void)setWind:(float)arg1 {
    if([preferences boolForKey:@"tankNoWind"]) {
        return %orig(0.0);
    }
    return %orig;
}
%end



// Darts
%hook DartsScene
-(void)showScore2:(int)arg1 full_score:(int)arg2 multi:(int)arg3 pos:(CGPoint)arg4 send_pos:(CGPoint)arg5 {
    int dartMode = [[self valueForKey:@"mode"] intValue];
    if([preferences boolForKey:@"oneDart"]) {
        return %orig(arg1, dartMode, arg3, arg4, arg5);
    } else {
        %orig;
    }
}
%end



// Mini golf
%hook GolfBall
-(BOOL)inside {
    if([preferences boolForKey:@"holeInOne"]) {
        return true;
    }
    return %orig;
}
-(BOOL)hole {
    if([preferences boolForKey:@"holeInOne"]) {
        return true;
    }
    return %orig;
}
%end



// Cup Pong
%hook BeerView
-(void)killCup:(id)arg1 {
    if([preferences boolForKey:@"cupInOne"]) {
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
    if([preferences boolForKey:@"wordReveal"]) {
        anagramsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [anagramsButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 110, 10.0f, 100.0f, 40.f)];
        [anagramsButton setBackgroundColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:.85]];
        [anagramsButton setTitle:@"Reveal Words" forState:UIControlStateNormal];
        [anagramsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [anagramsButton addTarget:self action:@selector(anagramsShow) forControlEvents:UIControlEventTouchUpInside];
        anagramsButton.layer.cornerRadius = 14;

        [self.view addSubview:anagramsButton];
    }

    if([preferences boolForKey:@"autoAnagrams"]) {
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
    if([preferences boolForKey:@"anagrams"]) {
        [anagramsButton removeFromSuperview];
    }

    if([preferences boolForKey:@"autoAnagrams"]) {
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
}
%end



// Win Spoofer
%hook GameIcon
-(void)setWins:(int)arg1 {
    NSString *_id = [self _id];
    %orig([preferences integerForKey:_id] ?: arg1);
}
%end



// Word Hunt
%hook HuntScene

UIButton *huntButton;
-(void)startGame {
    if([preferences boolForKey:@"wordReveal"]) {
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
    if([preferences boolForKey:@"wordReveal"]) {
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
    if([preferences boolForKey:@"seeShips"]) {
        for(SeaShip* ship in [self valueForKey:@"ships"]) {
            ship.sprite.hidden = false;
        }
    }
}
%end


%ctor {

    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.donato.gameseagullprefs"];

    if([preferences boolForKey:@"extTrajectory"]) {

        uint32_t newBallVal = 0x52A88F48;
        uint32_t newCueVal = 0x1E67D002;

        void *ballAddr1 = (void *)((unsigned char *)_dyld_get_image_header(0) + 0x155684);
        MSHookMemory(ballAddr1, &newBallVal, sizeof(newBallVal));
        void *cueAddr1 = (void *)((unsigned char *)_dyld_get_image_header(0) + 0x155750);
        MSHookMemory(cueAddr1, &newCueVal, sizeof(newCueVal));


        void *ballAddr2 = (void *)((unsigned char *)_dyld_get_image_header(0) + 0xCA6B0);
        MSHookMemory(ballAddr2, &newBallVal, sizeof(newBallVal));
        void *cueAddr2 = (void *)((unsigned char *)_dyld_get_image_header(0) + 0xCA77C);
        MSHookMemory(cueAddr2, &newCueVal, sizeof(newCueVal));

        void *ballAddr3 = (void *)((unsigned char *)_dyld_get_image_header(0) + 0x155684);
        MSHookMemory(ballAddr3, &newBallVal, sizeof(newBallVal));
        void *cueAddr3 = (void *)((unsigned char *)_dyld_get_image_header(0) + 0x645C8);
        MSHookMemory(cueAddr3, &newCueVal, sizeof(newCueVal));
        
    }


    %init;
}