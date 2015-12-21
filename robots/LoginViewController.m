//
//  FirstViewController.m
//  robots
//
//  Created by Anton McConville on 2014-12-31.
//  Copyright (c) 2014 IBM. All rights reserved.
//

#import "LoginViewController.h"

#import <Foundation/Foundation.h>

#import <IBMBluemix/IBMBluemix.h>
#import <IBMData/IBMData.h>

#import "Player.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize logInButton;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // ** Don't forget to add NSLocationWhenInUseUsageDescription in MyApp-Info.plist and give it a string
    
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
//    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//        [self.locationManager requestWhenInUseAuthorization];
//    }
//    [self.locationManager startUpdatingLocation];
    
    TWTRLogInButton* newlogInButton =  [TWTRLogInButton
                                     buttonWithLogInCompletion:
                                     ^(TWTRSession* session, NSError* error) {
                                         if (session) {
                                             
                                             NSLog(@"signed in as %@", [session userName]);
                                             
                                             IBMQuery *qry = [Player query];
                                             
                                             [[qry find] continueWithBlock:^id(BFTask *task) {
                                                 if(task.error) {
                                                     NSLog(@"listItems failed with error: %@", task.error);
                                                 } else {
                                                     
                                                     BOOL playerFound = false;
                                                     
                                                     NSMutableArray* playerList = [NSMutableArray arrayWithArray: task.result];
                                                     
                                                     for( Player* player in playerList ){
                                                         
                                                         if( [ player.name isEqualToString: [ session userName ] ]){
                                                             
                                                             /* Player has played before - so we don't need to make a new
                                                                accound for them */
                                                             
                                                             NSLog( @"PLAYER FOUND" );
                                                             
                                                             playerFound = true;
                                                             
                                                             [self performSegueWithIdentifier:@"scanSegue" sender:self];
                                                             
                                                         }
                                                     }
                                                     
                                                     if( playerFound == false ){
                                                         
                                                         /* create a player account */
                                                         
                                                         Player* newPlayer = [[Player alloc] init];
                                                         
                                                         newPlayer.name = [ session userName ];
                                                         newPlayer.robots = [[NSMutableArray alloc] init ];
                                                         
                                                         [self getTwitterPersonalityData];
                                                         
                                                         [[newPlayer save] continueWithBlock:^id(BFTask *task) {
                                                             if(task.error) {
                                                                 NSLog(@"createItem failed with error: %@", task.error);
                                                             }
                                                             
                                                             [self performSegueWithIdentifier:@"scanSegue" sender:self];
                                                             
                                                             return nil;
                                                         }];
                                                     }
                                                 }
                                                 return nil;
                                                 
                                             }];
                                             
                                         } else {
                                             NSLog(@"error: %@", [error localizedDescription]);
                                         }
                                     }];
    
    logInButton.logInCompletion = newlogInButton.logInCompletion;
    
    [self performSegueWithIdentifier:@"scanSegue" sender:self];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)getTwitterPersonalityData {
    
    NSString *restUrl = [NSString stringWithFormat:@"http://localhost:3000/personality?id=antonmc"];
    
    NSURL *url = [NSURL URLWithString:restUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data.length > 0 && connectionError == nil) {
            NSDictionary *wpComments = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
//            for (id key in wpComments) {
//                NSInteger commentId = [[key objectForKey:@"ID"] integerValue];
//                NSMutableString *commentText = [[NSMutableString alloc] init];
//                [commentText appendString:[key objectForKey:@"content"]];
//                PostComment *pcom = [[PostComment alloc] initPostCommentWithComIdAndPostId:commentId postId:[postId integerValue] text:commentText];
//                [commentsToShow addObject:pcom];
//            }
        }
    }];
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
