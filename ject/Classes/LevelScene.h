//
//  GameScene.mm
//
//  Copyright GameXtar 2010. All rights reserved.
//
//	info@gamextar.com
//	http://www.gamextar.com - iPhone Development 
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class GameScene;

@interface LevelScene : CCLayer
{
    CGSize size;
	bool pressButtonAllowed;
}
//return a scene
+(id) scene;

@end