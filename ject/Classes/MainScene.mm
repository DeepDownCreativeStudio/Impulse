//
//  mainScene.mm
//  presentation
//
//  Created by Bogdan Vladu on 15.03.2011.
//
// Import the interfaces
#import "MainScene.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"

const float32 FIXED_TIMESTEP = 1.0f / 60.0f;
const float32 MINIMUM_TIMESTEP = 1.0f / 600.0f;  
const int32 VELOCITY_ITERATIONS = 8;
const int32 POSITION_ITERATIONS = 8;
const int32 MAXIMUM_NUMBER_OF_STEPS = 25;

// mainScene implementation
@implementation MainScene

-(void)step:(ccTime)dt {
	float32 frameTime = dt;
	int stepsPerformed = 0;
	while ( (frameTime > 0.0) && (stepsPerformed < MAXIMUM_NUMBER_OF_STEPS) ){
		float32 deltaTime = std::min( frameTime, FIXED_TIMESTEP );
		frameTime -= deltaTime;
		if (frameTime < MINIMUM_TIMESTEP) {
			deltaTime += frameTime;
			frameTime = 0.0f;
		}
		world->Step(deltaTime,VELOCITY_ITERATIONS,POSITION_ITERATIONS);
		stepsPerformed++;
	}
	world->ClearForces ();
}


+(id) scene
{
	CCScene *scene = [CCScene node];
	MainScene *layer = [MainScene node];
	[scene addChild: layer];
	return scene;
}

-(id) init {
    
    self = [super init];
    
	if (self) {
 

		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		[[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
        
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -14.0f);
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity);
		
		world->SetContinuousPhysics(true);
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw();
		world->SetDebugDraw(m_debugDraw);
		/*
		uint32 flags = 0;
		flags += b2Draw::e_shapeBit;
		flags += b2Draw::e_jointBit;
		m_debugDraw->SetFlags(flags);	*/	
				
		[self schedule: @selector(tick:) interval:1.0f/60.0f];
		
        //TUTORIAL - loading one of the levels - test each level to see how it works
        lh = [[LevelHelperLoader alloc] initWithContentOfFile:@"M4"];
	        
        //creating the objects
        [lh addObjectsToWorld:world cocos2dLayer:self];
        
        if([lh hasPhysicBoundaries])
            [lh createPhysicBoundaries:world];
        
        if(![lh isGravityZero])
            [lh createGravity:world];

        
        paralaxNode = [lh parallaxNodeWithUniqueName:@"MainParallax"];
        [self retrieveData];
        [self createButtons];
        

        
    }
    	return self;
}

- (void) retrieveData {
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [currentDefaults objectForKey:[NSString stringWithFormat:@"data"]];
    NSData *arrData = [currentDefaults objectForKey:[NSString stringWithFormat:@"stars"]];
    if (data != nil) {
        NSMutableArray *arrayData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        levelUsed = [[arrayData objectAtIndex:0] intValue];
        levelHigh = [[arrayData objectAtIndex:1] intValue];
        self.arrStars = [NSKeyedUnarchiver unarchiveObjectWithData:arrData];
        NSLog(@"retrieve data");
        NSLog(@"arrStars count %i",self.arrStars.count);
        
    } else {
        
        NSMutableArray* starter = [[NSMutableArray alloc]init];
        [starter addObject:[NSNumber numberWithInt:2]];
        [starter addObject:[NSNumber numberWithInt:2]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter]
                                                  forKey:[NSString stringWithFormat:@"data"]];
        levelHigh = 2;
        levelUsed = 1;
        
        NSMutableArray* starterStars = [[NSMutableArray alloc]init];
        for (int i = 0; i < 200; i ++) {
        [starterStars addObject:[NSNumber numberWithInt:0]];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starterStars]
                                                  forKey:[NSString stringWithFormat:@"stars"]];
        self.arrStars = starterStars;
    }
}

- (void) first {
    if (!first) {
        first = true;
    

    for (LHSprite* spr in [lh spritesWithTag:DEFAULT_TAG]) {
        if (![spr.uniqueName isEqualToString:@"bg"]) {
            spr.color = ccBLUE;
            spr.opacity = 125;
        }
    }
        LHSprite * iner = [lh spriteWithUniqueName:@"point_0"];
        float mehr = [self selfScreen].size.height - 480;
        [iner transformPosition:ccp(mehr + iner.position.x -150 * (levelUsed - 1), iner.position.y)];
                        NSLog(@"arrStars count %i",self.arrStars.count);
        for (LHSprite* spr in [lh spritesWithTag:TAG_LOST]) {
            if (spr.zOrder != -2) {
                NSString* numStr = [spr.uniqueName stringByReplacingOccurrencesOfString:@"point_"
                                                                             withString:@""];
                int level = [numStr integerValue];

                int amount = [[self.arrStars objectAtIndex:level+1] intValue];
                if (level < levelHigh) {
                [spr prepareAnimationNamed:[NSString stringWithFormat:@"bol%i",amount] fromSHScene:@"bol.pshs"];
                [spr playAnimation];
                }
            }
            else {
                [spr removeSelf];
            }
        }
        LHSprite* fst = [lh spriteWithUniqueName:@"point_0"];
        int amount = [[self.arrStars objectAtIndex:1] intValue];
            [fst prepareAnimationNamed:[NSString stringWithFormat:@"bol%i",amount] fromSHScene:@"bol.pshs"];
            [fst playAnimation];
    }
    
}

- (void) createButtons {
    
    for (LHSprite*blow in [lh spritesWithTag:DEFAULT_TAG]) {
    float ap = arc4random() % 80 + 40;
    ap = ap /75;
    CCAction *fadeIn = [CCFadeTo actionWithDuration:ap opacity:blow.opacity/2];
    CCAction *fadeOut = [CCFadeTo actionWithDuration:ap opacity:blow.opacity / 4];
    
    CCSequence *pulseSequence = [CCSequence actions:
                                 [fadeIn copy],
                                 [fadeOut copy],
                                 nil];
    
    CCRepeatForever *repeats = [CCRepeatForever actionWithAction:pulseSequence];
    
    [blow runAction:repeats];
    }

    
    
    for (LHSprite* spr in [lh spritesWithTag:TAG_LOST]) {
        if (spr.zOrder != -2) {
            NSString* numStr = [spr.uniqueName stringByReplacingOccurrencesOfString:@"point_"
                                                                          withString:@""];
            int level = [numStr integerValue];
            level++;
            if (level > levelHigh) {
                spr.color = ccGRAY;
            }
        }
    }
    
    for (LHSprite*blow in [lh spritesWithTag:TAG_TELEPORT]) {
        float ap = arc4random() % 80 + 40;
        ap = ap /20;
        CCAction *fadeIn = [CCFadeTo actionWithDuration:ap opacity:blow.opacity];
        CCAction *fadeOut = [CCFadeTo actionWithDuration:ap opacity:blow.opacity / 2];
        
        CCSequence *pulseSequence = [CCSequence actions:
                                     [fadeIn copy],
                                     [fadeOut copy],
                                     nil];
        
        CCRepeatForever *repeats = [CCRepeatForever actionWithAction:pulseSequence];
        
        [blow runAction:repeats];
    }
    
    prefirst = [lh spriteWithUniqueName:@"point_0"].position.x;
    
    numberLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Marker Felt" fontSize:24];
    numberLabel.position = ccp(240, 56);
    numberLabel.color = ccWHITE;
    [self addChild:numberLabel];
}



    
-(void) draw {
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	//glDisable(GL_TEXTURE_2D);
//	glDisableClientState(GL_COLOR_ARRAY);
	//glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	//world->DrawDebugData();
	
	// restore default GL states
//	glEnable(GL_TEXTURE_2D);
//	glEnableClientState(GL_COLOR_ARRAY);
//	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}

-(void) tick: (ccTime) dt
{
	[self step:dt];
    
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) 
        {
			CCSprite *myActor = (CCSprite*)b->GetUserData();
            
            if(myActor != 0)
            {
                myActor.position = [LevelHelperLoader metersToPoints:b->GetPosition()];
                myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());		
            }
            
        }	
	}
    
    
    
    LHSprite*fst = [lh spriteWithUniqueName:@"point_0"];
    LHSprite*lst = [lh spriteWithUniqueName:@"point_99"];
    
    //BOLITAS
    
    float highestOp = 0;
    LHSprite* spriteOp;
    
    for (LHSprite*follow in [lh spritesWithTag:TAG_LOST]) {
    
        follow.position = ccp(follow.position.x - prefirst + fst.position.x, follow.position.y);
        
         if (follow.position.x > -200 && follow.position.x < 730) {
        
        float dimer = [self selfScreen].size.height / 2 - follow.position.x;
             if (dimer<0) {dimer = -dimer;}
        dimer = (dimer / ([self selfScreen].size.height / 2)) * 125;
        if (dimer> 125) {dimer = 125;}
        dimer = 255 - dimer;
        follow.opacity = dimer;
        if (follow.zOrder == -2) {follow.scaleY = dimer / 255 + .55;
            follow.opacity = follow.opacity / 1.5f;}
        else {follow.scale = dimer / 255 + .55;
        
            if (follow.opacity>highestOp) {highestOp = follow.opacity; spriteOp = follow;}
        }
        }
    }
    
    float dimer = [self selfScreen].size.height / 2 - fst.position.x;
    if (dimer<0) {dimer = -dimer;}
    dimer = (dimer / ([self selfScreen].size.height / 2)) * 125;
    if (dimer> 125) {dimer = 125;}
    dimer = 255 - dimer;
    fst.opacity = dimer;
    fst.scale = dimer / 255 + .55;
     if (fst.opacity>highestOp) {spriteOp = fst;}
    
    float newOp = spriteOp.opacity - 220;
    if (newOp < 0) {newOp = 0;}
    newOp = newOp * 7;
    
    numberLabel.position = ccp (spriteOp.position.x, numberLabel.position.y);
    numberLabel.opacity = newOp;
    NSString* numStr = [spriteOp.uniqueName stringByReplacingOccurrencesOfString:@"point_"
                                                                  withString:@""];
    int nextLevel = [numStr integerValue];
    nextLevel++;
    [numberLabel setString:[NSString stringWithFormat:@"%i",nextLevel]];
    if (nextLevel<= levelHigh) {numberLabel.color = ccWHITE;}
    else {numberLabel.color = ccYELLOW;}
    
    //CUADRADOS
    
    for (LHSprite*follow in [lh spritesWithTag:DEFAULT_TAG]) {
        
        follow.position = ccp(follow.position.x - prefirst + fst.position.x, follow.position.y);
        if (follow.position.x > -200 && follow.position.x < 730) {
        float dimer = [self selfScreen].size.height / 2 - follow.position.x;
        dimer = (dimer / ([self selfScreen].size.height / 2)) * 30;
        if (dimer> 30) {dimer = 30;}
            follow.rotation = dimer;
            [follow resumeSchedulerAndActions];
        }
        else {
            [follow pauseSchedulerAndActions];
        }
    }
    
    //SWIPE

    
    if (fst.position.x > [self selfScreen].size.height / 2) {
        
        float vel = [fst body] -> GetLinearVelocity().x;
        vel = vel * 9 - (fst.position.x - [self selfScreen].size.height / 2);
        vel = vel / 15;
        
        for (LHSprite*but in [lh spritesWithTag:TAG_INVISIBLE]) {
            [but body] -> SetLinearVelocity(b2Vec2(vel, 0));
            
        }
    
    }
    
    else if (lst.position.x < [self selfScreen].size.height / 2) {
        
        
        
        float vel = [fst body] -> GetLinearVelocity().x;
        vel = vel * 9 - (lst.position.x - [self selfScreen].size.height / 2);
        vel = vel / 15;
        
        for (LHSprite*but in [lh spritesWithTag:TAG_INVISIBLE]) {
            [but body] -> SetLinearVelocity(b2Vec2(vel, 0));
            
        }
        
    }
    
    else {
    
        float swap;
        swap =[fst body] -> GetLinearVelocity().x * .95;
        
        
        float dist = spriteOp.position.x - [self selfScreen].size.height / 2;
        if (dist < 0) {dist = - dist;}
        if (dist>=0 && [self selfScreen].size.height != 480) {switched = true;}
        if (dist>20 && [self selfScreen].size.height == 480) {switched = true;}
        if (swap<0&&swap>-10 && switched) {
            LHSprite* forth;
            
            if (spriteOp.position.x + 5 >[self selfScreen].size.height / 2) {
                forth = spriteOp;
            }
            else {
     
                NSString* numStr = [spriteOp.uniqueName stringByReplacingOccurrencesOfString:@"point_"
                                                                                  withString:@""];
                int nextLevel = [numStr integerValue];
                nextLevel++;
                forth = [lh spriteWithUniqueName:[NSString stringWithFormat:@"point_%i", nextLevel]];
            }
            float vel = forth.position.x - [self selfScreen].size.height / 2;
            swap = -.1 * vel;
        }
        
        if (swap>0&&swap<10&& switched) {
            LHSprite* forth;
            
            if (spriteOp.position.x - 5 <[self selfScreen].size.height / 2) {
                forth = spriteOp;
            }
            else {
                
                NSString* numStr = [spriteOp.uniqueName stringByReplacingOccurrencesOfString:@"point_"
                                                                                  withString:@""];
                int nextLevel = [numStr integerValue];
                nextLevel--;
                forth = [lh spriteWithUniqueName:[NSString stringWithFormat:@"point_%i", nextLevel]];
            }
            float vel = forth.position.x - [self selfScreen].size.height / 2;
            swap = -.1 * vel;
        }
        else {
            switched = false;
        }
         

        
        [fst body] -> SetLinearVelocity(b2Vec2(swap, 0));
        swap = -swap + 14;
        if (swap<1) {swap = 1;}
        [paralaxNode setSpeed:swap];
    }
    
    prefirst = fst.position.x;
    

    
    [self first];
    
}
//FIX TIME STEPT<<<<<<<<<<<<<<<----------------------

////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{   act = true;
    
    for( UITouch *touch in touches ) {
		
		CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        location = [self convertToNodeSpace:location];
        pretouch = location.x;
        
    }
    
}


////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    act = false;
    
    for( UITouch *touch in touches ) {
		
		CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        location = [self convertToNodeSpace:location];
        
        float swap = location.x - pretouch;
    
        pretouch = location.x;
 
        for (LHSprite*but in [lh spritesWithTag:TAG_INVISIBLE]) {
            [but body] -> SetLinearVelocity(b2Vec2(swap, 0));
        
        }
        
    }
}
////////////////////////////////////////////////////////////////////////////////
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (act) {
    
    for( UITouch *touch in touches ) {
		
		CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        location = [self convertToNodeSpace:location];

        for (LHSprite*node in [lh spritesWithTag:TAG_LOST]) {
            if (node.zOrder != -2) {
                
                if (CGRectContainsPoint([node boundingBox],location)) {
                    NSString* numStr = [node.uniqueName stringByReplacingOccurrencesOfString:@"point_"
                                                                                  withString:@""];
                    int nextLevel = [numStr integerValue];
                    nextLevel++;
                    NSLog(@"CHANGE TO %i, highest level achieved %i", nextLevel, levelHigh);
                    if (nextLevel<=levelHigh) {
                    [self goTo:nextLevel];
                    }
                    else {
                     [[SimpleAudioEngine sharedEngine] playEffect:@"transe.mp3"];
                    }
                        
                }
            }
        }
        
        if (CGRectContainsPoint([[lh spriteWithUniqueName:@"point_0"] boundingBox],location)) {
            
            [self goTo:1];
            NSLog(@"CHANGE TO 1");
        }
    }
    }
}

- (CGRect) selfScreen {
    
    
    
    CGFloat a = [UIScreen mainScreen].bounds.size.height;
    CGFloat b = [UIScreen mainScreen].bounds.size.width;
    
    if (a>b) {return CGRectMake(0, 0, b, a);}
    else { return CGRectMake(0, 0, a, b);}
    
    
    
}

-(void) goTo :(int) change {

    NSMutableArray* starter = [[NSMutableArray alloc]init];
    [starter addObject:[NSNumber numberWithInt:change]];
    [starter addObject:[NSNumber numberWithInt:levelHigh]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter]
                                              forKey:[NSString stringWithFormat:@"data"]];
     [[SimpleAudioEngine sharedEngine] playEffect:@"ganar.mp3"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.4 scene:[GameScene scene] withColor:ccWHITE]];
}
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	// static float prevX=0, prevY=0;
	
	//#define kFilterFactor 1.0f
	
    float pi = 3.14159265589793f;
    
	// float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	// float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
    
	float accelX = (float) acceleration.x;
	float accelY = (float) acceleration.y;
    
    double currentRawReading = atan2(accelY, accelX);
    currentRawReading = currentRawReading * 180/pi;
    //NSLog(@"VALOR %f", currentRawReading);
    
    
    //	prevX = accelX;
    //	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
    
	// 0.5
	//
	//
	
	if (!((accelX<0.05 and accelX > -0.05) and (accelY<0.25 and accelY > -0.25))) 
	{
		b2Vec2 gravity( -accelX *-24, accelY *24);

	}
    
    CGFloat RotateAngle = -ccpToAngle(ccp(-accelX * 22, accelY * 22));
    RotateAngle = CC_RADIANS_TO_DEGREES(RotateAngle);
    [ball setRotation:RotateAngle];
	
}


-(void) retrieveRequiredObjects {
        ball = [lh spriteWithUniqueName: @"ball"]; 
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    
    if(nil != lh)
        [lh release];

	delete world;
	world = NULL;
	
  	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
////////////////////////////////////////////////////////////////////////////////