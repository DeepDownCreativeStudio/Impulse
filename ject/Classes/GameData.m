//
//  GameData.m
//

#import "GameData.h"

@implementation GameData

@synthesize selectedChapter = _selectedChapter; 
@synthesize selectedLevel = _selectedLevel;
@synthesize sound = _sound; 
@synthesize music = _music;
@synthesize tilt = _tilt;

-(id)initWithSelectedChapter:(int)chapter
             selectedLevel:(int)level
                     sound:(BOOL)sound
                     music:(BOOL)music
                     tilt:(BOOL)tilt{
    
    if ((self = [super init])) {
        
        self.selectedChapter = chapter; 
        self.selectedLevel = level; 
        self.sound = sound;  
        self.music = music;
        self.tilt = tilt;
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}

@end



