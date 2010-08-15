//
//  TTWindow.m
//  toptabs
//
//  Created by Alex Gordon on 04/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TTWindow.h"
#import "TTBar.h"
#import "TTBarContainerView.h"

@implementation TTWindow

- (void)awakeFromNib
{
	if ([super respondsToSelector:@selector(awakeFromNib)])
		[super awakeFromNib];
	
	//NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"test"]; 
	//[self setToolbar:toolbar];
	
	[tabBar removeFromSuperview];
	
	[self setShowsToolbarButton:NO];
	
	NSRect tabContainerFrame = [tabBar frame];
	tabContainerFrame.origin.y += 31.0;
	tabContainerFrame.origin.x = 0.0;
	tabContainerFrame.size.width = [[[self contentView] superview] frame].size.width;
	
	TTBarContainerView *tabContainer = [[TTBarContainerView alloc] initWithFrame:tabContainerFrame];
	[tabContainer setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
	
	NSView *themeFrame = [[self contentView] superview];
	[themeFrame addSubview:tabContainer];
	
	NSRect tabBarFrame = [tabBar frame];
	tabBarFrame.origin.y = 0.0;
	tabBarFrame.origin.x = 61;
	tabBarFrame.size.width = tabContainerFrame.size.width - tabBarFrame.origin.x;
	[tabBar setAutoresizingMask:NSViewWidthSizable];
	[tabBar setFrame:tabBarFrame];
	
	[tabContainer addSubview:tabBar];
	
	[self display];
}

- (TTBar *)tabBar
{
	return tabBar;
}

@end
