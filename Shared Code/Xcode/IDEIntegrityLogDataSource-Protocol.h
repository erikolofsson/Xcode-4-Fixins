//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk.sdk
//

#import "DVTInvalidation-Protocol.h"

@class IDEActivityLogSection;

@protocol IDEIntegrityLogDataSource <DVTInvalidation>
@property(readonly) IDEActivityLogSection *integrityLog;
- (void)analyzeModelIntegrity;
@end

