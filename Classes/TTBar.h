//
//  TTBar.h
//  TabBar3
//
//  Created by Alex Gordon on 20/08/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TTController;
@class TBButton, TBPopupButton;
@class TBTabItemLayer, TTBarLayout;


static __inline__ int TBRandomIntBetween(int a, int b)
{
    int range = b - a < 0 ? b - a - 1 : b - a + 1; 
    int value = (int)(range * ((float)random() / (float) LONG_MAX));
    return value == range ? a : a + value;
}


@interface TTBar : NSButton
{	
	IBOutlet NSTabView *tabView;
	IBOutlet TBButton *addButton;
	IBOutlet TBPopupButton *overflowButton;
	
	IBOutlet id document;
	
	NSView *selectingView;
	
	BOOL resettingOrdering;
	
	TBTabItemLayer *lastHover;
	
	int lastCounter;
	
	BOOL ignoreTabEvents;
}

@property (readonly) NSTabView *tabView;
@property (readonly) id document;

- (IBAction)addButton:(id)sender;

- (float)rightmostNonOverflowX;

+ (void)drawBackgroundInRect:(NSRect)rect;
- (void)resetItems;
- (TBTabItemLayer *)sendEventToSublayers:(NSEvent *)e selector:(SEL)selector view:(TBTabItemLayer *)view;

- (TBTabItemLayer *)layerAtPoint:(NSPoint)p;

- (void)draggingTab:(NSObject<TTController> *)ident;

@end
