//
//  TBPreviewController.h
//  TabBar3
//
//  Created by Alex Gordon on 26/12/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TBPreviewWindow, TBTabContentsPreviewView;

@interface TBPreviewController : NSObject
{
	NSWindow *hostWindow;
	NSTabViewItem *subject;
	
	TBPreviewWindow *previewWindow;
	TBTabContentsPreviewView *previewView;
	
	NSTimeInterval timeIntervalSinceClose;
	BOOL isOpen;
	
	BOOL alreadyRefreshing;
}

@property (assign) NSTabViewItem *subject;
@property (assign) BOOL isOpen;
@property (assign) NSTimeInterval timeIntervalSinceClose;

+ (TBPreviewController*)sharedController;

@end
