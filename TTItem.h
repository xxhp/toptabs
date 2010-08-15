#import <Cocoa/Cocoa.h>

@class TTBar;

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
