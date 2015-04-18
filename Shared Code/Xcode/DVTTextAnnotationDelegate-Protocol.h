//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

//
// SDK Root: /Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//

@class DVTAnnotation, DVTTextAnnotation, DVTTextSidebarView, NSArray, NSEvent, NSGestureRecognizer, NSSet;

@protocol DVTTextAnnotationDelegate <NSObject>

@optional
- (void)annotation:(DVTTextAnnotation *)arg1 willDrawInTextSidebarView:(DVTTextSidebarView *)arg2 withAnnotationsInSameLine:(NSSet *)arg3;
- (BOOL)annotation:(DVTTextAnnotation *)arg1 shouldDrawInTextSidebarView:(DVTTextSidebarView *)arg2 withAnnotationsInSameLine:(NSSet *)arg3;
- (double)sidebarMarkerOpacityForAnnotation:(DVTTextAnnotation *)arg1;
- (BOOL)shouldMoveCursorForAnnotation:(DVTTextAnnotation *)arg1;
- (NSArray *)contextMenuItemsForAnnotation:(DVTTextAnnotation *)arg1 inTextSidebarView:(DVTTextSidebarView *)arg2;
- (void)didRecognizeGestureInAnnotation:(DVTTextAnnotation *)arg1 inTextSidebarView:(DVTTextSidebarView *)arg2 recognizer:(NSGestureRecognizer *)arg3;
- (void)didDeleteOrReplaceParagraphForAnnotation:(DVTTextAnnotation *)arg1;
- (void)didRemoveAnnotation:(DVTAnnotation *)arg1;
- (void)didMoveAnnotation:(DVTAnnotation *)arg1;
- (unsigned long long)annotation:(DVTTextAnnotation *)arg1 willMoveToParagraphNumber:(unsigned long long)arg2;
- (void)didDragAnnotation:(DVTAnnotation *)arg1 inTextSidebarView:(DVTTextSidebarView *)arg2 event:(NSEvent *)arg3;
- (void)didEndRolloverOnAnnotation:(DVTAnnotation *)arg1 inTextSidebarView:(DVTTextSidebarView *)arg2 event:(NSEvent *)arg3;
- (void)didBeginRolloverOnAnnotation:(DVTAnnotation *)arg1 inTextSidebarView:(DVTTextSidebarView *)arg2 event:(NSEvent *)arg3;
- (void)didClickAnnotation:(DVTAnnotation *)arg1 inTextSidebarView:(DVTTextSidebarView *)arg2 event:(NSEvent *)arg3;
@end

