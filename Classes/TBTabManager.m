//
//  TBTabManager.m
//  MacBase
//
//  Created by Alex Gordon on 02/02/2009.
//  Copyright 2009 Fileability. All rights reserved.
//

#import "TBTabManager.h"
#import "TTController.h"
#import "TTBar.h"
#import "TTDefaultController.h"

NSString *const MBTableItemType = @"Tables";
NSString *const MBQueryItemType = @"Queries";
NSString *const MBFormItemType = @"Forms";
NSString *const MBReportItemType = @"Reports";
NSString *const MBScriptItemType = @"Scripts";


/*
 
 If the item is already open:
	If the Command Key is down:
		Create new tab
		Open in that tab
	Else:
		Switch to old instance
 Else
	If selected tab is blank:
		Open in that tab
	Else:
		Create new tab
		Open in that tab
 */

@implementation TBTabManager

@synthesize document;

- (NSArray *)openItems
{
	NSArray *identifiers = [[tabview tabViewItems] arrayByMakingObjectsPerformSelector:@selector(identifier) withObject:nil];
	return identifiers;
}
- (NSObject<TTController> *)openNewItemHumanType:(NSString *)humanType xbaseType:(NSString *)type
{
	NSString *n = [@"New " stringByAppendingString:humanType];
	[self openItemWithName:n ofType:type forceNewTab:YES];
}
- (NSObject<TTController> *)openItemWithName:(NSString *)name ofType:(NSString *)type forceNewTab:(BOOL)newTab
{
	NSObject<TTController> *ident = [self itemWithName:name ofType:type];
	
	BOOL itemIsAlreadyOpen = (ident != nil);
	BOOL commandKeyIsDown = newTab;
	BOOL selectedTabIsBlank = [self selectedItemIsBlank];
	
	if (itemIsAlreadyOpen)
	{
		if (commandKeyIsDown)
		{
			ident = [self createItemWithName:name ofType:type];
			[ident createNewTab];
			[ident makeActive];
		}
		else
		{
			[ident makeActive]; //Switch to old instance
		}
	}
	else
	{
		if (selectedTabIsBlank)
		{
			ident = [self createItemWithName:name ofType:type];
			[ident replaceCurrentTabWithItemAndMakeActive];
		}
		else
		{
			ident = [self createItemWithName:name ofType:type];
			[ident createNewTab];
			[ident makeActive];
		}
	}
	
	return ident;
}

- (NSObject<TTController> *)itemWithView:(NSView *)itemView
{
	if (!itemView)
		return nil;
	
	NSArray *items = [tabview tabViewItems];
	for (NSTabViewItem *item in items)
	{
		if ([item view] == itemView && [[item identifier] conformsToProtocol:@protocol(TTController)])
			return [item identifier];
	}
}
- (NSObject<TTController> *)itemWithName:(NSString *)name ofType:(NSString *)type
{
	NSArray *openItems = [self openItems];
	for (NSObject<TTController> *item in openItems)
	{
		if ([item respondsToSelector:@selector(name)] && [item.name isEqual:name] && [item.type isEqual:type])
			return item;
	}
	
	return nil;
}

- (void)switchItem:(NSTabViewItem *)item toIdentifier:(NSObject<TTController> *)ident
{
	
}

- (BOOL)selectedItemIsBlank
{
	NSTabViewItem *selItem = [tabview selectedTabViewItem];
	
	if ([[selItem label] isEqual:@"New Item"])
		return YES;
	return NO;
}

#pragma mark Private

- (NSObject<TTController> *)createItemWithName:(NSString *)name ofType:(NSString *)type
{
	NSObject<TTController> *ident = [[TTDefaultController alloc] init];
	NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:ident];
	ident.item = item;
	[item setLabel:name];
	ident.type = type;
	ident.tabBar = tabbar;
	ident.dict = [document dictionaryForName:name type:type];
	
	return ident;
}

@end
