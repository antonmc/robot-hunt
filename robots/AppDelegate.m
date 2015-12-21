//
//  AppDelegate.m
//  robots
//
//  Created by Anton McConville on 2014-12-31.
//  Copyright (c) 2014 IBM. All rights reserved.
//

#import "AppDelegate.h"
#import <TwitterKit/TwitterKit.h>
#import <Fabric/Fabric.h>

#import <IBMBluemix/IBMBluemix.h>
#import <IBMData/IBMData.h>
#import <CoreData/CoreData.h>

#import "RemoteHelp.h"
#import "Help.h"
#import "RobotRemote.h"
#import "Robot.h"
#import "ESTBeaconManager.h"
#import "ESTConfig.h"
#import "SBUIColor.h"
#import "ConfigData.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [ESTConfig setupAppID:nil andAppToken:nil];
    
    self.healthStore = [[HKHealthStore alloc] init];
    
    NSSet *shareObjectTypes  = [NSSet setWithObjects:nil];
    
    NSSet *readObjectTypes  = [NSSet setWithObjects:
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                               nil];
    

    
    if ( IDIOM == IPAD ) {
        /* Healthkit is not supported on iPads. */
    } else {
        
        [self.healthStore requestAuthorizationToShareTypes:shareObjectTypes
                                                 readTypes:readObjectTypes
                                                completion:^(BOOL success, NSError *error) {
                                                    
                                                    if(success == YES)
                                                    {
                                                        //                                               NSLog(@'Authorized');
                                                        
                                                        [self refreshStatistics];
                                                        
                                                    }
                                                    else
                                                    {
                                                        NSLog(@'Not Authorized');
                                                        
                                                        // Determine if it was an error or if the
                                                        // user just canceld the authorization request
                                                    }
                                                    
                                                }];
        
    }
    
    

    
    
    
    // Override point for customization after application launch.
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor colorwithHexString:@"17AF4B" alpha:0.5];
    pageControl.currentPageIndicatorTintColor = [UIColor colorwithHexString:@"17AF4B" alpha:1];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    [[Twitter sharedInstance] startWithConsumerKey:@"ySuqlYwlxAWmOyA09IwWHAzPE"
                                    consumerSecret:@"g0KGyljw1fdfBj8QxUCPoSMH8uuXlNfOkbiM30Pk6fQ9COVQZP"];
    [Fabric with:@[[Twitter sharedInstance]]];
    
    
    [[UITabBar appearance] setTintColor: [UIColor colorwithHexString:@"00b2ef" alpha:1] ];
    [[UITabBar appearance] setBarTintColor:[UIColor colorwithHexString:@"fbfafb" alpha:1] ];
    self.viewController.tabBarController.tabBar.layer.borderColor = (__bridge CGColorRef)([UIColor colorwithHexString:@"00b2ef" alpha:1]);
    
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorwithHexString:@"00b2ef" alpha:1] ];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    
    [IBMBluemix initializeWithApplicationId: @"4108d6c9-4b48-430f-a538-ab0c33b04f2e"
                       andApplicationSecret: @"63c05841728503c14a3807fa2f18eba5e04f803d"
                        andApplicationRoute: @"robot.mybluemix.net"];
    
    
    [IBMData initializeService];
    
    IBMQuery *qry = [RobotRemote query];
    
    [[qry find] continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            NSLog(@"listItems failed with error: %@", task.error);
        } else {
            
            NSMutableArray* robotList = [NSMutableArray arrayWithArray: task.result];
            
            for( RobotRemote* remoteRobot in robotList ){
                
                NSLog(@"Name: %@", remoteRobot.name);
                
                
                Robot *newRobot = [NSEntityDescription insertNewObjectForEntityForName:@"Robot"
                                                                          inManagedObjectContext:self.managedObjectContext];
                
                newRobot.name = remoteRobot.name;
                newRobot.about = remoteRobot.description;
                newRobot.mugshot = remoteRobot.mugshotBase64;
                newRobot.fullshot = remoteRobot.fullBase64;
                newRobot.iBeacon = remoteRobot.beacon;
                newRobot.primaryColor = remoteRobot.primaryColor;
                newRobot.secondaryColor = remoteRobot.secondaryColor;
                
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                
                newRobot.disruption = [ f numberFromString: remoteRobot.disruption  ];
            }
        }
    
        return nil;
    }];
    
    
    
    
    qry = [ConfigData query];
    
    [[qry find] continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            NSLog(@"listItems failed with error: %@", task.error);
        } else {
            
            NSMutableArray* configList = [NSMutableArray arrayWithArray: task.result];
            
            for( ConfigData* configItem in configList ){
                
                NSLog( @"Disruption Range: %@", configItem.disruptionRange );
                
                self.config = configItem;
                
            }
        }
        
        return nil;
    }];

    
    return YES;
}

- (NSPredicate *)predicateForSamplesToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *now = [NSDate date];
    NSDate *yesterday = [now dateByAddingTimeInterval: -86400.0];
    NSDate *lastMonth = [now dateByAddingTimeInterval: -5259487.66];
    NSDate *startDate = [calendar startOfDayForDate:yesterday];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:now options:0];
    
    return [HKQuery predicateForSamplesWithStartDate:yesterday endDate:now options:HKQueryOptionStrictStartDate];
}

- (void)fetchSumOfSamplesTodayForType:(HKQuantityType *)quantityType unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    NSPredicate *predicate = [self predicateForSamplesToday];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        HKQuantity *sum = [result sumQuantity];
        
        if (completionHandler) {
            double value = [sum doubleValueForUnit:unit];
            
            completionHandler(value, error);
        }
    }];
    
    [self.healthStore executeQuery:query];
}


-(Player*) getPlayer{
    return self.player;
}

-(NSArray*)getRobots
{
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Robot"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error;
    
    // Query on managedObjectContext With Generated fetchRequest
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Returning Fetched Records
    return fetchedRecords;
}

-(NSArray*)getHelp
{
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Help"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error;
    
    // Query on managedObjectContext With Generated fetchRequest
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Returning Fetched Records
    return fetchedRecords;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RobotModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"robots.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (void)refreshStatistics {
    
    HKQuantityType *stepcount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    // First, fetch the sum of energy consumed samples from HealthKit. Populate this by creating your
    // own food logging app or using the food journal view controller.
    [self fetchSumOfSamplesTodayForType:stepcount unit:[HKUnit unitFromString:@"count"] completion:^(double totalsteps, NSError *error) {
        
        // Next, fetch the sum of active energy burned from HealthKit. Populate this by creating your
        // own calorie tracking app or the Health app.
        [self fetchSumOfSamplesTodayForType:activeEnergyBurnType unit:[HKUnit jouleUnit] completion:^(double activeEnergyBurned, NSError *error) {
            
            double steps = totalsteps;
            

            double burn = activeEnergyBurned;

        }];
    }];
     
}






#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
