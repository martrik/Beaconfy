//
//  favoritedFlyer.h
//  Beacons
//
//  Created by Martí Serra Vivancos on 16/07/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import <Realm/Realm.h>

@interface SavedFavFlyer : RLMObject

@property int companyId;
@property int beaconId;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<favoritedFlyer>
RLM_ARRAY_TYPE(SavedFavFlyer)
