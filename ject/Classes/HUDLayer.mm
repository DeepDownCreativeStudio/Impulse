//
//  GameScene.mm
//
//  Copyright GameXtar 2010. All rights reserved.
//
//	info@gamextar.com
//	http://www.gamextar.com - iPhone Development
//
//

#import "HUDLayer.h"
#import "GameData.h"

extern int Nivel;
extern BOOL isPaused;
extern CCSprite *agujaSprite;
extern GameData *gameData;
extern int RecordScore;
extern int LevelScore;
extern int NewScore;

@implementation GameHUD
@synthesize pauseButton;

// Shared HUD instance
static GameHUD *sharedManager_ = nil;

+ (GameHUD *)sharedManager
{
	if (!sharedManager_)
	{
		sharedManager_ = [[super allocWithZone:nil] init];
	}
	return sharedManager_;
}

+ (id)allocWithZone:(NSZone *)zone
{
	return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (NSUInteger)retainCount
{
	return NSUIntegerMax; //denotes an object that cannot be released
}

- (void)release
{
	//do nothing
}

- (id)autorelease
{
	return self;
}

- (id)init
{
	if( (self = [super init]) )
	{
		
        NSLog(@"HUD %i", [self retainCount]);
		
        size = [[CCDirector sharedDirector] winSize];

        self.touchEnabled = YES;
        
		brujulaSprite = [CCSprite spriteWithFile:@"brujula.png"];
		brujulaSprite.opacity = 230;
        brujulaSprite.position = ccp(25, 294);
		[self addChild:brujulaSprite]; 
        
		
		agujaSprite = [CCSprite spriteWithFile:@"aguja.png"];
        agujaSprite.opacity = 200;

		agujaSprite.position = ccp(24, 24);
		[brujulaSprite addChild:agujaSprite]; 
		
		placa = [CCSprite spriteWithFile:@"LevelFinished22.png"];
        placa.visible = FALSE;	
		placa.opacity = 220;
        placa.position = ccp(size.width/2, size.height/2);
		[self addChild:placa];
        
		pauseButton = [CCSprite spriteWithFile:@"boton-pausa.png"];
		pauseButton.opacity = 230;
        pauseButton.position=ccp(size.width - 26, 294);
		[self addChild:pauseButton z:10];
		
        
        levelLabel = [CCLabelBMFont labelWithString:@""
                                           fntFile:@"font-hud.fnt"];
        
        [levelLabel setAnchorPoint:ccp(0.0f, 0.5f)];
        
        levelLabel.scale = 1.2f;
        
		scoreLabel = [CCLabelBMFont labelWithString:@""
                                            fntFile:@"font-hud.fnt"];
        
        [scoreLabel setAnchorPoint:ccp(0.0f, 0.5f)];
							 
		[self addChild:levelLabel];
		[self addChild:scoreLabel];
        
        [levelLabel setPosition:ccp(brujulaSprite.position.x + 26, 305)];
        [scoreLabel setPosition:ccp(brujulaSprite.position.x + 26, 285)];

		[self showHUD];
				
	}
	return self;
}

- (void)dealloc
{
	[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}

-(void) setGame: (GameScene*) newGame
{
	game = newGame;
}


- (void) showHUD
{
    // pauseButton.position=ccp(976, 720);

    pauseButtonRect = CGRectMake(pauseButton.position.x-pauseButton.contentSize.width/2, pauseButton.position.y-pauseButton.contentSize.height/2, 64, 64);

    levelLabel.visible = TRUE;
    scoreLabel.visible = TRUE;
    pauseButton.visible = TRUE;
    brujulaSprite.visible = TRUE;
	
}

- (void) hideHUD
{

	pauseButtonRect = CGRectMake(0, 0, 0, 0);
    
    levelLabel.visible = FALSE;
    scoreLabel.visible = FALSE;
    pauseButton.visible = FALSE;
    brujulaSprite.visible = FALSE;
    
}

- (void) setLevelComplete: (int) value
{
  if(value > 500) value = 500;
  int percentage = value/45;
  // we crack it up to 11 baby.
  if(percentage == currentPercentage)
  {
    return;
  }
}

- (void) updateGameWithNewMenuRect
{
  //Beware, the positioning of the rects means at CGRect Union may not give expected results
  // the != 0 should fix this

 CGRect newRect = CGRectMake(size.width, size.height, 0, 0);
  if (pauseButtonRect.size.width != 0)
  {
    newRect = CGRectUnion(newRect, pauseButtonRect);
  }
	
}

- (void) setLevelLabel:(NSString * ) value
{
	//NSLog(@"setLevelLabel %@", value);
     NSLog(@"scoring5");
	//[levelLabel setString:value];
}


- (void) updateScore:(NSString * ) value
{

    /*
    oldScore = LevelScore - NewScore;
    NSLog(@"CURRENT: %i  NEW: %i", oldScore, LevelScore);
    [self schedule: @selector(animateScore:) interval:0.02];
     NSLog(@"scoring3");
    */

}


-(void)animateScore:(id)sender
{
    
	if (oldScore <= LevelScore)
    {
		oldScore += (arc4random() % 1000); //get a random number between one and ten
		if (oldScore > LevelScore)
        { //if we went to far, pull it bacl
			oldScore = LevelScore;
		}
        
		//[scoreLabel setString:[NSString stringWithFormat:@"Score: %i",oldScore]]; //update it with the new oldScore

	}
	else
    {
		oldScore = LevelScore; //if we've arrived at the score
		[self unschedule:@selector(animateScore:)]; //...unschedule us
	}
}


- (void) showPlaca:(NSString*)mensaje :(NSString*)nivel :(NSString*)score :(NSString*)record :(BOOL)gano :(int) estrellas_best :(int) estrellas_score :(bool)newrecord;
{
	
	[self hideHUD];
	
	menu = [CCMenu menuWithItems:nil];
    
    placa.visible = 1;
    
	CCMenuItemImage *levelButton = [CCMenuItemImage itemWithNormalImage:@"boton-niveles-small.png" selectedImage:@"boton-niveles-small.png" target:self selector:@selector(levelsButton:)];
	[levelButton setPosition:ccp(98, 16)];
    levelButton.opacity = 200;
	[menu addChild:levelButton];
	
	if (gano)
	{ 
		CCMenuItemImage *nextButton = [CCMenuItemImage itemWithNormalImage:@"boton-next.png" selectedImage:@"boton-next.png" target:self selector:@selector(nextButton:)];
		[nextButton setPosition:ccp(302, 16)];
        nextButton.opacity = 200;
		[menu addChild:nextButton];
        
	}
	else
	{
		CCMenuItemImage *replayButton = [CCMenuItemImage itemWithNormalImage:@"boton-replay.png" selectedImage:@"boton-replay.png" target:self selector:@selector(replayButton:)];
		[replayButton setPosition:ccp(302, 16)];
		[menu addChild:replayButton];
        replayButton.opacity = 200;
		
	}
	
    
    
	CCLabelTTF *placaLabel1 = [CCLabelTTF labelWithString:@"300" fontName:@"Arnold 2.1" fontSize:25 dimensions:CGSizeMake(360,200) hAlignment:kCCTextAlignmentLeft ];
	[placaLabel1 setPosition:ccp(220, 139)];
    
	CCLabelTTF *placaLabel2 = [CCLabelTTF labelWithString:@"2" fontName:@"Arnold 2.1" fontSize:15 dimensions:CGSizeMake(360,200) hAlignment:kCCTextAlignmentLeft ];
	[placaLabel2 setPosition:ccp(220, 113)];
	
	CCLabelTTF *placaLabel3 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",mensaje] fontName:@"Arnold 2.1" fontSize:28 dimensions:CGSizeMake(360,200) hAlignment:kCCTextAlignmentCenter];
	[placaLabel3 setPosition:ccp(205, 70)];
    
	CCLabelTTF *placaLabel4 = [CCLabelTTF labelWithString:@"100" fontName:@"Arnold 2.1" fontSize:21 dimensions:CGSizeMake(360,200) hAlignment:kCCTextAlignmentCenter ];
	[placaLabel4 setPosition:ccp(205, 36)];
    
	
	[placa addChild:placaLabel1];
	[placa addChild:placaLabel2];
	[placa addChild:placaLabel3];
	[placa addChild:placaLabel4];
	
	for( int i =0; i<3; i++)
	{
        
		if(estrellas_best>i)
		{	
			CCSprite *estrellaSprite = [CCSprite spriteWithFile:@"estrella.png"];
			estrellaSprite.position = ccp(46+18*i, 186);
			[placa addChild:estrellaSprite z:15];
			estrellaSprite.scale = 0.5;
		}
		else 
		{
			CCSprite *estrellaSprite = [CCSprite spriteWithFile:@"estrella.png"];
			estrellaSprite.opacity = 100;
			estrellaSprite.position = ccp(46+18*i, 186);
			[placa addChild:estrellaSprite z:15];
			estrellaSprite.scale = 0.5;
		}
		
	}
	
	for( int i =0; i<3; i++)
	{
        
		if(estrellas_score>i)
		{
			CCSprite *estrellaSprite = [CCSprite spriteWithFile:@"estrella.png"];
			estrellaSprite.position = ccp(168+38*i, 90);
			[placa addChild:estrellaSprite z:15];
		}
		else 
		{
			CCSprite *estrellaSprite = [CCSprite spriteWithFile:@"estrella.png"];
			estrellaSprite.position = ccp(168+38*i, 90);
			[placa addChild:estrellaSprite z:15];
			estrellaSprite.opacity = 100;
		}
        
		
	}
	
	menu.position = ccp(0, 0);
    
	if(newrecord)
	{
		CCSprite *medallaSprite = [CCSprite spriteWithFile:@"medalla.png"];
		medallaSprite.position = ccp(340, 205);
		[placa addChild:medallaSprite z:15];
	}
	
	[placa addChild:menu z:22];
    
	
	
}


- (void) levelsButton: (id) sender
{
	
	[self hidePlaca];
	[game gotoLevelMenu];
	
}


- (void) nextButton: (id) sender
{
	
	[self hidePlaca];
	[game gotoNextLevel];
	
}


- (void) replayButton: (id) sender
{
	
	[self hidePlaca];
	[game replayLevel];	
}





- (void) showHelp
{
	
	ShowingHelp = TRUE;
	
	if(gameData.tilt)
	{

		helpSprite = [CCSprite spriteWithFile:@"tutorial2.png"];
		[helpSprite setPosition:ccp(512, 310)];
		[self addChild:helpSprite];		
		
		helpLabel = [CCLabelTTF labelWithString:@"Tilt your device to start rolling" fontName:@"Arnold 2.1" fontSize:20 dimensions:CGSizeMake(340,30) hAlignment:kCCTextAlignmentLeft];
		helpLabel.position=ccp(512,220);
		[self addChild:helpLabel];
		
	}
	else 
	{
	
		helpSprite = [CCSprite spriteWithFile:@"tutorial.png"];
		helpSprite.scale = 0.8;
		[helpSprite setPosition:ccp(465, 145)];
		[self addChild:helpSprite];		
		
		helpLabel = [CCLabelTTF labelWithString:@"Slide your finger to rotate" fontName:@"Arnold 2.1" fontSize:20 dimensions:CGSizeMake(300,30) hAlignment:kCCTextAlignmentLeft];
		helpLabel.position=ccp(size.width/2,64);
		[self addChild:helpLabel];
		

	}
	
	
	id espera = [CCDelayTime actionWithDuration:2];
	id desaparecer = [CCFadeOut actionWithDuration:1];
	CCCallFunc* callback = [CCCallFunc actionWithTarget:self selector:@selector(hideHelp:)];
	id esfumar = [CCSequence actions: espera, desaparecer, callback, nil];

	id espera2 = [CCDelayTime actionWithDuration:2];
	id desaparecer2 = [CCFadeOut actionWithDuration:1];
	id esfumar2 = [CCSequence actions: espera2, desaparecer2, nil];
	//help.scale = 0.75;
	[helpSprite runAction: esfumar2];
	[helpLabel runAction: esfumar];

}



-(void) hideHelp:(id)sender
{
	[self removeChild:helpSprite cleanup:YES];	
	[self removeChild:helpLabel cleanup:YES];	
	ShowingHelp = FALSE;
	[self showHUD];
}	


- (void) hidePlaca
{
	//[self removeChild:placa cleanup:YES];
	[self removeChild:menu cleanup:YES];
	[placa removeAllChildrenWithCleanup:YES];
	//[placa removeChild:placaLabel cleanup:YES];
	placa.visible = FALSE;

	[self showHUD];
}

- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent *)event
{
	
	//NSLog(@"Iniciando Touches");
	
  for (UITouch *myTouch in touches) 
  { 
	  	  
    CGPoint location = [myTouch locationInView: [myTouch view]];
  	location = [[CCDirector sharedDirector] convertToGL: location]; 
      if(CGRectContainsPoint(pauseButtonRect, location))
	  {
		  //[game replayLevel];
		  if(!isPaused)
		  {
		  	  isPaused=TRUE;
			  
              game.touchEnabled = NO;
              [[CCDirector sharedDirector] pause];
			  
			  playButton = [CCSprite spriteWithFile:@"boton-resume.png"];
			  [playButton setPosition:pauseButton.position];   
			  [self addChild:playButton z:16];
			  
			  fadeSprite = [CCSprite spriteWithFile:@"fade.png"];
			  [fadeSprite setPosition:ccp(size.width/2, size.height/2)];
			  [self addChild:fadeSprite z:0];
			  
			  pausaLabel = [CCLabelTTF labelWithString:@"Paused" fontName:@"Arnold 2.1" fontSize:22 dimensions:CGSizeMake(360,200) hAlignment:kCCTextAlignmentCenter ];
			  [pausaLabel setPosition:ccp(size.width/2, 80)];
			  [self addChild:pausaLabel];
              
			  
			  menu = [CCMenu menuWithItems:nil];
			  
			  CCMenuItemImage *levelButton = [CCMenuItemImage itemWithNormalImage:@"boton-niveles.png" selectedImage:@"boton-niveles.png" target:self selector:@selector(backtoMenu:)];
			  [levelButton setPosition:ccp(pauseButton.position.x-47,pauseButton.position.y)];
			  [menu addChild:levelButton];
			  
			  
			  if (gameData.music) 
			  {
				  
				  [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
				  
				  CCMenuItemImage *sonidoButton = [CCMenuItemImage itemWithNormalImage:@"boton-sonido-on.png" selectedImage:@"boton-sonido-off.png" target:self selector:@selector(toggleSound:)];
				  [sonidoButton setPosition:ccp(pauseButton.position.x-91,pauseButton.position.y)];   
				  [menu addChild:sonidoButton];
			  }
			  else 
			  {
				  CCMenuItemImage *sonidoButton = [CCMenuItemImage itemWithNormalImage:@"boton-sonido-off.png" selectedImage:@"boton-sonido-on.png" target:self selector:@selector(toggleSound:)];
				  [sonidoButton setPosition:ccp(pauseButton.position.x-91,pauseButton.position.y)];
				  [menu addChild:sonidoButton];
			  }
			  
              
			  menu.position = ccp(0, 0);
			  
		  	  [self addChild:menu z:22];
			  
		  }
		  else 
		  {
  			  [self removeChild:playButton cleanup:YES];
   			  [self removeChild:fadeSprite cleanup:YES];
   			  [self removeChild:pausaLabel cleanup:YES];
		  	  [self removeChild:menu cleanup:YES];
			  
			  [[CCDirector sharedDirector] resume];
			  
			  if (gameData.music) 
			  {
			  	  [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
			  }
			  
			  game.touchEnabled = YES;
			  
			  isPaused=FALSE;
			  
		  }

  		 
        return;
      }
	  
  }  
}


- (void) toggleSound: (id) sender
{

	
	[game toggleMusic];
	
	[self removeChild:playButton cleanup:YES];
	[self removeChild:fadeSprite cleanup:YES];
	[self removeChild:pausaLabel cleanup:YES];
	[self removeChild:menu cleanup:YES];
	
	[[CCDirector sharedDirector] resume];
	game.touchEnabled = YES;
	
	isPaused=FALSE;
	
	
	
}

- (void) backtoMenu: (id) sender
{
	
	[game stopAllActions];
	
	if(ShowingHelp)
	{
		[self removeChild:helpSprite cleanup:YES];	
		[self removeChild:helpLabel cleanup:YES];	
		
	}
	
	if (gameData.music) 
	{
		[[SimpleAudioEngine sharedEngine] setMute:FALSE];
	}
	
	[game unschedule: @selector(tick:)];
	[game unschedule: @selector(segundos:)];
	
	[self removeChild:playButton cleanup:YES];
	[self removeChild:fadeSprite cleanup:YES];
	[self removeChild:pausaLabel cleanup:YES];
	[self removeChild:menu cleanup:YES];

	[game gotoLevelMenu];	
	[[CCDirector sharedDirector] resume];
	
}
@end
