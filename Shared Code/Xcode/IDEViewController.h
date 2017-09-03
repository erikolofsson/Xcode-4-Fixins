//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk.sdk
//

#include "Shared.h"

#import "DVTViewController.h"

#import "DVTStatefulObject-Protocol.h"
#import "IDESelectionSource-Protocol.h"

@class DVTStateToken, IDESelection, IDEWorkspace, IDEWorkspaceDocument, IDEWorkspaceTabController, NSString;
@protocol IDEWorkspaceDocumentProvider;

@interface IDEViewController : DVTViewController <IDESelectionSource, DVTStatefulObject>
{
    IDESelection *_outputSelection;
    DVTStateToken *_stateToken;
    id <IDEWorkspaceDocumentProvider> _workspaceDocumentProvider;
    IDEWorkspaceTabController *_workspaceTabController;
}

+ (void)configureStateSavingObjectPersistenceByName:(id)arg1;
+ (long long)version;
+ (id)keyPathsForValuesAffectingWorkspace;
+ (id)keyPathsForValuesAffectingWorkspaceDocument;
@property(retain, nonatomic) IDEWorkspaceTabController *workspaceTabController; // @synthesize workspaceTabController=_workspaceTabController;
@property(retain, nonatomic) id <IDEWorkspaceDocumentProvider> workspaceDocumentProvider; // @synthesize workspaceDocumentProvider=_workspaceDocumentProvider;
@property(readonly, nonatomic) DVTStateToken *stateToken; // @synthesize stateToken=_stateToken;
@property(copy, nonatomic) IDESelection *outputSelection; // @synthesize outputSelection=_outputSelection;
// - (void).cxx_destruct;
- (void)setStateToken:(DVTStateToken *)arg1;
- (BOOL)_knowsAboutInstalledState;
- (void)revertState;
- (void)commitState;
- (void)commitStateToDictionary:(id)arg1;
- (void)revertStateWithDictionary:(id)arg1;
- (void)primitiveInvalidate;
@property(readonly, nonatomic) BOOL automaticallyInvalidatesChildViewControllers;
- (void)_invalidateSubViewControllersForView:(id)arg1;
- (id)supplementalTargetForAction:(SEL)arg1 sender:(id)arg2;
@property(readonly, copy, nonatomic) IDESelection *contextMenuSelection;
@property(readonly, nonatomic) IDEWorkspace *workspace;
@property(readonly, nonatomic) IDEWorkspaceDocument *workspaceDocument;
- (void)_resolveWorkspaceDocumentProvider;
- (void)_resolveWorkspaceTabController;
- (void)viewDidInstall;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;

// Remaining properties
@property(readonly) BOOL canRevertWithEmptyStateDictionary;
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) Class superclass;

@end

