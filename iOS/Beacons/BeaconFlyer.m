//
//  BeaconInfoV.m
//  Beacons
//
//  Created by Martí Serra Vivancos on 10/05/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import "BeaconFlyer.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import <Realm/Realm.h>
#import "SavedFavFlyer.h"

#define MARGIN 5
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation BeaconFlyer

bool dark = NO;
bool shareable = YES;
bool dontReport;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // View
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 4;
        
        // Border
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 0.5f;
        
        // Header
        _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
        [self addSubview:_header];
        
        // Web
        _webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 50, self.frame.size.width, self.frame.size.height-50)];
        _webview.delegate = self;
        _webview.scalesPageToFit = YES;
        _webview.backgroundColor = [UIColor whiteColor];
        _webview.opaque = NO;
        _webview.multipleTouchEnabled = YES;
        _webview.scrollView.bounces = YES;
        _webview.clipsToBounds = YES;
        [self addSubview:_webview];
        
        // Logo
        _logo = [[UIImageView alloc] initWithImage:nil];
        _logo.frame = CGRectMake( 0 , 0, 50, 50);
        _logo.clipsToBounds = YES;
        [self addSubview:_logo];
        
        // Title
        _title = [[UILabel alloc] initWithFrame:CGRectMake(60, 12, 0, 0)];
        [self addSubview:_title];
        
        // Buttons
        _expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_expandButton addTarget:self
                      action:@selector(expandContent)
            forControlEvents:UIControlEventTouchUpInside];
        [_expandButton setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
        _expandButton.frame = CGRectMake(self.frame.size.width-40, 11, 30, 30);
        _expandButton.showsTouchWhenHighlighted = YES;
        [self addSubview:_expandButton];
        
        _favButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_favButton addTarget:self
                    action:@selector(favFlyer)
          forControlEvents:UIControlEventTouchUpInside];
        [_favButton setImage:[UIImage imageNamed:@"nofav.png"] forState:UIControlStateNormal];
        _favButton.frame = CGRectMake(self.frame.size.width-76, 10, 30, 30);
        _favButton.showsTouchWhenHighlighted = YES;
        [self addSubview:_favButton];
        
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton addTarget:self
                 action:@selector(shareFlyer)
       forControlEvents:UIControlEventTouchUpInside];
        [_shareButton setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
        _shareButton.frame = CGRectMake(self.frame.size.width-114, 10, 30, 30);
        _shareButton.showsTouchWhenHighlighted = YES;
        [self addSubview:_shareButton];
        
        // Analytics
        _stats = [[NSMutableArray alloc]init];
        _tappedLinks = [[NSMutableArray alloc]init];
        
       
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                    selector: @selector(handleEnteredBackground)
                                                        name: UIApplicationDidEnterBackgroundNotification
                                                    object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleBeacomeActive)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil];
        
    }
    return self;
}

// Request url to server with ids
- (void) createBeaconFlyerWithCompanyId: (int)major  beaconId: (int)minor withCallback:(loadContentCallback)callback
{
    _callback = [callback copy];
    
    // Set new id values
    _companyId = major;
    _beaconId = minor;
    [self reloadFavButton];
    
    // Server calls
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    // Check if internet available
    if (networkStatus != NotReachable)
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager PUT:@"http://fernandezmir.com/beacons/api/beacons_info.php" parameters:
         @{@"major" : [NSNumber numberWithInt:major],
           @"minor" : [NSNumber numberWithInt:minor],
           @"user_id" : [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"]
        }
        success:^(AFHTTPRequestOperation *operation, id response) {
            
            NSLog(@"JSON: %@", response);
            
            if ([response[@"success"]boolValue]) {
                
                // Title style
                _title.text = response[@"header_title"];
                _title.font = [UIFont fontWithName:response[@"header_typography"] size:23];
                [_title sizeToFit];
                
                unsigned result = 0;
                NSScanner *scanner = [NSScanner scannerWithString:response[@"title_color"]];
                [scanner setScanLocation:1];
                [scanner scanHexInt:&result];
                _title.textColor = UIColorFromRGB(result);
                
                // Header color
                unsigned result2 = 0;
                NSScanner *scanner2 = [NSScanner scannerWithString:response[@"header_color"]];
                [scanner2 setScanLocation:1];
                [scanner2 scanHexInt:&result2];
                _header.backgroundColor = UIColorFromRGB(result2);
                
                // Favicon
                UIImage *favicon = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:response[@"header_favicon"]]]];
                _logo.image = favicon;
                
                // Button style
                if ([response[@"header_theme"] isEqualToString:@"black"]) {
                    dark = YES;
                    [_favButton setImage:[UIImage imageNamed:@"nofavD.png"] forState:UIControlStateNormal];
                    [_shareButton setImage:[UIImage imageNamed:@"shareD.png"] forState:UIControlStateNormal];
                    [_expandButton setImage:[UIImage imageNamed:@"expandD.png"] forState:UIControlStateNormal];
                    
                    // Check if is fav
                    [self reloadFavButton];
                }
                
                // Public
                if ([response[@"beacon_shareable"]boolValue]!=YES)
                {
                    _shareButton.hidden = YES;
                    shareable = NO;
                    _favButton.hidden = YES;
                
                } else  _share_link = response[@"share_link"];
               
                // Category
                _category = response[@"beacon_category"];
                
                // Load website
                NSURL *url = [[NSURL alloc] initWithString:response[@"content_path"]];
                NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
                [_webview loadRequest:request];
   
            }
            else
            {
                [_flyerdelegate flyerLoadingFailed:self];
                [self removeBeaconFlyerWithAnalytics:NO];
            }
          
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [_flyerdelegate flyerLoadingFailed:self];
            [self removeBeaconFlyerWithAnalytics:NO];
            
        }];
    }
    else
    {
        [_flyerdelegate flyerLoadingFailed:self];
        [self removeBeaconFlyerWithAnalytics:NO];
    }
}

// Webview did load content --> add flyer
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    _callback(YES);
}

// Did touch expand button for fullsize content
- (void) expandContent
{
    // Maximize
    if (!_fullscreen)
    {
        _fullscreen = YES;
        
        // Call delegate fkyer did expand
        [_flyerdelegate beaconDidExpand:self toState:YES];
        
        _header.alpha = 0;
        
        // Animations
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
            // Expand website
            _webview.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            
            // Other changes
            _logo.hidden = YES;
            _title.hidden = YES;
            self.layer.cornerRadius = 0.0f;
            self.layer.borderWidth = 0.0f;
            
            // Change buttons properties
            _expandButton.frame = CGRectMake(self.frame.size.width-35, 5, 30, 30);
            _expandButton.alpha = 0.6;
            [_expandButton setImage:[UIImage imageNamed:@"minimize.png"] forState:UIControlStateNormal];
        
            _favButton.hidden = YES;
            _shareButton.hidden = YES;

        } completion:nil];
    }

    // Minimize
    else
    {
        _fullscreen = NO;
        
        // Call delegate to expand flyer
        [_flyerdelegate beaconDidExpand:self toState:NO];
        
        _header.alpha = 1;
        
        // Animations
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            // Expand website
            _webview.frame = CGRectMake(0, 50, self.frame.size.width, self.frame.size.height-50);
            
            // Other changes
            _logo.hidden = NO;
            _title.hidden = NO;
             self.layer.cornerRadius = 5.0f;
             self.layer.borderWidth = 0.5f;
            
            // Change expand button properties
            _expandButton.frame = CGRectMake(self.frame.size.width-40, 11, 30, 30);
            _expandButton.alpha = 1;
            [_expandButton setImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
            if (dark) [_expandButton setImage:[UIImage imageNamed:@"expandD.png"] forState:UIControlStateNormal];
            
            _favButton.hidden = NO;
            if (shareable)
            {
                _shareButton.hidden = NO;
                _favButton.hidden = NO;
            }
            
        } completion:nil];
    }
}

// Check if beacon is favorited
- (void) reloadFavButton
{
    // Change button depending fav state and theme
   if ([self alreadyFavorited])
    {
        [_favButton setImage:[UIImage imageNamed:@"fav.png"] forState:UIControlStateNormal];
        if (dark)  [_favButton setImage:[UIImage imageNamed:@"favD.png"] forState:UIControlStateNormal];

    }
    else
    {
        [_favButton setImage:[UIImage imageNamed:@"nofav.png"] forState:UIControlStateNormal];
        if (dark)  [_favButton setImage:[UIImage imageNamed:@"nofavD.png"] forState:UIControlStateNormal];
    }    
}

// Add Beacon to favorites or delete it
- (void) favFlyer
{
    // Favorited & in favorites view -> show alert
    if ([self alreadyFavorited] & _inFavView)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                        message:@"You'll loose this beacon"
                                                       delegate:nil
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Sure", nil];
        alert.tag = 1;
        alert.delegate = self;
        [alert show];
    }
    
    // Favorited & in nearby view -> unfavorite it directly
    else if ([self alreadyFavorited] && !_inFavView)
    {
        [self deleteFromFavDB];
    }
    
    // Is not favorited -> favorite it
    else if (![self alreadyFavorited])
    {
        // Declare saved object
        SavedFavFlyer *favFlyer = [[SavedFavFlyer alloc]init];
        favFlyer.companyId = _companyId;
        favFlyer.beaconId = _beaconId;
        
        // Save object in Realm DB
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addObject:favFlyer];
        [realm commitWriteTransaction];
    }

    [self reloadFavButton];
}

// Check if flyer is already favorited
- (BOOL) alreadyFavorited
{
     BOOL alreadyFav = (BOOL)[[SavedFavFlyer objectsWhere:[NSString stringWithFormat:@"companyId == %i AND beaconId == %i", _companyId, _beaconId]]count];
    
    return alreadyFav;
}

// Delete favorited flyer from DB
- (void) deleteFromFavDB
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteObjects:[SavedFavFlyer objectsWhere:[NSString stringWithFormat:@"companyId == %i AND beaconId == %i", _companyId, _beaconId]]];
    [realm commitWriteTransaction];
}

// Unfavorite flyer alert
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex == 1) & (alertView.tag == 1))
    {
        [self deleteFromFavDB];
        [self removeBeaconFlyerWithAnalytics:NO];
        [_flyerdelegate flyerDidUnFav: self];
    }
}

// Share flyer 
- (void) shareFlyer
{
    NSString* sharingText = [NSString stringWithFormat:NSLocalizedString(@"SHARE_MESSAGE", @"Look at this!")];
    NSURL *url = [NSURL URLWithString:_share_link];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:sharingText, url, nil] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[ UIActivityTypeCopyToPasteboard ,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
  
    [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
       
        // Save which shared
        if ([activityType isEqual:UIActivityTypePostToFacebook]) _facebookShare++;
        if ([activityType isEqual:UIActivityTypePostToTwitter]) _twitterShare++;
        if ([activityType isEqual:UIActivityTypeMail]) _mailShare++;
        if ([activityType isEqual:UIActivityTypeMessage]) _messageShare++;
        
    }];
    
    UIViewController* mainController = (UIViewController*)  self.window.rootViewController;
    [mainController presentViewController:activityVC animated:YES completion:nil];
}

// WebView tapped links
-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        
        NSURL *url = inRequest.URL;
        [_tappedLinks addObject:url.absoluteString];
        
        dontReport = YES;
        
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        
        return NO;
    }
    return YES;
}



// Analytics
- (void) reportNewIntervalWithStartTime: (NSString *)start proximity:(int) proximity index:(int)index
{
    [_stats addObject:@{@"start_time" : start, @"distance" : [NSNumber numberWithInt:proximity]}];

}

// Report analytics if app goes background
- (void) handleEnteredBackground
{
    if (!dontReport) [self reportAnalytics:^(BOOL success){
       
    }];
}

- (void) handleBeacomeActive
{
    dontReport = NO;
}

// Remove flyer from superview
- (void) removeBeaconFlyerWithAnalytics:(BOOL) analytics
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        // Deletion animation
        self.center = CGPointMake(self.center.x, self.center.y-self.frame.size.height*1.5);
        self.alpha = 0;
        
    } completion:^(BOOL completed)
     {
         if (analytics) {
             [self reportAnalytics:^(BOOL success){
                 [self removeFromSuperview];
             }];
         }
         
         [self removeFromSuperview];
         
     }];
}

- (void) reportAnalytics:(reportedAnalyticsCallback)callback
{
    _analyticsCallback = [callback copy];
    
    NSLog(@"Reporting");
    
   // Create analytics dictionary
    NSDictionary *analytics = [[NSDictionary alloc] init];
    if (_inFavView) {
        analytics = @{
                                    @"user_id" : [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"],
                                    @"beacon_major" : [NSNumber numberWithInt:_companyId],
                                    @"beacon_minor": [NSNumber numberWithInt:_beaconId],
                                    @"beacon_shared": @{ @"facebook": [NSNumber numberWithInt:_facebookShare],
                                                         @"twitter" : [NSNumber numberWithInt:_twitterShare],
                                                         @"mail": [NSNumber numberWithInt:_mailShare],
                                                         @"message": [NSNumber numberWithInt:_messageShare]},
                                    @"beacon_favorited": @2,
                                    @"beacon_tappedLinks" : _tappedLinks,
                                   };
    }
    else{
        
        analytics = @{
                                    @"user_id" : [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"],
                                    @"beacon_major" : [NSNumber numberWithInt:_companyId],
                                    @"beacon_minor": [NSNumber numberWithInt:_beaconId],
                                    @"beacon_shared": @{ @"facebook": [NSNumber numberWithInt:_facebookShare],
                                                         @"twitter" : [NSNumber numberWithInt:_twitterShare],
                                                         @"mail": [NSNumber numberWithInt:_mailShare],
                                                         @"message": [NSNumber numberWithInt:_messageShare]},
                                    @"beacon_favorited": [self alreadyFavorited]? @1: @0,
                                    @"beacon_tappedLinks" : _tappedLinks,
                                    @"beacon_time_intervals": _stats};

    }
    
    NSLog(@"%@", analytics);
    
    // Report analytics to server
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager PUT:@"http://fernandezmir.com/beacons/api/analytics.php" parameters:analytics success:^(AFHTTPRequestOperation *operation, id response){
        
        NSLog(@"%@", response);
        if ([response[@"success"]boolValue]) {
            _analyticsCallback(YES);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     NSLog(@"%@", error);
    }];
}

@end
