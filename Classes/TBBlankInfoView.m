//
//  TBBlankInfoView.m
//  BlankTab
//
//  Created by Alex Gordon on 03/02/2009.
//  Copyright 2009 Fileability. All rights reserved.
//

#import "TBBlankInfoView.h"

@implementation TBBlankInfoView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        delegate = nil;
    }
    return self;
}

- (float)offsetHeight
{
	//return [self frame].size.height;
	delegate = [[self window] document];
	if (!delegate)
		return 284;
	if (![delegate respondsToSelector:@selector(yValueForBlankInfoView)])
		return 284;
	
	float y = 200;//[delegate yValueForBlankInfoView];
	return (y <= [self frame].size.height ? y : [self frame].size.height);
}

- (void)drawRect:(NSRect)rect
{
    rect = [self bounds];
	
	float offset = [self offsetHeight];
	
	[[NSColor colorWithCalibratedRed:0.91 green:0.91 blue:0.91 alpha:1.00] set];
	NSRectFill(rect);
	
	NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:14], NSFontAttributeName, [NSColor colorWithCalibratedRed:0.21 green:0.21 blue:0.21 alpha:1.00], NSForegroundColorAttributeName, nil];
	NSDictionary *boldAttributes = [normalAttributes mutableCopy];
	[boldAttributes setValue:[NSFont boldSystemFontOfSize:14] forKey:NSFontAttributeName];
	
	
	NSMutableAttributedString *sourceListText = [[NSMutableAttributedString alloc] initWithString:@"Double click on one of these items to open it in a tab" attributes:normalAttributes];
	[sourceListText setAttributes:boldAttributes range:[[sourceListText string] rangeOfString:@"Double click"]]; 
	[sourceListText setAttributes:boldAttributes range:[[sourceListText string] rangeOfString:@"tab"]]; 
	
	NSMutableAttributedString *searchText = [[NSMutableAttributedString alloc] initWithString:@"Type in here to search" attributes:normalAttributes];
	[sourceListText setAttributes:boldAttributes range:[[sourceListText string] rangeOfString:@"search"]]; 
	
	
	//Draw curly bracket
	NSImage *curlyInfoBracket = [NSImage imageNamed:@"TBCurlyInfoBracket"];
	[curlyInfoBracket setCacheMode:NSImageCacheNever];
	NSRect sourceRect = NSMakeRect(0, 0, [curlyInfoBracket size].width, [curlyInfoBracket size].height);
	NSRect destRect = NSMakeRect(20, 20, 0, offset - 39);
	
	destRect.size.width = sourceRect.size.width * (destRect.size.height/sourceRect.size.height);
	[curlyInfoBracket drawInRect:destRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.0];
	float curlyWidth = destRect.origin.x + destRect.size.width + 14;
	
	//Draw help text
	NSSize sourceListTextSize = [sourceListText size];
	[sourceListText drawAtPoint:NSMakePoint(curlyWidth, offset/2.0 - sourceListTextSize.height/2.0)];
}

- (BOOL)isFlipped
{
	return YES;
}

@end
