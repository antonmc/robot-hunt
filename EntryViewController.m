//
//  ViewController.m
//  PageViewDemo
//
//  Created by Simon on 24/11/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "EntryViewController.h"
#import "AppDelegate.h"
#import <IBMData/IBMData.h>

#import "RemoteHelp.h"
#import "Help.h"
#import "Player.h"
#import "Robot.h"

#import <CloudantSync.h>


@import HealthKit;

@interface EntryViewController ()

@property TextToSpeech *tts;

@end

@implementation EntryViewController

@synthesize logInButton;

AppDelegate *appDelegate;

NSArray *help;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
   
    
    
    [ logInButton setHidden: TRUE ];
    
    TTSConfiguration *conf = [[TTSConfiguration alloc] init];
    
    [conf setBasicAuthUsername:@"31d9fe64-b35d-4be2-ae9c-40921cd89878"];
    [conf setBasicAuthPassword:@"Yodiyv6h9dFx"];
    
    [conf setVoiceName:@"en-US_MichaelVoice"];
    
    self.tts = [TextToSpeech initWithConfig:conf];
    
    IBMQuery *qry = [RemoteHelp query];
    
    [[qry find] continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            NSLog(@"listItems failed with error: %@", task.error);
        } else {
            
            appDelegate = [UIApplication sharedApplication].delegate;

            
            NSMutableArray* helpList = [NSMutableArray arrayWithArray: task.result];
            
            for( RemoteHelp* help in helpList ){
                
                NSLog(@"Title: %@", help.title);
                
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle = NSNumberFormatterDecimalStyle;
               
                
                Help *newHelp = [NSEntityDescription insertNewObjectForEntityForName:@"Help" inManagedObjectContext:appDelegate.managedObjectContext];
                
                newHelp.title = help.title;
                newHelp.image = help.image;
                newHelp.subtitle = help.subtext;
                newHelp.screen = [ formatter numberFromString:help.screen  ];
                newHelp.size = help.size;
                newHelp.weight = help.weight;
                newHelp.justification = help.justification;
                newHelp.color = help.color;
            }
            
            NSArray* unsorted = [appDelegate getHelp];
            
            NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"screen" ascending:YES]];
            help = [unsorted sortedArrayUsingDescriptors:sortDescriptors];
            
            // Create page view controller
            self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
            self.pageViewController.dataSource = self;
            
            PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
            NSArray *viewControllers = @[startingViewController];
            [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            
            // Change the size of page view controller
            self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
            
            [self addChildViewController:_pageViewController];
            [self.view addSubview:_pageViewController.view];
            [self.pageViewController didMoveToParentViewController:self];
            
            self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-100);

            
            RobotLoginButton* newlogInButton =  [RobotLoginButton
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
                                                                    
                                                                    NSArray* r = player.robots;
                                                                    
                                                                    for( int rcount = 0; rcount < r.count; rcount++ ){
                                                                        NSMutableDictionary* item = [ r objectAtIndex:rcount ];
                                                                    }
                                                                    
                                                                    
                                                                    if( [ player.name isEqualToString: [ session userName ] ]){
                                                                        
                                                                        /* Player has played before - so we don't need to make a new
                                                                         accound for them */
                                                                        
                                                                        NSLog( @"PLAYER FOUND" );
                                                                        
                                                                        playerFound = true;
                                                                        
                                                                        NSString *welcome = @"Welcome back, ";
                                                                        
                                                                        if( player.fullname != nil ){
                                                                            welcome = [welcome stringByAppendingString:player.fullname];
                                                                        }
                                                                        
                                                                        [self speak:welcome];
                                                                        
                                                                        [self performSegueWithIdentifier:@"scanSegue" sender:self];
                                                                        
                                                                        appDelegate.player = player;
                                                                        
                                                                        break;
                                                                    }
                                                                }
                                                                
                                                                if( playerFound == false ){
                                                                    
                                                                    Player* newPlayer = [[Player alloc] init];
                                                                    
                                                                    newPlayer.name = [ session userName ];
                                                                    newPlayer.robots = [self createNewScoreTemplate];
                                                                    newPlayer.startTime = [NSDate date];
                                                                    
                                                                    /* Build personality data from Twitter profile */
                                                                    
                                                                    NSString *path = @"https://robot.mybluemix.net/personality?id=";
                                                                    
                                                                    path = [path stringByAppendingString:[session userName]];
                                                                    
                                                                    NSString *restUrl = [NSString stringWithFormat:path];
                                                                    
                                                                    NSURL *url = [NSURL URLWithString:restUrl];
                                                                    
                                                                    NSURLRequest *request = [NSURLRequest requestWithURL:url];
                                                                    
                                                                    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                                                        if (data.length > 0 && connectionError == nil) {
                                                                            NSMutableDictionary *elements = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                                                                            
                                                                            NSMutableDictionary *person = elements[@"person"];
                                                                            newPlayer.description = person[@"description"];
                                                                            newPlayer.location = person[@"location"];
                                                                            newPlayer.fullname = person[@"name"];
                                                                            newPlayer.zone = person[@"timezone"];
                                                                            newPlayer.lat = person[@"lat"];
                                                                            newPlayer.lng = person[@"lng"];
                                                                            newPlayer.traits = elements[@"profiles"];
                                                                        
                                                                            NSString *welcome = @"Welcome to Robot Hunt, ";
                                                                            
                                                                            welcome = [welcome stringByAppendingString:newPlayer.fullname];
                                                                                
                                                                                 newPlayer.startSteps = 0;
                                                                                
                                                                                [[newPlayer save] continueWithBlock:^id(BFTask *task) {
                                                                                    if(task.error) {
                                                                                        NSLog(@"createItem failed with error: %@", task.error);
                                                                                    }
                                                                                    
                                                                                    appDelegate.player = newPlayer;
                                                                                    
                                                                                    [self speak:welcome];
                                                                                    
                                                                                    [self performSegueWithIdentifier:@"scanSegue" sender:self];
                                                                                    
                                                                                    return nil;
                                                                                }];

                                                                            
                                                                                                                                                    }
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
            
            [ logInButton setHidden: FALSE ];
            
        }
        
        return nil;
    }];
}

- (UIImage *) imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1000, 1000);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    //  [[UIColor colorWithRed:222./255 green:227./255 blue: 229./255 alpha:1] CGColor]) ;
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startWalkthrough:(id)sender {
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
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

- (NSMutableArray *) createNewScoreTemplate{
    
    NSMutableArray* scoreTemplate = [NSMutableArray array];
    
    NSArray* robots = [appDelegate getRobots];
    
    for( int count = 0; count < robots.count; count++ ){
        
        NSMutableDictionary* robotStatus = [NSMutableDictionary dictionary];
        
        Robot* r = [robots objectAtIndex:count];
        
        NSNumber* number;
        
        [ robotStatus setObject:@"" forKey:@"disruptionOrder"];
        [ robotStatus setObject:@"" forKey:@"disruptionSeconds"];
        [ robotStatus setObject:@"" forKey:@"timestamp"];
        [ robotStatus setObject:@"wanted" forKey:@"status"];
        [ robotStatus setObject:r.name forKey:@"name"];
        [ robotStatus setObject:@"" forKey:@"steps"];
        
        [scoreTemplate addObject: robotStatus ];
    }
    
    return scoreTemplate;
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (index >= [help count]) {
        return nil;
    }
    
    Help *helpEntity = help[index];
    
    NSData* imageData = [ self base64DataFromString: helpEntity.image ];
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.image = [UIImage imageWithData:imageData];
    pageContentViewController.titleText = helpEntity.title;
    pageContentViewController.descriptionText = helpEntity.subtitle;
    pageContentViewController.pageIndex = index;
    pageContentViewController.help = helpEntity;
    
    return pageContentViewController;
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


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [help count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [help count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
