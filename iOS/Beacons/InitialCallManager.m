//
//  InitialCallManager.m
//  Beacons
//
//  Created by Martí Serra Vivancos on 26/08/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import "InitialCallManager.h"
#import "AFNetworking.h"
#import <Realm/Realm.h>


@interface AppVersion : RLMObject
@property NSString *version;
@end
@implementation AppVersion
@end

@interface UserId : RLMObject
@property NSInteger userid;
@end
@implementation UserId
@end

@implementation InitialCallManager

+ (id)sharedManager
{
    static InitialCallManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void) makeCall:(initialCallback)callback
{
    NSLog(@"%@", @{
                   @"user_id" :  [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"],
                   @"app_version" : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
                   @"os" : @"iOS",
                   @"os_version" : [[UIDevice currentDevice] systemVersion]
                   });
   
    AFHTTPRequestOperationManager *notCall = [AFHTTPRequestOperationManager manager];
    [notCall PUT:@"http://www.fernandezmir.com/beacons/api/initial"  parameters:
     @{
        @"user_id" :  [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"],
        @"app_version" : [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
        @"os" : @"iOS",
        @"os_version" : [[UIDevice currentDevice] systemVersion]
     }
     
    success:^(AFHTTPRequestOperation *operation, id response) {
        
        NSLog(@"%@", response);
        
        if ([response[@"success"] boolValue]){
            
            // If recieved used_id -> add it to user defaults
            if ([response objectForKey:@"user_id"]) {
                
                [[NSUserDefaults standardUserDefaults] setValue:response[@"user_id"] forKey:@"user_id"];
            }
            
            // If should_upta
            if ([response[@"should_update"]boolValue]) {
                callback(YES);
            } else callback (NO);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];    
}

@end
