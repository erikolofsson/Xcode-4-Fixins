//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//

#include "Shared.h"

#import "IDEXMLPackageContainer.h"

#import "IDEClientTracking-Protocol.h"
#import "IDEIntegrityLogDataSource-Protocol.h"

@class DVTFilePath, DVTObservingToken, DVTStackBacktrace, DVTTimeSlicedMainThreadWorkQueue, IDEActivityLogSection, IDEBatchFindManager, IDEBreakpointManager, IDEConcreteClientTracker, IDEContainer, IDEContainerQuery, IDEDeviceInstallWorkspaceMonitor, IDEExecutionEnvironment, IDEIndex, IDEIssueManager, IDELocalizationManager, IDELogManager, IDERefactoring, IDERunContextManager, IDESourceControlWorkspaceMonitor, IDETestManager, IDETextIndex, IDEWorkspaceArena, IDEWorkspaceSharedSettings, IDEWorkspaceSnapshotManager, IDEWorkspaceUpgradeTasksController, IDEWorkspaceUserSettings, NSArray, NSDictionary, NSHashTable, NSMapTable, NSMutableArray, NSMutableOrderedSet, NSMutableSet, NSSet, NSString;
@protocol IDEActiveRunContextStoring, IDEContinuousIntegrationBotMonitor, IDECustomDataStoring, IDEWorkspaceDelegate;

@interface IDEWorkspace : IDEXMLPackageContainer <IDEClientTracking, IDEIntegrityLogDataSource>
{
    NSString *_untitledName;
    IDEWorkspaceArena *_workspaceArena;
    DVTFilePath *_headerMapFilePath;
    IDEExecutionEnvironment *_executionEnvironment;
    IDEContainerQuery *_containerQuery;
    DVTObservingToken *_containerQueryObservingToken;
    NSMutableSet *_referencedContainers;
    NSHashTable *_fileRefsWithContainerLoadingIssues;
    IDEActivityLogSection *_containerLoadingIntegrityLog;
    NSMutableSet *_customDataStores;
    IDEWorkspaceUserSettings *_userSettings;
    IDEWorkspaceSharedSettings *_sharedSettings;
    NSMapTable *_blueprintProviderObserverMap;
    NSMutableSet *_referencedBlueprints;
    BOOL _initialContainerScanComplete;
    NSMutableArray *_referencedRunnableBuildableProducts;
    IDERunContextManager *_runContextManager;
    IDELogManager *_logManager;
    IDEIssueManager *_issueManager;
    IDEBreakpointManager *_breakpointManager;
    IDEBatchFindManager *_batchFindManager;
    IDETestManager *_testManager;
    IDEContainerQuery *_indexableSourceQuery;
    DVTObservingToken *_indexableSourceQueryObservingToken;
    NSMutableArray *_observedIndexableSources;
    IDEContainerQuery *_indexableFileQuery;
    DVTObservingToken *_indexableFileQueryObservingToken;
    id _indexableFileUpdateNotificationToken;
    IDEIndex *_index;
    IDERefactoring *_refactoring;
    NSMapTable *_fileRefsToResolvedFilePaths;
    DVTTimeSlicedMainThreadWorkQueue *_fileReferenceForIndexingQueue;
    IDETextIndex *_textIndex;
    IDEDeviceInstallWorkspaceMonitor *_deviceInstallWorkspaceMonitor;
    IDESourceControlWorkspaceMonitor *_sourceControlWorkspaceMonitor;
    IDEWorkspaceSnapshotManager *_snapshotManager;
    IDELocalizationManager *_localizationManager;
    DVTFilePath *_wrappedContainerPath;
    IDEContainer<IDECustomDataStoring> *_wrappedContainer;
    DVTObservingToken *_wrappedContainerValidObservingToken;
    DVTObservingToken *_newWrappedContainerObservingToken;
    NSHashTable *_pendingReferencedFileReferences;
    NSHashTable *_pendingReferencedContainers;
    IDEConcreteClientTracker *_clientTracker;
    NSHashTable *_fileReferencesForProblem8727051;
    DVTObservingToken *_finishedLoadingObservingToken;
    NSDictionary *_Problem9887530_preferredStructurePaths;
    BOOL _simpleFilesFocused;
    id _openingPerformanceMetricIdentifier;
    DVTStackBacktrace *_finishedLoadingBacktrace;
    NSMutableOrderedSet *_initialOrderedReferencedBlueprintProviders;
    BOOL _hasPostedIndexingRegistrationBatchNotification;
    BOOL _didFinishLoadingFirstStage;
    BOOL _finishedLoading;
    BOOL _postLoadingPerformanceMetricsAllowed;
    BOOL _willInvalidate;
    BOOL _pendingFileReferencesAndContainers;
    BOOL _didProcessFileReferencesForProblem8727051;
    BOOL _isCleaningBuildFolder;
    BOOL _indexingAndRefactoringRestartScheduled;
    BOOL _indexCreationInFlight;
    BOOL _didFinishBuildingInitialBlueprintProviderOrderedSet;
    NSMapTable *_pendingExecutionNotificationTokens;
    BOOL _hostsOnlyWrappedContainer;
    BOOL _hostsOnlyXcode3Project;
    BOOL _hostsOnlyPlayground;
    BOOL _isPotentiallyClosing;
    id <IDEContinuousIntegrationBotMonitor> _xcs2WorkspaceBotMonitor;
    long long _indexGenerationCounter;
    id <IDEActiveRunContextStoring> _activeRunContextStore;
    IDEWorkspaceUpgradeTasksController *_deferredUpgradeTasksController;
}

+ (BOOL)_shouldTrackReadOnlyStatus;
+ (id)keyPathsForValuesAffectingRepresentingCustomDataStore;
+ (id)keyPathsForValuesAffectingHostsOnlyPlayground;
+ (id)keyPathsForValuesAffectingHostsOnlyXcode3Project;
+ (id)keyPathsForValuesAffectingRepresentingTitle;
+ (id)keyPathsForValuesAffectingRepresentingFilePath;
+ (id)keyPathsForValuesAffectingName;
+ (id)_workspaceFileExtension;
+ (id)containerTypeDisplayName;
+ (id)containerFileDataType;
+ (id)xmlArchiveFileName;
+ (id)rootElementName;
+ (BOOL)_shouldLoadUISubsystems;
+ (BOOL)automaticallyNotifiesObserversOfFileRefsWithContainerLoadingIssues;
+ (unsigned long long)assertionBehaviorForKeyValueObservationsAtEndOfEvent;
+ (void)initialize;
@property(retain) IDEWorkspaceUpgradeTasksController *deferredUpgradeTasksController; // @synthesize deferredUpgradeTasksController=_deferredUpgradeTasksController;
@property(nonatomic) BOOL pendingFileReferencesAndContainers; // @synthesize pendingFileReferencesAndContainers=_pendingFileReferencesAndContainers;
@property(retain) id <IDEActiveRunContextStoring> activeRunContextStore; // @synthesize activeRunContextStore=_activeRunContextStore;
@property(readonly, nonatomic) long long indexGenerationCounter; // @synthesize indexGenerationCounter=_indexGenerationCounter;
@property(nonatomic) BOOL isPotentiallyClosing; // @synthesize isPotentiallyClosing=_isPotentiallyClosing;
@property BOOL isCleaningBuildFolder; // @synthesize isCleaningBuildFolder=_isCleaningBuildFolder;
@property BOOL hostsOnlyPlayground; // @synthesize hostsOnlyPlayground=_hostsOnlyPlayground;
@property BOOL hostsOnlyXcode3Project; // @synthesize hostsOnlyXcode3Project=_hostsOnlyXcode3Project;
@property BOOL hostsOnlyWrappedContainer; // @synthesize hostsOnlyWrappedContainer=_hostsOnlyWrappedContainer;
@property(readonly) DVTFilePath *wrappedContainerPath; // @synthesize wrappedContainerPath=_wrappedContainerPath;
@property(readonly, nonatomic) BOOL postLoadingPerformanceMetricsAllowed; // @synthesize postLoadingPerformanceMetricsAllowed=_postLoadingPerformanceMetricsAllowed;
@property(nonatomic) BOOL finishedLoading; // @synthesize finishedLoading=_finishedLoading;
@property(retain, nonatomic) IDEWorkspaceSharedSettings *sharedSettings; // @synthesize sharedSettings=_sharedSettings;
@property(retain, nonatomic) IDEWorkspaceUserSettings *userSettings; // @synthesize userSettings=_userSettings;
@property(retain, nonatomic) id <IDEContinuousIntegrationBotMonitor> xcs2WorkspaceBotMonitor; // @synthesize xcs2WorkspaceBotMonitor=_xcs2WorkspaceBotMonitor;
@property(retain) IDESourceControlWorkspaceMonitor *sourceControlWorkspaceMonitor; // @synthesize sourceControlWorkspaceMonitor=_sourceControlWorkspaceMonitor;
@property(retain) IDEDeviceInstallWorkspaceMonitor *deviceInstallWorkspaceMonitor; // @synthesize deviceInstallWorkspaceMonitor=_deviceInstallWorkspaceMonitor;
@property(readonly) IDERefactoring *refactoring; // @synthesize refactoring=_refactoring;
@property(readonly) IDETextIndex *textIndex; // @synthesize textIndex=_textIndex;
@property(retain) IDEIndex *index; // @synthesize index=_index;
@property(retain) IDERunContextManager *runContextManager; // @synthesize runContextManager=_runContextManager;
@property BOOL initialContainerScanComplete; // @synthesize initialContainerScanComplete=_initialContainerScanComplete;
@property(retain, nonatomic) IDEWorkspaceArena *workspaceArena; // @synthesize workspaceArena=_workspaceArena;
// - (void).cxx_destruct;
- (id)buildableProductsForBaseName:(id)arg1;
- (void)_handleIndexablesChange:(id)arg1;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
- (void)didCreateIndex:(id)arg1;
- (void)initializeIndexAndRefactoring:(id)arg1;
- (void)_scheduleWorkspaceUpgradeTasksController:(id)arg1;
- (void)_setupWorkspaceUpgradeTasksController;
- (void)_setupSourceControlWorkspaceMonitorIfNeeded;
- (void)_initializeSourceControlWorkspaceMonitor;
- (void)_setupDeviceInstallWorkspaceMonitor;
- (void)beginTextIndexing;
- (id)tearDownIndexAndRefactoring;
- (void)_restartIndexingAndRefactoring;
- (void)_scheduleIndexingAndRefactoringRestart;
- (void)_handleIndexableFilesChange:(id)arg1;
- (void)_updateIndexableFiles:(id)arg1;
- (id)_fileRefsToResolvedFilePaths;
- (void)_handleIndexableSourcesChange:(id)arg1;
- (void)primitiveInvalidate;
@property(readonly) IDEContainer<IDECustomDataStoring> *representingCustomDataStore;
- (void)_updateWrappedContainer;
- (void)_setWrappedContainer:(id)arg1;
@property(readonly, getter=isSimpleFilesFocused) BOOL simpleFilesFocused;
- (void)_setSimpleFilesFocused:(BOOL)arg1;
- (void)_primitiveSetSimpleFilesFocused:(BOOL)arg1;
- (void)setSimpleFilesFocused:(BOOL)arg1;
@property(readonly) NSString *representingTitle;
@property(readonly) DVTFilePath *representingFilePath;
@property(retain) IDEExecutionEnvironment *executionEnvironment;
- (void)_setupExecutionEnvironment;
- (id)_subitemsForUnarchivedSubitems:(id)arg1;
- (float)maxSupportedArchiveVersion;
- (float)archiveVersion;
- (id)displayName;
@property(readonly) NSString *name;
@property(readonly) IDELocalizationManager *localizationManager;
@property(retain) IDETestManager *testManager; // @dynamic testManager;
- (void)setBatchFindManager:(IDEBatchFindManager *)arg1;
@property(readonly) IDEBatchFindManager *batchFindManager;
@property(retain) IDEWorkspaceSnapshotManager *snapshotManager;
@property(retain) IDEBreakpointManager *breakpointManager; // @dynamic breakpointManager;
@property(readonly) IDEIssueManager *issueManager;
- (void)_setupIssueManagerIfNeeded;
@property(readonly) IDELogManager *logManager;
- (void)_setupLogManagerIfNeeded;
- (id)blueprintsContainingFilePaths:(id)arg1;
@property(readonly) NSArray *notificationPayloadFileReferences;
@property(readonly) NSSet *customDataStores;
@property(readonly) NSSet *referencedRunnableBuildableProducts;
@property(readonly) NSSet *referencedBlueprints;
- (id)containerGraphOrderForBlueprintProviders:(id)arg1;
@property(readonly) NSSet *referencedBlueprintProviders;
@property(readonly) NSSet *referencedContainers;
- (void)_referencedContainersDidUpdate;
- (void)invokeChangingValueForKey:(id)arg1 fromSet:(id)arg2 toSet:(id)arg3 block:(CDUnknownBlockType)arg4;
- (void)_referencedBlueprintsDidUpdateForProvider:(id)arg1;
- (id)buildableProductsForProductWithModuleName:(id)arg1;
- (id)buildableProductsForProductName:(id)arg1;
- (void)_setupHeaderMapPath;
- (void)_setupContainerQueries;
- (void)_addBlueprintProviderToOrderedSet:(id)arg1;
- (id)_Problem9887530_preferredStructurePathForContainerAtPath:(id)arg1;
- (id)_Problem9887530_preferredStructurePaths;
- (id)_Problem9887530_preferredStructurePathsForContainerToContainerFileReferences:(id)arg1;
- (id)_Problem9887530_wrappedContainerFileReferences:(id)arg1 forPath:(id)arg2;
- (void)_processFileReferencesForProblem8727051;
- (void)_addFileReferenceForProblem8727051:(id)arg1;
- (void)cancelTrackedClients;
- (id)clientsNotSupportingCancellation;
- (id)clientsRequiringCancellationPrompt;
- (id)registerUncancellableClientWithName:(id)arg1;
- (id)registerClientWithName:(id)arg1 promptForCancellation:(BOOL)arg2 cancellationBlock:(CDUnknownBlockType)arg3;
@property(readonly) IDEConcreteClientTracker *clientTracker;
- (BOOL)_cancelOngoingBuildWithCompletionBlockIfNeeded:(CDUnknownBlockType)arg1;
- (void)_setupBuildCompletedNotificationForExecutionEnvironment:(id)arg1 completionBlock:(CDUnknownBlockType)arg2;
- (BOOL)setContainerFilePath:(id)arg1 error:(id *)arg2;
- (BOOL)_setContainerFilePath:(id)arg1 upgradeToWorkspace:(BOOL)arg2 error:(id *)arg3;
- (void)_changeContainerFilePath:(id)arg1 inContext:(id)arg2 upgradeToWorkspace:(BOOL)arg3;
- (void)_changeContainerFilePath:(id)arg1 inContext:(id)arg2;
- (BOOL)_configureWrappedWorkspaceWithError:(id *)arg1;
- (id)_wrappingContainerPath;
- (id)_wrappedPlaygroundContainer;
- (void)_setWrappedContainerPath:(id)arg1;
- (id)initWithFilePath:(id)arg1 extension:(id)arg2 workspace:(id)arg3 options:(id)arg4 error:(id *)arg5;
- (void)_buildProductsLocationDidChange;
- (void)_containerDidLoad;
- (void)_checkIfHasFinishedLoading;
- (void)_finishLoadingAsynchronously:(BOOL)arg1 shouldUpgradeFromSimpleFilesFocused:(BOOL)arg2;
- (void)_setupWorkspaceArenaIfNeeded;
- (void)_setUpBotMonitor;
@property(readonly) IDEActivityLogSection *integrityLog;
- (void)analyzeModelIntegrity;
- (void)_setFileRefsWithContainerLoadingIssues:(id)arg1;
- (void)_handleContainerResolutionFailureForFileReference:(id)arg1;
- (void)_clearPendingFileReferencesAndContainerLoadingTokens;
- (void)_removePendingReferencedContainerPath:(id)arg1;
- (void)_addPendingReferencedContainerPath:(id)arg1;
- (void)_removePendingReferencedFileReference:(id)arg1;
- (void)_addPendingReferencedFileReference:(id)arg1;
@property(retain) id <IDEWorkspaceDelegate> workspaceDelegate;
- (id)_openingPerformanceMetricIdentifier;
- (void)dvt_encodeRelationshipsWithXMLArchiver:(id)arg1 version:(id)arg2;
- (void)dvt_encodeAttributesWithXMLArchiver:(id)arg1 version:(id)arg2;
- (void)insertInSdefSupport_symbolicBreakpoints:(id)arg1 atIndex:(unsigned long long)arg2;
- (void)insertInSdefSupport_fileBreakpoints:(id)arg1 atIndex:(unsigned long long)arg2;
- (void)insertInSdefSupport_breakpoints:(id)arg1 atIndex:(unsigned long long)arg2;
- (id)sdefSupport_newXcode3GroupWithProperties:(id)arg1;
- (id)sdefSupport_newXcode3FileReferenceWithProperties:(id)arg1;
- (id)sdefSupport_newSymbolicBreakpointWithProperties:(id)arg1;
- (id)sdefSupport_newRunContextWithProperties:(id)arg1;
- (id)sdefSupport_newProjectForDocument:(id)arg1 withContentsValue:(id)arg2 andProperties:(id)arg3;
- (id)sdefSupport_newItemReferenceWithProperties:(id)arg1;
- (id)sdefSupport_newGroupWithProperties:(id)arg1;
- (id)sdefSupport_newFileReferenceWithProperties:(id)arg1;
- (id)sdefSupport_newFileBreakpointWithProperties:(id)arg1;
- (id)sdefSupport_newBuildMessagesWithProperties:(id)arg1;
- (id)sdefSupport_newBreakpointWithProperties:(id)arg1;
- (id)newScriptingObjectOfClass:(Class)arg1 forValueForKey:(id)arg2 withContentsValue:(id)arg3 properties:(id)arg4;
- (id)sdefSupport_symbolicBreakpointsForDocument:(id)arg1;
- (id)sdefSupport_fileBreakpointsForDocument:(id)arg1;
- (id)sdefSupport_breakpointsForDocument:(id)arg1;
- (void)setSdefSupport_buildFolderName:(id)arg1;
- (id)sdefSupport_buildFolderName;
- (id)ideModelObjectTypeIdentifier;
- (id)patchesDirectoryWrapper;
- (id)patchesDirectory;

// Remaining properties
@property(retain) DVTStackBacktrace *creationBacktrace;
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) DVTStackBacktrace *invalidationBacktrace;
@property(readonly) Class superclass;
@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

