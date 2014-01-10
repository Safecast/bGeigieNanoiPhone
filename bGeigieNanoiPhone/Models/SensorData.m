//
//  SensorData.m
//  GreenSmile
//
//  Created by 祐也 金田 on 12/04/28.
//  Copyright (c) 2012 会津大学. All rights reserved.
//

#import "SensorData.h"

@implementation SensorData

@synthesize ID;
@synthesize latitude;
@synthesize longitude;
@synthesize distance;
@synthesize nowDate;
@synthesize temperature;
@synthesize humidity;
@synthesize co2;
@synthesize radiation;
@synthesize pressure;
//@synthesize co;
//@synthesize nox;
@synthesize isUploaded;
@synthesize deviceID;
@synthesize capturedDate;
@synthesize CO;
@synthesize NOX;


#pragma mark - Setter

- (void)setRadiation:(float)_radiation {
    radiation = _radiation;
}

- (void)setTemperature:(float)_temperature {
    temperature = _temperature;
}

- (void)setHumidity:(float)_humidity {
    humidity = _humidity;
}


- (void)setPressure:(float)_pressure {
    pressure = _pressure / 10 + 800;
}

- (float)getCPMRadiation{
    return radiation * 344;
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if(self){
        ID = -1;
        isUploaded = NO;
    }
    return self;
}


- (id)initForDemo {
    self = [super init];
    if(self){
        srand((long long)time(NULL));
        
        latitude = (0.003 / ((float)(rand() % 100) + 1)) + 36.5;
        longitude = (0.003 / ((float)(rand() % 100) + 1)) + 135.5;
        
        nowDate = [NSDate date];
        temperature = 15.0 + (1.0 / (float)(rand() % 100) + 1) * 5;
        humidity = (float)(rand() % 1000) / 10.0;
        co2 = 50.0 + (rand() % 100);
        radiation = rand() % 1000 / 10.0;//0.01 + (1.0 / (float)(rand() % 100)) * 0.1;
        CO = rand() % 1001 / 1000.0;
        NOX = rand() % 1001 / 1000.0;
    }
    return self;
}

- (void)print {
    NSLog(@"ID: %d, Location: (%f, %f), date: %@, temperature: %f, humidity: %f, co2: %f, radiation: %f, CO: %f, NOX: %f, capture: %@", ID, latitude, longitude, nowDate, temperature, humidity, co2, radiation, CO, NOX, capturedDate);
}

- (NSString *)toString
{
    return [NSString stringWithFormat:@"time = %@, temperature = %f, humidity = %f,radiation = %f", nowDate, temperature, humidity, radiation];
}

/*
- (void)dealloc {
    if(nowDate)
        [nowDate release];
    
    [super dealloc];
}
*/

- (NSDictionary*)getDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:latitude],    @"latitude",
            [NSNumber numberWithFloat:longitude],   @"longitude",
            nowDate,                                @"nowDate",
            [NSNumber numberWithFloat:temperature], @"temperature",
            [NSNumber numberWithFloat:humidity],    @"humidity",
            [NSNumber numberWithFloat:co2],         @"co2",
            [NSNumber numberWithFloat:radiation],   @"radiation",
            [NSNumber numberWithFloat:pressure],    @"pressure",
            [NSNumber numberWithFloat:CO],          @"co",
            [NSNumber numberWithFloat:NOX],         @"nox",
            nil];
}

- (void)setObjectWithDictionary:(NSDictionary*)dictionary
{
    self.latitude       = [[dictionary objectForKey:@"latitude"] floatValue];
    self.longitude      = [[dictionary objectForKey:@"longitude"] floatValue];
    self.nowDate        = (NSDate *)[dictionary objectForKey:@"nowDate"];
    self.temperature    = [[dictionary objectForKey:@"temperature"] floatValue];
    self.humidity       = [[dictionary objectForKey:@"humidity"] floatValue];
    self.co2            = [[dictionary objectForKey:@"co2"] floatValue];
    self.radiation      = [[dictionary objectForKey:@"radiation"] floatValue];
    self.pressure       = [[dictionary objectForKey:@"pressure"] floatValue];
    self.CO             = [[dictionary objectForKey:@"co"] floatValue];
    self.NOX            = [[dictionary objectForKey:@"nox"] floatValue];
   
}

/*
- (BOOL)isCorrectData
{
    if(self.latitude == 0.0 &&
       self.longitude == 0.0 &&
       self.temperature == 0.0 &&
       self.humidity == 0.0 &&
       self.co2 == 0.0 &&
       self.radiation == 0.0 &&
       self.pressure == 0.0 &&
       self.CO == 0.0 &&
       self.NOX == 0.0)
        return NO;
    return YES;
}
*/

- (BOOL)isCorrectSensorData
{
    if(self.temperature == 0.0 &&
       self.humidity == 0.0 &&
       self.co2 == 0.0 &&
       self.radiation == 0.0 &&
       self.pressure == 0.0 &&
       self.CO == 0.0 &&
       self.NOX == 0.0)
        return NO;
    return YES;
}

- (BOOL)isCorrectLocation
{
    if(self.latitude == 0.0 && self.longitude == 0.0)
        return NO;
    return YES;
}

@end
