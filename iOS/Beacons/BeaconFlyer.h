//
//  BeaconInfoV.h
//  Beacons
//
//  Created by Martí Serra Vivancos on 10/05/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"

@protocol BeaconFlyerDelegate;

typedef void (^loadContentCallback)(BOOL success);
typedef void (^reportedAnalyticsCallback)(BOOL success);

@interface BeaconFlyer : UIView <UIAlertViewDelegate, NSURLConnectionDataDelegate, UIWebViewDelegate>
{
    loadContentCallback _callback;
    reportedAnalyticsCallback _analyticsCallback;
}

// Ids
@property (nonatomic) int companyId;
@property (nonatomic) int beaconId;
@property (nonatomic) NSString *category;
@property (nonatomic) bool inFavView;
@property (nonatomic) bool fullscreen;

// Header
@property (nonatomic, retain) UIView *header;

// Company or beacon logo image
@property (nonatomic, strong) UIImageView *logo;

// Beacon title
@property (nonatomic, strong) UILabel *title;

// Buttons
@property (nonatomic, strong) UIButton *expandButton;
@property (nonatomic, strong) UIButton *favButton;
@property (nonatomic, strong) UIButton *shareButton;

// Content webview
@property (nonatomic, strong) UIWebView *webview;

// Social share
@property (nonatomic, strong) NSString *share_link;

// Server side
@property (nonatomic, strong) NSURLConnection *connection;

// Analytics
@property (nonatomic) int detectionProximity;
@property (nonatomic) int proximity;
@property (nonatomic) int facebookShare;
@property (nonatomic) int twitterShare;
@property (nonatomic) int mailShare;
@property (nonatomic) int messageShare;
@property (nonatomic) int didFullscreen;
@property (nonatomic) NSMutableArray *tappedLinks;

@property (nonatomic, strong) NSMutableArray *stats;
- (void) reportNewIntervalWithStartTime: (NSString *)start proximity:(int) proximity index:(int)index;

// Delegate
@property (assign, nonatomic) id<BeaconFlyerDelegate> flyerdelegate;

// Load beacon flyer
- (void) createBeaconFlyerWithCompanyId: (int)major  beaconId: (int)minor withCallback:(loadContentCallback)callback;

// Reload fav button
- (void) reloadFavButton;

// Delete beacon flyer
- (void) removeBeaconFlyerWithAnalytics:(BOOL) analytics;

@end

// Delegate protocol
@protocol BeaconFlyerDelegate <NSObject>

- (void) beaconDidExpand:(BeaconFlyer *)flyer toState: (BOOL) fullscreen ;

- (void) flyerDidUnFav:(BeaconFlyer *) flyer;

- (void) flyerLoadingFailed:(BeaconFlyer *) flyer;

@end
