#include <Cephei/HBPreferences.h>
#include <mach-o/dyld.h>
#include "headers.h"

HBPreferences *preferences;
static BOOL archeryNoWind;
static BOOL showTrajectory;
static BOOL noHardMode;
static BOOL rgbLine;
static BOOL tankNoWind;
static BOOL oneDart;
static BOOL holeInOne;
static BOOL oneCup;
static BOOL autoAnagrams;
static BOOL wordReveal;
static BOOL seeShips;
static BOOL extTrajectory;
static BOOL moveCue;
static BOOL archeryClose;

// Archery
%hook ArcheryScene
-(void)setWind:(float)arg1 angle:(float)arg2 {
    if(archeryNoWind) {
        %orig(0.0, 0.0);
    } else {
        %orig;
    }
}
%end

%hook ArcheryView
-(void)setTargetDistance:(int)arg1 {
    if(archeryClose) {
        %orig(50);
    } else {
        %orig;
    }
}
%end

// 8 ball
// for extended pool lines code, go to %ctor at the end of the file.
%hook PoolBall
-(BOOL)isStripes {
    if(showTrajectory) {
        return true;
    }
    return %orig;
}
-(BOOL)isSolid {
    if(showTrajectory) {
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
    if(noHardMode) {
        MSHookIvar<NSString *>(self, "mode") = @"n";
    }
}

-(void)update:(double)arg1 {
    %orig;
    if(rgbLine) {
        SKShapeNode* canvas = [self valueForKey:@"canvas"];
        _currentColorHue++;
        if (_currentColorHue > 360) {
            _currentColorHue = 0;
        }
        canvas.strokeColor = [[UIColor alloc] initWithHue:_currentColorHue/360.0f saturation:1 brightness:1 alpha:1];
    }
    if(moveCue) {
        MSHookIvar<BOOL>(self, "move_white") = true;
    }
}
%end

%hook PoolScene2
-(void)didMoveToView:(id)arg1 {
    %orig;
    if(noHardMode) {
        MSHookIvar<NSString*>(self, "mode") = @"n";
    }
}
-(void)update:(double)arg1 {
    %orig;
    if(rgbLine) {
        SKShapeNode* canvas = [self valueForKey:@"canvas"];
        _currentColorHue++;
        if (_currentColorHue > 360)
        {
            _currentColorHue = 0;
        }
        canvas.strokeColor = [[UIColor alloc] initWithHue:_currentColorHue/360.0f saturation:1 brightness:1 alpha:1];
    }
    if(moveCue) {
        MSHookIvar<BOOL>(self, "move_white") = true;
    }
}
%end

%hook PoolScene3
-(void)didMoveToView:(id)arg1 {
    %orig;
    if(noHardMode) {
        MSHookIvar<NSString*>(self, "mode") = @"n";
    }
}
-(void)update:(double)arg1 {
    %orig;
    if(rgbLine) {
        SKShapeNode* canvas = [self valueForKey:@"canvas"];
        _currentColorHue++;
        if (_currentColorHue > 360)
        {
            _currentColorHue = 0;
        }
        canvas.strokeColor = [[UIColor alloc] initWithHue:_currentColorHue/360.0f saturation:1 brightness:1 alpha:1];
    }
    if(moveCue) {
        MSHookIvar<BOOL>(self, "move_white") = true;
    }
}
%end


// Tanks
%hook TanksWind
-(void)setWind:(float)arg1 {
    if(tankNoWind) {
        return %orig(0.0);
    }
    return %orig;
}
%end



// Darts
%hook DartsScene
-(void)showScore2:(int)arg1 full_score:(int)arg2 multi:(int)arg3 pos:(CGPoint)arg4 send_pos:(CGPoint)arg5 {
    int dartMode = [[self valueForKey:@"mode"] intValue];
    if(oneDart) {
        return %orig(arg1, dartMode, arg3, arg4, arg5);
    } else {
        %orig;
    }
}
%end



// Mini golf
%hook GolfBall
-(BOOL)inside {
    if(holeInOne) {
        return true;
    }
    return %orig;
}
-(BOOL)hole {
    if(holeInOne) {
        return true;
    }
    return %orig;
}
%end



// Cup Pong
%hook BeerView
-(void)killCup:(id)arg1 {
    if(oneCup) {
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
UIButton *autoAnagramsButton;
-(void)startGame {
    if(wordReveal) {
        anagramsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [anagramsButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 110, 10.0f, 100.0f, 40.f)];
        [anagramsButton setBackgroundColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:.85]];
        [anagramsButton setTitle:@"Reveal Words" forState:UIControlStateNormal];
        [anagramsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [anagramsButton addTarget:self action:@selector(anagramsShow) forControlEvents:UIControlEventTouchUpInside];
        anagramsButton.layer.cornerRadius = 14;

        [self.view addSubview:anagramsButton];
    }

    if(autoAnagrams) {
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
    if(wordReveal) {
        [anagramsButton removeFromSuperview];
    }

    if(autoAnagrams) {
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
    //%orig;
    NSString* _id = [self _id];
    int wins = [preferences integerForKey:_id];
    %orig(wins ?: arg1);
    //%orig(valueForKey(_id) ?: arg1);
}
%end



// Word Hunt
%hook HuntScene

UIButton *huntButton;
-(void)startGame {
    if(wordReveal) {
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
    if(wordReveal) {
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
    if(seeShips) {
        for(SeaShip* ship in [self valueForKey:@"ships"]) {
            ship.sprite.hidden = false;
        }
    }
}
%end

%ctor {
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.fiore.gameseagullprefs"];
    [preferences registerBool:&archeryNoWind default:NO forKey:@"archeryNoWind"];
    [preferences registerBool:&autoAnagrams default:NO forKey:@"autoAnagrams"];
    [preferences registerBool:&extTrajectory default:NO forKey:@"extTrajectory"];
    [preferences registerBool:&holeInOne default:NO forKey:@"holeInOne"];
    [preferences registerBool:&noHardMode default:NO forKey:@"noHardMode"];
    [preferences registerBool:&oneCup default:NO forKey:@"oneCup"];
    [preferences registerBool:&oneDart default:NO forKey:@"oneDart"];
    [preferences registerBool:&rgbLine default:NO forKey:@"rgbLine"];
    [preferences registerBool:&seeShips default:NO forKey:@"seeShips"];
    [preferences registerBool:&showTrajectory default:NO forKey:@"showTrajectory"];
    [preferences registerBool:&tankNoWind default:NO forKey:@"tankNoWind"];
    [preferences registerBool:&wordReveal default:NO forKey:@"wordReveal"];
    [preferences registerBool:&moveCue default:NO forKey:@"moveCue"];
    [preferences registerBool:&archeryClose default:NO forKey:@"archeryClose"];

    if(extTrajectory) {

        uint32_t newBallVal = 0x52A88F48, newCueVal = 0x1E67D002;
        void *ballAddr, *cueAddr;

        ballAddr = (void *)((unsigned char *)_dyld_get_image_header(0) + 0x155684);
        MSHookMemory(ballAddr, &newBallVal, sizeof(newBallVal));
        cueAddr = (void *)((unsigned char *)_dyld_get_image_header(0) + 0x155750);
        MSHookMemory(cueAddr, &newCueVal, sizeof(newCueVal));

        ballAddr = (void *)((unsigned char *)_dyld_get_image_header(0) + 0x0CA6B0);
        MSHookMemory(ballAddr, &newBallVal, sizeof(newBallVal));
        cueAddr = (void *)((unsigned char *)_dyld_get_image_header(0) + 0x0CA77C);
        MSHookMemory(cueAddr, &newCueVal, sizeof(newCueVal));

        ballAddr = (void *)((unsigned char *)_dyld_get_image_header(0) + 0x0644FC);
        MSHookMemory(ballAddr, &newBallVal, sizeof(newBallVal));
        cueAddr = (void *)((unsigned char *)_dyld_get_image_header(0) + 0x0645C8);
        MSHookMemory(cueAddr, &newCueVal, sizeof(newCueVal));
        
    }
    %init;
}