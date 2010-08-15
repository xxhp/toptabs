#import "TTBar.h"

@implementation TTBar

@synthesize delegate;

//The associated tab view. Normally this would be tabless 
@synthesize tabView;

//If allowsDraggingOutOfBar is YES, then identifier is used to determine if a tab bar is a compatible drag destination
@synthesize identifier;

//YES if the tab bar has an overflow area where it moves tabs if there's not enough space
@synthesize hasOverflow;

//YES if items in the tab bar may be dragged out into empty space (to create new window)
@synthesize allowsDraggingOutOfBar;

//The smallest width an item will resize to before it is either moved to the overflow or no more items are accepted
@synthesize minimumItemWidth;

//The largest width an item will take. Widths are greedy so if a tab can resize to maximumItemWidth, it will. Pass 0 for no maximum (think Safari 4 Beta R.I.P.)
@synthesize maximumItemWidth;

//The class of items in the tab bar
@synthesize itemClass;

//The selected item
- (TTItem *)selectedItem
{
	return [[self.tabView selectedTabViewItem] identifier];
}
- (void)setSelectedItem:(TTItem *)item
{
	[self.tabView selectTabViewItemWithIdentifier:item];
}

//Return YES if there's room to accept more items. KVO compliant.
- (BOOL)acceptsNewItems
{
	
}

//Creates an item using [[self.itemClass alloc] init] then attempt to add it to the bar with an animation using addItem:animate:. Does nothing if there's no space.
- (IBAction)createAndAddItem:(id)sender
{
	TTItem *item = [[TTItem alloc] init];
	[self addItem:item animate:YES];
}

//Close the selected item with an animation using removeItem:animate:
- (IBAction)closeSelectedItem:(id)sender
{
	[self removeItem:self.selectedItem animate:YES];
}

//Attempt to add an item to the bar. May fail and return NO if there's no space.
- (BOOL)addItem:(TTItem *)item animate:(BOOL)shouldAnimate
{
	
}

//Remove an item to the bar.
- (void)removeItem:(TTItem *)item animate:(BOOL)shouldAnimate
{
	
}

//The items in the tab bar. KVO compliant.
- (NSArray *)items
{
	return items;
}

//A menu with items in the overflow. Returns nil if there's no overflow. KVO compliant.
- (NSMenu *)overflowMenu
{
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Menu"];
	[menu setFont:[NSFont systemFontOfSize:12]];

	BOOL didAddSeparator = NO;
	for (NSTabViewItem *tabItem in [tabView tabViewItems])
	{
		TTItem *item = [tabItem identifier];
		TBTabItemLayer *view = item.view;
		
		if (view.position.x >= [self frame].size.width)
		{
			if (!didAddSeparator)
			{
				didAddSeparator = YES;
			}
		}
		else
		{
			continue;
		}
		
		if (![item.title length])
			continue;
		
		NSMenuItem *mitem = [[NSMenuItem alloc] initWithTitle:item.title action:nil keyEquivalent:@""];
		[mitem setImage:item.icon];
		[mitem setRepresentedObject:item];
		[mitem setTarget:self];
		[mitem setAction:@selector(overflow:)];
		
		if (item == [self selectedItem])
		{
			[mitem setAttributedTitle:[[NSAttributedString alloc] initWithString:item.title attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:12], NSFontAttributeName, nil]]];
			[mitem setState:NSOnState];
		}
		
		[menu addItem:mitem];
	}
	
	return menu;
}
- (void)overflow:(NSMenuItem *)sender
{
	self.selectedItem = [sender representedObject];
}

@end
