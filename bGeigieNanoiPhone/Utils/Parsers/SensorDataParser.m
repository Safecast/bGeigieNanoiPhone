//
//  SensorDataParser.m
//  GreenSmile
//
//  Created by 金田 祐也 on 6/13/12.
//  Copyright (c) 2012 会津大学. All rights reserved.
//

#import "SensorDataParser.h"

@implementation SensorDataParser


- (SensorData*)parseData:(NSData*)data {
    
    
    SensorData *sensor = [[[SensorData alloc] initForDemo] retain];
    return sensor;
}

/* From sensor there are 2 type of messages: one type is begined with BNRDD, another type is begined with BNXSTS. 
 BNRDD has radiation data, and BNXSTS has temperature, humidity, CO and NOX data
 @param rawString NSString: raw message sent from sensor set with combine 2 types of message as one message

 The format as following:
 
 BNRDD message format :
 
$BNRDD,0210,2013-04-11T05:40:51Z,35,0,736,A,3516.1459,N,13614.9700,E,73.50,A,125,0*64
$BNXSTS,0210,23,45,12,0.304
  
 **first part**
 Header : $BNRDD
 Device ID : Device serial number. 0210
 Date : Date formatted according to iso-8601 standard. Usually uses GMT. 2013-04-11T05:40:51Z
 Radiation 1 minute : number of pulses given by the Geiger tube in the last minute. 35 (cpm)
 Radiation 5 seconds : number of pulses given by the Geiger tube in the last 5 seconds. 0
 Radiation total count : total number of pulses recorded since startup. 736
 Radiation count validity flag : 'A' indicates the counter has been running for more than one minute and the 1 minute count is not zero. Otherwise, the flag is 'V' (void). A
 Latitude : As given by GPS. The format is ddmm.mmmm where dd is in degrees and mm.mmmm is decimal minute. 3516.1459
 Hemisphere : 'N' (north), or 'S' (south). N
 Longitude : As given by GPS. The format is dddmm.mmmm where ddd is in degrees and mm.mmmm is decimal minute. 13614.9700
 East/West : 'W' (west) or 'E' (east) from Greenwich. E
 Altitude : Above sea level as given by GPS in meters. 73.50
 GPS validity : 'A' ok, 'V' invalid. A
 HDOP : Horizontal Dilution of Precision (HDOP), relative accuracy of horizontal position. 125
 Checksum: 0*64
 
 **second part: $BNXSTS,ID,temperature,humidity,CO, NOX**
 
 Header: $BNXSTS (together with Checksum of first part)
 ID: the ID of device
 temperature: unit is Celsius (°C)
 humidity: unit is percentage
 CO: range from 1 ~ 1000, unit is ppm
 NOX: range from 0.05 ~ 5, unit is ppm
 */

- (SensorData*)parseDataByString:(NSString*)rawString
{
    NSArray *dataArray = [rawString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
//    SensorData *sensor = [[[SensorData alloc] initForDemo] retain];
    if (dataArray.count != 20) {
        return nil;
    }
    
    SensorData *data = [[SensorData alloc] init];
    NSString *radiationValueString =    [dataArray objectAtIndex:3];

    

    NSDate *receivedDate = [self dateFromUTCString:[dataArray objectAtIndex:2]];
    NSString *temperatureValueString= [dataArray objectAtIndex:16];
    NSString *humilityValueString   = [dataArray objectAtIndex:17];
    NSString *COValueString         = [dataArray objectAtIndex:18];
    NSString *NOXValueString        = [dataArray objectAtIndex:19];
    
    [data setNowDate:       receivedDate];
    [data setRadiation:     [radiationValueString floatValue]/344.00];
    [data setDeviceID:      [dataArray objectAtIndex:1]];
    [data setCapturedDate:  [dataArray objectAtIndex:2]];

    [data setHumidity:      [humilityValueString            floatValue]];
    [data setTemperature:   [temperatureValueString         floatValue]];
    [data setCO:            [self adjustCO:[COValueString   floatValue]]];
    [data setNOX:           [self adjustNOX:[NOXValueString floatValue]]];
    
    
    return data;
}

/** Adust CO data by the formula: y = x * 0.06434171 - 0.5958041554, x is the raw data, y is the result data
 @param rawCO float: raw data of CO
 @return float: the result data after adjustment
 */
- (float)adjustCO: (float)rawCO
{
    return rawCO * 0.06434171 - 0.5958041554;
}

/** Adust NOX data by the formula: y = x * 0.157408338 - 0.0193973525, x is the raw data, y is the result data
 @param rawNOX float: raw data of NOX
 @return float: the result data after adjustment
 */
- (float)adjustNOX: (float)rawNOX
{
    return rawNOX * 0.157408338 - 0.0193973525;
}

- (NSDate *)dateFromJSTString:(NSString *)dateString
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSTimeZone *timezone = [NSTimeZone timeZoneWithName:@"JST"];
    [df setTimeZone:timezone];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [df dateFromString:dateString];

}

- (NSDate *)dateFromUTCString:(NSString *)dateString
{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSTimeZone *timezone = [NSTimeZone timeZoneWithName:@"UTC"];
    [df setTimeZone:timezone];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    return [df dateFromString:dateString];
}

- (NSString *)dateStringOfUTC:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timezone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timezone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    return [dateFormatter stringFromDate:date];

}

- (NSString *)dateStringOfJST:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timezone = [NSTimeZone timeZoneWithName:@"JST"];
    [dateFormatter setTimeZone:timezone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
}
@end
