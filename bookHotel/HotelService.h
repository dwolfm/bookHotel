//
//  HotelService.h
//  bookHotel
//
//  Created by drwizzard on 2/15/15.
//  Copyright (c) 2015 nacnud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "CoreDataStack.h"
#import "Reservation.h"
#import "Room.h"
#import "Guest.h"
@interface HotelService : NSObject
+(id)sharedService;

@property (strong,nonatomic) CoreDataStack *coreDataStack;

-(instancetype)initForTesting;

-(Reservation *)bookReservationForGuest:(Guest *)guest ForRoom:(Room *)room startDate:(NSDate*)startDate endDate:(NSDate *)endDate;

-(void)checkRoomAvailabilityForGuest:(NSString *)hotel startDate:(NSDate*)starttDate endDate:(NSDate *)endDate;



@end
