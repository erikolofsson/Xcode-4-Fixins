#import <Cocoa/Cocoa.h>
#include <Carbon/Carbon.h>
#import <objc/runtime.h>
#include "../Shared Code/XCFixin.h"

#import "XCFixin_EmulateVisualStudio_0900-Swift.h"

#import "XCFixin_EmulateVisualStudio.h"

#include <dlfcn.h>


#define LLDBFixesEnable false

enum EPreferredNextLocation
{
	EPreferredNextLocation_Undefined
	, EPreferredNextLocation_Search
	, EPreferredNextLocation_Issue
	, EPreferredNextLocation_Structure
	, EPreferredNextLocation_Console
};

typedef NSEvent* __nullable (^CNavigationHandler)(NSEvent*);

static IMP original_IDEFindNavigatorScopeChooserController_viewDidInstall = nil;
static IMP original_SourceEditor_SourceEditorView_pasteAndPreserveFormatting = nil;
static IMP original_SourceEditor_SourceEditorView_paste = nil;
static IMP original_SourceEditor_SourceEditorView_moveWordForward = nil;
static IMP original_SourceEditor_SourceEditorView_moveWordForwardAndModifySelection = nil;
static IMP original_SourceEditor_SourceEditorView_moveWordBackward = nil;
static IMP original_SourceEditor_SourceEditorView_moveWordBackwardAndModifySelection = nil;
static IMP original_SourceEditor_SourceEditorView_deleteWordForward = nil;
static IMP original_SourceEditor_SourceEditorView_deleteWordBackward = nil;


static IMP original_didSelectTabViewItem = nil;
static IMP original_mouseDownInConsole = nil;
static IMP original_becomeFirstResponder_Console = nil;
static IMP original_becomeFirstResponder_Search = nil;
static IMP original_becomeFirstResponder_NavigatorOutlineView = nil;
static IMP original_becomeFirstResponder_DVTFindPatternFieldEditor = nil;
static IMP original_resignFirstResponder_DVTFindPatternFieldEditor = nil;
static IMP original_menuItemWithKeyEquivalentMatchingEventRef = nil;
static IMP original_menuItemWithKeyEquivalentMatchingEventRef_macOS1012 = nil;
#if LLDBFixesEnable
static IMP original_LLDBLauncherStart = nil;
#endif
static IMP original_compositeEnvironmentVariables = nil;
static IMP original_filePathDidChangeWithPendingChangeDictionary = nil;
static IMP original_saveContainerForAction = nil;
static IMP original_resumeFilePathChangeNotifications = nil;
static IMP original_suspendFilePathChangeNotifications = nil;
static IMP original_updateOperationConcurrency = nil;
static IMP original_changeMaximumOperationConcurrencyUsingThrottleFactor = nil;
static IMP original_evaluatedStringListValueForMacroNamed = nil;
static IMP original_adjustedFileTypeForInputFileAtPath = nil;
static IMP original_compileSourceCodeFileAtPath = nil;
static IMP original_filteredBuildFileReferencesWithMacroExpansionScope = nil;

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface IDEContainer (EmulateVisualStudioIDEContainer)

@property (nonatomic, retain) NSNumber *generatedContainer;
@property (nonatomic, retain) NSNumber *lastBuilding;

@end

static void * EmulateVisualStudioIDEContainerKey_generatedContainer = &EmulateVisualStudioIDEContainerKey_generatedContainer;
static void * EmulateVisualStudioIDEContainerKey_lastBuilding = &EmulateVisualStudioIDEContainerKey_lastBuilding;

@implementation NSObject (EmulateVisualStudioIDEContainer)

- (NSNumber *)generatedContainer {
    return objc_getAssociatedObject(self, EmulateVisualStudioIDEContainerKey_generatedContainer);
}

- (void)setGeneratedContainer:(NSNumber *)generated {
    objc_setAssociatedObject(self, EmulateVisualStudioIDEContainerKey_generatedContainer, generated, OBJC_ASSOCIATION_RETAIN_NONATOMIC); 
}

- (NSNumber *)lastBuilding {
    return objc_getAssociatedObject(self, EmulateVisualStudioIDEContainerKey_lastBuilding);
}

- (void)setLastBuilding:(NSNumber *)generated {
    objc_setAssociatedObject(self, EmulateVisualStudioIDEContainerKey_lastBuilding, generated, OBJC_ASSOCIATION_RETAIN_NONATOMIC); 
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////


@interface NSWindow (EmulateVisualStudioNSWindow)

@property (nonatomic, retain) IDEFindNavigatorOutlineView *activeFindNavigatorOutlineView;
@property (nonatomic, retain) IDENavigatorOutlineView *activeNavigatorOutlineView;
@property (nonatomic, retain) IDEFindNavigator *activeFindNavigator;
@property (nonatomic, retain) IDEIssueNavigator *activeIssueNavigator;
@property (nonatomic, retain) IDEStructureNavigator *activeStructureNavigator;

@property (nonatomic, retain) DVTFindPatternFieldEditor *respondingPatternFieldEditor;
@property (nonatomic, retain) DVTFindBarOptionsCtrl *findBarOptionsCtrl;




@end

static void * EmulateVisualStudioNSWindow_activeFindNavigatorOutlineView = &EmulateVisualStudioNSWindow_activeFindNavigatorOutlineView;
static void * EmulateVisualStudioNSWindow_activeNavigatorOutlineView = &EmulateVisualStudioNSWindow_activeNavigatorOutlineView;
static void * EmulateVisualStudioNSWindow_activeFindNavigator = &EmulateVisualStudioNSWindow_activeFindNavigator;
static void * EmulateVisualStudioNSWindow_activeIssueNavigator = &EmulateVisualStudioNSWindow_activeIssueNavigator;
static void * EmulateVisualStudioNSWindow_activeStructureNavigator = &EmulateVisualStudioNSWindow_activeStructureNavigator;
static void * EmulateVisualStudioNSWindow_respondingPatternFieldEditor = &EmulateVisualStudioNSWindow_respondingPatternFieldEditor;
static void * EmulateVisualStudioNSWindow_findBarOptionsCtrl = &EmulateVisualStudioNSWindow_findBarOptionsCtrl;

@implementation NSWindow (EmulateVisualStudioNSWindowTabGroup)

- (IDEFindNavigatorOutlineView *)activeFindNavigatorOutlineView {
    return objc_getAssociatedObject(self, EmulateVisualStudioNSWindow_activeFindNavigatorOutlineView);
}
- (void)setActiveFindNavigatorOutlineView:(IDEFindNavigatorOutlineView *)value {
    objc_setAssociatedObject(self, EmulateVisualStudioNSWindow_activeFindNavigatorOutlineView, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (IDENavigatorOutlineView *)activeNavigatorOutlineView {
    return objc_getAssociatedObject(self, EmulateVisualStudioNSWindow_activeNavigatorOutlineView);
}
- (void)setActiveNavigatorOutlineView:(IDENavigatorOutlineView *)value {
    objc_setAssociatedObject(self, EmulateVisualStudioNSWindow_activeNavigatorOutlineView, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (IDEFindNavigator *)activeFindNavigator {
    return objc_getAssociatedObject(self, EmulateVisualStudioNSWindow_activeFindNavigator);
}
- (void)setActiveFindNavigator:(IDEFindNavigator *)value {
    objc_setAssociatedObject(self, EmulateVisualStudioNSWindow_activeFindNavigator, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (IDEIssueNavigator *)activeIssueNavigator {
    return objc_getAssociatedObject(self, EmulateVisualStudioNSWindow_activeIssueNavigator);
}
- (void)setActiveIssueNavigator:(IDEIssueNavigator *)value {
    objc_setAssociatedObject(self, EmulateVisualStudioNSWindow_activeIssueNavigator, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (IDEStructureNavigator *)activeStructureNavigator {
    return objc_getAssociatedObject(self, EmulateVisualStudioNSWindow_activeStructureNavigator);
}
- (void)setActiveStructureNavigator:(IDEStructureNavigator *)value {
    objc_setAssociatedObject(self, EmulateVisualStudioNSWindow_activeStructureNavigator, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (DVTFindPatternFieldEditor *)respondingPatternFieldEditor {
    return objc_getAssociatedObject(self, EmulateVisualStudioNSWindow_respondingPatternFieldEditor);
}
- (void)setRespondingPatternFieldEditor:(DVTFindPatternFieldEditor *)value {
    objc_setAssociatedObject(self, EmulateVisualStudioNSWindow_respondingPatternFieldEditor, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (IDEWorkspaceWindow *)findBarOptionsCtrl {
    return objc_getAssociatedObject(self, EmulateVisualStudioNSWindow_findBarOptionsCtrl);
}
- (void)setFindBarOptionsCtrl:(IDEWorkspaceWindow *)value {
    objc_setAssociatedObject(self, EmulateVisualStudioNSWindow_findBarOptionsCtrl, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////


@interface NSWindowTabGroup (EmulateVisualStudioNSWindowTabGroup)

@property (nonatomic, retain) IDEWorkspaceWindow *lastValidEditorWindow;
@property (nonatomic, retain) IDEConsoleTextView *lastConsoleTextView;

@property (nonatomic, assign) enum EPreferredNextLocation preferredNextLocation;

@end

static void * EmulateVisualStudioNSWindowTabGroup_lastValidEditorWindow = &EmulateVisualStudioNSWindowTabGroup_lastValidEditorWindow;
static void * EmulateVisualStudioNSWindowTabGroup_lastConsoleTextView = &EmulateVisualStudioNSWindowTabGroup_lastConsoleTextView;
static void * EmulateVisualStudioNSWindowTabGroup_preferredNextLocation = &EmulateVisualStudioNSWindowTabGroup_preferredNextLocation;

@implementation NSWindowTabGroup (EmulateVisualStudioNSWindowTabGroup)

- (IDEWorkspaceWindow *)lastValidEditorWindow {
    return objc_getAssociatedObject(self, EmulateVisualStudioNSWindowTabGroup_lastValidEditorWindow);
}

- (void)setLastValidEditorWindow:(IDEWorkspaceWindow *)value {
    objc_setAssociatedObject(self, EmulateVisualStudioNSWindowTabGroup_lastValidEditorWindow, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (IDEConsoleTextView *)lastConsoleTextView {
    return objc_getAssociatedObject(self, EmulateVisualStudioNSWindowTabGroup_lastConsoleTextView);
}

- (void)setLastConsoleTextView:(IDEConsoleTextView *)value {
    objc_setAssociatedObject(self, EmulateVisualStudioNSWindowTabGroup_lastConsoleTextView, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (enum EPreferredNextLocation)preferredNextLocation {
    NSNumber *pNumber = objc_getAssociatedObject(self, EmulateVisualStudioNSWindowTabGroup_preferredNextLocation);
	if (!pNumber)
		return EPreferredNextLocation_Undefined;

	return [pNumber intValue];
}

- (void)setPreferredNextLocation:(enum EPreferredNextLocation )value {
    objc_setAssociatedObject(self, EmulateVisualStudioNSWindowTabGroup_preferredNextLocation, [NSNumber numberWithInt:value], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////


@interface NSObject (EmulateVisualStudioNSObject)

@property (nonatomic, retain) NSNumber *displayCycleObserver_alreadyScheduled;
@property (nonatomic, retain) NSNumber *displayCycleObserver_lastDraw;
@property (nonatomic, retain) NSNumber *displayCycleObserver_sequence;

@end


static void * EmulateVisualStudioNSObjectKey_displayCycleObserver_alreadyScheduled = &EmulateVisualStudioNSObjectKey_displayCycleObserver_alreadyScheduled;
static void * EmulateVisualStudioNSObjectKey_displayCycleObserver_lastDraw = &EmulateVisualStudioNSObjectKey_displayCycleObserver_lastDraw;
static void * EmulateVisualStudioNSObjectKey_displayCycleObserver_sequence = &EmulateVisualStudioNSObjectKey_displayCycleObserver_sequence;

@implementation NSObject (EmulateVisualStudioNSObject)

- (NSNumber *)displayCycleObserver_alreadyScheduled {
    return objc_getAssociatedObject(self, EmulateVisualStudioNSObjectKey_displayCycleObserver_alreadyScheduled);
}

- (void)setDisplayCycleObserver_alreadyScheduled:(NSNumber *)generated {
    objc_setAssociatedObject(self, EmulateVisualStudioNSObjectKey_displayCycleObserver_alreadyScheduled, generated, OBJC_ASSOCIATION_RETAIN_NONATOMIC); 
}

- (NSNumber *)displayCycleObserver_lastDraw {
    return objc_getAssociatedObject(self, EmulateVisualStudioNSObjectKey_displayCycleObserver_lastDraw);
}

- (void)setDisplayCycleObserver_lastDraw:(NSNumber *)generated {
    objc_setAssociatedObject(self, EmulateVisualStudioNSObjectKey_displayCycleObserver_lastDraw, generated, OBJC_ASSOCIATION_RETAIN_NONATOMIC); 
}

- (NSNumber *)displayCycleObserver_sequence {
    return objc_getAssociatedObject(self, EmulateVisualStudioNSObjectKey_displayCycleObserver_sequence);
}

- (void)setDisplayCycleObserver_sequence:(NSNumber *)generated {
    objc_setAssociatedObject(self, EmulateVisualStudioNSObjectKey_displayCycleObserver_sequence, generated, OBJC_ASSOCIATION_RETAIN_NONATOMIC); 
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////


@interface NSView (SubtreeDescription)

- (NSString *)_subtreeDescription;

@end

/*@interface SwiftReflector
- (void)reflect: (id) object;
@end*/

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface NSView (FindUIViewController)
- (NSViewController *) firstAvailableResponderOfClass:(Class)ClassToFind;
- (id) traverseResponderChainForResponder:(Class)ClassToFind;
@end

@implementation NSView (FindUIViewController)
- (NSViewController *) firstAvailableResponderOfClass:(Class)ClassToFind {
    // convenience function for casting and to "mask" the recursive function
    return (NSViewController *)[self traverseResponderChainForResponder:ClassToFind];
}

- (id) traverseResponderChainForResponder:(Class)ClassToFind {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:ClassToFind]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[NSView class]]) {
        return [nextResponder traverseResponderChainForResponder:ClassToFind];
    } else {
        return nil;
    }
}
@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XCFixinXcodeVersioned(XCFixin_EmulateVisualStudio)
- (CNavigationHandler) registerNavigationHandler;
@end


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////


@interface XCFixinXcodeVersioned(XCFixin_EmulateVisualStudio) : NSObject<IDEContainerReloadingDelegate>
{
	id eventMonitor;
}
@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface NSObject (Private)
- (NSString*)_methodDescription;
@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface SourceEditor_SourceEditorView : NSView
- (void) replaceAndFindNext:(id) arg1;
- (void) replaceAndFindPrevious:(id) arg1;
- (void) replaceAll:(id) arg1;
- (void) useSelectionForFind:(id) arg1;
- (void) useSelectionForReplace:(id) arg1;
- (void) findAndReplace:(id) arg1;
- (void) hideFindBar:(id) arg1;
- (void) replace:(id) arg1;
- (void) find:(id) arg1;
- (void) findNext:(id) arg1;
- (void) findPrevious:(id) arg1;
- (void) deleteToBeginningOfText:(id) arg1;
- (void) moveCurrentLineUp:(id) arg1;
- (void) moveCurrentLineDown:(id) arg1;
- (void) indentSelection:(id) arg1;
- (void) moveToBeginningOfText:(id) arg1;
- (void) moveToBeginningOfTextAndModifySelection:(id) arg1;
- (void) moveToEndOfText:(id) arg1;
- (void) moveToEndOfTextAndModifySelection:(id) arg1;
- (void) deleteToEndOfText:(id) arg1;
- (void) pasteAndPreserveFormatting:(id) arg1;
- (void) paste:(id) arg1;
- (void) unfold:(id) arg1;
- (void) fold:(id) arg1;
- (void) moveForward: (id)arg;
- (void) moveBackward: (id)arg;
@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface IDEPegasusSourceEditor_SourceCodeEditorView: SourceEditor_SourceEditorView
@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface IDEPegasusSourceEditor_SourceCodeEditor : IDEEditor
- (NSRange)selectedLineRange;
- (NSArray *)currentSelectedDocumentLocations;
- (void)selectDocumentLocations: (NSArray *)array;
- (NSString *)selectedText;
- (IDEPegasusSourceEditor_SourceCodeEditorView *)sourceEditorView;
- (DVTAnnotationManager *) annotationManager;
- (void) toggleBreakpointAtCurrentLine:(id) arg1;
@end


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface SourceEditor_TextFindPanelViewController : NSViewController
/*
	 findPanel
	 replacePanel
	 findField
	 replaceField
	 nextPreviousControl
	 doneControl
	 replaceControl
	 panelModePopUp
	 panelModeSeparator
	 panelModeSeparatorHeightConstraint
	 matchesLabel
	 addPatternSeparator
	 addPatternSeparatorHeightConstraint
	 addPatternButton
	 caseSensitiveSeparator
	 caseSensitiveSeparatorHeightConstraint
	 caseSensitiveButton
	 searchPatternSeparator
	 searchPatternSeparatorHeightConstraint
	 searchPatternPopUp
	 replaceIcon
	 replaceFieldTitle
	 replaceFieldTitleSeparator
	 replaceFieldTitleSeparatorHeightConstraint
	 replacePanelHeightConstraint
	 client
	 recentQueries
	 colorTheme
	 controlFont
	 boldControlFont
	 miniControlFont
	 replacePanelExpandedHeight
	 mode
 */

 	- (id) findPatternField;
	- (id) replacePatternField;
	- (id) visualEffectView;
	- (id) findPanel;
	- (void) setFindPanel:(id) arg1;
	- (id) replacePanel;
	- (void) setReplacePanel:(id) arg1;
	- (void) setFindField:(id) arg1;
	- (void) setReplaceField:(id) arg1;
	- (id) nextPreviousControl;
	- (void) setNextPreviousControl:(id) arg1;
	- (id) doneControl;
	- (void) setDoneControl:(id) arg1;
	- (id) replaceControl;
	- (void) setReplaceControl:(id) arg1;
	- (id) panelModePopUp;
	- (void) setPanelModePopUp:(id) arg1;
	- (id) panelModeSeparator;
	- (void) setPanelModeSeparator:(id) arg1;
	- (id) panelModeSeparatorHeightConstraint;
	- (void) setPanelModeSeparatorHeightConstraint:(id) arg1;
	- (id) matchesLabel;
	- (void) setMatchesLabel:(id) arg1;
	- (id) addPatternSeparator;
	- (void) setAddPatternSeparator:(id) arg1;
	- (id) addPatternSeparatorHeightConstraint;
	- (void) setAddPatternSeparatorHeightConstraint:(id) arg1;
	- (id) addPatternButton;
	- (void) setAddPatternButton:(id) arg1;
	- (id) caseSensitiveSeparator;
	- (void) setCaseSensitiveSeparator:(id) arg1;
	- (id) caseSensitiveSeparatorHeightConstraint;
	- (void) setCaseSensitiveSeparatorHeightConstraint:(id) arg1;
	- (id) caseSensitiveButton;
	- (void) setCaseSensitiveButton:(id) arg1;
	- (id) searchPatternSeparator;
	- (void) setSearchPatternSeparator:(id) arg1;
	- (id) searchPatternSeparatorHeightConstraint;
	- (void) setSearchPatternSeparatorHeightConstraint:(id) arg1;
	- (id) searchPatternPopUp;
	- (void) setSearchPatternPopUp:(id) arg1;
	- (id) replaceIcon;
	- (void) setReplaceIcon:(id) arg1;
	- (id) replaceFieldTitle;
	- (void) setReplaceFieldTitle:(id) arg1;
	- (id) replaceFieldTitleSeparator;
	- (void) setReplaceFieldTitleSeparator:(id) arg1;
	- (id) replaceFieldTitleSeparatorHeightConstraint;
	- (void) setReplaceFieldTitleSeparatorHeightConstraint:(id) arg1;
	- (id) replacePanelHeightConstraint;
	- (void) setReplacePanelHeightConstraint:(id) arg1;
	- (id) panelModeMenuItems;
	- (void) toggleFindReplaceMode:(id) arg1;
	- (id) searchPatternMenuItems;
	- (id) recentsMenuItems;
	- (void) applyRecentQueryMenuItem:(id) arg1;
	- (void) clearRecentQueries;
	- (void) setNeedsContentUpdate;
	- (void) updateDisplayForColorTheme;
	- (void) startObservingPanelModePopUp;
	- (void) stopObservingPanelModePopUp;
	- (void) popUpButtonWillDisplay:(id) arg1;
	- (void) findFieldAction:(id) arg1;
	- (void) nextPreviousControlAction:(id) arg1;
	- (void) doneControlAction:(id) arg1;
	- (void) replaceAction:(id) arg1;
	- (void) addPatternButtonAction:(id) arg1;
	- (void) caseSensitiveButtonAction:(id) arg1;
	- (void) searchPatternPopUpAction:(id) arg1;
	- (void) themePanelModePopUp;
	- (void) themeClearFindButton;
	- (void) themeAddPatternButton;
	- (void) themeMatchesLabel;
	- (void) themeCaseSensitiveButton;
	- (void) themeSearchPatternPopUp;
	- (void) themeReplaceFieldTitle;
	- (void) themeSeparators;
	- (void) updateFieldInsets;
	- (void) updatePanelModePopUp;
	- (void) updateFindFieldWithForce: (char) arg1;
	- (void) updateReplaceField;
	- (void) updateCaseSentivityButtonState;
	- (void) updateSearchPatternPopUp;
	- (void) updateMatchesLabel;
	- (void) updateMatchesLabelVisibility;
	- (void) updateNextPreviousControl;
	- (void) updateReplaceControl;
	- (id) initWithCoder: (id) arg1;
	- (void) dealloc;
	- (char) control: (id) arg1 textView: (id) arg2 doCommandBySelector: (SEL) arg3;
	- (char) acceptsFirstResponder;
	- (char) becomeFirstResponder;
	- (id) initWithNibName: (id) arg1 bundle: (id) arg2;
	- (void) controlTextDidBeginEditing:(id) arg1;
	- (void) controlTextDidChange:(id) arg1;
	- (void) awakeFromNib;
	- (void) viewDidLayout;
	- (void) viewWillAppear;
	- (void) performTextFinderAction:(id) arg1;
	- (id) findField;
	- (id) replaceField;
@end

@implementation XCFixinXcodeVersioned(XCFixin_EmulateVisualStudio)

static IDEPegasusSourceEditor_SourceCodeEditor *getEditor(NSWindow* _pWindow)
{
	IDEWorkspaceTabController *pTabController = getWorkspaceTabController(_pWindow);
	if (!pTabController)
		return NULL;

	IDEEditorArea *editorArea = pTabController.editorArea;
	if (!editorArea)
		return NULL;

	IDEEditorContext *lastActiveEditorContext = editorArea.lastActiveEditorContext;
	if (!lastActiveEditorContext)
		return NULL;

	if ([lastActiveEditorContext.editor isKindOfClass:NSClassFromString(@"IDEPegasusSourceEditor.SourceCodeEditor")])
		return (IDEPegasusSourceEditor_SourceCodeEditor *)lastActiveEditorContext.editor;
	return NULL;
}

static void setEditorFocus(NSWindow* _pWindow)
{
	IDEEditor *editor = getEditor(_pWindow);
	if (!editor)
		return;

	[_pWindow makeKeyWindow];
	[editor takeFocus];
}

static XCFixinXcodeVersioned(XCFixin_EmulateVisualStudio) *singleton = nil;

#include "XCFixin_EmulateVisualStudio_Navigation.h"
#if LLDBFixesEnable
#	include "XCFixin_EmulateVisualStudio_LLDBFixes.h"
#endif
#include "XCFixin_EmulateVisualStudio_InterceptShortcuts.h"
#include "XCFixin_EmulateVisualStudio_ConsoleGoto.h"
#include "XCFixin_EmulateVisualStudio_DebugOptions.h"
#include "XCFixin_EmulateVisualStudio_BuildSystem.h"
#include "XCFixin_EmulateVisualStudio_ProjectReload.h"
#include "XCFixin_EmulateVisualStudio_Options.h"
#include "XCFixin_EmulateVisualStudio_PasteNoFormat.h"
#include "XCFixin_EmulateVisualStudio_MoveWord.h"

Class g_SourceEditorViewClass = nil;

- (void) applicationReady:(NSNotification*)notification {
	g_SourceEditorViewClass = NSClassFromString(@"SourceEditor.SourceEditorContentView");
	[self loadSettings];

	original_SourceEditor_SourceEditorView_pasteAndPreserveFormatting = XCFixinOverrideMethodString(@"SourceEditor.SourceEditorView", @selector(pasteAndPreserveFormatting:), (IMP)&SourceEditor_SourceEditorView_pasteAndPreserveFormatting);
	original_SourceEditor_SourceEditorView_paste = XCFixinOverrideMethodString(@"SourceEditor.SourceEditorView", @selector(paste:), (IMP)&SourceEditor_SourceEditorView_paste);
	original_SourceEditor_SourceEditorView_moveWordForward = XCFixinOverrideMethodString(@"SourceEditor.SourceEditorView", @selector(moveWordForward:), (IMP)&SourceEditor_SourceEditorView_moveWordForward);
	original_SourceEditor_SourceEditorView_moveWordForwardAndModifySelection = XCFixinOverrideMethodString(@"SourceEditor.SourceEditorView", @selector(moveWordForwardAndModifySelection:), (IMP)&SourceEditor_SourceEditorView_moveWordForwardAndModifySelection);
	original_SourceEditor_SourceEditorView_moveWordBackward = XCFixinOverrideMethodString(@"SourceEditor.SourceEditorView", @selector(moveWordBackward:), (IMP)&SourceEditor_SourceEditorView_moveWordBackward);
	original_SourceEditor_SourceEditorView_moveWordBackwardAndModifySelection = XCFixinOverrideMethodString(@"SourceEditor.SourceEditorView", @selector(moveWordBackwardAndModifySelection:), (IMP)&SourceEditor_SourceEditorView_moveWordBackwardAndModifySelection);
	original_SourceEditor_SourceEditorView_deleteWordForward = XCFixinOverrideMethodString(@"SourceEditor.SourceEditorView", @selector(deleteWordForward:), (IMP)&SourceEditor_SourceEditorView_deleteWordForward);
	original_SourceEditor_SourceEditorView_deleteWordBackward = XCFixinOverrideMethodString(@"SourceEditor.SourceEditorView", @selector(deleteWordBackward:), (IMP)&SourceEditor_SourceEditorView_deleteWordBackward);
}

- (id) init {
	self = [super init];
	if (self)
	{
#if LLDBFixesEnable
		g_LLDBLaunchLock = [[NSLock alloc] init];
#endif

		NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];

		if ([NSRunningApplication currentApplication].finishedLaunching) {
		  [self applicationReady:nil];
		}
		else {
		  [notificationCenter addObserver: self
								 selector: @selector( applicationReady: )
									 name: NSApplicationDidFinishLaunchingNotification
								   object: nil];

		}

		[notificationCenter addObserver: self
							   selector: @selector( frameChanged: )
								   name: NSViewFrameDidChangeNotification
								 object: nil];

		[notificationCenter addObserver: self
							   selector: @selector( windowDidBecomeKey: )
								   name: NSWindowDidBecomeKeyNotification
								 object: nil];

/*		[notificationCenter addObserver: self
							   selector: @selector( popoverDidShowNotification: )
								   name: NSPopoverDidShowNotification
								 object: nil];

		[notificationCenter addObserver: self
							   selector: @selector( popoverWillCloseNotification: )
								   name: NSPopoverWillCloseNotification
								 object: nil];*/

		eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler: [self registerNavigationHandler]];
	}
	return self;
}

- (void) dealloc {
	[NSEvent removeMonitor:eventMonitor];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void) pluginDidLoad:(NSBundle *)plugin
{
	if (singleton)
		return;
	XCFixinPreflight(true);

	singleton = [[XCFixinXcodeVersioned(XCFixin_EmulateVisualStudio) alloc] init];

	if (!singleton)
	{
		XCFixinLog(@"%s: Emulate visual studio init failed.\n",__FUNCTION__);
	}

	NSError *error = NULL;
	g_pSourceLocationColumnRegex = [NSRegularExpression regularExpressionWithPattern:@"^(.*?):([0-9]*):([0-9]*):?"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:&error];
	//DVTScrollableTabBarView, DVTTabBarView



/*	original_SourceEditor_SourceEditorView_pasteAndPreserveFormatting = XCFixinOverrideMethodString(@"SourceEditor.SourceEditorView", @selector(pasteAndPreserveFormatting:), (IMP)&SourceEditor_SourceEditorView_pasteAndPreserveFormatting);
	XCFixinAssertOrPerform(original_SourceEditor_SourceEditorView_pasteAndPreserveFormatting, goto failed);

	original_SourceEditor_SourceEditorView_paste = XCFixinOverrideMethodString(@"SourceEditor.SourceEditorView", @selector(paste:), (IMP)&SourceEditor_SourceEditorView_paste);
	XCFixinAssertOrPerform(original_SourceEditor_SourceEditorView_paste, goto failed);*/

	original_IDEFindNavigatorScopeChooserController_viewDidInstall = XCFixinOverrideMethodString(@"IDEFindNavigatorScopeChooserController", @selector(viewDidInstall), (IMP)&IDEFindNavigatorScopeChooserController_viewDidInstall);
	XCFixinAssertOrPerform(original_IDEFindNavigatorScopeChooserController_viewDidInstall, goto failed);

	original_didSelectTabViewItem = XCFixinOverrideMethodString(@"IDELocationCategoryPrefsPaneController", @selector(tabView:didSelectTabViewItem:), (IMP)&didSelectTabViewItem);
	XCFixinAssertOrPerform(original_didSelectTabViewItem, goto failed);

	original_mouseDownInConsole = XCFixinOverrideMethodString(@"IDEConsoleTextView", @selector(mouseDown:), (IMP)&mouseDownInConsole);
	XCFixinAssertOrPerform(original_mouseDownInConsole, goto failed);

	original_becomeFirstResponder_Console = XCFixinOverrideMethodString(@"IDEConsoleTextView", @selector(becomeFirstResponder), (IMP)&becomeFirstResponder_Console);
	XCFixinAssertOrPerform(original_becomeFirstResponder_Console, goto failed);

	original_becomeFirstResponder_Search = XCFixinOverrideMethodString(@"IDEProgressSearchField", @selector(becomeFirstResponder), (IMP)&becomeFirstResponder_Search);
	XCFixinAssertOrPerform(original_becomeFirstResponder_Search, goto failed);

	original_becomeFirstResponder_NavigatorOutlineView = XCFixinOverrideMethodString(@"IDENavigatorOutlineView", @selector(becomeFirstResponder), (IMP)&becomeFirstResponder_NavigatorOutlineView);
	XCFixinAssertOrPerform(original_becomeFirstResponder_NavigatorOutlineView, goto failed);

	original_becomeFirstResponder_DVTFindPatternFieldEditor = XCFixinOverrideMethodString(@"DVTFindPatternFieldEditor", @selector(becomeFirstResponder), (IMP)&becomeFirstResponder_DVTFindPatternFieldEditor);
	XCFixinAssertOrPerform(original_becomeFirstResponder_DVTFindPatternFieldEditor, goto failed);

	original_resignFirstResponder_DVTFindPatternFieldEditor = XCFixinOverrideMethodString(@"DVTFindPatternFieldEditor", @selector(resignFirstResponder), (IMP)&resignFirstResponder_DVTFindPatternFieldEditor);
	XCFixinAssertOrPerform(original_resignFirstResponder_DVTFindPatternFieldEditor, goto failed);

	original_menuItemWithKeyEquivalentMatchingEventRef = XCFixinOverrideStaticMethodString(@"NSCarbonMenuImpl", @selector(_menuItemWithKeyEquivalentMatchingEventRef:inMenu:), (IMP)&menuItemWithKeyEquivalentMatchingEventRef);
	original_menuItemWithKeyEquivalentMatchingEventRef_macOS1012 = XCFixinOverrideStaticMethodString(@"NSCarbonMenuImpl", @selector(_menuItemWithKeyEquivalentMatchingEventRef:inMenu:includingDisabledItems:), (IMP)&menuItemWithKeyEquivalentMatchingEventRef_macOS1012);

	XCFixinAssertOrPerform(original_menuItemWithKeyEquivalentMatchingEventRef || original_menuItemWithKeyEquivalentMatchingEventRef_macOS1012, goto failed);

#if LLDBFixesEnable
	{
		id pDebuggerExtension = [NSClassFromString(@"DBGLLDBDebugLocalService") _loadDebuggerExtension];

		if (pDebuggerExtension)
		{
			id pWorkerClass = [pDebuggerExtension valueForKey:@"workerClass"];
			(void)pWorkerClass;
		}
	}

	original_LLDBLauncherStart = XCFixinOverrideMethodString(@"DBGLLDBLauncher", @selector(start), (IMP)&LLDBLauncherStart);
	XCFixinAssertOrPerform(original_LLDBLauncherStart, goto failed);
#endif

	original_compositeEnvironmentVariables = XCFixinOverrideMethodString(@"IDERunOperationPathWorker", @selector(compositeEnvironmentVariables), (IMP)&compositeEnvironmentVariables);
	XCFixinAssertOrPerform(original_compositeEnvironmentVariables, goto failed);

	original_filePathDidChangeWithPendingChangeDictionary = XCFixinOverrideMethodString(@"IDEContainer", @selector(_filePathDidChangeWithPendingChangeDictionary), (IMP)&_filePathDidChangeWithPendingChangeDictionary);
	XCFixinAssertOrPerform(original_filePathDidChangeWithPendingChangeDictionary, goto failed);

	original_saveContainerForAction = XCFixinOverrideMethodString(@"IDEContainer", @selector(_saveContainerForAction:error:), (IMP)&_saveContainerForAction);
	XCFixinAssertOrPerform(original_saveContainerForAction, goto failed);

	original_resumeFilePathChangeNotifications = XCFixinOverrideStaticMethodString(@"IDEContainer", @selector(resumeFilePathChangeNotifications), (IMP)&resumeFilePathChangeNotifications);
	XCFixinAssertOrPerform(original_resumeFilePathChangeNotifications, goto failed);

	original_suspendFilePathChangeNotifications = XCFixinOverrideStaticMethodString(@"IDEContainer", @selector(suspendFilePathChangeNotifications), (IMP)&suspendFilePathChangeNotifications);
	XCFixinAssertOrPerform(original_suspendFilePathChangeNotifications, goto failed);

	original_updateOperationConcurrency = XCFixinOverrideMethodString(@"IDEBuildOperationQueueSet", @selector(updateOperationConcurrency), (IMP)&updateOperationConcurrency);
	XCFixinAssertOrPerform(original_updateOperationConcurrency, goto failed);

	original_changeMaximumOperationConcurrencyUsingThrottleFactor = XCFixinOverrideMethodString(@"IDEBuildOperationQueueSet", @selector(changeMaximumOperationConcurrencyUsingThrottleFactor:), (IMP)&changeMaximumOperationConcurrencyUsingThrottleFactor);
	XCFixinAssertOrPerform(original_changeMaximumOperationConcurrencyUsingThrottleFactor, goto failed);

	original_evaluatedStringListValueForMacroNamed = XCFixinOverrideMethodString(@"DVTMacroExpansionScope", @selector(evaluatedStringListValueForMacroNamed:), (IMP)&evaluatedStringListValueForMacroNamed);
	XCFixinAssertOrPerform(original_evaluatedStringListValueForMacroNamed, goto failed);

	original_adjustedFileTypeForInputFileAtPath = XCFixinOverrideMethodString(@"XCCompilerSpecification", @selector(adjustedFileTypeForInputFileAtPath:originalFileType:withMacroExpansionScope:), (IMP)&adjustedFileTypeForInputFileAtPath);
	XCFixinAssertOrPerform(original_adjustedFileTypeForInputFileAtPath, goto failed);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
	original_compileSourceCodeFileAtPath = XCFixinOverrideMethodString(@"PBXCompilerSpecificationGcc2_95_2", @selector(compileSourceCodeFileAtPath: ofType: toOutputDirectory: withMacroExpansionScope:), (IMP)&compileSourceCodeFileAtPath);
	XCFixinAssertOrPerform(original_compileSourceCodeFileAtPath, goto failed);
#pragma clang diagnostic pop

	original_filteredBuildFileReferencesWithMacroExpansionScope = XCFixinOverrideMethodString(@"XCBuildPhaseDGSnapshot", @selector(filteredBuildFileReferencesWithMacroExpansionScope:), (IMP)&filteredBuildFileReferencesWithMacroExpansionScope);
	XCFixinAssertOrPerform(original_filteredBuildFileReferencesWithMacroExpansionScope, goto failed);

	XCFixinPostflight();
}

@end
