//
//  FilterVC.h
//  Beacons
//
//  Created by Martí Serra Vivancos on 25/06/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterDelegate;

@interface FilterVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UINavigationBar *navBar;
@property (nonatomic, strong) NSMutableArray *filterCategories;
@property (nonatomic, strong) NSArray *categories;
@property (assign, nonatomic) id<FilterDelegate> filterDelegate;

@end

// Delegate protocol
@protocol FilterDelegate <NSObject>

- (void) filterDidDismissWithArray: (NSArray *) array;

@end