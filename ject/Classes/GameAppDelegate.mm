//
//  AppDelegate.mm
//  Rotate & Roll 2
//
//  Created by Javier on 01/10/12.
//  Copyright Javier 2012. All rights reserved.
//

#import "cocos2d.h"

#import "GameAppDelegate.h"
#import "MenuScene.h"
#import "Appirater.h"
#import "GameData.h"
#import "GameScene.h"
#import "GameDataParser.h"
#import "Level.h"
#import "GameCenterManager.h"
#import "IntroLayer.h"

int Nivel = 1;

GameData *gameData;
NSMutableArray *worldsArray = [[NSMutableArray alloc] init];
GameScene* game;

@implementation MyNavigationController

// The available orientations should be defined in the Info.plist file.
// And in iOS 6+ only, you can override it in the Root View controller in the "supportedInterfaceOrientations" method.
// Only valid for iOS 6+. NOT VALID for iOS 4 / 5.
-(NSUInteger)supportedInterfaceOrientations {
	
	// iPhone only
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
		return UIInterfaceOrientationMaskLandscape;
	
	// iPad only
	return UIInterfaceOrientationMaskLandscape;
}


// Supported orientations. Customize it for your own needs
// Only valid on iOS 4 / 5. NOT VALID for iOS 6.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"IOS 4/5 ROTATION CALLED");
    // Support both landscape orientations
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        return YES;
    }else{
        return NO;
    }
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil) {
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
		[director runWithScene: [IntroLayer scene]];
	}
}

@end

@implementation GameAppController

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];
    
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	[director_ setDisplayStats:NO];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

    
    // If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
    
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	//[sharedFileUtils setiPhone5DisplaySuffix:@"-hd2"];
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// Create a Navigation Controller with the Director
	navController_ = [[MyNavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// for rotation and other messages
	[director_ setDelegate:navController_];
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
    
    // LOAD DATA
    
    gameData = [GameDataParser loadData];
    
    CCLOG(@"Read from XML 'Selected Chapter' = %i", gameData.selectedChapter);
    CCLOG(@"Read from XML 'Selected Level' = %i", gameData.selectedLevel);
    CCLOG(@"Read from XML 'Music' = %i", gameData.music);
    CCLOG(@"Read from XML 'Sound' = %i", gameData.sound);
    CCLOG(@"Read from XML 'Tilt' = %i", gameData.tilt);
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:@"gamedata.sav"];
    
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    
    tmp = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
    //NSLog(@"count %d", tmp.count);
    if(tmp == nil)
    {
        
        NSLog(@"NO HAY NIVELES GUARDADOS");
        
        
        for( int h = 0; h<8; h++)
        {
            
            NSMutableArray *nivelesArray = [[NSMutableArray alloc] init];
            World *world = [[World alloc] init];
            Level *nivel = [[Level alloc] init];
            
            nivel.score = 0;
            nivel.estrellas = 0;
            nivel.locked = FALSE;
            
            
            [nivelesArray insertObject:nivel atIndex:0];
            
            for( int i = 1; i<18; i++)
            {
                Level *nivel = [[Level alloc] init];
                nivel.score = 0;
                nivel.estrellas = 0;
                nivel.locked = TRUE;
                [nivelesArray insertObject:nivel atIndex:i];
            }
            
            world.titulo = [NSString stringWithFormat:@"Mundo %d",h+1];
            
            world.locked = TRUE;
            world.completed = FALSE;
            
            if (h<1)
            {
                world.locked = FALSE;
            }
            
            world.niveles = nivelesArray;
            
            [worldsArray insertObject:world atIndex:h];
            
        }
        
        [NSKeyedArchiver archiveRootObject:worldsArray toFile:fullPath];
        
    }
    else
    {
        worldsArray = tmp;
        
        NSLog(@"MUNDOS %d", worldsArray.count);
        if( worldsArray.count == 4)
        {
            
            NSMutableArray *nivelesArray = [[NSMutableArray alloc] init];
            
            World *tmpworld  = [worldsArray objectAtIndex:2];	// MUNDO ACTUAL
            nivelesArray = tmpworld.niveles;					// NIVELES ACTUALES
            
            Level *ll = [nivelesArray objectAtIndex:17];		// NIVEL ACTUAL
            if(ll.score > 0)
            {
                NSLog(@"Tiene completo el 3");
                gameData.selectedChapter = 4;
                World *tmpworld  = [worldsArray objectAtIndex:3];	// MUNDO ACTUAL
                tmpworld.locked = FALSE;
            }
            
            
            
            // AMPLIAMOS TABLA
            
            for( int h = 4; h<8; h++)
            {
                
                NSMutableArray *niveles2Array = [[NSMutableArray alloc] init];
                World *world = [[World alloc] init];
                Level *nivel = [[Level alloc] init];
                
                nivel.score = 0;
                nivel.estrellas = 0;
                nivel.locked = FALSE;
                
                [niveles2Array insertObject:nivel atIndex:0];
                
                for( int i = 1; i<18; i++)
                {
                    Level *nivel = [[Level alloc] init];
                    nivel.score = 0;
                    nivel.estrellas = 0;
                    nivel.locked = TRUE;
                    [niveles2Array insertObject:nivel atIndex:i];
                }

                
                world.titulo = [NSString stringWithFormat:@"Mundo %d",h+1];
                
                world.locked = TRUE;
                world.completed = FALSE;
                world.niveles = niveles2Array;
                NSLog(@"counting %i",[niveles2Array count]);
                [worldsArray insertObject:world atIndex:h];
                
            }
            
        }
        
        NSLog(@"HAY NIVELES GUARDADOS - MOSTRANDO");
        /*
         
         for (World* w in worldsArray)
         {
         NSLog(@"world titulo %@", w.titulo);
         NSLog(@"world locked %d", w.locked);
         NSLog(@"world completed %d", w.completed);
         
         
         for (Level* l in w.niveles)
         {
         NSLog(@"nivel locked %d", l.locked);
         NSLog(@"nivel score %d", l.score);
         }
         
         }
         */
        
        [worldsArray retain];
        
        
    }
    
	
	return YES;
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
    [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];
	[navController_ release];
	
	[super dealloc];
}
@end

