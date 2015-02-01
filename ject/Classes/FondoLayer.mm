//
//  FondoLayer.mm
//
//  Copyright GameXtar 2010. All rights reserved.
//
//	info@gamextar.com
//	http://www.gamextar.com - iPhone Development 
//
//
#import "FondoLayer.h"
#import "MenuScene.h"
#import "GameScene.h"

extern NSString *superfondo;

@implementation FondoLayer

-(id) init
{
	if( (self=[super init]) )
	{

        CGSize size = [[CCDirector sharedDirector] winSize];

        
		//NSLog(@"FONDOLAYER INIT %i", [self retainCount]);

		
		//NSLog(@"Seteando FondoLayer:%@", superfondo);
			
			[self removeAllChildrenWithCleanup:YES];
		
			fondo2 = [CCSprite spriteWithFile:superfondo];
			fondo2.position = ccp(size.width/2,size.height/2);
			[self addChild:fondo2 z:0];
		
		
		id expande = [CCScaleBy actionWithDuration:0.5 scale:2.0f];
		id contrae = [expande reverse];
		id latir = [CCRepeatForever actionWithAction: [CCSequence actions: expande, contrae, nil]];

		for(int i = 0; i<10;i++)
		{
			CCSprite *estrellita = [CCSprite spriteWithFile:@"skystar1.png"];
			estrellita.position = ccp(random() % (int)size.width, random() % (int)size.height);
			estrellita.rotation = CCRANDOM_0_1() * 360;
			estrellita.scale = CCRANDOM_0_1() * 1;
			
			[estrellita runAction: [[latir copy] autorelease]];
			
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
		
		
	}
	return self;
}


-(void) setFondo: (NSString*) fondo
{
	
	//NSLog(@"FONDO LAYER SET FONDO");
	
	[self removeAllChildrenWithCleanup:YES];
		
	fondo2 = [CCSprite spriteWithFile:fondo];
	fondo2.anchorPoint = ccp(0,0);
	
	
	[self addChild:fondo2 z:0];
	
	id expande = [CCScaleBy actionWithDuration:0.5 scale:2.0f];
	id contrae = [expande reverse];
	id latir = [CCRepeatForever actionWithAction: [CCSequence actions: expande, contrae, nil]];
	
	for(int i = 0; i<10;i++)
	{
		CCSprite *estrellita = [CCSprite spriteWithFile:@"skystar1.png"];
		CGSize size = [[CCDirector sharedDirector] winSize];
		estrellita.position = ccp(random() % (int)size.width, random() % (int)size.height);
		estrellita.rotation = CCRANDOM_0_1() * 360;
		estrellita.scale = CCRANDOM_0_1() * 1;

		[estrellita runAction: [[latir copy] autorelease]];
		
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

}

-(void) setFondoRotation:(float)rotationer
{
    if (fondo2!=nil){
        fondo2.rotation = rotationer;
        
        
    }}


- (void) dealloc
{
	[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}
@end

