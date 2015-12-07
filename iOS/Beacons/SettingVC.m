//
//  SettingVC.m
//  Beacons
//
//  Created by Martí Serra Vivancos on 14/07/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import "SettingVC.h"
#import "FilterVC.h"

@implementation SettingVC

+ (id)sharedView
{
    static SettingVC *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = NSLocalizedString(@"SETTINGS_TITLE", @"Settings");
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    filterButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = filterButton;
    
    // User options
    UITableView *myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    myTable.delegate = self;
    myTable.dataSource = self;
    [self.view addSubview:myTable];
}

- (void) viewWillAppear:(BOOL)animated
{
    // Navigation bar
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0.48f blue:1 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:20]};
    self.navigationController.navigationBar.translucent = NO;
 
}


// Populate UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section==0) return 2;
    if (section==1) return 3;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // First row
    if (indexPath.section == 0 && indexPath.row ==0) {
        
        cell.textLabel.text = NSLocalizedString(@"BACK_NOTS", @"Background notifications");
        
        // Notification switch
        UISwitch *notswitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, 40, 25, 50)];
        [notswitch setOn:YES];
        [notswitch addTarget:self
                      action:@selector(switchIsChanged:)
            forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = notswitch;
        notswitch.on = [[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"backNots"]boolValue];
    }
    
    // Second row
    /*if (indexPath.section == 0 && indexPath.row ==1) {
        
        cell.textLabel.text = NSLocalizedString(@"BACK_NOTS", @"Background notifications");
        
    }*/
   
    return cell;
}

// Switch preferences
- (void) switchIsChanged:(UISwitch *)paramSender
{
    if ([paramSender isOn])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"backNots"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"backNots"];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* if (indexPath.section == 0 && indexPath.row ==1) {
         [self.navigationController pushViewController:[[FilterVC alloc]init] animated:YES];
        
     }*/
}

// Dismiss vc
- (void) close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
