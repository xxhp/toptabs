//This is how I *would* rewrite TTBar if I had the time.
//I don't think it's such a good idea though... you know what they say about rewrites



#import <Cocoa/Cocoa.h>

@class TTItem;
@protocol TTBarDelegate;

@interface TTBar : NSView
{
	IBOutlet NSObject<TTBarDelegate> *delegate;
	
	IBOutlet NSTabView *tabView;
	NSMutableArray *items;
}

@property (retain) IBOutlet NSObject<TTBarDelegate> *delegate;

//The associated tab view. Normally this would be tabless 
@property (retain) IBOutlet NSTabView *tabView;

//If allowsDraggingOutOfBar is YES, then identifier is used to determine if a tab bar is a compatible drag destination
@property (copy) NSObject<NSCopying> *identifier;

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