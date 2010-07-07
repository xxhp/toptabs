//
//  CHTabController.m
//  Chocolat
//
//  Created by Alex Gordon on 08/07/2009.
//  Copyright 2009 Fileability. All rights reserved.
//

#import "CHTabController.h"

#import "CHWindowController.h"
#import "CHSplitController.h"

#import "TBTabItemLayer.h"
#import "TBView.h"
#import "TBPreviewController.h"
#import "TBBlankInfoView.h"

#import "CHDocumentController.h"

#import "CHMutableStack.h"

#import "CHNavigatorController.h"

NSRect CHRectQuotientAtIndex(NSRect masterRect, int divideInto, int index, BOOL horizontal)
{
	CGFloat fullLength = masterRect.size.height;
	if (!horizontal)
		masterRect.size.width;
	
	CGFloat floorSublength = floor(fullLength / (CGFloat)divideInto);
	CGFloat sublengthRemainder = fmod(fullLength, (CGFloat)divideInto);
	
	CGFloat approximateSublength = floorSublength;

	
	if (index < sublengthRemainder)
		approximateSublength += 1.0;
	
	NSRect splitRect = masterRect;
	if (horizontal)
	{
		splitRect.origin.y = floorSublength;
		if (index < sublengthRemainder)
			splitRect.origin.y += index;
		else
			splitRect.origin.y += sublengthRemainder;
	}
	else
	{
		splitRect.origin.x = floorSublength;
		if (index < sublengthRemainder)
			splitRect.origin.x += index;
		else
			splitRect.origin.x += sublengthRemainder;
	}
	
	return splitRect;
}

@implementation CHTabController


@synthesize navigationController;

@synthesize windowController;
@synthesize splitControllers;
@synthesize contentView;

@synthesize isDirty;

- (id)initWithWindow:(NSWindow *)window
{
	NSWindowController *oldWindowController = [window windowController];
	if (self = [super initWithWindow:window])
	{
		splitControllers = [[NSMutableArray alloc] init];
		
		//We don't want the window to change its window controller
		[window setWindowController:oldWindowController];
		
		contentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 500, 500)];
		
		float navigatorWidth = 200;
		
		splitView = [[NSSplitView alloc] initWithFrame:[contentView bounds]];
		[splitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[splitView setDividerStyle:NSSplitViewDividerStyleThin];

		
		isNavigatorHidden = NO;
		
		//Set up the nav controller
		navigationController = [[CHNavigatorController alloc] init];
		
		//Add the nav split
		[[navigationController view] setFrame:[contentView bounds]];
		[contentView addSubview:[navigationController view]];
		//[contentView performSelector:@selector(addSubview:) withObject:[navigationController view] afterDelay:2.0];
		
		//Add main split view into the nav split
		[splitView setFrame:[[navigationController leftView] bounds]];
		[[navigationController leftView] addSubview:splitView];
		
		
		
		/*
		NSRect contentSplitFrame = [contentView bounds];
		contentSplitFrame.size.width = contentSplitFrame.size.width - navigatorWidth;
		
		[contentView addSubview:splitView];
		[splitView setFrame:contentSplitFrame];

		navigationController = [[CHNavigatorController alloc] init];
		NSRect newNavigatorFrame = [contentView bounds];
		newNavigatorFrame.origin.x = newNavigatorFrame.size.width - navigatorWidth;
		newNavigatorFrame.size.width = navigatorWidth;
		
		[[navigationController view] setAutoresizingMask:NSViewMinXMargin | NSViewHeightSizable];
		[contentView addSubview:[navigationController view]];
		[[navigationController leftView] addSubview:splitView];
		[[navigationController view] setFrame:newNavigatorFrame];
		 */
		
		[self resizeNavigator:[[NSUserDefaults standardUserDefaults] boolForKey:@"CHNavigatorHidden"] animate:NO];
		
		
		
		[self performSelector:@selector(setUpNav) withObject:nil afterDelay:2.0];
	}
	
	return self;
}

/*
- (CHTabController *)createItemWithName:(NSString *)name ofType:(NSString *)type
{
	CHTabController *ident = [[CHTabController alloc] init];
	
	ident.dict = [document dictionaryForName:name type:type];
	
	return ident;
}
 */

- (void)setUpNav
{
	}

#pragma mark Window Controller Overrides

- (void)synchronizeWindowTitleWithDocumentName
{
	//Set the tab view item's title to that of the active split's
	NSString *title = [[self lastActiveSplit] title];
	if (title)
	{
		[item setLabel:title];
	}
	
	[self.windowController synchronizeWindowTitleWithDocumentName];
}

- (void)setSplitDirection:(BOOL)isHorizontal
{
	[splitView setDividerStyle:NSSplitViewDividerStyleThick];
	[splitView setVertical:!isHorizontal];
	
	[self equalizeSplitFrames];
}

+ (BOOL)directionForIsNormal:(BOOL)isNormal
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"split.horizontal"] == isNormal;
}
- (void)addSplitInDirection:(BOOL)isHorizontal
{
	//Maximum 5 splits
	if ([splitControllers count] >= 5)
	{
		[self setSplitDirection:isHorizontal];
		return;
	}
	
	[splitView setDividerStyle:NSSplitViewDividerStyleThin];
	[splitView setVertical:!isHorizontal];
	
	CHSplitController *sp = [self lastActiveSplit];
	if (!sp)
		return;
	
	CHSplitController *sp2 = [[CHSplitController alloc] initWithWindow:[self.windowController window]];
	sp2.tabController = self;
	[sp2 setDocument:[[sp view] document]];
	[[[[sp view] document] splitControllers] addObject:sp2];

	
	[self addSplit:sp2];
	
	[self equalizeSplitFrames];
	
}

- (void)newSplitView:(id)x
{
	[self addSplitInDirection:YES];
}

- (void)addSplit:(CHSplitController *)s
{
	//[[s.tabController splitControllers] removeObject:tabController];
	
	s.tabController = self;
	[splitControllers addObject:s];
	[splitView addSubview:s.view];
	
	[self equalizeSplitFrames];
}

- (void)removeSplit:(CHSplitController *)s
{
	[self removeSplit:s andCascade:YES];
}
- (void)removeSplit:(CHSplitController *)s andCascade:(BOOL)shouldCascade
{
	[splitControllers removeObject:s];
	[s.view removeFromSuperview];
	
	//If that was the last split - also close the tab
	if ([splitControllers count] == 0)
		[self forceCloseTab:shouldCascade];//[windowController removeTab:self];
	
	//Otherwise equalize the frames for the remaining splits
	else
		[self equalizeSplitFrames];
}

- (void)equalizeSplitFrames
{
	//Set split frames	
	
	int i;
	for (i = 0; i < [splitControllers count]; i++)
	{
		CHSplitController *sp = [splitControllers objectAtIndex:i];
		
		NSRect newFrame = CHRectQuotientAtIndex([splitView bounds], [splitControllers count], i, ![splitView isVertical]);
		[[sp view] setFrame:newFrame];
	}
	
	[splitView adjustSubviews];
}

#pragma mark Split View Stuff

- (void)activeDidChange
{
	[self.windowController activeDidChange];
	
	CHSplitController *sp = [self lastActiveSplit];
	if ([sp document] == nil)
		sp.informTabControllerOfNewDoc = YES;
	else
		[self activeDidChangeWithDoc:sp];
	
	[tabBar displayEverything];
}
- (void)activeDidChangeWithDoc:(CHSplitController *)sp
{
	isDirty = [[sp document] isDocumentEdited];
	
	[navigationController switchInNavDelegate:[sp document]];
	
	[tabBar displayEverything];
}
- (void)setNavToDoc:(id)doc
{
	[navigationController switchInNavDelegate:doc];
}

- (void)setDocumentEdited:(BOOL)dirtyFlag
{
	[super setDocumentEdited:dirtyFlag];
		
	[self refreshDirtyIndicator];
}


- (void)refreshDirtyIndicator
{
	CHSplitController *sp = [self lastActiveSplit];
	isDirty = [[sp document] isDocumentEdited];
	[tabBar displayEverything];
}

- (CHSplitController *)activeSplit
{
	for (CHSplitController *split in splitControllers)
	{
		if ([split isActive])
			return split;
	}
	
	return nil;
}
- (CHSplitController *)lastActiveSplit
{
	CHSplitController *activeSplit = [self activeSplit];
	if (activeSplit)
	{
		lastActiveSplit = activeSplit;
		return lastActiveSplit;
	}
	else if (!lastActiveSplit && [splitControllers count])
	{
		lastActiveSplit = [splitControllers objectAtIndex:0];
	}
	
	return lastActiveSplit;
}

- (BOOL)isVertical
{
	return [splitView isVertical];
}
- (void)setVertical:(BOOL)b
{
	[splitView setVertical:YES];
}

- (BOOL)isAlone
{
	if ([splitControllers count] == 0)
		return YES;
	else
		return NO;
}

#pragma mark Navigator

- (IBAction)toggleNavigator:(id)sender
{
	[self resizeNavigator:!isNavigatorHidden animate:YES];
	
	[[NSUserDefaults standardUserDefaults] setBool:isNavigatorHidden forKey:@"CHNavigatorHidden"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)resizeNavigator:(BOOL)hidden animate:(BOOL)animate
{
	isNavigatorHidden = hidden;
	if (animate)
	{
		[NSAnimationContext beginGrouping];
		[[NSAnimationContext currentContext] setDuration:0.15];
	}
	
	NSRect frame = [[navigationController view] frame];
	NSTableView *navTable = [navigationController outlineView];
	
	if (isNavigatorHidden)
	{
		frame.size.width = [contentView frame].size.width + [[navTable enclosingScrollView] frame].size.width + 1;
	}
	else
	{
		frame.size.width = [contentView frame].size.width;
	}
	
	[[navigationController view] setEnabled:!isNavigatorHidden];
	
	if (animate)
	{
		[[[navigationController view] animator] setFrame:frame];
		
		[NSAnimationContext endGrouping];
	}
	else
	{
		[[navigationController view] setFrame:frame];
	}
}

#pragma mark TBTabItemIdentifier

@synthesize item;
@synthesize view;
@synthesize tabBar;
@synthesize icon;

@synthesize dict;
@synthesize type;

- (NSString *)name
{
	return [item label];
}
- (NSView *)itemview
{
	return [[self item] view];
}

- (void)refreshTabBar
{
	[self.tabBar displayEverything];
}

- (BOOL)canClose
{
	BOOL lastOne = [[self.item tabView] numberOfTabViewItems] == 1;
	if (lastOne && [[self.item view] isKindOfClass:[TBBlankInfoView class]])
		return NO;
	else
		return YES;
}

#pragma mark Closing
- (BOOL)runsCloseMultipleModal
{
	return NO;
}
- (NSArray *)closeMultiplePromptDocuments:(CHSaveMultiplePromptController *)c
{
	NSMutableArray *docs = [[NSMutableArray alloc] init];
	for (CHSplitController *split in [self splitControllers])
	{
		NSDocument *splitDoc = [split document];
		if ([docs containsObject:splitDoc])
			continue;
		
		[docs addObject:splitDoc];
	}
	
	return docs;
}
- (void)saveMultipleUserSaveAndClose:(NSSet *)docsToSave allDocuments:(NSArray *)allDocs
{
	saveChain = [[CHMutableStack alloc] initWithArray:[docsToSave allObjects]];
	for (NSDocument *doc in [allDocs reverseObjectEnumerator])
	{
		if ([docsToSave containsObject:doc])
			[saveChain push:doc];
		else
		{
			[doc closeAllSplitInstancesInWindowController:self promptToSaveChanges:NO];
		}
	}
	
	[self saveChainDocument:nil didSave:YES contextInfo:NULL];
}
- (void)saveChainDocument:(NSDocument *)document didSave:(BOOL)didSaveSuccessfully contextInfo:(void *)contextInfo
{
	if (didSaveSuccessfully == NO)
	{
		[saveChain removeAllObjects];
		return;
	}
	
	[document closeAllSplitInstancesInWindowController:self promptToSaveChanges:NO];
	
	NSDocument *newDoc = [saveChain pop];
	if (!newDoc)
	{
		//End of the chain
		
		[self forceCloseTab];
		return;
	}
	
	for (CHSplitController *sp in [newDoc splitControllers])
	{
		if ([sp windowController] == self)
		{
			//Select a tab here
			//[tabView selectTabViewItem:[[sp tabController] item]];
		}
	
	}
	[newDoc saveDocumentWithDelegate:self didSaveSelector:@selector(saveChainDocument:didSave:contextInfo:) contextInfo:nil]; 
}
- (void)saveMultipleUserDiscardAndClose
{	
	[self forceCloseTab];
}

- (void)closeTab
{
	[self makeActive];
	
	CHSaveMultiplePromptController *c = [[CHSaveMultiplePromptController alloc] initWithHostWindow:[[self windowController] window] controller:self];
	
	
	return;
	//Put any logic that might cancel the close here
	//...
	NSArray *documents = [[NSMutableArray alloc] initWithCapacity:[splitControllers count]];
	for (CHSplitController *sp in splitControllers)
	{
		[documents addObject:[sp viewDocument]];
	}
						  
	[[CHDocumentController sharedDocumentController] attemptToCloseDocuments:documents delegate:nil didCloseAllSelector:nil contextInfo:nil];
	
	//No going back after this
	[self forceCloseTab];
}
- (void)forceCloseTab
{
	[self forceCloseTab:YES];
}
- (void)forceCloseTab:(BOOL)shouldCascade
{
	[windowController removeTab:self andCascade:shouldCascade];
	
	return;
	
	BOOL lastOne = [[self.item tabView] numberOfTabViewItems] == 1;
	if (lastOne && [[self.item view] isKindOfClass:[TBBlankInfoView class]])
		return;
	
	[[self.item tabView] removeTabViewItem:self.item];
	
	[windowController removeTab:self];
	
	[[TBPreviewController sharedController] hideIfItem:self.item];
	
	if (lastOne)
	{
		/*
		[tabBar.document documentDidSwitchFromView:[self itemview] toView:nil];
		[self.tabBar addButton:nil];
		[tabBar.document documentDidSwitchFromView:nil toView:[[tabBar.tabView selectedTabViewItem] view]];
		 */
	}
	else
		[self.tabBar displayEverything];
}
- (void)createNewTab
{
	
	[self.tabBar createNewViewForIdentifier:self];
	[self.tabBar beginIgnoringAnimations];
	[[self.tabBar tabView] addTabViewItem:self.item];
	[self.tabBar endIgnoringAnimations];
	
}
- (void)replaceCurrentTabWithItemAndMakeActive
{
	NSTabView *tv = self.tabBar.tabView;
	NSTabViewItem *selItem = [tv selectedTabViewItem];
	
	[self.tabBar createNewViewForIdentifier:self];
	//[[self.tabBar tabView] addTabViewItem:self.item];
	int index = [tv indexOfTabViewItem:selItem];
	[tv insertTabViewItem:self.item atIndex:index];
	[tv removeTabViewItem:selItem];
	[tv selectTabViewItem:self.item];
	
	[self.tabBar displayEverything];
}
- (void)makeActive
{
	NSTabView *tv = self.tabBar.tabView;
	NSTabViewItem *selItem = [tv selectedTabViewItem];
	
	[[self.tabBar tabView] selectTabViewItem:self.item];
	
	[self.tabBar displayEverything];
}

- (void)showFilePathMenu:(NSEvent *)event
{
	[[[self lastActiveSplit].view document] showFilePathMenu:self event:event];
}

#pragma mark Context Menu

- (NSMenu *)menuForEvent:(NSEvent *)event
{
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Actions"];
	
	NSMutableArray *parentGroup = [NSMutableArray array];

	NSMutableArray *group1 = [NSMutableArray array];
	NSMutableArray *group2 = [NSMutableArray array];
	NSMutableArray *group3 = [NSMutableArray array];
	NSMutableArray *group4 = [NSMutableArray array];

	//***** Close Tab *****
	//***** Close Other Tabs *****
	if ([tabBar.tabView numberOfTabViewItems] > 1)
	{
		//Only if there's more than one tab
		[group1 addObject:[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Close Tab", @"") action:@selector(closeTabAction:) keyEquivalent:@""]]; 
		[group1 addObject:[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Close Other Tabs", @"") action:@selector(closeOtherTabsAction:) keyEquivalent:@""]]; 
	}
	
	//***** Duplicate Tab *****	
	[group2 addObject:[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Duplicate Tab", @"") action:@selector(duplicateTabAction:) keyEquivalent:@""]];
	
	//***** Move Tab to New Window *****	
	if ([tabBar.tabView numberOfTabViewItems] > 1)
	{
		[group2 addObject:[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Move Tab to New Window", @"") action:@selector(moveTabToNewWindowAction:) keyEquivalent:@""]]; 
	}
	
	//***** Move Split Views to Tabs *****	
	if ([splitControllers count] > 1)
	{
		[group3 addObject:[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Move Split Views to Tabs", @"") action:@selector(moveSplitViewsToTabs:) keyEquivalent:@""]]; 
	}
	
	//***** Consolidate Split Views *****
	NSUInteger documentCount = 0;
	NSMutableArray *documents = [NSMutableArray arrayWithCapacity:[splitControllers count]];
	for (CHSplitController *sp in splitControllers)
	{
		[documents addObject:[sp.view document]];
	}
	
	documents = [documents arrayByRemovingIdenticalDuplicates];
	
	if ([documents count] > 1 && [documents count] > [splitControllers count])
	{
		[group3 addObject:[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Consolidate Split Views", @"") action:@selector(consolidateSplitViews:) keyEquivalent:@""]]; 
	}
	
	//Put in a menu
	
	if ([group1 count])
		[parentGroup addObject:group1];
	if ([group2 count])
		[parentGroup addObject:group2];
	if ([group3 count])
		[parentGroup addObject:group3];
	if ([group4 count])
		[parentGroup addObject:group4];
		
	if (![parentGroup count])
		return nil;
	
	for (NSArray *group in parentGroup)
	{
		for (NSMenuItem *item in group)
		{
			[item setTarget:self];
			[menu addItem:item];
		}
		
		if (group != [parentGroup lastObject])
			[menu addItem:[NSMenuItem separatorItem]];
	}
	
	return menu;
}

- (void)closeTabAction:(id)sender
{
	[self closeTab];
}

- (void)closeOtherTabsAction:(id)sender
{
	//We've got to be a little careful here: We can't just send all the other tabs -closeTab messages. If more than one has docs with unsaved changes then the Review Changes alert won't be shown properly. So we ask the window controller to do it for us
	
	NSMutableArray *tabs = [NSMutableArray array];
	for (NSTabViewItem *item in [windowController.tabView tabViewItems])
	{
		CHTabController *t = [item identifier];
		
		if (t != self)
			[tabs addObject:t];
	}
	
	[windowController closeTabs:tabs];
}

- (id)copyWithZone:(NSZone *)zone
{
	CHTabController *copiedTab = [[CHTabController alloc] initWithWindow:[self window]];
	//copiedTab.windowController = wc;
	
	for (CHSplitController *sp in splitControllers)
	{
		CHSplitController *copiedSplit = [sp copy];
		[copiedTab addSplit:copiedSplit];
		copiedSplit.tabController = copiedTab;
	}
	
	return copiedTab;
}
- (void)duplicateTabAction:(id)sender
{
	CHTabController *copiedTab = [self copy];
	copiedTab.windowController = windowController;
	[windowController addTab:copiedTab];
}
- (void)moveSplitViewsToTabs:(id)sender
{
	BOOL isFirst = YES;
	for (CHSplitController *sp in [splitControllers copy])
	{
		//Don't move the first split view
		if (isFirst)
		{
			isFirst = NO;
			continue;
		}
		
		[self removeSplit:sp];
		
		CHTabController *copiedTab = [[CHTabController alloc] initWithWindow:[self window]];
		copiedTab.windowController = windowController;
		[copiedTab addSplit:sp];
		sp.tabController = copiedTab;
		[windowController addTab:copiedTab];
	}
}

@end
