//
//  HYPMathHelpers.h
//  Thyme
//
//  Created by Elvis Nunez on 02/12/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Helper Functions **/
#define DegToRad(deg)                 ( (M_PI * (deg)) / 180.0 )
#define RadToDeg(rad)                ( (180.0 * (rad)) / M_PI )
#define SQR(x)                        ( (x) * (x) )

@protocol HYPMathHelpers <NSObject>

@end
