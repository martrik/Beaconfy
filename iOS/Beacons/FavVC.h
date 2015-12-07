//
//  FavVC.h
//  Beacons
//
//  Created by Martí Serra Vivancos on 11/06/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritedFlyers.h"
#import "FXPageControl.h"
#import "FilterVC.h"

@interface FavVC : UIViewController <FavoritedFlyersDelegate, FilterDelegate>

// ScrollView
@property (nonatomic, strong) FavoritedFlyers *favoritesView;
@property (nonatomic, strong) FXPageControl *pageControl;
@property (nonatomic, strong) FilterVC *filter;

@end


