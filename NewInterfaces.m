@interface TTBar : NSView
{
	IBOutlet NSTabView *tabView;
	NSMutableArray *items;
}

//The associated tab view. Normally this would be tabless 
@property (retain) IBOutlet NSTabView *tabView;

//If allowsDraggingOutOfBar is YES, then identifier is used to determine if a tab bar is a compatible drag destination
@property (copy) NSObject<NSCopying> identifier;

//YES if the tab bar has an overflow area where it moves tabs if there's not enough space
@property (assign) BOOL hasOverflow;

//YES if items in the tab bar may be dragged out into empty space (to create new window)
@property (assign) BOOL allowsDraggingOutOfBar;

//The smallest width an item will resize to before it is either moved to the overflow or no more items are accepted
@property (assign) CGFloat minimumItemWidth;

//The largest width an item will take. Widths are greedy so if a tab can resize to maximumItemWidth, it will. Pass 0 for no maximum (think Safari 4 Beta R.I.P.)
@property (assign) CGFloat maximumItemWidth;

//The class of items in the tab bar
@property (assign) Class itemClass;

//The selected item
@property (assign) TTItem *selectedItem;

//Return YES if there's room to accept more items. KVO compliant.
- (BOOL)acceptsNewItems;

//Creates an item using [[self.itemClass alloc] init] then attempt to add it to the bar with an animation using addItem:animate:. Does nothing if there's no space.
- (IBAction)createAndAddItem:(id)sender;

//Close the selected item with an animation using removeItem:animate:
- (IBAction)closeSelectedItem:(id)sender;

//Attempt to add an item to the bar. May fail and return NO if there's no space.
- (BOOL)addItem:(TTItem *)item animate:(BOOL)shouldAnimate;

//Remove an item to the bar.
- (void)removeItem:(TTItem *)item animate:(BOOL)shouldAnimate;

//The items in the tab bar. KVO compliant.
- (NSArray *)items;

//A menu with items in the overflow. Returns nil if there's no overflow. KVO compliant.
- (NSMenu *)overflowMenu;

@end


@protocol TTBarDelegate

@optional

- (BOOL)tabBar:(TTBar *)bar shouldAddItem:(TTItem *)item;
- (void)tabBar:(TTBar *)bar willAddItem:(TTItem *)item;
- (void)tabBar:(TTBar *)bar didAddItem:(TTItem *)item;

- (BOOL)tabBar:(TTBar *)bar shouldSelectItem:(TTItem *)item;
- (void)tabBar:(TTBar *)bar willSelectItem:(TTItem *)item;
- (void)tabBar:(TTBar *)bar didSelectItem:(TTItem *)item;

- (BOOL)tabBar:(TTBar *)bar shouldCloseItem:(TTItem *)item;
- (void)tabBar:(TTBar *)bar willCloseItem:(TTItem *)item;
- (void)tabBar:(TTBar *)bar didCloseItem:(TTItem *)item;

- (void)tabBar:(TTBar *)bar willMoveItemToOverflow:(TTItem *)item;
- (void)tabBar:(TTBar *)bar didMoveItemToOverflow:(TTItem *)item;

- (void)tabBar:(TTBar *)sourceBar willMoveItem:(TTItem *)item toDifferentBar:(TTBar *)destinationBar;
- (void)tabBar:(TTBar *)sourceBar didMoveItem:(TTItem *)item toDifferentBar:(TTBar *)destinationBar;
- (void)tabBar:(TTBar *)destinationBar willReceiveItem:(TTItem *)item fromDifferentBar:(TTBar *)sourceBar;
- (void)tabBar:(TTBar *)destinationBar didReceiveItem:(TTItem *)item fromDifferentBar:(TTBar *)sourceBar;

//Called if no more tabs will be accepted in this bar, due to lack of space. Will not be called if hasOverflow is YES.
- (void)tabBarDidBecomeFull:(TTBar *)bar;
//Called if tabs will be accepted in this bar, due new space being found. Will not be called if hasOverflow is YES.
- (void)tabBarDidBecomeSpacious:(TTBar *)bar;

@end


//Represents a tab item. Acts as the identifier for the NSTabViewItem
@interface TTItem : NSObject
{
	NSString *title;
	NSImage *icon;
	NSTabViewItem *tabViewItem;
}

@property (copy) NSString *title;
@property (retain) NSImage *icon;
@property (retain) NSTabViewItem *tabViewItem;

- (TTBar *)bar;
- (NSTabView *)tabView;

@end
