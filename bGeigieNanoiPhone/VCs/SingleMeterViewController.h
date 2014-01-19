//
//  SingleMeterViewController.h
//  bGeigieNanoiPhone
//
//  Created by Chen Yongping on 1/19/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleMeterViewController : UIViewController

@property(nonatomic, assign) NSInteger pageIndex;
@property(nonatomic, retain) NSString *dataType;
@property(nonatomic, retain) NSString *dataValue;
@property(nonatomic, retain) NSString *dataUnit;

@end
