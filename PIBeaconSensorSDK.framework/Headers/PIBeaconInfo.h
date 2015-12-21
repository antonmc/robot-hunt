//
// IBM Confidential
// OCO Source Materials
// 5725-U96 © Copyright IBM Corp. 2015
// The source code for this program is not published or otherwise
// divested of its trade secrets, irrespective of what has
// been deposited with the U.S. Copyright Office.
//

#ifndef PIBeaconSensorSDK_PIBeaconInfo_h
#define PIBeaconSensorSDK_PIBeaconInfo_h

#import <Foundation/Foundation.h>

@interface PIBeaconInfo : NSObject

-(instancetype)initWithAPIObject:(NSDictionary *)APIObject;

@property NSString * name;

@property NSNumber * x;

@property NSNumber * y;

@property NSString * proximityUUID;

@property NSString * descriptor;

@property NSDictionary * updated;

@property NSString * code;

-(NSDictionary *)toJSON;

@end

#endif
