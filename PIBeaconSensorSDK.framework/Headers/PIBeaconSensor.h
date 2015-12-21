//
// IBM Confidential
// OCO Source Materials
// 5725-U96 © Copyright IBM Corp. 2015
// The source code for this program is not published or otherwise
// divested of its trade secrets, irrespective of what has
// been deposited with the U.S. Copyright Office.
//

#ifndef PIBeaconSensor_Header_h
#define PIBeaconSensor_Header_h

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>
#import "PIAdapter.h"
#import "PIBeaconSensorDelegate.h"

/**
 Monitors and ranges for beacons using the proximity UUIDs specified in the
 PI configuration console.
 */
@interface PIBeaconSensor : NSObject<CLLocationManagerDelegate>
/**
 The adapter that contains information relevant to communicate with the PI server
 */
@property (readonly) PIAdapter *adapter;
/**
 The delegate that, when specified, will be notified on various beacon events.
 */
@property id<PIBeaconSensorDelegate> delegate;
/**
 Creates a sensor with the given adapter.
 @param adapter - The Adapter that handles commmunication to the PI server
 @returns A new PIBeaconSensor
 */
+(instancetype)sensorWithAdapter:(PIAdapter*)adapter;
/**
 Creates a sensor with the given adapter.
 @param adapter - The Adapter that handles commmunication to the PI server
 */
-(instancetype)initWithAdapter:(PIAdapter *)adapter;

/**
 Starts monitoring for beacons using the proximity UUIDs specified in the
 PI configuration console.
 @returns A BFTask that resolves the task if it's able to retrieve the proximity
 UUIDs from the server, and rejects the task if there's a problem communicating
 with the server.
 */
-(BFTask *)start;
/**
 Stops monitoring for beacons.
 */
-(BFTask *)stop;

@end
#endif