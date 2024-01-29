@import SpriteKit;

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

@interface BeerView : NSObject
@end

@interface DartsScene : NSObject
@property (assign) int score1;
@end

@interface BeerCup : NSObject
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
