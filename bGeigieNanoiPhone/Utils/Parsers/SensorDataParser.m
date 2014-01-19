//
//  SensorDataParser.m
//
//
//  Created by Yongping on 1/19/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//

#import "SensorDataParser.h"

@interface SensorDataParser()

@end

@implementation SensorDataParser


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

- (NSDictionary*)parseDataByString:(NSString*)rawString
{
    NSArray *stringArray = [rawString componentsSeparatedByString:@"$BNXSTS"];
    if (stringArray.count > 1) {
        NSString *bnrddString =     [stringArray objectAtIndex:0];
        NSString *bnxstsString =    [stringArray objectAtIndex:1];
        NSDictionary *bnrddDict = [self parseBNRDDString:bnrddString];
        NSDictionary *bnxstsDict = [self parseBNXSTSString:bnxstsString];
        
        NSArray *dataTypeArray1 =   [bnrddDict objectForKey:@"dataTypes"];
        NSArray *dataValueArray1 =  [bnrddDict objectForKey:@"dataValues"];
        NSArray *dataUnitArray1 =   [bnrddDict objectForKey:@"dataUnits"];

        NSArray *dataTypeArray2 =   [bnxstsDict objectForKey:@"dataTypes"];
        NSArray *dataValueArray2 =  [bnxstsDict objectForKey:@"dataValues"];
        NSArray *dataUnitArray2 =   [bnxstsDict objectForKey:@"dataUnits"];
        
        NSMutableArray *dataTypeArray = [[NSMutableArray alloc] initWithArray:dataTypeArray1];
        [dataTypeArray addObjectsFromArray:dataTypeArray2];

        NSMutableArray *dataValueArray = [[NSMutableArray alloc] initWithArray:dataValueArray1];
        [dataValueArray addObjectsFromArray:dataValueArray2];
        
        NSMutableArray *dataUnitArray = [[NSMutableArray alloc] initWithArray:dataUnitArray1];
        [dataUnitArray addObjectsFromArray:dataUnitArray2];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:bnrddDict];
        [dict setObject:dataTypeArray forKey:@"dataTypes"];
        [dict setObject:dataValueArray forKey:@"dataValues"];
        [dict setObject:dataUnitArray forKey:@"dataUnits"];
        
        return dict;
        
    }else{
        if ([rawString hasPrefix:@"$BNRDD"]) {
            return [self parseBNRDDString:rawString];
        }else if([rawString hasPrefix:@"$BNXSTS"]){
            return [self parseBNXSTSString:rawString];
        }
    }
    return nil;
}

-(NSDictionary *)parseBNRDDString:(NSString *)rawString
{
    NSArray *dataArray = [rawString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    if (dataArray.count != 15) {
        return nil;
    }
    
    NSString *radiationCPMString =    [dataArray objectAtIndex:3];
    float radiationuSvhValue =  [radiationCPMString floatValue]/344.00;
    NSString *radiationuSvhString = [NSString stringWithFormat:@"%4.3f",radiationuSvhValue];
    
    NSString *latitudeString        = [dataArray objectAtIndex:7];
    NSString *longitudeString       = [dataArray objectAtIndex:9];
    NSDate *receivedDate =            [dataArray objectAtIndex:2];
    
    NSString *unit = @"uSv/h";
    NSString *dataType = @"Radiation";
    return @{@"dataTypes":@[dataType], @"dataValues":@[radiationuSvhString], @"dataUnits":@[unit], @"latitude":latitudeString, @"longitude":longitudeString, @"receivedDate":receivedDate};
    
}
-(NSDictionary *)parseBNXSTSString:(NSString *)rawString
{
    NSArray *dataArray = [rawString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    if (dataArray.count != 6) {
        return nil;
    }
    
    NSString *temperatureValueString= [dataArray objectAtIndex:2];
    NSString *humilityValueString   = [dataArray objectAtIndex:3];
    NSString *COValueString         = [dataArray objectAtIndex:4];
    NSString *NOXValueString        = [dataArray objectAtIndex:5];
    
    float coValue   = [self adjustCO:[COValueString   floatValue]];
    float noxValue  = [self adjustNOX:[NOXValueString floatValue]];

    NSString *coPPMString = [NSString stringWithFormat:@"%4.3f",coValue];
    NSString *noxPPMString = [NSString stringWithFormat:@"%4.3f",noxValue];

    NSArray *dataTypesArray = @[@"Tempreature", @"Humility", @"CO", @"NOX"];
    NSArray *valueArray = @[temperatureValueString, humilityValueString, coPPMString, noxPPMString];
    NSArray *unitArray = @[@"C", @"%",@"PPM", @"PPM"];
    
    return @{@"dataTypes":dataTypesArray, @"dataValues":valueArray, @"dataUnits":unitArray};
}

-(SensorData *)sensorDataFromDict: (NSDictionary *)dict
{
    SensorData *sensorData = [[SensorData alloc] init];
    
    if (!([dict objectForKey:@"dataTypes"] && [dict objectForKey:@"dataValues"] && [dict objectForKey:@"latitude"] && [dict objectForKey:@"longitude"])) {
        return nil;
    }
    
    NSArray *dataTypeArray =   [dict objectForKey:@"dataTypes"];
    NSArray *dataValueArray =  [dict objectForKey:@"dataValues"];
    
    for (int i= 0; i < dataTypeArray.count; i++) {
        NSString *dataType = [dataTypeArray objectAtIndex:i];
        NSString *dataValue = [dataValueArray objectAtIndex:i];
        
        if ([dataType isEqualToString:@"Radiation"]) {
            sensorData.radiation = [dataValue floatValue];
        }else if([dataType isEqualToString:@"Tempreature"]) {
            sensorData.temperature = [dataValue floatValue];
        }else if([dataType isEqualToString:@"Humility"]) {
            sensorData.humidity = [dataValue floatValue];
        }else if([dataType isEqualToString:@"CO"]) {
            sensorData.CO = [dataValue floatValue];
        }else if([dataType isEqualToString:@"NOX"]) {
            sensorData.NOX = [dataValue floatValue];
        }
    
    }
    
    sensorData.latitude = [[dict objectForKey:@"latitude"] floatValue];
    sensorData.longitude = [[dict objectForKey:@"longitude"] floatValue];
    sensorData.capturedDate = [dict objectForKey:@"receivedDate"];
    
    return sensorData;
    
}



/** Adust CO data by the formula: y = x * 0.06434171 - 0.5958041554, x is the raw data, y is the result data
 @param rawCO float: raw data of CO
 @return float: the result data after adjustment
 */
- (float)adjustCO: (float)rawCO
{
    float adjustedValue = rawCO * 0.06434171 - 0.5958041554;
    if (adjustedValue < 0) {
        adjustedValue = 0;
    }
    return adjustedValue;
}

/** Adust NOX data by the formula: y = x * 0.157408338 - 0.0193973525, x is the raw data, y is the result data
 @param rawNOX float: raw data of NOX
 @return float: the result data after adjustment
 */
- (float)adjustNOX: (float)rawNOX
{
    float adjustedValue = rawNOX * 0.157408338 - 0.0193973525;
    if (adjustedValue < 0) {
        adjustedValue = 0;
    }
    return adjustedValue;
}

/** Adjust degree and minutes format latitude format to decimal format with the formual: decimal = degrees + minutes/60
 @param latitudeString string: format ddmm.mmmm
 @return float: the decimal latitude
 */
- (float)adjustToDecimalLatitude: (NSString *) latitudeString
{
    NSRange degreeRange;
    degreeRange.length      = 2;
    degreeRange.location    = 0;
    
    float degree = [[latitudeString substringWithRange:degreeRange] floatValue];
    float minutes = [[latitudeString substringFromIndex:2] floatValue];
    
    float decimal = degree + minutes/60;
    
    return decimal;
}

/** Adjust degree and minutes format longitude format to decimal format with the formual: decimal = degrees + minutes/60
 @param latitudeString string: format dddmm.mmmm
 @return float: the decimal latitude
 */
- (float)adjustToDecimalLongitude: (NSString *) longitudeString
{
    NSRange degreeRange;
    degreeRange.length      = 3;
    degreeRange.location    = 0;
    
    float degree = [[longitudeString substringWithRange:degreeRange] floatValue];
    float minutes = [[longitudeString substringFromIndex:3] floatValue];
    
    float decimal = degree + minutes/60;
    
    return decimal;
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
