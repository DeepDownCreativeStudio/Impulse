//
//  FondoLayer.mm
//
//  Copyright GameXtar 2010. All rights reserved.
//
//	info@gamextar.com
//	http://www.gamextar.com - iPhone Development 
//
//

#import "cocos2d.h"
#import "GameScene.h"

@class GameScene;

@interface FondoLayer : CCLayer 
{
	CCSprite *fondo2;
}
-(void) setFondo: (NSString*) fondo;
-(void) setFondoRotation:(float) rotationer;
@end
