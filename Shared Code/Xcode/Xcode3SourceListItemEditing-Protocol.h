//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk.sdk
//


@class NSArray, NSDictionary, NSString;
@protocol Xcode3SourceListItemEditing;

@protocol Xcode3SourceListItemEditing <NSObject>
+ (id <Xcode3SourceListItemEditing>)deserializedSourceListItem:(NSDictionary *)arg1;
+ (NSString *)pasteboardDataType;
- (NSDictionary *)serializedSourceListItem;
- (NSArray *)supportedSourceListItemEditorClasses;
@end

