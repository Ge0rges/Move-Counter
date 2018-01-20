//
//  SCMove.h
//  Sport Counter
//
//  Created by Georges Kanaan on 5/3/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCMove : NSObject

+ (BOOL)createMoveWithHashs:(NSArray *)hashs count:(int)count image:(UIImage *)image  defaultImage:(BOOL)defaultImage imageName:(NSString *)imageName wantsMapping:(BOOL)wantsMap andName:(NSString *)name;
+ (NSArray *)moveWithNumber:(int)moveNumber;
+ (NSMutableArray *)allMoves;
+ (void)removeMoveNumber:(int)number;
+ (void)renameMoveWithNumber:(int)number andName:(NSString *)name;
+ (BOOL)setCount:(int)count forMoveWithNumber:(int)number;
+ (void)setImage:(UIImage *)image forMoveWithNumber:(int)number defaultImage:(BOOL)defaultImage imageName:(NSString *)defaultImageName;
+ (void)setMoveWithNumber:(int)number hasDefaultImage:(BOOL)defaultImage imageName:(NSString *)imageName;
+ (void)setWantsMapping:(BOOL)wantsMap forMoveWithNumber:(int)number;

@end
