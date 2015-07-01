//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//

#include "Shared.h"

#import "DVTOutlineView.h"

#import "DVTInvalidation-Protocol.h"

@class DVTDelayedInvocation, DVTStackBacktrace, IDEOutlineViewGroupInfo, NSArray, NSHashTable, NSMutableArray, NSMutableIndexSet, NSPredicate, NSSet, NSString, _IDENavigatorOutlineViewDataSource;
@protocol IDENavigatorOutlineViewLoadingDelegate;

@interface IDENavigatorOutlineView : DVTOutlineView <DVTInvalidation>
{
    double _groupHeaderRowHeight;
    long long _batchRowUpdateCount;
    id _itemBeingFullyReloaded;
    NSHashTable *_unfilteredRootItems;
    NSPredicate *_filterPredicate;
    DVTDelayedInvocation *_delayedInvocation;
    NSString *_emptyContentStringCopy;
    SEL _keyAction;
    id <IDENavigatorOutlineViewLoadingDelegate> _loadingDelegate;
    IDEOutlineViewGroupInfo *_groupInfo;
    _IDENavigatorOutlineViewDataSource *_interposedDelegate;
    _IDENavigatorOutlineViewDataSource *_interposedDataSource;
    void *_keepSelfAliveUntilCancellationRef;
    BOOL _updatesDisplayOnlyInTrayCharts;
    BOOL _calledFromSetsNeedsDisplayOnlyInTrayCharts;
    NSMutableArray *_entriesToRestoreToVisibleRect;
    struct {
        unsigned int _needsToPushRowSelection:1;
        unsigned int _needsToRefreshBoundSelectedObjects:1;
        unsigned int _needsToRefreshBoundExpandedItems:1;
        unsigned int _suspendRowHeightInvalidation:1;
        unsigned int _doingBatchExpand:1;
        unsigned int _filteringEnabled:1;
        unsigned int _filteringActive:1;
        unsigned int _scrollSelectionToVisibleAfterRefreshingSelection:1;
        unsigned int _hasContent:1;
        unsigned int _didDrawContent:1;
        unsigned int _resettingRootItems:1;
        unsigned int _reloadingItems:1;
        unsigned int _didRecieveKeyDownEvent:1;
        unsigned int _didPublishSelectedObjects:1;
        unsigned int _supportsTrackingAreasForCells:1;
        unsigned int _inSameRunloopForTrackingSelectionVisibleRect:1;
    } _idenovFlags;
    BOOL _supportsVariableHeightCells;
    BOOL _tracksSelectionVisibleRect;
    BOOL _disableSourceListSelectionStyle;
    NSSet *_editorSelectedNavigableItems;
    NSMutableIndexSet *_selectedIndexesToDrawAsUnselected;
}

+ (void)initialize;
@property(retain) NSMutableIndexSet *selectedIndexesToDrawAsUnselected; // @synthesize selectedIndexesToDrawAsUnselected=_selectedIndexesToDrawAsUnselected;
@property(nonatomic) BOOL disableSourceListSelectionStyle; // @synthesize disableSourceListSelectionStyle=_disableSourceListSelectionStyle;
@property BOOL tracksSelectionVisibleRect; // @synthesize tracksSelectionVisibleRect=_tracksSelectionVisibleRect;
@property(retain, nonatomic) NSSet *editorSelectedNavigableItems; // @synthesize editorSelectedNavigableItems=_editorSelectedNavigableItems;
@property BOOL supportsVariableHeightCells; // @synthesize supportsVariableHeightCells=_supportsVariableHeightCells;
@property(retain) id <IDENavigatorOutlineViewLoadingDelegate> loadingDelegate; // @synthesize loadingDelegate=_loadingDelegate;
@property(nonatomic) SEL keyAction; // @synthesize keyAction=_keyAction;
@property(copy, nonatomic) NSPredicate *filterPredicate; // @synthesize filterPredicate=_filterPredicate;
@property double groupHeaderRowHeight; // @synthesize groupHeaderRowHeight=_groupHeaderRowHeight;
// - (void).cxx_destruct;
- (void)processPendingChanges;
- (void)drawRect:(struct CGRect)arg1;
- (void)scrollSelectionToVisible;
- (BOOL)scrollRectToVisible:(struct CGRect)arg1;
- (struct _NSRange)initialSelectionRangeForCell:(id)arg1 proposedRange:(struct _NSRange)arg2;
- (void)_drawGroupItemGradientInRect:(struct CGRect)arg1 borderSides:(int)arg2;
- (struct CGRect)frameOfOutlineCellAtRow:(long long)arg1;
- (struct CGRect)frameOfCellAtColumn:(long long)arg1 row:(long long)arg2;
- (double)_indentationForRow:(long long)arg1 withLevel:(long long)arg2 isSourceListGroupRow:(BOOL)arg3;
- (struct CGRect)adjustRect:(struct CGRect)arg1 forItem:(id)arg2 row:(long long)arg3 inGroupRange:(struct _NSRange)arg4;
- (BOOL)groupWithRangeShouldDrawLeftDivider:(struct _NSRange)arg1;
- (BOOL)groupWithRangeShouldDrawTopDivider:(struct _NSRange)arg1;
- (struct _NSRange)rowRangeForEnclosingGroupOfItem:(id)arg1;
- (struct _NSRange)rowRangeForEnclosingGroupOfTreeNode:(id)arg1;
- (id)enclosingGroupItemForItem:(id)arg1;
- (id)enclosingGroupInfoForRow:(long long)arg1;
- (void)selectRowIndexes:(id)arg1 byExtendingSelection:(BOOL)arg2;
- (void)highlightSelectionInClipRect:(struct CGRect)arg1;
- (void)_drawSelectionForGroupItemInRect:(struct CGRect)arg1;
- (void)setNeedsDisplayInRect:(struct CGRect)arg1;
- (void)setNeedsDisplayOnlyInTrayCharts:(BOOL)arg1;
- (BOOL)_hasExpandedGroups;
- (BOOL)needsDisplayOnlyInTrayCharts;
- (void)_setNeedsDisplayInSelectedRows;
- (BOOL)dvt_highlightColorDependsOnWindowState;
- (void)accessibilitySetSelectedRowsAttribute:(id)arg1;
- (void)keyUp:(id)arg1;
- (void)keyDown:(id)arg1;
- (void)mouseDown:(id)arg1;
- (void)quickLookWithEvent:(id)arg1;
- (BOOL)_supportsTrackingAreasForCells;
@property BOOL supportsTrackingAreasForCells;
- (void)setSortDescriptors:(id)arg1;
@property(copy) NSArray *rootItems;
- (void)_updateRootItems:(id)arg1 sortDescriptors:(id)arg2;
- (BOOL)isRootItem:(id)arg1;
@property(readonly) id realDelegate;
@property(readonly) id realDataSource;
- (void)setDelegate:(id)arg1;
- (void)setDataSource:(id)arg1;
- (void)reloadData;
- (void)reloadItem:(id)arg1 reloadChildren:(BOOL)arg2;
- (void)_restoreEntriesToVisibleRect;
- (void)_rememberEntriesToRestoreToVisibleRect;
- (void)item:(id)arg1 expandedAddingRows:(long long)arg2;
- (void)registerGroupHeaderItem:(id)arg1 atRow:(unsigned long long)arg2;
- (void)printGroupInfo;
- (void)_clearGroupingInfo;
- (id)itemBeingFullyReloaded;
@property(readonly, getter=isReloadingItems) BOOL reloadingItems;
- (BOOL)sendAction:(SEL)arg1 to:(id)arg2;
- (void)_refreshDisplayForItem:(id)arg1;
- (void)updateBoundExpandedItems;
- (void)updateBoundSelectedObjects;
- (void)publishBoundSelectedObjects;
- (void)_updateBoundContentArrayOrSet;
- (void)updateBoundContentSet;
- (void)updateBoundContentArray;
- (void)_refreshBoundExpandedAndSelectedItems:(id)arg1;
- (void)refreshBoundSelectedObjects;
- (void)refreshBoundExpandedItems;
- (id)dvtExtraBindings;
- (void)primitiveInvalidate;
- (void)suspendEditingWhilePerformingBlock:(CDUnknownBlockType)arg1;
- (id)_suspendEditing:(long long *)arg1;
- (void)noteAllRowHeightsMayHaveChanged;
- (void)setShouldSuspendPublishBoundSelectedObjects:(BOOL)arg1;
- (BOOL)shouldSuspendPublishBoundSelectedObjects;
- (void)concludeBatchRowUpdates;
- (void)beginBatchRowUpdates;
- (void)setShouldSuspendRowHeightInvalidation:(BOOL)arg1;
- (BOOL)shouldSuspendRowHeightInvalidation;
- (void)collapseItem:(id)arg1;
- (void)collapseItem:(id)arg1 collapseChildren:(BOOL)arg2;
- (void)expandItemIncludingAncestors:(id)arg1 expandChildren:(BOOL)arg2;
- (void)expandItem:(id)arg1;
- (void)expandItem:(id)arg1 expandChildren:(BOOL)arg2;
- (void)expandAncestorsForItem:(id)arg1;
- (void)_expandAncestorsForItem:(id)arg1;
- (void)setFilteringEnabled:(BOOL)arg1;
- (BOOL)filteringEnabled;
- (void)setFilteringActive:(BOOL)arg1;
- (long long)filterProgress;
@property(readonly, getter=isFilteringActive) BOOL filteringActive;
- (id)emptyContentString;
- (void)setEmptyContentString:(id)arg1;
- (void)_updateEmptyContentString;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)_ide_commonInit;

// Remaining properties
@property(retain) DVTStackBacktrace *creationBacktrace;
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) DVTStackBacktrace *invalidationBacktrace;
@property(readonly) Class superclass;
@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

