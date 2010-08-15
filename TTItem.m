#import "TTItem.h"

@implementation TTItem

@synthesize icon;
@synthesize tabViewItem;

@synthesize title;

- (void)setTitle:(NSString *)newTitle
{
	title = [newTitle copy];
	[tabViewItem setLabel:title];
}

- (TTBar *)bar
{
	return [[tabViewItem tabView] delegate];
}
- (NSTabView *)tabView
{
	return [tabViewItem tabView];
}

@end