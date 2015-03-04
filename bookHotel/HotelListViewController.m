//
//  HotelListViewController.m
//  bookHotel
//
//  Created by drwizzard on 2/15/15.
//  Copyright (c) 2015 nacnud. All rights reserved.
//

#import "HotelListViewController.h"
#import "AppDelegate.h"
#import "Hotel.h"
#import "RoomListViewController.h"
#import "CoreDataStack.h"
#import "HotelService.h"


@interface HotelListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *hotels;
//@property (strong, nonatomic) CoreDataStack *cdStack;
@end

@implementation HotelListViewController

- (void)viewDidLoad {
    
    
    
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Hotel"];
    NSError *fetchError;
    
    
    NSArray *results = [[[HotelService sharedService] coreDataStack].managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    Hotel *ahotel = results[0];
    NSLog(@"results: %@", ahotel.name);
    if (!fetchError){
        self.hotels = results;
        [self.tableView reloadData];
    }
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.hotels.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"HOTEL_CELL"];
    Hotel *hotel = self.hotels[indexPath.row];
    

    cell.textLabel.text = hotel.name;
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SHOW_ROOM_LIST"]){
        RoomListViewController *roomVC = (RoomListViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        roomVC.selectedHotel = self.hotels[indexPath.row];
        
    }
}



/*
 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
