//
//  ViewController.m
//  bGeigieNanoiPhone
//
//  Created by Chen Yongping on 1/7/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>
#import "AFNetworking.h"

#import "ViewController.h"
#import "FindingPeripheralTableViewController.h"
#import "SensorData.h"
#import "SensorDataParser.h"

@interface ViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate, FindingPeripheralDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *connectingPeripheral;
@property (nonatomic, assign) BOOL                  isStart;
@property (nonatomic, retain) NSString              *dataRecord;
@property (nonatomic, retain) NSString              *serviceUUID;
@property (nonatomic, retain) NSString              *rxUUID;


@property (weak, nonatomic) IBOutlet UISwitch *txSwitch;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITextView *messageOutputTextView;
@property (weak, nonatomic) IBOutlet UISwitch *uploadServerSwitch;

@property (nonatomic, strong) NSMutableArray                        *foundPeripherals;
@property (nonatomic, strong) FindingPeripheralTableViewController  *findPeripheralController;


@property (nonatomic, retain) NSMutableArray        *sensorDataToUpload;


- (IBAction)pushStartButton:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _isStart = FALSE;
    
    _foundPeripherals = [[NSMutableArray alloc] init];
    _sensorDataToUpload = [[NSMutableArray alloc] init];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
        UIStoryboard *managementStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        _findPeripheralController = [managementStoryboard instantiateViewControllerWithIdentifier:@"FindingPeripheralTableViewController"];;
        [_findPeripheralController setDelegate:self];
        [self.navigationController pushViewController:_findPeripheralController animated:YES];
        
    }
}

#pragma mark - start and stop
-(void)start
{
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [_startButton setTitle:@"Stop" forState:UIControlStateNormal];
    _isStart = TRUE;
    
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
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    
    
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
        if (_findPeripheralController) {
            [_findPeripheralController addPeripheralName:peripheral.name];
        }
    }
    //    }
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
        [self addStringToTextView:[NSString stringWithFormat:@"Error discovering services: %@", error]];
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
        [self addStringToTextView:[NSString stringWithFormat:@"Error discovering characteristics: %@", [error localizedDescription]]];
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
        
        if (stringFromData && ![stringFromData isEqualToString:@""]) {
            SensorDataParser *parser = [[SensorDataParser alloc] init];
            SensorData *sensorData = [parser parseDataByString:_dataRecord];
            if (sensorData) {
                [_sensorDataToUpload addObject:sensorData];
            }
            if (_uploadServerSwitch.on) {
                [self postSensorData];
            }
            NSLog(@"sensorData:%f,%f,%f,%f,%f,%f",sensorData.CO, sensorData.NOX,sensorData.temperature, sensorData.humidity,sensorData.latitude,sensorData.longitude);
        }
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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"findPeripherals"]) {
        _findPeripheralController = (FindingPeripheralTableViewController *)segue.destinationViewController;
        [_findPeripheralController setDelegate:self];
    }
}

#pragma mark delegate methods of finding peripheral view controller
-(void)selectPeripheralByIndex:(NSInteger)index
{
    _connectingPeripheral = [_foundPeripherals objectAtIndex:index];
    
    if (_connectingPeripheral) {
        _connectingPeripheral.delegate = self;
        [self.centralManager connectPeripheral:_connectingPeripheral options:nil];
        [self addStringToTextView:@"request to connect peripheral"];
    }
    [_centralManager stopScan];
}

#pragma mark -method to post data to server
- (BOOL)postSensorData {
    
    if ([_sensorDataToUpload count] == 0) {
        return NO;
    }
    
    //Post data to Fukushima Wheel server
    NSString    *urlString = @"http://fukushimawheel.org/map/api.php";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setTimeoutInterval:180];
    
    SensorDataParser *parser = [[SensorDataParser alloc] init];
    NSMutableArray *dataDictArray = [[NSMutableArray alloc] init];
    for (SensorData *sensor in _sensorDataToUpload) {
        
        //if the location is empty, wont upload
        if (sensor.longitude == 0 || sensor.latitude == 0) {
            continue;
        }
        
        NSDate *captureDate = [parser dateFromUTCString:sensor.capturedDate];
        NSString *dateString = [parser dateStringOfJST:captureDate];
        NSDictionary *singleDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%f", sensor.latitude],   @"latitude",
                                        [NSString stringWithFormat:@"%f", sensor.longitude],  @"longitude",
                                        [NSString stringWithFormat:@"%f", sensor.distance],   @"distance",
                                        [NSString stringWithFormat:@"%f", sensor.temperature],@"temperature",
                                        [NSString stringWithFormat:@"%f", sensor.humidity],   @"humidity",
                                        [NSString stringWithFormat:@"%f", sensor.co2],        @"co2",
                                        [NSString stringWithFormat:@"%f", sensor.radiation],  @"radiation",
                                        [NSString stringWithFormat:@"%f", sensor.CO],  @"co",
                                        [NSString stringWithFormat:@"%f", sensor.NOX],  @"nox",
                                        dateString, @"capture_at",
                                        nil];
        
        [dataDictArray addObject:singleDataDict];
        
        
        //Post data to safecast
        if (sensor.radiation == 0) { //if the radiation value is zero, would not upload to safecast server
            return NO;
        }
        /*
         NSString *requestURLFormat = @"https://api.safecast.org/measurements.json?api_key=%@&measurement[latitude]=%f&measurement[longitude]=%f&measurement[unit]=%@&measurement[value]=%f&measurement[device_id]=%@&measurement[captured_at]=%@&measurement[device_id]=%@";
         NSString *requestURLString = [NSString stringWithFormat:requestURLFormat,
         @"q1LKu7RQ8s5pmyxunnDW",
         sensor.latitude,
         sensor.longitude,
         @"cpm",
         [sensor getCPMRadiation],
         sensor.deviceID,
         sensor.capturedDate,@"44"
         ];
         
         NSMutableURLRequest *requestSC = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURLString]];
         
         NSLog(@"request url to safecast server:%@",requestURLString);
         [requestSC setHTTPBody:nil];
         [requestSC setHTTPMethod:@"POST"];
         
         //During testing period, disable to upload datas to safecast server
         [NSURLConnection connectionWithRequest:requestSC delegate:self];
         */
        
        AFHTTPRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        
        NSDictionary *parameters = @{
                                     @"latitude":[NSNumber numberWithFloat:sensor.latitude],
                                     @"longitude":[NSNumber numberWithFloat:sensor.longitude],
                                     @"unit":@"cpm",
                                     @"value":[NSNumber numberWithFloat:[sensor getCPMRadiation]],
                                     @"device_id":@"44",
                                     @"captured_at":sensor.capturedDate};
        
        
        
        NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:@"http://176.56.236.75/safecast/index.php?api_key=q1LKu7RQ8s5pmyxunnDW" parameters:parameters];
        //Add your request object to an AFHTTPRequestOperation
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:
         ^(AFHTTPRequestOperation *operation,
           id responseObject) {
             NSLog(@"response from server after upload:%@",operation.responseString);
             [self addStringToTextView:@"upload json to safecast server"];
             [self addStringToTextView:[NSString stringWithFormat:@"response from server after upload:%@",operation.responseString]];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self addStringToTextView:[NSString stringWithFormat:@"error when upload to server:%@",error.description]];
             NSLog(@"error when upload to server:%@",error.description);
             
         }];
        
        [operation start];
        
        
        
    }
    
    NSDictionary *bodyDict = [NSDictionary dictionaryWithObjectsAndKeys:dataDictArray, @"data", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:NSJSONWritingPrettyPrinted error:nil];
    
    NSLog(@"post data to api server:%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    //NSLog(@"url = %@, body =  %@", urlString, bodyString);
    [request setHTTPBody:jsonData];
    [request setHTTPMethod:@"POST"];
    
    //[[NSURLConnection alloc] initWithRequest:request delegate:self];
    [NSURLConnection connectionWithRequest:request delegate:self];
    
    [_sensorDataToUpload removeAllObjects];
    
    
    
    return YES;
}




@end
