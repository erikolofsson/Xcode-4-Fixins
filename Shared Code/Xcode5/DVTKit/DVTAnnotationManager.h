/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

/*
 * SDK Root: /Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk.sdk
 */

@class DVTAnnotationContext, NSMutableArray;
@protocol DVTAnnotationManagerDelegate;

@interface DVTAnnotationManager : NSObject
{
    id <DVTAnnotationManagerDelegate> _delegate;
    NSMutableArray *_annotationProviders;
    DVTAnnotationContext *_context;
}

@property(retain) id <DVTAnnotationManagerDelegate> delegate; // @synthesize delegate=_delegate;
@property(retain) DVTAnnotationContext *context; // @synthesize context=_context;
@property(retain) NSMutableArray *annotationProviders; // @synthesize annotationProviders=_annotationProviders;
- (void)removeAllAnnotationProviders;
- (void)setupAnnotationProvidersWithContext:(id)arg1;
- (id)_installObservationBlockForAnnotationProvider:(id)arg1;

@end

