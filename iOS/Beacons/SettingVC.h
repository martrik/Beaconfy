//
//  SettingVC.h
//  Beacons
//
//  Created by Martí Serra Vivancos on 14/07/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingVC : UIViewController <UITableViewDelegate, UITableViewDataSource>

+ (id)sharedView;
@property (nonatomic, strong) UINavigationBar *navBar;

@end
