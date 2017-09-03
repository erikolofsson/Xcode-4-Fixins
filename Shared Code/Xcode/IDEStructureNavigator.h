//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk.sdk
//

#include "Shared.h"

#import "IDEOutlineBasedNavigator.h"

#import "DVTTableCellViewTitleEditingDelegate-Protocol.h"
#import "IDETemplateSupportingNavigator-Protocol.h"
#import "IDETestingSelection-Protocol.h"

@class DVTObservingToken, IDESelection, IDEWorkspaceTabController, NSDictionary, NSMenu, NSMutableSet, NSSet, NSString, NSTableColumn;
@protocol IDEStructureEditingDropTarget;

@interface IDEStructureNavigator : IDEOutlineBasedNavigator <NSOutlineViewDelegate, DVTTableCellViewTitleEditingDelegate, IDETemplateSupportingNavigator, IDETestingSelection, NSMenuDelegate>
{
    NSTableColumn *_mainTableColumn;
    NSSet *_expandedItems;
    NSMutableSet *_expandedItemsBeforeFiltering;
    id <IDEStructureEditingDropTarget> _dropTarget;
    BOOL _restoringState;
    BOOL _clearingFilter;
    BOOL _scmStatusFilteringEnabled;
    BOOL _scmStatusFilteringAllowed;
    NSDictionary *_previouslyRestoredStateDictionary;
    NSMutableSet *_observingAndBindingTokens;
    DVTObservingToken *_recentEditorDocumentURLsObservingToken;
    DVTObservingToken *_scmFilterObservingToken;
    DVTObservingToken *_scmEnabledToken;
    NSMenu *_contextualMenu;
    NSMenu *_filterButtonMenu;
    BOOL _recentDocumentFilteringEnabled;
    NSString *_fileNamePatternString;
}

+ (void)configureStateSavingObjectPersistenceByName:(id)arg1;
+ (id)keyPathsForValuesAffectingScmStatusFilteringEnabled;
+ (void)_ideKeyBindingsDidChange:(id)arg1;
+ (id)_structureNavigatorDragTypes;
+ (unsigned long long)assertionBehaviorForKeyValueObservationsAtEndOfEvent;
+ (unsigned long long)assertionBehaviorAfterEndOfEventForSelector:(SEL)arg1;
+ (void)initialize;
@property(nonatomic) BOOL recentDocumentFilteringEnabled; // @synthesize recentDocumentFilteringEnabled=_recentDocumentFilteringEnabled;
@property(copy, nonatomic) NSString *fileNamePatternString; // @synthesize fileNamePatternString=_fileNamePatternString;
// - (void).cxx_destruct;
- (id)selectedTestsAndTestables;
- (id)selectedTest;
- (void)_handleEnterAction;
- (BOOL)outlineView:(id)arg1 doCommandBySelector:(SEL)arg2;
- (BOOL)_isNavigableItem:(id)arg1 childOfNavigableItems:(id)arg2;
- (BOOL)outlineView:(id)arg1 shouldShowOutlineCellForItem:(id)arg2;
- (BOOL)outlineView:(id)arg1 isItemExpandable:(id)arg2;
- (BOOL)outlineView:(id)arg1 acceptDrop:(id)arg2 item:(id)arg3 childIndex:(long long)arg4;
- (unsigned long long)outlineView:(id)arg1 validateDrop:(id)arg2 proposedItem:(id)arg3 proposedChildIndex:(long long)arg4;
- (BOOL)outlineView:(id)arg1 writeItems:(id)arg2 toPasteboard:(id)arg3;
- (void)titleDidChangeForTableCellView:(id)arg1;
- (struct _NSRange)initialSelectionRangeForTableCellView:(id)arg1 usingProposedRange:(struct _NSRange)arg2;
- (void)_addStatusViewForContainerProgress:(id)arg1 navItem:(id)arg2;
- (void)_addStatusViewForContainerIssues:(id)arg1 navItem:(id)arg2;
- (void)_updateSCMStatusViewBindings:(id)arg1;
- (id)_tableCellViewForDefaultNavItem:(id)arg1;
- (void)statusItemClickedAction:(id)arg1;
- (double)outlineView:(id)arg1 heightOfRowByItem:(id)arg2;
- (id)outlineView:(id)arg1 viewForTableColumn:(id)arg2 item:(id)arg3;
- (id)outlineView:(id)arg1 rowViewForItem:(id)arg2;
- (void)_updateScmStatusTextFieldBindingsForExistingItemInOutlineView:(id)arg1;
- (void)outlineViewItemDidCollapse:(id)arg1;
- (void)outlineViewItemDidExpand:(id)arg1;
@property(copy) NSString *visibleRectString;
- (id)_selectedItemsAsNameTree;
- (void)_setSelectedItemsFromNameTree:(id)arg1;
- (id)_expandedItemsAsNameTree;
- (id)_expandedItemsBeforeFilteringAsNameTree;
- (void)_setExpandedItemsFromNameTree:(id)arg1;
- (void)commitStateToDictionary:(id)arg1;
- (void)revertStateWithDictionary:(id)arg1;
- (void)_revertWithoutState;
- (id)_bestItemToOpenFromInitalItems:(id)arg1;
- (BOOL)canRevertWithEmptyStateDictionary;
- (void)configureStateSavingObservers;
- (void)revealNavigableItems:(id)arg1;
- (void)setFilter:(id)arg1;
- (id)filterDefinitionIdentifier;
@property(nonatomic) BOOL scmStatusFilteringEnabled;
@property(nonatomic) BOOL scmStatusFilteringAllowed;
- (void)_triggerFilteringForDocumentURLs:(id)arg1;
- (void)_updateFilter;
- (void)_clearFilter;
- (id)filterButtonAccessibilityDescription;
- (id)filterButtonToolTip;
- (id)filterButtonMenu;
- (void)fiterButton_newProject:(id)arg1;
- (void)filterButton_newPackage:(id)arg1;
- (void)filterButton_newFile:(id)arg1;
- (void)_hideDuplicateSeparatorItemsInMenu:(id)arg1;
- (void)_updateMenuItem:(id)arg1 withNavigable:(id)arg2 target:(id)arg3;
- (id)_menuItemWhitelistProviderUsingContextualMenuSelection:(BOOL)arg1;
- (void)_filterMenu:(id)arg1 fromMenuItemWhitelist:(id)arg2;
- (void)menuNeedsUpdate:(id)arg1;
- (id)_cleanNewMenuItemForIdentifier:(id)arg1;
- (BOOL)validateUserInterfaceItem:(id)arg1;
- (void)openInAdjacentEditorWithShiftPlusAlternate:(id)arg1;
- (void)openInNewWindow:(id)arg1;
- (void)openInNewTab:(id)arg1;
- (id)_openSpecifierForNavigableItem:(id)arg1;
- (id)_itemFromContextualClickedRows;
- (BOOL)_isSelectionFileReferenceNavigableItem;
- (void)contextMenu_showFileInspector:(id)arg1;
- (void)contextMenu_delete:(id)arg1;
- (void)delete:(id)arg1;
- (void)_newPackage:(id)arg1 useContextualMenuSelection:(BOOL)arg2;
- (void)contextMenu_newProject:(id)arg1;
- (void)contextMenu_newFile:(id)arg1;
- (void)newDocument:(id)arg1;
- (void)_newTemplateWithTemplateKind:(id)arg1 template:(id)arg2 useContextualMenuSelection:(BOOL)arg3;
- (id)_titleForNewGroupFolderOrPageMenuItemAlternate:(BOOL)arg1 useContextualMenuSelection:(BOOL)arg2 forFilterMenu:(BOOL)arg3;
- (id)_folderOfOrContainingReference:(id)arg1;
- (id)_playgroundForNavItem:(id)arg1 playgroundItem:(id *)arg2;
- (id)_titleForAddFilesMenuItemUsingContextualMenuSelection:(BOOL)arg1;
- (id)_titleForNewFileMenuItemUsingContextualMenuSelection:(BOOL)arg1 isMainMenu:(BOOL)arg2;
- (id)_containerNameForNavigableItem:(id)arg1;
- (id)_selectedContainerOrContainingReferenceUsingContextualMenuSelection:(BOOL)arg1;
- (void)_createPlaygroundBookItemOfType:(unsigned long long)arg1 usingContextualMenuSelection:(BOOL)arg2;
- (void)contextMenu_newPlaygroundCutscene:(id)arg1;
- (void)newPlaygroundCutscene:(id)arg1;
- (void)contextMenu_newPlaygroundPage:(id)arg1;
- (void)newPlaygroundPage:(id)arg1;
- (void)contextMenu_newPlaygroundChapter:(id)arg1;
- (void)newPlaygroundChapter:(id)arg1;
- (void)contextMenu_addFiles:(id)arg1;
- (void)addFiles:(id)arg1;
- (void)contextMenu_sortFilesByType:(id)arg1;
- (void)sortFilesByType:(id)arg1;
- (void)contextMenu_sortFilesByName:(id)arg1;
- (void)sortFilesByName:(id)arg1;
- (void)contextMenu_newFolderWithSelected:(id)arg1;
- (void)newFolderWithSelected:(id)arg1;
- (void)contextMenu_groupSelected:(id)arg1;
- (void)groupSelected:(id)arg1;
- (void)contextMenu_newFolder:(id)arg1;
- (void)newFolder:(id)arg1;
- (void)contextMenu_newGroupWithoutFolder:(id)arg1;
- (void)newGroupWithoutFolder:(id)arg1;
- (void)contextMenu_newGroupWithFolder:(id)arg1;
- (void)newGroupWithFolder:(id)arg1;
- (void)contextMenu_newGroup:(id)arg1;
- (void)newGroup:(id)arg1;
- (void)_createNewPlaygroundPageWithType:(long long)arg1 inPlayground:(id)arg2 targeting:(id)arg3;
- (void)addTemplateInstantiatedItems:(id)arg1 primaryItem:(id)arg2 shouldEdit:(BOOL)arg3;
- (id)_itemsToExpandFromInitialItems:(id)arg1;
- (void)setupTemplateContext:(id)arg1 forTemplateKind:(id)arg2;
- (id)defaultDestinationGroupForTemplateInstantiationWithDestinationIndex:(long long *)arg1;
- (BOOL)_setupTemplateContext:(id)arg1 forTemplateKind:(id)arg2 useContextualMenuSelection:(BOOL)arg3;
- (id)_destinationGroupForSelectedItem:(id)arg1 destinationIndex:(long long *)arg2;
- (void)focusedEditorDidSelectItem:(id)arg1;
- (BOOL)_shouldSupressNavigationForURL:(id)arg1;
- (id)openSpecifierForNavigableItem:(id)arg1 error:(id *)arg2;
- (void)_editChildItemAtIndex:(unsigned long long)arg1 ofParentItem:(id)arg2;
- (void)_editNavigableItem:(id)arg1;
- (void)_expandNavigableItem:(id)arg1;
- (void)_expandOutlineViewItem:(id)arg1;
- (BOOL)_askToRemoveFileURLs:(id)arg1 shouldRemoveReferences:(BOOL)arg2 willPerformRemoveBlock:(CDUnknownBlockType)arg3 didPerformRemoveBlock:(CDUnknownBlockType)arg4;
- (BOOL)_testOrDeleteItems:(BOOL)arg1 useContextualMenuSelection:(BOOL)arg2;
- (void)_removeFoldersIfEmpty:(id)arg1 usingVersionedFileManager:(id)arg2;
- (BOOL)_isDirectoryEmpty:(id)arg1;
- (BOOL)_testOrAddFiles:(BOOL)arg1 useContextualMenuSelection:(BOOL)arg2;
- (BOOL)_shouldAllowCreationOfNewFilesForTarget:(id)arg1 proposedNavigableItem:(id)arg2 proposedChildIndex:(long long)arg3;
- (BOOL)_testOrSort:(BOOL)arg1 byNameOrByType:(BOOL)arg2 useContextualMenuSelection:(BOOL)arg3;
- (BOOL)_testOrGroupSelected:(BOOL)arg1 forceFolder:(id)arg2 useContextualMenuSelection:(BOOL)arg3;
- (BOOL)_testOrAddNewGroup:(BOOL)arg1 forceFolder:(id)arg2 useContextualMenuSelection:(BOOL)arg3;
- (BOOL)_testOrAddNewFolder:(BOOL)arg1 useContextualMenuSelection:(BOOL)arg2;
- (BOOL)_testOrAddNewPlaygroundPage:(BOOL)arg1 useContextualMenuSelection:(BOOL)arg2;
- (BOOL)_performUsingContextualMenuSelection:(BOOL)arg1 op:(CDUnknownBlockType)arg2;
- (id)_outlineViewItemForNavigableItem:(id)arg1;
- (id)_selectedOutlineViewItemUsingContextualSelection:(BOOL)arg1 useFirstIndex:(BOOL)arg2;
- (id)_navigableItemForOutlineViewItem:(id)arg1 representedObject:(id *)arg2;
- (void)willForgetNavigableItems:(id)arg1;
- (void)viewWillUninstall;
- (void)viewDidInstall;
- (id)domainIdentifier;
- (void)loadView;
- (void)primitiveInvalidate;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;

// Remaining properties
@property(readonly, copy) IDESelection *contextMenuSelection;
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(copy) NSSet *expandedItems; // @dynamic expandedItems;
@property(readonly, copy) NSMutableSet *mutableExpandedItems; // @dynamic mutableExpandedItems;
@property(readonly, copy) IDESelection *outputSelection;
@property(readonly) Class superclass;
@property(readonly, nonatomic) IDEWorkspaceTabController *workspaceTabController;

@end

