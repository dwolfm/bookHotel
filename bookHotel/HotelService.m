//
//  HotelService.m
//  bookHotel
//
//  Created by drwizzard on 2/15/15.
//  Copyright (c) 2015 nacnud. All rights reserved.
//


#import "HotelService.h"
#import <UIKit/UIKit.h>


@implementation HotelService

+(id)sharedService {
    static HotelService *mySharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        mySharedService = [[self alloc] init];
    });
    return mySharedService;
}


-(instancetype)init {
    self = [super init];
    if (self) {
        self.coreDataStack = [[CoreDataStack alloc] init];
    }
    return self;
}

-(instancetype)initForTesting {
    self = [super init];
    if (self) {
        self.coreDataStack = [[CoreDataStack alloc] initForTesting];
    }
    return self;
}

-(Reservation *)bookReservationForGuest:(Guest *)guest ForRoom:(Room *)room startDate:(NSDate*)startDate endDate:(NSDate *)endDate {
    Reservation *reservation = [NSEntityDescription insertNewObjectForEntityForName:@"Reservation" inManagedObjectContext:self.coreDataStack.managedObjectContext];
    reservation.startDate = startDate;
    reservation.endDate = endDate;
    reservation.room = room;
    reservation.guest = guest;
    
    NSDate *date = [NSDate date];
    
    NSLog(@"Start date and End dates for reservation are : %@ and %@", reservation.startDate, reservation.endDate);
    NSLog(@"Hotel reserved is : %@", reservation.room.hotel);
    NSLog(@"Room reserved is : %@", reservation.room.number);
    
    //validation for start date to be less than or equal to end date
    
    if( [reservation.startDate timeIntervalSinceDate:reservation.endDate] > 0 ){
        NSLog(@"The end date is smaller than start date for this reservation");
        return nil;
    }
    
    NSComparisonResult result = [date compare:reservation.startDate];
    if (result == NSOrderedAscending) {
        NSLog(@"now < startdate");
    } else if (result == NSOrderedSame) {
        NSLog(@"now == startdate");
    } else if (result == NSOrderedDescending) {
        NSLog(@"now > startdate");
    }
    
    //    if (result == NSOrderedDescending) {
    //        NSLog(@"This reservation is in the past");
    //        return nil;
    //    }
    
    
    
    NSError *saveError;
    [self.coreDataStack.managedObjectContext save:&saveError];
    if (!saveError) {
        return reservation;
    } else {
        return nil;
    }
}

-(void)checkRoomAvailabilityForGuest:(NSString *)hotel startDate:(NSDate *)starttDate endDate:(NSDate *)endDate {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Room"];
    NSLog(@"Hotel selected for availability is %@", hotel);
    
    //fetch all rooms with hotel name that matches the selected hotel
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hotel.name MATCHES %@",hotel];
    
    fetchRequest.predicate = predicate;
    
    NSFetchRequest *reservationFetch = [NSFetchRequest fetchRequestWithEntityName:@"Reservation"];
    
    NSPredicate *reservationPredicate = [NSPredicate predicateWithFormat:@"room.hotel.name MATCHES %@ AND startDate <= %@ AND endDate >= %@", hotel, endDate, starttDate];
    
    NSLog(@"Start date and End dates to check for availability are : %@ and %@", starttDate, endDate);
    
    reservationFetch.predicate = reservationPredicate;
    NSError *fetchError;
    
    NSArray *results = [[[HotelService sharedService] coreDataStack].managedObjectContext executeFetchRequest:reservationFetch error:&fetchError];
    NSLog(@"Rooms reserved in that period are: %lu", (unsigned long)results.count);
    
    NSMutableArray *rooms = [NSMutableArray new];
    
    for (Reservation *reservation in results) {
        [rooms addObject:reservation.room];
        NSLog(@"Rooms checked out for availability are: %@", reservation.room);
    }
    
    NSFetchRequest *anotherFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Room"];
    NSPredicate *roomsPredicate = [NSPredicate predicateWithFormat:@"hotel.name MATCHES %@ AND NOT (self IN %@)", hotel, rooms];
    anotherFetchRequest.predicate = roomsPredicate;
    NSError *finalError;
    NSArray *finalResults = [[[HotelService sharedService] coreDataStack].managedObjectContext executeFetchRequest:anotherFetchRequest error:&finalError];
    if (finalError) {
        NSLog(@"%@",finalError.localizedDescription);
    }
    
    NSLog(@"results for number of available rooms : %lu",(unsigned long)finalResults.count);
    //NSLog(@"ARRAY for number of available rooms : %@",finalResults);
    
    for (Room *availableRoom in finalResults) {
        NSLog(@"These room is available for this hotel and dates selected: %@", availableRoom);
    }
    
    [self myAlert:[NSString stringWithFormat:@"%lu", (unsigned long)finalResults.count]];
}

- (void) myAlert: (NSString*)errorMessage
{
    UIAlertView *myAlert = [[UIAlertView alloc]
                            initWithTitle:errorMessage
                            message:@"Rooms Available"
                            delegate:self
                            cancelButtonTitle:nil
                            otherButtonTitles:@"Ok", nil];
    myAlert.cancelButtonIndex = -1;
    [myAlert setTag:1000];
    [myAlert show];
}

@end
