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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:DATA_NEED_TO_UPDATA object:nil];
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
    
    if (![_dataType isEqualToString:@""]) {
        NSArray *receivedDataTypes = [notification.userInfo objectForKey:@"dataTypes"];
        NSArray *receivedDataUnits = [notification.userInfo objectForKey:@"dataUnits"];
        NSArray *receivedDataValues = [notification.userInfo objectForKey:@"dataValues"];
        
        for (int i=0; i < receivedDataTypes.count; i++) {
            NSString *receivedDataType = receivedDataTypes[i];
            NSString *receivedDataUnit = receivedDataUnits[i];
            if ([receivedDataType isEqualToString:_dataType] &&
                [receivedDataUnit isEqualToString:_dataUnit]) {
                _dataValue = receivedDataValues[i];
                _valueLabel.text = _dataValue;
            }
        }
    
    }
    

}

@end
