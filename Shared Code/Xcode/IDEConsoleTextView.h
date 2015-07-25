//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//

#include "Shared.h"

#import "DVTCompletingTextView.h"

#import "DVTFindBarFindable-Protocol.h"
#import "DVTInvalidation-Protocol.h"
#import "DVTTextFindable-Protocol.h"

@class DVTObservingToken, DVTStackBacktrace, DVTTextCompletionDataSource, NSDictionary, NSMutableArray, NSString;
@protocol IDEConsoleTextViewObjectiveCExpressionRangeDelegate, IDEConsoleTextViewStandardIODelegate;

@interface IDEConsoleTextView : DVTCompletingTextView <DVTTextFindable, DVTFindBarFindable, DVTInvalidation>
{
    unsigned long long _startLocationOfLastLine;
    long long _lastRemovableTextLocation;
    NSString *_promptString;
    DVTTextCompletionDataSource *_consoleTextViewcompletionsDataSource;
    BOOL _itemsToAppendTimerScheduled;
    NSMutableArray *_itemsToAppendAfterDelay;
    unsigned long long _viewableCharactersExceededHit;
    BOOL _wasScrolledToBottomWhenHidden;
    NSDictionary *_debuggerPromptTextAttributes;
    NSDictionary *_debuggerInputTextAttributes;
    NSDictionary *_debuggerOutputTextAttributes;
    NSDictionary *_debuggedTargetInputTextAttributes;
    NSDictionary *_debuggedTargetOutputTextAttributes;
    NSDictionary *_textTypeToAttributes;
    DVTObservingToken *_suggestCompletionsObserver;
    int _logMode;
    id <IDEConsoleTextViewStandardIODelegate> _standardIODelegate;
    id <IDEConsoleTextViewObjectiveCExpressionRangeDelegate> _openingBracketLocationDelegate;
}

+ (void)initialize;
@property(nonatomic) int logMode; // @synthesize logMode=_logMode;
@property(retain) id <IDEConsoleTextViewObjectiveCExpressionRangeDelegate> openingBracketLocationDelegate; // @synthesize openingBracketLocationDelegate=_openingBracketLocationDelegate;
@property(retain) id <IDEConsoleTextViewStandardIODelegate> standardIODelegate; // @synthesize standardIODelegate=_standardIODelegate;
// - (void).cxx_destruct;
- (id)startingLocationForFindBar:(id)arg1 findingBackwards:(BOOL)arg2;
- (void)dvtFindBar:(id)arg1 didUpdateCurrentResult:(id)arg2;
- (id)findStringMatchingDescriptor:(id)arg1 backwards:(BOOL)arg2 from:(id)arg3 to:(id)arg4;
- (id)menuForEvent:(id)arg1;
- (void)paste:(id)arg1;
- (void)moveToBeginningOfLineAndModifySelection:(id)arg1;
- (void)moveToBeginningOfLine:(id)arg1;
- (id)_attributesForConsoleItem:(id)arg1;
- (BOOL)_handleClosingBracketTypedIfNecessary:(id)arg1;
- (void)insertText:(id)arg1;
- (void)insertNewline:(id)arg1;
- (void)_moveCursorToBeJustAfterPrompt;
- (BOOL)_isSelectionAfterPrompt;
- (void)moveToBeginningOfParagraph:(id)arg1;
- (void)moveDown:(id)arg1;
- (void)moveUp:(id)arg1;
- (BOOL)_isValidForHistoryTracking;
- (BOOL)readSelectionFromPasteboard:(id)arg1;
- (id)writablePasteboardTypes;
- (void)_undoManagerDidUndoChangeNotification:(id)arg1;
- (BOOL)shouldChangeTextInRanges:(id)arg1 replacementStrings:(id)arg2;
- (void)keyDown:(id)arg1;
- (void)_sendKeyImmediatelyIfNecessary:(id)arg1 event:(id)arg2;
- (void)_moveInsertionPointToEnd;
- (id)userEnteredTextAfterPromptUpToLocation:(unsigned long long)arg1;
- (id)userEnteredTextAfterPrompt;
- (void)repeatInput:(id)arg1;
- (void)_appendPromptConsoleItem:(id)arg1;
- (void)_appendNonPromptSameConsoleItems:(id)arg1;
- (void)appendConsoleItemsImmediatelyWithoutScrolling:(id)arg1;
- (void)_appendConsoleItemsWaitingToBeAppended;
- (void)appendConsoleItemsAfterDelay:(id)arg1;
- (void)appendConsoleItemAfterDelay:(id)arg1;
- (void)_resetTypingAttributes;
- (struct _NSRange)_rangeBeforeLastLineText;
- (void)_processInputTextForCompleteLineAndSendToDelegate:(BOOL)arg1;
- (void)clearConsoleItems;
- (void)_scrollToBottom;
- (BOOL)_shouldScrollToTheBottom;
- (void)_batchReplaceCharactersWithoutNotificationsInRange:(struct _NSRange)arg1 withString:(id)arg2 attributes:(id)arg3;
- (void)_batchReplaceCharactersWithNotificationsInRange:(struct _NSRange)arg1 withString:(id)arg2 attributes:(id)arg3;
@property(readonly) struct _NSRange lastLineTextRange;
- (struct _NSRange)_inputTextRange;
- (void)_reapplyAttributes;
- (void)_recreateAttributes;
- (void)_themeFontsAndColorsUpdated;
- (void)viewWillMoveToWindow:(id)arg1;
- (void)setCompletionStrategies:(id)arg1;
- (id)completionsDataSource;
- (BOOL)shouldAutoCompleteAtLocation:(unsigned long long)arg1;
- (id)autoCompleteChars;
- (double)autoCompletionDelay;
- (struct _NSRange)wordRangeAtLocation:(unsigned long long)arg1;
- (BOOL)acceptsFirstMouse:(id)arg1;
- (void)viewDidUnhide;
- (void)viewDidHide;
- (void)primitiveInvalidate;
- (void)awakeFromNib;
- (void)_dvt_commonInit;
- (id)initWithCoder:(id)arg1;
- (id)initWithFrame:(struct CGRect)arg1;

// Remaining properties
@property(retain) DVTStackBacktrace *creationBacktrace;
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) DVTStackBacktrace *invalidationBacktrace;
@property(readonly) Class superclass;
@property unsigned long long supportedMatchingOptions;
@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

