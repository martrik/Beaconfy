//
//  CategoriesManager.h
//  Beacons
//
//  Created by Martí Serra Vivancos on 10/07/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import <Realm/Realm.h>
#import <Foundation/Foundation.h>

@interface CategoriesManager : NSObject

+ (id)sharedManager;
- (void) updateCategories;
- (UIImage *)imageFromCategoryName:(NSString *)name;
- (NSArray *) getSavedCategories;

@end
