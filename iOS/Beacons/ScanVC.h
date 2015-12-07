//
//  NearbyVC.h
//  Beacons
//
//  Created by Martí Serra Vivancos on 10/05/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetectedFlyers.h"
#import "FXPageControl.h"
#import "FilterVC.h"
#import "Reachability.h"

@interface ScanVC : UIViewController <DetectedFlyersDelegate, FilterDelegate>

// ScrollView
@property (nonatomic, strong)  DetectedFlyers *detectedView;

// Views
@property (nonatomic, strong) FXPageControl *pageControl;
@property (nonatomic, strong) FilterVC *filter;

// Buttons
@property (nonatomic, strong) UIBarButtonItem *filterButton;

// Services
@property (nonatomic, strong) Reachability *networkReachability;

@end
