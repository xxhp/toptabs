#import <Cocoa/Cocoa.h>

@class TTBar;
@class TTItem;

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