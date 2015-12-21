//
// IBM Confidential
// OCO Source Materials
// 5725-U96 © Copyright IBM Corp. 2015
// The source code for this program is not published or otherwise
// divested of its trade secrets, irrespective of what has
// been deposited with the U.S. Copyright Office.
//

#ifndef PIBeaconSensorDelegate_Header_h
#define PIBeaconSensorDelegate_Header_h

#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>
#import "PIBeaconSensor.h"

@protocol PIBeaconSensorDelegate <NSObject>
- (void)didRangeBeacons:(NSArray *)beacons;
@end

#endif