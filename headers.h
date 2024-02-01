@import SpriteKit;
@import SceneKit;

@interface ArcheryView : NSObject
@end

@interface PoolScene : SKScene
@property (nonatomic) int currentColorHue;
@end

@interface PoolScene2 : NSObject
@property (nonatomic) int currentColorHue;
@end

@interface PoolScene3 : NSObject
@property (nonatomic) int currentColorHue;
@end

@interface BeerView : SCNView
@property (assign) float F_x;
@property (assign) float F_z;
-(void)touchDownAtPoint:(CGPoint)arg1;
-(void)touchMovedToPoint:(CGPoint)arg1;
-(void)touchUpAtPoint:(CGPoint)arg1;
- (void)shootRandomCup;
@end

@interface BeerScene : SKScene
@property (retain) BeerView *scene3d; 
@end

@interface BeerCup : NSObject
@property (assign) SCNVector3 pos;
@property (assign) BOOL live;
@end

@interface BeerBall : NSObject
@property (nonatomic, retain) SCNNode *ball;
@end

@interface DartsScene : SKScene
@property (nonatomic, assign) bool aimbotEnabled;
@property (nonatomic, retain) UIButton *menuButton;
@property (nonatomic, assign) int multiplier;
@property (nonatomic, assign) int number;
@property (nonatomic, retain) UIView *aimbotStatusView;
@property (assign) int score1;
- (void)updateAimbotStatusView;
- (void)createMainMenu;
@end

@interface SeaScene : NSObject
@end

@interface SeaShip : SKScene
@property (nonatomic) SKSpriteNode *sprite; 
@end

@interface AnagramsScene : SKScene
@property (nonatomic, retain) NSArray *words;
@property (nonatomic, retain) UIButton *anagrams_revealButton;
@property (nonatomic, retain) UIButton *anagrams_autoButton;
- (void)enterWord;
- (void)thingAt:(NSArray *)words wordsArr:(NSMutableArray *)wordsArr blocks:(NSMutableArray *)blocks fromIndex:(int)index;
- (void)revealWords:(bool)arg1;
- (void)winGame;
@end

@interface HuntScene : SKScene {
    SKSpriteNode* score_bg;
}
@property (nonatomic, retain) NSArray *words;
@property (nonatomic, retain) UIButton *hunt_revealWordsButton;
- (void)revealWords:(BOOL)reveal;
- (bool)checkWord:(NSString *)word flag:(bool)flag;
@end

@interface GameIcon : NSObject
@property (nonatomic, retain) NSString *_id;
@end
