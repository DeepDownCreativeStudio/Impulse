//
//  Level.h
//  CookieLand
//
//  Created by javier on 21/12/2010.
//  Copyright 2010 GAMEXTAR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Level : NSObject <NSCoding> 
{
    int score;
    int estrellas;
	BOOL locked;
}
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int estrellas;
@property (nonatomic, assign) BOOL locked;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

@end


@interface World : NSObject <NSCoding> 
{
	NSMutableArray *niveles;
	NSString *titulo;
	BOOL locked;
	BOOL completed;
}

@property (nonatomic, retain) NSMutableArray *niveles;
@property (nonatomic, retain) NSString *titulo;
@property (nonatomic, assign) BOOL locked;
@property (nonatomic, assign) BOOL completed;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

@end