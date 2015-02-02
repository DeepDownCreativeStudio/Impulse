//
//  HelloWorldScene.h
//  presentation
//
//  Created by Bogdan Vladu on 15.03.2011.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "LevelHelperLoader.h"

// HelloWorld Layer
@interface MainScene : CCLayer
{
	b2World* world;
    LHSprite* wall1;
    LHSprite* ball;
	GLESDebugDraw *m_debugDraw;
	LevelHelperLoader* lh;
    LHParallaxNode* paralaxNode;
    float pretouch;
    float prefirst;
    bool first;
    CCLabelTTF *numberLabel;
    int levelHigh;
    int levelUsed;
    bool act;
    bool switched;
    LHSprite* switchNext;
}

@property (nonatomic,strong)     NSMutableArray* arrStars;

-(void) retrieveRequiredObjects;
+(id) scene;

@end
