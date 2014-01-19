//
//  BLECentralHandler.h
//  GreenSmile
//
//  Created by Chen Yongping on 1/16/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLECentralHandler : NSObject

@property (strong, nonatomic) NSString   *connectingPeripheralName;

-(void)start;
-(void)stop;

@end
