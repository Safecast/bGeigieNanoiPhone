//
//  SensorDataParser.h
//  GreenSmile
//
//  Created by Chen Yongping on 1/13/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef _SENSOR_DATA_PARSER_H_
#define _SENSOR_DATA_PARSER_H_

#import "SensorData.h"

@interface SensorDataParser : NSObject

- (NSDictionary*)parseDataByString:(NSString*)rawString;
- (SensorData *)sensorDataFromDict: (NSDictionary *)dict;


- (NSString*)dateStringOfUTC: (NSDate *)date;
- (NSString*)dateStringOfJST: (NSDate *)date;
- (NSDate*)dateFromUTCString: (NSString *)dateString;
- (NSDate*)dateFromJSTString: (NSString *)dateString;

@end

#endif
