//
//  TBAddSplitButton.h
//  Chocolat
//
//  Created by Alex Gordon on 10/07/2009.
//  Copyright 2009 Fileability. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TBButton.h"

@interface TBAddSplitButton : TBButton
{
	BOOL horizontal;
	BOOL orientation;
}

@property (assign, setter=setHorizontal:) BOOL horizontal;
@property (assign, setter=setOrientation:) BOOL orientation;

@end
