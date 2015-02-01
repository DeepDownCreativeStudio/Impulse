//
//  ConfigScene.mm
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

@interface ConfigScene : CCLayer 
{
}

//return a scene
+(id) scene;
- (void) onMusicClick:(id)sender;
- (void) onSoundClick:(id)sender;
- (void)onBackClick:(id)sender;
- (void)onTiltClick:(id)sender;
- (void)onResetClick:(id)sender;
@end

