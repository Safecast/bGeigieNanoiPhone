//
//  MainViewController.m
//  bGeigieNanoiPhone
//
//  Created by Chen Yongping on 1/19/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//

#import "MainViewController.h"
#import "SingleMeterViewController.h"

@interface MainViewController ()<UIPageViewControllerDataSource>

@property(nonatomic, retain) UIPageViewController   *pageViewController;
@property(nonatomic, strong) NSArray                *dataTypes;
@property(nonatomic, strong) NSArray                *dataValues;
@property(nonatomic, strong) NSArray                *dataUnits;
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
    _dataTypes = @[@"Radiation", @"Humility"];
    _dataValues = @[@"0.111", @"20"];
    _dataUnits  = @[@"uSv/h", @"%"];
    
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

@end
