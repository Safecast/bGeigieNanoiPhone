//
//  BLECentralHandler.m
//  GreenSmile
//
//  Created by Chen Yongping on 1/16/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import "BLECentralHandler.h"
#import "SensorData.h"
#import "SensorDataParser.h"
#import "NotificationSharedHeader.h"
@interface BLECentralHandler()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *connectingPeripheral;

@property (nonatomic, strong) NSMutableArray        *foundPeripherals;

@property (nonatomic, assign) BOOL                  isStart;

@property (nonatomic, strong) NSString              *dataRecord;


@end

@implementation BLECentralHandler

-(id)init
{
    self = [super init];
    if (self) {
        _foundPeripherals = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPeripheralToConnect:) name:BLE_SELECT_A_PERIPHERAL_TO_CONNECT object:nil];

    }
    return self;
}

-(BOOL)theDeviceExitsInArray: (NSString *)peripheralName
{
    for (CBPeripheral *peripheral in _foundPeripherals) {
        if ([peripheralName isEqualToString:peripheral.name]) {
            return TRUE;
        }
    }
    return FALSE;
}

#pragma mark - start and stop
-(void)start
{
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _isStart = TRUE;
    _dataRecord = @"";
    _foundPeripherals = [[NSMutableArray alloc] init];
    
}
-(void)stop
{
    if (_connectingPeripheral) {
        [_centralManager cancelPeripheralConnection:_connectingPeripheral];
        _connectingPeripheral = nil;
    }
    _foundPeripherals = nil;
    _isStart = FALSE;
    _connectingPeripheralName = nil;
    
}



#pragma mark -  BLE communication delegate methods
/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        
        //if the centralmanage power off, set the state
        return;
    }
    
    //if central manager power on, change the state
    [_centralManager scanForPeripheralsWithServices:nil
                                            options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
    
    
}

/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSLog(@"identifier of peripheral:%@, data:%@",peripheral.identifier, peripheral.name);
    
    //    if ([peripheral.name hasPrefix:@"BLEbee"]) {
    if (peripheral.name && ![self theDeviceExitsInArray:peripheral.name]) {
        [_foundPeripherals addObject:peripheral];
    
        [[NSNotificationCenter defaultCenter] postNotificationName:BLE_CENTRAL_FOUND_PERIPHERAL
                                                            object:self
                                                          userInfo:@{@"peripheralName": peripheral.name}];
        
    }
    
}


/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    NSLog(@"Central node Failed to connect to %@. (%@)", peripheral, error);
    
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Central node Peripheral Connected");
    //sent out notification
    [[NSNotificationCenter defaultCenter] postNotificationName:BLE_PERIPHERIAL_CONNECTED
                                                        object:self
                                                      userInfo:nil];
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:nil];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Caution", nil)
                                                    message:NSLocalizedString(@"Peripheral disconnect.", nil)
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self stop];
    
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Central node Error discovering services: %@", error);
        
        return;
    }
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        
        NSLog(@"service:%@",service.description);
        [peripheral discoverCharacteristics:nil forService:service];
        
    }
    
}

/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Central node　Error discovering characteristics: %@", [error localizedDescription]);
        
        return;
    }
    
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        BOOL isRX = FALSE;
        
        if ((characteristic.properties & CBCharacteristicPropertyRead) == CBCharacteristicPropertyRead &&
            (characteristic.properties & CBCharacteristicPropertyNotify) == CBCharacteristicPropertyNotify) {
            isRX = TRUE;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            NSLog(@"found RX char");
            
        }
        
    }
    
    
}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Central node Error changing notification state: %@", error.localizedDescription);
    }
    
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Central node Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Central node Notification stopped on %@.  Disconnecting", characteristic);
    }
}



/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Central node Error when reading characteristics: %@", [error localizedDescription]);
        return;
    }
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    if ([stringFromData hasPrefix:@"$"] && _dataRecord.length > 0 ) {//has the head of sensor data
    
        if (_dataRecord && ![_dataRecord isEqualToString:@""]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:BLE_CENTRAL_RECEIVED_DATA
                                                                object:self
                                                              userInfo:@{@"rawData": _dataRecord}];

        }
        _dataRecord = @"";
        
    }
    NSLog(@"received data:%@",_dataRecord);
    if (stringFromData) {
        _dataRecord = [[NSString alloc] initWithString:[_dataRecord stringByAppendingString:stringFromData]];
    }
    
    
}
-(void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral
{
    NSLog(@"Central node peripheralDidInvalidateServices");
}


#pragma mark notification hanlding method
-(void)selectPeripheralToConnect:(NSNotification *) notification
{
    NSString *peripheralName = [notification.userInfo objectForKey:@"peripheralName"];
    
    if (!peripheralName) {
        return;
    }
    
    for (CBPeripheral *peripheral in _foundPeripherals) {
        if ([peripheral.name isEqualToString:peripheralName]) {
            _connectingPeripheral = peripheral;
        }
    }
    
    if (_connectingPeripheral) {
        _connectingPeripheral.delegate = self;
        [self.centralManager connectPeripheral:_connectingPeripheral options:nil];
        _connectingPeripheralName = _connectingPeripheral.name;
    }
    [_centralManager stopScan];
}

@end
