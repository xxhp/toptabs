//
//  TBTabItemLayer.m
//  TabBar3
//
//  Created by Alex Gordon on 20/08/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import "TBTabItemLayer.h"

#import "TTController.h"
#import "TTBar.h"
#import "TBPreviewController.h"
#import "TBBlankInfoView.h"

@implementation TBTabItemLayer

@synthesize ident;

- (id)init
{
    if (self = [super init]) {
        gtx = -10;
		willHandleBringFront = NO;
		self.needsDisplayOnBoundsChange=YES;
		self.delegate = self;
		self.anchorPoint = CGPointMake(0, 0);
		backgroundStatus = 0;
		
		inFilePathMenuMode = NO;
	}
	
    return self;
}

- (NSArray *)textAttributes
{
	NSTabState state = [ident.item tabState];
	
	id attr = nil;
	id shadowAttr = nil;
	
	NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	//[paraStyle setAlignment:NSCenterTextAlignment];
	
	if (state == NSBackgroundTab)
	{
		attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
		shadowAttr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithCalibratedWhite:1.0 alpha:0.6], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
	}
	else if (state == NSSelectedTab)
	{
		attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
		shadowAttr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithCalibratedWhite:0.0 alpha:0.5], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
	
		//attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
		//shadowAttr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithCalibratedWhite:1.0 alpha:0.5], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
		
		if (![[ident.tabBar window] isMainWindow])
		{
			attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
			shadowAttr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithCalibratedWhite:1.0 alpha:0.6], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
		}
	}
	
	return [NSArray arrayWithObjects:attr, shadowAttr, nil];
}

- (NSRect)textRect
{
	NSTabState state = [ident.item tabState];

	id attr, shadowAttr;

	NSImage *closeIcon = [NSImage imageNamed:@"TBCloseButton_Image"];
	NSPoint closeIconPoint = NSMakePoint(round(26/2 - closeIcon.size.width/2), round(NSRectFromCGRect(self.bounds).size.height/2.0 - [closeIcon size].height/2.0 -  1.0));
	
	NSRect rect = NSRectFromCGRect(self.bounds);
	
	NSArray *textAttributes = [self textAttributes];
	attr = [textAttributes objectAtIndex:0];
	
	float iconOffset = 23;
	float textPadding = 10;
	float extraBit = 3;
	
	NSImage *icon = [ident icon];
	if (icon == 0)
		iconOffset = 0;
	
	NSString *label = [ident.item label];
	NSSize size = [label sizeWithAttributes:attr];
	
	//	NSPoint point = NSMakePoint((icon ? iconOffset + textPadding + textPadding : 18 + 1) + extraBit, rect.size.height/2 - size.height/2);
	//	NSRect textDrawRect = NSMakeRect(point.x, point.y, width + 18 - (icon ? iconOffset + textPadding + extraBit + extraBit + extraBit: 18) - textPadding, size.height);
	
	NSPoint point = NSMakePoint(iconOffset + textPadding - 3 + (icon ? [icon size].width : closeIconPoint.x + [closeIcon size].width), rect.size.height/2 - size.height/2);
	NSRect textDrawRect = NSMakeRect(point.x, point.y, rect.size.width - iconOffset - (textPadding * 2) - (icon ? [icon size].width : closeIconPoint.x + [closeIcon size].width), size.height);
	
	return textDrawRect;
}

+ (id)defaultValueForKey:(NSString *)key
{
	if ([key isEqualToString:@"needsDisplayOnBoundsChange"])
		return (id) kCFBooleanTrue;
	
	return [super defaultValueForKey:key];
}
+ (id<CAAction>)defaultActionForKey:(NSString *)event
{
	if ([event isEqualToString:@"opacity"])
		return nil;
	
	return [super defaultActionForKey:event];
}

- (NSBezierPath *)backgroundPath
{
	//The approximate radius of the curve
	const float curve_amount = 3.0;
	
	//The horizontal distance between the bottom of the curve and the top of the curve
	const float curve_width = 8.0;
	
	//The full height of the tab
	const float height = [self bounds].size.height - 2.0;

	//The full width of the tab (including the padding of curve_amount on each side)
	const float width = [self bounds].size.width;
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	
	
	//Point 1
	NSPoint p1 = NSZeroPoint;
	NSPoint p1c1 = NSMakePoint(curve_amount, 0);
	[path moveToPoint:p1];
	
	//Point 3
	NSPoint p3c1 = NSMakePoint(curve_width - curve_amount, height);
	NSPoint p3 = NSMakePoint(curve_width, height);
	[path curveToPoint:p3 controlPoint1:p1c1 controlPoint2:p3c1];
	
	//Q-Point 3
	NSPoint q3 = NSMakePoint(width - p3.x, p3.y);
	NSPoint q3c1 = NSMakePoint(width - p3c1.x, p3c1.y);
	[path lineToPoint:q3];
	
	//Q-Point 1
	NSPoint q1c1 = NSMakePoint(width - p1c1.x, p1c1.y);
	NSPoint q1 = NSMakePoint(width - q1.x, q1.y);
	[path curveToPoint:q1 controlPoint1:q3c1 controlPoint2:q1c1];
	
	[path closePath];
		
	return path;
}
- (void)drawLayer:(CALayer *)theLayer inContext:(CGContextRef)theContext
{	
	NSGraphicsContext *oldContext = [NSGraphicsContext currentContext];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:theContext flipped:NO]];
	
	NSRect rect = NSRectFromCGRect(self.bounds);
	NSTabState state = [ident.item tabState];
	
	NSDictionary *attr = nil;
	NSDictionary *shadowAttr = nil;
	
	NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[paraStyle setAlignment:NSCenterTextAlignment];
	
	if (state == NSBackgroundTab)
	{
		attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
		shadowAttr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithCalibratedWhite:1.0 alpha:0.6], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
		
		[TTBar drawBackgroundInRect:rect flipped:YES light:![[ident.tabBar window] isMainWindow] hover:backgroundStatus == -1];
		
		//NSBezierPath *backgroundPath = [self backgroundPath];
		//[[NSColor redColor] set];
		//[backgroundPath fill];
		
		NSRect sideLine = NSMakeRect(0, 0, 1, rect.size.height - 1);
		NSRectFillUsingOperation(sideLine, NSCompositeSourceOver);
		
		sideLine = NSMakeRect(rect.size.width - 1, 0, 1, rect.size.height - 1);
		NSRectFillUsingOperation(sideLine, NSCompositeSourceOver);
	}
	else if (state == NSPressedTab)
	{
		[[NSColor blueColor] set];
		NSRectFill(rect);
	}
	else if (state == NSSelectedTab)
	{
		rect = NSRectFromCGRect(self.bounds);
		attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
		shadowAttr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithCalibratedWhite:0.0 alpha:0.5], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
		if (![[ident.tabBar window] isMainWindow])
		{
			attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
			shadowAttr = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor colorWithCalibratedWhite:1.0 alpha:0.6], NSForegroundColorAttributeName, [NSFont systemFontOfSize:11], NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
		}
		
		NSColor *topGradientColor = [NSColor colorWithCalibratedWhite:([[ident.tabBar window] isMainWindow] ? 0.584 : 0.812) alpha:1.0];
		NSColor *bottomGradientColor = [NSColor colorWithCalibratedWhite:([[ident.tabBar window] isMainWindow] ? 0.45 : 0.778) alpha:1.0];
		
		NSColor *bottomLineHighlight = [NSColor colorWithCalibratedWhite:([[ident.tabBar window] isMainWindow] ? 0.492 : 0.788) alpha:1.0];
		NSColor *bottomLineColor = [NSColor colorWithCalibratedWhite:([[ident.tabBar window] isMainWindow] ? 0.251 : 0.529) alpha:1.0];
		
		NSRect lineRect = NSMakeRect(0, 0, rect.size.width, 1);
		
		lineRect.size.height = rect.size.height;
		lineRect.origin.y = 0;
		NSGradient *grad = [[NSGradient alloc] initWithStartingColor:topGradientColor endingColor:bottomGradientColor];
		[grad drawInRect:lineRect angle:270];
		
		lineRect.size.height = 1;
		lineRect.origin.y = 1;
		[bottomLineHighlight set];
		NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
		
		lineRect.origin.y = 0;
		[bottomLineColor set];
		NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
		
		NSRect sideLine = NSMakeRect(0, 0, 1, rect.size.height);
		NSRectFillUsingOperation(sideLine, NSCompositeSourceOver);
		
		sideLine = NSMakeRect(rect.size.width - 1, 0, 1, rect.size.height);
		NSRectFillUsingOperation(sideLine, NSCompositeSourceOver);
	}
	
	NSArray *textAttributes = [self textAttributes];
	attr = [textAttributes objectAtIndex:0];
	shadowAttr = [textAttributes objectAtIndex:1];

	
	float width = rect.size.width - 18;
	
	NSImage *closeIcon = [NSImage imageNamed:@"TBCloseButton_Image"];
	if ([ident isDirty] && closeIconStatus == 0)
	{
		closeIcon = [NSImage imageNamed:@"TBCloseButtonDirty_Image"];
	}
	
	NSPoint closeIconPoint = NSMakePoint(round(26/2 - closeIcon.size.width/2), round(NSRectFromCGRect(self.bounds).size.height/2.0 - [closeIcon size].height/2.0 -  1.0));
	
	if ([[ident.item tabView] numberOfTabViewItems] > 1 && !(backgroundStatus == 0 && state == NSBackgroundTab))
	{
		[closeIcon compositeToPoint:closeIconPoint operation:NSCompositeSourceOver];
		if (closeIconStatus == 1)
			[closeIcon compositeToPoint:closeIconPoint operation:NSCompositeSourceOver];
	}
	
	//26 pixels from origin.x to image.x
	
	
	float iconOffset = 23;
	float textPadding = 8;
	float extraBit = 3;
	
	
	NSImage *icon = [ident icon];
	if (icon == 0)
		iconOffset = 0;
	
	NSString *label = [ident.item label];
	NSSize size = [label sizeWithAttributes:attr];
	

	
//	NSPoint point = NSMakePoint((icon ? iconOffset + textPadding + textPadding : 18 + 1) + extraBit, rect.size.height/2 - size.height/2);
//	NSRect textDrawRect = NSMakeRect(point.x, point.y, width + 18 - (icon ? iconOffset + textPadding + extraBit + extraBit + extraBit: 18) - textPadding, size.height);

	NSPoint point = NSMakePoint(iconOffset + textPadding - 3 + (icon ? [icon size].width : closeIconPoint.x + [closeIcon size].width), rect.size.height/2 - size.height/2);
	NSRect textDrawRect = [self textRect]; //NSMakeRect(point.x, point.y, rect.size.width - iconOffset - (textPadding * 2) - (icon ? [icon size].width : closeIconPoint.x + [closeIcon size].width), size.height);

	
	
	textDrawRect.origin.y--;
	[label drawInRect:textDrawRect withAttributes:shadowAttr];
	
	textDrawRect.origin.y++;
	[label drawInRect:textDrawRect withAttributes:attr];
	
	if (icon)
	{
		NSSize iconSize = [icon size];
		point = NSMakePoint(iconOffset, rect.size.height/2.0 - iconSize.height/2.0);
		[icon compositeToPoint:point operation:NSCompositeSourceOver];
	}
	
	[NSGraphicsContext setCurrentContext:oldContext];
	//[NSGraphicsContext restoreGraphicsState];
}

- (void)setGoingToX:(float)f
{
	gtx = f;
}
- (float)goingToX
{
	return gtx;
}

- (BOOL)isOpaque
{
	return NO;
}
- (BOOL)isFlipped
{
	return YES;
}

- (void)sublayer_mouseDown:(NSEvent *)e
{	
	inFilePathMenuMode = NO;
	
	NSPoint p = [e locationInWindow];	
	if (NSPointInRect(p, NSMakeRect(3, 0, 20, self.frame.size.height)) && ([[ident.item tabView] numberOfTabViewItems] > 1 || [[ident.item view] isKindOfClass:[TBBlankInfoView class]] == NO))
	{
		closeIconStatus = 1;
		stopDragging = YES;
	}
	else if (NSPointInRect(p, NSRectFromCGRect(self.bounds)))
	{
		if (([e modifierFlags] & NSCommandKeyMask) == NSCommandKeyMask)
		{
			//File path menu
			inFilePathMenuMode = YES;
			[ident showFilePathMenu:e];
		}
		else
		{
			willHandleBringFront = YES;
			[[ident.item tabView] selectTabViewItem:ident.item];
		}
	}
	
	//[[TBPreviewController sharedController] hideIfItem:ident.item];
	
	[self setNeedsDisplay];
}

- (void)sublayer_mouseDragged:(NSEvent *)e
{
	if (inFilePathMenuMode)
		return;
	
	NSPoint p = [e locationInWindow];	
	if (!stopDragging)
	{
		if (!dragging)
		{
			draggingPoint = p;
		}
		else if (dragging)
		{
			CGPoint newOrigin = self.position;
			newOrigin.x -= draggingPoint.x - p.x;
			if (newOrigin.x < 0)
				newOrigin.x = 0;
			else if (newOrigin.x + self.frame.size.width > [ident.tabBar frame].size.width)
				newOrigin.x = [ident.tabBar frame].size.width - self.frame.size.width;
			
			[CATransaction begin];
			[CATransaction flush];
			
			[CATransaction setValue:(id)kCFBooleanTrue
							 forKey:kCATransactionDisableActions];
		 
			self.position = newOrigin;
			
			[CATransaction commit];
			
			[self.ident.tabBar setNeedsDisplay:YES];
			[self.ident.tabBar draggingTab:self.ident];
		}
		dragging = YES;
	}
	else if ([[ident.item tabView] numberOfTabViewItems] > 1 || [[ident.item view] isKindOfClass:[TBBlankInfoView class]] == NO)
	{
		if (NSPointInRect(p, NSMakeRect(3, 0, 20, self.frame.size.height)))
		{
			closeIconStatus = 1;
		}
		else
			closeIconStatus = 0;
		
		[self setNeedsDisplay];
	}
	
	
	
}

- (void)sublayer_mouseUp:(NSEvent *)e
{
	if (inFilePathMenuMode)
		return;
	
	NSPoint p = [e locationInWindow];
	if (NSPointInRect(p, NSRectFromCGRect(self.bounds)) && !dragging && [[ident.item tabView] numberOfTabViewItems] > 1)
	{
		if (NSPointInRect(p, NSMakeRect(3, 0, 20, self.frame.size.height)))
		{
			[ident closeTab];
			closeIconStatus = 0;
		}
		else
		{
		//	[[ident.item tabView] selectTabViewItem:ident.item];
		}
	}
	
	if (dragging && !stopDragging)
	{
		[ident.tabBar.document ignoreTabCleanupsAndRefereshes:YES];
		[ident.tabBar resetOrdering];
		[ident.tabBar.document ignoreTabCleanupsAndRefereshes:NO];
	}
	
	stopDragging = NO;
	dragging = NO;
	
	if (willHandleBringFront)
	{
		willHandleBringFront = NO;
		[[ident tabBar] bringViewToFront:self];
	}
	
	[self setNeedsDisplay];
}

- (void)previewWindowHoverTimerFire
{
	if (backgroundStatus == 0)
		return;
	if ([TBPreviewController sharedController].isOpen)
		return;
	
	[[TBPreviewController sharedController] showOnWindow:[ident.tabBar window] tabItem:ident.item];
}


- (void)sublayer_mouseMoved:(NSEvent *)e
{
	for (id item in [[self superlayer] sublayers])
	{
		if (item != self)
			[item sublayer_mouseExited:e];
	}
	
	backgroundStatus = -1;
	
	if (closeIconStatus != 1)
	{
		NSPoint p = [e locationInWindow];
		if (NSPointInRect(p, NSMakeRect(3, 0, 20, self.frame.size.height)))
			closeIconStatus = -1;
		else 
			closeIconStatus = 0;
	}
	
	if (([TBPreviewController sharedController].isOpen
		    || [NSDate timeIntervalSinceReferenceDate] - [TBPreviewController sharedController].timeIntervalSinceClose < 1.0)
		&& [TBPreviewController sharedController].subject != ident.item && !dragging)
	{
		//[[TBPreviewController sharedController] showOnWindow:[ident.tabBar window] tabItem:ident.item];
	}
	else
	{
		
		//[self performSelector:@selector(previewWindowHoverTimerFire) withObject:nil afterDelay:0.5];
	}
	
	[self setNeedsDisplay];
}
- (void)sublayer_mouseExited:(NSEvent *)e
{
	int oldBackgroundStatus = backgroundStatus;
	backgroundStatus = 0;
	
	if (closeIconStatus == -1)
		closeIconStatus = 0;
	
	if (oldBackgroundStatus != 0)
		[self setNeedsDisplay];
	
	//[[TBPreviewController sharedController] hideIfItem:ident.item];
}


- (BOOL)willHandleBringFront
{
	return willHandleBringFront;
}


@end
