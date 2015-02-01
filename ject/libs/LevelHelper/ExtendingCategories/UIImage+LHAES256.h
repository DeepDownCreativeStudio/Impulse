//
//  UIImage+LHAES256.h
//  LevelHelper API
//
//  Created by Rabih on 7/5/11.
//  Modified by Vladu Bogdan for LevelHelper usage
//

#import <Foundation/Foundation.h>


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

@interface UIImage (LHAES256)
+ (UIImage *)imageWithContentsOfEncryptedFile:(NSString *)path withKey:(NSData *)key;

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

@interface NSImage (LHAES256)
+ (NSImage *)imageWithContentsOfEncryptedFile:(NSString *)path withKey:(NSData *)key;

#endif

- (id)initWithContentsOfEncryptedFile:(NSString *)path withKey:(NSData *)key;

@end
