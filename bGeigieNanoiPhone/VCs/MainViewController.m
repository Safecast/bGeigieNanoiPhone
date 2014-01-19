//
//  MainViewController.m
//  bGeigieNanoiPhone
//
//  Created by Chen Yongping on 1/19/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//

#import "MainViewController.h"
#import "SingleMeterViewController.h"
#import "AppDelegate.h"
#import "FindingPeripheralTableViewController.h"
#import "NotificationSharedHeader.h"
#import "SensorDataParser.h"
#import <AFNetworking/AFNetworking.h>


@interface MainViewController ()<UIPageViewControllerDataSource>

@property(nonatomic, retain) UIPageViewController   *pageViewController;
@property(nonatomic, strong) NSArray                *dataTypes;
@property(nonatomic, strong) NSArray                *dataValues;
@property(nonatomic, strong) NSArray                *dataUnits;

@property(nonatomic, assign) NSInteger              currentIndex;

@property(nonatomic, assign) BOOL                   isBLEConnected;

@property (weak, nonatomic) IBOutlet UIButton *bleConnectionButton;

//for uploading
@property (nonatomic, retain) NSString      *apiKey;
@property (nonatomic, retain) NSString      *deviceID;
@property (nonatomic, retain) NSString      *safecastAPIAddress;
@property (nonatomic, retain) NSMutableArray        *sensorDataToUpload;



- (IBAction)pushBLEConnectionButton:(id)sender;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isBLEConnected = FALSE;
    _sensorDataToUpload = [[NSMutableArray alloc] init];

    //regiester to be observer of BLE notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedToPeripheral:) name:BLE_PERIPHERIAL_CONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectedWithPeripheral:) name:BLE_PERIPHERIAL_DISCONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSensorData:) name:BLE_CENTRAL_RECEIVED_DATA object:nil];


}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _dataTypes = @[@"Radiation"];
    _dataValues = @[@"0.000"];
    _dataUnits  = @[@"uSv/h"];
    
    //init page view controller
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MetersPageViewController"];
    self.pageViewController.dataSource = self;
    
    SingleMeterViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -page control data source
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SingleMeterViewController *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    _currentIndex = index;
    index++;
    if (index == [self.dataTypes count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SingleMeterViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (SingleMeterViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.dataTypes count] == 0) || (index >= [self.dataTypes count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    SingleMeterViewController *singleMeterViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleMeterViewController"];
    
    singleMeterViewController.pageIndex = index;
    singleMeterViewController.dataType = [_dataTypes objectAtIndex:index];
    singleMeterViewController.dataValue = [_dataValues objectAtIndex:index];
    singleMeterViewController.dataUnit = [_dataUnits objectAtIndex:index];
    
    return singleMeterViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.dataTypes count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (IBAction)pushBLEConnectionButton:(id)sender {
    
    if (!_isBLEConnected) {
        [ApplicationDelegate.bleCentralHandler start];
        
        UIStoryboard *managementStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FindingPeripheralTableViewController *findingPeripheralVC = [managementStoryboard instantiateViewControllerWithIdentifier:@"FindingPeripheralTableViewController"];
        [self.navigationController pushViewController:findingPeripheralVC animated:YES];

    }else{
        [ApplicationDelegate.bleCentralHandler stop];
        [_bleConnectionButton setTitle:@"Connect" forState:UIControlStateNormal];
        _isBLEConnected = FALSE;

    }
    
}

#pragma mark -BLE notification handling methods
-(void)connectedToPeripheral:(NSNotification *) notification
{
    
    [_bleConnectionButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    _isBLEConnected = TRUE;
}

-(void)disconnectedWithPeripheral:(NSNotification *) notification
{
    [_bleConnectionButton setTitle:@"Connect" forState:UIControlStateNormal];
    _isBLEConnected = FALSE;
}
-(void)receivedSensorData:(NSNotification *) notification
{
    NSString *sensorRawData = [notification.userInfo objectForKey:@"rawData"];
    SensorDataParser *parser = [[SensorDataParser alloc] init];
    NSDictionary *parsedResult = [parser parseDataByString:sensorRawData];
    NSLog(@"parserResult:%@",parsedResult);
    if (parsedResult) {
        NSArray *dataTypesArray = [parsedResult objectForKey:@"dataTypes"];
        NSArray *valueArray = [parsedResult objectForKey:@"dataValues"];
        NSArray *unitArray  = [parsedResult objectForKey:@"dataUnits"];
        _dataTypes = dataTypesArray;
        _dataValues = valueArray;
        _dataUnits = unitArray;
        SensorData *sensorData = [parser sensorDataFromDict:parsedResult];
        
        if (sensorData) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RADIATION_NEED_TO_UPDATA object:self userInfo:@{@"dataType": [_dataTypes objectAtIndex:0], @"dataValue":[_dataValues objectAtIndex:0], @"dataUnit":[_dataUnits objectAtIndex:0]}];
            [_sensorDataToUpload addObject:sensorData];
        
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

            if ([ud valueForKey:@"uploadToServer"] ) {
                
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSString *apiKey = [ud valueForKey:@"apiKey"];
                NSString *deviceID = [ud valueForKey:@"deviceID"];
                if (!deviceID || !apiKey || [deviceID isEqualToString:@""] || [apiKey isEqualToString:@""]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Caution", nil)
                                                                    message:NSLocalizedString(@"Device ID or API Key empty", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }else{
                    _apiKey = apiKey;
                    _deviceID = deviceID;
                    if ([[ud valueForKey:@"uploadToServer"] boolValue]) {
                        [self postSensorData];
                    }
                }


            }
        }


    }
    
}

#pragma mark -method to post data to server
- (BOOL)postSensorData {
    
    if ([_sensorDataToUpload count] == 0) {
        return NO;
    }
    
    //Post data to Fukushima Wheel server
    NSString    *urlString = @"http://fukushimawheel.org/map/api.php";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setTimeoutInterval:180];
    
    SensorDataParser *parser = [[SensorDataParser alloc] init];
    NSMutableArray *dataDictArray = [[NSMutableArray alloc] init];
    for (SensorData *sensor in _sensorDataToUpload) {
        
        //if the location is empty, wont upload
        if (sensor.longitude == 0 || sensor.latitude == 0) {
            continue;
        }
        
        NSDate *captureDate = [parser dateFromUTCString:sensor.capturedDate];
        NSString *dateString = [parser dateStringOfJST:captureDate];
        NSDictionary *singleDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%f", sensor.latitude],   @"latitude",
                                        [NSString stringWithFormat:@"%f", sensor.longitude],  @"longitude",
                                        [NSString stringWithFormat:@"%f", sensor.distance],   @"distance",
                                        [NSString stringWithFormat:@"%f", sensor.temperature],@"temperature",
                                        [NSString stringWithFormat:@"%f", sensor.humidity],   @"humidity",
                                        [NSString stringWithFormat:@"%f", sensor.co2],        @"co2",
                                        [NSString stringWithFormat:@"%f", sensor.radiation],  @"radiation",
                                        [NSString stringWithFormat:@"%f", sensor.CO],  @"co",
                                        [NSString stringWithFormat:@"%f", sensor.NOX],  @"nox",
                                        dateString, @"capture_at",
                                        nil];
        
        [dataDictArray addObject:singleDataDict];
        
        
        //Post data to safecast
        if (sensor.radiation == 0) { //if the radiation value is zero, would not upload to safecast server
            return NO;
        }
        
        AFHTTPRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        
        NSDictionary *parameters = @{
                                     @"latitude":[NSNumber numberWithFloat:sensor.latitude],
                                     @"longitude":[NSNumber numberWithFloat:sensor.longitude],
                                     @"unit":@"cpm",
                                     @"value":[NSNumber numberWithFloat:[sensor getCPMRadiation]],
                                     @"device_id":_deviceID,
                                     @"captured_at":sensor.capturedDate};
        
        
        
        NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString: [NSString stringWithFormat:@"http://176.56.236.75/safecast/index.php?api_key=%@",_apiKey]  parameters:parameters];
        //Add your request object to an AFHTTPRequestOperation
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:
         ^(AFHTTPRequestOperation *operation,
           id responseObject) {
             NSLog(@"response from server after upload:%@",operation.responseString);
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error when upload to server:%@",error.description);
             
         }];
        
        [operation start];
        
        
        
    }
    /*
    NSDictionary *bodyDict = [NSDictionary dictionaryWithObjectsAndKeys:dataDictArray, @"data", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:NSJSONWritingPrettyPrinted error:nil];
    
    NSLog(@"post data to api server:%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    //NSLog(@"url = %@, body =  %@", urlString, bodyString);
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    
    //[[NSURLConnection alloc] initWithRequest:request delegate:self];
    [NSURLConnection connectionWithRequest:request delegate:self];
    */
    [_sensorDataToUpload removeAllObjects];
    
    
    
    return YES;
}

@end
