//
//  GameScene.mm
//
//  Copyright GameXtar 2010. All rights reserved.
//
//	Javier Asenjo Fuchs
//	http://www.gamextar.com - iPhone Development
//
//

// Import the interfaces
#import "GameScene.h"
#import "HUDLayer.h"
#import "SimpleAudioEngine.h"
#import "LevelScene.h"
#import "Level.h"
#import "FondoLayer.h"
#import "ChapterSelect.h"
#import "EndScene.h"
#import "GameData.h"
#import "LHSprite.h"
#import "GameCenterManager.h"
#import "GameDataParser.h"
#import "mainScene.h"


extern int Nivel;
extern GameData *gameData;
extern GameScene* game;
int RecordScore;
int LevelScore;
int NewScore;

extern NSMutableArray *worldsArray;
CCSprite *agujaSprite;
BOOL isPaused;
FondoLayer *myfondito;
NSString *superfondo;


// FLECHA

const float32 FIXED_TIMESTEP = 1.0f / 600.0f;
const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;
const int32 VELOCITY_ITERATIONS = 8;
const int32 POSITION_ITERATIONS = 8;


bool SLOW_MOTION = false;

#define MIN_TRACK_PATH_DIST (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 8.0f : 8.0f )

struct TargetParameters
{
    float hardness;
};

TargetParameters m_strawTarget;
TargetParameters m_woodTarget;
TargetParameters m_steelTarget;

bool m_useWeldJoint = true;

/*
 // enums that will be used as tags
 enum {
 
 TAG_PLATAFORMA = 4,
 TAG_STATIC = 5,
 TAG_MALO2 = 8,
 TAG_SPRITE = 9,
 TAG_BUENO = 10,
 TAG_ESTRELLA = 11,
 TAG_META = 12,
 TAG_MALO = 13,
 TAG_CIRCULO = 14,
 TAG_REBOTE = 15,
 TAG_VENTILADOR = 16,
 TAG_PIVOT = 17,
 TAG_REVIVE = 18,
 TAG_LLAMA = 19,
 TAG_DESAPARECE = 44,
 TAG_JUNK = 255,
 
 };
 
 */

static const float MIN_SCALE = 0.4;
static const float MAX_SCALE = 1.5;

@implementation GameScene

+(id) scene
{
	
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    GameScene *Gamelayer = [GameScene node];
    
    // add layer as a child to scene
    [scene addChild: Gamelayer z:1];


    
    return scene;
    
}

// initialize your instance here
-(id) init
{
	if( (self=[super init]))
	{
        
        [super init];
        
		
		//NSLog(@"GS %i", [self retainCount]);
		
        self.touchEnabled = YES;
		firstRun = true;
        
		      
		_winSize = [[CCDirector sharedDirector] winSize];
		
		//[[GameHUD sharedManager] setGame:self];
		//game = self;
        
        

        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [currentDefaults objectForKey:[NSString stringWithFormat:@"data"]];
        
        if (data != nil)
        {
            NSMutableArray *arrayData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            levelUsed = [[arrayData objectAtIndex:0] intValue];
            levelHigh = [[arrayData objectAtIndex:1] intValue];
        }
        else
        {
            
            NSMutableArray* starter = [[NSMutableArray alloc]init];
            [starter addObject:[NSNumber numberWithInt:1]];
            [starter addObject:[NSNumber numberWithInt:1]];
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter]
                                                      forKey:[NSString stringWithFormat:@"data"]];
            levelHigh = 1;
            levelUsed = 1;
            
        }
        
        //circulito

       
        NSData *dataMem = [currentDefaults objectForKey:[NSString stringWithFormat:@"memory"]];
        
        if (dataMem != nil)
        {
            NSMutableArray *arrayData = [NSKeyedUnarchiver unarchiveObjectWithData:dataMem];
            memoryX = [[arrayData objectAtIndex:0] floatValue];
            memoryY = [[arrayData objectAtIndex:1] floatValue];
            repeat = [[arrayData objectAtIndex:2] intValue];
        }
        else
        {
            
            NSMutableArray* starter = [[NSMutableArray alloc]init];
            [starter addObject:[NSNumber numberWithFloat:-200]];
            [starter addObject:[NSNumber numberWithFloat:-200]];
            [starter addObject:[NSNumber numberWithInt:0]];
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter]
                                                      forKey:[NSString stringWithFormat:@"memory"]];
            
            memoryX = -200;
            memoryY = -200;
            repeat = 0;
        }
        
        NSLog(@"repeat es %i... %f,%f", repeat, memoryX,memoryY);
        
            
        blockRemove = true;
        locationMove = false;
        fondoapplied = true;
        
        
		[self StartLevel:[NSString stringWithFormat:@"J%i",levelUsed]];
        

        
		[self schedule: @selector(tick:)];
		//[self schedule: @selector(segundos:) interval:0.1];
		//[self setupCollisionHandling];
        noSeguir = false;
        
        keyCount = 0;
        NSArray* keys = [lh spritesWithTag:TAG_KEY]; {
            for (LHSprite* spr in keys) {
                keyCount++;
            }}
        NSLog(@"total de llaves en este nivel = %i", keyCount);
        
        UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandle:)];
        rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [rightRecognizer setNumberOfTouchesRequired:2];
        [[[CCDirector sharedDirector] view] addGestureRecognizer:rightRecognizer];
        [rightRecognizer release];
        
        UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandle:)];
        leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [leftRecognizer setNumberOfTouchesRequired:2];
        [[[CCDirector sharedDirector] view]addGestureRecognizer:leftRecognizer];
        [leftRecognizer release];
        
        UISwipeGestureRecognizer *downRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoLevelMenu)];
        downRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        [downRecognizer setNumberOfTouchesRequired:2];
        [[[CCDirector sharedDirector] view]addGestureRecognizer:downRecognizer];
        [downRecognizer release];
        
        
        bg2 = [lh createSpriteWithName:@"bg" fromSheet:@"design" fromSHFile:@"design.pshs"];
        bg2.uniqueName = [NSString stringWithFormat:@"bgw2"];
        bg2.color = ccBLACKBLUE;
        bg2.position = ccp ([self selfScreen].size.height / 2,160);
        bg2.scaleX = [self selfScreen].size.height / 480;
        bg2.zOrder = -510;
        bg2.tag = 10;
        
        bg = [lh createSpriteWithName:@"bg" fromSheet:@"design" fromSHFile:@"design.pshs"];
        bg.uniqueName = [NSString stringWithFormat:@"bgw"];
        bg.position = ccp ([self selfScreen].size.height / 2,160);
        bg.scaleX = [self selfScreen].size.height / 480;
        bg.zOrder = -500;
        bg.tag = 10;
        
        menu = [CCMenu menuWithItems:nil];
		
		
		CCMenuItemImage *but = [CCMenuItemImage itemWithNormalImage:@"back.png" selectedImage:@"backps.png" target:self                                       selector:@selector(back)];
        but.position = ccp (-215,136);
		[menu addChild:but];
        [self addChild:menu];
         
        
    }
	return self;
}

- (void) back
{
    if (noSeguir == false)
    {
        noSeguir = true;
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[mainScene node]]];
        [[SimpleAudioEngine sharedEngine] playEffect:@"photo.mp3"];
    }
}


/*
 // Point conversion routines
 - (CGPoint)convertPoint:(CGPoint)point fromNode:(CCNode *)node {
 return [self convertToNodeSpace:[node convertToWorldSpace:point]];
 }
 - (CGPoint)convertPoint:(CGPoint)touchLocation toNode:(CCNode *)node {
 // do the inverse of the routine above
 // Where touchLocation is the result of what is called from the UIGestureRecognizer
 CGPoint newPos = [[CCDirector sharedDirector] convertToGL: touchLocation];
 newPos = [node convertToNodeSpace:newPos];
 return newPos;
 }*/

// Zoom board

-(void) setupCollisionHandling {
    
    [lh useLevelHelperCollisionHandling];
    

    [lh registerBeginOrEndCollisionCallbackBetweenTagA:TAG_ARROW andTagB: TAG_LOST idListener:self selListener:
     @selector(arrowLost:)];
    
    [lh registerBeginOrEndCollisionCallbackBetweenTagA:TAG_ARROW andTagB: DEFAULT_TAG idListener:self selListener:
     @selector(tuck:)];
    
    
}



- (void) arrowLost:(LHContactInfo*)contact
{
    LHSprite* a = [contact spriteA];
    if (tiros == cantidadDeTirosMaximo)
    {
        
        if (a == following)
        {
        [self perdedor];
        }
    }
    
    
    kill = following;
    nowToKill = true;
    following = cupido;
    


}



-(void)tuck:(LHContactInfo*)contact
{
 
}


-(void) StartLevel:(NSString*) level
{

	NSLog(@"Iniciando Nivel:%@", level);
	
	isPaused=FALSE;

    TrackingArray =[[NSMutableArray alloc]init];

	cocosAngle = 0;
	//[self setPosition:ccp(_origin.x,_origin.y)];
	self.rotation = 0;
	Bolas=0;
	Stars=0;
	gano=false;
	perdio=false;
	portal=false;
	Tiempo = 0;
	LevelScore = 0;
	NewScore = 0;
    
	zoomed = false;
	agujaSprite.rotation = 0;
	Star1 = 0;
	Star2 = 0;
	Star3 = 0;
	StarScore = 0;
	mensaje = nil;
	NewRecord = FALSE;
    pocion = false;
    spacer = true;
    bubbleForce = false;
    atrapadoEnBaloon = false;
    locationMove = false;
    teleportAllowed = true;
    
   
    
    shooting = false;
    tiros = 0;
    fuerza = 0;
    MAXIMUM_NUMBER_OF_STEPS = 25;
    
    
    cantidadDeTirosMaximo = 1;

	//
	//	ACTIONS
	//
	
	
	
	if(firstRun == false)
	{

		
		for (b2Body* body = world->GetBodyList(); body; body = body->GetNext())
		{
			if (body->GetUserData() != NULL)
			{
				CCSprite *sprite = (CCSprite *) body->GetUserData();
				[self removeChild:sprite cleanup:YES];
			}
			world->DestroyBody(body);
		}
        
		delete world;
		world = NULL;
		// delete _contactListener;
		
		[self removeAllChildrenWithCleanup:YES];
		
		
		[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
        
	}
	else
	{
   	}
    
	
	if (Nivel == 1  &&  gameData.selectedChapter == 1)
	{
        
		//[[GameHUD sharedManager] showHelp];
        
	}
	
	firstRun = false;
	
	// Define the gravity vector.
	b2Vec2 gravity;
	gravity.Set(0.0f, -14.0f);
    gravityForBall = gravity;
    broken = false;
    

    
	world = new b2World(gravity);
	world->SetContinuousPhysics(true);

	// Define the ground body.
	b2BodyDef groundBodyDef;
	
	groundBodyDef.position.Set(0, 0); // bottom-left corner

    lh = [[LevelHelperLoader alloc] initWithContentOfFile:level];
    
    [lh addObjectsToWorld:world cocos2dLayer:self];
    
 
    [lh createPhysicBoundaries:world];
  

    CGRect rect = [self selfScreen];
    rect = CGRectMake(0, 0, rect.size.height, rect.size.width);
    worldSize = rect;
    
    
    offsetH = (_winSize.width/2/self.scale);
    offsetV = (_winSize.height/2/self.scale);
    
    NSLog(@"ORIGIN X%f - Y%f             WIDTH:%f - HEIGHT: X%f", worldSize.origin.x,worldSize.origin.y,worldSize.size.width, worldSize.size.height);
    
    _contactListener = new MyContactListener();
	world->SetContactListener(_contactListener);
    

    // LINEA DE TIRO
    
    line1 = [CCSprite spriteWithFile:@"linea.png"];
    //line1.visible = FALSE;
    line1.opacity = 200;
    [line1.texture setAntiAliasTexParameters];
    [line1 setAnchorPoint:ccp(0.0f, 0.5f)];
    [self addChild:line1 z:5];
    
    
    line2 = [CCSprite spriteWithFile:@"linea.png"];
    line2.opacity = 255;
    [line2.texture setAntiAliasTexParameters];
    [line2 setAnchorPoint:ccp(0.0f, 0.5f)];
    [self addChild:line2 z:5];
    
    line3 = [CCSprite spriteWithFile:@"linea.png"];
    line3.opacity = 255;
    [line3.texture setAntiAliasTexParameters];
    [line3 setAnchorPoint:ccp(0.0f, 0.5f)];
    [self addChild:line3 z:5];
    
    

    cupido = [lh spriteWithUniqueName:@"arco"];
    following = cupido;

    waitingToStop = false;
    
    
    //cargando box

    box = [lh spriteWithUniqueName:@"box"];
    if (box!=nil) {
        NSLog(@"box existe");
   }
    
    CCAction *fadeIn = [CCFadeTo actionWithDuration:0.35f opacity:127];
    CCAction *fadeOut = [CCFadeTo actionWithDuration:0.35f opacity:40];
    
    CCSequence *pulseSequence = [CCSequence actions:
                                 [fadeIn copy],
                                 [fadeOut copy],
                                 nil];
    
    CCRepeatForever *repeats = [CCRepeatForever actionWithAction:pulseSequence];
    glass = [lh spriteWithUniqueName:@"glass"];
    glass.color = ccBLUE;
    if (glass){[glass runAction:repeats];}
    off = false;
    
}


-(void) setBack: (NSString*) fondo
{
	
	//NSLog(@"Seteando Fondo:%@", fondo);
	superfondo = fondo;
	[superfondo retain];
	[myfondito setFondo:fondo];
	
}


-(void) setStars:(int)min :(int)mid :(int)max;
{
	
	Star1 = min;
	Star2 = mid;
	Star3 = max;
}

-(void) segundos: (ccTime) dt
{
	
    Tiempo++;
	
}

-(void)afterStep
{   
    
    std::vector<b2Body *>toDestroy;
    std::vector<MyContact>::iterator pos;
	
    for(pos = _contactListener->_contacts.begin(); pos != _contactListener->_contacts.end(); ++pos)
    {
        
        if ((perdio) || (gano))
        {
            break;
        }
        
        MyContact contact = *pos;
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL)
        {
            LHSprite *spriteA = (LHSprite *) bodyA->GetUserData();
            LHSprite *spriteB = (LHSprite *) bodyB->GetUserData();
            
            if (spriteB.tag == TAG_ARROW)
            {
                if(spriteA.tag == DEFAULT_TAG)
            {
                
                if (repeatpoint.x == spriteB.position.x) {
                    
                    if (repeatAllow < 2) {
                    repeatcounter++;
                        repeatAllow = 10;
                    
                    }
                    
                }
                else {
                    repeatcounter = 0;
                  
                }
                
                if (repeatcounter == 3) {
                    CCSprite* bobo = [CCSprite spriteWithFile:@"reset.png"];
                    bobo.position = ccp(-self.position.x + [self selfScreen].size.height/2,160);
                    [self addChild:bobo z:1000];
                    bobo.opacity = 0;
                    [bobo runAction:[CCFadeTo actionWithDuration:1.5 opacity:160]];
                    resetbo = true;
                }
                repeatpoint = spriteB.position;
                
                if (tuckpass < 1) {
                
                if (!blackout) {
                    for (LHSprite* spr in [lh spritesWithTag:DEFAULT_TAG]) {
                        if (![spr.uniqueName isEqualToString:@"bg"]) {
                            [spr runAction:[CCTintTo actionWithDuration:2 red:0 green:0 blue:50]];
                        }
                    }
                    blackout = true;
                }
                
                
                
                
                CCParticleSystem* particleSystem;
                particleSystem = [CCParticleSystemQuad particleWithFile:@"tuck.plist"];
                particleSystem.positionType = kCCPositionTypeGrouped;
                particleSystem.position = spriteB.position;
                particleSystem.scale = .3f;
                [self addChild: particleSystem z:100];
                    
                    
                    
                    [[SimpleAudioEngine sharedEngine] playEffect:@"acSound.mp3"];
                    CCCallFuncO* selfdestroy = [CCCallFuncO actionWithTarget:particleSystem selector:@selector(removeFromParent) object:nil];
                    CCScaleTo * wait = [CCScaleTo actionWithDuration:3 scale:1];
                    CCSequence * seq = [CCSequence actionOne:wait two:selfdestroy];
                    
                    [particleSystem runAction:seq];
                    
                    tuckpass = 10;
                    
                    
                    
                    [spriteB stopAllActions];
                    spriteB.opacity = 100;
                    CCFadeTo* comein = [CCFadeTo actionWithDuration:.3 opacity:255];
                    [spriteB runAction:comein];
                    
                    
                    spriteA.opacity = 185;
                    CCFadeTo* comeout = [CCFadeTo actionWithDuration:1 opacity:125];
                    [spriteA runAction:comeout];
                     
                 
                }
                
            }
                
                if(spriteA.tag == TAG_KEY)
                {
                    float bee = [spriteA body] -> GetGravityScale();
                    
                    if (bee!=278) {
                    
                        [[SimpleAudioEngine sharedEngine] playEffect:@"door.mp3"];
                    keyCount = keyCount - 1;
                        NSLog(@"key count = %i", keyCount);
                    [spriteA body] -> SetGravityScale(278);
                        spriteA.visible = false;
                    if (keyCount == 0){
                        
                        
                       LHSprite * arrive = [lh spriteWithUniqueName:@"arrive"];
                        [arrive prepareAnimationNamed:@"unlock" fromSHScene:@"items.pshs"];
                        [arrive playAnimation];
                        
                        for (b2Fixture* f = [arrive body]->GetFixtureList(); f; f = f->GetNext())
                    
                        { f -> SetSensor(YES);
                            
                        }
                    }
                    }
                }
                

                
                
                
                if(spriteA.tag == TAG_BROKEN)
                {
                    if (noSeguir == false) {
float bee = [spriteA body] -> GetGravityScale();
                        
                        if (bee!=278) {
                        [[SimpleAudioEngine sharedEngine] playEffect:@"broken.mp3"];
                        [spriteA prepareAnimationNamed:@"broken" fromSHScene:@"broken.pshs"];
                        [spriteA playAnimation];
                            removeLater = spriteA;
                            blockRemove = false;
                        [spriteA body] -> SetGravityScale(278);
                        
                        }}}
                if(spriteA.tag == TAG_TELEPORT)
                {    if (noSeguir == false) {
                    float g = [spriteA body] -> GetGravityScale();
                    if (g != 0) {
                        

                        
                    LHSprite* teleport;
                    if ([spriteA.uniqueName isEqualToString:@"teleport1"]){
                        
                        teleport = [lh spriteWithUniqueName:@"teleport2"];
                        NSLog(@"teleporting to 2, position %f, %f",[teleport position].x,[teleport position].y);
                    }
                    if ([spriteA.uniqueName isEqualToString:@"teleport2"]){
                        
                        teleport = [lh spriteWithUniqueName:@"teleport1"];
                        NSLog(@"teleporting to 1, position %f, %f",[teleport position].x,[teleport position].y);
                    }
                    if ([spriteA.uniqueName isEqualToString:@"teleport3"]){
                        
                        teleport = [lh spriteWithUniqueName:@"teleport4"];
                        NSLog(@"teleporting to 4, position %f, %f",[teleport position].x,[teleport position].y);
                    }
                    if ([spriteA.uniqueName isEqualToString:@"teleport4"]){
                        
                        teleport = [lh spriteWithUniqueName:@"teleport3"];
                        NSLog(@"teleporting to 3, position %f, %f",[teleport position].x,[teleport position].y);
                        }
                        
                        [teleport transformScale:1.2];
                        [teleport runAction:[CCScaleTo actionWithDuration:.5 scale:1]];

                    [teleport body] -> SetGravityScale(0);
                    teleportAllowed = false;
                    teleportPoint = teleport.position;
                    
                        
                    [[SimpleAudioEngine sharedEngine] playEffect:@"beam.mp3"];
                        
                        
                    [timerTeleportAllowed invalidate];
                    timerTeleportAllowed = nil;
                    timerTeleportAllowed = [[NSTimer scheduledTimerWithTimeInterval:.7 target:self selector:@selector(reactivate) userInfo:nil repeats:NO] retain];

                        
                        
                    }}}
                
                if(spriteA.tag == TAG_WIN)
                {
                    if (noSeguir == false) {
                    
                    b2Fixture * fixture2 = contact.fixtureA;
                    bool canWin = fixture2 -> IsSensor();
                    if (canWin) {
                        
                        if (timer==nil) {
                            
                            
                            
                            [[SimpleAudioEngine sharedEngine] playEffect:@"ganar.mp3"];
                            LHSprite * arrive = [lh spriteWithUniqueName:@"arrive"];
                            arrive.color = ccWHITE;
                            CGPoint clep = ccpSub(arrive.position, following.position);
                            float forced =  ccpToAngle(clep);
                            clep = ccpForAngle(forced);
                            b2Vec2 smooth (clep.x, clep.y);
                            [arrive prepareAnimationNamed:@"win" fromSHScene:@"items.pshs"];
                            [arrive playAnimation];
                            
                            [following body] -> SetGravityScale(0);
                            noSeguir = true;
                            [following body] -> SetLinearVelocity(.8 * smooth);
                            
                            timer = [[NSTimer scheduledTimerWithTimeInterval:.7 target:self selector:@selector(ganador) userInfo:nil repeats:NO] retain];
                            
                            
                            
                        }}
                    else {
                    
                        CCParticleSystem* particleSystem;
                        particleSystem = [CCParticleSystemQuad particleWithFile:@"tuck.plist"];
                        particleSystem.positionType = kCCPositionTypeGrouped;
                        particleSystem.position = spriteB.position;
                        particleSystem.scale = .3f;
                        
                        
                        [self addChild: particleSystem z:100];
                        [[SimpleAudioEngine sharedEngine] playEffect:@"acSound.mp3"];
                        CCCallFuncO* selfdestroy = [CCCallFuncO actionWithTarget:particleSystem selector:@selector(removeFromParent) object:nil];
                        CCScaleTo * wait = [CCScaleTo actionWithDuration:3 scale:1];
                        CCSequence * seq = [CCSequence actionOne:wait two:selfdestroy];
                        
                        [particleSystem runAction:seq];
                        
                        tuckpass = 10;
                        
                        
                        [spriteB stopAllActions];
                        spriteB.opacity = 100;
                        CCFadeTo* comein = [CCFadeTo actionWithDuration:.3 opacity:255];
                        CCTintTo* tinter = [CCTintTo actionWithDuration:.5 red:255 green:255 blue:255];
                        spriteB.color = ccRED;
                        [spriteB runAction:comein];
                        [spriteB runAction:tinter];
                    }
                    
                    
                    }}

                
                if(spriteA.tag == TAG_LOST)
                {
                    following = cupido;
                    [spriteB removeSelf];
                    if (tiros == cantidadDeTirosMaximo) {
                    
                        CCSprite* bobo = [CCSprite spriteWithFile:@"reset.png"];
                        bobo.position = ccp(-self.position.x + [self selfScreen].size.height/2,160);
                        [self addChild:bobo z:1000];
                        bobo.opacity = 0;
                        [bobo runAction:[CCFadeTo actionWithDuration:1.5 opacity:160]];
                        resetbo = true;
                    
                    }
                }
                
            }
            
        }
        
    }
    
    

}
    
-(void) reactivate
{
   
    NSArray* keys = [lh spritesWithTag:TAG_TELEPORT]; {
        for (LHSprite* spr in keys) {
            [spr body] -> SetGravityScale(1);
        }}
}

-(void)step:(ccTime)dt
{
	float32 frameTime = dt;
	int stepsPerformed = 0;
	while ( (frameTime > 0.0) && (stepsPerformed < MAXIMUM_NUMBER_OF_STEPS) ){
		float32 deltaTime = std::min( frameTime, FIXED_TIMESTEP );
		frameTime -= deltaTime;
		if (frameTime < MINIMUM_TIMESTEP)
        {
			deltaTime += frameTime;
			frameTime = 0.0f;
		}
		world->Step(deltaTime,VELOCITY_ITERATIONS,POSITION_ITERATIONS);
		stepsPerformed++;
		[self afterStep]; // process collisions and result from callbacks called by the step
	}
	world->ClearForces ();
}


-(void) tick: (ccTime) dt
{
	[self step:dt];
    
    float dragConstant = 8.3f;
    
    // FEDE
    
    
    if (tuckpass>0) {
        tuckpass--;
    }
    
    //Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		
        if ((perdio) || (gano))
        {
            break;
        }
        

        
		if (b->GetUserData() != NULL)
		{
            
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            myActor.position = [LevelHelperLoader metersToPoints:b->GetPosition()];
            myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());}}
    

    
    if (box!=nil) {
        CGRect rect2 = box.boundingBox;
        if (following.tag==1) {

    if (noSeguir == false) {
    if (CGRectContainsPoint(rect2, following.position))
    {[following body] -> SetGravityScale(-1);  [self stepIn];}
    else {[following body] -> SetGravityScale(1); [self stepOut];}
    } else {[following body] -> SetGravityScale(0);}
    }}
    
    
    if ([following body]) {
    
        b2Vec2 vc = [following body] -> GetLinearVelocity();
        float flo = ccpToAngle(ccp(vc.x,vc.y)) *(360/(3.141592653 * 2));
        [following transformRotation: -flo + 90];
        cupido.opacity = 50;
        
        
        
        [cupido transformRotation: cupido.rotation + 12];

        
    }
    
    else {
        [following transformRotation: following.rotation + 2];
    
    }
    
    if (blackout) {
        
        LHSprite* bg = [lh spriteWithUniqueName:@"bgw"];
            bg.opacity = 120 + (bg.opacity - 120) *.99f;
    
        
        
        
    }
    
    if (repeatAllow>0) {
        repeatAllow--;
    }
    
    
    if (nowToKill)
    {
        if (kill.tag == TAG_ARROW)
        {
            [kill removeSelf];
        }
    }
    
    if (teleportAllowed==false) { [following transformPosition:teleportPoint]; teleportAllowed = true;   }

    if (blockRemove == false) {   [removeLater body] -> SetActive(NO); blockRemove = true;
    }
    

    if (repeat>0) {
        repeat = -10;
        memory = [lh createSpriteWithName:@"memory" fromSheet:@"UntitledSheet" fromSHFile:@"items.pshs"];
       
        [memory transformPosition:ccp(memoryX,memoryY)];
        [memory transformScale:1];
        memory.opacity = 200;
        [memory runAction:[CCFadeTo actionWithDuration:.35f opacity:125.0f]];
         NSLog(@"creating memory in position %f, %f",memoryX,memoryY);
    }
    
    if (following.tag == TAG_ARROW)
    {
 
       b2Body *arrowBody = following.body;
    
        b2Vec2 flightDirection = arrowBody->GetLinearVelocity();
        float flightSpeed = flightDirection.Normalize();//normalizes and returns length
        b2Vec2 pointingDirection = arrowBody->GetWorldVector( b2Vec2( 1, 0 ) );
        float dot = b2Dot( flightDirection, pointingDirection );
    
        float dragForceMagnitude = (1 - dot) * flightSpeed * flightSpeed * dragConstant * arrowBody->GetMass();
    
        b2Vec2 arrowTailPosition = arrowBody->GetWorldPoint( b2Vec2( -0, 0 ) );
       /* arrowBody->ApplyForce( dragForceMagnitude * -flightDirection, arrowTailPosition );*/
    
        [self showTrackingPath: CGPointMake(arrowTailPosition.x*PTM_RATIO,arrowTailPosition.y*PTM_RATIO)];
    
        if (ball != nil) {
            float ext = [lh returnExtension] *([self selfScreen].size.height/480);
            if (ball.position.x < [self selfScreen].size.height/2) {
                self.position = ccp(0, self.position.y);
            }
            else if (ball.position.x > ext - [self selfScreen].size.height/2) {
                self.position = ccp(-(ext - [self selfScreen].size.height), self.position.y);
            }
            else {
            self.position = ccp(-ball.position.x+ [self selfScreen].size.height/2, self.position.y);
            }
            [bg transformPosition:ccp(-self.position.x + [self selfScreen].size.height/2, bg.position.y)];
            [bg2 transformPosition:ccp(-self.position.x + [self selfScreen].size.height/2, bg.position.y)];
            [menu setPosition:ccp(-self.position.x + [self selfScreen].size.height/2, menu.position.y)];
        }
        
}
    if (startupSequence == 0) {
        
        float speed;
        float ext = [lh returnExtension] * ([self selfScreen].size.height/480);
        float secondpost = -(ext - [self selfScreen].size.height);
        
        
        
        
        speed = self.position.x * (secondpost - self.position.x);
        
        speed = sqrtf(speed);
        speed = speed / 20;
        self.position = ccp(self.position.x + speed, self.position.y);
        
        if (self.position.x > -2) {self.position = ccp (0, self.position.y);
            startupSequence = 1;
        }
        
        [bg transformPosition:ccp(-self.position.x + [self selfScreen].size.height/2, bg.position.y)];
        [bg2 transformPosition:ccp(-self.position.x + [self selfScreen].size.height/2, bg.position.y)];
        [menu setPosition:ccp(-self.position.x + [self selfScreen].size.height/2, menu.position.y)];
    
    }
    
    [self first];
    
}

- (void) stepIn {
    

    
    
    if (!off) {
    CCAction *fadeIn = [CCFadeTo actionWithDuration:0.35f opacity:230];
    CCAction *fadeOut = [CCFadeTo actionWithDuration:0.35f opacity:120];
    
    CCSequence *pulseSequence = [CCSequence actions:
                                 [fadeIn copy],
                                 [fadeOut copy],
                                 nil];
    
    CCRepeatForever *repeats = [CCRepeatForever actionWithAction:pulseSequence];
    glass = [lh spriteWithUniqueName:@"glass"];
    glass.color = ccBLUE;
        if (glass){
            [glass stopAllActions];
            [glass runAction:repeats];}
        off = true;
        transe = 0;
    }
    
    if (transe<1) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"hit.mp3"];
        transe = 20;
    }
    transe--;
    
}


- (void) stepOut {
    if (off) {
        CCAction *fadeIn = [CCFadeTo actionWithDuration:0.35f opacity:90];
        CCAction *fadeOut = [CCFadeTo actionWithDuration:0.35f opacity:42];
        
        CCSequence *pulseSequence = [CCSequence actions:
                                     [fadeIn copy],
                                     [fadeOut copy],
                                     nil];
        
        CCRepeatForever *repeats = [CCRepeatForever actionWithAction:pulseSequence];
        glass = [lh spriteWithUniqueName:@"glass"];
        glass.color = ccBLUE;
        if (glass){
            [glass stopAllActions];
            [glass runAction:repeats];}
        off = false;
    }
}

-(void) first {
    if (!first) {
        
        movedCircle  = [lh createSpriteWithName:@"memory" fromSheet:@"UntitledSheet" fromSHFile:@"items.pshs"];
        movedCircle.color = ccBLUE;
        movedCircle.opacity = 125;
        movedCircle.visible = false;
        first = true;
        for (LHSprite* spr in [lh spritesWithTag:DEFAULT_TAG]) {
            if (![spr.uniqueName isEqualToString:@"bg"]) {
            spr.color = ccBLUE;
                spr.opacity = 125;
            }
        }
            LHSprite*spr1 = [lh spriteWithUniqueName:@"arco"];
            spr1.color = ccBLUE;
            spr1.opacity = 125;
            [spr1 transformScale:1];
        
        for (LHSprite* spr in [lh spritesWithTag:TAG_BROKEN]) {
            spr.opacity = 100;
        }
        
        for (LHSprite* spr in [lh spritesWithTag:TAG_TELEPORT]) {
            puff = !puff;
        CCParticleSystem* particleSystem;
            NSString* str;
            if (puff) {str = [NSString stringWithFormat:@"strange.plist"];}
            else {str = [NSString stringWithFormat:@"strange2.plist"];}
            
        particleSystem = [CCParticleSystemQuad particleWithFile:str];
        particleSystem.positionType = kCCPositionTypeGrouped;
        particleSystem.position = spr.position;
        particleSystem.scale = .25f;
            
        [self addChild: particleSystem z:100];
            spr.opacity = 100;
            spr.scale = .9f;
            spr.color = ccBLACK;
            
            
            if (puff) {
            CCAction *fadeIn = [CCFadeTo actionWithDuration:0.35f opacity:120];
            CCAction *fadeOut = [CCFadeTo actionWithDuration:0.35f opacity:50];
            CCSequence *pulseSequence = [CCSequence actions:
                                         [fadeIn copy],
                                         [fadeOut copy],
                                         nil];
            CCRepeatForever *repeats = [CCRepeatForever actionWithAction:pulseSequence];
            [spr runAction:repeats];
            }
            else {
                CCAction *fadeIn = [CCFadeTo actionWithDuration:0.35f opacity:120];
                CCAction *fadeOut = [CCFadeTo actionWithDuration:0.35f opacity:20];
                CCAction *fadeIn2 = [CCFadeTo actionWithDuration:0.35f opacity:90];
                CCAction *fadeOut2 = [CCFadeTo actionWithDuration:0.35f opacity:50];
                CCSequence *pulseSequence = [CCSequence actions:
                                             [fadeOut copy],
                                             [fadeIn copy],
                                             [fadeOut2 copy],
                                             [fadeIn2 copy],
                                             nil];
                CCRepeatForever *repeats = [CCRepeatForever actionWithAction:pulseSequence];
                [spr runAction:repeats];
            }
        }
        
        
        for (LHSprite* spr in [lh spritesWithTag:TAG_KEY]) {
            spr.color = ccBLACKBLUE;
        }
        
        LHSprite * arrive = [lh spriteWithUniqueName:@"arrive"];
        arrive.color = ccBLUE;
        arrive.opacity = 125;
        
        for (LHBezier* bez in [lh allBeziers]) {
            bez.visible = false;
        }
        NSLog(@"ext %f",[lh returnExtension]);
        if ([lh returnExtension]==480) {
            startupSequence = 1;
        } else {
            NSLog(@"startup = 0");
            startupSequence = 0;
            float ext = [lh returnExtension] *([self selfScreen].size.height/480);
            
            self.position = ccp(-(ext - [self selfScreen].size.height) + 1, self.position.y);
        }
    }
}


-(void) perdedor
{
    if (noSeguir == false) {
    noSeguir = true;
        
        NSMutableArray* starter2 = [[NSMutableArray alloc]init];
        [starter2 addObject:[NSNumber numberWithFloat:remainingSpace.x]];
        [starter2 addObject:[NSNumber numberWithFloat:remainingSpace.y]];
        [starter2 addObject:[NSNumber numberWithInt:1]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter2]
                                                  forKey:[NSString stringWithFormat:@"memory"]];
        
        
    [[SimpleAudioEngine sharedEngine] playEffect:@"photo.mp3"];
      //  [[CCDirector sharedDirector] popScene];
  [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:0.4 scene:[GameScene scene] withColor:ccWHITE]];
    }
}


-(void) ganador {
    
    
    NSMutableArray* starter = [[NSMutableArray alloc]init];
    int ultimoNivel= 100;
    
    
    NSMutableArray* starter2 = [[NSMutableArray alloc]init];
    [starter2 addObject:[NSNumber numberWithFloat:0]];
    [starter2 addObject:[NSNumber numberWithFloat:0]];
    [starter2 addObject:[NSNumber numberWithInt:0]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter2]
                                              forKey:[NSString stringWithFormat:@"memory"]];
    
    
    if (levelUsed == ultimoNivel) {
        NSLog(@"ULTIMO NIVEL");
        [starter addObject:[NSNumber numberWithInt:levelUsed]];
    }
    else {
        NSLog(@"avanza al siguiente");
        [starter addObject:[NSNumber numberWithInt:levelUsed + 1]];
    }
    
    
    
    if (levelUsed == levelHigh) {
        if (levelHigh == ultimoNivel) {
            [starter addObject:[NSNumber numberWithInt:levelHigh]];
        }
        else if (levelHigh == ultimoNivel-1) {
            [starter addObject:[NSNumber numberWithInt:levelHigh+1]];
        }
        else {
            [starter addObject:[NSNumber numberWithInt:levelHigh+2]];
        }
    }
    else     if (levelUsed == levelHigh - 1) {
        if (levelHigh != ultimoNivel) {
            [starter addObject:[NSNumber numberWithInt:levelHigh+1]];
        }
        else {
            [starter addObject:[NSNumber numberWithInt:levelHigh]];
        }
    }
    else {
        [starter addObject:[NSNumber numberWithInt:levelHigh]];
    }
    
    
    int trialWin = 1;
    if (repeat == 0) {trialWin = 2;}
    NSLog(@"repeat WIN %i",repeat);
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter]
                                              forKey:[NSString stringWithFormat:@"data"]];
    
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *arrayData = [currentDefaults objectForKey:[NSString stringWithFormat:@"stars"]];
    NSMutableArray *  arrayStars = [NSKeyedUnarchiver unarchiveObjectWithData:arrayData];
    
    if ([[arrayStars objectAtIndex:levelUsed] intValue]<trialWin) {
        
        [arrayStars replaceObjectAtIndex:levelUsed withObject:[NSNumber numberWithInt:trialWin]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:arrayStars]
                                                  forKey:[NSString stringWithFormat:@"stars"]];
        
    }
    
    
    
    
    
    
    
    
    
    noSeguir = true;
    [timer invalidate];
    timer = nil;
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.4 scene:[GameScene scene] withColor:ccWHITE]];
}


- (void)leftSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer  {
    if (noSeguir == false) {
        
    if (levelUsed != levelHigh) {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.4 scene:[GameScene scene] withColor:ccWHITE]];
        [[SimpleAudioEngine sharedEngine] playEffect:@"ganar.mp3"];
        NSMutableArray* starter = [[NSMutableArray alloc]init];
        [starter addObject:[NSNumber numberWithInt:levelUsed + 1]];
        NSLog(@"next level");
        [starter addObject:[NSNumber numberWithInt:levelHigh]];
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter]
                                                  forKey:[NSString stringWithFormat:@"data"]];
        
        NSMutableArray* starter2 = [[NSMutableArray alloc]init];
        [starter2 addObject:[NSNumber numberWithFloat:0]];
        [starter2 addObject:[NSNumber numberWithFloat:0]];
        [starter2 addObject:[NSNumber numberWithInt:0]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter2]
                                                  forKey:[NSString stringWithFormat:@"memory"]];
        
        noSeguir = true;
        [timer invalidate];
        timer = nil;
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.4 scene:[GameScene scene] withColor:ccWHITE]];
        
        
    } else {[self perdedor];}
    
}}


- (void)rightSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer  {if (noSeguir == false) {
    if (levelUsed != 1) {
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.4 scene:[GameScene scene] withColor:ccWHITE]];
        [[SimpleAudioEngine sharedEngine] playEffect:@"ganar.mp3"];
        NSMutableArray* starter = [[NSMutableArray alloc]init];
        [starter addObject:[NSNumber numberWithInt:levelUsed - 1]];
        NSLog(@"previous level");
        [starter addObject:[NSNumber numberWithInt:levelHigh]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter]
                                                  forKey:[NSString stringWithFormat:@"data"]];
        
        NSMutableArray* starter2 = [[NSMutableArray alloc]init];
        [starter2 addObject:[NSNumber numberWithFloat:0]];
        [starter2 addObject:[NSNumber numberWithFloat:0]];
        [starter2 addObject:[NSNumber numberWithInt:0]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter2]
                                                  forKey:[NSString stringWithFormat:@"memory"]];
        
        noSeguir = true;
        [timer invalidate];
        timer = nil;
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.4 scene:[GameScene scene] withColor:ccWHITE]];
    } else {[self perdedor];}
    
}}



-(void) desaparece:(id)sender data:(b2Body*)data
{
	
	CCSprite *sprite = (CCSprite *) data->GetUserData();
	[self removeChild:sprite cleanup:YES];
	world->DestroyBody(data);
	
}


- (void)showTrackingPath:(CGPoint)inPosition
{
    bool showTrackDot = true ;
    
    float diff_x = ABS(inPosition.x-mPrevTrackPosition.x) ;
    float diff_y = ABS(inPosition.y-mPrevTrackPosition.y) ;
    
    if( ( diff_x < MIN_TRACK_PATH_DIST ) && ( diff_y < MIN_TRACK_PATH_DIST ) )
        showTrackDot = false;
    
    /*
     float floorHeight = (sGame.IsIpad ? IPAD_FLOOR_HEIGTH : FLOOR_HEIGTH);
     
     if(inPosition.y < (floorHeight + self.sprite.contentSize.height))
     showTrackDot = false;
     */
    if(showTrackDot)
    {
        
		// NIVEL ACTUAL
        if(!mTrackPath)
        {
            mTrackPath = [CCSpriteBatchNode batchNodeWithFile:@"trackPath.png"];
            [self addChild:mTrackPath z:5];
        }
        
        CCSprite *track = [CCSprite spriteWithTexture: [mTrackPath texture]];
        track.position  = inPosition;
        track.scale     = [self getSizeOfTrackDot]/2;
        
        CCFadeOut * fade = [CCFadeOut actionWithDuration:.5];
        [track runAction:fade];
        
        
        [mTrackPath addChild:track];
        track.tag = tiros;
        
        mPrevTrackPosition = inPosition ;
        mTrackDotIndex++ ;
        
        mIsTrackAvail = true;
    }
    
}


- (void)clearTrackingPath
{
    
    NSLog(@"CLEAN UP CALLED: TIROS:%i", tiros);
    for (CCSprite* sprite in mTrackPath.children)
    {
        if(sprite.tag==tiros-1)
        {
            [TrackingArray addObject:sprite];
        }
    }
    
    
    NSLog(@"TRACKING ARRAY COUNT:%i", TrackingArray.count);
    
    float t = 0.1;
    for (CCSprite* s in TrackingArray)
    {
        t = t + 0.1;
        
        CCFadeOut* move = [CCFadeOut actionWithDuration:0.5];
        CCCallFunc* callback = [CCCallFuncND actionWithTarget:self selector:@selector(borrar:data:) data:(CCSprite*)s];
        CCSequence* sequence = [CCSequence actions:move, callback, nil];
        [s runAction:sequence];
        
    }
    
    mIsTrackAvail = false;
    mTrackDotIndex = 0;
    
}


-(void)borrar:(id)sender data:(CCSprite*)sp
{
    [sp removeFromParentAndCleanup:YES];
    [TrackingArray removeObject:sp];

}


-(float)getSizeOfTrackDot
{
    float array[4] = { 0.6f, 0.2f, 0.45f } ;
    
    int index  = ( mTrackDotIndex % 3) ; //3 type dots
    
    float scale = array[index] ;
    
    return scale;
}





////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (startupSequence > 0) {
    MAXIMUM_NUMBER_OF_STEPS = 25;

    if (tiros < cantidadDeTirosMaximo)
    {
        following = cupido;
    }
    
    if(tiros>1)
    {
        [self clearTrackingPath];
    }
        if (startupSequence != 4) {
        startupSequence = 2;
        }
        NSLog(@"start = 2");
    }
}



- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (startupSequence > 2) {
        startupSequence = 4;
    if (resetbo) {[self perdedor];}
    else {
        NSLog(@"ENDED");
    
    if (numberOfShoots>0) {
        

       b2Vec2 primary = [following body] -> GetLinearVelocity();
        primary = b2Vec2 (primary.x, 10);
        [following body] -> SetLinearVelocity(primary);
        numberOfShoots--;
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"transe.mp3"];
        
            if (numberOfShoots == 0) {
                following.color = ccWHITE;
            }
        
    } else {
    
    
    
    if (tiros < cantidadDeTirosMaximo) {
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
       
        
		location = [[CCDirector sharedDirector] convertToGL: location];
        location = [self convertToNodeSpace:location];
        
        //memory = [lh createSpriteWithName:@"memory" fromSheet:@"UntitledSheet" fromSHFile:@"items.pshs"];
      //  memory.color = ccBLUE;
       // memory.opacity = 125;
       // [memory transformPosition:movedCircle.position];
        remainingSpace = movedCircle.position;
        
        numberOfShoots = 0;
        if (levelUsed == 34) {numberOfShoots = 1;}
        if (levelUsed == 35) {numberOfShoots = 1;}
        if (levelUsed == 36) {numberOfShoots = 2;}
        if (levelUsed == 37) {numberOfShoots = 1;}
        if (levelUsed == 38) {numberOfShoots = 1;}
        if (levelUsed == 39) {numberOfShoots = 1;}
        if (levelUsed == 40) {numberOfShoots = 1;}
        if (levelUsed == 41) {numberOfShoots = 2;}
        if (levelUsed == 42) {numberOfShoots = 2;}
        if (levelUsed == 43) {numberOfShoots = 1;}
        if (levelUsed == 59) {numberOfShoots = 1;}
        if (levelUsed == 61) {numberOfShoots = 1;}
        if (levelUsed == 96) {numberOfShoots = 1;}
        if (levelUsed == 100){numberOfShoots = 5;}
        takeRotation = true;
        
        LHSprite *arrow = [lh createSpriteWithName:@"ball" fromSheet:@"UntitledSheet" fromSHFile:@"items.pshs"];
        [arrow prepareAnimationNamed:@"ble" fromSHScene:@"design.pshs"];
        [arrow playAnimation];
        ball = arrow;
        for (b2Fixture* f = [ball body]->GetFixtureList(); f; f = f->GetNext())
            
        { f -> SetRestitution(1);
            
        }
        
        if (numberOfShoots == 0) {  arrow.color = ccWHITE;  }
        else {
            arrow.color = ccGREEN;
        }
        [arrow transformPosition: cupido.position];
        
        // JAVIER
        [arrow body]->SetGravityScale(1);
        [arrow body]->SetAngularDamping( 3 );
        [arrow body]->SetAngularVelocity(0);
        //[arrow body]->SetBullet(true);

        [arrow setZOrder:20];
        [arrow body] -> SetLinearVelocity(2*shootImpulse);
        arrow.tag = TAG_ARROW;
        
        [memory stopAllActions];
        [memory runAction:[CCFadeTo actionWithDuration:.4 opacity:0.0f]];
        [movedCircle runAction:[CCFadeTo actionWithDuration:.6 opacity:200.0f]];
        
        // [self dispararFlecha];
        line1.visible = false;
        line2.visible = false;
        line3.visible = false;
        following = arrow;
		
        [[SimpleAudioEngine sharedEngine] playEffect:@"acSound2.mp3"];
        
        tiros++;
                }
            }
        }
    }
    }
}
// on "dealloc" you need to release all your retained objects


- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{

    if (startupSequence > 1) {
    
     if (tiros < cantidadDeTirosMaximo)
     {
    for( UITouch *touch in touches ) {
		
		CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        location = [self convertToNodeSpace:location];
        
        CGPoint vector = ccpSub(cupido.position, location);
        vector = ccp(vector.x/2, vector.y/2);
        
        
        
        CGFloat rotateAngle = -ccpToAngle(vector) +  3.1415926f;
      
        float distanciaLinea = sqrtf(powf(vector.x,2) + powf(vector.y,2));
        
        distanciaLinea = distanciaLinea * 1.4;
        
        float distReal = distanciaLinea;
        
     
        if (distanciaLinea > 75) {
            distanciaLinea = 75;

            float angle = ccpToAngle(vector);
            CGPoint angulate = ccpForAngle(angle);
            vector = ccp(angulate.x * 75, angulate.y * 75);
        }
        else {
            float angle = ccpToAngle(vector);
            CGPoint angulate = ccpForAngle(angle);
            vector = ccp(angulate.x * distanciaLinea, angulate.y * distanciaLinea);
        }
        
        remainingSpace = location;
        
        shootImpulse = b2Vec2 (-vector.x/13.5,-vector.y/13.5);
       
        float estiramientoDelArco = .25f; //VALOR 1 = tan largo como la distancia del touch al cupido
        
        
        
        CGPoint pointNull = ccpForAngle(rotateAngle);
        pointNull = ccp (-pointNull.x * distanciaLinea * estiramientoDelArco, pointNull.y * distanciaLinea * estiramientoDelArco);
        pointNull = ccpSub([cupido position], pointNull);
        
        float floc = (cupido.rotation + 180) * (2 * 3.14159) / 360;
        
        RotateBis = rotateAngle;
        DistanceBis = distanciaLinea;
        
        
        CGPoint pointRight =  ccpForAngle(floc - 3.14159 /2);
        pointRight = ccp (-pointRight.x * 35, pointRight.y * 35);
        pointRight = ccpSub([cupido position], pointRight);
        CGPoint vecRight = ccpSub(pointRight, pointNull);
        float flocRight = ccpToAngle(vecRight);
        float distoRight = sqrtf (powf(vecRight.x, 2) + powf (vecRight.y,2));
        
        CGPoint pointLeft =  ccpForAngle(floc + 3.14159 /2);
        pointLeft = ccp (-pointLeft.x * 35, pointLeft.y * 35);
        pointLeft = ccpSub([cupido position], pointLeft);
        CGPoint vecLeft = ccpSub(pointLeft, pointNull);
        float flocLeft = ccpToAngle(vecLeft);
        float distoLeft = sqrtf (powf(vecLeft.x, 2) + powf (vecLeft.y,2));
        
        rotateAngle = rotateAngle * 360 / (2 * 3.14159) + 180;
        flocRight = -flocRight * 360 / (2 * 3.14159) + 180;
        flocLeft = -flocLeft * 360 / (2 * 3.14159) + 180;
        aproaching = rotateAngle;

        line1.visible = TRUE;
        
        float addup;
        if (distReal > 50) {
            addup = (distReal - 49);
            addup = sqrt(addup) * 2 - 1;
            addup = addup + 49;
        
        }
        else {
            addup = distanciaLinea;
        }
        
        addup = addup* 1.3f;
        
        [line1 setPosition: [cupido position]];
        [line1 setScaleX:addup/8];
        [line1 setScaleY:.2f];
        [line1 setRotation: rotateAngle];
        
        
        
        [line2 setPosition: line1.position];
        [line2 setScaleX:addup/12];
        [line2 setScaleY:.2f];
        [line2 setRotation: rotateAngle];
        
       
        [line3 setPosition: line1.position];
        [line3 setScaleX:addup/16];
        [line3 setScaleY:.2f];
        [line3 setRotation: rotateAngle];
        
        CGPoint min = ccpForAngle(-rotateAngle*2*3.14159/360);
        addup = addup/2 + 8;
        CGPoint movedpos = ccpAdd(line1.position, ccp(addup*min.x, addup * min.y));
        [movedCircle transformPosition:movedpos];
        movedCircle.color = ccBLUE;
        movedCircle.visible = true;
        line1.opacity = 50; line1.color = ccBLUE;
        line2.opacity = 50; line2.color = ccBLUE;
        line3.opacity = 50; line3.color = ccBLUE;
        
        if (memory.opacity == 125.0f) {
            [memory stopAllActions];
            [memory runAction:[CCFadeTo actionWithDuration:1 opacity:40.0f]];
        }
        
        
        if (startupSequence != 4) {
        startupSequence = 3;
        }
            }
        }
    }
}





-(void) toggleMusic
{
    
    gameData.music = !gameData.music;
    gameData.sound = !gameData.sound;
    
    [SimpleAudioEngine sharedEngine].backgroundMusicVolume = gameData.music;
    [SimpleAudioEngine sharedEngine].effectsVolume = gameData.sound;
    
}

- (CGRect) selfScreen {

    
    
    CGFloat a = [UIScreen mainScreen].bounds.size.height;
    CGFloat b = [UIScreen mainScreen].bounds.size.width;
    
    if (a>b) {return CGRectMake(0, 0, b, a);}
    else { return CGRectMake(0, 0, a, b);}
    
    

}

-(void) gotoLevelMenu
{
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[mainScene node] ]];
}

- (void) dealloc
{
	
	NSLog(@"SALIENDO");
    
    [lh release];
    lh = nil;
    
	delete world;
	world = NULL;
	
    delete _contactListener;
	
	[self removeAllChildrenWithCleanup:YES];
	
    [self unscheduleAllSelectors];
    
	[self unschedule: @selector(tick:)];
	[self unschedule: @selector(segundos:)];
    
    
     [myfondito release];
     myfondito=nil;
     
     [superfondo release];
     superfondo = nil;
     [texture1 release];
     [texture2 release];
     
	[super dealloc];
}
@end