//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//

#include "Shared.h"

@class IDEUpgradeContext, NSString;

@interface IDEUpgradeTask : NSObject
{
    NSString *_title;
    NSString *_subtitle;
    NSString *_category;
    IDEUpgradeContext *_context;
    BOOL _selected;
}

+ (id)analyzeInScheme:(id)arg1;
+ (id)analyzeInContext:(id)arg1;
+ (id)metricLogAspect;
@property BOOL selected; // @synthesize selected=_selected;
@property(readonly) IDEUpgradeContext *context; // @synthesize context=_context;
@property(readonly) NSString *category; // @synthesize category=_category;
@property(readonly) NSString *subtitle; // @synthesize subtitle=_subtitle;
@property(readonly) NSString *title; // @synthesize title=_title;
// - (void).cxx_destruct;
- (void)_setCategory:(id)arg1;
- (BOOL)upgrade;
- (id)initWithTitle:(id)arg1 subtitle:(id)arg2 context:(id)arg3;

@end

