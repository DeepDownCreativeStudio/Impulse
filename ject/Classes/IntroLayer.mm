//
//  IntroLayer.m
//  Rotate & Roll 2
//
//  Created by Javier on 01/10/12.
//  Copyright Javier 2012. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "GameScene.h"
#import "mainScene.h"
#import "MenuScene.h"
#import "SimpleAudioEngine.h"
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//
-(id) init
{
	if( (self=[super init])) {
		
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background;
		
        
        
        if( CC_CONTENT_SCALE_FACTOR() == 2 )
        {
            if (IS_IPHONE_5)
            {
                background = [CCSprite spriteWithFile:@"Default-568h@2x.png"];
            }
            else
            {
                background = [CCSprite spriteWithFile:@"Default@2x.png"];
            }
		}
        else
        {
            background = [CCSprite spriteWithFile:@"Default.png"];
        }
    
        background.rotation = -90;
	
		background.position = ccp(size.width/2, size.height/2);
		
		// add the label as a child to this Layer
		[self addChild: background];
        
        
        CCParticleSystem* particleSystem;
        particleSystem = [CCParticleSystemQuad particleWithFile:@"tuck.plist"];
        particleSystem.positionType = kCCPositionTypeGrouped;
        particleSystem.position = ccp(-200,-200);
        
	}
	
	return self;
}

-(void) onEnter
{
	[super onEnter];
    [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 1.0f;
   [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background.mp3"];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.5 scene:[mainScene scene]]];
}
@end
