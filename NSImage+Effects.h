
//  NSImage+Effects.h
//
//  Originally created by Alex Gordon on 10/08/2007

#import <Cocoa/Cocoa.h>


@interface NSView (Effects)

- (NSImage *)alphaImage;
- (NSImage *)compositedImage;
- (NSRect)screenSpaceRect;
- (NSView *)subviewForClassName:(NSString *)name;

@end


@interface NSImage (Effects)

- (NSImageView *)imageViewValue;
- (NSImage *)croppedWithFrame:(NSRect)frame;

@end
