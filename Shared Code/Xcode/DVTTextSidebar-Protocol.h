//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk.sdk
//


@class DVTTextAnnotation, NSView, NSWindow;

@protocol DVTTextSidebar <NSObject>
- (void)getParagraphRect:(struct CGRect *)arg1 firstLineRect:(struct CGRect *)arg2 forLineNumber:(unsigned long long)arg3;
- (struct CGRect)sidebarMarkerRectForTextAnnotation:(DVTTextAnnotation *)arg1;
- (NSView *)sidebarMarkerParentView;
- (NSView *)viewForPopover;
- (NSWindow *)window;
@end
