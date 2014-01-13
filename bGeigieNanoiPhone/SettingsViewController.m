//
//  SettingsViewController.m
//  bGeigieNanoiPhone
//
//  Created by Chen Yongping on 1/13/14.
//  Copyright (c) 2014 Eyes, JAPAN. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *apiKeyTextfield;
@property (weak, nonatomic) IBOutlet UITextField *deviceIDTextfield;
- (IBAction)pushRob:(id)sender;

@end

@implementation SettingsViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud valueForKey:@"deviceID"]) {
        _deviceIDTextfield.text = [ud valueForKey:@"deviceID"];
    }
    
    if ([ud valueForKey:@"apiKey"]) {
        _apiKeyTextfield.text = [ud valueForKey:@"apiKey"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


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

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (textField == _apiKeyTextfield) {
        [ud setObject:_apiKeyTextfield.text forKey:@"apiKey"];
        
    }else if(textField == _deviceIDTextfield){
        [ud setObject:_deviceIDTextfield.text forKey:@"deviceID"];
    }
}

- (IBAction)pushRob:(id)sender {
    
    _apiKeyTextfield.text = @"q1LKu7RQ8s5pmyxunnDW";
    _deviceIDTextfield.text = @"44";
    [self textFieldDidEndEditing:_apiKeyTextfield];
    [self textFieldDidEndEditing:_deviceIDTextfield];
}
@end