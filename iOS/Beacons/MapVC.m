//
//  MapVC.m
//  Beacons
//
//  Created by Martí Serra Vivancos on 02/07/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import "MapVC.h"
#import "Annotation.h"
#import "AnnotationView.h"
#import "AFNetworking.h"
#import "SettingVC.h"

@interface MapVC ()

@end

@implementation MapVC

- (void)viewDidLoad
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Navigation Bar
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0.48f blue:1 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:20]};
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter.png"] style:UIBarButtonItemStylePlain target:self action:@selector(filterAnnotations)];
    filterButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = filterButton;
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
    [settingsButton setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size: 18]} forState:UIControlStateNormal];
    settingsButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = settingsButton;
    
    // Map
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 65, self.view.frame.size.width,  self.view.frame.size.height-114)];
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    _downAnnotations = [[NSArray alloc]init];
    
    // Make server calls to get all beacon zones
    [self getAnotations:nil];
    
    // Categories manager
    _categories = [CategoriesManager sharedManager];
    
    // FilterVC
    _filter = [[FilterVC alloc] init];
    [_filter setFilterDelegate:self];
    _filter.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

}

// Open settings view
- (void) openSettings
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[SettingVC sharedView]];
    [self presentViewController:navigationController animated:YES completion:nil];
}


// Filter annotations by category
- (void) filterAnnotations
{
    [self presentViewController:_filter animated:YES completion:nil];
}

// Filter annotations
- (void) filterDidDismissWithArray:(NSArray *)array
{
    [self filterAnotations:array];
}

// Load annotations
- (void) getAnotations:(NSArray *)filter
{
    // Call the server for beacon areas
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://fernandezmir.com/beacons/api/map?latitude=%f&longitude=%f&lang=%@", _mapView.userLocation.location.coordinate.latitude, _mapView.userLocation.location.coordinate.longitude, [[NSLocale preferredLanguages] objectAtIndex:0]] parameters:nil success:^(AFHTTPRequestOperation *operation, id response) {
        
        _downAnnotations = response[@"regions"];
        
        // Add each annotation to coordinate
        for (NSDictionary* annotationInfo in _downAnnotations) {
            
            if (![filter containsObject:annotationInfo[@"category"]]) {
                CLLocationCoordinate2D coordinate;
                coordinate.latitude = [annotationInfo[@"latitude"] floatValue];
                coordinate.longitude = [annotationInfo[@"longitude"] floatValue];
                Annotation *annotation = [[Annotation alloc] initWithCoordinate:coordinate title:annotationInfo[@"title"] subTitle:annotationInfo[@"subtitle"]];
                annotation.beaconCount = annotationInfo[@"beacons_count"];
                annotation.category = annotationInfo[@"category"];
                [self.mapView addAnnotation:annotation];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);        
        
    }];
}

- (void) filterAnotations:(NSArray *)filter
{
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    // Add each annotation to coordinate
    for (NSDictionary* annotationInfo in _downAnnotations) {
        
        if (![filter containsObject:annotationInfo[@"category"]]) {
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = [annotationInfo[@"latitude"] floatValue];
            coordinate.longitude = [annotationInfo[@"longitude"] floatValue];
            Annotation *annotation = [[Annotation alloc] initWithCoordinate:coordinate title:annotationInfo[@"title"] subTitle:annotationInfo[@"subtitle"]];
            annotation.beaconCount = annotationInfo[@"beacons_count"];
            annotation.category = annotationInfo[@"category"];
            [self.mapView addAnnotation:annotation];
            
        }
    }
}

// Set custom image to Annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString *identifier = @"myAnnotation";
    MKAnnotationView * annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        
        CGSize newSize = CGSizeMake(40, 40);
        UIGraphicsBeginImageContextWithOptions(newSize,NO,0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        [[_categories imageFromCategoryName:[(Annotation*)[annotationView annotation] category]] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        annotationView.image = newImage;
        
    }else {
        annotationView.annotation = annotation;
    }
    return annotationView;
}

// Animate annotation drop
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
    // Animate drop
    for (MKAnnotationView *annotation in annotationViews)
    {
        CGRect startFrame = annotation.frame;
        CGRect bigFrame = annotation.frame;
        CGRect normalFrame = annotation.frame;
        startFrame.size.width = 0;
        startFrame.size.height = 0;
        startFrame.origin.y = bigFrame.origin.y + 10;
        bigFrame.size.width = annotation.frame.size.width*1.2;
        bigFrame.size.height = annotation.frame.size.height*1.2;
        bigFrame.origin.y = bigFrame.origin.y - 10;
        annotation.frame = startFrame;
        annotation.alpha = 0;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            annotation.frame = bigFrame;
            annotation.alpha = 1;
        }completion:^(BOOL completion){
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                annotation.frame = normalFrame;
            }completion:nil];
        }];
    }
}

// Add annotation's selected view
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
    if(![view.annotation isKindOfClass:[MKUserLocation class]]) {
        
        // Create detail view
        AnnotationView* calloutView = [[AnnotationView alloc] initWithFrame:CGRectMake(-115, -55, 250, 60)];
        calloutView.title.text = [(Annotation*)[view annotation] title];
        calloutView.subtitle.text = [(Annotation*)[view annotation] subtitle];
        calloutView.count.text = [(Annotation*)[view annotation] beaconCount];
        [calloutView.count sizeToFit];
        
        calloutView.count.center = CGPointMake(20, 20);
        calloutView.category.image = [_categories imageFromCategoryName:[(Annotation*)[view annotation] category]];
        calloutView.alpha = 0;
        [view addSubview:calloutView];
        
        NSLog(@"%@", calloutView.count.text);
        
        // Animate
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{ calloutView.alpha = 1; } completion:nil];
    }
}

// Remove selected view
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
    for (UIView *subview in view.subviews ){
        
        // Animate before deleting
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{subview.alpha = 0;} completion:^(BOOL completed){ [subview removeFromSuperview]; }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
