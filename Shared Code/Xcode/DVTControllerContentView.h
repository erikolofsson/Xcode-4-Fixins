//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

//
// SDK Root: /Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//

#import <DVTKit/DVTLayoutView_ML.h>

#import "DVTInvalidation.h"

@class DVTStackBacktrace, DVTViewController, NSArray, NSMapTable, NSString, NSView, NSWindow;

@interface DVTControllerContentView : DVTLayoutView_ML <DVTInvalidation>
{
    struct CGSize _minContentFrameSize;
    struct CGSize _maxContentFrameSize;
    DVTViewController *_viewController;
    NSWindow *_kvoWindow;
    int _horizontalAlignmentWhenClipping;
    int _horizontalAlignmentWhenPadding;
    int _verticalAlignmentWhenClipping;
    int _verticalAlignmentWhenPadding;
    int _verticalContentViewResizingMode;
    int _horizontalContentViewResizingMode;
    BOOL _isInstalled;
    BOOL _isPadding;
    BOOL _isReplacingSubview;
    BOOL _disablePaddingWarning;
    BOOL _isGrouped;
    NSMapTable *_subviewObservations;
    NSArray *_currentContentViewConstraints;
    DVTStackBacktrace *_setFrameSizeBacktrace;
    NSString *_frameSizeDimentionIsNaN;
    BOOL _constraintsCameFromNib;
}

+ (void)initialize;
@property BOOL isGrouped; // @synthesize isGrouped=_isGrouped;
@property BOOL disablePaddingWarning; // @synthesize disablePaddingWarning=_disablePaddingWarning;
@property(nonatomic) int verticalContentViewResizingMode; // @synthesize verticalContentViewResizingMode=_verticalContentViewResizingMode;
@property(nonatomic) int horizontalContentViewResizingMode; // @synthesize horizontalContentViewResizingMode=_horizontalContentViewResizingMode;
@property(nonatomic) int verticalAlignmentWhenClipping; // @synthesize verticalAlignmentWhenClipping=_verticalAlignmentWhenClipping;
@property(nonatomic) int horizontalAlignmentWhenClipping; // @synthesize horizontalAlignmentWhenClipping=_horizontalAlignmentWhenClipping;
@property(nonatomic) struct CGSize minimumContentViewFrameSize; // @synthesize minimumContentViewFrameSize=_minContentFrameSize;
@property(nonatomic) int verticalAlignmentWhenPadding; // @synthesize verticalAlignmentWhenPadding=_verticalAlignmentWhenPadding;
@property(nonatomic) int horizontalAlignmentWhenPadding; // @synthesize horizontalAlignmentWhenPadding=_horizontalAlignmentWhenPadding;
@property(nonatomic) struct CGSize maximumContentViewFrameSize; // @synthesize maximumContentViewFrameSize=_maxContentFrameSize;
- (BOOL)performKeyEquivalent:(id)arg1;
- (void)_invalidateLayoutBecauseOfSubviewFrameChange:(id)arg1;
- (void)willRemoveSubview:(id)arg1;
- (void)didAddSubview:(id)arg1;
- (void)windowWillClose:(id)arg1;
- (void)viewDidMoveToSuperview;
- (void)viewDidMoveToWindow;
- (void)viewWillMoveToSuperview:(id)arg1;
- (void)viewWillMoveToWindow:(id)arg1;
@property(readonly) BOOL isInstalled;
- (void)_viewDidInstall;
- (void)_viewWillUninstall;
@property(retain) NSView *contentView;
- (void)replaceSubview:(id)arg1 with:(id)arg2;
- (void)setSubviews:(id)arg1;
- (void)addSubview:(id)arg1;
- (void)layoutBottomUp;
- (void)layoutTopDown;
- (void)setFrameSize:(struct CGSize)arg1;
- (void)setTranslatesAutoresizingMaskIntoConstraints:(BOOL)arg1;
- (void)_syncContentViewTranslatesAutoresizingMaskIntoConstraintsValue;
- (void)updateConstraints;
- (void)setNextResponder:(id)arg1;
@property(retain, nonatomic) DVTViewController *viewController;
- (void)_checkKvoWindow;
@property(readonly) NSWindow *kvoWindow;
- (void)primitiveInvalidate;
- (id)initWithFrame:(struct CGRect)arg1;
- (void)awakeFromNib;
- (id)accessibilityAttributeValue:(id)arg1;
- (BOOL)accessibilityIsIgnored;

// Remaining properties
@property(retain) DVTStackBacktrace *creationBacktrace;
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;

@property(readonly) DVTStackBacktrace *invalidationBacktrace;
@property(readonly) Class superclass;
@property(readonly, nonatomic, getter=isValid) BOOL valid;

@end

