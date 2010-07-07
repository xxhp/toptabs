//
//  TBAddSplitButton.m
//  Chocolat
//
//  Created by Alex Gordon on 10/07/2009.
//  Copyright 2009 Fileability. All rights reserved.
//

#import "TBAddSplitButton.h"


@implementation TBAddSplitButton


- (void)awakeFromNib
{
	self.orientation = NO;
	self.horizontal = [[NSUserDefaults standardUserDefaults] boolForKey:@"split.horizontal"]; //Get from preferences
}

- (void)drawRect:(NSRect)rect
{
	rect = [self bounds];
	
	[super drawRect:rect];
    
	NSColor *sideLineColor = [NSColor colorWithCalibratedWhite:0.525 alpha:1.0];
	NSRect sideRect = NSMakeRect(0, 1, 1, rect.size.height - 1);
	[sideLineColor set];
	NSRectFillUsingOperation(sideRect, NSCompositeSourceOver);
}


@synthesize horizontal;

- (void)setHorizontal:(BOOL)b
{
	horizontal = b;
	[self updateImage];
}


@synthesize orientation;

- (void)setOrientation:(BOOL)b
{
	orientation = b;
	[self updateImage];
}


- (void)updateImage
{	
	if (horizontal)
	{
		[self setImage:[NSImage imageNamed:@"TBAddSplitHorizontal_Image"]];
	}
	else
	{
		[self setImage:[NSImage imageNamed:@"TBAddSplitVertical_Image"]];
	}
	
	
	return;
	
	if (orientation)
	{
		if (horizontal)
		{
			[self setImage:[NSImage imageNamed:@"TBSetSplitOrientationtHorizontal_Image"]];
		}
		else
		{
			[self setImage:[NSImage imageNamed:@"TBSetSplitOrientationtVertical_Image"]];
		}
	}
	else
	{
		if (horizontal)
		{
			[self setImage:[NSImage imageNamed:@"TBAddSplitHorizontal_Image"]];
		}
		else
		{
			[self setImage:[NSImage imageNamed:@"TBAddSplitVertical_Image"]];
		}
	}
}

- (void)flagsChanged:(NSEvent *)event
{
	BOOL startHorizontal = [[NSUserDefaults standardUserDefaults] boolForKey:@"split.horizontal"];
	BOOL altOn = (([event modifierFlags] & NSAlternateKeyMask) != 0);
	BOOL cmdOn = (([event modifierFlags] & NSCommandKeyMask) != 0);
	
	
	self.horizontal = startHorizontal != altOn;
	self.orientation = cmdOn;
	
	[self updateImage];
	
	[self setNeedsDisplay:YES];
}

@end
