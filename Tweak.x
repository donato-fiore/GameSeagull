@import Foundation;
@import UIKit;

#import "Utils.h"
#import "Headers.h"

bool archeryDisableWind;
bool archeryDisableTimer;
bool extendLines;
bool disableHardmode;
bool alwaysShowLines;
bool rgbLine;
bool alwaysMoveCueBall;
bool oneDartWin;
bool tanksDisableWind;
bool alwaysHoleInOne;
bool oneCupWin;
bool revealWords;
bool autoEnterWords;
bool seeEnemyShips;

%hook ArcheryScene
- (void)setWind:(float)arg1 angle:(float)arg2 {
	if (archeryDisableWind) {
		%orig(0.0, 0.0);
	} else {
		%orig;
	}
}
%end

%hook ArcheryView

- (void)update {
    %orig;
    if (archeryDisableTimer) {
        [self setValue:@(38) forKey:@"shot_time"];
    }
}

%end

%hook PoolBall
- (bool)isStripes {
	return alwaysShowLines ? true : %orig;
}

- (bool)isSolid {
	return alwaysShowLines ? true : %orig;
}
%end

%hook PoolScene
%property (nonatomic) int currentColorHue;
- (void)didMoveToView:(id)arg1 {
	%orig;
	if (disableHardmode) {
		[self setValue:@"n" forKey:@"mode"];
	}
}

- (void)update:(double)arg1 {
	%orig;

	if (rgbLine) {
		SKShapeNode *canvas = [self valueForKey:@"canvas"];
		self.currentColorHue++;
		if (self.currentColorHue > 360) self.currentColorHue = 0;
		[canvas setStrokeColor:[UIColor colorWithHue:self.currentColorHue/360.0 saturation:1.0 brightness:1.0 alpha:1.0]];
	}
	
	if (alwaysMoveCueBall) {
		[self setValue:@(true) forKey:@"move_white"];
	}
}
%end

%hook PoolScene2
%property (nonatomic) int currentColorHue;
- (void)didMoveToView:(id)arg1 {
	%orig;
	if (disableHardmode) {
		[self setValue:@"n" forKey:@"mode"];
	}
}

- (void)update:(double)arg1 {
	%orig;
	if (rgbLine) {
		SKShapeNode *canvas = [self valueForKey:@"canvas"];
		self.currentColorHue++;
		if (self.currentColorHue > 360) self.currentColorHue = 0;
		[canvas setStrokeColor:[UIColor colorWithHue:self.currentColorHue/360.0 saturation:1.0 brightness:1.0 alpha:1.0]];
	}
	
	if (alwaysMoveCueBall) {
		[self setValue:@(true) forKey:@"move_white"];
	}
}
%end

%hook PoolScene3
%property (nonatomic) int currentColorHue;
- (void)didMoveToView:(id)arg1 {
	%orig;
	if (disableHardmode) {
		[self setValue:@"n" forKey:@"mode"];
	}
}

- (void)update:(double)arg1 {
	%orig;
	if (rgbLine) {
		SKShapeNode *canvas = [self valueForKey:@"canvas"];
		self.currentColorHue++;
		if (self.currentColorHue > 360) self.currentColorHue = 0;
		[canvas setStrokeColor:[UIColor colorWithHue:self.currentColorHue/360.0 saturation:1.0 brightness:1.0 alpha:1.0]];
	}
	
	if (alwaysMoveCueBall) {
		[self setValue:@(true) forKey:@"move_white"];
	}
}
%end

%hook TanksWind
- (void)setWind:(float)arg1 {
	if (tanksDisableWind) {
		%orig(0.0);
	} else {
		%orig;
	}
}
%end

%hook DartsScene
- (void)showScore2:(int)arg1 full_score:(int)arg2 multi:(int)arg3 pos:(int)arg4 send_pos:(CGPoint)arg5 {
	if (oneDartWin) {
		%orig(100, self.score1, arg3, arg4, arg5);
	} else {
		%orig;
	}
}
%end

%hook GolfBall
- (bool)inside {
	return alwaysHoleInOne ? true : %orig;
}

- (bool)hole {
	return alwaysHoleInOne ? true : %orig;
}
%end

%hook BeerView
- (void)killCup:(id)arg1 {
	if (oneCupWin) {
		for (BeerCup *cup in [self valueForKey:@"cups"]) {
			%orig(cup);
		}
	} else {
		%orig;
	}
}
%end

%hook SeaScene
- (void)update:(double)arg1 {
	%orig;
	if (seeEnemyShips) {
		for (SeaShip *ship in [self valueForKey:@"ships"]) {
			ship.sprite.hidden = false;
		}
	}
}
%end

%hook AnagramsScene
%property (nonatomic, retain) NSArray *words;
%property (nonatomic, retain) UIButton *anagrams_revealButton;
%property (nonatomic, retain) UIButton *anagrams_autoButton;

- (void)startGame {
	%orig;

	[self revealWords:YES];
	self.words = [[[[self valueForKey:@"wordList"] valueForKey:@"words_string"] stringByReplacingOccurrencesOfString:@"?" withString:@""] componentsSeparatedByString:@"|"];

	if (revealWords) {
		CGFloat offset = autoEnterWords ? 110 : 50;
		self.anagrams_revealButton = makeButton(@"Reveal Words", CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - offset, 10, 100, 40), self, @selector(anagramsShow));
		[self.view addSubview:self.anagrams_revealButton];
		[self.view bringSubviewToFront:self.anagrams_revealButton];
	}
	
	if (autoEnterWords) {
		CGFloat offset = revealWords ? -10 : 50;
		self.anagrams_autoButton = makeButton(@"Auto", CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - offset, 10, 100, 40), self, @selector(fillArr));
		[self.view addSubview:self.anagrams_autoButton];
		[self.view bringSubviewToFront:self.anagrams_autoButton];
	}
	
}

- (void)toResult {
	%orig;

	[self.anagrams_revealButton removeFromSuperview];
	[self.anagrams_autoButton removeFromSuperview];
}

%new
- (void)thingAt:(NSArray *)words wordsArr:(NSMutableArray *)wordsArr blocks:(NSMutableArray *)blocks fromIndex:(int)index {
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
			[self winGame];
			return;
		}
		
		[self thingAt:words wordsArr:wordsArr blocks:blocks fromIndex:index + 1];
	});
}

%new
- (void)fillArr {
	[self revealWords:YES];
	if ([self.words count] == 0) return;
	NSMutableArray *wordsArr = [self valueForKey:@"answer"];
	NSMutableArray *blocks = [self valueForKey:@"blocks"];

	[self thingAt:self.words wordsArr:wordsArr blocks:blocks fromIndex:0];
}

%new
- (void)anagramsShow {
	alert(self.view, @"Words", [self.words componentsJoinedByString:@"\n"]);
}
%end

%hook HuntScene
%property (nonatomic, retain) UIButton *hunt_revealWordsButton;
- (void)startGame {
	%orig;

	if (revealWords) {
		CGFloat pos = ((SKSpriteNode*)[self valueForKey:@"score_bg"]).size.height + self.view.safeAreaInsets.top;
		self.hunt_revealWordsButton = makeButton(@"Reveal Words", CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 50, pos, 100, 40), self, @selector(hunt_revealWords));
		[self.view addSubview:self.hunt_revealWordsButton];
		[self.view bringSubviewToFront:self.hunt_revealWordsButton];
	}
}

- (void)toResult {
	%orig;
	[self.hunt_revealWordsButton removeFromSuperview];
}

%new
- (void)hunt_revealWords {
	[self revealWords:YES];
	NSMutableArray *words = [[[[self valueForKey:@"wordList"] valueForKey:@"words_string"] stringByReplacingOccurrencesOfString:@"?" withString:@""] componentsSeparatedByString:@"|"].mutableCopy;
	for (NSString *word in words) {
		if (![self checkWord:word flag:0]) {
			[words removeObject:word];
		}
	}

	alert(self.view, @"Words", [words componentsJoinedByString:@"\n"]);
}
%end

%hook GameIcon
- (void)setWins:(int)arg1 {
	NSString *wins = getPreferences()[self._id];
	%orig(wins.length ? wins.intValue : arg1);
}
%end

%ctor {
	archeryDisableWind = boolForKey(@"kArcheryDisableWind");
	archeryDisableTimer = boolForKey(@"kDisableTimer");
	extendLines = boolForKey(@"kExtendLines");
	disableHardmode = boolForKey(@"kDisableHardMode");
	alwaysShowLines = boolForKey(@"kAlwaysShowLines");
	rgbLine = boolForKey(@"kRGBLine");
	alwaysMoveCueBall = boolForKey(@"kAlwaysMoveCueBall");
	oneDartWin = boolForKey(@"kOneDart");
	tanksDisableWind = boolForKey(@"kTanksDisableWind");
	alwaysHoleInOne = boolForKey(@"kHoleInOne");
	oneCupWin = boolForKey(@"kOneCup");
	revealWords = boolForKey(@"kRevealWords");
	autoEnterWords = boolForKey(@"kAutoEnterWords");
	seeEnemyShips = boolForKey(@"kSeeEnemies");

	if (extendLines) {
		uint32_t patch = 0x52a9cdc8;
		uint8_t needle[4] = { 0x08, 0x4e, 0xa8, 0x52 };
		for (NSString *class in @[@"PoolScene", @"PoolScene2", @"PoolScene3"]) {
			uint64_t method = (uint64_t)[NSClassFromString(class) instanceMethodForSelector:@selector(mMove)];
			uint64_t result = bh_memmem((const uint8_t*)method, 0x1000, needle, 4);

			HookMemory(NSClassFromString(class), @selector(mMove), (result - method), patch);
		}
	}
	
	%init;
}
