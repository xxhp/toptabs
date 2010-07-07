//
//  TBTabItemIdentifier.h
//  TabBar3
//
//  Created by Alex Gordon on 20/08/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TBTabItemLayer, TTBar;

@interface TBTabItemIdentifier : NSObject {
	NSTabViewItem *item;
	TBTabItemLayer *view;
	TTBar *tabBar;
	NSImage *icon;
	
	NSDictionary *dict;
	NSString *type;
}

@property (assign) NSTabViewItem *item;
@property (assign) TBTabItemLayer *view;
@property (assign) TTBar *tabBar;
@property (assign) NSImage *icon;

@property (assign) NSDictionary *dict;
@property (assign) NSString *type;

@property (readonly, getter=name) NSString *name;
@property (readonly, getter=itemview) NSView *itemview;

- (void)close;
- (void)createNewTab;
- (void)replaceCurrentTabWithItemAndMakeActive;
- (void)makeActive;

@end
