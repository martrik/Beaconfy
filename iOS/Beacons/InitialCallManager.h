//
//  InitialCallManager.h
//  Beacons
//
//  Created by Martí Serra Vivancos on 26/08/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^initialCallback)(BOOL needUpdate);

@interface InitialCallManager : NSObject{
    
    initialCallback _callback;
}

+ (id)sharedManager;
- (void) makeCall:(initialCallback)callback;

@end
