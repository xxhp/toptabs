//
//  TTController.h
//  toptabs
//
//  Created by Alex Gordon on 10/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TTBar, TBTabItemLayer;

@protocol TTController

@property (assign) NSWindowController *windowController;
@property (readonly) id navigationController;

@property (readonly) NSMutableArray *splitControllers;
@property (readonly) NSView *contentView;

@property (getter=isVertical, setter=setVertical:) BOOL isVertical;
@property (readonly, getter=isAlone) BOOL isAlone;

@property (assign) BOOL isDirty;

@property (assign) NSTabViewItem *item;
@property (assign) TBTabItemLayer *view;
@property (assign) TTBar *tabBar;
@property (assign) NSImage *icon;

@property (assign) NSDictionary *dict;
@property (assign) NSString *type;

@property (readonly, getter=name) NSString *name;
@property (readonly, getter=itemview) NSView *itemview;

- (void)closeTab;
- (void)createNewTab;
- (void)replaceCurrentTabWithItemAndMakeActive;
- (void)makeActive;

@end
