//
//  CategoriesManager.m
//  Beacons
//
//  Created by Martí Serra Vivancos on 10/07/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import "CategoriesManager.h"
#import "AFNetworking.h"


@interface SavedCategory : RLMObject
@property NSString *name;
@property NSString *image;
@end
@implementation SavedCategory
@end


@implementation CategoriesManager

+ (id)sharedManager
{
    static CategoriesManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

// Get categories
- (void) updateCategories
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://www.fernandezmir.com/beacons/api/category_list.php?lang=%@&version=%@", [[NSLocale preferredLanguages] objectAtIndex:0],  [[NSUserDefaults standardUserDefaults] objectForKey:@"category_version"]]  parameters:nil success:^(AFHTTPRequestOperation *operation, id response) {
        
        // Save categories to db
        if ([response[@"success"]boolValue]) {
                
            NSLog(@"%@", response);
                
            [self saveCategories:response[@"categories"] newVersion:[response[@"new_version"]floatValue]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];   
}

// Return image for each category
- (UIImage *)imageFromCategoryName:(NSString *)name
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *imagePath = [NSString stringWithFormat:@"%@/%@.jpg", docDir, name];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}


// Database Realm
// Save categories
- (void) saveCategories:(NSArray *)response newVersion:(float) version
{
     [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:version] forKey:@"category_version"];
    
    // Save object in Realm DB
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObjects:[SavedCategory allObjects]];
    
    for (NSDictionary *category in response) {
        
        SavedCategory *saving = [[SavedCategory alloc]init];
        saving.name = category[@"name"];
        saving.image = [self imagePathFromURL:[NSURL URLWithString:category[@"image"]] withName:category[@"name"]];
        [realm addObject:saving];
        
    }
    
    [realm commitWriteTransaction];
}

// Fetch saved categories
- (NSArray *) getSavedCategories
{
    // Fetch and parse saved categories
    NSMutableArray *categories = [[NSMutableArray alloc]init];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMArray* saved = [SavedCategory allObjects];
    [realm commitWriteTransaction];
    
    for (SavedCategory *category in saved) {
        
        [categories addObject:@[category.name, category.image]];
    }
    
    return categories;
}

// Save image in URL to local path
- (NSString *)imagePathFromURL:(NSURL *)url withName:(NSString *)name
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
	NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.jpg", docDir, name];
    
	NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
    [data writeToFile:pngFilePath atomically:YES];
    
    return pngFilePath;
}


@end
