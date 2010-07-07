//
//  TBPopupButton.m
//  TabBar3
//
//  Created by Alex Gordon on 24/12/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import "TBPopupButton.h"

@class TBButton, TTBar;

@implementation TBPopupButton

@synthesize isBlank;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
	}
    return self;
}

- (void)viewDidMoveToWindow
{
	NSTrackingArea *ta = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:(NSTrackingMouseEnteredAndExited | NSTrackingInVisibleRect | NSTrackingActiveAlways) owner:self userInfo:nil];
	[self addTrackingArea:ta];
}

- (void)drawRect:(NSRect)rect
{
	if ([self numberOfItems] <= 1)
		[TTBar drawBackgroundInRect:[self bounds] flipped:NO light:![[self window] isMainWindow] hover:NO];
	else
		[TBButton drawMainRect:[self bounds] obj:self];
}

- (int)mouseState
{
	return (mouseState != -1 ? 0 : -1);
}

- (void)mouseDown:(NSEvent *)e
{
	[super mouseDown:e];
	
	mouseState = 1;
	[self setNeedsDisplay:YES];
}
- (void)mouseDragged:(NSEvent *)e
{
	[super mouseDragged:e];
	
	NSPoint p = [self convertPoint:[e locationInWindow] fromView:nil];
	if (NSPointInRect(p, [self bounds]))
		mouseState = 1;
	else
		mouseState = 0;
	
	[self setNeedsDisplay:YES];
}
- (void)mouseUp:(NSEvent *)e
{
	[super mouseUp:e];
	
	mouseState = 0;
	[self setNeedsDisplay:YES];
}
- (void)mouseEntered:(NSEvent *)e
{
	mouseState = -1;
	[self setNeedsDisplay:YES];
}
- (void)mouseMoved:(NSEvent *)e
{
	
}
- (void)mouseExited:(NSEvent *)e
{
	mouseState = 0;
	[self setNeedsDisplay:YES];
}

- (void)setImage:(NSImage *)img
{
	image = img;
}
- (NSImage *)image
{
	return image;
}

@end
