//
//  calloutAnnotation.m
//  Beacons
//
//  Created by Martí Serra Vivancos on 03/07/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import "AnnotationView.h"

@implementation AnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Info View
        UIView *rectangle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-20)];
        rectangle.backgroundColor = [UIColor whiteColor];
        rectangle.layer.cornerRadius = 4;
        rectangle.layer.borderWidth = 0.5;
        rectangle.layer.borderColor = [UIColor lightGrayColor].CGColor;
        rectangle.clipsToBounds = YES;
        [self addSubview:rectangle];
        
        // Load image
        _category = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [rectangle addSubview:_category];
        
        // Titles
        _title = [[UILabel alloc] initWithFrame:CGRectMake(45, 2, 180, 20)];
        _title.font = [UIFont fontWithName:@"Helvetica" size:18];
        //_title.text = @"Startbuck Coffee";
        [rectangle addSubview:_title];
        
        _subtitle = [[UILabel alloc] initWithFrame:CGRectMake(45, 21, 180, 15)];
        _subtitle.font = [UIFont fontWithName:@"Helvetica-Light" size:14];
        //_title.text = @"Quite hipster & cool bar";
        [rectangle addSubview:_subtitle];
        
        UIView* beacon = [[UIView alloc] initWithFrame:CGRectMake(210, 0, 40, 40)];
        beacon.backgroundColor = [UIColor blueColor];
        [rectangle addSubview: beacon];
        
        _count = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _count.font = [UIFont fontWithName:@"Helvetica" size:25];
        _count.textColor = [UIColor whiteColor];
        _count.center = CGPointMake(20, 20);
        [beacon addSubview:_count];
        
        // Triangle image
        UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2-10, 39, 24,  20)];
        triangle.image = [UIImage imageNamed:@"triangle.png"];
        [self addSubview:triangle];
        
        
        
    }
    return self;
}

- (void) adjustLabels
{
    [_count sizeToFit];
    _count.center = CGPointMake(20, 20);
}


@end
