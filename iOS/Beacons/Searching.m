//
//  Searching.m
//  Extensions
//
//  Created by Martí Serra Vivancos on 11/09/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import "Searching.h"

@implementation Searching

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Third
        _third = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _third.image = [UIImage imageNamed:@"searching3.png"];
        _third.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self addSubview:_third];
        
        // Second
        _second = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,0, 0)];
        _second.image = [UIImage imageNamed:@"searching2.png"];
        _second.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self addSubview:_second];
        
        // First
        _first = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _first.image = [UIImage imageNamed:@"searching1.png"];
        _first.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self addSubview:_first];
        
        [self startAnimating];
    }
    return self;
}

- (void) startAnimating
{
    self.hidden = NO;
    self.alpha = 1;
    
    // First circle
    [UIView animateWithDuration:0.25 delay: 0.0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        
        _first.frame = CGRectMake(0, 0, self.frame.size.width*0.30, self.frame.size.height*0.30);
        _first.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
    }
    completion:^(BOOL finished){
                         
        [UIView animateWithDuration:0.15 delay: 0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _first.frame = CGRectMake(0, 0, self.frame.size.width*0.25, self.frame.size.height*0.25);
            _first.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            
        }
        completion:nil];
    }];
    
    // Second view
    [UIView animateWithDuration:0.35 delay: 0.25 options: UIViewAnimationOptionCurveEaseIn animations:^{
        
        _second.frame = CGRectMake(0, 0, self.frame.size.width*0.65, self.frame.size.height*0.65);
        _second.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
    completion:^(BOOL finished){
                         
        [UIView animateWithDuration:0.2 delay: 0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _second.frame = CGRectMake(0, 0, self.frame.size.width*0.60, self.frame.size.height*0.60);
            _second.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            
        }
        completion:nil];
    }];
    
    // Third view
    [UIView animateWithDuration:0.45 delay: 0.55 options: UIViewAnimationOptionCurveEaseIn animations:^{
        _third.frame = CGRectMake(0, 0, self.frame.size.width*0.95, self.frame.size.height*0.95);
        _third.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
    completion:^(BOOL finished){
                         
        [UIView animateWithDuration:0.25 delay: 0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _third.frame = CGRectMake(0, 0, self.frame.size.width*0.9, self.frame.size.height*0.9);
            _third.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            
        }
        completion:^(BOOL finished){
            [self smallAnimation];
        }];
    }];
}

- (void) smallAnimation
{    
    // First circle
    [UIView animateWithDuration:0.25 delay: 0.0 options: UIViewAnimationOptionCurveEaseOut animations:^{
        
        _third.frame = CGRectMake(0, 0, self.frame.size.width*0.95, self.frame.size.height*0.95);
        _third.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
    }
    completion:^(BOOL finished){
                         
        [UIView animateWithDuration:0.4 delay: 0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _third.frame = CGRectMake(0, 0, 0, 0);
            _third.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                             
        } completion:nil];
    }];
    
    // Second view
    [UIView animateWithDuration:0.2 delay: 0.4 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        
        _second.frame = CGRectMake(0, 0, self.frame.size.width*0.65, self.frame.size.height*0.65);
        _second.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
    completion:^(BOOL finished){
                         
        [UIView animateWithDuration:0.35 delay: 0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _second.frame = CGRectMake(0, 0, 0, 0);
            _second.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                             
        }completion:nil];
    }];
    
    // First view
    [UIView animateWithDuration:0.15 delay: 0.8 options: UIViewAnimationOptionCurveEaseOut animations:^{
        
        _first.frame = CGRectMake(0, 0, self.frame.size.width*0.30, self.frame.size.height*0.30);
        _first.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }completion:^(BOOL finished){
                         
        [UIView animateWithDuration:0.2 delay: 0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _first.frame = CGRectMake(0, 0, 0, 0);
            _first.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                             
        }completion:^(BOOL finished){
            [self startAnimating];
        }];
    }];

}

- (void) stopAnimating
{
    
    [UIView animateWithDuration:0.15 delay: 0.8 options: UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0;
    }completion:^(BOOL finished){
        self.hidden = YES;
        _third.frame = CGRectMake(0, 0, 0, 0);
        _second.frame = CGRectMake(0, 0,0, 0);
        _first.frame = CGRectMake(0, 0, 0, 0);
        _first.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        _second.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        _third.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);

    }];
}

@end
