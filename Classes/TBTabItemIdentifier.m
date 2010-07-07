//
//  TBTabItemIdentifier.m
//  TabBar3
//
//  Created by Alex Gordon on 20/08/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import "TBTabItemIdentifier.h"

#import "TBTabItemLayer.h"
#import "TTBar.h"
#import "TBPreviewController.h"
#import "TBBlankInfoView.h"

@implementation TBTabItemIdentifier

@synthesize item;
@synthesize view;
@synthesize tabBar;
@synthesize icon;

@synthesize dict;
@synthesize type;

- (NSString *)name
{
	return [item label];
}
- (NSView *)itemview
{
	return [[self item] view];
}

- (void)refreshTabBar
{
	[self.tabBar displayEverything];
}

- (BOOL)canClose
{
	BOOL lastOne = [[self.item tabView] numberOfTabViewItems] == 1;
	if (lastOne && [[self.item view] isKindOfClass:[TBBlankInfoView class]])
		return NO;
	else
		return YES;
}
- (void)close
{
	BOOL lastOne = [[self.item tabView] numberOfTabViewItems] == 1;
	if (lastOne && [[self.item view] isKindOfClass:[TBBlankInfoView class]])
		return;

	[[self.item tabView] removeTabViewItem:self.item];

	[[TBPreviewController sharedController] hideIfItem:self.item];

	if (lastOne)
	{
		[tabBar.document documentDidSwitchFromView:[self itemview] toView:nil];
		[self.tabBar addButton:nil];
		[tabBar.document documentDidSwitchFromView:nil toView:[[tabBar.tabView selectedTabViewItem] view]];
	}
	else
		[self.tabBar displayEverything];
}
- (void)createNewTab
{
	
	[self.tabBar createNewViewForIdentifier:self];
	[self.tabBar beginIgnoringAnimations];
	[[self.tabBar tabView] addTabViewItem:self.item];
	[self.tabBar endIgnoringAnimations];
	
}
- (void)replaceCurrentTabWithItemAndMakeActive
{
	NSTabView *tv = self.tabBar.tabView;
	NSTabViewItem *selItem = [tv selectedTabViewItem];
	
	[self.tabBar createNewViewForIdentifier:self];
	//[[self.tabBar tabView] addTabViewItem:self.item];
	int index = [tv indexOfTabViewItem:selItem];
	[tv insertTabViewItem:self.item atIndex:index];
	[tv removeTabViewItem:selItem];
	[tv selectTabViewItem:self.item];
	
	[self.tabBar displayEverything];
}
- (void)makeActive
{
	NSTabView *tv = self.tabBar.tabView;
	NSTabViewItem *selItem = [tv selectedTabViewItem];
	
	[[self.tabBar tabView] selectTabViewItem:self.item];
	
	[self.tabBar displayEverything];
}

@end
