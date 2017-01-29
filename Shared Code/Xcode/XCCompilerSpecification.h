//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk.sdk
//

#include "Shared.h"

#import "XCCommandLineToolSpecification.h"

@class NSArray, NSMapTable;
@protocol DVTMacroExpansion;

@interface XCCompilerSpecification : XCCommandLineToolSpecification
{
    NSMapTable *_supportedArchsByDomain;
    NSArray<DVTMacroExpansion> *_depInfoArgs;
}

+ (id)specificationsToDisplayInDomain:(id)arg1;
+ (id)specificationTypePathExtensions;
+ (id)localizedSpecificationTypeName;
+ (id)specificationType;
+ (Class)specificationTypeBaseClass;
// - (void).cxx_destruct;
- (id)computeDependenciesForFilePath:(id)arg1 ofType:(id)arg2 outputDirectory:(id)arg3 withMacroExpansionScope:(id)arg4;
- (void)setupHeadermapsWithMacroExpansionScope:(id)arg1;
- (id)computeDependenciesForInputNodes:(id)arg1 ofType:(id)arg2 variant:(id)arg3 architecture:(id)arg4 outputDirectory:(id)arg5 withMacroExpansionScope:(id)arg6;
- (id)adjustedFileTypeForInputFileAtPath:(id)arg1 originalFileType:(id)arg2 withMacroExpansionScope:(id)arg3;
- (id)fileTypeForGccLanguageDialect:(id)arg1;
- (id)effectiveCompilerSpecificationForFileType:(id)arg1 withMacroExpansionScope:(id)arg2 forSDK:(id)arg3;
- (id)effectiveCompilerSpecificationForFileType:(id)arg1 withMacroExpansionScope:(id)arg2 platformDomain:(id)arg3;
- (id)defaultOutputDirectory;
- (id)executablePath;
- (id)outputFilesForInputFilePath:(id)arg1 withMacroExpansionScope:(id)arg2;
- (id)builtinJambaseRuleName;
- (BOOL)showOnlySelfDefinedPropertiesInBuildSettingsGUI;
- (BOOL)isAbstract;
- (id)supportedArchitecturesInDomain:(id)arg1 withMacroExpansionScope:(id)arg2;
- (id)initWithPropertyListDictionary:(id)arg1 inDomain:(id)arg2;
- (id)builtinMacroDefinitionsWithMacroExpansionScope:(id)arg1 forLanguageDialect:(id)arg2;
- (id)builtinFrameworkSearchPathsWithMacroExpansionScope:(id)arg1 forLanguageDialect:(id)arg2;
- (id)builtinBracketSearchPathsWithMacroExpansionScope:(id)arg1 forLanguageDialect:(id)arg2;
- (id)builtinQuoteSearchPathsWithMacroExpansionScope:(id)arg1 forLanguageDialect:(id)arg2;

@end

