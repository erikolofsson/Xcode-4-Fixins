//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//

#include "Shared.h"

#import "XCPropertyDomainSpecification.h"

@class DVTMacroDefinitionTable, NSArray, NSDictionary, NSIndexSet, NSMutableDictionary, NSString, XCFnmatchPatternSet;
@protocol DVTMacroExpansion;

@interface XCCommandLineToolSpecification : XCPropertyDomainSpecification
{
    NSString<DVTMacroExpansion> *_commandIdentTemplate;
    NSArray<DVTMacroExpansion> *_commandLineTemplate;
    NSString<DVTMacroExpansion> *_execPath;
    NSArray<DVTMacroExpansion> *_ruleLineTemplate;
    Class _commandInvocationClass;
    NSMutableDictionary *_messageCategoryInfoDicts;
    NSMutableDictionary *_severityBasedMessageCategoryInfoDicts;
    NSArray *_outputParserClassesOrRules;
    Class _resultsPostprocessorClass;
    NSArray *_fallbackToolIdentifiers;
    NSMutableDictionary *_fallbackToolSpecifications;
    NSArray *_inputFileTypes;
    NSArray<DVTMacroExpansion> *_additionalInputFiles;
    BOOL _shouldDeeplyStatInputDirectories;
    NSString<DVTMacroExpansion> *_generatedInfoPlistContentFilePath;
    NSArray<DVTMacroExpansion> *_additionalPathsToClean;
    XCFnmatchPatternSet *_flagsNotAffectingOutputFile;
    BOOL _supportsDeploymentTarget;
    NSMutableDictionary *_defaultDeploymentTargetsByName;
    NSString<DVTMacroExpansion> *_outputDir;
    NSString<DVTMacroExpansion> *_outputPath;
    NSArray<DVTMacroExpansion> *_outputPaths;
    BOOL _outputsAreProducts;
    BOOL _dontProcessOutputs;
    BOOL _mightNotEmitAllOutputs;
    NSArray *_additionalDirectoriesToCreate;
    NSDictionary *_environmentVariables;
    BOOL _wantsBuildSettingsInEnvironment;
    DVTMacroDefinitionTable *_overridingMacros;
    NSArray *_requiredComponents;
    BOOL _shouldSynthesizeGlobalBuildRule;
    NSArray *_buildPhasesForWhichToSynthesizeBuildRules;
    NSArray *_inputFileGroupings;
    BOOL _serializeCommands;
    NSString<DVTMacroExpansion> *_dependencyInfoFile;
    NSString<DVTMacroExpansion> *_executionDescription;
    NSString<DVTMacroExpansion> *_progressDescription;
    BOOL _isUnsafeToInterrupt;
    unsigned long long _messageLimit;
    NSIndexSet *_successExitCodes;
}

+ (id)unionedDefaultMacrosForAllToolsInDomain:(id)arg1;
+ (unsigned long long)defaultMessageLimit;
+ (void)createDefaultCommandLineToolSpecificationRegistry;
+ (id)specificationRegistryName;
+ (id)specificationTypePathExtensions;
+ (id)localizedSpecificationTypeName;
+ (id)specificationType;
+ (Class)specificationTypeBaseClass;
+ (void)initialize;
@property(readonly, nonatomic) BOOL isUnsafeToInterrupt; // @synthesize isUnsafeToInterrupt=_isUnsafeToInterrupt;
@property(readonly, nonatomic) NSString<DVTMacroExpansion> *dependencyInfoFile; // @synthesize dependencyInfoFile=_dependencyInfoFile;
@property(readonly) NSIndexSet *successExitCodes; // @synthesize successExitCodes=_successExitCodes;
@property(readonly) unsigned long long messageLimit; // @synthesize messageLimit=_messageLimit;
// - (void).cxx_destruct;
- (id)instantiatedCommandResultsPostprocessorForCommand:(id)arg1;
- (unsigned long long)concurrentExecutionCountWithMacroExpansionScope:(id)arg1;
- (id)createCommandsforInputs:(id)arg1 withMacroExpansionScope:(id)arg2;
- (id)discoveredToolInfoWithMacroExpansionScope:(id)arg1;
- (id)findExecutable:(id)arg1 withMacroExpansionScope:(id)arg2;
- (id)doSpecialDependencySetupForCommand:(id)arg1 withInputNodes:(id)arg2 withMacroExpansionScope:(id)arg3;
- (id)outputPathFromInputNodes:(id)arg1 withMacroExpansionScope:(id)arg2;
- (id)executablePathWithMacroExpansionScope:(id)arg1;
- (void)checkDeploymentTargetAgainstSDKWithMacroExpansionScope:(id)arg1;
- (BOOL)isAppleProvidedSpecification;
- (BOOL)shouldIncludeInUnionedToolDefaults;
- (void)_addNameToDefaultValueMappingsToMacroDefinitionTable:(id)arg1;
- (id)identifiersOfBuildPhasesForWhichToSynthesizeBuildRules;
- (BOOL)shouldSynthesizeGlobalBuildRule;
- (id)messageFormatForFailingCommandWithNoErrors;
- (CDUnknownBlockType)processDependencyInfoFileIfNecessaryForCommand:(id)arg1 commandInvocationSucceeded:(BOOL)arg2;
- (BOOL)parseDependencyInfoFileAtPath:(id)arg1 usingBlock:(CDUnknownBlockType)arg2 errorPtr:(id *)arg3;
- (BOOL)shouldProcessDependencyInfoFileWithMacroExpansionScope:(id)arg1;
- (id)instantiatedCommandOutputParserForCommand:(id)arg1 withLogSectionRecorder:(id)arg2;
- (id)severityBasedMessageCategoryInfoForExecutablePath:(id)arg1;
- (id)messageCategoryInfoForExecutablePath:(id)arg1;
- (BOOL)commandsNeedToRecomputeSignatureOnEveryBuild;
- (id)extraSignatureInfoForCommand:(id)arg1;
- (id)arrayByRemovingArgumentsNotAffectingOutputFileFromArray:(id)arg1;
- (BOOL)areOutputFilesAffectedByEnvironmentVariable:(id)arg1;
- (BOOL)areOutputFilesAffectedByCommandLineArgument:(id)arg1;
- (id)commandLineForAutogeneratedOptionsWithMacroExpansionScope:(id)arg1;
- (id)hashStringForCommandLineComponents:(id)arg1 inputFilePaths:(id)arg2 withMacroExpansionScope:(id)arg3;
- (id)inputFileGroupings;
- (id)requiredComponents;
- (void)setDefaultDeploymentTarget:(id)arg1 forName:(id)arg2;
- (id)defaultDeploymentTargetNamed:(id)arg1;
- (id)commandOutputParserClassesOrParseRules;
- (Class)commandInvocationClass;
- (id)overridingMacros;
- (void)_addPerToolOverridingMacrosToMacroDefinitionTable:(id)arg1;
- (void)_addToDefaultMacros:(id)arg1;
- (id)progressDescription;
- (id)executionDescription;
- (id)environmentVariables;
- (id)additionalDirectoriesToCreate;
- (BOOL)shouldRemoveOutputsOnFailure;
- (BOOL)mightNotEmitAllOutputs;
- (BOOL)dontProcessOutputs;
- (BOOL)outputsAreProducts;
- (id)outputPaths;
- (id)outputDir;
- (BOOL)supportsArchitecture:(id)arg1 inDomain:(id)arg2 allArchitectures:(id)arg3 withMacroExpansionScope:(id)arg4;
- (BOOL)supportsArchitecture:(id)arg1 inDomain:(id)arg2 withMacroExpansionScope:(id)arg3;
- (BOOL)shouldProcessInputFilePath:(id)arg1 ofFileType:(id)arg2 withMacroExpansionScope:(id)arg3 errorString:(id *)arg4;
- (BOOL)acceptsInputFileType:(id)arg1;
- (id)versionWithMacroExpansionScope:(id)arg1;
- (id)supportedArchitecturesInDomain:(id)arg1 withMacroExpansionScope:(id)arg2;
- (id)generatedInfoPlistContentFilePath;
- (BOOL)shouldDeeplyStatInputDirectories;
- (id)additionalInputFiles;
- (id)inputFileTypes;
- (id)ruleLineTemplate;
- (id)commandIdentifierTemplate;
- (id)fallbackToolSpecificationsForSDK:(id)arg1;
- (id)fallbackToolSpecificationsForDomain:(id)arg1;
- (id)path;
- (id)name;
- (id)initWithPropertyListDictionary:(id)arg1 inDomain:(id)arg2;

@end

