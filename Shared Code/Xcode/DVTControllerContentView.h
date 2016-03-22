//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//

#include "Shared.h"

#import "DVTWrapperView.h"

#import "DVTInvalidation-Protocol.h"

@class DVTStackBacktrace, DVTViewController, NSString, NSWindow;

@interface DVTControllerContentView : DVTWrapperView <DVTInvalidation>
{
}

+ (id)keyPathsForValuesAffectingKvoWindow;
+ (unsigned long long)assertionBehaviorAfterEndOfEventForSelector:(SEL)arg1;
@property(readonly, nonatomic) DVTViewController *viewController;
- (void)setViewController:(DVTViewController *viewController)arg1;
@property(readonly) NSWindow *kvoWindow;
- (BOOL)performKeyEquivalent:(id)arg1;
- (void)setNextResponder:(id)arg1;
- (void)invalidate;

// Remaining properties
@property(retain) DVTStackBacktrace *creationBacktrace;
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) DVTStackBacktrace *invalidationBacktrace;
@property(readonly) Class superclass;
@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

