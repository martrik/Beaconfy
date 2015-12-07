//
//  AppDelegate.m
//  Beacons
//
//  Created by Martí Serra Vivancos on 03/05/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "CategoriesManager.h"
#import "FXBlurView.h"
#import "InitialCallManager.h"
#import <Realm/Realm.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface BackBeacon : RLMObject
@property int major;
@property int minor;
@end
@implementation BackBeacon
@end

bool internet = YES;
bool bluetooth = YES;

@implementation AppDelegate
@synthesize locationManager, beaconRegion, bluetoothManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Black app if no internet
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNetworkChange:)
                                                 name:kReachabilityChangedNotification object:nil];
    
    _networkReachability = [Reachability reachabilityForInternetConnection];
    [_networkReachability startNotifier];
    NetworkStatus networkStatus = [_networkReachability currentReachabilityStatus];
    
    // Check if internet available
    if (networkStatus == NotReachable) internet = NO;
    
    // Block app if bluetooth not enabled
    if(!self.bluetoothManager)
    {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerOptionShowPowerAlertKey, nil];
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
    }
    
    // First time actions
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"hasLaunchedBefore"] boolValue] != YES)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunchedBefore"];
        
        // Set zone notifications
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"backNots"];
        
        // Set user id 0
        [[NSUserDefaults standardUserDefaults] setValue:@0 forKey:@"user_id"];
        
        // Category version to 0        
         [[NSUserDefaults standardUserDefaults] setValue:0 forKey:@"category_version"];
    }
    
    // Make initial call
    [[InitialCallManager sharedManager] makeCall:^(BOOL needUpdate){
        // Show alert if app is not updated
        if (needUpdate) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UPDATE_TITLE", @"Need to update alert") message:NSLocalizedString(@"UPDATE_BODY", @"Need to update alert") delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Ok message") otherButtonTitles: nil];
            [alert show];
        }
    }];
    
    // Update categories
    [[CategoriesManager sharedManager]updateCategories];
    
    // Beacon detection
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) [self.locationManager requestAlwaysAuthorization];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.Tomorrow.com"];
    self.beaconRegion.notifyOnEntry = YES;
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    // Tab bar
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    tabBarController.selectedIndex = 1;
    tabBarController.tabBar.barTintColor =  [UIColor colorWithRed:0 green:0.48 blue:1 alpha:1.000];
    tabBarController.tabBar.tintColor =  [UIColor whiteColor];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor whiteColor]
                                                        } forState:UIControlStateSelected];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor lightTextColor]
                                                        } forState:UIControlStateNormal];
    
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"mapTab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem1.image = [[UIImage imageNamed:@"mapTabDes.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    
    tabBarItem2.selectedImage = [[UIImage imageNamed:@"searchTab.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem2.image = [[UIImage imageNamed:@"searchTabDes.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    
    tabBarItem3.selectedImage = [[UIImage imageNamed:@"favoritesTab.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem3.image = [[UIImage imageNamed:@"favoritesTabDes.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    
    return YES;
}


// Block app if bluetooth not opened & display message
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (bluetoothManager.state == CBCentralManagerStatePoweredOff) bluetooth = NO;
    if (bluetoothManager.state == CBCentralManagerStatePoweredOn) bluetooth = YES;
    
    [self updateNoServiceAlert];
}

// Recheck internet connection
- (void)handleNetworkChange:(NSNotification *)notice{
    
    NetworkStatus networkStatus = [_networkReachability currentReachabilityStatus];
    if (networkStatus != NotReachable)  internet = YES;
    else internet = NO;
    [self updateNoServiceAlert];
}


// Show no service alert
- (void) updateNoServiceAlert
{
    if (!internet || !bluetooth) {
        
       [_noService removeFromSuperview];
        
        UIViewController *vc = (UIViewController *)self.window.rootViewController;
        _noService = [[UIView alloc]initWithFrame:CGRectMake(0, 0, vc.view.frame.size.width, vc.view.frame.size.height)];
        _noService.backgroundColor = [UIColor colorWithRed:0 green:0.48f blue:1 alpha:1];
        [vc.view addSubview:_noService];
        
        UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0.95*vc.view.frame.size.width, vc.view.frame.size.height/3)];
        text.textColor = [UIColor whiteColor];
        text.backgroundColor = [UIColor clearColor];
        
        if (!internet && !bluetooth)  text.text = NSLocalizedString(@"NO_SERVICES", @"No services message");
        else if (!internet) text.text = NSLocalizedString(@"NO_INTERNET", @"No internet connection message");
        else if (!bluetooth) text.text = NSLocalizedString(@"NO_BLUETOOTH", @"No bluetooth connection message");
        
        text.font = [UIFont fontWithName:@"Helvetica" size:23];
        [text sizeToFit];
        text.center = CGPointMake(vc.view.frame.size.width/2, vc.view.frame.size.height/1.6);
        text.editable = NO;
        text.selectable = NO;
        text.scrollEnabled = NO;
        text.textAlignment = NSTextAlignmentCenter;
        [_noService addSubview:text];
        
        if (!bluetooth && internet) {
            
            UIImageView *bluetooth = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bluetooth.png"]];
            bluetooth.center = CGPointMake(vc.view.frame.size.width/2, vc.view.frame.size.height/2.4);
            [_noService addSubview:bluetooth];
        }
        
        if (!internet && bluetooth) {
            UIImageView *internet = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"internet.png"]];
            internet.center = CGPointMake(vc.view.frame.size.width/2, vc.view.frame.size.height/2.4);
            [_noService addSubview:internet];
        }
        
        if (!internet && !bluetooth) {
            
            UIImageView *bluetooth = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bluetooth.png"]];
            bluetooth.center = CGPointMake(vc.view.frame.size.width/1.5, vc.view.frame.size.height/2.4);
            [_noService addSubview:bluetooth];
            
            UIImageView *internet = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"internet.png"]];
            internet.center = CGPointMake(vc.view.frame.size.width/3, vc.view.frame.size.height/2.4);
            [_noService addSubview:internet];
        }
    }
    else
    {
        [UIView animateWithDuration:0.25
                              delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _noService.alpha = 0;
                         } completion:^(BOOL success){
                             [_noService removeFromSuperview];
                         }];
    }
}

// Detect beacons in background and notify user with server message
- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

// Did range beacons
- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    
    [self.locationManager stopRangingBeaconsInRegion:region];
    
    // Make call to get custom message when entered region
    CLBeacon *beacon = [beacons firstObject];
    
    // Save to realm to use later
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    BackBeacon *backbeacon = [[BackBeacon alloc]init];
    backbeacon.major = beacon.major.intValue;
    backbeacon.minor = beacon.minor.intValue;
    [realm addObject:backbeacon];
    [realm commitWriteTransaction];
    
    // Date
    NSDate *localDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    // Make enter region analytics call
    AFHTTPRequestOperationManager *notCall = [AFHTTPRequestOperationManager manager];
    [notCall PUT:@"http://www.fernandezmir.com/beacons/api/background"  parameters:@{
                                                                                    @"user_id": [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"],
                                                                                    @"major" : [NSNumber numberWithInt:beacon.major.intValue],
                                                                                    @"minor"  : [NSNumber numberWithInt:beacon.major.intValue],
                                                                                    @"state" : @"in",
                                                                                    @"time" : [dateFormatter stringFromDate: localDate],
                                                                                    @"lang" : [[NSLocale preferredLanguages] objectAtIndex:0]
                                                                                    }
    success:^(AFHTTPRequestOperation *operation, id response) {
        
        NSLog(@"%@", response);
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"backNots"] boolValue] && [UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertBody = response[@"notification"];
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
    }];
}

// User left region -> report analytics
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    // Save to realm to use later
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    BackBeacon *backbeacon = [[BackBeacon allObjects]firstObject];
   
    
    // Call server when user left region
    NSDate *localDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    AFHTTPRequestOperationManager *notCall = [AFHTTPRequestOperationManager manager];
    [notCall PUT:@"http://www.fernandezmir.com/beacons/api/background"  parameters:
        @{
            @"user_id": [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"],
            @"major" : [NSNumber numberWithInt:backbeacon.major],
            @"minor"  : [NSNumber numberWithInt:backbeacon.major],
            @"state" : @"out",
            @"time" : [dateFormatter stringFromDate: localDate],
            @"lang" : [[NSLocale preferredLanguages] objectAtIndex:0]
    } success:^(AFHTTPRequestOperation *operation, id response) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [realm deleteObject: backbeacon];
    [realm commitWriteTransaction];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
