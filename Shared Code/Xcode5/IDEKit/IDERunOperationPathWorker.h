//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

//
// SDK Root: /Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk.sdk
//

#import "../IDEFoundation/IDERunOperationWorker.h"

@class DVTFilePath, NSMutableDictionary;

@interface IDERunOperationPathWorker : IDERunOperationWorker
{
    DVTFilePath *_filePathToBinary;
}

@property(readonly) NSMutableDictionary *compositeEnvironmentVariables;
@property(readonly) DVTFilePath *filePathToBinary;
@property(readonly) DVTFilePath *filePath;

@end

