//
//  TBTabItemLayer.h
//  TabBar3
//
//  Created by Alex Gordon on 20/08/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <QuartzCore/QuartzCore.h>

@protocol TTController;
@class TTBar;

@interface TBTabItemLayer : CALayer {
	NSObject<TTController> *ident;
	
	NSTrackingArea *ta;
	
	float gtx;
	
	//There's probably a clever replacement for all these states
	BOOL stopDragging;
	BOOL dragging;
	BOOL willHandleBringFront;
	NSPoint draggingPoint;
	
	int backgroundStatus;
	int closeIconStatus; //0 = normal, -1 = hover, 1 = pressed
	
	BOOL inFilePathMenuMode;
}

- (void)setGoingToX:(float)f;
- (float)goingToX;	

- (NSRect)textRect;

@property (assign) NSObject<TTController> *ident;

@end
