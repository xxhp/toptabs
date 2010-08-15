//
//  TTBarContainerView.m
//  toptabs
//
//  Created by Alex Gordon on 05/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TTBarContainerView.h"


@implementation TTBarContainerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[[NSImage imageNamed:@"tab_background"] drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
}

@end
