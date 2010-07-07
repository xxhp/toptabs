//
//  toptabsAppDelegate.h
//  toptabs
//
//  Created by Alex Gordon on 10/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class TTBar;

@interface toptabsAppDelegate : NSObject <NSApplicationDelegate> {

    NSWindow *window;
	
	IBOutlet TTBar *tabBar;
	IBOutlet NSTabView *tabView;
}

@property (assign) IBOutlet NSWindow *window;

@end

