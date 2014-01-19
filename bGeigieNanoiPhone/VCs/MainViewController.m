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

@interface MainViewController ()<UIPageViewControllerDataSource>

@property(nonatomic, retain) UIPageViewController   *pageViewController;
@property(nonatomic, strong) NSArray                *dataTypes;
@property(nonatomic, strong) NSArray                *dataValues;
@property(nonatomic, strong) NSArray                *dataUnits;

@property(nonatomic, assign) NSInteger              currentIndex;

@property(nonatomic, assign) BOOL                   isBLEConnected;

@property (weak, nonatomic) IBOutlet UIButton *bleConnectionButton;


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
    
    //init
    _isBLEConnected = FALSE;
    
    //regiester to be observer of BLE notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedToPeripheral:) name:BLE_PERIPHERIAL_CONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectedWithPeripheral:) name:BLE_PERIPHERIAL_DISCONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSensorData:) name:BLE_CENTRAL_RECEIVED_DATA object:nil];


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
    [ApplicationDelegate.bleCentralHandler stop];
    [_bleConnectionButton setTitle:@"Connect" forState:UIControlStateNormal];
    _isBLEConnected = FALSE;
}
-(void)receivedSensorData:(NSNotification *) notification
{
    NSString *sensorRawData = [notification.userInfo objectForKey:@"rawData"];
    SensorDataParser *parser = [[SensorDataParser alloc] init];
    NSDictionary *parsedResult = [parser parseDataByString:sensorRawData];

    if (parsedResult) {
        NSArray *dataTypesArray = [parsedResult objectForKey:@"dataTypes"];
        NSArray *valueArray = [parsedResult objectForKey:@"dataValues"];
        NSArray *unitArray  = [parsedResult objectForKey:@"dataUnits"];
        _dataTypes = dataTypesArray;
        _dataValues = valueArray;
        _dataUnits = unitArray;

    }
    
}


@end
