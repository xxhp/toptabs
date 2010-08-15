//
//  TTWindow.h
//  toptabs
//
//  Created by Alex Gordon on 04/08/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TTBar;

@interface TTWindow : NSWindow {
	IBOutlet TTBar *tabBar;
}

@end
