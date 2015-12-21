//
// IBM Confidential
// OCO Source Materials
// 5725-U96 © Copyright IBM Corp. 2015
// The source code for this program is not published or otherwise
// divested of its trade secrets, irrespective of what has
// been deposited with the U.S. Copyright Office.
//

#ifndef PIRangedBraconData_Header_h
#define PIRangedBraconData_Header_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 Encapsulates the information reported when a beacon is ranged
 */
@interface PIRangedBeaconData : NSObject

/**
 Initializes a PIRangedBeaconData with the given CLBeacon at the given detected time.
 @param beacon The beacon that was ranged.
 @param detectedTime The time at which the beacon was detected
 */
-(instancetype)initBeacon:(CLBeacon *)beacon atDetectedTime:(NSDate *)detectedTime;
/**
 The Proximity UUID of the beacon
 */
@property (readonly) NSUUID *uuid;
/**
 The major id of the beacon
 */
@property (readonly) NSNumber *major;
/**
 The minor id of the beacon
 */
@property (readonly) NSNumber *minor;
/**
 The accuracy, in meters, of the beacon's proximity.
 */
@property (readonly) CLLocationAccuracy accuracy;
/**
 The RSSI value of the ranged beacon
 */
@property (readonly) NSInteger rssi;
/**
 The proximity of the beacon (Immediate, Near, Far, & Unknown)
 */
@property (readonly) CLProximity proximity;
/**
 The time that the beacon was detected
 */
@property (readonly) NSDate *detectedTime;
/**
 The descriptor of this device.
 */
@property (readonly) NSString *deviceDescriptor;
/**
 The ranged beacon.
 */
@property (readonly) CLBeacon *beacon;
/**
 Converts the BeaconData to JSON
 */
-(NSDictionary *)toJSON;

@end

#endif
