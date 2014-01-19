//
//  MainViewController.m
//  bGeigieNanoiPhone
//
//  Created by Chen Yongping on 1/19/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//

#import "MainViewController.h"
#import "SingleMeterViewController.h"

@interface MainViewController ()

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
	// Do any additional setup after loading the view.
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    SingleMeterViewController *viewController1 = [sb instantiateViewControllerWithIdentifier:@"SingleMeterViewController"];
    SingleMeterViewController *viewController2 = [sb instantiateViewControllerWithIdentifier:@"SingleMeterViewController"];
    viewController2.titleLabel.text = @"Humility";
    viewController2.valueLabel.text = @"20";
    viewController2.unitLabel.text = @"%";
    
    NSArray *pagesArray = @[viewController1, viewController2];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
