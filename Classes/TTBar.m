//
//  TTBar.m
//  TabBar3
//
//  Created by Alex Gordon on 20/08/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import "TTBar.h"

#import "TTController.h"
#import "TTDefaultController.h"
#import "TBTabItemLayer.h"
#import "TTBarLayout.h"
#import "TBPreviewController.h"
#import "TBBlankInfoView.h"

//This function compares the views of two identifiers by midpoint.x  
NSInteger TBSortTabItem(NSTabViewItem *item1, NSTabViewItem *item2, void *context)
{
	NSObject<TTController> *item1Ident = [item1 identifier];
	NSObject<TTController> *item2Ident = [item2 identifier];
	
	CGRect f1 = item1Ident.view.frame;
	CGRect f2 = item2Ident.view.frame;
	
	if (f1.origin.x + f1.size.width/2.0 < f2.origin.x + f2.size.width/2.0)
		return NSOrderedAscending;
	else if (f1.origin.x + f1.size.width/2.0 > f2.origin.x + f2.size.width/2.0)
		return NSOrderedDescending;
	else return NSOrderedSame;
}


@implementation TTBar

@synthesize tabView;
@synthesize document;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		resettingOrdering = NO;
		selectingView = nil;
	}
    return self;
}

- (void)viewDidMoveToWindow
{
	NSTrackingArea *ta = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingInVisibleRect | NSTrackingActiveAlways) owner:self userInfo:nil];
	[self addTrackingArea:ta];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becameMain:) name:NSWindowDidBecomeMainNotification object:[self window]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignMain:) name:NSWindowDidResignMainNotification object:[self window]];
}

- (void)mouseMoved:(NSEvent *)e
{
	NSPoint p = [self convertPoint:[e locationInWindow] fromView:nil];
	lastHover = [self sendEventToSublayers:e selector:@selector(sublayer_mouseMoved:) view:nil];
	
	if ([self layerAtPoint:p])
	{
		if ([TBPreviewController sharedController].isOpen)
			[[TBPreviewController sharedController] showOnWindow:[self window] tabItem:lastHover.ident.item];
		else
			[self performSelector:@selector(previewWindowHoverTimerFire) withObject:nil afterDelay:0.75];
	}
	else
	{
		[[TBPreviewController sharedController] hide];
	}
}
- (void)mouseExited:(NSEvent *)e
{
	for (id item in [[self layer] sublayers])
	{
		if (item != self)
			[item sublayer_mouseExited:nil];
	}
	
	lastHover = nil;
	
	TBPreviewController *previewController = [TBPreviewController sharedController];
	if (!previewController.subject || [previewController.subject tabView] == tabView)
		[[TBPreviewController sharedController] hide];
}
- (void)previewWindowHoverTimerFire
{
	if (!lastHover)
		return;
	if ([TBPreviewController sharedController].isOpen)
		return;
	
	[[TBPreviewController sharedController] showOnWindow:[self window] tabItem:lastHover.ident.item];
}
/*- (void)mouseExited:(NSEvent *)e
{
	[self sendEventToSublayers:e selector:@selector(sublayer_mouseExited:) view:nil];
}*/

- (void)becameMain:(NSNotification *)notif
{
	[CATransaction flush];
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	
	[[[self layer] sublayers] makeObjectsPerformSelector:@selector(setNeedsDisplay)]; 
	
	[self setNeedsDisplay:YES];

	[CATransaction commit];
}
- (void)resignMain:(NSNotification *)notif
{
	[CATransaction flush];
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	[[[self layer] sublayers] makeObjectsPerformSelector:@selector(setNeedsDisplay)]; 
	
	[self setNeedsDisplay:YES];
	[CATransaction commit];
}

- (void)awakeFromNib
{
	[tabView setDelegate:self];
	[self resetItems];
	
	if (overflowButton)
	{
		[overflowButton setImage:[NSImage imageNamed:@"TBChevrons_Image"]];
		[self refreshOverflowMenuItems];
	}
	
	[[self layer] setLayoutManager:self];
}

- (void)setLayer:(CALayer *)layer
{
	[super setLayer:layer];
	[self resetOrdering];
}

#pragma mark Draw Rect

- (BOOL)isFlipped
{
	return YES;
}

- (void)drawRect:(NSRect)rect
{
	//[[self class] drawBackgroundInRect:[self bounds] flipped:NO light:![[self window] isMainWindow] hover:NO];
	
	rect = [self bounds];
	
	//rect.origin.y = rect.size.height - 6;
//	rect.size.height = 6;
	[[NSImage imageNamed:@"tab_background"] drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	
	/*
	NSColor *sideLineColor = [NSColor colorWithCalibratedWhite:0.525 alpha:1.0];
	NSRect sideRect = NSMakeRect(0, 1, 1, rect.size.height - 1);
	[sideLineColor set];
	NSRectFillUsingOperation(sideRect, NSCompositeSourceOver);
	
	if ([overflowButton numberOfItems] > 1)
	{
		sideRect = NSMakeRect(rect.size.width - 1, 1, 1, rect.size.height - 1);
		NSRectFillUsingOperation(sideRect, NSCompositeSourceOver);
	}*/
	
	if ([[self layer] layoutManager] != self)
		[[self layer] setLayoutManager:self];
}

+ (void)drawBackgroundInRect:(NSRect)rect flipped:(BOOL)flipped
{
	[self drawBackgroundInRect:rect flipped:flipped light:NO hover:NO];
}
+ (void)drawBackgroundInRect:(NSRect)rect flipped:(BOOL)flipped light:(BOOL)light
{
	[self drawBackgroundInRect:rect flipped:flipped light:NO hover:NO];
}
+ (void)drawBackgroundInRect:(NSRect)rect flipped:(BOOL)flipped light:(BOOL)light hover:(BOOL)hover
{
	NSColor *topLineColor = [NSColor colorWithCalibratedWhite:(!light ? 0.251 : 0.529) alpha:1.0];
	
	NSColor *topGradientColor = [NSColor colorWithCalibratedWhite:0.906 alpha:1.0];
	NSColor *bottomGradientColor = [NSColor colorWithCalibratedWhite:0.824 alpha:1.0];
	
	//NSColor *bottomLineHighlight = [NSColor colorWithCalibratedWhite:0.875 alpha:1.0];
	NSColor *bottomLineHighlight = [NSColor colorWithCalibratedWhite:0.93 alpha:1.0];

	NSColor *bottomLineColor = [NSColor colorWithCalibratedWhite:0.525 alpha:1.0];
	
	
	if (hover)
	{
		topGradientColor = [NSColor colorWithCalibratedWhite:0.831 alpha:1.0];
		bottomGradientColor = [NSColor colorWithCalibratedWhite:0.753 alpha:1.0];
	}
	
	NSRect lineRect = (flipped ? NSMakeRect(0, rect.size.height - 1, rect.size.width, 1) : NSMakeRect(0, 0, rect.size.width, 1));
	
	lineRect.size.height = rect.size.height;
	lineRect.origin.y = 0;
	NSGradient *grad = [[NSGradient alloc] initWithStartingColor:topGradientColor endingColor:bottomGradientColor];
	[grad drawInRect:lineRect angle:(flipped ? 270 : 90)];
	
	
	lineRect.origin.y = (flipped ? rect.size.height - 1 : 0);
	lineRect.size.height = 1;
	[topLineColor set];
	NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
	
//	lineRect.origin.y = (flipped ? 1 : rect.size.height - 2);
	lineRect.origin.y = (flipped ? rect.size.height - 2 : 1);
	//[bottomLineHighlight set];
	//NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
	
	lineRect.origin.y = (flipped ? 0 : rect.size.height - 1);
	[bottomLineColor set];
	NSRectFillUsingOperation(lineRect, NSCompositeSourceOver);
}

- (void)refreshOverflowMenuItems
{
	[overflowButton removeAllItems];
	[overflowButton addItemWithTitle:@"Overflow"];
	[overflowButton setFont:[NSFont systemFontOfSize:12]];
	
	NSArray *items = [[tabView tabViewItems] copy];
	BOOL didAddSeparator = NO;
	for (NSTabViewItem *item in items)
	{
		NSObject<TTController> *d = [item identifier];
		TBTabItemLayer *view = d.view;
		
		if (view.position.x >= [self frame].size.width)
		{
			if (!didAddSeparator)
			{
				didAddSeparator = YES;
			}
		}
		else
			continue;
		
		if ([item label] == nil)
			continue;
		
		NSMenuItem *mitem = [[NSMenuItem alloc] initWithTitle:[item label] action:nil keyEquivalent:@""];
		[mitem setImage:[d icon]];
		[mitem setRepresentedObject:d];
		[mitem setTarget:self];
		[mitem setAction:@selector(overflow:)];
		
		if (item == [tabView selectedTabViewItem])
		{
			[mitem setAttributedTitle:[[NSAttributedString alloc] initWithString:[item label] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:12], NSFontAttributeName, nil]]];
			[mitem setState:NSOnState];
		}
		[[overflowButton menu] addItem:mitem];
	}
	
	[self setNeedsDisplay:YES];
}
- (void)overflow:(NSMenuItem *)sender
{
	[tabView selectTabViewItem:((NSObject<TTController> *)[sender representedObject]).item];
}

- (void)beginIgnoringAnimations
{
	[CATransaction flush];
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
}
- (void)endIgnoringAnimations
{
	[CATransaction commit];
}


- (IBAction)addButton:(id)sender
{
	//FIXME: Glue addButton: in to the controller
	//[[CHApplicationController sharedController] newUntitledDocumentTab:nil];
		
	//[[self layer] setLayoutManager:self]; 
	NSObject<TTController> *ident = [self createItemAndView];
	NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:ident];
	[item setView:[[TBBlankInfoView alloc] initWithFrame:NSMakeRect(0, 0, 10, 10)]];
	[item setLabel:[NSString stringWithFormat:@"Hello World!", lastCounter + 1]];
	
	lastCounter++;
	
	ident.item = item;
	
	[[self layer] addSublayer:ident.view];
	
	[tabView addTabViewItem:item];
	[tabView selectTabViewItem:item];
	[self layoutSublayersOfLayer:nil];
	
	[[self layer] setNeedsDisplay];
	
	[self resetZOrdering];
	//[self resetItems];
}

- (NSObject<TTController> *)createItemAndView
{
	NSObject<TTController> *ident = [[TTDefaultController alloc] init];
	TBTabItemLayer *view = [[TBTabItemLayer alloc] init];
	view.needsDisplayOnBoundsChange = YES;
	view.frame = CGRectMake([self rightmostNonOverflowX], -[self bounds].size.height, 216, [self bounds].size.height);
	ident.view = view;
	view.ident = ident;
	ident.tabBar = self;
	
	ident.icon = nil;
	
	[view setNeedsDisplay];
	[[self layer] addSublayer:view];
	
	[self resetZOrdering];
	
	return ident;
}

- (void)createNewViewForIdentifier:(NSObject<TTController> *)ident
{
	TBTabItemLayer *view = [[TBTabItemLayer alloc] init];
	view.needsDisplayOnBoundsChange = YES;
	view.frame = CGRectMake([self rightmostNonOverflowX], -[self bounds].size.height, 216, [self bounds].size.height); //.frame =
	ident.view = view;
	view.ident = ident;
	
	[[self layer] addSublayer:ident.view];
}
- (float)rightmostNonOverflowX
{
	CGFloat previousX = 0.0;
	CGFloat previousWidth = 0.0;
	
	for (NSTabViewItem *item in [tabView tabViewItems])
	{
		TBTabItemLayer *view = [[item identifier] view];
		CGFloat thisX = view.position.x;
		CGFloat thisWidth = view.frame.size.width;
		
		if (thisX + thisWidth > self.frame.size.width)
			return previousX;
		
		if (thisX > previousX)
		{
			previousX = thisX;
			previousWidth = thisWidth;
		}
	}
	
	return previousX + previousWidth;
}

#pragma mark Event Sending

- (void)mouseDown:(NSEvent *)e
{
	CALayer *sub = [[[self layer] sublayers] lastObject];
	
	[self sendEventToSublayers:e selector:@selector(sublayer_mouseDown:) view:nil];
	
	lastHover = nil;
	
	TBPreviewController *previewController = [TBPreviewController sharedController];
	if (!previewController.subject || [previewController.subject tabView] == tabView)
		[[TBPreviewController sharedController] hide];
}
- (void)mouseDragged:(NSEvent *)e
{
	[self sendEventToSublayers:e selector:@selector(sublayer_mouseDragged:) view:selectingView];
}
- (void)mouseUp:(NSEvent *)e
{
	[self sendEventToSublayers:e selector:@selector(sublayer_mouseUp:) view:selectingView];
	selectingView = nil;
}
- (NSMenu *)menuForEvent:(NSEvent *)e
{
	NSPoint p = [self convertPoint:[e locationInWindow] fromView:nil];
	TBTabItemLayer *view = [self layerAtPoint:p];
	
	if (!view)
		return nil;
	
	return [view.ident menuForEvent:e];
}

- (TBTabItemLayer *)layerAtPoint:(NSPoint)p
{
	NSArray *sublayers = [[self layer] sublayers];
	for (TBTabItemLayer *v in [sublayers reverseObjectEnumerator])
	{
		if ([v containsPoint:[v convertPoint:p fromLayer:[self layer]]])//NSPointInRect(p, NSRectFromCGRect(v.frame)))
		{
			return v;
		}
	}
	
	return nil;
}

- (TBTabItemLayer *)sendEventToSublayers:(NSEvent *)e selector:(SEL)selector view:(TBTabItemLayer *)view
{
	NSPoint p = [self convertPoint:[e locationInWindow] fromView:nil];
	
	if (view == nil)
	{
		selectingView = view = [self layerAtPoint:p];
	}
	
	if (view)
	{
		NSPoint location = p;//[v convertPoint:p fromView:self];
		location.y = 0;
		
		location.x -= [view frame].origin.x;
		NSEvent *newevent = nil;
		
		if ([e type] == NSMouseEntered || [e type] == NSMouseExited)
			newevent = [NSEvent enterExitEventWithType:[e type] location:location modifierFlags:[e modifierFlags] timestamp:[e timestamp] windowNumber:[e windowNumber] context:[e context] eventNumber:[e eventNumber] trackingNumber:[e trackingNumber] userData:[e userData]];
		else
			newevent = [NSEvent mouseEventWithType:[e type] location:location modifierFlags:[e modifierFlags]
											  timestamp:[e timestamp] windowNumber:[e windowNumber] context:[e context]
											eventNumber:[e eventNumber] clickCount:[e clickCount] pressure:[e pressure]];
		[view performSelector:selector withObject:newevent];
	}
	return view;
}


#pragma mark Tab View

- (void)displayEverything
{
	[self setNeedsDisplay:YES];
	[[self layer] setNeedsDisplay];
	for (CALayer *l in [[self layer] sublayers]) {
		[l setNeedsDisplay];
	}
}

const float betweenTabBuffer = -19;

- (void)draggingTab:(NSObject<TTController> *)ident
{
	[document ignoreTabCleanupsAndRefereshes:YES];

	NSArray *items = [tabView tabViewItems];

	float itemWidth = [ident.view frame].size.width;
	int index = [items indexOfObject:ident.item];
	
	NSMutableArray *widths = [NSMutableArray arrayWithCapacity:[items count]];
	for (NSTabViewItem *item in items)
	{
		NSObject<TTController> *d = [item identifier];
		TBTabItemLayer *view = d.view;
		[widths addObject:[NSNumber numberWithFloat:[view frame].size.width]];
	}
	
	float runningX = 0.0;
		
	[CATransaction flush];
	[CATransaction begin];	
	[CATransaction setValue:[NSNumber numberWithFloat:0.3] forKey:@"animationDuration"];	
	
	int i;
	for (i = 0; i < [widths count]; i++)
	{
		NSNumber *nw = [widths objectAtIndex:i];
		float w = [nw floatValue];
		
		NSTabViewItem *item = [items objectAtIndex:i];
		NSObject<TTController> *d = [item identifier];
		
		if (d != ident)
		{
			if (runningX < [ident.view frame].origin.x - [ident.view frame].size.width / 2.0)
			{
				if ([d.view goingToX] != runningX)
				{
					[d.view setGoingToX:runningX];
					CGRect r = CGRectMake(runningX, 0, [d.view frame].size.width, [d.view frame].size.height);
					if (r.origin.x + r.size.width > [self frame].size.width)
					{
						r.origin.x = [self frame].size.width;
						runningX = r.origin.x + r.size.width - 1;
					}
					else
						runningX += w - 1 + betweenTabBuffer;
					
					d.view.frame = r;
				}
				else
					runningX += w - 1 + betweenTabBuffer;
			}
			else if (runningX >= [ident.view frame].origin.x - [ident.view frame].size.width / 2.0)
			{	
				if ([d.view goingToX] != runningX + itemWidth - 1 + betweenTabBuffer)
				{
					[d.view setGoingToX:runningX + itemWidth - 1 + betweenTabBuffer];
					CGRect r = CGRectMake(runningX + itemWidth - 1 + betweenTabBuffer, 0, [d.view frame].size.width, [d.view frame].size.height);
					if (r.origin.x + r.size.width > [self frame].size.width)
					{
						r.origin.x = [self frame].size.width;
						runningX = r.origin.x + r.size.width - 1 + betweenTabBuffer;
					}
					else
						runningX += w - 1 + betweenTabBuffer;
					
					d.view.frame = r;
				}
				else
					runningX += w - 1 + betweenTabBuffer;
				
				
			}
		}
	}
	
	[CATransaction commit];
	
	[self setNeedsDisplay:YES];
	
	[document ignoreTabCleanupsAndRefereshes:NO];
	
	[self resetZOrdering];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
	NSArray *items = [tabView tabViewItems];
	NSArray *sorted = [items sortedArrayUsingFunction:TBSortTabItem context:nil];
	
	[CATransaction flush];
	[CATransaction begin];	
	//[CATransaction setDisableActions:YES];
	[CATransaction setValue:[NSNumber numberWithFloat:0.15] forKey:@"animationDuration"];	
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:@"linear"]];
	
	float runningX = 0.0;
	BOOL firstSet = YES;
	for (TBTabItemLayer *item in sorted)
	{
		TBTabItemLayer *view = [[item identifier] view];
		if ([view isKindOfClass:[TBTabItemLayer class]])
		{
			CGPoint pos = CGPointMake(runningX, 0);
			
			const float bufferSpaceWidth = 15.0;
			
			if (pos.x + view.frame.size.width + bufferSpaceWidth > [self frame].size.width)
			{
				if (firstSet)
					pos.x = [self frame].size.width + bufferSpaceWidth;
				
				if (firstSet)
					runningX = [self frame].size.width + bufferSpaceWidth + view.frame.size.width - 1 + betweenTabBuffer;
				else
					runningX += [view frame].size.width + bufferSpaceWidth - 1 + betweenTabBuffer;
				
				firstSet = NO;
			}
			else
			{
				runningX += [view frame].size.width - 1 + betweenTabBuffer;
			}
			
			if ([view goingToX] != pos.x)
			{
				view.position = pos;
				[view setGoingToX:pos.x];
			}
		}
	}
	
	[CATransaction commit];	

	
	/*
	float runningX = 0.0;
	for (TBTabItemLayer *item in sorted)
	{
		TBTabItemLayer *view = [[item identifier] view];
		if ([view isKindOfClass:[TBTabItemLayer class]])
		{
			CGPoint pos = CGPointMake(runningX, 0);
			
			if (pos.x + view.frame.size.width > [self frame].size.width)
			{
				
				pos.x = [self frame].size.width;
				runningX = pos.x + view.frame.size.width - 1;
			}
			else
				runningX += [view frame].size.width - 1;
			
			if ([view goingToX] != pos.x)
			{
				view.position = pos;
				[view setGoingToX:pos.x];
			}
		}
	}
	 
	 */
	
//	[CATransaction commit];
	
	[self refreshOverflowMenuItems];
	//[self resetZOrdering];
}


- (void)resetZOrdering
{
	NSArray *items = [tabView tabViewItems];
	for (NSTabViewItem *item in [items reverseObjectEnumerator])
	{
		[self bringViewToFront:[[item identifier] view]];
	}
	
	[self bringViewToFront:[[[tabView selectedTabViewItem] identifier] view]];
}
- (void)resetItems
{
	NSMutableArray *removemes = [NSMutableArray array];
	
	[CATransaction flush];
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.3] forKey:kCATransactionAnimationDuration];
	
	NSArray *sublayers = [[[self layer] sublayers] copy];
	for (TBTabItemLayer *view in sublayers)
	{
		if ([view isKindOfClass:[TBTabItemLayer class]] && [view ident] && [[view ident] conformsToProtocol:@protocol(TTController)])
		{
			//Remove from our view if no longer necessary
			NSObject<TTController> *ident = [view ident];
			NSInteger result = [tabView indexOfTabViewItemWithIdentifier:ident];
			if (result == NSNotFound || result == -1)
			{
				CGRect oldFrame = view.frame;
				//oldFrame.size.width = 0.0;
				oldFrame.origin.y = -oldFrame.size.height;
				view.frame = oldFrame;
				[removemes addObject:view];
				//[view removeFromSuperlayer]; //FADE
			}
		}
	}
	
	[CATransaction commit];
	
	for (TBTabItemLayer *view in removemes)
	{
		[view removeFromSuperlayer];
	}
	
	[CATransaction flush];
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	NSArray *items = [tabView tabViewItems];
	for (NSTabViewItem *item in items)
	{
		NSObject<TTController> *ident = [item identifier];
		if (!ident || [ident conformsToProtocol:@protocol(TTController)] == NO)
		{
			//Add a new tab item/tab view
			ident = [self createItemAndView];
			
			ident.item = item;
			[item setIdentifier:ident];
		}
		
		[[self layer] addSublayer:ident.view];
	}
	
	[CATransaction commit];
	
	
	float runningX = 0.0;
	BOOL firstSet = YES;
	for (TBTabItemLayer *view in [[self layer] sublayers])
	{
		if ([view isKindOfClass:[TBTabItemLayer class]])
		{
			CGPoint pos = CGPointMake(runningX, 0);

			if (pos.x + view.frame.size.width > [self frame].size.width)
			{				
				if (firstSet)
					pos.x = [self frame].size.width;
				
				if (firstSet)
					runningX = [self frame].size.width + view.frame.size.width - 1 + betweenTabBuffer;
				else
					runningX += [view frame].size.width - 1 + betweenTabBuffer;
				
				firstSet = NO;
				
				//runningX = pos.x + view.frame.size.width - 1;
			}
			else
				runningX += [view frame].size.width - 1 + betweenTabBuffer;
			
			view.position = pos;
		}
	}
	
	[self resetZOrdering];
	//[self bringViewToFront:[[[tabView selectedTabViewItem] identifier] view]];
}

//This method orders the tabs by frame.origin.x
- (void)resetOrdering
{
	NSArray *items = [tabView tabViewItems];
	NSArray *sorted = [items sortedArrayUsingFunction:TBSortTabItem context:nil];
	resettingOrdering = YES;
	
	NSTabViewItem *sel = [tabView selectedTabViewItem];
	
	ignoreTabEvents = YES;
	
	int i;
	for (i = 0; i < [items count]; i++)
	{
		[tabView removeTabViewItem:[items objectAtIndex:i]];
	}
	
	for (i = 0; i < [sorted count]; i++)
	{
		[tabView addTabViewItem:[sorted objectAtIndex:i]];
	}
	
	ignoreTabEvents = NO;
	
	if (sel)
		[tabView selectTabViewItem:sel];
	
	[self resetItems];
	
	resettingOrdering = NO;
}

- (void)bringViewToFront:(TBTabItemLayer *)v
{
	//[CATransaction flush];
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	
	//FADE
	[v removeFromSuperlayer];
	[[self layer] addSublayer:v];
	//[[self layer] insertSublayer:v atIndex:[[[self layer] sublayers] count]];
	
	[CATransaction commit];
}

- (void)tabView:(NSTabView *)tv didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	if (ignoreTabEvents)
		return;
	
	[CATransaction flush];
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
		
	TBTabItemLayer *v = ((NSObject<TTController> *)[tabViewItem identifier]).view;
	if (v)
		[self bringViewToFront:v];
	
	for (CALayer *l in [[self layer] sublayers]) {
		[l setNeedsDisplay];
	}
	
	[self resetZOrdering];
	
	[CATransaction commit];
	
	if ([document respondsToSelector:@selector(tabView:didSelectTabViewItem:)])
		[document tabView:tv didSelectTabViewItem:tabViewItem];
}
- (BOOL)tabView:(NSTabView *)tv shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	if (ignoreTabEvents)
		return YES;
	
	[self setNeedsDisplay:YES];
	
	if ([document respondsToSelector:@selector(tabView:shouldSelectTabViewItem:)])
		[document tabView:tv shouldSelectTabViewItem:tabViewItem];
	
	return YES;
}
- (void)tabView:(NSTabView *)tv willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	if (ignoreTabEvents)
		return;
	
	if ([document respondsToSelector:@selector(tabView:willSelectTabViewItem:)])
		[document tabView:tv willSelectTabViewItem:tabViewItem];
}
- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
	if (ignoreTabEvents)
		return;
		
	[self resetZOrdering];
	
	if ([document respondsToSelector:@selector(tabView:didCloseTabViewItem:)])
		[document tabView:aTabView didCloseTabViewItem:tabViewItem];
}
- (void)tabView:(NSTabView *)aTabView willCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
	if (ignoreTabEvents)
		return;
	
	if ([document respondsToSelector:@selector(tabView:willCloseTabViewItem:)])
		[document tabView:aTabView willCloseTabViewItem:tabViewItem];
}
- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView *)tv
{
	if (ignoreTabEvents)
		return;
	
	if (!resettingOrdering)
		[self resetItems];
}

- (void)performDelegateSelector:(SEL)sel withObject:(id)obj
{
	if ([document respondsToSelector:sel])
		[document performSelector:sel withObject:tabView withObject:obj];
}

@end
