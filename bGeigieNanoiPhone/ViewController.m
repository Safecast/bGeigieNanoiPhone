//
//  ViewController.m
//  bGeigieNanoiPhone
//
//  Created by Chen Yongping on 1/7/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import "ViewController.h"

@interface ViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *connectingPeripheral;
@property (nonatomic, assign) BOOL                  isStart;
@property (nonatomic, retain) NSString              *dataRecord;
@property (nonatomic, retain) NSString              *serviceUUID;
@property (nonatomic, retain) NSString              *rxUUID;


@property (weak, nonatomic) IBOutlet UISwitch *txSwitch;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITextView *messageOutputTextView;

- (IBAction)pushStartButton:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _isStart = FALSE;
    
    /*
    _serviceUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"Service_UUID"];
    if (!_serviceUUID) {
       
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:NSLocalizedString(@"Please provide service UUID in the Settings", nil)
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    _rxUUID =[[NSUserDefaults standardUserDefaults] valueForKey:@"RX_UUID"];
    
    if (!_rxUUID) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:NSLocalizedString(@"Please provide RX UUID in the Settings", nil)
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    if (!_rxUUID || !_serviceUUID) {
        _startButton.hidden = TRUE;
    }else{
        _startButton.hidden = FALSE;
    }
     */
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushStartButton:(id)sender {
    if (_isStart) {
        [self stop];
    }else{
        [self start];
    }
}

#pragma mark - start and stop
-(void)start
{
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [_startButton setTitle:@"Stop" forState:UIControlStateNormal];
    _isStart = TRUE;

}
-(void)stop
{
    if (_connectingPeripheral) {
        [_centralManager cancelPeripheralConnection:_connectingPeripheral];
        _connectingPeripheral = nil;
    }
    _isStart = FALSE;
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];

}

#pragma mark -add string to text view
- (void)addStringToTextView: (NSString *)message
{
    //To change the properties of UI object, need to return to main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *textViewContent = [_messageOutputTextView text];
        
        NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
        [dateFormate setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        [dateFormate setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
        NSString *dateString = [dateFormate stringFromDate:[NSDate date]];
        
        textViewContent = [NSString stringWithFormat:@"%@:%@\n%@",dateString, message, textViewContent];
        [_messageOutputTextView setText:textViewContent];
    });
    
}
-(NSString *)getSwitchValue
{
    /*
    NSString *selectedUUID;
    if (_txSwitch.on) {
        selectedUUID = TX_CHARACTERISTIC_UUID;
        NSLog(@"switch to TX");
    }else{
        selectedUUID = RX_CHARACTERISTIC_UUID;
        NSLog(@"switch to RX");

    }
    return selectedUUID;
     */
    return _rxUUID;
}


#pragma mark - delegate methods
/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        
        //if the centralmanage power off, set the state
        [self stop];
        [self addStringToTextView: @"BLE is not power on"];
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
 /*
    if (!_connectingPeripheral) {
        [_centralManager stopScan];
        
        _connectingPeripheral = peripheral;
        
        [self.centralManager connectPeripheral:peripheral options:nil];
        [self addStringToTextView:@"request to connect peripheral"];
    }
  */

}


/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    
    [self addStringToTextView:[NSString stringWithFormat:@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]]];

    NSLog(@"Central node Failed to connect to %@. (%@)", peripheral, error);
    
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self addStringToTextView:@"Peripheral Connected"];
    NSLog(@"Central node Peripheral Connected");
    
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [self addStringToTextView:@"discover service"];
    
    [peripheral discoverServices:@[[CBUUID UUIDWithString:_serviceUUID]]];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        [self addStringToTextView:[NSString stringWithFormat:@"Error discovering services: %@", error]];
        NSLog(@"Central node Error discovering services: %@", error);
        
        return;
    }
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        

        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:[self getSwitchValue]]] forService:service];
        
    }
    
}

/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        [self addStringToTextView:[NSString stringWithFormat:@"Error discovering characteristics: %@", [error localizedDescription]]];
        NSLog(@"Central node　Error discovering characteristics: %@", [error localizedDescription]);
        
        return;
    }
    
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        

        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self getSwitchValue]]]) {
            
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];

            
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
    
    // Exit if it's not the transfer characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:[self getSwitchValue]]]) {
        return;
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
        [self addStringToTextView:[NSString stringWithFormat:@"Error when reading characteristics: %@", [error localizedDescription]]];
        NSLog(@"Central node Error when reading characteristics: %@", [error localizedDescription]);
        return;
    }
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    /*
    [self addStringToTextView: stringFromData];
     */
    if ([stringFromData isEqualToString:@"$"]) {
        [self addStringToTextView: _dataRecord];
        _dataRecord = @"";
    }
    
    if (stringFromData) {
        _dataRecord = [_dataRecord stringByAppendingString:stringFromData];
    }

    
}
-(void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral
{
    NSLog(@"Central node peripheralDidInvalidateServices");
}



@end
