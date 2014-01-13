//
//  FindingPeripheralTableViewController.h
//  bGeigieNanoiPhone
//  This view to show the list of name of BLE peripheral found, enable user to select a peripheral to connect
//  Created by Chen Yongping on 1/7/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FindingPeripheralDelegate <NSObject>

-(void)selectPeripheralByIndex: (NSInteger)index;

@end

@interface FindingPeripheralTableViewController : UITableViewController

@property (nonatomic, strong)   NSMutableArray *peripheralNameArray;
@property (nonatomic)           id<FindingPeripheralDelegate> delegate;

-(void)addPeripheralName: (NSString *)foundPeripheralName;

@end
