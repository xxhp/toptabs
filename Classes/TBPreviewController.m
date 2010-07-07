//
//  TBPreviewController.m
//  TabBar3
//
//  Created by Alex Gordon on 26/12/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import "TBPreviewController.h"

#import "TBTabContentsPreviewView.h"
#import "TBPreviewWindow.h"

#import "TTController.h"
#import "TBTabItemLayer.h"

//#import "AGBlockAnimator.h"

@implementation TBPreviewController

@synthesize timeIntervalSinceClose;
@synthesize subject;
@synthesize isOpen;

- (id)init
{
	if (self = [super init])
	{
		previewWindow = [[TBPreviewWindow alloc] initWithContentRect:NSMakeRect(0, 0, 10, 10) styleMask:0 backing:NSBackingStoreBuffered defer:NO];
		previewView = [[TBTabContentsPreviewView alloc] initWithFrame:NSMakeRect(0, 0, 10, 10)];
		[previewWindow setContentView:previewView];
	}
	
	return self;
}

- (void)showOnWindow:(NSWindow *)w tabItem:(NSTabViewItem *)t
{
	return;
	
	hostWindow = w;
	subject = t;
	NSRect r = NSMakeRect(0, 0, [previewView fullSize].width, [previewView fullSize].height);
	
	TBTabItemLayer *layer = [[t identifier] view];
	
	previewView.image = [[t view] alphaImage];
	[previewView.image setFlipped:YES];
	NSSize imageSize = [[subject tabView] frame].size;
	r.size.height = imageSize.height * (r.size.width / imageSize.width);
	
	NSRect textRect = [layer textRect];
	r.origin.x = [w frame].origin.x + [[[t identifier] tabBar] convertPoint:NSZeroPoint toView:nil].x + layer.position.x + textRect.origin.x + textRect.size.width/2.0 - r.size.width/2.0;
	r.origin.y = [w frame].origin.y + [[[t identifier] tabBar] convertPoint:NSZeroPoint toView:nil].y - layer.frame.size.height - r.size.height + 7;// + layer.position.x + layer.frame.size.width/2.0 - r.size.width/2.0
		
	[previewWindow setFrame:r display:YES animate:NO];
	[previewView setNeedsDisplay:YES];
	
	if ([previewWindow parentWindow] != w)
		[[previewWindow parentWindow] removeChildWindow:previewWindow];
	
	if (![previewWindow parentWindow])
		[w addChildWindow:previewWindow ordered:NSWindowAbove];
	
	timeIntervalSinceClose = 0.0;
	isOpen = YES;
	
	
	if (!alreadyRefreshing)
	{
		alreadyRefreshing = YES;
		[self performSelector:@selector(refreshRepersentation) withObject:nil afterDelay:1.0/3.0];
	}
}
- (void)refreshRepersentation
{
	return;
	
	if (!isOpen)
	{
		alreadyRefreshing = NO;
		return;
	}
	if (![hostWindow isVisible])
	{
		alreadyRefreshing = NO;
		return;
	}
	
	NSTabView *tv = [subject tabView];
	
	if (!tv || [tv indexOfTabViewItem:subject] == NSNotFound)
	{
		alreadyRefreshing = NO;
		return;
	}
	
	if ([tv indexOfTabViewItem:subject] == [tv indexOfTabViewItem:[tv selectedTabViewItem]])
	{
		previewView.image = [[subject view] alphaImage];
		[previewView.image setFlipped:YES];
		[previewView setNeedsDisplay:YES];
	}
	
	[self performSelector:@selector(refreshRepersentation) withObject:nil afterDelay:1.0/3.0];
}

- (void)hide
{
	return;
	
	[hostWindow removeChildWindow:previewWindow];
	[previewWindow orderOut:nil];
	
	timeIntervalSinceClose = [NSDate timeIntervalSinceReferenceDate];
	
	subject = nil;
	isOpen = NO;
}
- (void)hideIfItem:(NSTabViewItem *)i
{
	if (self.subject == i)
		[self hide];
}

#pragma mark Singleton

static TBPreviewController *sharedController = nil;

+ (TBPreviewController*)sharedController
{	
    @synchronized(self) {
        if (sharedController == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedController;
}
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedController == nil) {
            sharedController = [super allocWithZone:zone];
            return sharedController;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
- (id)retain
{
    return self;
}
- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}
- (void)release
{
    //do nothing
}
- (id)autorelease
{
    return self;
}

@end
