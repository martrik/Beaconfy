//
//  NearbyVC.m
//  Beacons
//
//  Created by Martí Serra Vivancos on 10/05/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import "ScanVC.h"
#import "SettingVC.h"

@implementation ScanVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Navigation Bar
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0.48f blue:1 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:20]};
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter.png"] style:UIBarButtonItemStylePlain target:self action:@selector(filterBeacons)];
    filterButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = filterButton;
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openSettings)];
    [settingsButton setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size: 18]} forState:UIControlStateNormal];
    settingsButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = settingsButton;
    
    // FilterVC
    _filter = [[FilterVC alloc]init];
    [_filter setFilterDelegate:self];
    _filter.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // Detect view
    _detectedView = [[DetectedFlyers alloc] initWithFrame:CGRectMake(0, 65, self.view.frame.size.width, self.view.frame.size.height-114)];
    [_detectedView setDetectedDelegate:self];
    [self.view addSubview:_detectedView];
    
    _pageControl = [[FXPageControl alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    _pageControl.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-57);
    _pageControl.defersCurrentPageDisplay = YES;
    _pageControl.selectedDotColor = [UIColor colorWithRed:0 green:0.48f blue:1 alpha:1];
    _pageControl.selectedDotShape = FXPageControlDotShapeCircle;
    _pageControl.selectedDotSize = 9.0f;
    _pageControl.dotColor = [UIColor lightGrayColor];
    _pageControl.dotSpacing = 8.0f;
    [self.view addSubview:_pageControl];
    
    // Searching loader

}

// Ranging actions
- (void) viewWillAppear:(BOOL)animated
{
    [_detectedView reloadFavButtons];
    [_detectedView startRanging];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [_detectedView stopRanging];
}

// Open filter list
- (void) filterBeacons;
{
    [self presentViewController:_filter animated:YES completion:nil];
}

- (void) filterDidDismissWithArray:(NSArray *)array
{
    _detectedView.filterCategories = array;
    [_detectedView rearrangeFlyers];
}

// Open settings view
- (void) openSettings
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[SettingVC sharedView]];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

// Adjust view when flyer expanded
- (void) scrollHadBeaconExpanded:(BOOL)fullscreen
{    
    if (fullscreen)
    {
        // Make scrollview bigger to show fullscreen content
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        _detectedView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50);
        
        // Hide status bar
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
        // Hide page controll
        _pageControl.hidden = YES;
        
        // Stop ranging beacons
        [_detectedView stopRanging];
    }
    else
    {
        // Turn to normal size
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        _detectedView.frame = CGRectMake(0, 65, self.view.frame.size.width, self.view.frame.size.height-114);
        
        // Show status bar
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        
        // Hide page controll
        _pageControl.hidden = NO;
        
        // Start ranging beacons
        [_detectedView startRanging];
    }
}

// Page controll delegate
- (void) modifyPageControllNumber: (NSInteger) pages
{
    _pageControl.numberOfPages = pages;
}
- (void) selectedPage: (NSInteger) index
{
    _pageControl.currentPage = index;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
