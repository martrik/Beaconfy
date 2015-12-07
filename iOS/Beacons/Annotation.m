//
//  myAnnotation.m
//  MapView
//
//  Created by dev27 on 5/30/13.
//  Copyright (c) 2013 codigator. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation


-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subTitle:(NSString *)subTitle{
    
  if ((self = [super init])) {

    self.coordinate = coordinate;
    self.title = title;
    self.subtitle = subTitle;
  }
  return self;
}

- (id) initWithId:(int) id{
    
    if ((self = [super init])) {
        
        // Crides al server
    }
    return self;
}


@end
