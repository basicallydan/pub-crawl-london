//
//  LPCLineOptionModalViewController.m
//  London Pub Crawl
//
//  Created by Daniel Hough on 13/11/2013.
//  Copyright (c) 2013 LondonPubCrawl. All rights reserved.
//

#import "LPCLineOptionModalViewController.h"

@interface LPCLineOptionModalViewController () <UITableViewDataSource>

@end

@implementation LPCLineOptionModalViewController

NSArray *startingStations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (id)initWithStartingStations:(NSArray *)stations {
    self = [self initWithNibName:@"LPCLineOptionModalViewController" bundle:nil];
    
    startingStations = stations;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [startingStations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    cell.textLabel.text = [startingStations objectAtIndex:indexPath.row];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate didSelectStartingStation:[startingStations objectAtIndex:indexPath.row]];
}


@end
