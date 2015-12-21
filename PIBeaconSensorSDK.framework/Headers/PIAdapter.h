//
// IBM Confidential
// OCO Source Materials
// 5725-U96 © Copyright IBM Corp. 2015
// The source code for this program is not published or otherwise
// divested of its trade secrets, irrespective of what has
// been deposited with the U.S. Copyright Office.
//

#ifndef PIAdapter_Header_h
#define PIAdapter_Header_h

#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>
#import "PIRangedBeaconData.h"
#import "PIDeviceInfo.h"
/**
 Provides a set of helper functions for the management server REST API.
 @see https://presenceinsights.stage1-dev.ng.bluemix.net/pi-swagger/ for documentation regarding
 all the APIs.
 */
@interface PIAdapter : NSObject

@property (nonatomic, strong) NSURL    *managementUrl;
@property (nonatomic, strong) NSString *tenantCode;
@property (nonatomic, strong) NSString *orgCode;
@property (nonatomic, strong) NSString *encodedUserPass;
/**
 Creates a PIAdapter and initializes it with the given tenant and organization codes.
 @param tenantCode The code associated with your tenant acccount.
 @param orgCode The code associated with your organization account.
 @param username The username used in beacon notifications
 @param password The password used in beacon notifications
 @return BFTask that will resolve if successfully connected to the server.
 */
-(instancetype)initWithTenantCode:(NSString *)tenantCode andOrgCode:(NSString *)orgCode withUsername:(NSString *)username andPassword:(NSString *)password;
/**
 Creates a PIAdapter and initializes it with the given tenant and organization codes.
 @param tenantCode The code associated with your tenant acccount.
 @param orgCode The code associated with your organization account.
 @param username The username used in beacon notifications
 @param password The password used in beacon notifications
 @return BFTask that will resolve if successfully connected to the server.
 */
+(instancetype)adapterWithTenantCode:(NSString *)tenantCode andOrgCode:(NSString *)orgCode withUsername:(NSString *)username andPassword:(NSString *)password;

/**
 Sends the given beaconData to the PI server
 @param beaconData An array of PIRangedBeaconData objects.
 @return BFTask that will resolve if the server accepts the beacon data.
 */
-(BFTask *)notifyRangedBeaconData:(NSArray *)beaconData;

/**
 Tests to ensure it can communicate with the config server.
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)testConfigServer;

/**
 Retrieves the proximity UUIDs associated with this tenant and organization.
 @return BFTask that will resolve on an NSArray of proximity UUID strings.
 */
-(BFTask *)retrieveProximityUUIDs;
/**
 Registers the given device for this tenant and organization, using the descriptor as the identifier.
 Will also assign the device code to the provided PIDeviceInfo object.
 @param deviceInfo The deviceInfo you wish to use to register this device. Note: The isRegistered field will be set to true
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)registerDevice:(PIDeviceInfo *)deviceInfo;
/**
 Unregisters the given device for this tenant and organization, using the descriptor as the identifier.
 @param deviceInfo The deviceInfo you wish to use to unregister this device. Note: The isRegistered field will be set to false
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)unregisterDevice:(PIDeviceInfo *)deviceInfo;
/**
 Updates the given device for this tenant and organization, using the descriptor as the identifier.
 @param deviceInfo The deviceInfo you wish to use to update this device.
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)updateDevice:(PIDeviceInfo *)deviceInfo;
/**
 Retrieves the map associated with the given site and floor.
 @param siteCode The siteCode associated with this map.
 @param floorCode The floorCode associated with this map.
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getFloorMapForSite:(NSString *)siteCode andFloor:(NSString *)floorCode;
/**
 Retrieves configuration information for the given beacon.
 @param beaconCode The beaconCode associated with this beacon.
 @param siteCode The siteCode associated with this beacon.
 @param floorCode The floorCode associated with this beacon.
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getBeacon:(NSString *)beaconCode atSite:(NSString *)siteCode andFloor:(NSString *)floorCode;
/**
 Retrieves configuration information for the given site and floor.
 @param siteCode The siteCode
 @param floorCode The floorCode
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getAllBeaconsAtSite:(NSString *)siteCode andFloor:(NSString *)floorCode;

/**
 Retrieves configuration information for the given device.
 @param deviceCode The deviceCode
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getDevice:(NSString *)deviceCode;
/**
 Retrieves configuration information for the given floor and site.
 @param floorCode The floorCode
 @param siteCode The siteCode
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getFloor:(NSString *)floorCode atSite:(NSString *)siteCode;
/**
 Retrieves configuration information for all floors at the given site.
 @param siteCode The siteCode
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getAllFloorsForSite:(NSString *)siteCode;
/**
 Retrieves configuration information for the org associated with this adapter.
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getOrg;
/**
 Retrieves configuration information for all organizations under the tenant
 associate with this adapter.
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getAllOrgs;
/**
 Retrieves configuration information for the specified sensor
 @param sensorCode The sensorCode
 @param siteCode The siteCode
 @param floorCode The floorCode
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getSensor:(NSString *)sensorCode atSite:(NSString *)siteCode andFloor:(NSString *)floorCode;
/**
 Retrieves all sensors for on the given floor.
 @param siteCode The siteCode
 @param floorCode The floorCode
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getAllSensorsAtSite:(NSString *)siteCode andFloor:(NSString *)floorCode;
/**
 Retrieves configuration information for the given site.
 @param siteCode The siteCode
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getSite:(NSString *)siteCode;
/**
 Retrieves configuration information for all sites associated with tenant
 and organization associated with this
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getAllSites;
/**
 Retrieves the configuration information for the tenant associated with this
 adapter.
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getTenant;
/**
 Retrieves the configuration information for the given zone.
 @param zoneCode the zoneCode
 @param siteCode The siteCode
 @param floorCode The floorCode
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getZone:(NSString *)zoneCode atSite:(NSString *)siteCode andFloor:(NSString *)floorCode;
/**
 Retrieves all zones on the given floor.
 @param siteCode The siteCode
 @param floorCode The floorCode
 @return BFTask that will resolve if the server responds successfully.
 */
-(BFTask *)getAllZonesAtSite:(NSString *)siteCode andFloor:(NSString *)floorCode;

@end

#endif