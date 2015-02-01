//
//  LHCuttingEngineMgr.h
//  LevelHelperExplodingSprites
//
//  Created by Bogdan Vladu on 3/10/12.
//  Copyright (c) 2012 Bogdan Vladu. All rights reserved.
//
#import "lhConfig.h"

#ifdef LH_USE_BOX2D
#include "Box2D.h"
#include <vector>
#import "cocos2d.h"
@class LHSprite;
@class LHJoint;

@interface LHCuttingEngineMgr : CCNode{
    std::vector<CGPoint> explosionLines;
    NSMutableSet* spritesPreviouslyCut;

#if COCOS2D_VERSION >= 0x00020000
    CCGLProgram *mShaderProgram;
	GLint		mColorLocation;
#endif

}

+(LHCuttingEngineMgr*) sharedInstance;

//returns all the sprites that were generated by the last cut action.
//calling this method makes LHCuttingEngineMgr to not retain the sprites anymore
-(NSArray*)sprites;

//removed all cut sprites from the world
-(void)destroyAllPrevioslyCutSprites;


//will triangulate only fixture under point - all other fixtures in the body will remain the same
-(void) splitSprite:(LHSprite *)oldSprite atPoint:(CGPoint)location;

//will triangulate all fixtures based on your decision
//will not create bodies that have mass smaller then mass - this will improve performance
//usually mass smaller then 0.04 - 0.06 can be ignore - play with this value until it suit your needs
-(void) splitSprite:(LHSprite *)oldSprite 
                atPoint:(CGPoint)location 
 triangulateAllFixtures:(bool)triangulate
      ignoreSmallerMass:(float)mass;


-(void)cutFirstSpriteIntersectedByLine:(CGPoint)lineA 
                                 lineB:(CGPoint)lineB
                             fromWorld:(b2World*)world;

-(void)cutFirstSpriteWithTag:(int)tag
           intersectedByLine:(CGPoint)lineA 
                       lineB:(CGPoint)lineB
                   fromWorld:(b2World*)world;

-(void)cutSprite:(LHSprite*)oldSprite
           withLineA:(CGPoint)lineA
               lineB:(CGPoint)lineB;

-(void)cutAllSpritesIntersectedByLine:(CGPoint)lineA
                                lineB:(CGPoint)lineB
                            fromWorld:(b2World*)world;

-(void)cutAllSpritesWithTag:(int)tag
          intersectedByLine:(CGPoint)lineA
                      lineB:(CGPoint)lineB
                  fromWorld:(b2World*)world;


-(void)cutSpritesFromPoint:(CGPoint)point
                  inRadius:(float)radius
                      cuts:(int)numberOfCuts //must be even
                 fromWorld:(b2World*)world;

//because of the randomness of this method sometimes sprites might be cut more then its desired
-(void)cutSpritesWithTag:(int)tag
               fromPoint:(CGPoint)point
                inRadius:(float)radius
                    cuts:(int)numberOfCuts //must be even
                fromWorld:(b2World*)world;

-(void) explodeSpritesInRadius:(float)radius
                     withForce:(float)maxForce
                      position:(CGPoint)pos
                       inWorld:(b2World*)world;

-(void) implodeSpritesInRadius:(float)radius
                     withForce:(float)maxForce
                      position:(CGPoint)pos
                       inWorld:(b2World*)world;

#ifdef B2_ROPE_JOINT_H
-(bool)cutRopeJoint:(LHJoint*)joint
 withLineFromPointA:(CGPoint)ptA
           toPointB:(CGPoint)ptB; //returns true if it has cut the joint, false otherwise


-(void)cutRopeJoints:(NSArray*)jointsArray
  withLineFromPointA:(CGPoint)ptA
            toPointB:(CGPoint)ptB;
#endif

//use this only for debuging - performance is slow
-(void)debugDrawing;

@end
#endif
