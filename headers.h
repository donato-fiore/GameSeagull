#include <SpriteKit/SpriteKit.h>
#include <SpriteKit/SKView.h>
#include <SceneKit/SCNView.h>
#include <Foundation/Foundation.h>

@interface GameScene : SKScene
@end

@interface PoolScene : GameScene {
    SKShapeNode *canvas;
}
@end

@interface PoolScene2 : GameScene {
    SKShapeNode *canvas;
}
@end

@interface PoolScene3 : GameScene {
    SKShapeNode *canvas;
}
@end

@interface BeerView : SCNView {
    NSMutableArray *cups;
}
@end

@interface DartsScene : GameScene {
    NSString *mode;
}
@end

@interface HuntScene : GameScene
-(void)revealWords:(BOOL)arg1 ;
@end

@interface AnagramsScene : GameScene {
    NSMutableArray *blocks;
}
-(void)revealWords:(BOOL)arg1 ;
-(void)enterWord;
-(void)thingAt:(NSArray *)words wordsArr:(NSMutableArray *)wordsArr blocks:(NSMutableArray *)blocks fromIndex:(int)index;
-(void)fillArr;
@end

@interface AnagramsWordList : SKNode {
    NSString *words_string;
}
@end

@interface GameIcon : UIView
-(void)setWins:(int)arg1 ;
-(NSString *)name ;
-(NSString *)_id;
@end

@interface SeaShip : SKNode
@property (retain) SKSpriteNode *sprite; 
@end

@interface SeaScene : GameScene {
    NSMutableArray *ships;
}
@end
