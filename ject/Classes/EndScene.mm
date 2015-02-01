//
//  EndScene.m
//  Rotate & Roll
//
//  Created by javier on 06/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EndScene.h"
#import "MenuScene.h"

@implementation EndScene

+(id)scene
{
	
	//NSLog(@"LEVEL ID %i", [self retainCount]); 
	
	CCScene *scene =[CCScene node];
	EndScene *EndLayer = [EndScene node];
	[scene addChild: EndLayer];
	return scene;
}

-(id) init
{
	if( (self=[super init]) )
	{
			

		CCSprite *bg = [CCSprite spriteWithFile: @"noche.png"];
		bg.position = ccp(240,160);
		[self addChild: bg z:0];
		
		CCSprite *portal = [CCSprite spriteWithFile: @"portal.png"];
		portal.position = ccp(240,160);
		[self addChild: portal z:2];
		portal.scale = 0.75;
		portal.opacity = 180;
		
		// custom spinning
	
		
		for(int i=1;i<6;i++)
		{
			
			int num_particles = 15;
			
			if(i==5)
			{
				num_particles = 60;
			}
			
			CCParticleSystemQuad *emitter = [[CCParticleSystemQuad alloc] initWithTotalParticles:num_particles];
			
			emitter.texture = [[CCTextureCache sharedTextureCache] addImage: [NSString stringWithFormat:@"bolapart%i.png", i]];	
			
			
			emitter.position = ccp(240, 160);
			//emitter.posVar = ccp(27, 27);
			
			// spin of particles
			emitter.startSpin = 0;
			emitter.startSpin = 360;
			emitter.endSpin = 720;
			emitter.endSpinVar = 360;
			
			
			// angle
			emitter.angle = 90;
			emitter.angleVar = 360;
			
			emitter.emitterMode = kCCParticleModeRadius;
			
			
			// radius mode: start and end radius in pixels
			emitter.startRadius = 680;
			emitter.startRadiusVar = 5;
			emitter.endRadius = 16.5799987f;
			emitter.endRadiusVar = 6;
			
			// duration
			emitter.duration = kCCParticleDurationInfinity;
			
			
			ccColor4F endColor = {1.0f, 1.0f, 1.0f, 1.0f};
			emitter.endColor = endColor;
			
			ccColor4F endColorVar = {0.5f, 0.5f, 0.5f, 50.0f};	
			emitter.endColorVar = endColorVar;
			
			ccColor4F startColor = {1.0f, 1.0f, 1.0f, 1.0f};
			emitter.startColor = startColor;
			
			ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 0.5f};
			emitter.startColorVar = startColorVar;
			
			
			// size, in pixels
			emitter.startSize = 30.0f;
			emitter.startSizeVar = 4.049999f;
			
			emitter.endSize = 0;
			emitter.endSizeVar = 0;
			
			//emitter.gravity = CGPointZero;
			
			//emitter.max = 1000;
			
			// life of particles
			emitter.life = 10.0f;
			emitter.lifeVar = 0.0f;
			
			// Gravity Mode: radial
			//emitter.radialAccel = 0.0f;
			//emitter.radialAccelVar = 0.0f;
			
			emitter.rotatePerSecond = 0.0f;
			emitter.rotatePerSecondVar = 68.68000f;
			emitter.sourcePosition = ccp(160.0f, 222.0f);
			emitter.posVar = ccp(7.0f, 7.0f);;
			
			// additive
			// emits per second
			emitter.emissionRate = emitter.totalParticles/emitter.life;
			
			emitter.blendAdditive = NO;
			
			[self addChild: emitter z:1];
			
		}
		
		
		
		CCLabelTTF *winLabel = [CCLabelTTF labelWithString:@"Congratulations !!!" fontName:@"Arnold 2.1" fontSize:24 dimensions:CGSizeMake(360,200) hAlignment:kCCTextAlignmentCenter];
		[winLabel setPosition:ccp(240, -20)];
		[self addChild:winLabel z:10];
		
		CCMenu *menu = [CCMenu menuWithItems:nil];
		
		menu.position = ccp(0,0);
		
		CCMenuItemImage *item = [CCMenuItemImage itemWithNormalImage:@"boton-back.png" selectedImage:@"boton-over-small.png" target:self selector:@selector(back:)];
		item.position = ccp(30,30);
		[menu addChild:item];
		
		[self addChild:menu z:2];
        
	}
	return self;
}


-(void) back: (id) sender
{
	
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.8 scene:[MenuScene scene]withColor:ccWHITE]];
}

-(void)dealloc
{
	//NSLog(@"END SCENE DEALLOC %i", [self retainCount]); 
	[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}


@end
