//
// IBM Confidential
// OCO Source Materials
// 5725-U96 © Copyright IBM Corp. 2015
// The source code for this program is not published or otherwise
// divested of its trade secrets, irrespective of what has
// been deposited with the U.S. Copyright Office.
//

#ifndef PIDeviceInfo_Header_h
#define PIDeviceInfo_Header_h

#import <Foundation/Foundation.h>

/**
 The default device type, "Internal"
 */
extern NSString * const DEVICE_INTERNAL;
/**
 The default device type, "External"
 */
extern NSString * const DEVICE_EXTERNAL;

/**
 Encapsulates the information that defines an device as reported to the PI server. The descriptor 
 is used to uniquely identify this device.
 */
@interface PIDeviceInfo : NSObject
/**
 Initializes the device with the given descriptor, name, and type
 @param descriptor - An identifier that is unique to this device
 @param name - Name of the device being registered
 @param type - The type of device. By default "Internal" and "External" types are supported, but this
 can be customized through the management console.
 */
-(instancetype)initWithDescriptor:(NSString *)descriptor andName:(NSString *)name andType:(NSString *)type;
/**
 Initializes the device with the given name using the deviceID as the descriptor and "External" as the type.
 By default the UUID of the device is used.
 @param name - Name of the device being registered
 @see https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIDevice_Class/#//apple_ref/occ/instp/UIDevice/identifierForVendor
 */
-(instancetype)initWithName:(NSString *)name;
/**
 Adds a device code to the device. The device code is returned from the API when the device is
 registered.
 @param code - The device code to assign to this device.
 */
-(instancetype)applyCode:(NSString *)code;
/**
 Add a single key/value pair to the metadata dictionary.
 @param key
 @param value
 */
-(void)addMetadataKey:(NSString *)key ValuePair:(NSString *)value;
/**
 Helper method to update device info of an existing device document
 @param dict - device payload from call to PI
 */
-(NSMutableDictionary *)addDeviceInfoToDictionary:(NSMutableDictionary *)dict;
/**
 * A unique string that will be used to uniquely identify this device.
 */
@property NSString *descriptor;
/**
 * The device type, as specified in the configuration console. By default the types allowed are
 "Internal" and "External"
 */
@property NSString *type;
/**
 A dictionary of additional meta data that can be associated with this device.
 */
@property NSMutableDictionary *metadata;
/**
 Description of the
 */
//AH: I'm not sure this should be here. This should be handled by the Adapter.
@property BOOL isRegistered;
/**
 The name used to identify this device.
 */
@property NSString *name;
/**
 The device code, which will only be filled in when the device is registered.
 */
@property NSString *code;
/**
 * Converts the DeviceInfo into the appropriate JSON format expected by the PI server
 */
-(NSDictionary *)toJSON;
@end

#endif
