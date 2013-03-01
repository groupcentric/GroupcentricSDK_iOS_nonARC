//
//  MainViewController.h
//  TKContactsMultiPicker
//
//  Created by Jongtae Ahn on 12. 8. 31..
//  Copyright (c) 2012년 TABKO Inc. All rights reserved.
//

#import "gc_TKAddressBook.h"

@implementation gc_TKAddressBook
@synthesize name, email, tel, thumbnail, recordID, sectionNumber, rowSelected, phoneArray;

- (void)dealloc
{
    [name release];
    [email release];
    [tel release];
    [thumbnail release];
    [phoneArray release];
    [super dealloc];
}

@end
