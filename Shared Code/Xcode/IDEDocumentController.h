//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk.sdk
//

#include "Shared.h"

#import "IDEContainerErrorPresenter-Protocol.h"
#import "IDEContainerReloadingDelegate-Protocol.h"
#import "IDEContainerUnlockingDelegate-Protocol.h"
#import "IDEVersionedFileManagerDelegate-Protocol.h"

@class NSArray, NSMapTable, NSString;

@interface IDEDocumentController : NSDocumentController <IDEVersionedFileManagerDelegate, IDEContainerErrorPresenter, IDEContainerReloadingDelegate, IDEContainerUnlockingDelegate, NSMenuDelegate>
{
    NSMapTable *_editorDocumentByFilePath;
    BOOL _isClosingAllDocuments;
    BOOL _hasScheduledMobileDeviceLoadBlock;
    BOOL _isSafeToLoadMobileDevice;
}

+ (id)_informativeTextFieldForAlert:(id)arg1;
+ (id)_informativeTextForQuarantineProperties:(id)arg1;
+ (id)_documentDisplayNameForDocumentType:(id)arg1;
+ (BOOL)_shouldOpenURL:(id)arg1 documentType:(id)arg2;
+ (void)_setOpenAsContextMenu:(id)arg1 withViewController:(id)arg2;
+ (BOOL)_isWorkspaceWrappingDocumentURL:(id)arg1;
+ (BOOL)_isWorkspaceDocumentURL:(id)arg1;
+ (Class)_THREAD_editorDocumentClassForType:(id)arg1 extension:(id *)arg2;
+ (void)_THREAD_cacheDocumentClass:(Class)arg1 forExtension:(id)arg2;
+ (Class)_THREAD_cachedDocumentClassForExtension:(id)arg1;
+ (id)_typeForContentsOfURL:(id)arg1;
+ (BOOL)_isValidDocumentExtensionIdentifier:(id)arg1 withEditorCategories:(id)arg2;
+ (id)editorDocumentExtensionForNavigableItem:(id)arg1 editorCategories:(id)arg2;
+ (id)editorDocumentExtensionForFileDataType:(id)arg1 editorCategories:(id)arg2;
+ (id)_THREAD_editorDocumentExtensionForType:(id)arg1 withEditorCategories:(id)arg2;
+ (id)_THREAD_bestEditorDocumentExtensionSupportingType:(id)arg1 withEditorCategories:(id)arg2;
+ (BOOL)_isDocumentExtensionPreferred:(id)arg1 over:(id)arg2;
+ (BOOL)_isValidDocumentExtensionIdentifier:(id)arg1 supportingDocumentType:(id)arg2 withEditorCategories:(id)arg3;
+ (void)_enumerateDocumentExtensionsMatchingFileDataType:(id)arg1 withEditorCategories:(id)arg2 matchBlock:(CDUnknownBlockType)arg3;
+ (id)_readableTypesForDocumentClass:(Class)arg1;
+ (id)_organizerSourceExtensionForDocumentType:(id)arg1;
+ (id)_bestEditorDocumentExtensionForDocumentClass:(Class)arg1 supportingDocumentType:(id)arg2 withEditorCategories:(id)arg3 shouldPreferExtension:(char *)arg4;
+ (id)_documentExtensionForNavigableItem:(id)arg1;
+ (id)_editorDocumentExtensionsForOpenAsWhichSupportType:(id)arg1 editorCategories:(id)arg2;
+ (BOOL)_isAllowedToCreateEditorDocumentForFileDataType:(id)arg1;
+ (BOOL)_THREAD_type:(id)arg1 role:(int)arg2 isPreferableToType:(id)arg3 role:(int)arg4;
+ (void)_THREAD_cacheBestEditorDocumentExtension:(id)arg1 forType:(id)arg2 withEditorCategory:(id)arg3;
+ (id)_THREAD_cachedBestEditorDocumentExtensionForType:(id)arg1 withEditorCategory:(id)arg2;
+ (id)_THREAD_allOrganizerSourceExtensions;
+ (id)_THREAD_allEditorDocumentExtensions;
+ (id)workspaceDocumentForWorkspace:(id)arg1;
+ (id)editorDocumentForNavigableItem:(id)arg1;
+ (id)editorDocumentForFilePath:(id)arg1;
+ (id)editorDocumentForURL:(id)arg1;
+ (id)retainedEditorDocumentForNavigableItem:(id)arg1 forUseWithWorkspaceDocument:(id)arg2 error:(id *)arg3;
+ (id)retainedEditorDocumentForDocumentLocation:(id)arg1 forUseWithWorkspaceDocument:(id)arg2 error:(id *)arg3;
+ (id)_retainedEditorDocumentForURL:(id)arg1 type:(id)arg2 error:(id *)arg3;
+ (id)_newEditorDocumentWithClass:(Class)arg1 forURL:(id)arg2 withContentsOfURL:(id)arg3 ofType:(id)arg4 extension:(id)arg5 error:(id *)arg6;
+ (void)releaseEditorDocument:(id)arg1;
+ (BOOL)_closeDocumentIfNeeded:(id)arg1;
+ (void)retainEditorDocument:(id)arg1;
+ (id)_openDocuments;
+ (id)sharedDocumentController;
+ (void)initialize;
@property BOOL isClosingAllDocuments; // @synthesize isClosingAllDocuments=_isClosingAllDocuments;
// - (void).cxx_destruct;
- (void)_structureEditingWillRemoveContainerItems:(id)arg1;
- (id)unsavedEditorDocumentFilePaths;
- (void)container:(id)arg1 attemptToUnlockItems:(id)arg2 workspace:(id)arg3 completionQueue:(id)arg4 completionBlock:(CDUnknownBlockType)arg5;
- (int)responseToExternalChangesToBackingFileForContainer:(id)arg1 fileWasRemoved:(BOOL)arg2;
- (void)attemptRecoveryFromError:(id)arg1 optionIndex:(unsigned long long)arg2 delegate:(id)arg3 didRecoverSelector:(SEL)arg4 contextInfo:(void *)arg5;
- (BOOL)attemptRecoveryFromError:(id)arg1 optionIndex:(unsigned long long)arg2;
- (int)handleSaveError:(id)arg1 forContainer:(id)arg2 withAction:(int)arg3;
- (void)moveItemAtFilePathToTrash:(id)arg1 completionBlock:(CDUnknownBlockType)arg2;
- (BOOL)canMoveItemsAtFilePaths:(id)arg1 toFilePaths:(id)arg2 completionBlockDispatchQueue:(id *)arg3 completionBlock:(CDUnknownBlockType *)arg4;
- (void)asyncRemoveItemsAtFilePaths:(id)arg1 completionBlock:(CDUnknownBlockType)arg2;
- (void)_asyncRemoveItemsAtFilePaths:(id)arg1 completionBlock:(CDUnknownBlockType)arg2;
- (void)willRemoveItemsAtFilePaths:(id)arg1 completionBlock:(CDUnknownBlockType)arg2;
- (BOOL)canRemoveItemsAtFilePaths:(id)arg1 completionBlockDispatchQueue:(id *)arg2 completionBlock:(CDUnknownBlockType *)arg3;
- (id)_wrappedWorkspacesForContainers:(id)arg1;
- (id)_retainedContainersForFilePaths:(id)arg1;
- (id)_getEditorDocumentsForFilePaths:(id)arg1 editedDocuments:(id *)arg2;
- (void)_splitEditorExtensions:(id)arg1 intoPreferred:(id)arg2 andNonPreferred:(id)arg3;
- (void)_addOpenAsMenuItemsForCategoryExtensions:(id)arg1 toMenu:(id)arg2;
- (void)menuNeedsUpdate:(id)arg1;
- (id)_openAsDocumentExtensionsForFileDataTypes:(id)arg1 editorCategories:(id)arg2;
- (void)_openAs:(id)arg1;
- (void)noteNewRecentDocumentURL:(id)arg1;
- (id)_recentDocumentRecordsKeyForMenuTag:(long long)arg1;
- (id)_recentWorkspaceDocumentInfosAsyncUpdate:(CDUnknownBlockType)arg1;
- (id)_recentWorkspaceDocumentURLs;
- (id)_recentEditorDocumentURLs;
- (id)displayNameForType:(id)arg1;
- (id)fileExtensionsFromType:(id)arg1;
- (BOOL)_applicationShouldTerminate;
- (void)_runOpenPanelWithURLsFromRunningOpenPanel:(id)arg1 completionBlock:(CDUnknownBlockType)arg2;
- (void)runOpenPanelWithCompletionBlock:(CDUnknownBlockType)arg1;
- (id)_setupOpenPanel;
- (id)currentDirectory;
- (id)documentClassNames;
- (BOOL)validateUserInterfaceItem:(id)arg1;
- (void)reviewUnsavedDocumentsWithAlertTitle:(id)arg1 cancellable:(BOOL)arg2 delegate:(id)arg3 didReviewAllSelector:(SEL)arg4 contextInfo:(void *)arg5;
- (void)closeAllDocumentsWithDelegate:(id)arg1 didCloseAllSelector:(SEL)arg2 contextInfo:(void *)arg3;
- (void)_dvt_closeAllDocumentsWithDelegate:(id)arg1 didCloseAllSelector:(SEL)arg2 shouldCloseAutosavingDocuments:(BOOL)arg3 contextInfo:(void *)arg4;
- (void)_checkAndCloseAllDocumentsStartingWith:(id)arg1 shouldCloseDocuments:(BOOL)arg2 closeAllContext:(void *)arg3;
- (void)saveAllEditorDocuments:(id)arg1;
- (void)saveAllEditorDocumentsAsyncronouslyWithCompletionBlock:(CDUnknownBlockType)arg1;
- (void)autosaveInPlaceAllEditorDocumentsAsyncronouslyWithCompletionBlock:(CDUnknownBlockType)arg1;
- (void)_saveEditorDocuments:(id)arg1 forOperation:(unsigned long long)arg2 completionBlock:(CDUnknownBlockType)arg3;
- (BOOL)_saveEditorDocuments:(id)arg1 forOperation:(unsigned long long)arg2 error:(id *)arg3;
- (id)editedEditorDocuments;
@property(readonly) NSArray *editorDocumentsToManuallySave;
@property(readonly) NSArray *editorDocumentsToSave;
@property(readonly) NSArray *editorDocuments;
@property(readonly) NSArray *workspaceDocuments;
- (void)removeDocument:(id)arg1;
- (void)addDocument:(id)arg1;
- (id)documents;
- (void)_endObservingEditorDocument:(id)arg1 keyPath:(id)arg2 associationKey:(id)arg3;
- (void)_startObservingEditorDocument:(id)arg1 keyPath:(id)arg2 associationKey:(id)arg3;
- (Class)documentClassForType:(id)arg1;
- (Class)_THREAD_documentClassForType:(id)arg1 extension:(id *)arg2;
- (void)_editorDocument:(id)arg1 didPrint:(BOOL)arg2 contextInfo:(void *)arg3;
- (void)_printDocumentsWithContentsOfUnprocessedURLs:(id)arg1 settings:(id)arg2 showPrintPanels:(BOOL)arg3 completionHandler:(CDUnknownBlockType)arg4;
- (void)_printDocumentsWithContentsOfURLs:(id)arg1 settings:(id)arg2 showPrintPanels:(BOOL)arg3 completionHandler:(CDUnknownBlockType)arg4;
- (void)_openDocumentsWithContentsOfURLs:(id)arg1 presentErrors:(BOOL)arg2 completionHandler:(CDUnknownBlockType)arg3;
- (void)_coordinateReadingAndGetAlternateContentsForOpeningDocumentAtURL:(id)arg1 resolvingSymlinks:(BOOL)arg2 thenContinueOnMainThreadWithAccessor:(CDUnknownBlockType)arg3;
- (id)openDocumentWithContentsOfURL:(id)arg1 display:(BOOL)arg2;
- (void)asyncOpenDocumentsWithContentsOfURLs:(id)arg1 display:(BOOL)arg2 completionHandler:(CDUnknownBlockType)arg3;
- (id)openDocumentWithContentsOfURL:(id)arg1 display:(BOOL)arg2 error:(id *)arg3;
- (id)openUntitledDocumentAndDisplay:(BOOL)arg1 error:(id *)arg2;
- (void)openDocumentWithContentsOfURL:(id)arg1 display:(BOOL)arg2 completionHandler:(CDUnknownBlockType)arg3;
- (void)asyncOpenDocumentLocation:(id)arg1 display:(BOOL)arg2 completionHandler:(CDUnknownBlockType)arg3;
- (void)_openDocumentsForDocumentLocations:(id)arg1 display:(BOOL)arg2 completionHandler:(CDUnknownBlockType)arg3;
- (void)_openProjectsPlaygroundsAndWorkspaces:(id)arg1 display:(BOOL)arg2 openedDocuments:(id)arg3 simpleFileDocumentLocations:(id)arg4 completionHandler:(CDUnknownBlockType)arg5;
- (void)_openProjectsPlaygroundsAndWorkspaces:(id)arg1 display:(BOOL)arg2 completionHandler:(CDUnknownBlockType)arg3;
- (id)_workspacePlaygroundOrProjectDocumentLocationsInFolderURL:(id)arg1;
- (void)_openSimpleFileDocumentLocations:(id)arg1 display:(BOOL)arg2 completionBlock:(CDUnknownBlockType)arg3;
- (id)_frontmostSimpleFilesFocusedWorkspaceWindowForTopLevelFilePaths:(id)arg1;
- (BOOL)_workspace:(id)arg1 topLevelChildrenMatches:(id)arg2;
- (void)_promptToOpenWorkspaceWithCompletionBlock:(CDUnknownBlockType)arg1;
- (void)_chooseWorkspaceWithCompletionBlock:(CDUnknownBlockType)arg1;
- (void)_openWrappingContainerDocument:(id)arg1 displayDocument:(BOOL)arg2 completionHandler:(CDUnknownBlockType)arg3;
- (id)makeDocumentWithContentsOfURL:(id)arg1 ofType:(id)arg2 error:(id *)arg3;
- (void)_openWorkspaceDocumentForWorkspace:(id)arg1 display:(BOOL)arg2 completionHandler:(CDUnknownBlockType)arg3;
- (id)_addPath:(id)arg1 toChildrenOfWorkspace:(id)arg2;
- (id)_frontmostWorkspaceWindowForWorkspaces:(id)arg1;
- (BOOL)_isWorkspaceWindow:(id)arg1 forWorkspaces:(id)arg2;
- (id)typeForContentsOfURL:(id)arg1 error:(id *)arg2;
- (void)reopenDocumentForURL:(id)arg1 withContentsOfURL:(id)arg2 display:(BOOL)arg3 completionHandler:(CDUnknownBlockType)arg4;
- (void)asyncSaveUntitledWorkspaceDocument:(id)arg1 forProjectDocument:(id)arg2 completionHandler:(CDUnknownBlockType)arg3;
- (id)openUntitledWorkspaceDocumentAndDisplay:(BOOL)arg1 error:(id *)arg2;
- (id)_openUntitledWorkspaceDocumentAndDisplay:(BOOL)arg1 simpleFilesFocused:(BOOL)arg2 forSingleFile:(BOOL)arg3 editorDocumentURLOrNil:(id)arg4 error:(id *)arg5;
- (id)documentForURL:(id)arg1;
- (BOOL)_anyDocumentClassUsesUbiquitousStorage;
- (id)defaultType;
- (id)init;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) Class superclass;

@end

