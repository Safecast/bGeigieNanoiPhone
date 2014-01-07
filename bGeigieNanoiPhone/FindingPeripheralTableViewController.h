//
//  FindingPeripheralTableViewController.h
//  bGeigieNanoiPhone
//
//  Created by Chen Yongping on 1/7/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface FindingPeripheralTableViewController : UITableViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

@property(nonatomic, retain)CBPeripheral *peripheralToConnect;

@end
