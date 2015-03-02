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

@end

@implementation GameAppController

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initialize];
		return YES;
}

- (void) initialize {
    
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
    
    [director_ runWithScene: [IntroLayer scene]];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"UnlimitedBalls"];
    
    NSDate* lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastUsedDate"];
    
    if ([self simpleDateForDate:lastDate].timeIntervalSince1970 != [self simpleDateForDate:[NSDate date]].timeIntervalSince1970 		) {
    
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUsedDate"];

}

- (NSDate*) simpleDateForDate: (NSDate*) date {

    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* components = [calendar components:flags fromDate:date];
    
    NSDate* dateOnly = [calendar dateFromComponents:components];

    return dateOnly;
    
}


- (void) resetView {

    [self initialize];
    
    
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

