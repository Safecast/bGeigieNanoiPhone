//
//  SensorData.h
//  GreenSmile
//
//  Created by 祐也 金田 on 12/04/28.
//  Copyright (c) 2012 会津大学. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef _SENSOR_DATA_H_
#define _SENSOR_DATA_H_



@interface SensorData : NSObject {
    NSInteger   ID;
    // 緯度
    float       latitude;
    // 経度
    float       longitude;
    
    // 時間
    NSDate      *nowDate;
    
    // 気温 Celsius (°C)
    float       temperature;
    
    // 湿度 Percentage (%)
    float       humidity;
    
    // CO2量 Kilogram (kg)
    float       co2;
    
    // 放射線量 microsievert per hour(mSv/h)
    float       radiation;
    
    // 気圧
    float       pressure;
    
//    // CO
//    float       co;
//    
//    // NOx
//    float       nox;
    
    // センサーデータがアップロードされたか
    BOOL        isUploaded;
    
    float       CO;
    float       NOX;
    
    //Get from sensor data message of sensor set 
    NSString    *deviceID;
    NSString    *capturedDate;
}

@property (nonatomic        )   NSInteger   ID;
@property (nonatomic        )   float       latitude;
@property (nonatomic        )   float       longitude;
@property (nonatomic        )   float       distance;
@property (nonatomic, retain)   NSDate      *nowDate;
@property (nonatomic        )   float       temperature;
@property (nonatomic        )   float       humidity;
@property (nonatomic        )   float       co2;
@property (nonatomic        )   float       radiation;
@property (nonatomic        )   float       pressure;
//@property (nonatomic        )   float       co;
//@property (nonatomic        )   float       nox;
@property (nonatomic        )   BOOL        isUploaded;
@property (nonatomic, retain)   NSString    *deviceID;
@property (nonatomic, retain)   NSString    *capturedDate;
@property (nonatomic        )   float       CO;
@property (nonatomic        )   float       NOX;



- (id)initForDemo;
- (void)print;
- (NSString *)toString;

//for pass the sensor data by notification
- (NSDictionary*)getDictionary; 
- (void)setObjectWithDictionary:(NSDictionary*)dictionary;
- (float)getCPMRadiation;

//- (BOOL)isCorrectData;
- (BOOL)isCorrectSensorData;
- (BOOL)isCorrectLocation;

@end

#endif
