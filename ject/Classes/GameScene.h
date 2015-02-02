//
//  GameScene.h
//
//  Copyright GameXtar 2010. All rights reserved.
//
//	Javier Asenjo Fuchs
//	http://www.gamextar.com - iPhone Development
//
//

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "MyContactListener.h"
#import "LevelHelperLoader.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.

#define PTM_RATIO [LevelHelperLoader pointsToMeterRatio]
#define NUM_WORLDS 3
#define NUM_LEVELS 18
#define kRADIAL_GRAVITY_FORCE -250.0f

@interface GameScene : CCLayer
{  
	b2World* world;
    MyContactListener *_contactListener;
	b2Body* groundBody;
    b2Fixture *bolaFixture;
    b2Fixture *maloFixture;
	b2Fixture *ventiladorFixture;
    b2Fixture *starFixture;
    b2Fixture *metaFixture;
    b2Fixture *bottomFixture;
    bool noSeguir;
     NSTimer* timer;
    int bolaActual;
    int bolaTotal;
    b2Vec2 gravityForBall;
    
    bool blackout;
    bool first;
    bool locationMove;
    CGPoint futureLocation;
    
    int startupSequence;
    
    
    bool fondoapplied;
    
    NSTimer *timerMalo2;
    NSTimer *timerCalabaza;
    NSTimer *timerBubloder;
    NSTimer *timerVentiladorSwitch;
    NSTimer *timerAragneSwitch;
     NSTimer *timerTeleportAllowed;
    NSTimer *proteccionComienza;
    NSTimer *proteccionTitila;
    NSTimer *proteccionPumpComienza;
    NSTimer *proteccionPumpTitila;
	 NSTimer *timerGravityOff;
     NSTimer *timerBalloon;
    LHSprite *bg;
    LHSprite *bg2;
    CCMenu *menu;
    
    NSArray* spritesRUTOR;
    bool spacer;
    bool balloonPuedeExplotar;
    bool balloonPuedeSerAtrapado;
    bool atrapadoEnBaloon;
    bool bubbleForce;
    bool firstRun;
	bool menuactive;
	bool portal;
	bool gano;
	bool perdio;
    bool broken;
	bool NewRecord;
	BOOL zoomed;
	bool pocion;
    bool calabazaSafe;
    int gravityExtra;

    LHSprite* movedCircle;
    LHSprite* ball;
    
    
    bool teleportAllowed;
    CGPoint teleportPoint;
    
	CGSize _winSize;
	CGFloat cocosAngle;

	
    LHSprite* brillo;
    LHSprite* brilloPump;
	
    //b2Vec2 gravity;
	
	int Tiempo;
    int temperatura;
	
	int Bolas;
	int Stars;

	CCParticleRain	*emitter2;
	CCParticleRain	*emitter3;
	CCParticleRain	*emitter4;

	//CCParticleFire *fuego;
	
	CGPoint puntito;
	
	NSMutableArray *personajes;
	
	
	CCSprite *ojitos;
	CCAction *walkAction;
	CCAction *moveAction;
	
	CCTexture2D	*texture1;
	CCTexture2D	*texture2;
	
	int Star1;
	int Star2;
	int Star3;
	int StarScore;
	int StarHighScore;
	NSString *mensaje;
	
	// ACTIONS
	
	id malo1_expande;
	id malo1_contrae;
	id latir1;
    
    LevelHelperLoader* lh;    
    CGRect worldSize;
    float offsetV, offsetH;

    CGPoint ZB_last_posn;
    
    // FLECHA
    int MAXIMUM_NUMBER_OF_STEPS;        // 4 slow motion
    b2MouseJoint* mouseJoint;

    bool shooting;
    //b2Body* arrowBody;
    b2Body* m_launcherBody;
    b2Body* m_loadedArrowBody;
    std::vector<b2Body *>m_arrowBodies;
    LHSprite *arco;
    LHSprite *palo;
    
    CCSprite *line1;
    CCSprite *line2;
    CCSprite *line3;
    
    LHParallaxNode* parallaxNode;
    
    CCSpriteBatchNode   *mTrackPath;
    
    // TRAYECTORIAS PREVIAS
    
    NSMutableArray *TrackingArray;
    bool            mIsTrackAvail ;
    CGPoint         mPrevTrackPosition;
    int             mTrackDotIndex;
    bool mIsCameraMoving;
    
    int tiros;
    int fuerza;
    
    
    // definiciones nuevas
    float previousRotate;
    bool takeRotation;
    LHSprite * cupido;
    LHSprite * following;
    bool nowToKill;
    LHSprite * kill;
    
    b2Vec2 shootImpulse;
    bool waitingToStop;
    int cantidadDeTirosMaximo;

    bool stop;
    float aproaching;
    float previousScale;
    
    
    float RotateBis;
    float DistanceBis;
    CGPoint remainingSpace;
    int levelUsed;
    int levelHigh;
    LHSprite *memory;
    float memoryX;
    float memoryY;
    int repeat;
    LHSprite* removeLater;
    bool blockRemove;
    int keyCount;
    LHSprite* glass;
    LHSprite *box;
    bool teleportDone;
    int numberOfShoots;
    int tuckpass;
    bool off;
    bool puff;
    int transe;
    
    CGPoint originPoint;
    CGPoint repeatpoint;
    int repeatcounter;
    bool resetbo;
    int repeatAllow;
}

+(id) scene;

-(void) addNewCircle:(CGPoint)p :(CGFloat)radio :(CGFloat)rebote :(NSString*) textura;
-(void) addNewRebote:(CGPoint)p :(CGFloat)radio :(CGFloat)rebote;

-(void) addNewVentilador:(CGPoint)p :(CGFloat)radio :(int)fuerza;

-(void) addBola;

-(void) addNewMalo:(CGPoint)p :(int)angulo :(int)intermitente;
-(void) addNewMalo2:(CGPoint)p :(int)angulo :(CGFloat)intermitente;
-(void) addNewMalo3:(CGPoint)p :(int)angulo :(CGFloat)intermitente;

-(void) addPortal:(CGPoint)p;
-(void) addNewStar:(CGPoint)p :(int)angulo;

-(void) toggleMusic;

-(void) gotoNextLevel;
-(void) replayLevel;
-(void) gotoLevelMenu;
-(void) StartLevel:(NSString*)level;
-(void) setBack: (NSString*) fondo;
-(void) setStars:(int)min :(int)mid :(int)max;

// FLECHA

-(void) loadOneArrow;
-(void) dispararFlecha;
- (void)showTrackingPath:(CGPoint)inPosition;
-(void) dispararFlecha;
- (void)clearTrackingPath;
- (float)getSizeOfTrackDot;
-(void)borrar:(id)sender data:(CCSprite*)sp;


@end