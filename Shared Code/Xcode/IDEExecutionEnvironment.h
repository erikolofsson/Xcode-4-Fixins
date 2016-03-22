//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//

#include "Shared.h"

#import "DVTInvalidation-Protocol.h"

@class DVTStackBacktrace, IDEActivityLogSection, IDEBreakpointManager, IDEBuildOperation, IDEExecutionTracker, IDEInMemoryLogStore, IDELaunchSession, IDELogStore, IDEWorkspace, IDEWorkspaceArena, NSArray, NSCountedSet, NSMapTable, NSMutableArray, NSMutableOrderedSet, NSOperationQueue, NSSet, NSString;
@protocol IDEClientTracking, IDEPreBuildSavingDelegate;

@interface IDEExecutionEnvironment : NSObject <DVTInvalidation>
{
    NSMutableArray *_executionTrackers;
    NSMutableArray *_executionTrackersForDisplay;
    NSMutableOrderedSet *_executedActionInvocationRecords;
    NSMutableArray *_queuedBuildOperationInfos;
    NSCountedSet *_activeBuildLogs;
    IDEBuildOperation *_currentBuildOperation;
    int _buildState;
    int _lastBuildResult;
    unsigned long long _disableSubmissionOfBuildOperationsCount;
    NSString *_disableBuildSubmissionsReason;
    NSMutableArray *_launchSessions;
    NSMapTable *_launchSessionStateObservationTokens;
    NSMapTable *_launchSessionRunnablePIDObservationTokens;
    IDELogStore *_logStore;
    IDEInMemoryLogStore *_interfaceBuilderLogStore;
    NSMapTable *_ibLogsByBuildable;
    BOOL _handlingLaunchSessionStateChange;
    BOOL _settingLaunchSessionForTabChange;
    IDEWorkspace *_workspace;
    IDEExecutionTracker *_currentExecutionTracker;
    IDEWorkspaceArena *_workspaceArena;
    id <IDEClientTracking> _clientTracker;
    IDELaunchSession *_selectedLaunchSession;
    IDELaunchSession *_currentLaunchSession;
    NSMapTable *_productNamesToBuildableProductsMapping;
    NSMapTable *_productNameStemsToBuildableProductsMapping;
    NSMapTable *_productModuleNamesToBuildableProductsMapping;
    id <IDEPreBuildSavingDelegate> _preBuildSavingDelegate;
    NSMapTable *_operationGroupSuboperationObserversByExecutionTracker;
    NSOperationQueue *_operationQueue;
}

+ (BOOL)automaticallyNotifiesObserversOfCurrentLaunchSession;
+ (id)keyPathsForValuesAffectingLatestBuildLog;
+ (id)keyPathsForValuesAffectingLogRecords;
+ (id)keyPathsForValuesAffectingBreakpointManager;
+ (BOOL)automaticallyNotifiesObserversForCurrentExecutionTracker;
+ (unsigned long long)assertionBehaviorForKeyValueObservationsAtEndOfEvent;
+ (void)initialize;
@property(retain) NSOperationQueue *operationQueue; // @synthesize operationQueue=_operationQueue;
@property(retain) NSMapTable *operationGroupSuboperationObserversByExecutionTracker; // @synthesize operationGroupSuboperationObserversByExecutionTracker=_operationGroupSuboperationObserversByExecutionTracker;
@property(retain) id <IDEPreBuildSavingDelegate> preBuildSavingDelegate; // @synthesize preBuildSavingDelegate=_preBuildSavingDelegate;
@property(copy) NSMapTable *productModuleNamesToBuildableProductsMapping; // @synthesize productModuleNamesToBuildableProductsMapping=_productModuleNamesToBuildableProductsMapping;
@property(copy) NSMapTable *productNameStemsToBuildableProductsMapping; // @synthesize productNameStemsToBuildableProductsMapping=_productNameStemsToBuildableProductsMapping;
@property(copy) NSMapTable *productNamesToBuildableProductsMapping; // @synthesize productNamesToBuildableProductsMapping=_productNamesToBuildableProductsMapping;
@property(retain, nonatomic) IDELaunchSession *currentLaunchSession; // @synthesize currentLaunchSession=_currentLaunchSession;
@property(retain, nonatomic) IDELaunchSession *selectedLaunchSession; // @synthesize selectedLaunchSession=_selectedLaunchSession;
@property(retain) id <IDEClientTracking> clientTracker; // @synthesize clientTracker=_clientTracker;
@property(retain) IDEWorkspaceArena *workspaceArena; // @synthesize workspaceArena=_workspaceArena;
@property(retain) IDEExecutionTracker *currentExecutionTracker; // @synthesize currentExecutionTracker=_currentExecutionTracker;
@property(readonly) IDEWorkspace *workspace; // @synthesize workspace=_workspace;
@property(readonly) int lastBuildResult; // @synthesize lastBuildResult=_lastBuildResult;
@property(readonly) int buildState; // @synthesize buildState=_buildState;
@property(readonly) NSArray *queuedBuildOperationInfos; // @synthesize queuedBuildOperationInfos=_queuedBuildOperationInfos;
@property(retain) IDEBuildOperation *currentBuildOperation; // @synthesize currentBuildOperation=_currentBuildOperation;
// - (void).cxx_destruct;
- (id)queuedBuildOperationsDescription;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
- (void)_completeBuildOperation:(id)arg1 andPostLastBuildCompleted:(BOOL)arg2 andPostLastUserInitiatedBuildCompleted:(BOOL)arg3;
- (void)_addMissingErrorForFailedBuildToRecorder:(id)arg1 buildLog:(id)arg2;
- (void)_handleLaunchSession:(id)arg1 stateChange:(id)arg2;
- (void)_setStatusDisplayNameForLaunchSession:(id)arg1;
- (void)_setStatusDisplayNamesForExecutionTracker;
- (void)_noteLaunchSessionTargetOutputStateChanged:(id)arg1;
- (void)_setSelectedLaunchSessionForTabChange:(id)arg1;
- (void)promoteXPCExecutionTrackerForDisplay:(id)arg1;
@property(readonly) NSArray *interfaceBuilderLogs;
@property(readonly) IDEActivityLogSection *latestBuildLog;
@property(readonly, copy) NSArray *logRecords;
- (void)_storeLogForOperation:(id)arg1;
- (id)executeOperation:(id)arg1 withCommandName:(id)arg2 invocationRecord:(id)arg3 error:(id *)arg4;
- (id)executeOperation:(id)arg1 withCommandName:(id)arg2 serviceTier:(int)arg3 invocationRecord:(id)arg4 error:(id *)arg5;
- (void)_startNextQueuedBuildOperationIfNecessary;
- (void)_addSuboperationObservationToken:(id)arg1 forExecutionTracker:(id)arg2;
- (void)_startOperationForTracker:(id)arg1 commandName:(id)arg2 operationIncludesBuild:(BOOL)arg3;
- (void)_handleRunOperation:(id)arg1 addExecutionTrackerToDisplayList:(char *)arg2;
@property(readonly) BOOL canSubmitBuildOperations;
- (void)enableSubmissionOfBuildOperationsWithReason:(id)arg1;
- (void)disableSubmissionOfBuildOperationsWithReason:(id)arg1;
@property(readonly) int currentBuildOperationServiceTier;
@property(readonly) BOOL hasUserInitiatedBuildOperations;
@property(readonly) BOOL hasQueuedBuildOperations;
@property(readonly) NSSet *queuedBuildOperations;
@property(readonly) NSArray *executionTrackersOfOperationsWithBuilds;
@property(readonly) IDEBreakpointManager *breakpointManager;
- (void)primitiveInvalidate;
- (id)initWithWorkspaceArena:(id)arg1;

// Remaining properties
@property(retain) DVTStackBacktrace *creationBacktrace;
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly, copy) NSSet *executedActionInvocationRecords; // @dynamic executedActionInvocationRecords;
@property(readonly, copy) NSArray *executionTrackers; // @dynamic executionTrackers;
@property(readonly, copy) NSArray *executionTrackersForDisplay; // @dynamic executionTrackersForDisplay;
@property(readonly) DVTStackBacktrace *invalidationBacktrace;
@property(readonly, copy) NSArray *launchSessions; // @dynamic launchSessions;
@property(readonly, copy) NSMutableOrderedSet *mutableExecutedActionInvocationRecords; // @dynamic mutableExecutedActionInvocationRecords;
@property(readonly, copy) NSMutableArray *mutableExecutionTrackers; // @dynamic mutableExecutionTrackers;
@property(readonly, copy) NSMutableArray *mutableExecutionTrackersForDisplay; // @dynamic mutableExecutionTrackersForDisplay;
@property(readonly, copy) NSMutableArray *mutableLaunchSessions; // @dynamic mutableLaunchSessions;
@property(readonly) Class superclass;
@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

