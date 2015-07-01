//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//


@class DVTSourceModel, DVTSourceModelItem, NSString;

@protocol DVTSourceLanguageSourceModelService <NSObject>
- (long long)languageIdentifierAtLocation:(unsigned long long)arg1;
- (NSString *)stringForItem:(DVTSourceModelItem *)arg1;
- (DVTSourceModelItem *)commonSourceModelItemAtRange:(struct _NSRange)arg1;
- (DVTSourceModelItem *)sourceModelItemAtCharacterIndex:(unsigned long long)arg1;
- (DVTSourceModelItem *)sourceModelItemAtCharacterIndex:(unsigned long long)arg1 affinity:(unsigned long long)arg2;
- (DVTSourceModel *)sourceModelWithoutParsing;
- (DVTSourceModel *)sourceModel;
@end

