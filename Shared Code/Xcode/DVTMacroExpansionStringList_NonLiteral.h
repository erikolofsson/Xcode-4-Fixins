//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk.sdk
//

#include "Shared.h"

#import "DVTMacroExpansionStringList.h"

@class NSString;
@protocol DVTMacroExpansion;

@interface DVTMacroExpansionStringList_NonLiteral : DVTMacroExpansionStringList
{
    unsigned long long _numElements;
    NSString<DVTMacroExpansion> *_elements[0];
}

+ (id)newWithStringForm:(id)arg1 elements:(struct ArrayBuilder *)arg2;
// - (void).cxx_destruct;
- (id)dvt_debugDescription;
- (void)dvt_assertInternalConsistency;
- (id)dvt_evaluateAsStringListInScope:(id)arg1 withState:(const struct DVTNestedMacroExpansionState *)arg2;
- (id)dvt_evaluateAsStringInScope:(id)arg1 withState:(const struct DVTNestedMacroExpansionState *)arg2;
- (id)description;
- (unsigned long long)countByEnumeratingWithState:(CDStruct_70511ce9 *)arg1 objects:(id *)arg2 count:(unsigned long long)arg3;
- (id)objectAtIndex:(unsigned long long)arg1;
- (unsigned long long)count;
- (BOOL)isEqual:(id)arg1;
- (unsigned long long)hash;
- (id)dvt_stringForm;
- (BOOL)dvt_isLiteral;
- (void)dealloc;
- (id)initWithStringForm:(id)arg1 elements:(struct ArrayBuilder *)arg2;

@end

