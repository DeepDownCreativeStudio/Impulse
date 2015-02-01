//
//  ConfigScene.m
//  CookieLand
//
//  Created by javier on 28/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ConfigScene.h"
#import "LevelScene.h"
#import "MenuScene.h"
#import "Level.h"
#import "SimpleAudioEngine.h"
#import "GameData.h"
#import "GameDataParser.h"

extern GameData *gameData;
extern NSMutableArray *worldsArray;

@implementation ConfigScene
+(id)scene
{
	
	//NSLog(@"WORLD ID %i", [self retainCount]); 
	
	CCScene *scene =[CCScene node];
	
	ConfigScene *layer = [ConfigScene node];
	[scene addChild: layer z:1];
	
	return scene;
}

-(id) init
{
	if( (self=[super init]) )
	{
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"fondomundo1.png"];
		bg.position = ccp(size.width/2,size.height/2);
        
		[self addChild: bg z:0];
		
		for(int i = 0; i<10;i++)
		{
			CCSprite *estrellita = [CCSprite spriteWithFile:@"skystar1.png"];
			CGSize size = [[CCDirector sharedDirector] winSize];
			estrellita.position = ccp(random() % (int)size.width, random() % (int)size.height);
			estrellita.rotation = CCRANDOM_0_1() * 360;
			estrellita.scale = CCRANDOM_0_1() * 1;
			
			id ojos = [CCScaleBy actionWithDuration:0.5 scale:2.0f];
			id ojos_back = [ojos reverse];
			id hacerojos = [CCRepeatForever actionWithAction: [CCSequence actions: ojos, ojos_back, nil]];
			[estrellita runAction: hacerojos];
			
			[self addChild:estrellita z:0];
			
		}
		
		for(int i = 0; i<40;i++)
		{
			CCSprite *estrellita = [CCSprite spriteWithFile:@"skystar2.png"];
			CGSize size = [[CCDirector sharedDirector] winSize];
			estrellita.position = ccp(random() % (int)size.width, random() % (int)size.height);
			estrellita.rotation = CCRANDOM_0_1() * 360;
			estrellita.scale = CCRANDOM_0_1() * 2 + 0.2;
			
			[self addChild:estrellita z:0];
			
		}

        // SETTINGS
        
        // TILT on/off button
		CCMenuItemToggle *tiltBtn = [CCMenuItemToggle itemWithTarget:self selector:@selector(onTiltClick:) items:
                                     [CCMenuItemImage itemWithNormalImage:@"settings-tilt-off.png" selectedImage:@"settings-tilt-on.png"],
                                     [CCMenuItemImage itemWithNormalImage:@"settings-tilt-on.png" selectedImage:@"settings-tilt-off.png"],
                                     nil];
		tiltBtn.position = ccp(size.width/2, size.height/2+60);
        [tiltBtn setSelectedIndex: gameData.tilt];
        
        
        
        // MUSIC on/off button
        CCMenuItemToggle *musicBtn = [CCMenuItemToggle itemWithTarget:self selector:@selector(onMusicClick:) items:
									  [CCMenuItemImage itemWithNormalImage:@"settings-music-off.png" selectedImage:@"settings-music-on.png"],
                                      [CCMenuItemImage itemWithNormalImage:@"settings-music-on.png" selectedImage:@"settings-music-off.png"],
									  nil];
		musicBtn.position = ccp(size.width/2, size.height/2 + 20);
        [musicBtn setSelectedIndex: gameData.music];
        
		
        // SOUND on/off button
		CCMenuItemToggle *soundBtn = [CCMenuItemToggle itemWithTarget:self selector:@selector(onSoundClick:) items:
									  [CCMenuItemImage itemWithNormalImage:@"settings-sound-off.png" selectedImage:@"settings-sound-on.png"],
                                      [CCMenuItemImage itemWithNormalImage:@"settings-sound-on.png" selectedImage:@"settings-sound-off.png"],
									  nil];
		soundBtn.position = ccp(size.width/2, size.height/2 -20);
        [soundBtn setSelectedIndex: gameData.sound];

        // RESET GAME SETTINGS
        
        CCMenuItemSprite *resetBtn = [CCMenuItemImage itemWithNormalImage:@"settings-reset.png" selectedImage:@"settings-reset-down.png" target:self selector:@selector(onResetClick:)];
        resetBtn.position = ccp(size.width/2, size.height/2 -60);

        
		// Back
		CCMenuItemSprite *backBtn = [CCMenuItemImage itemWithNormalImage:@"boton-back.png" selectedImage:@"boton-over-small.png" target:self selector:@selector(onBackClick:)];
		backBtn.position = ccp(28, 28);
		
		
		CCMenu *menu = [CCMenu menuWithItems:
						musicBtn,
						soundBtn, 
                        tiltBtn,
                        resetBtn,
						backBtn,
					    nil];
		
        menu.position = ccp(0,0);
		[self addChild:menu];
        
        // CONFIG END
    
	}
	return self;
}


- (void)onMusicClick:(id)sender
{
	// [MusicHandler playButtonClick];
	if ([sender selectedIndex] == 1) 
    {
		[SimpleAudioEngine sharedEngine].backgroundMusicVolume = 1;
        NSLog(@"MUSIC ON");
        gameData.music = 1;

	}
	else 
    {
		[SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0;
        NSLog(@"MUSIC OFF");
        gameData.music = 0;
	}
}


- (void)onResetClick:(id)sender
{
	// [MusicHandler playButtonClick];
    NSLog(@"RESETTING DATA");
    
    int i = 0;
    
    for (World* w in worldsArray) 
    {
        int h = 0;
        
        if (i==0)
        {
            w.locked = 0;
        }
        else
        {
            w.locked = 0; // 1
        }
        
        w.completed = 0;
        w.titulo = [NSString stringWithFormat:@"Mundo %d",i+1];
        
        for (Level* l in w.niveles) 
        {
            if (h==0)
            {
                l.locked = 0;
            }
            else
            {
                l.locked = 0; // 1
            }

            l.estrellas = 0;
            l.score = 0;
            
            h++;
        }
        
        i++;
        
    }
    
    // GUARDAR GAMEDATA.SAV
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:@"gamedata.sav"];
    [NSKeyedArchiver archiveRootObject:worldsArray toFile:fullPath];
    
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.6 scene:[MenuScene scene] ]];

}


- (void)onSoundClick:(id)sender
{
	// [MusicHandler playButtonClick];
	if ([sender selectedIndex] == 1) 
    {
		[SimpleAudioEngine sharedEngine].effectsVolume = 1;
        
        NSLog(@"SOUND ON");
        gameData.sound = 1;
	}
	else 
    {	
        [SimpleAudioEngine sharedEngine].effectsVolume = 0;
        gameData.sound = 0;
        NSLog(@"SOUND OFF");

	}
}



- (void)onTiltClick:(id)sender
{

	if ([sender selectedIndex] == 1) 
    {
        gameData.tilt = 1;
        NSLog(@"TILT ON");
	}
	else 
    {	
        gameData.tilt = 0;
        NSLog(@"TILT OFF");
	}
}

- (void)onBackClick:(id)sender
{

	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.6 scene:[MenuScene scene] ]];
    
}


-(void)dealloc

{
	[super dealloc];	
}

@end