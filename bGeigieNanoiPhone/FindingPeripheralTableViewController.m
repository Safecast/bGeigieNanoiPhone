//
//  FindingPeripheralTableViewController.m
//  bGeigieNanoiPhone
//
//  Created by Chen Yongping on 1/7/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//

#import "FindingPeripheralTableViewController.h"

@interface FindingPeripheralTableViewController ()<CBCentralManagerDelegate>
@property (strong, nonatomic) CBCentralManager      *centralManager;

@property (nonatomic, strong) NSMutableArray        *foundPeripherals;

@end

@implementation FindingPeripheralTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    _foundPeripherals = [[NSMutableArray alloc] init];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    if ([peripheral.name hasPrefix:@"BLEBee"]) {
        if (![self theDeviceExitsInArray:peripheral.name]) {
            [_foundPeripherals addObject:peripheral];
            [self.tableView reloadData];
        }
    }
    /*
     if (!_connectingPeripheral) {
     [_centralManager stopScan];
     
     _connectingPeripheral = peripheral;
     
     [self.centralManager connectPeripheral:peripheral options:nil];
     [self addStringToTextView:@"request to connect peripheral"];
     }
     */
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _foundPeripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    CBPeripheral *peripheral = [_foundPeripherals objectAtIndex:indexPath.row];
    if (peripheral) {
        cell.textLabel.text = peripheral.name;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
