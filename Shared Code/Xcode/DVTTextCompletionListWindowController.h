//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.13.sdk.sdk
//

#include "Shared.h"

#import "DVTInvalidation-Protocol.h"

@class DVTBorderedView, DVTDelayedInvocation, DVTObservingToken, DVTScaleInWindowAnimator, DVTStackBacktrace, DVTTextCompletionWindowResizeAnimation, DVTViewController, NSDictionary, NSScrollView, NSString, NSTableColumn, NSTableView, NSTextField, NSViewAnimation;
@protocol DVTInvalidation, DVTTextCompletionListDataSource;

@interface DVTTextCompletionListWindowController : NSWindowController <DVTInvalidation, NSTableViewDataSource, NSTableViewDelegate, NSAnimationDelegate>
{
    NSTextField *_messagesField;
    NSTableView *_completionsTableView;
    NSTableColumn *_iconColumn;
    NSTableColumn *_typeColumn;
    NSTableColumn *_titleColumn;
    NSScrollView *_completionsScrollView;
    DVTBorderedView *_quickHelpView;
    DVTBorderedView *_divider;
    id <DVTTextCompletionListDataSource> _dataSource;
    struct CGRect _referenceFrameInView;
    DVTTextCompletionWindowResizeAnimation *_resizeAnimation;
    DVTScaleInWindowAnimator *_fadeInAnimator;
    NSViewAnimation *_fadeOutAnimation;
    DVTObservingToken *_sessionCompletionsObserver;
    DVTObservingToken *_sessionSelectionObserver;
    NSDictionary *_selectedTitleCellAttributes;
    NSDictionary *_selectedTypeCellAttributes;
    int _hideReason;
    BOOL _showingWindow;
    BOOL _shouldIgnoreSelectionChange;
    BOOL _quickHelpOnTop;
    DVTDelayedInvocation *_delayedQuickHelpClearing;
    DVTViewController<DVTInvalidation> *_infoContentViewController;
    DVTBorderedView *_contentView;
    NSTableColumn *_leftPaddingColumn;
}

+ (id)_nonSelectedTypeColor;
+ (id)_nonSelectedTitleColor;
+ (void)initialize;
@property __weak NSTableColumn *leftPaddingColumn; // @synthesize leftPaddingColumn=_leftPaddingColumn;
@property __weak DVTBorderedView *contentView; // @synthesize contentView=_contentView;
@property(readonly) DVTViewController<DVTInvalidation> *infoContentViewController; // @synthesize infoContentViewController=_infoContentViewController;
@property(nonatomic) int hideReason; // @synthesize hideReason=_hideReason;
@property(readonly) id <DVTTextCompletionListDataSource> dataSource; // @synthesize dataSource=_dataSource;
@property(readonly) BOOL showingWindow; // @synthesize showingWindow=_showingWindow;
@property(readonly) NSScrollView *completionsScrollView; // @synthesize completionsScrollView=_completionsScrollView;
// - (void).cxx_destruct;
@property(readonly) NSString *debugStateString;
- (id)tableView:(id)arg1 toolTipForCell:(id)arg2 rect:(struct CGRect *)arg3 tableColumn:(id)arg4 row:(long long)arg5 mouseLocation:(struct CGPoint)arg6;
- (void)tableView:(id)arg1 willDisplayCell:(id)arg2 forTableColumn:(id)arg3 row:(long long)arg4;
- (void)tableViewSelectionDidChange:(id)arg1;
- (id)tableView:(id)arg1 objectValueForTableColumn:(id)arg2 row:(long long)arg3;
- (long long)numberOfRowsInTableView:(id)arg1;
- (void)_updateInfoNewSelection;
- (BOOL)showInfoForSelectedCompletionItem;
- (id)_selectedCompletionItem;
- (void)_updateInfoPaneForCompletionItem:(id)arg1 andViewController:(id)arg2;
- (void)_removeQuickHelpView;
- (void)showInfoPaneForCompletionItem:(id)arg1;
- (void)close;
- (void)_loadColorsFromCurrentTheme;
- (void)_themeColorsChanged:(id)arg1;
- (id)_notRecommendedAttributes;
- (id)_messageTextAttributes;
- (struct CGRect)_preferredWindowFrameForTextFrame:(struct CGRect)arg1 columnsWidth:(double *)arg2 titleColumnX:(double)arg3;
- (void)_getTitleColumnWidth:(double *)arg1 typeColumnWidth:(double *)arg2;
- (void)_updateSelectedRow;
- (void)_updateCurrentDisplayState;
- (void)_updateCurrentDisplayStateForQuickHelp;
- (void)_startDelayedAnimation;
- (void)selectedCompletionIndexChanged;
- (void)completionListChanged;
- (void)_doubleClickOnRow:(id)arg1;
- (void)animationDidEnd:(id)arg1;
- (void)animationDidStop:(id)arg1;
- (void)hideWindowWithReason:(int)arg1;
- (void)_hideWindow;
- (void)showWindowForTextFrame:(struct CGRect)arg1 explicitAnimation:(BOOL)arg2;
- (void)primitiveInvalidate;
- (void)windowDidLoad;
- (id)initWithDataSource:(id)arg1;
- (id)window;

// Remaining properties
@property(retain) DVTStackBacktrace *creationBacktrace;
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) DVTStackBacktrace *invalidationBacktrace;
@property(readonly) Class superclass;
@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

