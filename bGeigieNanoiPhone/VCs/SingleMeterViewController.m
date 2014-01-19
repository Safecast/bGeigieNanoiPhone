//
//  SingleMeterViewController.m
//  bGeigieNanoiPhone
//
//  Created by Chen Yongping on 1/19/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//

#import "SingleMeterViewController.h"
#import "NotificationSharedHeader.h"

@interface SingleMeterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@end

@implementation SingleMeterViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:RADIATION_NEED_TO_UPDATA object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    _titleLabel.text = _dataType;
    _valueLabel.text = _dataValue;
    _unitLabel.text = _dataUnit;
}

-(void)updateData: (NSNotification *) notification
{
    _dataType = [notification.userInfo objectForKey:@"dataType"];
    _dataValue = [notification.userInfo objectForKey:@"dataValue"];
    _dataUnit = [notification.userInfo objectForKey:@"dataUnit"];
    
    _titleLabel.text = _dataType;
    _valueLabel.text = _dataValue;
    _unitLabel.text = _dataUnit;
}



@end
