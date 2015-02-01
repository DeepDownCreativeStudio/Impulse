//
//  ChapterSelect.m
//

#import "ChapterSelect.h"
#import "CCScrollLayer.h"

#import "MenuScene.h"
#import "GameScene.h"
#import "Level.h"
#import "GameData.h"
#import "GameDataParser.h"
#import "GameCenterManager.h"
#import "SimpleAudioEngine.h"

extern NSMutableArray *worldsArray;
extern GameData *gameData;
extern int Nivel;

@implementation ChapterSelect
@synthesize iPad;

- (void)onBack: (id) sender
{
    
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.3 scene:[MenuScene scene] ]];
    
}

- (void)onSelectChapter:(CCMenuItemImage *)sender 
{ 

        
        NSMutableArray* starter = [[NSMutableArray alloc]init];
        [starter addObject:[NSNumber numberWithInt:sender.tag]];
        [starter addObject:[NSNumber numberWithInt:90]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:starter]
                                                  forKey:[NSString stringWithFormat:@"data"]];
        [[SimpleAudioEngine sharedEngine] playEffect:@"ganar.mp3"];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.4 scene:[GameScene scene] withColor:ccWHITE]];
    
}

- (CCLayer*)layerWithChapterName:(NSString*)chapterName
                   chapterNumber:(int)chapterNumber
                    chapterImage:(NSString*)chapterImage
                            size:(CGSize)size {
    
    CCLayer *layer = [[CCLayer alloc] init];
    
    CCMenuItemImage *image = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat:@"%@.png",chapterImage]
                                                    selectedImage:[NSString stringWithFormat:@"%@.png",chapterImage]
                                                           target:self
                                                         selector:@selector(onSelectChapter:)];
    //image.opacity = 240;
    
    
    /*
     id ojos = [CCScaleBy actionWithDuration:0.5 scale:1.1f];
     id ojos_back = [ojos reverse];
     id hacerojos = [CCRepeatForever actionWithAction: [CCSequence actions: ojos, ojos_back, nil]];
     [image runAction: hacerojos];
     
     */
    
    image.tag = chapterNumber;
    CCMenu *menu = [CCMenu menuWithItems: image, nil];
    [menu alignItemsVertically];
    [layer addChild: menu];
    
    
    // Put a label in the new layer based on the passed chapterName
    CCLabelTTF *layerLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i",chapterNumber]fontName:@"Marker Felt" fontSize:24];
    layerLabel.position =  ccp(image.boundingBox.size.width/2, image.position.y / 2 - 18 );
    //layerLabel.rotation = -3.0f;
    [image addChild:layerLabel];
    
    
    return layer;
}

- (void)addBackButton {
    
    // Create a menu image button for iPhone / iPod Touch
    CCMenuItemImage *goBack = [CCMenuItemImage itemWithNormalImage:@"boton-back.png"
                                                     selectedImage:@"boton-over-small.png"
                                                            target:self
                                                          selector:@selector(onBack:)];
    
    
    goBack.position = ccp(24,24);
    
    CCMenuItemImage *leaderboard = [CCMenuItemImage itemWithNormalImage:@"boton-leaderboard.png" selectedImage:@"boton-over-small.png" target:self selector:@selector(showLeaderBoard)];
    leaderboard.position = ccp(size.width-24,24);
    
    // Add menu image to menu
    CCMenu *back = [CCMenu menuWithItems: goBack, leaderboard, nil];
    
    // position menu in the bottom left of the screen (0,0 starts bottom left)
    back.position = ccp(0, 0);
    
    // Add menu to this scene
    [self addChild: back];
}


-(void)showLeaderBoard
{
	
    //
    [[GameCenterManager sharedGameCenterManager]showLeaderboardForCategory:@"total"];
    
}

- (id)init {
    
    if( (self=[super init]))
    {
        
        self.iPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        size = [CCDirector sharedDirector].winSize;
        
        
        NSMutableArray *capitulosArray = [NSMutableArray arrayWithObjects:@"Chapter 1: Space Run", @"Chapter 2: Air Party", @"Chapter 3: On Fire!", @"Chapter 4: The Storm", @"Chapter 5: The Ice", nil];
        
        NSMutableArray *layers = [NSMutableArray new];
        NSMutableArray *spriteArray =[[NSMutableArray alloc]init];
        
        for( int h = 0; h<200; h++)
        {
            // Create a layer for each of the stages found in Chapters.xml
            CCLayer *layer = [self layerWithChapterName:[NSString stringWithFormat: @"Level %i",h] chapterNumber:h+1 chapterImage:[NSString stringWithFormat:@"back"] size:size];
            [layers addObject:layer];
            
            
        }
        

        
        CCSprite* fondo2 = [CCSprite spriteWithFile:@"fondo1.png"];
        fondo2.position = ccp(size.width/2,size.height/2);
        [self addChild:fondo2 z:0];
        
        /*
                 
        // TOTAL SCORE
        
        int estrellas = 0;
        
        for (World* w in worldsArray)
        {
            
            if(!w.locked)
            {
                
                for (Level* l in w.niveles)
                {
                    estrellas += l.estrellas;
                }
                
            }
            
        }
        
        
        CCSprite* estrella = [CCSprite spriteWithFile:@"estrella.png"];
        [self addChild:estrella z:0];
        estrella.scale = 0.70f;
        [estrella setPosition:ccp(16, size.height-16)];
        
        
		CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Total %i/216", estrellas] fontName:@"Arnold 2.1" fontSize:19 dimensions:CGSizeMake(240,20) hAlignment:kCCTextAlignmentLeft];
		[self addChild:scoreLabel];
        [scoreLabel setPosition:ccp(152, 306)];
        */
        
        // METODO VIEJO
        //
        // Set up the swipe-able layers
        
        CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:layers
                                                            sprites:spriteArray
                                                            widthOffset:([UIScreen mainScreen].bounds.size.height - 108)];
        
         [scroller selectPage:(gameData.selectedChapter-1)];

        
        // METODO NUEVO
        //
        
        /*FGScrollLayer *scroller = [[FGScrollLayer alloc] initWithLayers:layers
         pageSize:CGSizeMake(32,32) pagesOffset:120 visibleRect:CGRectMake( 0.0f, 0.0f, 0.0f, 0.0f)];
         
         */
        [self addChild:scroller];
        
        [scroller release];
        [layers release];
        
        [self addBackButton];
        
    }
    return self;
}



@end
