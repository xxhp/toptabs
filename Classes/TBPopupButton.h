//
//  TBPopupButton.h
//  TabBar3
//
//  Created by Alex Gordon on 24/12/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TBPopupButton : NSPopUpButton {
	int mouseState;
	NSImage *image;
	NSTrackingArea *ta;
	
	BOOL isBlank;
}

@property (assign) BOOL isBlank;

@end
