//
//  TBButton.m
//  TabBar3
//
//  Created by Alex Gordon on 22/12/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import "TBButton.h"
#import "TTBar.h"

@implementation TBButton

//@synthesize target;
//@synthesize action;

- (id)initWithFrame:(NSRect)r
{
	if (self = [super initWithFrame:r])
	{
		state = 0;
		
	}
	return self;
}

- (void)viewDidMoveToWindow
{
	NSTrackingArea *ta = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:(NSTrackingMouseEnteredAndExited | NSTrackingInVisibleRect | NSTrackingActiveAlways) owner:self userInfo:nil];
	[self addTrackingArea:ta];
	
	if ([self window])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becameMain:) name:NSWindowDidBecomeMainNotification object:[self window]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignMain:) name:NSWindowDidResignMainNotification object:[self window]];
	}
	else
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:nil];
	}
}
- (void)finalize
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:nil];
	
	[super finalize];
}
- (void)becameMain:(NSNotification *)notif
{
	[self setNeedsDisplay:YES];
}
- (void)resignMain:(NSNotification *)notif
{
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
	[[self class] drawMainRect:[self bounds] obj:self];
}
+ (void)drawMainRect:(NSRect)rect obj:(id)object
{	
	{
		NSColor *topLineColor = [NSColor colorWithCalibratedWhite:([[object window] isMainWindow] ? 0.251 : 0.529) alpha:1.0];
		
		NSColor *topGradientColor = [NSColor colorWithCalibratedWhite:0.906 alpha:1.0];
		NSColor *bottomGradientColor = [NSColor colorWithCalibratedWhite:0.824 alpha:1.0];
		
		if ([object mouseState] == 1)
		{
			topGradientColor = [NSColor colorWithCalibratedWhite:0.737 alpha:1.0];
			bottomGradientColor = [NSColor colorWithCalibratedWhite:0.898 alpha:1.0];
		}
		else if ([object mouseState] == -1)
		{
			topGradientColor = [NSColor colorWithCalibratedWhite:0.831 alpha:1.0];
			bottomGradientColor = [NSColor colorWithCalibratedWhite:0.753 alpha:1.0];
		}
		
		//NSColor *bottomLineHighlight = [NSColor colorWithCalibratedWhite:0.875 alpha:1.0];
		NSColor *bottomLineHighlight = [NSColor colorWithCalibratedWhite:0.93 alpha:1.0];
		
		NSColor *bottomLineColor = [NSColor colorWithCalibratedWhite:0.525 alpha:1.0];
		
		
		NSRect lineRect = NSMakeRect(0, 0, rect.size.width, 1);
		
		lineRect.size.height = rect.size.height;
		lineRect.origin.y = 0;
		NSGradient *grad = [[NSGradient alloc] initWithStartingColor:topGradientColor endingColor:bottomGradientColor];
		[grad drawInRect:lineRect angle:90];
		
		
		lineRect.origin.y = 0;
		lineRect.size.height = 1;
		[topLineColor set];
		NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
		
		
		
		lineRect.origin.y = rect.size.height - 1;
		[bottomLineColor set];
		NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
	}
	
	
	if ([object image])
	{
		NSSize size = [[object image] size];
		NSPoint point = NSMakePoint(round(rect.size.width/2.0 - size.width/2.0), round(rect.size.height/2.0 + size.height/2.0));
		[[object image] compositeToPoint:point operation:NSCompositeSourceOver];
	}
}

- (int)mouseState
{
	return state;
}

- (void)mouseDown:(NSEvent *)e
{
	state = 1;
	[self setNeedsDisplay:YES];
}
- (void)mouseDragged:(NSEvent *)e
{
	NSPoint p = [self convertPoint:[e locationInWindow] fromView:nil];
	if (NSPointInRect(p, [self bounds]))
		state = 1;
	else
		state = 0;
	
	[self setNeedsDisplay:YES];
}
- (void)mouseUp:(NSEvent *)e
{
	if (state)
	{
		if ([[self target] respondsToSelector:[self action]])
			[[self target] performSelector:[self action] withObject:self];
	}
	
	state = 0;
	[self setNeedsDisplay:YES];
}
- (void)mouseEntered:(NSEvent *)e
{
	state = -1;
	[self setNeedsDisplay:YES];
}
- (void)mouseExited:(NSEvent *)e
{
	state = 0;
	[self setNeedsDisplay:YES];
}


@end
