/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

/*
 * SDK Root: /Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk.sdk
 */

@class NSMutableSet, NSSet;

@interface DVTAnnotationProvider : NSObject
{
    NSMutableSet *_annotations;
}

+ (id)annotationProviderForContext:(id)arg1 error:(id *)arg2;
+ (void)initialize;
- (void)providerWillUninstall;
- (id)init;

// Remaining properties
@property(copy) NSSet *annotations; // @dynamic annotations;
@property(readonly, copy) NSMutableSet *mutableAnnotations; // @dynamic mutableAnnotations;

@end

