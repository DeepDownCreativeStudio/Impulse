//
//  GameScene.mm
//
//  Copyright GameXtar 2010. All rights reserved.
//
//	info@gamextar.com
//	http://www.gamextar.com - iPhone Development 
//
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"

@class GameScene;

@interface GameHUD : CCLayer
{
  GameScene* game;
  CGSize size;

  CCSprite * pauseButton;
  CCSprite * playButton;
  CCSprite * soundButton;
  CCSprite * nivelButton;
  CCSprite * fadeSprite;
	
  CCSprite * brujulaSprite;
  CCSprite * placa;
  CCMenu   * menu;
	
  CCSprite * helpSprite;
  CCLabelTTF *helpLabel;
  CCLabelTTF *pausaLabel;

	
  CCSprite * helpButton;
  CGRect pauseButtonRect;
  CGRect playButtonRect;
  CGRect replayButtonRect;
  CGRect levelButtonRect;
  CGRect soundButtonRect;
  CGRect nextButtonRect;
  CGRect helpButtonRect;

  CCLabelTTF * placaLabel;

  CCLabelBMFont * levelLabel;
  CCLabelBMFont * scoreLabel;
	
  int currentPercentage;
  int oldScore;
    
	bool ShowingHelp;
	bool ShowingPlaca;

}

@property (nonatomic, retain) CCSprite *pauseButton;

+ (GameHUD *)sharedManager;
- (void) setGame: (GameScene*)game;

- (void) showHUD;
- (void) hideHUD;
- (void) release;

- (void) setLevelLabel:(NSString * ) value;
- (void) updateScore:(NSString * ) value;
 
- (void) showPlaca:(NSString*)mensaje :(NSString*)nivel :(NSString*)score :(NSString*)record :(BOOL)gano :(int) estrellas_best :(int) estrellas_score :(bool)newrecord;
- (void) hidePlaca;

- (void) showHelp;

- (void) setLevelComplete: (int) value;

@end
