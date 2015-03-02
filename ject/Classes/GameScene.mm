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


@implementation GameScene

+(id) scene
{
    CCScene *scene = [CCScene node];
    GameScene *Gamelayer = [GameScene node];
    [scene addChild: Gamelayer z:1];
    return scene;
    
}

-(id) init
{
	if( (self=[super init]))
	{
        
        [super init];


		_winSize = [[CCDirector sharedDirector] winSize];
        
        
        
        [self levelInitialSetup];
        [self circleMemoryPosition];
        [self setUpVariablesToDefaultValue];
        [self StartLevel:[NSString stringWithFormat:@"J%i",levelUsed]];
        [self setUpBackground];
        [self setUpKeys];
        [self addGestureRecognizer];
        
        
		[self schedule: @selector(tick:)];
        

    }
	return self;
}

- (void) setUpVariablesToDefaultValue {

    self.touchEnabled = YES;
    firstRun = true;
    blockRemove = true;
    locationMove = false;
    fondoapplied = true;
    noSeguir = false;
    isPaused=FALSE;
    TrackingArray =[[NSMutableArray alloc]init];
    cocosAngle = 0;
    self.rotation = 0;
    Bolas=0;
    Stars=0;
    gano=false;
    perdio=false;
    portal=false;

    locationMove = false;
    teleportAllowed = true;
    
    shooting = false;
    tiros = 0;
    fuerza = 0;
    MAXIMUM_NUMBER_OF_STEPS = 25;
    cantidadDeTirosMaximo = 1;
    
}

#pragma mark Initial Setup

- (void) setUpKeys {

    keyCount = 0;
    NSArray* keys = [lh spritesWithTag:TAG_KEY]; {
        for (LHSprite* spr in keys) {
            spr = spr;
            keyCount++;
        }}

}

- (void) setUpBackground {

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
    bg.opacity = 255;
    bg.tag = 10;
    
    menu = [CCMenu menuWithItems:nil];
    
    
    CCMenuItemImage *but = [CCMenuItemImage itemWithNormalImage:@"back.png" selectedImage:@"backps.png" target:self                                       selector:@selector(back)];
    but.position = ccp (-215,136);
    [menu addChild:but];
    [self addChild:menu];

}

- (void) addGestureRecognizer {

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
    
    UISwipeGestureRecognizer *downRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(restart)];
    downRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [downRecognizer setNumberOfTouchesRequired:2];
    [[[CCDirector sharedDirector] view]addGestureRecognizer:downRecognizer];
    [downRecognizer release];
    
    UISwipeGestureRecognizer *uprecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoLevelMenu)];
    uprecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [uprecognizer setNumberOfTouchesRequired:2];
    [[[CCDirector sharedDirector] view]addGestureRecognizer:uprecognizer];
    [uprecognizer release];
}

- (void) restart {
[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.4 scene:[GameScene scene] withColor:ccWHITE]];
}

- (void) levelInitialSetup {

    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"data"]];
    
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

}

- (void) circleMemoryPosition {

    NSData *dataMem = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"memory"]];
    
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
    
}

- (void) back
{
    if (noSeguir == false)
    {
        noSeguir = true;
[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.4 scene:[MainScene scene] withColor:ccWHITE]];
        [[SimpleAudioEngine sharedEngine] playEffect:@"photo.mp3"];
    }
}

#pragma mark StartLevel

-(void) StartLevel:(NSString*) level
{

	

	// Define the gravity vector.
	b2Vec2 gravity;
	gravity.Set(0.0f, -14.0f);
    gravityForBall = gravity;
    broken = false;
    

    
	world = new b2World(gravity);
	world->SetContinuousPhysics(true);

	b2BodyDef groundBodyDef;
	
	groundBodyDef.position.Set(0, 0);

    lh = [[LevelHelperLoader alloc] initWithContentOfFile:level];
    
    [lh addObjectsToWorld:world cocos2dLayer:self];
    
 
    [lh createPhysicBoundaries:world];
  

    CGRect rect = [self selfScreen];
    rect = CGRectMake(0, 0, rect.size.height, rect.size.width);
    worldSize = rect;
    
    
    offsetH = (_winSize.width/2/self.scale);
    offsetV = (_winSize.height/2/self.scale);
    
    _contactListener = new MyContactListener();
	world->SetContactListener(_contactListener);
    
    line1 = [CCSprite spriteWithFile:@"linea.png"];
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
    
    box = [lh spriteWithUniqueName:@"box"];
    if (box!=nil) {
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



-(void) first {
    
    if (first) {return;}
        
        first = true;
        
        movedCircle  = [lh createSpriteWithName:@"memory" fromSheet:@"UntitledSheet" fromSHFile:@"items.pshs"];
        movedCircle.color = ccBLUE;
        movedCircle.opacity = 125;
        movedCircle.visible = false;
    
    
        for (LHSprite* spr in [lh spritesWithTag:TAG_INVISIBLE]) {
            spr.opacity = 0;
        }

        for (LHSprite* spr in [lh spritesWithTag:DEFAULT_TAG]) {
            spr.color = ccBLUE;
            spr.opacity = 125;
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
            if (puff) {str = [NSString stringWithFormat:@"galaxy.plist"];}
            else {str = [NSString stringWithFormat:@"galaxyout.plist"];}
            
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
    
        if ([lh returnExtension]==480) {
            startupSequence = 1;
        } else {
            
            startupSequence = 0;
            float ext = [lh returnExtension] *([self selfScreen].size.height/480);
            
            self.position = ccp(-(ext - [self selfScreen].size.height) + 1, self.position.y);
        }
    
    
}


#pragma mark Contact

-(void)afterStep {
    std::vector<b2Body *>toDestroy;
    std::vector<MyContact>::iterator pos;
	
    for(pos = _contactListener->_contacts.begin(); pos != _contactListener->_contacts.end(); ++pos)
    {
        
        if (perdio || gano) {break;}
        
        MyContact contact = *pos;
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL)
        {
            LHSprite *spriteA = (LHSprite *) bodyA->GetUserData();
            LHSprite *spriteB = (LHSprite *) bodyB->GetUserData();
            LHSprite *spriteBall;
            LHSprite *spriteOther;
            
            if (spriteA.tag == TAG_ARROW || spriteB.tag == TAG_ARROW) {
            if (spriteA.tag == TAG_ARROW) { spriteBall = spriteA; spriteOther = spriteB;}
            if (spriteB.tag == TAG_ARROW) { spriteBall = spriteB; spriteOther = spriteA;}
            
            
            
            switch (spriteOther.tag) {
                case DEFAULT_TAG:
                    [self defaultContactWithSprite:spriteOther];
                    break;
                    
                case TAG_KEY:
                    [self keyContactWithSprite:spriteOther];
                    break;
                    
                case TAG_BROKEN:
                    [self glassContactWithSprite:spriteOther];
                    break;
                    
                case TAG_TELEPORT:
                    [self teleportContactWithSprite:spriteOther];
                    break;
                    
                case TAG_WIN: {
                    b2Fixture * fixture2 = contact.fixtureA;
                    bool canWin = fixture2 -> IsSensor();
                    canWin? [self winContactWithSprite:spriteOther] : [self falseWinContactWithSprite:spriteOther];
                    break;
                }
                    
                default:
                    break;
            }
                
            }
        
        }
    }
}

- (void) responseToContactWithBetweenBodyA:(b2Body*) bodyA bodyB:(b2Body*) bodyB {



}

- (void) defaultContactWithSprite: (LHSprite*) spriteA {
    LHSprite* spriteB = ball;
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

}

- (void) keyContactWithSprite: (LHSprite*) spriteA {
    LHSprite* spriteB = ball;
    {
        float bee = [spriteA body] -> GetGravityScale();
        
        if (bee!=278) {
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"door.mp3"];
            keyCount = keyCount - 1;
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
}

- (void) glassContactWithSprite: (LHSprite*) spriteA {
    LHSprite* spriteB = ball;
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
}

- (void) teleportContactWithSprite: (LHSprite*) spriteA {
    LHSprite* spriteB = ball;
    {
        if (noSeguir == false) {
            float g = [spriteA body] -> GetGravityScale();
            if (g != 0) {
                
                
                
                LHSprite* teleport;
                if ([spriteA.uniqueName isEqualToString:@"teleport1"]){
                    
                    teleport = [lh spriteWithUniqueName:@"teleport2"];
                }
                if ([spriteA.uniqueName isEqualToString:@"teleport2"]){
                    
                    teleport = [lh spriteWithUniqueName:@"teleport1"];
                }
                if ([spriteA.uniqueName isEqualToString:@"teleport3"]){
                    
                    teleport = [lh spriteWithUniqueName:@"teleport4"];
                }
                if ([spriteA.uniqueName isEqualToString:@"teleport4"]){
                    
                    teleport = [lh spriteWithUniqueName:@"teleport3"];
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
    
}

- (void) falseWinContactWithSprite: (LHSprite*) spriteA {
    
        LHSprite* spriteB = ball;
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

- (void) winContactWithSprite: (LHSprite*) spriteA {

    if (noSeguir) {return;}
    if (timer) {return;}
    
    timer = [[NSTimer scheduledTimerWithTimeInterval:.7 target:self selector:@selector(ganador) userInfo:nil repeats:NO] retain];
    
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
    
}


- (void) gameLost {

    following = cupido;
    [ball removeSelf];
    if (tiros == cantidadDeTirosMaximo) {
        
        CCSprite* bobo = [CCSprite spriteWithFile:@"reset.png"];
        bobo.position = ccp(-self.position.x + [self selfScreen].size.height/2,160);
        [self addChild:bobo z:1000];
        bobo.opacity = 0;
        [bobo runAction:[CCFadeTo actionWithDuration:1.5 opacity:160]];
        resetbo = true;
        
    }
    
}

#pragma mark Update Actions

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
    
    if (tuckpass>0) {
        tuckpass--;
    }
    
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
    }
    
    if (following.tag == TAG_ARROW)
    {
 
       b2Body *arrowBody = following.body;

        b2Vec2 arrowTailPosition = arrowBody->GetWorldPoint( b2Vec2( -0, 0 ) );
      
        [self showTrackingPath: CGPointMake(arrowTailPosition.x*PTM_RATIO,arrowTailPosition.y*PTM_RATIO)];
    
        [self checkBall];
        
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
    
    }
    [self moveBackground];
    [self first];
    
}

- (void) moveBackground {

    
    [bg transformPosition:ccp(-self.position.x + [self selfScreen].size.height/2, bg.position.y)];
    [bg2 transformPosition:ccp(-self.position.x + [self selfScreen].size.height/2, bg.position.y)];
    [menu setPosition:ccp(-self.position.x + [self selfScreen].size.height/2, menu.position.y)];

}
- (void) checkBall {
    
    if (ball) {
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
        
        
        BOOL bottomLost = ball.position.y<0;
        BOOL leftLost = ball.position.x<0;
        BOOL topLost = ball.position.y>[self selfScreen].size.width;
        BOOL rightLost = ball.position.x > ext;
        if (bottomLost||leftLost||topLost||rightLost) {
            [self gameLost];
        }
        
    }
    
    
    
    
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

#pragma mark End Level

-(void) perdedor
{
    if (noSeguir == false) {
    noSeguir = true;
        
        NSMutableArray* starter2 = [[[NSMutableArray alloc]init] autorelease];
        [starter2 addObject:[NSNumber numberWithFloat:remainingSpace.x]];
        [starter2 addObject:[NSNumber numberWithFloat:remainingSpace.y]];
        [starter2 addObject:[NSNumber numberWithInt:1]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter2]
                                                  forKey:[NSString stringWithFormat:@"memory"]];
        
        
    [[SimpleAudioEngine sharedEngine] playEffect:@"photo.mp3"];
  [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.4 scene:[GameScene scene] withColor:ccWHITE]];
    }
}


-(void) ganador {
    
    
    NSMutableArray* starter = [[[NSMutableArray alloc]init] autorelease];
    int ultimoNivel= 100;
    
    
    NSMutableArray* starter2 = [[[NSMutableArray alloc]init] autorelease];
    [starter2 addObject:[NSNumber numberWithFloat:0]];
    [starter2 addObject:[NSNumber numberWithFloat:0]];
    [starter2 addObject:[NSNumber numberWithInt:0]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter2]
                                              forKey:[NSString stringWithFormat:@"memory"]];
    
    
    if (levelUsed == ultimoNivel) {
        [starter addObject:[NSNumber numberWithInt:levelUsed]];
    }
    else {
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





-(void) desaparece:(id)sender data:(b2Body*)data
{
	
	CCSprite *sprite = (CCSprite *) data->GetUserData();
	[self removeChild:sprite cleanup:YES];
	world->DestroyBody(data);
	
}


#pragma mark Tracking Path

- (void)showTrackingPath:(CGPoint)inPosition
{
    bool showTrackDot = true ;
    
    float diff_x = ABS(inPosition.x-mPrevTrackPosition.x) ;
    float diff_y = ABS(inPosition.y-mPrevTrackPosition.y) ;
    
    if( ( diff_x < MIN_TRACK_PATH_DIST ) && ( diff_y < MIN_TRACK_PATH_DIST ) )
        showTrackDot = false;

    if(showTrackDot)
    {
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
    for (CCSprite* sprite in mTrackPath.children)
    {
        if(sprite.tag==tiros-1)
        {
            [TrackingArray addObject:sprite];
        }
    }
    
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

#pragma mark Touches Actions
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    for( UITouch *touch in touches ) {
        CGPoint location = [touch locationInView: [touch view]];
        
        
        location = [[CCDirector sharedDirector] convertToGL: location];
        location = [self convertToNodeSpace:location];
        originPoint = location;
    }
    
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
    }
}



- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (startupSequence > 2) {
        startupSequence = 4;
    if (resetbo) {[self perdedor];}
    else {
    
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

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{

    if (startupSequence > 1) {
    
     if (tiros < cantidadDeTirosMaximo)
     {
    for( UITouch *touch in touches ) {
		
		CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        location = [self convertToNodeSpace:location];
        
        CGPoint vector = ccpSub(originPoint, location);
        vector = ccp(vector.x/2, vector.y/2);
        
        
        
        CGFloat rotateAngle = -ccpToAngle(vector);
      
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
        
        shootImpulse = b2Vec2 (vector.x/13.5,vector.y/13.5);
       
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

#pragma mark Swipe Actions


- (void)leftSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer  {
    if (noSeguir == false) {
        
        if (levelUsed != levelHigh) {
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"ganar.mp3"];
            NSMutableArray* starter = [[[NSMutableArray alloc]init] autorelease];
            [starter addObject:[NSNumber numberWithInt:levelUsed + 1]];
            [starter addObject:[NSNumber numberWithInt:levelHigh]];
            
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter]
                                                      forKey:[NSString stringWithFormat:@"data"]];
            
            NSMutableArray* starter2 = [[[NSMutableArray alloc]init] autorelease];
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
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"ganar.mp3"];
        NSMutableArray* starter = [[[NSMutableArray alloc]init] autorelease];
        [starter addObject:[NSNumber numberWithInt:levelUsed - 1]];
        [starter addObject:[NSNumber numberWithInt:levelHigh]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter]
                                                  forKey:[NSString stringWithFormat:@"data"]];
        
        NSMutableArray* starter2 = [[[NSMutableArray alloc]init] autorelease];
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


#pragma mark Other: Processing

-(void) reactivate
{
    
    NSArray* keys = [lh spritesWithTag:TAG_TELEPORT]; {
        for (LHSprite* spr in keys) {
            [spr body] -> SetGravityScale(1);
        }}
}


- (CGRect) selfScreen {

    
    
    CGFloat a = [UIScreen mainScreen].bounds.size.height;
    CGFloat b = [UIScreen mainScreen].bounds.size.width;
    
    if (a>b) {return CGRectMake(0, 0, b, a);}
    else { return CGRectMake(0, 0, a, b);}
    
    

}

-(void) gotoLevelMenu
{
[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.4 scene:[MainScene scene] withColor:ccWHITE]];
}

- (void) dealloc
{

    for (LHBezier* bez in [lh allBeziers]) {
        [bez removeSelf];
    }
    
    
    [[CCDirector sharedDirector] purgeCachedData];
    
    [lh release];
    lh = nil;
    
	delete world;
	world = NULL;
	
    delete _contactListener;
	
	[self removeAllChildrenWithCleanup:YES];
	
    [self unscheduleAllSelectors];
    
	[self unschedule: @selector(tick:)];
    
    
    
     [myfondito release];
     myfondito=nil;
     
     [superfondo release];
     superfondo = nil;
     [texture1 release];
     [texture2 release];
     
	[super dealloc];
}
@end