//
//  SCMove.m
//  Sport Counter
//
//  Created by Georges Kanaan on 5/3/14.
//  Copyright (c) 2014 Georges Kanaan. All rights reserved.
//

#import "SCMove.h"

@implementation SCMove

+(BOOL)createMoveWithHashs:(NSArray *)hashes count:(int)count image:(UIImage *)image defaultImage:(BOOL)defaultImage imageName:(NSString *)imageName wantsMapping:(BOOL)wantsMap andName:(NSString *)name {
    //get the number of moves
    int moveNumber = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfMoves"] + 1;
    
    //get the path to the plist
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/move%i.plist", [documentsDirectory stringByAppendingPathComponent:@"MovePlists"], moveNumber];
    
    //save the array to a plist
    NSArray *move;
    if (!defaultImage) {
         move = [NSArray arrayWithObjects:hashes, name, [NSString stringWithFormat:@"%i", count], [NSNumber numberWithBool:wantsMap], [NSNumber numberWithBool:defaultImage], nil];
    } else {
        move = [NSArray arrayWithObjects:hashes, name, [NSString stringWithFormat:@"%i", count], [NSNumber numberWithBool:wantsMap], [NSNumber numberWithBool:defaultImage], imageName, nil];
    }
    
    BOOL moveSaved = [move writeToFile:filePath atomically:YES];
    
    if (moveSaved) {//make sure it saved
        //save the image if it isn't default
        if (!defaultImage) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [NSString stringWithFormat:@"%@/moveImage%i.plist", [documentsDirectory stringByAppendingPathComponent:@"MoveImages"], moveNumber];
            
            BOOL imageSaved = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
            if (!imageSaved) {
                return imageSaved;
            }
        }
        
        //synchronise defaults
        [[NSUserDefaults standardUserDefaults] setInteger:moveNumber forKey:@"numberOfMoves"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    return moveSaved;
}

#pragma mark - Retrieving Moves
+(NSArray *)moveWithNumber:(int)number {
    //create the key string with the number passed to us
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/move%i.plist", [documentsDirectory stringByAppendingPathComponent:@"MovePlists"], number];
    
    //get array
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:filePath];
    if ([[array objectAtIndex:ISDEFAULTIMAGE_INDEX_IN_MOVES_ARRAY] boolValue] == NO) {
        [array insertObject:[self loadImageForMoveNumber:number] atIndex:IMAGE_INDEX_IN_MOVES_ARRAY];
    }
    
    NSArray *move = [[NSArray alloc] initWithArray:array copyItems:YES];
    
    return move;
}

+(NSMutableArray *)allMoves {
    NSMutableArray *allMoves = [NSMutableArray new];
    
    int numberOfMoves = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfMoves"];
    
    for (int a = 1; a <= numberOfMoves; a++) {
        [allMoves addObject:[self moveWithNumber:a]];
    }
    
    return allMoves;
}

#pragma mark - Deleting Moves Data

+(void)removeMoveNumber:(int)number {
    //clear the key
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/move%i.plist", [documentsDirectory stringByAppendingPathComponent:@"MovePlists"], number];
    
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    //update number of moves
    int numberOfMoves = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfMoves"];
    
    //go through all plists above the one we need to delete and decrement there move number by 1
    for (int i = number+1; i<= numberOfMoves; i++) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *oldPath = [NSString stringWithFormat:@"%@/move%i.plist", [documentsDirectory stringByAppendingPathComponent:@"MovePlists"], i];
        NSString *newPath = [NSString stringWithFormat:@"%@/move%i.plist", [documentsDirectory stringByAppendingPathComponent:@"MovePlists"], i-1];
        
        NSString *oldImagePath = [NSString stringWithFormat:@"%@/moveImages%i.png", [documentsDirectory stringByAppendingPathComponent:@"MovePlists"], i];
        NSString *newImagePath = [NSString stringWithFormat:@"%@/moveImages%i.png", [documentsDirectory stringByAppendingPathComponent:@"MovePlists"], i-1];
        
        [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:oldPath error:nil];
        
        [[NSFileManager defaultManager] moveItemAtPath:oldImagePath toPath:newImagePath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:oldImagePath error:nil];
        
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:numberOfMoves-1 forKey:@"numberOfMoves"];
    
    //synchronise defaults
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Modifying Moves
+(void)renameMoveWithNumber:(int)number andName:(NSString *)name{
    NSArray *move = [SCMove moveWithNumber:number];//get the move
    
    //create a mutable array from the move
    NSMutableArray *mutableMove = [[NSMutableArray alloc] initWithArray:move copyItems:YES];
    
    //replace the name
    [mutableMove removeObjectAtIndex:NAME_INDEX_IN_MOVES_ARRAY];
    [mutableMove insertObject:name atIndex:NAME_INDEX_IN_MOVES_ARRAY];
    
    //remove the UIImage so we can save it
    if ([[mutableMove objectAtIndex:ISDEFAULTIMAGE_INDEX_IN_MOVES_ARRAY] boolValue] == NO) {
        [mutableMove removeObjectAtIndex:IMAGE_INDEX_IN_MOVES_ARRAY];
    }
    
    //get the filePath
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/move%i.plist", [documentsDirectory stringByAppendingPathComponent:@"MovePlists"], number];
    
    //write array to the plist overriding old values
    [mutableMove writeToFile:filePath atomically:YES];
}

#pragma mark Set Moves Properties
+(void)setWantsMapping:(BOOL)wantsMap forMoveWithNumber:(int)number {
    NSArray *move = [SCMove moveWithNumber:number];//get the move
    //create a mutable array from the move
    NSMutableArray *mutableMove = [[NSMutableArray alloc] initWithArray:move copyItems:YES];
    
    //replace the wants mapping bool
    [mutableMove removeObjectAtIndex:WANTSMAPPING_INDEX_IN_MOVES_ARRAY];
    [mutableMove insertObject:[NSNumber numberWithBool:wantsMap] atIndex:WANTSMAPPING_INDEX_IN_MOVES_ARRAY];
    
    //remove the UIImage so we can save it
    if ([[mutableMove objectAtIndex:ISDEFAULTIMAGE_INDEX_IN_MOVES_ARRAY] boolValue] == NO) {
        [mutableMove removeObjectAtIndex:IMAGE_INDEX_IN_MOVES_ARRAY];
    }
    
    //get the filePath
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/move%i.plist", [documentsDirectory stringByAppendingPathComponent:@"MovePlists"], number];
    
    //write array to the plist overriding old values
    [mutableMove writeToFile:filePath atomically:YES];
}

+(BOOL)setCount:(int)count forMoveWithNumber:(int)number {
    NSArray *move = [SCMove moveWithNumber:number];//get the move
    //create a mutable array from the move
    NSMutableArray *mutableMove = [[NSMutableArray alloc] initWithArray:move copyItems:YES];
    
    //replace the count
    [mutableMove removeObjectAtIndex:COUNT_INDEX_IN_MOVES_ARRAY];
    [mutableMove insertObject:[NSString stringWithFormat:@"%i",count] atIndex:COUNT_INDEX_IN_MOVES_ARRAY];
    
    //remove the UIImage so we can save it
    if ([[mutableMove objectAtIndex:ISDEFAULTIMAGE_INDEX_IN_MOVES_ARRAY] boolValue] == NO) {
        [mutableMove removeObjectAtIndex:IMAGE_INDEX_IN_MOVES_ARRAY];
    }
    
    //get the filePath
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/move%i.plist", [documentsDirectory stringByAppendingPathComponent:@"MovePlists"], number];
    
    //write array to the plist overriding old values
    BOOL savedMove = [mutableMove writeToFile:filePath atomically:YES];
    return savedMove;
}

+(void)setImage:(UIImage *)image forMoveWithNumber:(int)number defaultImage:(BOOL)defaultImage imageName:(NSString *)defaultImageName {
    
    //save image only if it isn't a default iamge so we don't have to resize it later
    if (!defaultImage) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [NSString stringWithFormat:@"%@/moveImage%i.plist", [documentsDirectory stringByAppendingPathComponent:@"MoveImages"], number];
        
        [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
        [self setMoveWithNumber:number hasDefaultImage:NO imageName:nil];
    } else {
        [self setMoveWithNumber:number hasDefaultImage:YES imageName:defaultImageName];
    }
}

+(void)setMoveWithNumber:(int)number hasDefaultImage:(BOOL)defaultImage imageName:(NSString *)imageName {
    NSArray *move = [SCMove moveWithNumber:number];//get the move
    if (defaultImage) {
        //create a mutable array from the move
        NSMutableArray *mutableMove = [[NSMutableArray alloc] initWithArray:move copyItems:YES];
        
        //replace the bool
        [mutableMove removeObjectAtIndex:ISDEFAULTIMAGE_INDEX_IN_MOVES_ARRAY];
        [mutableMove insertObject:[NSNumber numberWithBool:YES] atIndex:ISDEFAULTIMAGE_INDEX_IN_MOVES_ARRAY];
        
        //replace the image
        if (mutableMove.count == IMAGE_INDEX_IN_MOVES_ARRAY+1) {
            [mutableMove removeObjectAtIndex:IMAGE_INDEX_IN_MOVES_ARRAY];
        }
        [mutableMove insertObject:imageName atIndex:IMAGE_INDEX_IN_MOVES_ARRAY];
        
        //get the filePath
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [NSString stringWithFormat:@"%@/move%i.plist", [documentsDirectory stringByAppendingPathComponent:@"MovePlists"], number];
        
        //write array to the plist overriding old values
        [mutableMove writeToFile:filePath atomically:YES];
    } else {
        //create a mutable array from the move
        NSMutableArray *mutableMove = [[NSMutableArray alloc] initWithArray:move copyItems:YES];
        
        //replace the bool
        [mutableMove removeObjectAtIndex:ISDEFAULTIMAGE_INDEX_IN_MOVES_ARRAY];
        [mutableMove insertObject:[NSNumber numberWithBool:NO] atIndex:ISDEFAULTIMAGE_INDEX_IN_MOVES_ARRAY];
        
        //replace the image
        [mutableMove removeObjectAtIndex:IMAGE_INDEX_IN_MOVES_ARRAY];
        
        //get the filePath
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [NSString stringWithFormat:@"%@/move%i.plist", [documentsDirectory stringByAppendingPathComponent:@"MovePlists"], number];
        
        //write array to the plist overriding old values
        [mutableMove writeToFile:filePath atomically:YES];
    }
}

+(UIImage *)loadImageForMoveNumber:(int)number {
    
    //load image
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/moveImage%i.plist", [documentsDirectory stringByAppendingPathComponent:@"MoveImages"], number];
    
    UIImage *res = [UIImage imageWithContentsOfFile:filePath];
    
    return res;
}

@end