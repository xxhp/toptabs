//
//  TTDefaultController.m
//  toptabs
//
//  Created by Alex Gordon on 10/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TTDefaultController.h"


@implementation TTDefaultController

@synthesize navigationController;

@synthesize windowController;
@synthesize splitControllers;
@synthesize contentView;

@synthesize isDirty;

@synthesize item;
@synthesize view;
@synthesize tabBar;
@synthesize icon;

@synthesize dict;
@synthesize type;

- (void)closeTab
{
	[[self.item tabView] removeTabViewItem:self.item];
}
- (void)createNewTab
{
	
}
- (void)replaceCurrentTabWithItemAndMakeActive
{
	
}
- (void)makeActive
{
	
}
- (void)moveToBar:(TTBar *)bar
{
	NSLog(@"Move to bar %@", bar);
}

@end
