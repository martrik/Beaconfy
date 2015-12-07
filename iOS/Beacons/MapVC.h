//
//  MapVC.h
//  Beacons
//
//  Created by Martí Serra Vivancos on 02/07/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CategoriesManager.h"
#import "FilterVC.h"

@interface MapVC : UIViewController <MKMapViewDelegate, FilterDelegate>

// Map
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSArray *downAnnotations;
@property (nonatomic) CategoriesManager *categories;

// UI
@property (nonatomic, strong) UIBarButtonItem *filterButton;
@property (nonatomic, strong) FilterVC *filter;

@end
