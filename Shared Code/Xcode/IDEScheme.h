//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk.sdk
//

#include "Shared.h"

#import "DVTInvalidation-Protocol.h"

@class DVTCustomDataSpecifier, DVTDelayedInvocation, DVTObservingToken, DVTStackBacktrace, IDEAnalyzeSchemeAction, IDEArchiveSchemeAction, IDEBuildSchemeAction, IDEContainer, IDEEntityIdentifier, IDEInstallSchemeAction, IDEIntegrateSchemeAction, IDELaunchSchemeAction, IDEProfileSchemeAction, IDERunContextManager, IDERunnable, IDESchemeOrderedWorkspaceNotificationManager, IDETestSchemeAction, NSArray, NSData, NSError, NSNumber, NSString;
@protocol IDECustomDataStoring;

@interface IDEScheme : NSObject <DVTInvalidation>
{
    IDEBuildSchemeAction *_buildSchemeAction;
    IDETestSchemeAction *_testSchemeAction;
    IDELaunchSchemeAction *_launchSchemeAction;
    IDEArchiveSchemeAction *_archiveSchemeAction;
    IDEProfileSchemeAction *_profileSchemeAction;
    IDEAnalyzeSchemeAction *_analyzeSchemeAction;
    IDEInstallSchemeAction *_installSchemeAction;
    IDEIntegrateSchemeAction *_integrateSchemeAction;
    NSString *_lastUpgradeVersion;
    NSString *_cachedLastUpgradeVersion;
    BOOL _hasRunUpgradeCheck;
    BOOL _wasUpgraded;
    IDERunnable *_oldFormatArchivedRunnable;
    IDERunContextManager *_runContextManager;
    IDEContainer<IDECustomDataStoring> *_customDataStoreContainer;
    DVTCustomDataSpecifier *_customDataSpecifier;
    NSArray *_availableRunDestinations;
    BOOL _isShown;
    unsigned long long _orderHint;
    BOOL _dataStoreClosed;
    BOOL _deferredSaveScheduled;
    BOOL _registeredForIsBuildableNotifications;
    NSNumber *_isArchivable;
    id _isArchivableNotificationToken;
    NSNumber *_isInstallable;
    id _isInstallableNotificationToken;
    id _buildablesToken;
    BOOL _hasUnsupportedArchiveData;
    DVTDelayedInvocation *_runDestinationInvalidationScheduler;
    BOOL _transient;
    BOOL _persisted;
    BOOL _wasCreatedForAppExtension;
    BOOL _schemeRunnableRunsDirectlyOnPairedProxyDevice;
    BOOL _runDestinationInvalidationSuspended;
    BOOL _runDestinationInvalidationPending;
    IDEEntityIdentifier *_schemeIdentifier;
    NSError *_loadError;
    DVTObservingToken *_workspaceReferenceContainersObservingToken;
    IDESchemeOrderedWorkspaceNotificationManager *_orderedWorkspaceNotificationManager;
}

+ (id)_buildParametersForPurpose:(long long)arg1 schemeCommand:(id)arg2 configurationName:(id)arg3 workspaceArena:(id)arg4 overridingProperties:(id)arg5 activeRunDestination:(id)arg6 activeArchitecture:(id)arg7;
+ (BOOL)automaticallyNotifiesObserversOfOrderHint;
+ (BOOL)automaticallyNotifiesObserversOfIsShown;
+ (id)keyPathsForValuesAffectingDisambiguatedName;
+ (BOOL)automaticallyNotifiesObserversOfCustomDataStoreContainer;
+ (id)keyPathsForValuesAffectingIntegratable;
+ (id)keyPathsForValuesAffectingTestable;
+ (id)keyPathsForValuesAffectingAnalyzable;
+ (id)keyPathsForValuesAffectingProfilable;
+ (id)keyPathsForValuesAffectingRunnable;
+ (id)schemeFromXMLData:(id)arg1 withRunContextManager:(id)arg2 customDataStoreContainer:(id)arg3 customDataSpecifier:(id)arg4 isShown:(BOOL)arg5 orderHint:(unsigned long long)arg6 error:(id *)arg7;
+ (id)schemeWithRunContextManager:(id)arg1 customDataStoreContainer:(id)arg2 customDataSpecifier:(id)arg3;
+ (unsigned long long)assertionBehaviorForKeyValueObservationsAtEndOfEvent;
+ (unsigned long long)assertionBehaviorAfterEndOfEventForSelector:(SEL)arg1;
+ (void)initialize;
@property(retain) IDESchemeOrderedWorkspaceNotificationManager *orderedWorkspaceNotificationManager; // @synthesize orderedWorkspaceNotificationManager=_orderedWorkspaceNotificationManager;
@property(getter=isRunDestinationInvalidationPending) BOOL runDestinationInvalidationPending; // @synthesize runDestinationInvalidationPending=_runDestinationInvalidationPending;
@property(nonatomic, getter=isRunDestinationInvalidationSuspended) BOOL runDestinationInvalidationSuspended; // @synthesize runDestinationInvalidationSuspended=_runDestinationInvalidationSuspended;
@property(retain) DVTObservingToken *workspaceReferenceContainersObservingToken; // @synthesize workspaceReferenceContainersObservingToken=_workspaceReferenceContainersObservingToken;
@property(readonly) BOOL schemeRunnableRunsDirectlyOnPairedProxyDevice; // @synthesize schemeRunnableRunsDirectlyOnPairedProxyDevice=_schemeRunnableRunsDirectlyOnPairedProxyDevice;
@property BOOL wasCreatedForAppExtension; // @synthesize wasCreatedForAppExtension=_wasCreatedForAppExtension;
@property(retain) NSError *loadError; // @synthesize loadError=_loadError;
@property(copy, nonatomic) IDEEntityIdentifier *schemeIdentifier; // @synthesize schemeIdentifier=_schemeIdentifier;
@property(readonly) DVTCustomDataSpecifier *customDataSpecifier; // @synthesize customDataSpecifier=_customDataSpecifier;
@property(retain, nonatomic) IDEContainer<IDECustomDataStoring> *customDataStoreContainer; // @synthesize customDataStoreContainer=_customDataStoreContainer;
@property(retain) IDERunContextManager *runContextManager; // @synthesize runContextManager=_runContextManager;
@property(nonatomic, getter=isPersisted) BOOL persisted; // @synthesize persisted=_persisted;
@property(getter=isTransient) BOOL transient; // @synthesize transient=_transient;
@property BOOL wasUpgraded; // @synthesize wasUpgraded=_wasUpgraded;
@property BOOL hasRunUpgradeCheck; // @synthesize hasRunUpgradeCheck=_hasRunUpgradeCheck;
@property(copy) NSString *lastUpgradeVersion; // @synthesize lastUpgradeVersion=_lastUpgradeVersion;
@property(copy) NSString *cachedLastUpgradeVersion; // @synthesize cachedLastUpgradeVersion=_cachedLastUpgradeVersion;
@property(retain) IDEInstallSchemeAction *installSchemeAction; // @synthesize installSchemeAction=_installSchemeAction;
@property(retain) IDEIntegrateSchemeAction *integrateSchemeAction; // @synthesize integrateSchemeAction=_integrateSchemeAction;
@property(retain) IDEAnalyzeSchemeAction *analyzeSchemeAction; // @synthesize analyzeSchemeAction=_analyzeSchemeAction;
@property(retain) IDEProfileSchemeAction *profileSchemeAction; // @synthesize profileSchemeAction=_profileSchemeAction;
@property(retain) IDEArchiveSchemeAction *archiveSchemeAction; // @synthesize archiveSchemeAction=_archiveSchemeAction;
@property(retain) IDELaunchSchemeAction *launchSchemeAction; // @synthesize launchSchemeAction=_launchSchemeAction;
@property(retain) IDETestSchemeAction *testSchemeAction; // @synthesize testSchemeAction=_testSchemeAction;
@property(retain) IDEBuildSchemeAction *buildSchemeAction; // @synthesize buildSchemeAction=_buildSchemeAction;
// - (void).cxx_destruct;
- (void)addBuildableProductRunnable:(id)arg1 fromXMLUnarchiver:(id)arg2;
- (void)addPathRunnable:(id)arg1 fromXMLUnarchiver:(id)arg2;
- (void)addLaunchPhase:(id)arg1 fromXMLUnarchiver:(id)arg2;
- (void)addTestPhase:(id)arg1 fromXMLUnarchiver:(id)arg2;
- (void)addBuildPhase:(id)arg1 fromXMLUnarchiver:(id)arg2;
- (void)addArchiveAction:(id)arg1 fromXMLUnarchiver:(id)arg2;
- (void)addInstallAction:(id)arg1 fromXMLUnarchiver:(id)arg2;
- (void)addIntegrateAction:(id)arg1 fromXMLUnarchiver:(id)arg2;
- (void)addAnalyzeAction:(id)arg1 fromXMLUnarchiver:(id)arg2;
- (void)addProfileAction:(id)arg1 fromXMLUnarchiver:(id)arg2;
- (void)addLaunchAction:(id)arg1 fromXMLUnarchiver:(id)arg2;
- (void)addTestAction:(id)arg1 fromXMLUnarchiver:(id)arg2;
- (void)addBuildAction:(id)arg1 fromXMLUnarchiver:(id)arg2;
- (void)setWasCreatedForAppExtensionFromUTF8String:(char *)arg1 fromXMLUnarchiver:(id)arg2;
- (void)setLastUpgradeVersionFromUTF8String:(char *)arg1 fromXMLUnarchiver:(id)arg2;
- (void)dvt_encodeRelationshipsWithXMLArchiver:(id)arg1 version:(id)arg2;
- (void)dvt_encodeAttributesWithXMLArchiver:(id)arg1 version:(id)arg2;
@property(readonly) NSData *xmlData;
- (BOOL)_executionActionsNeedCurrentArchiveVersion;
- (void)dvt_awakeFromXMLUnarchiver:(id)arg1;
- (id)_groupAndImposeDependenciesForOrderedOperations:(id)arg1;
- (id)_buildOperationGroupForSchemeOperationParameters:(id)arg1 buildParameters:(id)arg2 buildLog:(id)arg3 dontActuallyRunCommands:(BOOL)arg4 restorePersistedBuildResults:(BOOL)arg5 schemeActionRecord:(id)arg6 overridingBuildables:(id)arg7 error:(id *)arg8;
- (id)_cleanOperationGroupForExecutionEnvironment:(id)arg1 orderedBuildables:(id)arg2 buildConfiguration:(id)arg3 buildLog:(id)arg4 overridingProperties:(id)arg5 activeRunDestination:(id)arg6 schemeActionRecord:(id)arg7 error:(id *)arg8;
- (id)_executionOperationForSchemeOperationParameters:(id)arg1 build:(BOOL)arg2 onlyBuild:(BOOL)arg3 buildParameters:(id)arg4 title:(id)arg5 buildLog:(id)arg6 dontActuallyRunCommands:(BOOL)arg7 restorePersistedBuildResults:(BOOL)arg8 deviceAvailableChecker:(CDUnknownBlockType)arg9 error:(id *)arg10 actionCallbackBlock:(CDUnknownBlockType)arg11;
- (id)buildParametersForTask:(long long)arg1 executionEnvironment:(id)arg2 buildPurpose:(long long)arg3 schemeCommand:(id)arg4 destination:(id)arg5 overridingProperties:(id)arg6 overridingBuildConfiguration:(id)arg7 overridingTestingSpecifiers:(id)arg8;
- (id)overridingBuildSettingsForSchemeCommand:(id)arg1 runDestination:(id)arg2;
- (id)startedOperationForSchemeOperationParameters:(id)arg1 deviceAvailableChecker:(CDUnknownBlockType)arg2 error:(id *)arg3 completionBlock:(CDUnknownBlockType)arg4;
- (id)schemeOperationForSchemeOperationParameters:(id)arg1 buildLog:(id)arg2 overridingProperties:(id)arg3 overridingBuildConfiguration:(id)arg4 dontActuallyRunCommands:(BOOL)arg5 restorePersistedBuildResults:(BOOL)arg6 error:(id *)arg7 completionBlock:(CDUnknownBlockType)arg8;
- (id)schemeOperationForSchemeOperationParameters:(id)arg1 buildLog:(id)arg2 overridingProperties:(id)arg3 overridingBuildConfiguration:(id)arg4 dontActuallyRunCommands:(BOOL)arg5 restorePersistedBuildResults:(BOOL)arg6 deviceAvailableChecker:(CDUnknownBlockType)arg7 error:(id *)arg8 completionBlock:(CDUnknownBlockType)arg9;
- (id)computeNameForCommand:(id)arg1 task:(long long)arg2;
- (id)_cleanOperationWithExecutionContext:(id)arg1 destination:(id)arg2 overridingProperties:(id)arg3 schemeCommand:(id)arg4 invocationRecord:(id)arg5 error:(id *)arg6;
- (void)_reportExecutionOperationForParameters:(id)arg1 shouldBuild:(BOOL)arg2 onlyBuild:(BOOL)arg3;
- (id)_addActionRecordToInvocationRecord:(id)arg1 shouldBuild:(BOOL)arg2 onlyBuild:(BOOL)arg3 schemeCommand:(id)arg4 runDestination:(id)arg5 title:(id)arg6;
- (void)_updateOrderHint:(unsigned long long)arg1;
@property unsigned long long orderHint;
- (void)_updateIsShown:(BOOL)arg1;
@property BOOL isShown;
@property BOOL isShared;
@property(readonly) NSString *disambiguatedName;
@property(copy) NSString *name;
- (void)_primitiveSetCustomDataStoreContainer:(id)arg1;
- (void)_updateCustomDataStoreContainer:(id)arg1 andSpecifier:(id)arg2;
- (void)_actuallyInvalidateAvailableRunDestinations;
- (void)_invalidateAvailableRunDestinations;
- (void)immediatelyInvalidateAvailableRunDestinations;
@property(readonly) NSArray *availableRunDestinations;
- (BOOL)schemeRunnableRunsOnPairedProxyDevice;
@property(readonly) BOOL schemeRunnableRequiresPairedProxyDevice;
- (void)buildConfigurationDidChange:(id)arg1;
- (id)buildParametersForSchemeCommand:(id)arg1 destination:(id)arg2;
- (id)buildParametersForSchemeCommand:(id)arg1 buildable:(id)arg2;
- (id)buildParametersForSchemeCommand:(id)arg1;
- (id)buildParametersForLaunchSchemeCommandAndBuildable:(id)arg1;
- (id)buildConfigurationForSchemeCommand:(id)arg1;
- (id)buildablesIncludingDependenciesForSchemeCommand:(id)arg1;
- (id)buildablesForSchemeCommand:(id)arg1;
- (id)runnablePathForSchemeCommand:(id)arg1 destination:(id)arg2;
- (id)schemeActionForSchemeCommand:(id)arg1;
- (BOOL)hasRunnableForBuildableProduct:(id)arg1;
@property(readonly, getter=isInstallable) BOOL installable;
@property(readonly, getter=isIntegratable) BOOL integratable;
@property(readonly, getter=isArchivable) BOOL archivable;
@property(readonly, getter=isTestable) BOOL testable;
@property(readonly, getter=isAnalyzable) BOOL analyzable;
@property(readonly, getter=isProfilable) BOOL profilable;
@property(readonly, getter=isRunnable) BOOL runnable;
@property(readonly, getter=isBuildable) BOOL buildable;
- (void)primitiveInvalidate;
@property(readonly) BOOL isClosed;
- (void)customDataStoreContainerClosing:(id)arg1;
- (void)performDelayedSave:(id)arg1;
- (void)markSchemeDirtyFromAutomaticChange;
- (void)markSchemeDirtyFromUserChange;
- (void)resolveBuildablesFromImport;
@property(readonly, copy) NSString *description;
- (id)initFromUnarchiver:(BOOL)arg1 runContextManager:(id)arg2 customDataStoreContainer:(id)arg3 customDataSpecifier:(id)arg4 isShown:(BOOL)arg5 orderHint:(unsigned long long)arg6;
- (void)_createDefaultSchemeActions;
- (id)buildDirectoriesForSchemeCommand:(id)arg1;
- (BOOL)ideIndex_containsBlueprint:(id)arg1;

// Remaining properties
@property(retain) DVTStackBacktrace *creationBacktrace;
@property(readonly, copy) NSString *debugDescription;
@property(readonly) DVTStackBacktrace *invalidationBacktrace;
@property(readonly) Class superclass;
@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

