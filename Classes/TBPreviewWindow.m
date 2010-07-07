//
//  TBPreviewWindow.m
//  TabBar3
//
//  Created by Alex Gordon on 26/12/2008.
//  Copyright 2008 Fileability. All rights reserved.
//

#import "TBPreviewWindow.h"


@implementation TBPreviewWindow

- (id)initWithContentRect:(NSRect)contentRect 
                styleMask:(unsigned int)aStyle 
                  backing:(NSBackingStoreType)bufferingType 
                    defer:(BOOL)flag
{
    
    if (self = [super initWithContentRect:contentRect 
								styleMask:NSBorderlessWindowMask 
								  backing:bufferingType 
									defer:flag])
	{
        [self setBackgroundColor: [NSColor clearColor]];
        [self setAlphaValue:1.0];
        [self setOpaque:NO];
        [self setHasShadow:NO];
        
        return self;
    }
    
    return nil;
}

@end
