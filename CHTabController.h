//
//  CHTabController.h
//  Chocolat
//
//  Created by Alex Gordon on 08/07/2009.
//  Copyright 2009 Fileability. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BWToolkitFramework/BWToolkitFramework.h>

@class CHWindowController;
@class CHSplitController;

@class TBTabItemLayer, TBView;

@class CHMutableStack;
@class CHNavigatorController;

//CHTabController _acts_ like a window controller but also controls a tab view item

NSRect CHRectQuotientAtIndex(NSRect masterRect, int divideInto, int index, BOOL horizontal);

@interface CHTabController : NSWindowController {
	CHWindowController *windowController;
	
	NSView *contentView;
	BWSplitView *splitView; //Subview of 'view'
	
	NSTabViewItem *item;
	
	NSMutableArray *splitControllers; //Array of CHSplitControllers
	CHSplitController *lastActiveSplit;
	
	BOOL isDirty;
	
	// TBTabItemIdentifier //
	TBTabItemLayer *view;
	TBView *tabBar;
	NSImage *icon;
	NSDictionary *dict;
	NSString *type;
	
	CHMutableStack *saveChain;
	
	//Navigation
	CHNavigatorController *navigationController;
	BOOL isNavigatorHidden;
}

@property (assign) CHWindowController *windowController;

@property (readonly) CHNavigatorController *navigationController;

@property (readonly) NSMutableArray *splitControllers;
@property (readonly) NSView *contentView;

@property (getter=isVertical, setter=setVertical:) BOOL isVertical;
@property (readonly, getter=isAlone) BOOL isAlone;

@property (assign) BOOL isDirty;


// TBTabItemIdentifier //
@property (assign) NSTabViewItem *item;
@property (assign) TBTabItemLayer *view;
@property (assign) TBView *tabBar;
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
