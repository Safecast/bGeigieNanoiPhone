//
//  AppDelegate.h
//  bGeigieNanoiPhone
//
//  Created by Chen Yongping on 1/7/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLECentralHandler.h"

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow              *window;
@property (nonatomic, strong) BLECentralHandler     *bleCentralHandler;

@end
