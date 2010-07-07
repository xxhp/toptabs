//
//  TBTabContentsPreviewView.m
//  TabBar3
//
//  Created by Alex Gordon on 24/12/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import "TBTabContentsPreviewView.h"


@implementation TBTabContentsPreviewView

@synthesize image;

- (id)initWithFrame:(NSRect)r
{
	self = [super initWithFrame:r];
	if (self != nil) {
		
	}
	return self;
}
- (void)setImage:(NSImage *)i
{
	image = i;
	//[imageView setImage:i];
}

- (void)drawRect:(NSRect)rect
{
	rect = [self bounds];
	
	NSRect bezierRect = NSMakeRect([self shadowWidth],
								   [self shadowWidth] + [self arrowSize].height,
								   rect.size.width - [self shadowWidth] * 2.0,
								   rect.size.height - [self shadowWidth] * 2.0 - [self arrowSize].height
								   /*[self contentSize].width + [self borderWidth],
								   [self contentSize].height + [self borderWidth]*/);
	NSBezierPath *bp = [NSBezierPath bezierPath];//bezierPathWithRoundedRect:bezierRect xRadius:6.0 yRadius:6.0];
	
	NSRect triangeRect = NSZeroRect;
	triangeRect.size = [self arrowSize];
	triangeRect.origin.x = bezierRect.origin.x + bezierRect.size.width/2.0 - triangeRect.size.width/2.0;//round(rect.size.width/2.0 - triangeRect.size.width/2.0);
	triangeRect.origin.y = bezierRect.origin.y - triangeRect.size.height;
	
	float radius = 6.0;
	float xoff = bezierRect.origin.x;
	float yoff = bezierRect.origin.y;
	NSPoint startpoint = NSMakePoint(xoff, yoff+radius);
	NSPoint center1 = NSMakePoint(xoff+radius, yoff+radius);
	NSPoint center2 = NSMakePoint(xoff+bezierRect.size.width-radius, yoff+radius);
	NSPoint center3 = NSMakePoint(xoff+bezierRect.size.width-radius, yoff+bezierRect.size.height-radius);
	NSPoint center4 = NSMakePoint(xoff+radius, yoff+bezierRect.size.height-radius);
	[bp moveToPoint:startpoint];
	
	
	[bp appendBezierPathWithArcWithCenter:center1 radius:radius startAngle:180.0 endAngle:270.0];
	
	//Draw the arrow
	NSPoint a, b, c;
	a = NSMakePoint(NSMinX(triangeRect), NSMaxY(triangeRect));
	c = NSMakePoint(NSMaxX(triangeRect), NSMaxY(triangeRect));
	b = NSMakePoint((NSMinX(triangeRect) + NSMaxX(triangeRect)) / 2, NSMinY(triangeRect));
	[bp lineToPoint:a];
	[bp lineToPoint:b];
	[bp lineToPoint:c];
	
	[bp appendBezierPathWithArcWithCenter:center2 radius:radius startAngle:270.0 endAngle:360.0];
	[bp appendBezierPathWithArcWithCenter:center3 radius:radius startAngle:360.0 endAngle:90.0];
	[bp appendBezierPathWithArcWithCenter:center4 radius:radius startAngle:90.0 endAngle:180.0];
	[bp closePath];
	
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0]];
	[shadow setShadowBlurRadius:9.0];
	[shadow setShadowOffset:NSMakeSize(0, -1)];
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[shadow set];
	//[[bp bezierPathByReversingPath] setClip];
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.94 green:0.94 blue:0.94 alpha:1.00] endingColor:[NSColor colorWithCalibratedRed:1.00 green:1.00 blue:1.00 alpha:1.00]];
	[gradient drawInBezierPath:bp angle:270];
	
	
	[[NSColor colorWithCalibratedRed:0.53 green:0.78 blue:1.00 alpha:1.00] set];
	[bp stroke];
	
	
	
	
	//[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.0]];
	//[shadow set];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	
	[gradient drawInBezierPath:bp angle:270];
	
	
	[[NSColor colorWithCalibratedRed:0.53 green:0.78 blue:1.00 alpha:1.00] set];
	[bp stroke];
	
	
	
	/*if (image)
	{
		[imageView setHidden:NO];
		[imageView setFrame:NSInsetRect(bezierRect, [self borderWidth], [self borderWidth])];
	}
	else
	{
		[imageView setHidden:YES];
	}*/
	
	 if (image)
	 {
		NSRect sourceRect = NSZeroRect;
		sourceRect.size = [image size];
		
		NSRect destRect = NSInsetRect(bezierRect, [self borderWidth], [self borderWidth]);
		//destRect.origin.y += sourceRect.size.height;
		
		//image = [NSImage imageNamed:@"NSComputer"];
		 [[NSGraphicsContext currentContext] saveGraphicsState];
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
			[image drawInRect:destRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.0];
			NSDrawNinePartImage(destRect, [NSImage imageNamed:@"TBPreviewBox_Top_Left"], [NSImage imageNamed:@"TBPreviewBox_Top"], [NSImage imageNamed:@"TBPreviewBox_Top_Right"], [NSImage imageNamed:@"TBPreviewBox_Left"], nil, [NSImage imageNamed:@"TBPreviewBox_Right"], [NSImage imageNamed:@"TBPreviewBox_Bottom_Left"], [NSImage imageNamed:@"TBPreviewBox_Bottom"], [NSImage imageNamed:@"TBPreviewBox_Bottom_Right"], NSCompositeSourceOver, 1.0, NO);
		[[NSGraphicsContext currentContext] restoreGraphicsState];
	 }
	
}

- (NSSize)contentSize
{
	return NSMakeSize(168, 98);//NSMakeSize(152.0, 89.0);
}
- (NSSize)fullSize
{
	NSSize contentSize = [self contentSize];
	contentSize.width += 2.0 * ([self borderWidth] + [self shadowWidth]);
	contentSize.height += 2.0 * ([self borderWidth] + [self shadowWidth]) + [self arrowSize].height;
	
	return contentSize;
}
- (NSSize)arrowSize
{
	return NSMakeSize(18.0, 9.0);
}

- (BOOL)isFlipped
{
	return YES;
}


- (float)borderWidth
{
	return 8.0;
}
- (float)shadowWidth
{
	return 9.0;
}

				  
				  
@end
