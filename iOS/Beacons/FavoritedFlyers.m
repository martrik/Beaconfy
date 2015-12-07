//
//  FavBeaconsScroll.m
//  Beacons
//
//  Created by Martí Serra Vivancos on 08/06/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import "FavoritedFlyers.h"
#import "AppDelegate.h"
#import <Realm/Realm.h>
#import "SavedFavFlyer.h"

@implementation FavoritedFlyers

#define MARGIN 5

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // View
        self.pagingEnabled = YES;
        self.bounces = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        
        // NSMutableArrays
        _favoritedFlyers = [[NSMutableArray alloc] init];
        _favoritedBeacons = [[NSMutableArray alloc] init];
        _filteredFavoritedFlyers = [[NSMutableArray alloc]init];
        
        [self reloadFavFlyers];
        
    }
    return self;
}

// Load favorite beacons
- (void) reloadFavFlyers
{
    // Get favorited flyers
    RLMArray *realmSaved = [SavedFavFlyer allObjects];
    NSMutableArray *savedFavorites = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<[realmSaved count]; i++) {
        
        SavedFavFlyer *saved = realmSaved[i];
        [savedFavorites addObject:@[[NSNumber numberWithInt:saved.companyId], [NSNumber numberWithInt:saved.beaconId]]];
    }
    
    // Add new flyers
    for (int i = 0; i<[savedFavorites count]; i++) {
        
        if (![_favoritedBeacons containsObject:savedFavorites[i]])
        {
            // Add to array
            [_favoritedBeacons addObject:savedFavorites[i]];
            
            // Add flyers visualy
            BeaconFlyer *flyer = [[BeaconFlyer alloc] initWithFrame:CGRectMake(MARGIN + i*self.frame.size.width, MARGIN, self.frame.size.width-MARGIN*2, self.frame.size.height-MARGIN*4)];
            flyer.flyerdelegate = self;
            flyer.inFavView = YES;
            flyer.alpha = 0;
            flyer.hidden = YES;
            [_favoritedFlyers addObject:flyer];
            
            [self addSubview:flyer];
            
            // Load info to show content
            NSArray *info = _favoritedBeacons[i];
            [flyer createBeaconFlyerWithCompanyId:[info[0] intValue]  beaconId:[info[1]intValue] withCallback:^(BOOL completed){
                
                [self rearrangeFlyers];
                
            }];
        }
    }
    
    // Check deleted flyers
    for (int i = 0; i<[_favoritedBeacons count]; i++)
    {
        // Delete unfaved beacons and flyers
        if (![savedFavorites containsObject:[_favoritedBeacons objectAtIndex:i]])
        {
            // Remove beacon and flyer
            BeaconFlyer *flyer = (BeaconFlyer *)[_favoritedFlyers objectAtIndex:i];
            [flyer removeFromSuperview];
            [_favoritedBeacons removeObjectAtIndex:i];
            [_favoritedFlyers removeObjectAtIndex:i];
            
                [self rearrangeFlyers];
        }
    }
}

// Loading failed
- (void) flyerLoadingFailed:(BeaconFlyer *)flyer
{
    [self reloadFavFlyers];
}

// Rearrange flyers
- (void) rearrangeFlyers
{
    [_filteredFavoritedFlyers removeAllObjects];
    
    NSLog(@"Displaying filtered flyers...");
    
    // Check if flyers have filtered categories -> hide them
    for (int i = 0; i<[_favoritedFlyers count]; i++)
    {
        BeaconFlyer *flyer = (BeaconFlyer *)_favoritedFlyers[i];
        
        if (![_filterCategories containsObject:flyer.category])
        {
            [_filteredFavoritedFlyers addObject:flyer];
                   
        } else flyer.hidden = YES;
    }
    
    self.contentSize = CGSizeMake(([_filteredFavoritedFlyers count])*(self.frame.size.width), self.frame.size.height);
    
    for (int i = 0; i<[_filteredFavoritedFlyers count]; i++) {
        
        BeaconFlyer *flyer = (BeaconFlyer *)_filteredFavoritedFlyers[i];
        
        [UIView animateWithDuration:0.25
                              delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             
                             flyer.frame = CGRectMake(MARGIN + [_filteredFavoritedFlyers indexOfObject:flyer]*self.frame.size.width, MARGIN, flyer.frame.size.width, flyer.frame.size.height);
                             flyer.alpha = 1;
                             flyer.hidden = NO;
        } completion:nil];
    }
    
    // Reload pagecontrol
    [_favdelegate modifyPageControllNumber:[_filteredFavoritedFlyers count]];
    [_favdelegate selectedPage:0];

}

// Reload beacons
- (void) flyerDidUnFav:(BeaconFlyer *)flyer
{
    // Delete flyer form arrays
    [_favoritedBeacons removeObjectAtIndex:[_favoritedFlyers indexOfObject:flyer]];
    [_favoritedFlyers removeObject:flyer];
    
    // Rearrange remaining flyers
    for (int i = 0; i<[_favoritedFlyers count]; i++) {
        
        BeaconFlyer *flyer = (BeaconFlyer *)_favoritedFlyers[i];
        
        [UIView animateWithDuration:0.25
                              delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             flyer.frame = CGRectMake(MARGIN + i*self.frame.size.width, MARGIN, flyer.frame.size.width, flyer.frame.size.height);
                             
                         } completion:nil];
    }
    
    [_favdelegate modifyPageControllNumber:[_favoritedFlyers count]];  
}

// Scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_favdelegate selectedPage:(round(scrollView.contentOffset.x / scrollView.bounds.size.width))];
}

// Flyer delegate
- (void) beaconDidExpand:(BeaconFlyer *)flyer toState:(BOOL)fullscreen
{
    // Expand viwed flyer
    if (fullscreen)
    {
        //Enlarge scrollview
        [_favdelegate scrollHadBeaconExpanded:YES];
        
        // Enlarge flyer
        [UIView animateWithDuration:0.3
                              delay:0.0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             flyer.frame = CGRectMake(flyer.frame.origin.x-MARGIN, flyer.frame.origin.y-MARGIN, self.frame.size.width, self.frame.size.height);
                             
                         } completion:nil];
    }
    else
    {
        //Minimize scrollview
        [_favdelegate scrollHadBeaconExpanded:NO];
        
        [UIView animateWithDuration:0.3
         
                              delay:0.0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             flyer.frame = CGRectMake(flyer.frame.origin.x+MARGIN, MARGIN, self.frame.size.width-MARGIN*2, self.frame.size.height-MARGIN*4);
                             
                         } completion:nil];      
    }
}

@end
