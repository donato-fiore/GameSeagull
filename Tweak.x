@import Foundation;
@import UIKit;

#import "Utils.h"
#import "Headers.h"

bool archeryDisableWind;
bool archeryDisableTimer;
bool archery50ft;
bool extendLines;
bool disableHardmode;
bool alwaysShowLines;
bool rgbLine;
bool alwaysMoveCueBall;
bool oneDartWin;
bool dartAimbot;
bool tanksDisableWind;
bool alwaysHoleInOne;
bool oneCupWin;
bool autoCupPong;
bool revealWords;
bool autoEnterWords;
bool seeEnemyShips;

DartsScene *sharedInstance;

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

- (void)setTargetDistance:(int)arg1 {
	if (archery50ft) arg1 = 50;
	%orig;
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
%property (nonatomic, assign) bool aimbotEnabled;
%property (nonatomic, retain) UIButton *menuButton;
%property (nonatomic, assign) int multiplier;
%property (nonatomic, assign) int number;

%property (nonatomic, retain) UIView *aimbotStatusView;

- (void)update:(double)arg1 {
	%orig;

	if (!self.menuButton.hidden) return;

	if ([[self valueForKey:@"state"] intValue] == 1) {
		self.menuButton.hidden = false;
		self.aimbotStatusView.hidden = false;
	} else {
		self.menuButton.hidden = true;
		self.aimbotStatusView.hidden = true;
	}
}

- (void)didMoveToView:(id)arg1 {
	%orig;

	if (!dartAimbot) return;

	sharedInstance = self;
	self.aimbotEnabled = false;
	self.menuButton = makeButton(@"Aimbot", CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 50, 10, 100, 40), nil, nil);
	[self createMainMenu];
	self.menuButton.showsMenuAsPrimaryAction = true;
	[self.view addSubview:self.menuButton];
	[self.view bringSubviewToFront:self.menuButton];

	self.aimbotStatusView = [[UIView alloc] init];
	[self.view addSubview:self.aimbotStatusView];
	[self updateAimbotStatusView];
	self.aimbotStatusView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view bringSubviewToFront:self.aimbotStatusView];

	[NSLayoutConstraint activateConstraints:@[
		[self.aimbotStatusView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10],
		[self.aimbotStatusView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-110],
		[self.aimbotStatusView.widthAnchor constraintEqualToConstant:100],
		[self.aimbotStatusView.heightAnchor constraintEqualToConstant:100]
	]];

	self.menuButton.hidden = true;
}

%new
- (void)createMainMenu {
	NSMutableArray *actions = [[NSMutableArray alloc] init];
	NSMutableArray *multipliers = [[NSMutableArray alloc] init];
	NSMutableArray *numbers = [[NSMutableArray alloc] init];

	UIAction *action = [UIAction actionWithTitle:@"Enabled" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
		self.aimbotEnabled = !self.aimbotEnabled;
		if (self.aimbotEnabled) {
			if (self.multiplier == 0) self.multiplier = 1;
			if (self.number == 0) self.number = 1;
		} else {
			self.multiplier = 0;
			self.number = 0;
		}

		[self createMainMenu];
	}];
	action.state = self.aimbotEnabled ? UIMenuElementStateOn : UIMenuElementStateOff;

	[actions addObject:action];

	for (int i = 1; i <= 3; i++) {
		UIAction *action = [UIAction actionWithTitle:[NSString stringWithFormat:@"%dx", i] image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
			if (self.number == 0) self.number = 1;
			self.multiplier = i;

			if (self.multiplier > 1 && self.number > 20) {
				self.number = 20;
			}

			[self createMainMenu];
		}];
		action.state = self.multiplier == i ? UIMenuElementStateOn : UIMenuElementStateOff;
		[multipliers addObject:action];
	}

	for (UIAction *action in multipliers) {
		if (!self.aimbotEnabled) {
			action.attributes = UIMenuElementAttributesDisabled;
		}
	}

	[actions addObject:[UIMenu menuWithTitle:@"Multiplier" children:multipliers]];

	for (int i = 1; i <= 20; i++) {
		UIAction *action = [UIAction actionWithTitle:[NSString stringWithFormat:@"%d", i] image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
			if (self.multiplier == 0) self.multiplier = 1;
			self.number = i;

			[self createMainMenu];
		}];
		action.state = self.number == i ? UIMenuElementStateOn : UIMenuElementStateOff;
		[numbers addObject:action];
	}

	UIAction *action25 = [UIAction actionWithTitle:@"25" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
		self.multiplier = 1;
		self.number = 25;

		[self createMainMenu];
	}];
	action25.state = self.number == 25 ? UIMenuElementStateOn : UIMenuElementStateOff;
	[numbers addObject:action25];

	UIAction *action50 = [UIAction actionWithTitle:@"50" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
		self.multiplier = 1;
		self.number = 50;

		[self createMainMenu];
	}];
	action50.state = self.number == 25 ? UIMenuElementStateOn : UIMenuElementStateOff;
	[numbers addObject:action50];

	for (UIAction *action in numbers) {
		if (!self.aimbotEnabled) {
			action.attributes = UIMenuElementAttributesDisabled;
		}

		if ([action.title isEqualToString:@"25"] || [action.title isEqualToString:@"50"]) {
			if (self.multiplier != 1) {
				action.attributes = UIMenuElementAttributesDisabled;
			}
		}
	}

	[actions addObject:[UIMenu menuWithTitle:@"Number" children:numbers]];


	UIMenu* menu = [UIMenu menuWithTitle:@"Aimbot" children:actions];
	self.menuButton.menu = menu;

	[self updateAimbotStatusView];
}

%new
- (void)updateAimbotStatusView {
	if (!self.aimbotStatusView) return;
	[[self.aimbotStatusView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

	UILabel *activeLabel = [[UILabel alloc] init];
	activeLabel.text = self.aimbotEnabled ? @"Enabled" : @"Disabled";
	activeLabel.textAlignment = NSTextAlignmentCenter;
	activeLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
	activeLabel.frame = CGRectMake(0, 0, 0, 0);
	[activeLabel sizeToFit];
	activeLabel.translatesAutoresizingMaskIntoConstraints = NO;

	activeLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
	activeLabel.layer.shadowOffset = CGSizeMake(1.5, 1.5);
	activeLabel.layer.shadowRadius = 4;
	activeLabel.layer.shadowOpacity = 1;

	[self.aimbotStatusView addSubview:activeLabel];

	[NSLayoutConstraint activateConstraints:@[
		[activeLabel.centerXAnchor constraintEqualToAnchor:self.aimbotStatusView.centerXAnchor],
		[activeLabel.topAnchor constraintEqualToAnchor:self.aimbotStatusView.topAnchor constant:5]
	]];

	if (!self.aimbotEnabled) return;

	UILabel *multiplierLabel = [[UILabel alloc] init];
	multiplierLabel.text = [NSString stringWithFormat:@"Multiplier: %dx", self.multiplier];
	multiplierLabel.textAlignment = NSTextAlignmentCenter;
	multiplierLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
	[multiplierLabel sizeToFit];
	multiplierLabel.translatesAutoresizingMaskIntoConstraints = NO;

	multiplierLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
	multiplierLabel.layer.shadowOffset = CGSizeMake(1.5, 1.5);
	multiplierLabel.layer.shadowRadius = 4;
	multiplierLabel.layer.shadowOpacity = 1;

	[self.aimbotStatusView addSubview:multiplierLabel];

	[NSLayoutConstraint activateConstraints:@[
		[multiplierLabel.centerXAnchor constraintEqualToAnchor:self.aimbotStatusView.centerXAnchor],
		[multiplierLabel.topAnchor constraintEqualToAnchor:activeLabel.bottomAnchor constant:5]
	]];

	UILabel *numberLabel = [[UILabel alloc] init];
	numberLabel.text = [NSString stringWithFormat:@"Number: %d", self.number];
	numberLabel.textAlignment = NSTextAlignmentCenter;
	numberLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
	numberLabel.translatesAutoresizingMaskIntoConstraints = NO;

	numberLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
	numberLabel.layer.shadowOffset = CGSizeMake(1.5, 1.5);
	numberLabel.layer.shadowRadius = 4;
	numberLabel.layer.shadowOpacity = 1;

	[numberLabel sizeToFit];
	[self.aimbotStatusView addSubview:numberLabel];

	[NSLayoutConstraint activateConstraints:@[
		[numberLabel.centerXAnchor constraintEqualToAnchor:self.aimbotStatusView.centerXAnchor],
		[numberLabel.topAnchor constraintEqualToAnchor:multiplierLabel.bottomAnchor constant:5]
	]];
}

- (void)showScore2:(int)arg1 full_score:(int)arg2 multi:(int)arg3 pos:(int)arg4 send_pos:(CGPoint)arg5 {
	if (oneDartWin) {
		%orig(100, self.score1, arg3, arg4, arg5);
	} else {
		%orig;
	}
}
%end

%hook DartsDart

- (void)setTarget:(SCNVector3)arg1 {
	if (sharedInstance.aimbotEnabled) {
		%orig(getAimbotPos(sharedInstance.multiplier, sharedInstance.number));
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

%hook BeerScene

- (void)didMoveToView:(id)arg1 {
	%orig;

	if (!autoCupPong) return;

	UIButton *button = makeButton(@"Shoot", CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 50, 10, 100, 40), self.scene3d, @selector(shootRandomCup));
	[self.view addSubview:button];
	[self.view bringSubviewToFront:button];
}

%end

%hook BeerView
%property (assign) float F_x;
%property (assign) float F_z;

- (void)killCup:(id)arg1 {
	if (oneCupWin) {
		for (BeerCup *cup in [self valueForKey:@"cups"]) {
			%orig(cup);
		}
	} else {
		%orig;
	}
}

%new
- (void)shootRandomCup {
	NSArray *cups = [self valueForKey:@"cups"];
	BeerCup *cup = nil;

	SCNNode *ball = [[self valueForKey:@"game_ball"] ball];

	if ([cups count] < 1 || !ball) return;

	SCNVector3 realBallPos = [self projectPoint:ball.position];
	CGPoint start = CGPointMake(realBallPos.x, self.frame.size.height - realBallPos.y);
	[self touchDownAtPoint:start];
	
	cup = cups[arc4random_uniform(cups.count)];
	
	self.F_x = (cup.pos.x - ball.position.x) * 1.3;					// yoinked from birdpoop
	self.F_z = -1.2 / (cup.pos.z - ball.position.z + 0.25) - 2.91;	// this too

	__block void (*orig_applyForce)(id self, SEL _cmd, SCNVector3 direction, BOOL impulse);
	MSHookMessageEx(
		[ball.physicsBody class],
		@selector(applyForce:impulse:),
		imp_implementationWithBlock(^(id selfRef, SCNVector3 direction, BOOL impulse) {
			if (self.F_x) direction.x = self.F_x;
			if (self.F_z) direction.z = self.F_z;

			orig_applyForce(selfRef, @selector(applyForce:impulse:), direction, impulse);
		}),
		(IMP *)&orig_applyForce
	);

	CGPoint dest = CGPointMake(realBallPos.x, self.frame.size.height);

	[self touchMovedToPoint:dest];
	[self touchUpAtPoint:dest];

	self.F_x = 0;
	self.F_z = 0;
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
	archery50ft = boolForKey(@"kArchery50ft");
	extendLines = boolForKey(@"kExtendLines");
	disableHardmode = boolForKey(@"kDisableHardMode");
	alwaysShowLines = boolForKey(@"kAlwaysShowLines");
	rgbLine = boolForKey(@"kRGBLine");
	alwaysMoveCueBall = boolForKey(@"kAlwaysMoveCueBall");
	oneDartWin = boolForKey(@"kOneDart");
	dartAimbot = boolForKey(@"kDartsAimbot");
	tanksDisableWind = boolForKey(@"kTanksDisableWind");
	alwaysHoleInOne = boolForKey(@"kHoleInOne");
	oneCupWin = boolForKey(@"kOneCup");
	autoCupPong = boolForKey(@"kAutoCupPong");
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
