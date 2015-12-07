//
//  FilterVC.m
//  Beacons
//
//  Created by Martí Serra Vivancos on 25/06/14.
//  Copyright (c) 2014 Tomorrow. All rights reserved.
//

#import "FilterVC.h"
#import "CategoriesManager.h"

@interface FilterVC ()

@end

@implementation FilterVC


- (void)viewDidLoad
{
    // Navigation bar
    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    navBar.barTintColor = [UIColor colorWithRed:0 green:0.48f blue:1 alpha:1];
    navBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:20]};
    navBar.translucent = NO;
    [self.view addSubview:navBar];

    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,navBar.frame.size.height-1,navBar.frame.size.width, 1)];
    [navBorder setBackgroundColor:[UIColor colorWithWhite:200.0f/255.f alpha:0.8f]];
    [navBorder setOpaque:YES];
    [navBar addSubview:navBorder];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done.png"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil action:@selector(close)];
    done.tintColor = [UIColor whiteColor];

    UINavigationItem *navigItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"FILTER_TITLE", @"Settings")];
    navigItem.rightBarButtonItem = done;
    navBar.items = [NSArray arrayWithObjects: navigItem,nil];
    
    [UIBarButtonItem appearance].tintColor = [UIColor blueColor];    
    
    // Table view
    _filterCategories = [[NSMutableArray alloc]init];

    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, self.view.frame.size.height-70) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    // Categories
    CategoriesManager *manager = [CategoriesManager sharedManager];
    self.categories = [manager getSavedCategories];
    
    
    [super viewDidLoad];
}

// Populate UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Object at index 0 is category's name
    cell.textLabel.text = _categories[indexPath.row][0];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    // Objct at index 1 is image path
    cell.imageView.image = [UIImage imageWithContentsOfFile:_categories[indexPath.row][1]];
    cell.imageView.layer.cornerRadius = 4.0;
    cell.imageView.layer.masksToBounds = YES;
    
    return cell;
}

// Handle selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (![_filterCategories containsObject:_categories[indexPath.row][0]])
    {
        [_filterCategories addObject:_categories[indexPath.row][0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        [_filterCategories removeObject:_categories[indexPath.row][0]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    NSLog(@"filter %@", _filterCategories);
}

// Dismiss view
- (void) close
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    [_filterDelegate filterDidDismissWithArray:_filterCategories];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
