
//  NSImage+Effects.h
//
//  Originally created by Alex Gordon on 10/08/2007


#import "NSImage+Effects.h"


@implementation NSView (Effects)

- (NSImage *)alphaImage
{
	NSBitmapImageRep* rep = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
	[self cacheDisplayInRect:[self bounds] toBitmapImageRep:rep];
	
	NSImage *outputImage = [[NSImage alloc] initWithSize:[rep size]];
	[outputImage addRepresentation:rep];
	
	return [outputImage autorelease];//[[[NSImage alloc] initWithData:[rep TIFFRepresentation]] autorelease];
}

- (NSImage *)compositedImage
{
	[self lockFocus];
	NSRect bounds = [self bounds];
	NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:bounds];
	[self unlockFocus];
	
	return [[[NSImage alloc] initWithData:[rep TIFFRepresentation]] autorelease];
}

- (NSRect)screenSpaceRect
{
	NSRect newWinRect = [self frame];
	newWinRect.origin = [self convertPoint:NSZeroPoint toView:nil];

	newWinRect.origin.x = [[self window] frame].origin.x + [self convertPoint:NSZeroPoint toView:nil].x; //[[oldParent contentView] convertRect:[[oldParent contentView] bounds] toView:nil]
	newWinRect.origin.y = [[self window] frame].origin.y + /*[oldParent frame].size.height -*/ [self convertPoint:NSZeroPoint toView:nil].y - [self frame].size.height;

	return newWinRect;
}

- (NSView *)subviewForClassName:(NSString *)name
{
	int i;
	NSArray *subviews = [self subviews];
	for (i = 0; i < [subviews count]; i++)
	{
		if ([[subviews objectAtIndex:i] isKindOfClass:NSClassFromString(name)])
			return [subviews objectAtIndex:i];
	}
	return nil;
}

@end


@implementation NSImage (Effects)

- (NSImageView *)imageViewValue
{
	NSImageView *v = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, [self size].width, [self size].height)];
	[v setImageFrameStyle:NSImageFrameNone];
	[v setImageScaling:NSScaleNone];
	[v setImage:self];
	return v;
}

- (NSImage *)croppedWithFrame:(NSRect)frame
{
	NSImage *i = [[NSImage alloc] initWithSize:frame.size];
	[i lockFocus];
		NSRect sourceRect = frame;
		NSRect destRect = NSMakeRect(0, 0, frame.size.width, frame.size.height);
		[self drawInRect:destRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.0];
		
	[i unlockFocus];
	return i;
}

@end
