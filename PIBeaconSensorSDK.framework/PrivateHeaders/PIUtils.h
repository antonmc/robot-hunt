//
// IBM Confidential
// OCO Source Materials
// 5725-U96 © Copyright IBM Corp. 2015
// The source code for this program is not published or otherwise
// divested of its trade secrets, irrespective of what has
// been deposited with the U.S. Copyright Office.
//


#ifndef PIUtils_h
#define PIUtils_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Bolts/Bolts.h>

#define TAG_INFO     @"INFO"
#define TAG_DEBUG    @"DEBUG"
#define TAG_ERROR    @"ERROR"
#define TAG_WARN     @"WARN"
#define TAG_FATAL    @"FATAL"
#define TAG_ENTERING @"ENTER"
#define TAG_EXITING  @"EXIT"

#define PI_LOCAL_HOST                           @"http://localhost:3000"
#define PI_DEV_HOST                             @"https://presenceinsights.stage1-dev.ng.bluemix.net"
#define PI_TEST_HOST                            @"https://presenceinsights.stage1-test.ng.bluemix.net"
#define PI_STAGE_HOST                           @"https://presenceinsights.stage1.ng.bluemix.net"
#define PI_PROD_HOST                            @"https://presenceinsights.ng.bluemix.net"
#define PI_CONFIG_URI_SEGMENT                   @"pi-config/v1/"
#define PI_HEALTH_URI_SEGMENT                   @"health"
#define PI_UUID_URI_SEGMENT                     @"views/proximityUUID"
#define PI_ERROR_DOMAIN                         @"com.ibm.presenceinsights"
#define PI_TENANT_ORG_SEGMENT(tenant, org)      STR_F(@"tenants/%@/orgs/%@/", tenant, org)
#define PI_BEACON_URI_SEGMENT(tenant, org)      STR_F(@"conn-beacon/%@", PI_TENANT_ORG_SEGMENT(tenant, org))

//UPDATE TO CHANGE DEFAULT HOST
#define PI_HOST                PI_PROD_HOST

#define STR_F(s, ...)          [NSString stringWithFormat:(s), ##__VA_ARGS__]
#define PI_LOG_ERROR(s, ...)   PI_LOG(TAG_ERROR,    STR_F(s, ##__VA_ARGS__))
#define PI_LOG_DEBUG(s, ...)   PI_LOG(TAG_DEBUG,    STR_F(s, ##__VA_ARGS__))
#define PI_LOG_INFO(s, ...)    PI_LOG(TAG_INFO,     STR_F(s, ##__VA_ARGS__))
#define PI_LOG_WARN(s, ...)    PI_LOG(TAG_WARN,     STR_F(s, ##__VA_ARGS__))
#define PI_LOG_ERROR(s, ...)   PI_LOG(TAG_ERROR,    STR_F(s, ##__VA_ARGS__))
#define PI_LOG_FATAL(s, ...)   PI_LOG(TAG_FATAL,    STR_F(s, ##__VA_ARGS__))
#define LOG_ENTERING(s, ...)   PI_LOG(TAG_ENTERING, STR_F(s, ##__VA_ARGS__))
#define LOG_EXITING(s, ...)    PI_LOG(TAG_EXITING,  STR_F(s, ##__VA_ARGS__))
#define LOG_ENTER              PI_LOG(TAG_ENTERING, @"")
#define LOG_EXIT               PI_LOG(TAG_EXITING,  @"")
#define PI_LOG(LVL, s)         NSLog(@"%s [%@] %@", __FUNCTION__, LVL, s)
#define PI_BASE_URL [NSURL URLWithString: PI_HOST]
#define PI_URL(uri) [NSURL URLWithString: uri relativeToURL: PI_BASE_URL]
#define PI_URL_APPEND(base, uri) [base URLByAppendingPathComponent: uri]

extern NSString *const PIErrorDomain;

NS_ENUM(NSUInteger, PIErrorCode){
    PIAdapterError = 42,
    PIBeaconSensorError
};

@interface PIError : NSError
+(instancetype)errorWithErrorCode:(NSInteger)code andDescripton:(NSString *)desc;
-(instancetype)initWithErrorCode:(NSInteger)code andDescription:(NSString *)desc;
+(NSDictionary *)createUserInfoWithDescription:(NSString *)desc;
@end

@interface PIHTTPURLs : NSObject
+(NSURL *)URLForHost;
+(NSURL *)URLForConfig;
+(NSURL *)URLforTenant:(NSString *)tenantCode andOrg:(NSString *)orgCode;
+(NSURL *)URLConfigHealth;
+(NSURL *)URLForUUIDForTenant:(NSString *)tenantCode andOrg:(NSString *)orgCode;
//+(NSURL *)URLForSite:(NSString *)siteCode;
//+(NSURL *)URLForSite:(NSString *)siteCode andFloor:(NSString *)floorCode;
@end

@interface PIUtils : NSObject
+(NSString *)CLAuthorizationStatusToString:(CLAuthorizationStatus)status;
+(NSString *)CLRegionStateToString:(CLRegionState)state;
@end

@interface PIMaybe : NSObject

@property (readwrite)      id  value;
@property (readwrite) NSError *error;

+(PIMaybe *) some: (id)data withError: (NSError*)error;
+(PIMaybe *) some: (id)data;
+(PIMaybe *) someError: (NSError *)error;
+(PIMaybe *) none;

-(NSString *) errorMsg;

@end

#endif
