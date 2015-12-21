//
//  RobotViewController.m
//  robots
//
//  Created by Anton McConville on 2015-01-16.
//  Copyright (c) 2015 IBM. All rights reserved.
//

#import "RobotViewController.h"
#import "AppDelegate.h"
#import "SBUIColor.h"

@import HealthKit;


@interface RobotViewController ()

@property TextToSpeech *tts;

@end

@implementation RobotViewController

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@synthesize progress;
@synthesize disruptionCode;
@synthesize beaconID;
@synthesize robotPic;

AppDelegate * appDelegate;

Robot *robot;

NSArray *knowledge;

NSArray *robots;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TTSConfiguration *conf = [[TTSConfiguration alloc] init];
    
    [conf setBasicAuthUsername:@"31d9fe64-b35d-4be2-ae9c-40921cd89878"];
    [conf setBasicAuthPassword:@"Yodiyv6h9dFx"];
    
    [conf setVoiceName:@"en-US_MichaelVoice"];
    
    self.tts = [TextToSpeech initWithConfig:conf];

    
    appDelegate = [UIApplication sharedApplication].delegate;
    
    self.navigationItem.hidesBackButton = YES;
    // Do any additional setup after loading the view.
    
    progress.textColor=[UIColor colorwithHexString:@"00B2CA" alpha:1]; /*#d15600*/
    
    NSString *timeString = @"Time : 0:";
    NSString *timeText = [ timeString stringByAppendingString: appDelegate.config.disruptionTime ];
    
    [progress setText:timeText];
    progress.backgroundColor=[UIColor clearColor];
    currMinute=0;
    currSeconds= [ appDelegate.config.disruptionTime intValue ];
    
    robots = [appDelegate getRobots];
    
    NSString *id = [ self.beaconID stringValue ];
    
    for( int count=0; count < robots.count; count++ ){
        
        robot = robots[count];
        
        if( [robot.iBeacon isEqualToString: id ] ){
            
            self.navigationItem.title = robot.name;
            
            NSData* imageData = [ self base64DataFromString: robot.fullshot ];
            
            robotPic.image = [UIImage imageWithData:imageData];

            self.thisRobot = robot;
            
            break;
        }
    }
    
    [ self start ];
}

- (void)speak:(NSString* )message{
    
    [self.tts synthesize:^(NSData *data, NSError *err) {
        
        // play audio and log when playing has finished
        [self.tts playAudio:^(NSError *err) {
            
            if(!err)
                NSLog(@"audio finished playing");
            else
                NSLog(@"error playing audio %@",err.localizedDescription);
            
        } withData:data];
        
    } theText:message];
}

- (NSData *)base64DataFromString: (NSString *)string
{
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[3];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
    
    if (string == nil)
    {
        return [NSData data];
    }
    
    ixtext = 0;
    
    tempcstring = (const unsigned char *)[string UTF8String];
    
    lentext = [string length];
    
    theData = [NSMutableData dataWithCapacity: lentext];
    
    ixinbuf = 0;
    
    while (true)
    {
        if (ixtext >= lentext)
        {
            break;
        }
        
        ch = tempcstring [ixtext++];
        
        flignore = false;
        
        if ((ch >= 'A') && (ch <= 'Z'))
        {
            ch = ch - 'A';
        }
        else if ((ch >= 'a') && (ch <= 'z'))
        {
            ch = ch - 'a' + 26;
        }
        else if ((ch >= '0') && (ch <= '9'))
        {
            ch = ch - '0' + 52;
        }
        else if (ch == '+')
        {
            ch = 62;
        }
        else if (ch == '=')
        {
            flendtext = true;
        }
        else if (ch == '/')
        {
            ch = 63;
        }
        else
        {
            flignore = true;
        }
        
        if (!flignore)
        {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
            
            if (flendtext)
            {
                if (ixinbuf == 0)
                {
                    break;
                }
                
                if ((ixinbuf == 1) || (ixinbuf == 2))
                {
                    ctcharsinbuf = 1;
                }
                else
                {
                    ctcharsinbuf = 2;
                }
                
                ixinbuf = 3;
                
                flbreak = true;
            }
            
            inbuf [ixinbuf++] = ch;
            
            if (ixinbuf == 4)
            {
                ixinbuf = 0;
                
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                
                for (i = 0; i < ctcharsinbuf; i++)
                {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
            if (flbreak)
            {
                break;
            }
        }
    }
    
    return theData;
}


- (void) viewDidAppear:(BOOL)animated{
    [disruptionCode bringSubviewToFront:self.view];
//    [disruptionCode becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)start
{
    
    NSString *greeting = @"You found me. I am ";
    
    greeting = [greeting stringByAppendingString:self.thisRobot.name];
    
    [self speak:greeting];
    
    timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

-(void)timerFired
{
    if((currMinute>0 || currSeconds>=0) && currMinute>=0)
    {
        if(currSeconds==0)
        {
            currMinute-=1;
            currSeconds=59;
        
        }else if(currSeconds>0)
        {
            currSeconds-=1;
        }
        
        if(currMinute>-1)
            [progress setText:[NSString stringWithFormat:@"%@%d%@%02d",@"Time : ",currMinute,@":",currSeconds]];
    }
    else
    {
        
        [ self setStatus:@"failed" ];
        
//        [[appDelegate.player save] continueWithBlock:^id(BFTask *task) {
//            if(task.error) {
//                NSLog(@"updateItem failed with error: %@", task.error);
//            }else{
//                
//                NSString* title = [NSString stringWithFormat:@"%@ caught you!", self.thisRobot.name ];
//                
//                NSString *found = @"I caught you";
//                
////                [self performSelector:@selector(finish)
////                           withObject:found
////                           afterDelay:4.0];
//                
//                [self finish:found];
//
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
//                                                                message:@"You've lost a disruption point."
//                                                               delegate:self
//                                                      cancelButtonTitle:@"OK"
//                                                      otherButtonTitles:nil];
//                
//                [alert show];
//            }
//            return nil;
//        }];

        
        [timer invalidate];
        
    }
}

- (NSMutableArray*) shuffledArrayFromArray:(NSArray *)original {
    NSMutableArray *shuffled = [NSMutableArray array];
    NSUInteger count = [original count];
    if (count > 0) {
        [shuffled addObject:[original objectAtIndex:0]];
        
        NSUInteger j;
        for (NSUInteger i = 1; i < count; ++i) {
            j = arc4random() % i; // simple but may have a modulo bias
            [shuffled addObject:[shuffled objectAtIndex:j]];
            [shuffled replaceObjectAtIndex:j
                                withObject:[original objectAtIndex:i]];
        }
    }
    
    return shuffled; // still autoreleased
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [ self performSegueWithIdentifier:@"returnToScanner" sender:self];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    if (textField == self.disruptionCode) {
    
    textField.text = @"";
    
        NSLog( @"text:%@", textField.text );
//        textField.text = @"Don't edit me!";
//    }
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSUInteger len = [newString length];
    
    if( len == 4 ){
    
        if( [newString isEqualToString:[ self.thisRobot.disruption stringValue ] ] ){
        
            int lowerBound = 0;
            int upperBound = 1;
            int choice = lowerBound + arc4random() % (upperBound - lowerBound);            
            
            [ self setStatus:@"disrupted" ];
//            
//            [[appDelegate.player save] continueWithBlock:^id(BFTask *task) {
//                if(task.error) {
//                    NSLog(@"updateItem failed with error: %@", task.error);
//                }else{
//                    
//                    NSString* title = [NSString stringWithFormat:@"Well done!" ];
//                    
//                    NSString *found = @"You've disrupted me.";
//                    
////                    [self performSelector:@selector(finish)
////                               withObject:found
////                               afterDelay:4.0];
////                    
//                    [self finish:found];
//
//                    
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
//                                                                    message: [ NSString stringWithFormat:@"You've disrupted %@ .", self.thisRobot.name ]
//                                                                   delegate:self
//                                                          cancelButtonTitle:@"OK"
//                                                          otherButtonTitles:nil];
//                    
//                    [alert show];
//                    
//                }
//                return nil;
//            }];
            
            
            [timer invalidate];
            
        }else{
            
            /* they've entered the wrong four digit code */
            
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            textField.text = nil;
            return NO;
        }
    }

    return YES;
}

-(void) finish:(NSString*)found{
    
    
    NSString *greeting =@"";
    
    int lowerBound = 0;
    int upperBound = 1;
    int choice = lowerBound + arc4random() % (upperBound - lowerBound);
    
    if(choice == 0){
        
        NSMutableArray* shuffledTraits = [self shuffledArrayFromArray:appDelegate.player.traits];
        
        greeting = [greeting stringByAppendingString:@"I have learned that you're interested in: "];
        
        if( [shuffledTraits count] > 3 ){
        
            for(int t = 0; t < 4;t++){
                greeting = [greeting stringByAppendingString:shuffledTraits[t]];
                greeting = [greeting stringByAppendingString:@", "];
            }
        }
        
    }else{
        
        greeting = [greeting stringByAppendingString:@"I have learned that you're from: "];
        
        greeting = [greeting stringByAppendingString:appDelegate.player.location];
    }
    
//    greeting =[found stringByAppendingString:greeting];
    
    [self speak:greeting];
    
}


- (void) setStatus:(NSString*)status {
    
    for( int count = 0; count < appDelegate.player.robots.count; count++ ){

        NSMutableDictionary* robotStatus = [ appDelegate.player.robots objectAtIndex:count ];
        
        if( [ [ robotStatus objectForKey: @"name" ] isEqualToString: self.thisRobot.name ] ){
            
            [ robotStatus setObject:status forKey: @"status" ];
            
            [ robotStatus setObject:[ self timeStamp ] forKey:@"timestamp"];
            
            NSString* seconds = [NSString stringWithFormat:@"%d", currSeconds];
            
            if( [status isEqualToString:@"failed" ] ){

                seconds = @"0";
            }
            
            [ robotStatus setObject: seconds forKey:@"disruptionSeconds"];
            
            if ( IDIOM == IPAD ) {
                /* Healthkit is not supported on iPads. */
            } else {
            
                HKQuantityType *stepcount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
            
                [self fetchSampleSteps:stepcount unit:[HKUnit unitFromString:@"count"] completion:^(double totalsteps, NSError *error) {
                
                    if( totalsteps == 0 ){
                        totalsteps = 7;
                    }
                
                    NSNumber* s = [NSNumber numberWithDouble:totalsteps];
                
                    [ robotStatus setObject:s forKey: @"steps" ];
                
                    NSString* stepMessage = @"you took ";
                
                    stepMessage =[stepMessage stringByAppendingString:[s stringValue]];
                
                    stepMessage = [stepMessage stringByAppendingString:@" steps to find me"];
                
//                  [self speak: stepMessage];
                
                }];
            }
            
            break;
        }
    }
}

- (NSString *) timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
}

- (NSPredicate *)predicateForSamplesOnThisRobot {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *begin = appDelegate.player.startTime;
    NSDate *now = [NSDate date];
//    NSDate *yesterday = [now dateByAddingTimeInterval: -86400.0];
//    NSDate *lastMonth = [now dateByAddingTimeInterval: -5259487.66];
//    NSDate *startDate = [calendar startOfDayForDate:yesterday];
//    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:now options:0];
    
    return [HKStatisticsCollectionQuery predicateForSamplesWithStartDate:begin endDate:now  options:HKQueryOptionStrictStartDate];
}

- (void)fetchSampleSteps:(HKQuantityType *)quantityType unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    NSPredicate *predicate = [self predicateForSamplesOnThisRobot];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        HKQuantity *sum = [result sumQuantity];
        
        if (completionHandler) {
            double value = [sum doubleValueForUnit:unit];
            
            completionHandler(value, error);
        }
    }];
    
    [appDelegate.healthStore executeQuery:query];
}

- (void)refreshStatistics {
    
    HKQuantityType *stepcount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

    [self fetchSampleSteps:stepcount unit:[HKUnit unitFromString:@"count"] completion:^(double totalsteps, NSError *error) {
        
    }];
    
}


-(void)textFieldDidChange:(UITextField *)theTextField
{
    NSLog( @"text changed: %@", theTextField.text);
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    
    BOOL outcome = NO;
    
//    if( textField.text.length > 4 ){
//        outcome = YES;
//    }
//    
//       if( [textField.text isEqualToString: [ self.thisRobot.disruption stringValue ] ] ) {
//        return YES;
//    }
    return outcome;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
