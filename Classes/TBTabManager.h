//
//  TBTabManager.h
//  MacBase
//
//  Created by Alex Gordon on 02/02/2009.
//  Copyright 2009 Fileability. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const MBTableItemType;
extern NSString *const MBQueryItemType;
extern NSString *const MBFormItemType;
extern NSString *const MBReportItemType;
extern NSString *const MBScriptItemType;

@protocol TTController;
@class TTBar;

@interface TBTabManager : NSObject {
	IBOutlet NSDocument *document;
	IBOutlet TTBar *tabbar; 
	IBOutlet NSTabView *tabview;
}

@property (assign) NSDocument *document;

- (NSArray *)openItems;
- (NSObject<TTController> *)itemWithName:(NSString *)name ofType:(NSString *)type;
- (NSObject<TTController> *)openItemWithName:(NSString *)name ofType:(NSString *)type forceNewTab:(BOOL)newTab;

- (BOOL)selectedItemIsBlank;

//Private
- (NSObject<TTController> *)createItemWithName:(NSString *)name ofType:(NSString *)type;

@end
