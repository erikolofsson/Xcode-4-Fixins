//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk.sdk
//

#include "Shared.h"

#import "IDENavigator.h"

@class IDENavigatorOutlineView, NSArray, NSMutableArray;
@protocol IDEOpenRequest;

@interface IDEOutlineBasedNavigator : IDENavigator
{
    NSArray *_selectedObjects;
    IDENavigatorOutlineView *_outlineView;
    id <IDEOpenRequest> _lastOpenRequest;
}

+ (id)keyPathsForValuesAffectingFilterProgress;
+ (id)keyPathsForValuesAffectingObjects;
+ (void)initialize;
@property(retain) id <IDEOpenRequest> lastOpenRequest; // @synthesize lastOpenRequest=_lastOpenRequest;
@property(retain) IDENavigatorOutlineView *outlineView; // @synthesize outlineView=_outlineView;
// - (void).cxx_destruct;
- (void)revertState;
- (long long)filterProgress;
- (void)setFilter:(id)arg1;
- (id)contextMenuSelection;
- (void)willForgetNavigableItems:(id)arg1;
- (void)primitiveInvalidate;
- (void)viewWillUninstall;
- (void)viewDidInstall;
@property(readonly, nonatomic) NSArray *objects;
- (void)_toggleExpandedStateOf:(id)arg1;
- (BOOL)_openNavigableItem:(id)arg1 eventType:(unsigned long long)arg2;
- (void)openDoubleClickedNavigableItemsAction:(id)arg1;
- (void)openClickedNavigableItemAction:(id)arg1;
- (void)openSelectedNavigableItemsKeyAction:(id)arg1;
- (id)openSpecifierForNavigableItem:(id)arg1 error:(id *)arg2;
- (BOOL)_shouldOpenNavigableItem:(id)arg1 eventType:(unsigned long long)arg2;
- (BOOL)delegateFirstResponder;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;
- (void)loadView;

// Remaining properties
@property(readonly) NSMutableArray *mutableSelectedObjects; // @dynamic mutableSelectedObjects;
@property(retain) NSArray *selectedObjects; // @dynamic selectedObjects;

@end

