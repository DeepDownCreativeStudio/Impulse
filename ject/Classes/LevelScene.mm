//
//  GameScene.mm
//
//  Copyright GameXtar 2010. All rights reserved.
//
//	info@gamextar.com
//	http://www.gamextar.com - iPhone Development 
//
//

#import "LevelScene.h"
#import "ChapterSelect.h" 
#import "GameScene.h"
#import "Level.h"
#import "GameData.h"

extern int Nivel;
extern GameData *gameData;
extern NSMutableArray *worldsArray;

@implementation LevelScene

+(id)scene
{
	
	//NSLog(@"LEVEL ID %i", [self retainCount]); 
	
	CCScene *scene =[CCScene node];
	LevelScene *layer = [LevelScene node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init]) )
	{
		
		// NUMBER OF WORLDS = 3 ( PAGES )
		
		// CURRENT WORLD = 1, 2, 3
		
		// CURRENT LEVEL = 1, 20
        
     

        
        
		CCMenu *menu = [CCMenu menuWithItems:nil];
        
        size = [[CCDirector sharedDirector] winSize];
		
		NSMutableArray *tmpniveles = [[NSMutableArray alloc] init];
		

		
        
		World *tmpworlds  = [worldsArray objectAtIndex:gameData.selectedChapter-1];
		tmpniveles = tmpworlds.niveles;
		
        
		
        
		int h = 0;
		
		for (int i = 0; i<3; i++)			// 3 LINEAS
		{
                 
			for (int j = 0; j<6; j++)		// 6 COLUMNAS
			{
				Level *l = [tmpniveles objectAtIndex:h];
                
                if(l.locked)
                {
                    CCMenuItemImage *item = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"cuadrito%i-locked.png", gameData.selectedChapter]  selectedImage:[NSString stringWithFormat:@"cuadrito%i-locked.png", gameData.selectedChapter] target:self selector:@selector(newGame:)];
                    item.isEnabled = NO;
                    item.tag = h+1;
                    item.position = ccp((size.width*0.12)+(size.width*0.15)*j, (size.height*0.82)-(74*i));
                    [menu addChild:item];
                    
                         
                }
                else 
                { 
                    
                    CCMenuItemImage *item = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"cuadrito%i.png", gameData.selectedChapter] selectedImage:[NSString stringWithFormat:@"cuadrito%i-down.png",gameData.selectedChapter ] target:self selector:@selector(newGame:)];
                    item.tag = h+1;
                    item.position = ccp((size.width*0.12)+(size.width*0.15)*j, (size.height*0.82)-(74*i));
                    CCLabelTTF* iconLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",h+1] fontName:@"Arnold 2.1" fontSize:30 dimensions:CGSizeMake(120,40) hAlignment:kCCTextAlignmentCenter];
                    iconLabel.color = ccc3(255,255,255);
                    iconLabel.position = ccp(32,34);
                    [item addChild:iconLabel];
					
                    for( int k =0; k<3; k++)
                    {
                        
                        if(l.estrellas>k)
                        {	
                            CCSprite *estrellaSprite = [CCSprite spriteWithFile:@"estrella.png"];
                            estrellaSprite.position = ccp(21+12*k, 9);
                            [item addChild:estrellaSprite z:15];
                            estrellaSprite.scale = 0.25;
						}
						else 
						{
                            CCSprite *estrellaSprite = [CCSprite spriteWithFile:@"estrella.png"];
                            estrellaSprite.opacity = 50;
                            estrellaSprite.position = ccp(21+12*k, 9);
                            [item addChild:estrellaSprite z:15];
                            estrellaSprite.scale = 0.25;
						}
						
					}
                   
					[menu addChild:item];
				}
				
				h++;
				
			}
						
		}

             
        
		NSString *fondo = [NSString stringWithFormat:@"fondomundo%i.png",gameData.selectedChapter];
		
		CCSprite *bg = [CCSprite spriteWithFile:fondo];
		bg.position = ccp(size.width/2,size.height/2);
		[self addChild: bg z:0];
		
		for(int i = 0; i<10;i++)
		{
			CCSprite *estrellita = [CCSprite spriteWithFile:@"skystar1.png"];
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
			estrellita.position = ccp(random() % (int)size.width, random() % (int)size.height);
			estrellita.rotation = CCRANDOM_0_1() * 360;
			estrellita.scale = CCRANDOM_0_1() * 2 + 0.2;
			
			[self addChild:estrellita z:0];
			
		}
		
		
		CCSprite *bolasas = [CCSprite spriteWithFile: @"bolasas.png"];
		bolasas.position = ccp(size.width-70,61);
		[self addChild: bolasas z:1];
        
		menu.position = ccp(0,0);

		
		CCMenuItemImage *item = [CCMenuItemImage itemWithNormalImage:@"boton-back.png" selectedImage:@"boton-over-small.png" target:self selector:@selector(back:)];
		item.position = ccp(30,30);
		[menu addChild:item];
		
		[self addChild:menu z: 2];
        
        
		pressButtonAllowed = true;
	}
	return self;
}

-(void) newGame: (id) sender
{
    
    if (pressButtonAllowed) {
        pressButtonAllowed = false;
	CCMenuItem *item = (CCMenuItem *)sender;
	
	Nivel = item.tag;
	//NSLog(@"NIVEL: %i", Nivel);
	
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.7 scene:[GameScene scene] ]];}
}


-(void) back: (id) sender
{
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.4 scene:[ChapterSelect node] ]];
}

-(void)dealloc
{
	//NSLog(@"LEVEL DEALLOC %i", [self retainCount]); 
	[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}

@end