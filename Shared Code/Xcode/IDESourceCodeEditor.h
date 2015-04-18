//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

//
// SDK Root: /Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//

#import "Shared.h"
#import "IDEEditor.h"

#import "DVTFindBarFindable-Protocol.h"
#import "DVTSourceTextViewDelegate-Protocol.h"
#import "IDEComparisonEditorHostContext-Protocol.h"
#import "IDEOpenQuicklyJumpToSupport-Protocol.h"
#import "IDERefactoringExpressionSource-Protocol.h"
#import "IDESourceControlLogDetailDelegate-Protocol.h"
#import "IDESourceExpressionSource-Protocol.h"
#import "IDETestingSelection-Protocol.h"
#import "IDETextVisualizationHost-Protocol.h"

@class DVTDispatchLock, DVTLayoutManager, DVTNotificationToken, DVTObservingToken, DVTOperation, DVTSDK, DVTScopeBarController, DVTSourceExpression, DVTSourceLanguageService, DVTSourceTextView, DVTStackBacktrace, DVTTextDocumentLocation, DVTTextSidebarView, DVTWeakInterposer, IDEAnalyzerResultsExplorer, IDENoteAnnotationExplorer, IDESingleFileProcessingToolbarController, IDESourceCodeDocument, IDESourceCodeEditorAnnotationProvider, IDESourceCodeEditorContainerView, IDESourceCodeHelpNavigationRequest, IDESourceCodeNavigationRequest, IDESourceCodeSingleLineBlameProvider, IDESourceControlLogDetailViewController, IDEViewController, NSArray, NSDictionary, NSMutableArray, NSOperationQueue, NSPopover, NSProgressIndicator, NSScrollView, NSString, NSTimer, NSTrackingArea, NSView;
@protocol IDESourceEditorViewControllerHost;

@interface IDESourceCodeEditor : IDEEditor <NSTextViewDelegate, NSMenuDelegate, NSPopoverDelegate, DVTSourceTextViewDelegate, DVTFindBarFindable, IDESourceExpressionSource, IDERefactoringExpressionSource, IDETextVisualizationHost, IDEOpenQuicklyJumpToSupport, IDEComparisonEditorHostContext, IDESourceControlLogDetailDelegate, IDETestingSelection>
{
    NSScrollView *_scrollView;
    DVTSourceTextView *_textView;
    DVTLayoutManager *_layoutManager;
    IDESourceCodeEditorContainerView *_containerView;
    DVTTextSidebarView *_sidebarView;
    NSArray *_currentSelectedItems;
    NSDictionary *_syntaxColoringContext;
    DVTSourceExpression *_selectedExpression;
    DVTSourceExpression *_mouseOverExpression;
    IDESourceCodeNavigationRequest *_currentNavigationRequest;
    IDESourceCodeHelpNavigationRequest *_helpNavigationRequest;
    NSObject<OS_dispatch_queue> *_symbolLookupQueue;
    NSMutableArray *_stateChangeObservingTokens;
    DVTObservingToken *_topLevelItemsObserverToken;
    DVTObservingToken *_firstResponderObserverToken;
    DVTObservingToken *_editorLiveIssuesEnabledObserverToken;
    DVTObservingToken *_navigatorLiveIssuesEnabledObserverToken;
    DVTNotificationToken *_workspaceLiveSourceIssuesEnabledObserver;
    DVTObservingToken *_needsDiagnosisObserverToken;
    DVTObservingToken *_diagnosticItemsObserverToken;
    NSOperationQueue *_diagnoseRelatedFilesQueue;
    DVTOperation *_findRelatedFilesOperation;
    DVTObservingToken *_sessionInProgressObserverToken;
    DVTNotificationToken *_blueprintDidChangeNotificationObservingToken;
    DVTNotificationToken *_textStorageDidProcessEndingObserver;
    DVTNotificationToken *_textViewBoundsDidChangeObservingToken;
    DVTNotificationToken *_sourceCodeDocumentDidSaveNotificationToken;
    DVTNotificationToken *_indexDidChangeNotificationToken;
    IDESourceCodeEditorAnnotationProvider *_annotationProvider;
    IDEAnalyzerResultsExplorer *_analyzerResultsExplorer;
    DVTWeakInterposer *_analyzerResultsScopeBar_dvtWeakInterposer;
    BOOL _hidingAnalyzerExplorer;
    IDENoteAnnotationExplorer *_noteAnnotationExplorer;
    IDESourceCodeSingleLineBlameProvider *_blameProvider;
    NSPopover *_blameLogPopover;
    IDESourceControlLogDetailViewController *_blameDetailController;
    IDESingleFileProcessingToolbarController *_singleFileProcessingToolbarController;
    NSView *_emptyView;
    NSView *_contentGenerationBackgroundView;
    NSProgressIndicator *_contentGenerationProgressIndicator;
    NSTimer *_contentGenerationProgressTimer;
    NSOperationQueue *_tokenizeQueue;
    DVTDispatchLock *_tokenizeAccessLock;
    unsigned long long _tokenizeGeneration;
    NSTrackingArea *_mouseTracking;
    NSDictionary *_previouslyRestoredStateDictionary;
    struct _NSRange _previousSelectedLineRange;
    unsigned long long _lastFocusedAnnotationIndex;
    struct _NSRange _lastEditedCharRange;
    DVTTextDocumentLocation *_continueToHereDocumentLocation;
    DVTTextDocumentLocation *_continueToLineDocumentLocation;
    DVTWeakInterposer *_hostViewController_dvtWeakInterposer;
    struct {
        unsigned int wantsDidScroll:1;
        unsigned int wantsDidFinishAnimatingScroll:1;
        unsigned int supportsContextMenuCustomization:1;
        unsigned int supportsAnnotationContextCreation:1;
        unsigned int wantsDidLoadAnnotationProviders:1;
        unsigned int reserved:3;
    } _hvcFlags;
    BOOL _trackingMouse;
    BOOL _scheduledInitialSetup;
    BOOL _initialSetupDone;
    BOOL _nodeTypesPrefetchingStarted;
    BOOL _isUninstalling;
}

+ (id)keyPathsForValuesAffectingIsWorkspaceBuilding;
+ (void)revertStateWithDictionary:(id)arg1 withSourceTextView:(id)arg2 withEditorDocument:(id)arg3;
+ (void)commitStateToDictionary:(id)arg1 withSourceTextView:(id)arg2;
+ (long long)version;
+ (void)configureStateSavingObjectPersistenceByName:(id)arg1;
@property(retain) IDESingleFileProcessingToolbarController *singleFileProcessingToolbarController; // @synthesize singleFileProcessingToolbarController=_singleFileProcessingToolbarController;
@property struct _NSRange lastEditedCharacterRange; // @synthesize lastEditedCharacterRange=_lastEditedCharRange;
@property(retain) IDEAnalyzerResultsExplorer *analyzerResultsExplorer; // @synthesize analyzerResultsExplorer=_analyzerResultsExplorer;
@property(retain, nonatomic) DVTSourceExpression *mouseOverExpression; // @synthesize mouseOverExpression=_mouseOverExpression;
@property(retain) IDESourceCodeEditorContainerView *containerView; // @synthesize containerView=_containerView;
@property(retain) DVTLayoutManager *layoutManager; // @synthesize layoutManager=_layoutManager;
@property(retain) DVTSourceTextView *textView; // @synthesize textView=_textView;
@property(retain) NSScrollView *scrollView; // @synthesize scrollView=_scrollView;
- (BOOL)editorDocumentIsCurrentRevision;
- (BOOL)editorIsHostedInComparisonEditor;
- (id)_documentLocationForLineNumber:(long long)arg1;
- (void)_createFileBreakpointAtLocation:(long long)arg1;
- (id)_breakpointManager;
- (long long)_currentOneBasedLineNubmer;
- (id)currentEditorContext;
- (id)documentLocationForOpenQuicklyQuery:(id)arg1;
- (void)openQuicklyScoped:(id)arg1;
- (void)debugLogJumpToDefinitionState:(id)arg1;
- (id)_jumpToDefinitionOfExpression:(id)arg1 fromScreenPoint:(struct CGPoint)arg2 clickCount:(long long)arg3 modifierFlags:(unsigned long long)arg4;
- (void)_cancelHelpNavigationRequest;
- (void)_cancelCurrentNavigationRequest;
- (void)contextMenu_revealInSymbolNavigator:(id)arg1;
- (void)jumpToSelection:(id)arg1;
- (void)jumpBetweenSourceFileAndGeneratedFileWithShiftPlusAlternate:(id)arg1;
- (void)jumpBetweenSourceFileAndGeneratedFileWithAlternate:(id)arg1;
- (void)jumpBetweenSourceFileAndGeneratedFile:(id)arg1;
- (void)jumpToDefinitionWithShiftPlusAlternate:(id)arg1;
- (void)jumpToDefinitionWithAlternate:(id)arg1;
- (void)jumpToDefinition:(id)arg1;
- (void)_jumpToExpression:(id)arg1;
- (void)revealInSymbolNavigator:(id)arg1;
- (unsigned long long)_insertionIndexUnderMouse;
- (id)_documentLocationUnderMouse;
- (id)_calculateContinueToDocumentLocationFromDocumentLocation:(id)arg1;
- (id)_calculateContinueToLineDocumentLocation;
- (id)_calculateContinueToHereDocumentLocation;
- (BOOL)validateMenuItem:(id)arg1;
- (void)menuNeedsUpdate:(id)arg1;
- (void)mouseExited:(id)arg1;
- (void)mouseEntered:(id)arg1;
- (void)mouseMoved:(id)arg1;
- (void)deregisterForMouseEvents;
- (void)registerForMouseEvents;
@property(readonly, nonatomic) DVTSourceLanguageService *languageService;
- (struct CGRect)expressionFrameForExpression:(id)arg1;
- (id)importStringInExpression:(id)arg1;
- (BOOL)isExpressionModuleImport:(id)arg1;
- (BOOL)isExpressionPoundImport:(id)arg1;
- (BOOL)_isExpressionImport:(id)arg1 module:(BOOL)arg2;
- (BOOL)expressionContainsExecutableCode:(id)arg1;
- (BOOL)isExpressionFunctionOrMethodCall:(id)arg1;
- (BOOL)isExpressionInFunctionOrMethodBody:(id)arg1;
- (BOOL)isLocationInFunctionOrMethodBody:(id)arg1;
- (BOOL)isExpressionFunctionOrMethodDefinition:(id)arg1;
- (BOOL)isExpressionInPlainCode:(id)arg1;
- (BOOL)isExpressionWithinComment:(id)arg1;
- (void)symbolsForExpression:(id)arg1 inQueue:(id)arg2 completionBlock:(CDUnknownBlockType)arg3;
@property(readonly, nonatomic) NSString *selectedText;
@property(readonly, nonatomic) struct CGRect currentSelectionFrame;
- (void)_sendDelayedSelectedExpressionDidChangeMessage;
@property(retain, nonatomic) DVTSourceExpression *selectedExpression; // @synthesize selectedExpression=_selectedExpression;
- (void)_invalidateMouseOverExpression;
@property(readonly) DVTSourceExpression *quickHelpExpression;
@property(readonly) DVTSourceExpression *contextMenuExpression;
- (void)_updatedMouseOverExpression;
- (void)_updateSelectedExpression;
- (BOOL)_expression:(id)arg1 representsTheSameLocationAsExpression:(id)arg2;
- (id)_expressionAtCharacterIndex:(unsigned long long)arg1;
- (id)refactoringExpressionUsingContextMenu:(BOOL)arg1;
- (id)selectedTestsAndTestables;
- (id)_testFromModelItem:(id)arg1 fromTests:(id)arg2;
- (void)specialPaste:(id)arg1;
- (id)_specialPasteContext;
- (void)_changeSourceCodeLanguageAction:(id)arg1;
- (void)_useSourceCodeLanguageFromFileDataTypeAction:(id)arg1;
- (void)_askToPromoteToUnicodeSheetDidEnd:(id)arg1 returnCode:(long long)arg2 contextInfo:(void *)arg3;
- (void)_askToPromoteToUnicode;
- (void)_applyPerFileTextSettings;
- (void)textView:(id)arg1 doubleClickedOnCell:(id)arg2 inRect:(struct CGRect)arg3 atIndex:(unsigned long long)arg4;
- (void)textView:(id)arg1 clickedOnCell:(id)arg2 inRect:(struct CGRect)arg3 atIndex:(unsigned long long)arg4;
- (void)contextMenu_toggleIssueShown:(id)arg1;
- (void)toggleIssueShown:(id)arg1;
- (void)_enumerateDiagnosticAnnotationsInSelection:(CDUnknownBlockType)arg1;
- (id)_jumpToAnnotationWithSelectedRange:(struct _NSRange)arg1 fixIt:(BOOL)arg2 backwards:(BOOL)arg3;
- (void)fixAllInScope:(id)arg1;
- (id)fixableDiagnosticAnnotationsInScope;
- (id)_diagnosticAnnotationsInScopeFixableOnly:(BOOL)arg1;
- (id)_diagnosticAnnotationsInRange:(struct _NSRange)arg1 fixableOnly:(BOOL)arg2;
- (void)popoverWillClose:(id)arg1;
- (id)viewWindow;
- (BOOL)detailShouldShowOpenBlameView;
- (void)openBlameView;
- (void)openComparisonView;
- (void)blameSelectedLine:(id)arg1;
- (void)_showDocumentationForSelectedSymbol:(id)arg1;
- (void)showQuickHelp:(id)arg1;
- (void)continueToCurrentLine:(id)arg1;
- (void)continueToHere:(id)arg1;
- (void)toggleInvisibleCharactersShown:(id)arg1;
- (void)toggleBreakpointAtCurrentLine:(id)arg1;
- (void)_stopShowingContentGenerationProgressInidcator;
- (void)_showContentGenerationProgressIndicatorWithDelay:(double)arg1;
- (void)_contentGenerationProgressTimerFired:(id)arg1;
- (void)_hideEmptyView;
- (void)_showEmptyViewWithMessage:(id)arg1;
- (void)_centerViewInSuperView:(id)arg1;
- (void)compileCurrentFile;
- (void)analyzeCurrentFile;
- (void)preprocessCurrentFile;
- (void)assembleCurrentFile;
- (void)_processCurrentFileUsingBuildCommand:(int)arg1;
- (id)_singleFileProcessingFilePath;
- (void)startSingleProcessingModeForURL:(id)arg1;
@property(readonly) BOOL isWorkspaceBuilding;
- (BOOL)canAssembleFile;
- (BOOL)canPreprocessFile;
- (BOOL)canAnalyzeFile;
- (BOOL)canCompileFile;
- (void)stopNoteExplorer;
- (void)startNoteExplorerForItem:(id)arg1;
- (void)showErrorsOnly:(id)arg1;
- (void)showAllIssues:(id)arg1;
- (void)toggleMessageBubbles:(id)arg1;
- (void)hideAnalyzerExplorerAnimate:(BOOL)arg1;
- (void)showAnalyzerExplorerForMessage:(id)arg1 animate:(BOOL)arg2;
- (void)_startPrefetchingNodeTypesInUpDirection:(BOOL)arg1 initialLineRange:(struct _NSRange)arg2 noProgressIterations:(unsigned long long)arg3;
- (void)revertStateWithDictionary:(id)arg1;
- (void)commitStateToDictionary:(id)arg1;
- (void)configureStateSavingObservers;
- (id)_transientStateDictionaryForDocument:(id)arg1;
- (id)_stateDictionariesForDocuments;
- (id)cursorForAltTemporaryLink;
- (void)_textViewDidLoseFirstResponder;
- (BOOL)completingTextViewHandleCancel:(id)arg1;
- (void)textViewDidScroll:(id)arg1;
- (void)textViewDidFinishAnimatingScroll:(id)arg1;
- (id)textView:(id)arg1 menu:(id)arg2 forEvent:(id)arg3 atIndex:(unsigned long long)arg4;
- (void)tokenizableRangesWithRange:(struct _NSRange)arg1 completionBlock:(CDUnknownBlockType)arg2;
- (void)textViewBoundsDidChange:(id)arg1;
- (void)textView:(id)arg1 handleMouseDidExitSidebar:(id)arg2;
- (void)textView:(id)arg1 handleMouseDidMoveOverSidebar:(id)arg2 atLineNumber:(unsigned long long)arg3;
- (void)uninstallBreakpointGestureRecognizers;
- (void)_replaceItemsInMenu:(id)arg1 withItemsInMenu:(id)arg2;
- (void)installBreakpointGestureRecognizersInView:(id)arg1;
- (void)textView:(id)arg1 handleMouseDownInSidebar:(id)arg2 atLineNumber:(unsigned long long)arg3;
- (id)completingTextView:(id)arg1 documentLocationForWordStartLocation:(unsigned long long)arg2;
- (void)completingTextView:(id)arg1 willPassContextToStrategies:(id)arg2 atWordStartLocation:(unsigned long long)arg3;
- (void)textView:(id)arg1 didClickOnTemporaryLinkAtCharacterIndex:(unsigned long long)arg2 event:(id)arg3 isAltEvent:(BOOL)arg4;
- (void)_doubleClickOnTemporaryHelpLinkTimerExpired;
- (void)_doubleClickOnTemporaryLinkTimerExpired;
- (BOOL)textView:(id)arg1 shouldShowTemporaryLinkForCharacterAtIndex:(unsigned long long)arg2 proposedRange:(struct _NSRange)arg3 effectiveRanges:(id *)arg4;
- (void)textView:(id)arg1 didRemoveAnnotations:(id)arg2;
- (void)textViewDidLoadAnnotationProviders:(id)arg1;
- (id)annotationContextForTextView:(id)arg1;
- (id)syntaxColoringContextForTextView:(id)arg1;
- (BOOL)textView:(id)arg1 shouldChangeTextInRange:(struct _NSRange)arg2 replacementString:(id)arg3;
- (void)setupTextViewContextMenuWithMenu:(id)arg1;
- (void)setupGutterContextMenuWithMenu:(id)arg1;
- (void)textViewDidChangeSelection:(id)arg1;
- (void)textDidChange:(id)arg1;
- (void)removeVisualization:(id)arg1 fadeOut:(BOOL)arg2 completionBlock:(CDUnknownBlockType)arg3;
- (void)addVisualization:(id)arg1 fadeIn:(BOOL)arg2 completionBlock:(CDUnknownBlockType)arg3;
@property(readonly) NSArray *visualizations;
- (id)pathCell:(id)arg1 menuItemForNavigableItem:(id)arg2 defaultMenuItem:(id)arg3;
- (BOOL)pathCell:(id)arg1 shouldInitiallyShowMenuSearch:(id)arg2;
- (BOOL)pathCell:(id)arg1 shouldSeparateDisplayOfChildItemsForItem:(id)arg2;
- (struct _NSRange)selectedRangeForFindBar:(id)arg1;
- (id)startingLocationForFindBar:(id)arg1 findingBackwards:(BOOL)arg2;
- (void)dvtFindBar:(id)arg1 didUpdateCurrentResult:(id)arg2;
- (void)dvtFindBar:(id)arg1 didUpdateResults:(id)arg2;
- (void)didSetupEditor;
- (void)takeFocus;
- (BOOL)canBecomeMainViewController;
- (id)undoManagerForTextView:(id)arg1;
- (void)viewWillUninstall;
- (void)viewDidInstall;
- (void)contentViewDidCompleteLayout;
- (void)_doInitialSetup;
- (void)_liveIssuesPreferencesUpdatedInvalidateDiagnosticController:(BOOL)arg1;
- (void)_blueprintDidChangeForSourceCodeEditor:(id)arg1;
- (void)_endObservingDiagnosticItems;
- (void)_startObservingDiagnosticItems;
- (void)primitiveInvalidate;
- (void)selectDocumentLocations:(id)arg1 highlightSelection:(BOOL)arg2;
- (void)selectAndHighlightDocumentLocations:(id)arg1;
- (void)selectDocumentLocations:(id)arg1;
- (void)navigateToAnnotationWithRepresentedObject:(id)arg1 wantsIndicatorAnimation:(BOOL)arg2 exploreAnnotationRepresentedObject:(id)arg3;
- (id)currentSelectedDocumentLocations;
- (id)_currentSelectedLandmarkItem;
- (void)setCurrentSelectedItems:(id)arg1;
- (id)currentSelectedItems;
- (void)_refreshCurrentSelectedItemsIfNeeded;
- (BOOL)_isCurrentSelectedItemsValid;
@property __weak IDEViewController<IDESourceEditorViewControllerHost> *hostViewController;
@property(readonly) IDESourceCodeEditorAnnotationProvider *annotationProvider; // @synthesize annotationProvider=_annotationProvider;
- (id)mainScrollView;
@property(readonly) IDESourceCodeDocument *sourceCodeDocument;
- (void)loadView;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2 document:(id)arg3;
@property __weak DVTScopeBarController *analyzerResultsScopeBar;

// Remaining properties
@property(retain) DVTStackBacktrace *creationBacktrace;
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;

@property(readonly) DVTStackBacktrace *invalidationBacktrace;
@property(readonly) DVTSDK *sdk;
@property(readonly) Class superclass;
@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

