//
//  AppDelegate.h
//  Beacons
//
//  Created by Martí Serra Vivancos on 03/05/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, CBCentralManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

// Location
@property (strong, nonatomic)  CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CBCentralManager *bluetoothManager;
@property (strong, nonatomic) CLBeacon *backBeacon;

// Reachability
@property (strong, nonatomic) UIView *noService;
@property (strong, nonatomic) Reachability *networkReachability;

@property (nonatomic) BOOL foreground;


@end

