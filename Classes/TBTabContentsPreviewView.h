//
//  TBTabContentsPreviewView.h
//  TabBar3
//
//  Created by Alex Gordon on 24/12/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TBTabContentsPreviewView : NSView {
	NSImageView *imageView;
	NSImage *image;
}

@property (setter=setImage:) NSImage *image;

- (NSSize)contentSize;
- (NSSize)fullSize;
- (NSSize)arrowSize;


- (float)borderWidth;
- (float)shadowWidth;

@end
