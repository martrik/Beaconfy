//
//  Searching.h
//  Extensions
//
//  Created by Martí Serra Vivancos on 11/09/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Searching : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *first;
@property (nonatomic, strong) UIImageView *second;
@property (nonatomic, strong) UIImageView *third;

- (void) stopAnimating;
- (void) startAnimating;


@end
