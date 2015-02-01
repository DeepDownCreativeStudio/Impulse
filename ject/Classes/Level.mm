//
//  Level.mm
//  CookieLand
//
//  Created by javier on 21/12/2010.
//  Copyright 2010 GAMEXTAR. All rights reserved.
//


#import "Level.h"

@implementation Level

@synthesize score, estrellas,locked;


- (id) init 
{ 
	self = [super init]; 

	return self; 
} 

+(id) alloc
{
	//@synchronized(self)
	//{
		// assert that we are the only instance
		return [super alloc];
	//}
	//return nil;
}

-(void) dealloc
{
	[super dealloc];
}

-(id) initWithCoder:(NSCoder*)coder
{
	self = [super init];
	if( self != nil )
	{
		// decode data
		score = [coder decodeIntForKey:@"score"];
		estrellas = [coder decodeIntForKey:@"estrellas"];
		locked = [coder decodeBoolForKey:@"locked"];
		
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)coder
{
	// encode data
	[coder encodeInt:score forKey:@"score"];
	[coder encodeInt:estrellas forKey:@"estrellas"];
	[coder encodeBool:locked forKey:@"locked"];
}

@end




@implementation World

@synthesize titulo, locked, completed,niveles;

- (id) init 
{ 
	self = [super init];
	return self; 
} 

+(id) alloc
{
	@synchronized(self)
	{
		// assert that we are the only instance
		return [super alloc];
	}
	return nil;
}

-(void) dealloc
{
	[super dealloc];
}

-(id) initWithCoder:(NSCoder*)coder
{
	self = [super init];
	if( self != nil )
	{
		// decode data
		niveles = [[coder decodeObjectForKey:@"niveles"] retain];
		titulo = [[coder decodeObjectForKey:@"titulo"] retain];
		locked = [coder decodeBoolForKey:@"locked"];
		completed = [coder decodeBoolForKey:@"completed"];
		
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder*)coder
{
	// encode data
	[coder encodeObject: niveles forKey:@"niveles" ];
	[coder encodeObject:titulo forKey:@"titulo"];
	[coder encodeBool:locked forKey:@"locked"];
	[coder encodeBool:completed forKey:@"completed"];
	
}

@end
