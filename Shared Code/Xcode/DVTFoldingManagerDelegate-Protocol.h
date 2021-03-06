//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk.sdk
//


@class DVTFoldingManager, NSArray;
@protocol DVTObjectLiteralMediaResourceProvider;

@protocol DVTFoldingManagerDelegate <NSObject>
- (void)foldingManager:(DVTFoldingManager *)arg1 didUnfoldRange:(struct _NSRange)arg2;
- (void)foldingManager:(DVTFoldingManager *)arg1 didFoldRange:(struct _NSRange)arg2;

@optional
- (id <DVTObjectLiteralMediaResourceProvider>)mediaResourceProviderForLiteralInFoldingManager:(DVTFoldingManager *)arg1;
- (NSArray *)directoriesForLiteralInFoldingManager:(DVTFoldingManager *)arg1;
@end

