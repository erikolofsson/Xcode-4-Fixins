//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//

#include "Shared.h"

@interface IDEWorkspaceWindow : NSWindow
{
}

+ (id)lastActiveWorkspaceWindowController;
- (void)_invalidateCursorRectsForView:(id)arg1 force:(BOOL)arg2;
- (void)_invalidateCursorRectsForViewsWithNoTrackingAreas;
- (BOOL)_addCursorRect:(struct CGRect)arg1 cursor:(id)arg2 forView:(id)arg3;
- (void)_setCursorForMouseLocation:(struct CGPoint)arg1;
- (BOOL)_keyViewRedirectionDisabled;
- (void)recalculateKeyViewLoop;
- (BOOL)canBecomeMainWindow;
- (BOOL)canBecomeKeyWindow;
- (void)becomeMainWindow;
- (void)setWindowController:(id)arg1;
- (void)setDelegate:(id)arg1;
- (void)dvt_shouldDeallocate;
- (void)close;
- (struct CGRect)adjustedFrameForCascade:(struct CGRect)arg1 fromWindow:(id)arg2;
- (struct CGRect)_adjustedFrameForSaving:(struct CGRect)arg1;
- (void)cancelOperation:(id)arg1;
- (void)toggleToolbarShown:(id)arg1;
- (id)firstResponder;
- (void)endSheet:(id)arg1 returnCode:(long long)arg2;
- (void)sendEvent:(id)arg1;
- (BOOL)validateMenuItem:(id)arg1;

@end

