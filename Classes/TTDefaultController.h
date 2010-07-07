//
//  TTDefaultController.h
//  toptabs
//
//  Created by Alex Gordon on 10/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTController.h"

@interface TTDefaultController : NSObject<TTController> {
	NSWindowController *windowController;
	
	NSView *contentView;
	NSView *splitView; //Subview of 'view'
	
	NSTabViewItem *item;
	
	NSMutableArray *splitControllers; //Array of CHSplitControllers
	id lastActiveSplit;
	
	BOOL isDirty;
	
	// TBTabItemIdentifier //
	TBTabItemLayer *view;
	TTBar *tabBar;
	NSImage *icon;
	NSDictionary *dict;
	NSString *type;
	
	NSMutableArray *saveChain;
	
	//Navigation
	id navigationController;
	BOOL isNavigatorHidden;
}

@end
