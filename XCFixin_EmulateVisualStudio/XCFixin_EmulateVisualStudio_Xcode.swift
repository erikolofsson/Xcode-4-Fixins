import Foundation
import Cocoa
import ObjectiveC.runtime
import Swift
import ObjectiveC
import Dispatch

/*
public func getLocalSymbol<T>( _ module: String, _ mangledName: String  ) -> T
{
	let localSymbol = fg_GetLocalSymbol(module, mangledName);
	print("localSymbol: ", localSymbol);
	print("Type: ", T.self, "Size: ", MemoryLayout<T>.size);
	return unsafeBitCast(localSymbol, to: T.self);
}
*/

// Mirror for SourceCodeEditorView
public class IDEPegasusSourceEditor {
}
extension IDEPegasusSourceEditor { 
public class SourceCodeEditorView: SourceEditor.SourceEditorView {
    var hostingEditor: Optional<IDEPegasusSourceEditor.SourceCodeEditor> = nil;
    var completionController: ImplicitlyUnwrappedOptional<DVTTextCompletionController> = nil;
    var realCompletionsDataSource: Optional<DVTTextCompletionDataSource> = nil;
    var sharedFindStringNotificationToken: Optional<NSObject> = nil;
    var sharedReplaceStringNotificationToken: Optional<NSObject> = nil;
    var sharedFindOptionsNotificationToken: Optional<NSObject> = nil;
    var isPushingFindConfiguration: Bool = false;
    var isPullingFindConfiguration: Bool = false;
    var markedVerticalScroller: DVTMarkedScroller = DVTMarkedScroller();
    var updateMarkedVerticalScrollerContinuation: Optional<SourceEditor.TimeoutContinuation> = nil;
}
}
// Mirror for SourceEditorView
public class SourceEditor { 
}
extension SourceEditor { 
@objc public class SourceEditorView: NSView {

	var delegate: Optional<SourceEditor.SourceEditorViewDelegate> = nil; // Offset 0x98   Size 16
    var delegate_dummy0: UInt64 = 0;
    var contentViewOffset: CoreGraphics.CGFloat = CoreGraphics.CGFloat(); // Offset 0xa8   Size 8
    var layoutManager: SourceEditor.SourceEditorLayoutManager = SourceEditor.SourceEditorLayoutManager(); // Offset 0xb0   Size 8
    var contentView: SourceEditor.SourceEditorContentView = SourceEditor.SourceEditorContentView(); // Offset 0xb8   Size 8
    var scrollView: SourceEditorScrollView = SourceEditorScrollView(); // Offset 0xc0   Size 8
    var editAssistant: SourceEditor.SourceEditorEditAssistant = SourceEditor.SourceEditorEditAssistant(); // Offset 0xc8   Size 8
    var structuredEditingController: Optional<SourceEditor.StructuredEditingController> = nil; // Offset 0xd0   Size 8
    var foldingController: SourceEditor.FoldingController = SourceEditor.FoldingController(); // Offset 0xd8   Size 8
    var dataSource: SourceEditor.SourceEditorDataSource = SourceEditor.SourceEditorDataSource(); // Offset 0xe0   Size 8
    var boundsChangeObserver: Optional<Any> = nil; // Offset 0xe8   Size 40
    var frameChangeObserver: Optional<Any> = nil; // Offset 0x110   Size 40
    var contentViewWidthConstraint: NSLayoutConstraint = NSLayoutConstraint(); // Offset 0x138   Size 8
    var contentViewWidthLimitConstraint: NSLayoutConstraint = NSLayoutConstraint(); // Offset 0x140   Size 8
    var contentViewHeightConstraint: NSLayoutConstraint = NSLayoutConstraint(); // Offset 0x148   Size 8
    var contentViewHeightLimitConstraint: NSLayoutConstraint = NSLayoutConstraint(); // Offset 0x150   Size 8
    var trimTrailingWhitespaceController: Optional<SourceEditor.TrimTrailingWhitespaceController> = nil; // Offset 0x158   Size 8
    var automaticallyAdjustsContentMargins: Bool = false; // Offset 0x160   Size 8
    var lineAnnotationManager: Optional<SourceEditor.SourceEditorLineAnnotationManager> = nil; // Offset 0x168   Size 8
    var gutter: Optional<SourceEditor.SourceEditorGutter> = nil; // Offset 0x170   Size 8
    var draggingSource: SourceEditor.SourceEditorViewDraggingSource = SourceEditor.SourceEditorViewDraggingSource(); // Offset 0x178   Size 8
    var registeredDraggingExtensions: Dictionary<String, SourceEditor.SourceEditorViewDraggingExtension> = Dictionary<String, SourceEditor.SourceEditorViewDraggingExtension>(); // Offset 0x180   Size 8
    var textFindableDisplay: Optional<SourceEditor.TextFindableDisplay> = nil; // Offset 0x188   Size 8
    var textFindPanel: Optional<SourceEditor.TextFindPanel> = nil; // Offset 0x190   Size 16
    var textFindPanel_dummy0: UInt64 = 0;
    var textFindPanelDisplayed: Bool = false; // Offset 0x1a0   Size 8
    var findQuery: SourceEditor.TextFindQuery = SourceEditor.TextFindQuery(); // Offset 0x1a8   Size 48
    var findQuery_dummy0: UInt64 = 0;
    var findQuery_dummy1: UInt64 = 0;
    var findQuery_dummy2: UInt64 = 0;
    var findQuery_dummy3: UInt64 = 0;
    var findResult: Optional<SourceEditor.TextFindResult> = nil; // Offset 0x1d8   Size 48
    var findResult_dummy0: UInt64 = 0;
    var findResult_dummy1: UInt64 = 0;
    var findResult_dummy2: UInt64 = 0;
    var findResult_dummy3: UInt64 = 0;
    var findResult_dummy4: UInt64 = 0;
    var findReplaceWith: Optional<SourceEditor.TextFindValue> = nil; // Offset 0x208   Size 41
    var findReplaceWith_dummy0: UInt64 = 0;
    var findReplaceWith_dummy1: UInt64 = 0;
    var findReplaceWith_dummy2: UInt64 = 0;
    var findReplaceWith_dummy3: UInt64 = 0;
    var findResultNeedUpdate: Bool = false; // Offset 0x231   Size 7
    var selectedSymbolHighlight: Optional<SourceEditor.SelectedSymbolHighlight> = nil; // Offset 0x238   Size 8
    var lineHighlightLayoutVisualization: SourceEditor.LineHighlightLayoutVisualization = SourceEditor.LineHighlightLayoutVisualization(); // Offset 0x240   Size 8
    var delimiterHighlight: Optional<SourceEditor.DelimiterHighlight> = nil; // Offset 0x248   Size 8
    var coverageLayoutVisualization: Optional<SourceEditor.CodeCoverageVisualization> = nil; // Offset 0x250   Size 8
    var isEditingEnabled: Bool = false; // Offset 0x258   Size 8
    var selectionController: Optional<SourceEditor.SourceEditorSelectionController> = nil; // Offset 0x260   Size 8
    var selectionDisplay: SourceEditor.SourceEditorSelectionDisplay = SourceEditor.SourceEditorSelectionDisplay(); // Offset 0x268   Size 8
    var selection: Optional<SourceEditor.SourceEditorSelection> = nil; // Offset 0x270   Size 48
    var selection_dummy0: UInt64 = 0;
    var oldSubstitutionView: Optional<SourceEditor.SourceEditorSizableAssociatedView> = nil; // Offset 0x2a0   Size 16
    var oldSubstitutionView_dummy0: UInt64 = 0;
    var calloutVisualization: Optional<SourceEditor.RangePopLayoutVisualization> = nil; // Offset 0x2b0   Size 8
    var isCodeCompletionEnabled: Bool = false; // Offset 0x2b8   Size 8
    var languageServiceCompletionStrategy: Optional<SourceEditor.LanguageServiceCodeCompletionStrategy> = nil; // Offset 0x2c0   Size 8
    var codeCompletionController: Optional<SourceEditor.SourceEditorCodeCompletionController> = nil; // Offset 0x2c8   Size 8
    var currentListShownExplicitly: Bool = false; // Offset 0x2d0   Size 8
    var currentListWordStart: Optional<SourceEditor.SourceEditorPosition> = nil; // Offset 0x2e9   Size 7
    var shouldProvideCodeCompletion: Bool = false;
    var markedSourceRange: Optional<SourceEditor.SourceEditorRange> = nil; // Offset 0x2f0   Size 40
    var markedSourceSelection: Optional<SourceEditor.SourceEditorRange> = nil; // Offset 0x318   Size 33
    var markedEditTransaction: Bool = false; // Offset 0x339   Size 7
    var asyncContinuations: SourceEditor.ContinuationScheduler = SourceEditor.ContinuationScheduler(); // Offset 0x340   Size 8
    var postLayoutContinuations: SourceEditor.ContinuationScheduler = SourceEditor.ContinuationScheduler(); // Offset 0x348   Size 8
    var emacsMarkedSourceRange: Optional<SourceEditor.SourceEditorRange> = nil; // Offset 0x350   Size 33
    var continueKillRing: Bool = false; // Offset 0x371   Size 7
    var contextualMenuEventConsumer: SourceEditor.ContextualMenuEventConsumer = SourceEditor.ContextualMenuEventConsumer(); // Offset 0x378   Size 8
    var contextualMenuItemProvider: Optional<SourceEditor.SourceEditorViewContextualMenuItemProvider> = nil; // Offset 0x380   Size 16
    var contextualMenuItemProvider_dummy0: UInt64 = 0;
    var structuredSelectionDelegate: Optional<SourceEditor.SourceEditorViewStructuredSelectionDelegate> = nil; // Offset 0x390   Size 16
    var structuredSelectionDelegate_dummy0: UInt64 = 0;
    var eventConsumers: Array<SourceEditor.SourceEditorViewEventConsumer> = Array<SourceEditor.SourceEditorViewEventConsumer>(); // Offset 0x3a0   Size 8
    var editing: Bool = false; // Offset 0x3a8   Size 1
    var isInLiveResize: Bool = false; // Offset 0x3a9   Size 1
    var contentSizeIsValid: Bool = false; // Offset 0x3aa   Size 6
    var contentSize: CoreGraphics.CGFloat = CoreGraphics.CGFloat(); // Offset 0x3b0   Size 8
    var annotationsAccessibilityGroup_: Optional<SourceEditor.AnnotationsAccessibilityGroup> = nil; // Offset 0x3b8   Size 0

}
}
// Mirror for TextFindableDisplay
extension SourceEditor { 
public class TextFindableDisplay {
    var sourceEditorView: Optional<SourceEditor.SourceEditorView> = nil;
    var layoutVisualizations: Optional<Array<SourceEditor.LayoutVisualization>> = nil;
    var textAttributeOverrideProviders: Optional<Array<SourceEditor.TextAttributeOverrideProvider>> = nil;
    var attributeOverrideProvider: SourceEditor.TextFindableAttributeOverrideProvider = SourceEditor.TextFindableAttributeOverrideProvider();
    var matchingRangesLayoutVisualization: SourceEditor.TextFindableResultLayoutVisualization = SourceEditor.TextFindableResultLayoutVisualization();
    var activeRangeLayoutVisualization: SourceEditor.RangePopLayoutVisualization = SourceEditor.RangePopLayoutVisualization();
    var findResult: Optional<SourceEditor.TextFindResult> = nil;
    var findResultDisplayMode: SourceEditor.TextFindResultDisplayMode = SourceEditor.TextFindResultDisplayMode();
}
}
// Mirror for SourceEditorLineAnnotationManager
extension SourceEditor { 
public class SourceEditorLineAnnotationManager {
    var sourceEditorView: Optional<SourceEditor.SourceEditorView> = nil;
    var interactionDelegate: Optional<SourceEditor.SourceEditorLineAnnotationInteractionDelegate> = nil;
    var annotations: Array<SourceEditor.SourceEditorLineAnnotation> = Array<SourceEditor.SourceEditorLineAnnotation>();
    var interaction: Optional<SourceEditor.SourceEditorLineAnnotation.Interaction> = nil;
    var annotationGroupsByLine: Dictionary<SourceEditor.SourceEditorLineIdentifier, Array<SourceEditor.SourceEditorLineAnnotationGroup>> = Dictionary<SourceEditor.SourceEditorLineIdentifier, Array<SourceEditor.SourceEditorLineAnnotationGroup>>();
    var allowAnimations: Bool = false;
    var lineAnnotationLayouts: Dictionary<SourceEditor.SourceEditorLineIdentifier, SourceEditor.SourceEditorLineAnnotationLayout> = Dictionary<SourceEditor.SourceEditorLineIdentifier, SourceEditor.SourceEditorLineAnnotationLayout>();
    var previousLineAnnotationLayouts: Dictionary<SourceEditor.SourceEditorLineIdentifier, SourceEditor.SourceEditorLineAnnotationLayout> = Dictionary<SourceEditor.SourceEditorLineIdentifier, SourceEditor.SourceEditorLineAnnotationLayout>();
    var lineAnnotationInsetForVerticalScroller: CoreGraphics.CGFloat = CoreGraphics.CGFloat();
    var displayedDropdown: Optional<(dropdown: SourceEditor.SourceEditorLineAnnotationDropdown, lineAnnotationView: SourceEditor.SourceEditorLineAnnotationView)> = nil;
    var fontTheme: ImplicitlyUnwrappedOptional<SourceEditor.SourceEditorFontTheme> = nil;
    var colorTheme: ImplicitlyUnwrappedOptional<SourceEditor.SourceEditorColorTheme> = nil;
}
}
// Mirror for TextFindPanelViewController
extension SourceEditor { 
public class TextFindPanelViewController: NSViewController {
    var findPanel: ImplicitlyUnwrappedOptional<NSView> = nil;
    var replacePanel: ImplicitlyUnwrappedOptional<NSView> = nil;
    var findField: ImplicitlyUnwrappedOptional<SourceEditor.TextFindField> = nil;
    var replaceField: ImplicitlyUnwrappedOptional<SourceEditor.TextReplaceField> = nil;
    var nextPreviousControl: ImplicitlyUnwrappedOptional<NSSegmentedControl> = nil;
    var doneControl: ImplicitlyUnwrappedOptional<NSSegmentedControl> = nil;
    var replaceControl: ImplicitlyUnwrappedOptional<NSSegmentedControl> = nil;
    var panelModePopUp: ImplicitlyUnwrappedOptional<SourceEditor.TextFindPopUpButton> = nil;
    var panelModeSeparator: ImplicitlyUnwrappedOptional<NSView> = nil;
    var panelModeSeparatorHeightConstraint: ImplicitlyUnwrappedOptional<NSLayoutConstraint> = nil;
    var matchesLabel: ImplicitlyUnwrappedOptional<NSTextField> = nil;
    var addPatternSeparator: ImplicitlyUnwrappedOptional<NSView> = nil;
    var addPatternSeparatorHeightConstraint: ImplicitlyUnwrappedOptional<NSLayoutConstraint> = nil;
    var addPatternButton: ImplicitlyUnwrappedOptional<NSButton> = nil;
    var caseSensitiveSeparator: ImplicitlyUnwrappedOptional<NSView> = nil;
    var caseSensitiveSeparatorHeightConstraint: ImplicitlyUnwrappedOptional<NSLayoutConstraint> = nil;
    var caseSensitiveButton: ImplicitlyUnwrappedOptional<SourceEditor.TextFindTextButton> = nil;
    var searchPatternSeparator: ImplicitlyUnwrappedOptional<NSView> = nil;
    var searchPatternSeparatorHeightConstraint: ImplicitlyUnwrappedOptional<NSLayoutConstraint> = nil;
    var searchPatternPopUp: ImplicitlyUnwrappedOptional<SourceEditor.TextFindPopUpButton> = nil;
    var replaceIcon: ImplicitlyUnwrappedOptional<NSImageView> = nil;
    var replaceFieldTitle: ImplicitlyUnwrappedOptional<NSTextField> = nil;
    var replaceFieldTitleSeparator: ImplicitlyUnwrappedOptional<NSView> = nil;
    var replaceFieldTitleSeparatorHeightConstraint: ImplicitlyUnwrappedOptional<NSLayoutConstraint> = nil;
    var replacePanelHeightConstraint: ImplicitlyUnwrappedOptional<NSLayoutConstraint> = nil;
    var client: Optional<SourceEditor.TextFindableDisplayable> = nil;
    var recentQueries: Array<SourceEditor.TextFindQuery> = Array<SourceEditor.TextFindQuery>();
    var colorTheme: IDEPegasusSourceEditor.SourceEditorTheme = IDEPegasusSourceEditor.SourceEditorTheme();
    var controlFont: NSFont = NSFont();
    var boldControlFont: NSFont = NSFont();
    var miniControlFont: NSFont = NSFont();
    var replacePanelExpandedHeight: CoreGraphics.CGFloat = CoreGraphics.CGFloat();
    var mode: SourceEditor.TextFindPanelMode = SourceEditor.TextFindPanelMode();
}
}
// Mirror for SourceEditorGutter
extension SourceEditor { 
public class SourceEditorGutter: NSObject {
    var sourceEditorView: Optional<SourceEditor.SourceEditorView> = nil;
    var interactionDelegate: Optional<SourceEditor.SourceEditorGutterInteractionDelegate> = nil;
    var annotationInteractionDelegate: Optional<SourceEditor.SourceEditorGutterAnnotationInteractionDelegate> = nil;
    var backgroundView: SourceEditor.SourceEditorGutterMarginBackgroundView = SourceEditor.SourceEditorGutterMarginBackgroundView();
    var contentView: SourceEditor.SourceEditorGutterMarginContentView = SourceEditor.SourceEditorGutterMarginContentView();
    var marginAnchor: SourceEditor.SourceEditorMarginAccessoryAnchor = SourceEditor.SourceEditorMarginAccessoryAnchor();
    var marginBackgroundView: Optional<NSView> = nil;
    var marginContentView: Optional<NSView> = nil;
}
}
// Mirror for TextFindQuery
extension SourceEditor { 
struct TextFindQuery {
    init() {
    }
    var find: Optional<SourceEditor.TextFindValue> = nil;
    var isCaseSensitive: Bool = false;
    var pattern: SourceEditor.TextFindPattern = SourceEditor.TextFindPattern();
}
}
// Mirror for SourceEditorSelectionController
extension SourceEditor { 
public class SourceEditorSelectionController {
    var sourceEditorView: Optional<SourceEditor.SourceEditorView> = nil;
    var mouseSelectionSession: Optional<SourceEditor.SourceEditorMouseSelectionSession> = nil;
    var selectionAnchor: Optional<SourceEditor.SourceEditorRange> = nil;
    var verticalAnchor: Optional<SourceEditor.SourceEditorVerticalAnchor> = nil;
    var mouseSelectionAnchor: Optional<SourceEditor.SourceEditorRange> = nil;
    var originalMouseSelectionAnchor: Optional<SourceEditor.SourceEditorRange> = nil;
    var mouseSelectionExpressionAnchor: Optional<SourceEditor.SourceEditorRange> = nil;
    var mouseSelectionGranularity: SourceEditor.TextGranularityType = SourceEditor.TextGranularityType();
    var scrollTimer: Optional<SourceEditor.TimeoutContinuation> = nil;
}
}
// Mirror for CGFloat
// Mirror for TrimTrailingWhitespaceController
extension SourceEditor { 
public class TrimTrailingWhitespaceController {
    var style: SourceEditor.TrimTrailingWhitespaceStyle = SourceEditor.TrimTrailingWhitespaceStyle();
    var isTrimming: Bool = false;
    var editedLines: Set<SourceEditor.SourceEditorLineIdentifier> = Set<SourceEditor.SourceEditorLineIdentifier>();
    var dataSource: Optional<SourceEditor.SourceEditorDataSource> = nil;
}
}
// Mirror for SourceEditorScrollView
public class SourceEditorScrollView: NSScrollView {
}
// Mirror for SourceEditorLayoutManager
extension SourceEditor { 
public class SourceEditorLayoutManager {
    var dataSource: Optional<SourceEditor.SourceEditorDataSource> = nil;
    var delegate: Optional<SourceEditor.SourceEditorLayoutManagerDelegate> = nil;
    var container: Optional<SourceEditor.SourceEditorLayoutContainer> = nil;
    var fontTheme: IDEPegasusSourceEditor.SourceEditorTheme = IDEPegasusSourceEditor.SourceEditorTheme();
    var colorTheme: IDEPegasusSourceEditor.SourceEditorTheme = IDEPegasusSourceEditor.SourceEditorTheme();
    var showInvisiblesTheme: Optional<SourceEditor.ShowInvisiblesTheme> = nil;
    var showInvisiblesOverlayProvider: Optional<SourceEditor.InvisibleCharactersOverlayProvider> = nil;
    var fontSmoothingAttributes: SourceEditor.SourceEditorFontSmoothingAttributes = SourceEditor.SourceEditorFontSmoothingAttributes();
    var textRenderingColorSpace: Optional<CGColorSpace> = nil;
    var _spaceWidth: Optional<CoreGraphics.CGFloat> = nil;
    var _paragraphStyle: Optional<NSParagraphStyle> = nil;
    var currentLayoutPassBoundsWidth: Optional<CoreGraphics.CGFloat> = nil;
    var lineSpacing: Optional<CoreGraphics.CGFloat> = nil;
    var lineWrappingStyle: Optional<SourceEditor.LineWrappingStyle> = nil;
    var avoidCroppedLayout: Bool = false;
    var lineExpansionEffects: Dictionary<Int, CoreGraphics.CGFloat> = Dictionary<Int, CoreGraphics.CGFloat>();
    var lineShiftEffects: Dictionary<Int, CGPoint> = Dictionary<Int, CGPoint>();
    var lineShiftCompensationEffects: Dictionary<Int, Int> = Dictionary<Int, Int>();
    var columnExpansionEffects: Dictionary<Int, Dictionary<Int, CoreGraphics.CGFloat>> = Dictionary<Int, Dictionary<Int, CoreGraphics.CGFloat>>();
    var columnShiftEffects: Dictionary<Int, Dictionary<Int, (shift: SourceEditor.LineLayoutColumnShift, padding: CoreGraphics.CGFloat, text: Optional<NSAttributedString>)>> = Dictionary<Int, Dictionary<Int, (shift: SourceEditor.LineLayoutColumnShift, padding: CoreGraphics.CGFloat, text: Optional<NSAttributedString>)>>();
    var textHighlightPaths: Array<(CGPath, CGPoint)> = Array<(CGPath, CGPoint)>();
    var layoutVisualizations: Array<SourceEditor.LayoutVisualization> = Array<SourceEditor.LayoutVisualization>();
    var marginAccessories: Array<SourceEditor.SourceEditorMarginAccessory> = Array<SourceEditor.SourceEditorMarginAccessory>();
    var layoutOverrideProviders: Array<SourceEditor.LayoutOverrideProvider> = Array<SourceEditor.LayoutOverrideProvider>();
    var additionalLineSpacing: CoreGraphics.CGFloat = CoreGraphics.CGFloat();
    var previouslyVisibleAuxAndSubstitutionViews: Set<NSView> = Set<NSView>();
    var visibleAuxAndSubstitutionViews: Set<NSView> = Set<NSView>();
    var separatorViews: Array<NSView> = Array<NSView>();
    var separatorViewLayoutCursor: Int = 0;
    var layoutStrategy: SourceEditor.ViewportLayoutStrategy = SourceEditor.ViewportLayoutStrategy();
    var dataSourceObserver: Optional<SourceEditor.LayoutManagerDataSourceObserver> = nil;
    var identifier: Optional<SourceEditor.SourceEditorLayoutManagerIdentifier> = nil;
}
}
// Mirror for SourceEditorEditAssistant
extension SourceEditor { 
public class SourceEditorEditAssistant {
    var dataSource: Optional<SourceEditor.SourceEditorDataSource> = nil;
    var layoutManager: Optional<SourceEditor.SourceEditorLayoutManager> = nil;
    var multiCursorController: Optional<SourceEditor.MultiCursorController> = nil;
    var postProcessOperations: Array<SourceEditor.EditAssistantPostProcessOperation> = Array<SourceEditor.EditAssistantPostProcessOperation>();
    var preProcessOperations: Array<SourceEditor.EditAssistantPreProcessOperation> = Array<SourceEditor.EditAssistantPreProcessOperation>();
    var transactionNesting: Int = 0;
    var enablePreAndPostProcessing: Bool = false;
}
}
// Mirror for SourceCodeEditor
extension IDEPegasusSourceEditor { 
public class SourceCodeEditor: IDEEditor {
    var sourceEditorView: ImplicitlyUnwrappedOptional<IDEPegasusSourceEditor.SourceCodeEditorView> = nil;
    var containerView: ImplicitlyUnwrappedOptional<NSView> = nil;
    var controllerContentView: ImplicitlyUnwrappedOptional<IDEPegasusSourceEditor.AutoLayoutSyncedControllerContentView> = nil;
    var contentGenerationBackgroundView: Optional<NSBox> = nil;
    var messageView: Optional<NSView> = nil;
    var progressIndicator: Optional<NSProgressIndicator> = nil;
    var progressIndicatorDisplayTime: Double = Double();
    var refactoringController: IDEPegasusSourceEditor.RefactoringController = IDEPegasusSourceEditor.RefactoringController();
    var coverageGenerationObserver: Optional<NSObject> = nil;
    var boundsChangeObserver: Optional<NSObject> = nil;
    var mouseOverExpressionNotification: Optional<Foundation.Notification> = nil;
    var pendingNavigationItemLocations: Array<Any> = Array<Any>();
    var sourceEditorScrollViewClass: Optional<SourceEditorScrollView.Type> = nil;
    var alreadyPrepared: Bool = false;
    var viewState: IDEPegasusSourceEditor.SourceCodeEditor.ViewState = IDEPegasusSourceEditor.SourceCodeEditor.ViewState();
    var didSetupEditorCalled: Bool = false;
    var currentToolbarViewController: Optional<IDEViewController> = nil;
    var coverageFile: Optional<IDESchemeActionCodeCoverageFile> = nil;
    var touchBarController: Optional<IDEPegasusSourceEditor.SourceCodeEditorDFRController> = nil;
    var allowBecomeMainViewController: Bool = false;
    var selectedRangeObserver: Optional<NSObject> = nil;
    var lastPosition: Optional<SourceEditor.SourceEditorPosition> = nil;
    var currentLandmark: Optional<IDEPegasusSourceEditor.SourceCodeLandmark> = nil;
    var selectionObservers: Array<IDEPegasusSourceEditor.SourceCodeEditorSelectionObserver> = Array<IDEPegasusSourceEditor.SourceCodeEditorSelectionObserver>();
    var themeChangeNotificationToken: Optional<DVTNotificationToken> = nil;
    var currentRenderedMarkupView: Optional<IDEPegasusSourceEditor.SourceCodeMarkupView> = nil;
    var dataSource: Optional<SourceEditor.SourceEditorDataSource> = nil;
    var currentStructuredSelectionMenuController: Optional<IDEPegasusSourceEditor.StructuredSelectionActionMenuController> = nil;
    var quickHelpForceTouchController: Optional<IDEPegasusSourceEditor.QuickHelpForceTouchController> = nil;
    var activeLineHighlightOverrideProvider: Optional<SourceEditor.ActiveLineHighlightOverrideProvider> = nil;
    var pageGuideLayoutVisualization: Optional<SourceEditor.PageGuideLayoutVisualization> = nil;
    var issueObserverToken: Optional<DVTCancellable> = nil;
    var issueManager: Optional<IDEIssueManager> = nil;
    var annotationManager: Optional<DVTAnnotationManager> = nil;
    var annotations: Set<DVTAnnotation> = Set<DVTAnnotation>();
    var analyzerVisualizations: Dictionary<IDEAnalyzerResultsVisualization, IDEPegasusSourceEditor.StaticAnalyzerStepVisualization> = Dictionary<IDEAnalyzerResultsVisualization, IDEPegasusSourceEditor.StaticAnalyzerStepVisualization>();
    var analyzerResultsExplorer: Optional<IDEAnalyzerResultsExplorer> = nil;
    var analyzerResultsScopeBar: Optional<DVTScopeBarController> = nil;
    var hidingAnalyzerExplorer: Bool = false;
    var singleFileProcessingToolbarController: Optional<IDESingleFileProcessingToolbarController> = nil;
    var workspaceObservingToken: Optional<DVTCancellable> = nil;
    var workspaceFinishedLoadingToken: Optional<DVTCancellable> = nil;
    var logRecordsToken: Optional<DVTObservingToken> = nil;
    var currentBuildOperationObservingToken: Optional<DVTCancellable> = nil;
    var lastKnownBuildOperation: Optional<IDEBuildOperation> = nil;
    var quickHelpExpression: Optional<DVTSourceExpression> = nil;
    var capturedContinueToHereDocumentLocation: Optional<DVTTextDocumentLocation> = nil;
    var capturedContinueToLineDocumentLocation: Optional<DVTTextDocumentLocation> = nil;
    var sourceEditorExtensionCancellationScopeBarController: Optional<DVTScopeBarController> = nil;
    var sourceEditorExtensionErrorScopeBarController: Optional<DVTScopeBarController> = nil;
    var sourceKitServiceStatusObserver: Optional<NSObject> = nil;
    var sourceKitSemaDisabledObserver: Optional<Any> = nil;
    var sourceKitErrorTimeout: Optional<SourceEditor.TimeoutContinuation> = nil;
    var sourceKitErrorTimeoutDuration: Double = Double();
    var sourceKitErrorScopeBarController: Optional<DVTScopeBarController> = nil;
}
}
// Mirror for TimeoutContinuation
extension SourceEditor { 
public class TimeoutContinuation {
    var continuation: SourceEditor.Continuation<()> = SourceEditor.Continuation<()>();
    var timeout: Double = Double();
    var expirationTime: Optional<Dispatch.DispatchTime> = nil;
}
}
// Mirror for StructuredEditingController
extension SourceEditor { 
public class StructuredEditingController {
    var dataSource: Optional<SourceEditor.SourceEditorDataSource> = nil;
    var structuredEditingDelegate: Optional<SourceEditor.StructuredEditingDelegate> = nil;
    var transientSelectionContext: Optional<SourceEditor.SelectionContext> = nil;
    var selectionContext: Array<SourceEditor.SelectionContext> = Array<SourceEditor.SelectionContext>();
    var selectionDisplay: SourceEditor.StructuredSelectionDisplay = SourceEditor.StructuredSelectionDisplay();
    var shouldAllowStructuredSelectionOperation: Bool = false;
    var isDoubleClickTimerOn: Bool = false;
    var delayedUpdateSelectionContextAction: Optional<Dispatch.DispatchWorkItem> = nil;
    var keyBindingMonitor: Optional<Any> = nil;
}
}
// Mirror for SourceEditorSelection
extension SourceEditor {
	//typealias SourceEditorSelection = (SourceEditor.SourceEditorRange, modifiers: SourceEditor.SourceEditorSelectionModifiers);
	struct SourceEditorSelection {
		var range: SourceEditor.SourceEditorRange = SourceEditor.SourceEditorRange();
		var modifiers: SourceEditor.SourceEditorSelectionModifiers = SourceEditor.SourceEditorSelectionModifiers();
	}
	/*
enum SourceEditorSelection: Int32 {
    case None

    init() {
        self = .None
    }
}*/
public enum TextStorageDirectionType {
	case Case_0
	case Case_1
	case Case_2
	case Case_3
	case Case_4
	case Case_5
	case Case_6
	case Case_7
	case Case_8
	case Case_9

    init() {
        self = .Case_9
    }
}
}
// Mirror for TextualFindResult
extension SourceEditor { 
struct TextualFindResult {
    init() {
    }
    var query: SourceEditor.TextFindQuery = SourceEditor.TextFindQuery();
    var matchingRanges: Array<SourceEditor.SourceEditorRange> = Array<SourceEditor.SourceEditorRange>();
    var activeRangeIndex: Optional<Int> = nil;
}
}
// Mirror for FoldingController
extension SourceEditor { 
public class FoldingController {
    var delegate: Optional<SourceEditor.FoldingControllerDelegate> = nil;
    var dataSource: Optional<SourceEditor.SourceEditorDataSource> = nil;
    var allFolds: Array<SourceEditor.Fold> = Array<SourceEditor.Fold>();
    var lowWaterMarkPosition: Optional<SourceEditor.SourceEditorPosition> = nil;
    var highWaterMarkPosition: Optional<SourceEditor.SourceEditorPosition> = nil;
}
}
// Mirror for SourceEditorSelectionDisplay
extension SourceEditor { 
public class SourceEditorSelectionDisplay {
    var sourceView: Optional<SourceEditor.SourceEditorView> = nil;
    var isSelecting: Bool = false;
    var isHidden: Bool = false;
    var cursorStyle: SourceEditor.SourceEditorCursorStyle = SourceEditor.SourceEditorCursorStyle();
    var isActive: Bool = false;
    var cursorLayer: SourceEditor.CursorLayer = SourceEditor.CursorLayer();
    var selectionLayers: Array<SourceEditor.SelectionLayer> = Array<SourceEditor.SelectionLayer>();
    var reusableSelectionLayers: Array<SourceEditor.SelectionLayer> = Array<SourceEditor.SelectionLayer>();
    var insertionPointColor: NSColor = NSColor();
    var selectionColor: NSColor = NSColor();
    var cursorBlinkRate: Double = Double();
    var cursorBlinkTimer: Optional<Timer> = nil;
    var cursorVisible: Bool = false;
    var transientCursors: Dictionary<String, SourceEditor.SourceEditorSelectionDisplay.TransientCursor> = Dictionary<String, SourceEditor.SourceEditorSelectionDisplay.TransientCursor>();
    var textAttributeOverrideProviders: Optional<Array<SourceEditor.TextAttributeOverrideProvider>> = nil;
    var cursorTextAttributeOverrideProvider: SourceEditor.CursorTextAttributeOverrideProvider = SourceEditor.CursorTextAttributeOverrideProvider();
    var selectionTextAttributeOverrideProvider: SourceEditor.SelectionTextAttributeOverrideProvider = SourceEditor.SelectionTextAttributeOverrideProvider();
}
}
// Mirror for RangePopLayoutVisualization
extension SourceEditor { 
public class RangePopLayoutVisualization {
    var sourceEditorView: Optional<SourceEditor.SourceEditorView> = nil;
    var pendingRangePops: Array<SourceEditor.RangePopLayoutVisualization.RangePop> = Array<SourceEditor.RangePopLayoutVisualization.RangePop>();
    var currentRangePops: Array<SourceEditor.RangePopLayoutVisualization.RangePop> = Array<SourceEditor.RangePopLayoutVisualization.RangePop>();
    var allowsSimultaneousPops: Bool = false;
    var scaleDuration: Double = Double();
    var fadeDuration: Double = Double();
    var fadeDelay: Double = Double();
    var popHighlightColor: Optional<NSColor> = nil;
    var popHighlightCornerRadius: Optional<CoreGraphics.CGFloat> = nil;
}
}
// Mirror for DelimiterHighlight
extension SourceEditor { 
public class DelimiterHighlight {
    var sourceEditorView: Optional<SourceEditor.SourceEditorView> = nil;
    var isEnabled: Bool = false;
    var needsUpdate: Bool = false;
    var proxyLayoutVisualization: SourceEditor.RangePopLayoutVisualization = SourceEditor.RangePopLayoutVisualization();
}
}

extension SourceEditor {
public class SourceEditorLineData {
    var lineContentRange: _NSRange = _NSRange();
    var lineTerminatorLength: Int = 0;
    var placeholders: Array<(_NSRange, SourceEditor.PlaceholderMetadata)> = Array<(_NSRange, SourceEditor.PlaceholderMetadata)>();
    var hidden: Bool = false;
    var layer: SourceEditor.LayoutContext<SourceEditor.SourceEditorLineLayer> = SourceEditor.LayoutContext<SourceEditor.SourceEditorLineLayer>();
    var auxViews: SourceEditor.LayoutContext<Array<SourceEditor.SourceEditorAuxiliaryView>> = SourceEditor.LayoutContext<Array<SourceEditor.SourceEditorAuxiliaryView>>();
    var accessoryView: SourceEditor.LayoutContext<NSView> = SourceEditor.LayoutContext<NSView>();
    var substitutionView: SourceEditor.LayoutContext<SourceEditor.SourceEditorSubstitutionView> = SourceEditor.LayoutContext<SourceEditor.SourceEditorSubstitutionView>();
    var accessibilityElement: SourceEditor.LayoutContext<NSAccessibilityElement> = SourceEditor.LayoutContext<NSAccessibilityElement>();
}
}
// Mirror for LayoutContext<SourceEditorLineLayer>
extension SourceEditor {
struct LayoutContext<T> {
	init() {
	}
    var values: Dictionary<SourceEditor.SourceEditorLayoutManagerIdentifier, T> = Dictionary<SourceEditor.SourceEditorLayoutManagerIdentifier, T>();
}
}
// Mirror for SourceEditorDataSource
extension SourceEditor { 
public class SourceEditorDataSource {
    var lineData: Array<SourceEditor.SourceEditorLineData> = Array<SourceEditor.SourceEditorLineData>();
    var contents: NSString = NSString();
    var transactionNesting: Int = 0;
    var editedRange: Optional<CountableRange<Int>> = nil;
    var name: Optional<String> = nil;
    var lockedDocument: Bool = false;
    var language: Optional<SourceEditor.SourceEditorLanguage> = nil;
    var languageService: Optional<SourceEditor.SourceEditorLanguageService> = nil;
    var formattingOptions: SourceEditor.SourceEditorFormattingOptions = SourceEditor.SourceEditorFormattingOptions();
    var observerTokens: Array<SourceEditor.SourceEditorDataSourceObserverToken> = Array<SourceEditor.SourceEditorDataSourceObserverToken>();
    var documentSettings: Optional<SourceEditor.SourceEditorDocumentSettings> = nil;
    var delegate: Optional<SourceEditor.SourceEditorDataSourceDelegate> = nil;
    var undoManager: Optional<SourceEditor.SourceEditorUndoManager> = nil;
    var diagnosticProviderToken: Optional<SourceEditor.SourceEditorDiagnosticProviderToken> = nil;
    var diagnosticManager: Optional<SourceEditor.SourceEditorDiagnosticManager> = nil;
}
}
// Mirror for SelectedSymbolHighlight
extension SourceEditor { 
public class SelectedSymbolHighlight {
    var sourceEditorView: Optional<SourceEditor.SourceEditorView> = nil;
    var delay: Optional<Double> = nil;
    var selectedSymbolContinuation: Optional<SourceEditor.TimeoutContinuation> = nil;
    var currentRequestIdentifier: Optional<NSUUID> = nil;
    var currentSymbolHighlights: Array<SourceEditor.SelectedSymbolHighlight.SymbolHighlight> = Array<SourceEditor.SelectedSymbolHighlight.SymbolHighlight>();
    var symbolHighlightsLayer: SourceEditor.SourceEditorRangeHighlightLayer = SourceEditor.SourceEditorRangeHighlightLayer();
}
}
// Mirror for ContinuationScheduler
extension SourceEditor { 
public class ContinuationScheduler {
    var autoAsyncDispatch: Bool = false;
    var continuations: Dictionary<String, SourceEditor.Continuation<()>> = Dictionary<String, SourceEditor.Continuation<()>>();
}
}
// Mirror for SourceEditorViewDraggingSource
extension SourceEditor { 
public class SourceEditorViewDraggingSource: NSObject {
    var defaultDragAndDropTextDelay: Double = Double();
    var dragAndDropTextDelayOverride: Optional<Double> = nil;
    var dragAndDropTextDelay: Optional<Double> = nil;
    var lastEvent: Optional<NSEvent> = nil;
    var draggingSession: Optional<SourceEditor.SourceEditorViewDraggingSource.SourceEditorViewDraggingSession> = nil;
}
}
// Mirror for LineHighlightLayoutVisualization
extension SourceEditor { 
public class LineHighlightLayoutVisualization {
    var lineHighlightLayers: Dictionary<Int, SourceEditor.LineHighlightLayer> = Dictionary<Int, SourceEditor.LineHighlightLayer>();
    var animationDuration: Optional<Double> = nil;
}
}
// Mirror for ContextualMenuEventConsumer
extension SourceEditor { 
public class ContextualMenuEventConsumer {
}
}
// Mirror for SourceEditorContentView
extension SourceEditor { 
public class SourceEditorContentView: NSView {
    var contentLayer: SourceEditor.SourceEditorContentView.ContentSublayer = SourceEditor.SourceEditorContentView.ContentSublayer();
    var underlayLayer: SourceEditor.SourceEditorContentView.ContentSublayer = SourceEditor.SourceEditorContentView.ContentSublayer();
    var overlayLayer: SourceEditor.SourceEditorContentView.ContentSublayer = SourceEditor.SourceEditorContentView.ContentSublayer();
    var visibleLineRange: CountableRange<Int> = CountableRange<Int>(uncheckedBounds: (0,0));
    var layoutManager: Optional<SourceEditor.SourceEditorLayoutManager> = nil;
    var fullBleedFrame: Optional<CGRect> = nil;
    var accessoryMargins: NSEdgeInsets = NSEdgeInsets();
    var contentMargins: NSEdgeInsets = NSEdgeInsets();
    var responderProxy: Optional<NSResponder> = nil;
}
}
// Mirror for SourceEditorGutterMarginBackgroundView
extension SourceEditor { 
public class SourceEditorGutterMarginBackgroundView: SourceEditor.SourceEditorGutterMarginView {
}
}
// Mirror for SourceEditorGutterMarginView
extension SourceEditor { 
public class SourceEditorGutterMarginView: NSView {
    var dividerLineLayer: SourceEditor.SourceEditorGutterMarginView.SourceEditorGutterMarginViewLayer = SourceEditor.SourceEditorGutterMarginView.SourceEditorGutterMarginViewLayer();
    var dividerLineWidth: CoreGraphics.CGFloat = CoreGraphics.CGFloat();
    var drawDividerLine: Bool = false;
}
}
// Mirror for (ContentSublayer in _AAA9EA6202C5955DAA98C4EF8563AD2F)
extension SourceEditor.SourceEditorContentView { 
public class ContentSublayer: CALayer {
}
}
// Mirror for TextFindTextButton
extension SourceEditor { 
public class TextFindTextButton: NSButton {
    var textColor: NSColor = NSColor();
}
}
// Mirror for SourceCodeEditorContainerView
extension IDEPegasusSourceEditor { 
public class SourceCodeEditorContainerView: NSView {
    var editor: Optional<IDEPegasusSourceEditor.SourceCodeEditor> = nil;
}
}
// Mirror for SourceCodeDocument
extension IDEPegasusSourceEditor { 
public class SourceCodeDocument: IDEEditor {
    var identifier2: String = String();
    var notifiesWhenClosing: Bool = false;
    var registeredEditors: Array<IDEEditor> = Array<IDEEditor>();
    var firstEditorWorkspaceObservingToken: Optional<DVTObservingToken> = nil;
    var firstEditorWorkspaceBuildSettings: Optional<Dictionary<String, Any>> = nil;
    var variantContextForMediaLibrary: Optional<IDEMediaResourceVariantContext> = nil;
    var variantForResolvingMediaResources: ImplicitlyUnwrappedOptional<Dictionary<AnyHashable, Any>> = nil;
    var firstEditorWorkspacePreferredIndexableIdentifiers: Optional<Set<String>> = nil;
    var activeSchemeObservingToken: Optional<DVTObservingToken> = nil;
    var diagnosticsEnabledObservingToken: Optional<DVTObservingToken> = nil;
    var activeSchemeBuildablesObservingToken: Optional<DVTNotificationToken> = nil;
    var dataSource: Optional<SourceEditor.SourceEditorDataSource> = nil;
    var languageServiceHostExtension: Optional<IDEPegasusSourceEditor.SourceCodeDocumentLanguageServiceExtension> = nil;
    var textEncoding: Optional<String.Encoding> = nil;
    var lastEditTimestamp: Double = Double();
    var usesInferredLanguage: Bool = false;
    var language: Optional<DVTSourceCodeLanguage> = nil;
    var contentState: IDEPegasusSourceEditor.SourceCodeDocument.ContentState = IDEPegasusSourceEditor.SourceCodeDocument.ContentState();
    var contentStateObservers: Dictionary<String, (IDEPegasusSourceEditor.SourceCodeDocument.ContentState) -> ()> = Dictionary<String, (IDEPegasusSourceEditor.SourceCodeDocument.ContentState) -> ()>();
    var contentReadFromURL: Optional<Foundation.URL> = nil;
    var generatedContentContext: Optional<IDEPegasusSourceEditor.SourceCodeDocument.GeneratedContentContext> = nil;
    var currentGeneratedContentProvider: Optional<DVTGeneratedContentProvider> = nil;
    var currentGeneratedContentProviderDisplayNameObserver: Optional<DVTObservingToken> = nil;
    var currentContentGenerationCoordinator: Optional<SourceEditor.LanguageServiceContentGenerationCoordinator> = nil;
    var sourceEditorDiagnosticManagerObserver: Optional<SourceEditor.SourceEditorDiagnosticManagerObserverToken> = nil;
    var sourceEditorDiagnosticManager: Optional<SourceEditor.SourceEditorDiagnosticManager> = nil;
    var journal: Optional<SourceEditor.SourceEditorJournal> = nil;
    var landmarkTimer: Optional<Timer> = nil;
    var _topLandmark: Optional<IDEPegasusSourceEditor.SourceCodeLandmark> = nil;
    var inFlightExtensionCommandToken: Optional<DVTCancellable> = nil;
    var inFlightExtensionCommandTimer: Optional<DVTCancellable> = nil;
    var indentReplacements: Bool = false;
    var printInfo_: Optional<NSPrintInfo> = nil;
}
}
// Mirror for SourceEditorMarginAccessoryAnchor
extension SourceEditor { 
enum SourceEditorMarginAccessoryAnchor {
    case None

    init() {
        self = .None
    }
}
}
// Mirror for ViewportLayoutStrategy
extension SourceEditor { 
public class ViewportLayoutStrategy {
    var viewportOrigin: CoreGraphics.CGFloat = CoreGraphics.CGFloat();
    var viewportOffset: CoreGraphics.CGFloat = CoreGraphics.CGFloat();
    var viewportLineRange: CountableRange<Int> = CountableRange<Int>(uncheckedBounds: (0,0));
}
}
// Mirror for (SelectionTextAttributeOverrideProvider in _F4E0FDEBDAE4300D9964F2BC65F79097)
extension SourceEditor { 
public class SelectionTextAttributeOverrideProvider {
    var selectionInfo: Optional<SourceEditor.SelectionInfo> = nil;
    var previousSelectionInfo: Optional<SourceEditor.SelectionInfo> = nil;
}
}
// Mirror for (LayoutManagerDataSourceObserver in _8A34A44A3A81F5AC1210A0E6DECBF3AB)
extension SourceEditor { 
public class LayoutManagerDataSourceObserver {
    var layoutManager: SourceEditor.SourceEditorLayoutManager = SourceEditor.SourceEditorLayoutManager();
}
}
// Mirror for SourceEditorFormattingOptions
extension SourceEditor { 
struct SourceEditorFormattingOptions {
    init() {
    }
    var indentWidth: Int = 0;
    var tabWidth: Int = 0;
    var useTabs: Bool = false;
    var syntaxAwareIndent: Bool = false;
    var tabIndentBehavior: SourceEditor.SourceEditorFormattingOptions.tabIndentBehavior_ = SourceEditor.SourceEditorFormattingOptions.tabIndentBehavior_();
}
}
// Mirror for RefactoringController
extension IDEPegasusSourceEditor { 
public class RefactoringController: NSObject {
    var gotAFailure: Bool = false;
    var editor: Optional<IDEPegasusSourceEditor.SourceCodeEditor> = nil;
    var updateTimer: Optional<Timer> = nil;
    var changeCount: Int = 0;
    var lastRefactoringRange: Optional<SourceEditor.SourceEditorRange> = nil;
    var lastAvailableRefactorings: Optional<Array<IDESourceKitAvailableRefactoring>> = nil;
    var renameOperation: Optional<IDEPegasusSourceEditor.RenameOperation> = nil;
}
}
// Mirror for SourceEditorPosition
extension SourceEditor { 
public struct SourceEditorPosition {
    init() {
    }
    var line: Int = 0;
    var col: Int = 0;
}
}
// Mirror for TextFindPattern
extension SourceEditor { 
enum TextFindPattern {
    case None

    init() {
        self = .None
    }
}
}
// Mirror for SourceModelEditorLanguage
class SourceModelSupport { 
}
extension SourceModelSupport { 
struct SourceModelEditorLanguage {
    init() {
    }
    var name: String = String();
    var identifier: String = String();
    var langServiceClass: SourceModelSupport.SourceModelLanguageService.Type = SourceModelSupport.SourceModelLanguageService.self;
    var contentGeneratingLangServiceClass: Optional<SourceEditor.ContentGeneratingLanguageService.Type> = nil;
    var lineDataClass: SourceEditor.SourceEditorLineData.Type = SourceEditor.SourceEditorLineData.self;
    var editableRangeSnapshotType: Optional<SourceEditor.EditableRangeSnapshot.Type> = nil;
}
}
// Mirror for SourceCodeLandmark
extension IDEPegasusSourceEditor { 
public class SourceCodeLandmark: NSObject {
    var landmark: Optional<SourceEditor.Landmark> = nil;
    var children: Optional<Array<SourceEditor.Landmark>> = nil;
    var parent: Optional<SourceEditor.Landmark> = nil;
    var owner: Optional<IDEPegasusSourceEditor.LandmarkRangeResolvingDocument> = nil;
}
}
// Mirror for SourceModelLanguageService
extension SourceModelSupport { 
public class SourceModelLanguageService: NSObject {
    var buffer: Optional<SourceEditor.SourceEditorBuffer> = nil;
    var hostExtension: Optional<SourceEditor.LanguageServiceHostExtension> = nil;
    var identifier: String = String();
    var lang: Optional<DVTSourceCodeLanguage> = nil;
    var sourceModelWithoutParsing: Optional<DVTSourceModel> = nil;
    var commentType: Int16 = 0;
    var docCommentType: Int16 = 0;
    var docCommentKeywordType: Int16 = 0;
    var stringType: Int16 = 0;
    var characterType: Int16 = 0;
    var numberType: Int16 = 0;
    var keywordType: Int16 = 0;
    var preprocessorType: Int16 = 0;
    var attributeType: Int16 = 0;
    var entityType: Int16 = 0;
    var entityStartType: Int16 = 0;
    var urlType: Int16 = 0;
    var identifierType: Int16 = 0;
    var plainIdentifierType: Int16 = 0;
    var classType: Int16 = 0;
    var systemClassType: Int16 = 0;
    var functionType: Int16 = 0;
    var systemFunctionType: Int16 = 0;
    var constantType: Int16 = 0;
    var systemConstantType: Int16 = 0;
    var typeType: Int16 = 0;
    var systemTypeType: Int16 = 0;
    var variableType: Int16 = 0;
    var systemVariableType: Int16 = 0;
    var macroType: Int16 = 0;
    var systemMacroType: Int16 = 0;
    var topLandmark: Optional<SourceEditor.SourceEditorLandmark> = nil;
    var landmarksNeedUpdating: Bool = false;
    var landmarkMap: Array<(Bool, Optional<SourceEditor.LandmarkType>)> = Array<(Bool, Optional<SourceEditor.LandmarkType>)>();
    var basicDiagnosticProvider: SourceEditor.BasicDiagnosticProvider = SourceEditor.BasicDiagnosticProvider();
    var hostProvidedDiagnosticsContinuation: Optional<SourceEditor.TimeoutContinuation> = nil;
    var hostProvidedDiagnosticsGeneration: NSUUID = NSUUID();
    var cachedBufferString: Optional<NSString> = nil;
}
}
// Mirror for TextReplaceField
extension SourceEditor { 
public class TextReplaceField: TextFindReplaceField {
    var panel: Optional<SourceEditor.TextFindPanelViewController> = nil;
    var insets: NSEdgeInsets = NSEdgeInsets();
}
}
// Mirror for TextFindReplaceField
public class TextFindReplaceField: DVTFindPatternTextField {
}
// Mirror for TextGranularityType
extension SourceEditor { 
public enum TextGranularityType {
	case Case_0
	case Case_1
	case Case_2
	case Case_3
	case Case_4
	case Case_5
	case Case_6
	case Case_7
	case Case_8
	case Case_9
	case Case_10

    init() {
        self = .Case_10
    }
}
}
// Mirror for SourceEditorCursorStyle
extension SourceEditor { 
enum SourceEditorCursorStyle {
    case None

    init() {
        self = .None
    }
}
}
// Mirror for TrimTrailingWhitespaceStyle
extension SourceEditor { 
enum TrimTrailingWhitespaceStyle {
    case None

    init() {
        self = .None
    }
}
}
// Mirror for CodeCompletionTrickingSettingsStub
extension IDEPegasusSourceEditor { 
struct CodeCompletionTrickingSettingsStub {
    init() {
    }
}
}
// Mirror for TextFindPanelMode
extension SourceEditor { 
enum TextFindPanelMode {
    case None

    init() {
        self = .None
    }
}
}
// Mirror for TextFindResultDisplayMode
extension SourceEditor { 
enum TextFindResultDisplayMode {
    case None

    init() {
        self = .None
    }
}
}
// Mirror for Continuation<()>
extension SourceEditor { 
struct Continuation<T> {
    init() {
    }
    var f: Optional<() -> T> = nil;
    var failable: Optional<() -> Optional<SourceEditor.Continuation<T>>> = nil;
}
}
// Mirror for TextFindPopUpButton
extension SourceEditor { 
public class TextFindPopUpButton: NSPopUpButton {
    var textColor: NSColor = NSColor();
}
}
// Mirror for SourceEditorTheme
extension IDEPegasusSourceEditor { 
public class SourceEditorTheme {
    var fontAndColorTheme: DVTFontAndColorTheme = DVTFontAndColorTheme();
    var cachedColors: Dictionary<String, NSColor> = Dictionary<String, NSColor>();
    var cachedFonts: Dictionary<String, NSFont> = Dictionary<String, NSFont>();
    var plainTextFont: Optional<NSFont> = nil;
    var commentFont: Optional<NSFont> = nil;
    var documentationCommentFont: Optional<NSFont> = nil;
    var documentationCommentKeywordFont: Optional<NSFont> = nil;
    var stringFont: Optional<NSFont> = nil;
    var characterFont: Optional<NSFont> = nil;
    var numberFont: Optional<NSFont> = nil;
    var keywordFont: Optional<NSFont> = nil;
    var preprocessorStatementFont: Optional<NSFont> = nil;
    var urlFont: Optional<NSFont> = nil;
    var attributeFont: Optional<NSFont> = nil;
    var projectClassNameFont: Optional<NSFont> = nil;
    var projectFunctionMethodNameFont: Optional<NSFont> = nil;
    var projectConstantFont: Optional<NSFont> = nil;
    var projectTypeNameFont: Optional<NSFont> = nil;
    var projectInstanceGlobalVariableFont: Optional<NSFont> = nil;
    var projectPreprocessorMacroFont: Optional<NSFont> = nil;
    var externalClassNameFont: Optional<NSFont> = nil;
    var externalFunctionMethodNameFont: Optional<NSFont> = nil;
    var externalConstantFont: Optional<NSFont> = nil;
    var externalTypeNameFont: Optional<NSFont> = nil;
    var externalInstanceGlobalVariableFont: Optional<NSFont> = nil;
    var externalPreprocessorMacroFont: Optional<NSFont> = nil;
    var backgroundColor: Optional<NSColor> = nil;
    var selectionColor: Optional<NSColor> = nil;
    var inactiveSelectionColor: Optional<NSColor> = nil;
    var currentLineHighlightColor: Optional<NSColor> = nil;
    var cursorColor: Optional<NSColor> = nil;
    var invisiblesColor: Optional<NSColor> = nil;
    var plainTextColor: Optional<NSColor> = nil;
    var structuredSelectionTransientLozengeColor: Optional<NSColor> = nil;
    var commentColor: Optional<NSColor> = nil;
    var documentationCommentColor: Optional<NSColor> = nil;
    var documentationCommentKeywordColor: Optional<NSColor> = nil;
    var stringColor: Optional<NSColor> = nil;
    var characterColor: Optional<NSColor> = nil;
    var numberColor: Optional<NSColor> = nil;
    var keywordColor: Optional<NSColor> = nil;
    var preprocessorStatementColor: Optional<NSColor> = nil;
    var urlColor: Optional<NSColor> = nil;
    var attributeColor: Optional<NSColor> = nil;
    var projectClassNameColor: Optional<NSColor> = nil;
    var projectFunctionMethodNameColor: Optional<NSColor> = nil;
    var projectConstantColor: Optional<NSColor> = nil;
    var projectTypeNameColor: Optional<NSColor> = nil;
    var projectInstanceGlobalVariableColor: Optional<NSColor> = nil;
    var projectPreprocessorMacroColor: Optional<NSColor> = nil;
    var externalClassNameColor: Optional<NSColor> = nil;
    var externalFunctionMethodNameColor: Optional<NSColor> = nil;
    var externalConstantColor: Optional<NSColor> = nil;
    var externalTypeNameColor: Optional<NSColor> = nil;
    var externalInstanceGlobalVariableColor: Optional<NSColor> = nil;
    var externalPreprocessorMacroColor: Optional<NSColor> = nil;
    var baseMarkupParagraphFont: Optional<NSFont> = nil;
    var invisiblesFontLight: Optional<NSFont> = nil;
    var invisiblesFontRegular: Optional<NSFont> = nil;
    var invisiblesFontHeavy: Optional<NSFont> = nil;
    var invisiblesGlyphInfo: Optional<Dictionary<SourceEditor.InvisibleCharacterType, (NSFont, UInt16, CoreGraphics.CGFloat)>> = nil;
}
}
// Mirror for PageGuideLayoutVisualization
extension SourceEditor { 
public class PageGuideLayoutVisualization {
    var sourceEditorView: Optional<SourceEditor.SourceEditorView> = nil;
    var pageGuideColumn: Int = 0;
    var pageGuideColor: NSColor = NSColor();
    var pageGuideLeftBorderColor: NSColor = NSColor();
    var pageGuideLayer: SourceEditor.PageGuideLayoutVisualization.PageGuideLayer = SourceEditor.PageGuideLayoutVisualization.PageGuideLayer();
    var pageGuideLeftBorderLayer: SourceEditor.PageGuideLayoutVisualization.PageGuideLayer = SourceEditor.PageGuideLayoutVisualization.PageGuideLayer();
}
}
// Mirror for SourceEditorMouseSelectionSession
extension SourceEditor { 
public class SourceEditorMouseSelectionSession {
    var startSelection: Optional<SourceEditor.SourceEditorSelection> = nil;
    var currentSelection: Optional<SourceEditor.SourceEditorSelection> = nil;
    var startPoint: CGPoint = CGPoint();
    var currentPoint: CGPoint = CGPoint();
}
}
// Mirror for (CursorTextAttributeOverrideProvider in _F4E0FDEBDAE4300D9964F2BC65F79097)
extension SourceEditor { 
public class CursorTextAttributeOverrideProvider {
    var selectionInfo: Optional<SourceEditor.SelectionInfo> = nil;
    var previousSelectionInfo: Optional<SourceEditor.SelectionInfo> = nil;
}
}
// Mirror for SourceEditorFontSmoothingAttributes
extension SourceEditor { 
struct SourceEditorFontSmoothingAttributes {
    init() {
    }
    var shouldAntialias: Bool = false;
    var shouldSmoothFonts: Bool = false;
    var shouldSubpixelPositionFonts: Bool = false;
    var shouldSubpixelQuantizeFonts: Bool = false;
    var fontSmoothingBackgroundColor: Optional<NSColor> = nil;
    var fontSmoothingStyle: Optional<SourceEditor.SourceEditorFontSmoothingStyle> = nil;
}
}
// Mirror for (ViewState in _424D7084F1974F214FECC883248672AF)
extension IDEPegasusSourceEditor.SourceCodeEditor { 
enum ViewState {
    case None

    init() {
        self = .None
    }
}
}
// Mirror for TextFindableResultLayoutVisualization
extension SourceEditor { 
public class TextFindableResultLayoutVisualization {
    var display: Optional<SourceEditor.TextFindableDisplay> = nil;
    var findResult: Optional<SourceEditor.TextFindResult> = nil;
    var findResultDisplayMode: SourceEditor.TextFindResultDisplayMode = SourceEditor.TextFindResultDisplayMode();
    var needsLayout: Bool = false;
    var resultLayer: SourceEditor.SourceEditorRangeHighlightLayer = SourceEditor.SourceEditorRangeHighlightLayer();
    var activeResultLayer: Optional<SourceEditor.SourceEditorRangeHighlightLayer> = nil;
    var layoutRect: Optional<CGRect> = nil;
    var contentViewFrame: Optional<CGRect> = nil;
    var contentSize: Optional<CoreGraphics.CGFloat> = nil;
}
}
// Mirror for Notification
// Mirror for TextFindableAttributeOverrideProvider
extension SourceEditor { 
public class TextFindableAttributeOverrideProvider {
    var display: Optional<SourceEditor.TextFindableDisplay> = nil;
    var findResult: Optional<SourceEditor.TextFindResult> = nil;
    var findResultDisplayMode: SourceEditor.TextFindResultDisplayMode = SourceEditor.TextFindResultDisplayMode();
    var priority: SourceEditor.LayoutOverrideProviderPriority = SourceEditor.LayoutOverrideProviderPriority();
}
}
// Mirror for TextFindField
extension SourceEditor { 
public class TextFindField: TextFindSearchField {
    var panel: Optional<SourceEditor.TextFindPanelViewController> = nil;
    var insets: NSEdgeInsets = NSEdgeInsets();
}
}
// Mirror for TextFindSearchField
public class TextFindSearchField: DVTFindPatternSearchField {
}
// Mirror for QuickHelpForceTouchController
extension IDEPegasusSourceEditor { 
public class QuickHelpForceTouchController: NSObject {
    var editor: Optional<IDEPegasusSourceEditor.SourceCodeEditor> = nil;
    var quickHelpForceTouchGestureRecognizer: Optional<NSGestureRecognizer> = nil;
}
}
// Mirror for SourceEditorLayoutManagerIdentifier
extension SourceEditor {
	typealias SourceEditorLayoutManagerIdentifier = ObjectIdentifier;
	/*
struct SourceEditorLayoutManagerIdentifier {
    init() {
    }
    var identifier: ObjectIdentifier = ObjectIdentifier(ObjectIdentifier.self);
}*/
}
// Mirror for DispatchTime
// Mirror for StructuredSelectionDisplay
extension SourceEditor { 
public class StructuredSelectionDisplay {
    var visualization: SourceEditor.StructuredSelectionVisualization = SourceEditor.StructuredSelectionVisualization();
}
}
// Mirror for SourceEditorDiagnosticProviderToken
extension SourceEditor { 
struct SourceEditorDiagnosticProviderToken {
    init() {
    }
    var diagnosticManager: SourceEditor.SourceEditorDiagnosticManager = SourceEditor.SourceEditorDiagnosticManager();
    var value: Int = 0;
}
}
// Mirror for ActiveLineHighlightOverrideProvider
extension SourceEditor { 
public class ActiveLineHighlightOverrideProvider {
    var priority: SourceEditor.LayoutOverrideProviderPriority = SourceEditor.LayoutOverrideProviderPriority();
}
}
// Mirror for SourceEditorRangeHighlightLayer
extension SourceEditor { 
public class SourceEditorRangeHighlightLayer: CAShapeLayer {
    var rangeHighlights: Optional<Array<SourceEditor.SourceEditorRangeHighlight>> = nil;
    var mutablePath: NSString = NSString();
    var pathCornerRadius: CoreGraphics.CGFloat = CoreGraphics.CGFloat();
    var drawsTokenShadow: Bool = false;
    var rightEndSquared: Bool = false;
}
}
// Mirror for AutoLayoutSyncedControllerContentView
extension IDEPegasusSourceEditor { 
public class AutoLayoutSyncedControllerContentView: DVTControllerContentView {
    var didInitalize: Bool = false;
}
}
// Mirror for SourceEditorDiagnosticManager
extension SourceEditor { 
public class SourceEditorDiagnosticManager {
    var diagnosticProviderContexts: Array<SourceEditor.SourceEditorDiagnosticProviderContext> = Array<SourceEditor.SourceEditorDiagnosticProviderContext>();
    var nextDiagnosticProviderTokenValue: Int = 0;
    var diagnostics: Array<SourceEditor.SourceEditorDiagnostic> = Array<SourceEditor.SourceEditorDiagnostic>();
    var diagnosticGenerationContinuation: Optional<SourceEditor.TimeoutContinuation> = nil;
    var observers: Array<((SourceEditor.SourceEditorDiagnosticManager) -> (), SourceEditor.SourceEditorDiagnosticManagerObserverToken)> = Array<((SourceEditor.SourceEditorDiagnosticManager) -> (), SourceEditor.SourceEditorDiagnosticManagerObserverToken)>();
    var nextDiagnosticManagerObserverTokenValue: Int = 0;
}
}
// Mirror for CursorLayer
extension SourceEditor { 
public class CursorLayer: CAShapeLayer {
}
}
// Mirror for SourceEditorGutterMarginContentView
extension SourceEditor { 
public class SourceEditorGutterMarginContentView: SourceEditor.SourceEditorGutterMarginView {
    var requiredWidth: CoreGraphics.CGFloat = CoreGraphics.CGFloat();
    var lineNumberLayers: Dictionary<Int, SourceEditor.SourceEditorFontSmoothingTextLayer> = Dictionary<Int, SourceEditor.SourceEditorFontSmoothingTextLayer>();
    var reusableLineNumberLayers: Dictionary<Int, SourceEditor.SourceEditorFontSmoothingTextLayer> = Dictionary<Int, SourceEditor.SourceEditorFontSmoothingTextLayer>();
    var lastLineNumberRange: Optional<CountableRange<Int>> = nil;
    var lineNumbersEnabled: Bool = false;
    var lineNumberFont: Optional<NSFont> = nil;
    var layerSizeCache: Dictionary<Int, CGSize> = Dictionary<Int, CGSize>();
    var annotations: Set<SourceEditor.SourceEditorGutterAnnotation> = Set<SourceEditor.SourceEditorGutterAnnotation>();
    var lineIdentifierOrderedAnnotations: Dictionary<SourceEditor.SourceEditorLineIdentifier, Array<SourceEditor.SourceEditorGutterAnnotation>> = Dictionary<SourceEditor.SourceEditorLineIdentifier, Array<SourceEditor.SourceEditorGutterAnnotation>>();
    var interaction: Optional<SourceEditor.SourceEditorGutterAnnotation.Interaction> = nil;
    var hoveringAnnotation: Optional<SourceEditor.SourceEditorGutterAnnotation> = nil;
    var layoutIntentMap: Dictionary<SourceEditor.SourceEditorGutterAnnotation, SourceEditor.SourceEditorGutterAnnotation.Interaction.Intent> = Dictionary<SourceEditor.SourceEditorGutterAnnotation, SourceEditor.SourceEditorGutterAnnotation.Interaction.Intent>();
}
}
// Mirror for SourceCodeUndoManager
extension IDEPegasusSourceEditor { 
public class SourceCodeUndoManager: SourceEditor.SourceEditorUndoManager {
    var willAutomaticallyUndoNextChangeGroup: Bool = false;
    var delegate: Optional<DVTUndoManagerDelegate> = nil;
}
}
// Mirror for SourceEditorUndoManager
extension SourceEditor { 
public class SourceEditorUndoManager: UndoManager {
    var undoStack: SourceEditor.CollapsibleStack<SourceEditor.UndoStackOperation> = SourceEditor.CollapsibleStack<SourceEditor.UndoStackOperation>();
    var redoStack: SourceEditor.CollapsibleStack<SourceEditor.UndoStackOperation> = SourceEditor.CollapsibleStack<SourceEditor.UndoStackOperation>();
    var pendingUndoOperations: Array<SourceEditor.UndoStackOperation> = Array<SourceEditor.UndoStackOperation>();
    var pendingRedoOperations: Array<SourceEditor.UndoStackOperation> = Array<SourceEditor.UndoStackOperation>();
    var needsTextualCoalesce: Bool = false;
    var lastTextualOperationType: Optional<SourceEditor.SourceEditorTextualUndoType> = nil;
    var lastKnownInsertionPoint: Optional<SourceEditor.SourceEditorPosition> = nil;
    var postingCheckpoint: Bool = false;
    var _undoGroupingLevel: Int = 0;
    var _redoGroupingLevel: Int = 0;
    var undoLevel: Int = 0;
    var redoLevel: Int = 0;
}
}
// Mirror for NSUndoManager
public class UndoManager: NSObject {
}
// Mirror for SourceEditorRange
extension SourceEditor { 
struct SourceEditorRange {
    init() {
    }
    var start: SourceEditor.SourceEditorPosition = SourceEditor.SourceEditorPosition();
    var end: SourceEditor.SourceEditorPosition = SourceEditor.SourceEditorPosition();
}
}
// Mirror for SourceEditorFontSmoothingStyle
extension SourceEditor { 
struct SourceEditorFontSmoothingStyle {
    init() {
    }
    var rawValue: UInt32 = 0;
    var name: String = String();
}
}
// Mirror for CollapsibleStack<(UndoStackOperation in _452FC792F9E02464CCF1D8C302F26888)>
extension SourceEditor { 
public class CollapsibleStack<T> {
    var top: Optional<SourceEditor.StackEntry<T>> = nil;
    var bottom: Optional<SourceEditor.StackEntry<T>> = nil;
    var lastCollapsed: Optional<SourceEditor.StackEntry<T>> = nil;
    var userEntries: Int = 0;
}
}
// Mirror for BasicDiagnosticProvider
extension SourceEditor { 
public class BasicDiagnosticProvider {
    var diagnostics: Optional<Array<SourceEditor.SourceEditorDiagnostic>> = nil;
    var observers: Array<((SourceEditor.SourceEditorDiagnosticProvider) -> (), Int)> = Array<((SourceEditor.SourceEditorDiagnosticProvider) -> (), Int)>();
    var nextObserverNumber: Int = 0;
}
}
// Mirror for LayoutOverrideProviderPriority
extension SourceEditor { 
enum LayoutOverrideProviderPriority {
    case None

    init() {
        self = .None
    }
}
}
// Mirror for SourceEditorLandmark
extension SourceEditor { 
public class SourceEditorLandmark {
    var displayName: String = String();
    var type: SourceEditor.LandmarkType = SourceEditor.LandmarkType();
    var parent: Optional<SourceEditor.Landmark> = nil;
    var range: SourceEditor.SourceEditorRange = SourceEditor.SourceEditorRange();
    var nameRange: SourceEditor.SourceEditorRange = SourceEditor.SourceEditorRange();
    var children: Optional<Array<SourceEditor.Landmark>> = nil;
}
}
// Mirror for (SourceCodeDocumentLanguageServiceExtension in _1FF747B2AB42EBC82BFFF96A6B15EC6E)
extension IDEPegasusSourceEditor { 
public class SourceCodeDocumentLanguageServiceExtension {
    var document: Optional<IDEPegasusSourceEditor.SourceCodeDocument> = nil;
    var nodeAdjustRequests: Array<SourceCodeAdjustNodeTypesRequest> = Array<SourceCodeAdjustNodeTypesRequest>();
    var allowIndexBasedSemanticColoring: Bool = false;
}
}
// Mirror for (SelectionInfo in _F4E0FDEBDAE4300D9964F2BC65F79097)
extension SourceEditor { 
struct SelectionInfo {
    init() {
    }
    var dataSource: Optional<SourceEditor.SourceEditorDataSource> = nil;
    var selection: SourceEditor.SourceEditorSelection = SourceEditor.SourceEditorSelection();
    var cursorStyle: SourceEditor.SourceEditorCursorStyle = SourceEditor.SourceEditorCursorStyle();
    var cursorVisible: Bool = false;
    var selectionTargetIsActive: Bool = false;
    var selectionColor: Optional<NSColor> = nil;
}
}
// Mirror for Encoding
// Mirror for SourceEditorGutterMarginViewLayer
extension SourceEditor.SourceEditorGutterMarginView { 
public class SourceEditorGutterMarginViewLayer: CALayer {
}
}
// Mirror for ContentState
extension IDEPegasusSourceEditor.SourceCodeDocument { 
enum ContentState {
    case None

    init() {
        self = .None
    }
}
}
// Mirror for CGPoint
struct CGPoint {
    init() {
    }
    var x: CoreGraphics.CGFloat = CoreGraphics.CGFloat();
    var y: CoreGraphics.CGFloat = CoreGraphics.CGFloat();
}
// Mirror for (PageGuideLayer in _11450687FAF9AECE734138FEC5A56F79)
extension SourceEditor.PageGuideLayoutVisualization { 
public class PageGuideLayer: CALayer {
}
}
// Mirror for (StructuredSelectionVisualization in _7AFBC303C5A816C40636AEF2F174C33D)
extension SourceEditor { 
public class StructuredSelectionVisualization {
    var lozengeContext: Array<SourceEditor.StructuredSelectionVisualization.LozengeContext> = Array<SourceEditor.StructuredSelectionVisualization.LozengeContext>();
    var layoutManager: Optional<SourceEditor.SourceEditorLayoutManager> = nil;
    var hitTestViews: Optional<Array<NSView>> = nil;
    var priority: SourceEditor.LayoutOverrideProviderPriority = SourceEditor.LayoutOverrideProviderPriority();
    var overridingAttrs: Dictionary<SourceEditor.SourceEditorLineIdentifier, Array<SourceEditor.SourceEditorTextAttributeOverride>> = Dictionary<SourceEditor.SourceEditorLineIdentifier, Array<SourceEditor.SourceEditorTextAttributeOverride>>();
    var lozengeHostLayer: SourceEditor.StructuredSelectionVisualization.LonzengeHostingLayer = SourceEditor.StructuredSelectionVisualization.LonzengeHostingLayer();
    var transientLozengeHostLayer: SourceEditor.StructuredSelectionVisualization.LonzengeHostingLayer = SourceEditor.StructuredSelectionVisualization.LonzengeHostingLayer();
}
}
// Mirror for tabIndentBehavior_
extension SourceEditor.SourceEditorFormattingOptions { 
enum tabIndentBehavior_ {
    case None

    init() {
        self = .None
    }
}
}
// Mirror for SourceEditorDiagnosticManagerObserverToken
extension SourceEditor { 
struct SourceEditorDiagnosticManagerObserverToken {
    init() {
    }
    var diagnosticManager: SourceEditor.SourceEditorDiagnosticManager = SourceEditor.SourceEditorDiagnosticManager();
    var value: Int = 0;
}
}
// Mirror for SourceEditorJournal
extension SourceEditor { 
public class SourceEditorJournal {
    var dataSource: SourceEditor.SourceEditorDataSource = SourceEditor.SourceEditorDataSource();
    var records: Array<(Double, SourceEditor.JournalRecord)> = Array<(Double, SourceEditor.JournalRecord)>();
    var dataSourceObserver: SourceEditor.JournalDataSourceObserver = SourceEditor.JournalDataSourceObserver();
    var currentTransactionTimestamp: Optional<Double> = nil;
}
}
// Mirror for URL
// Mirror for (JournalDataSourceObserver in _E53694DE114CF52172E44FB14EB48E6A)
extension SourceEditor { 
public class JournalDataSourceObserver {
    var journal: Optional<SourceEditor.SourceEditorJournal> = nil;
}
}
// Mirror for LonzengeHostingLayer
extension SourceEditor.StructuredSelectionVisualization { 
public class LonzengeHostingLayer: CALayer {
}
}
// Mirror for LandmarkType
extension SourceEditor { 
enum LandmarkType {
    case None

    init() {
        self = .None
    }
}
}
extension SourceEditor {
    public class SourceEditorViewDelegate {}
    public class TextFindPanel {}
    public class TextFindResult {}
    public class TextFindValue {}
    public class LanguageServiceCodeCompletionStrategy {}
    public class SourceEditorCodeCompletionController {}
    public class SourceEditorSizableAssociatedView {}
    public class SourceEditorViewContextualMenuItemProvider {}
    public class SourceEditorViewStructuredSelectionDelegate {}
    public class SourceEditorViewEventConsumer {}
    public class SourceEditorViewDraggingExtension {}
    public class CodeCoverageVisualization {}
    public class LayoutVisualization {}
    public class TextAttributeOverrideProvider {}
    public class SourceEditorLineAnnotationInteractionDelegate {}
    public class SourceEditorLineAnnotation {}
    public class SourceEditorLineAnnotationDropdown {}
    public class SourceEditorLineIdentifier: Hashable {public var hashValue: Int { return 0 }; public static func ==(lhs: SourceEditorLineIdentifier, rhs: SourceEditorLineIdentifier) -> Bool { return false; }}
    public class SourceEditorFontTheme {}
    public class SourceEditorColorTheme {}
    public class TextFindableDisplayable {}
    public class SourceEditorGutterInteractionDelegate {}
    public class SourceEditorGutterAnnotationInteractionDelegate {}
    public class SourceEditorVerticalAnchor {}
    public class SourceEditorLayoutManagerDelegate {}
    public class SourceEditorLayoutContainer {}
    public class ShowInvisiblesTheme {}
    public class InvisibleCharactersOverlayProvider {}
    public class LineWrappingStyle {}
    public class LineLayoutColumnShift {}
    public class SourceEditorMarginAccessory {}
    public class LayoutOverrideProvider {}
    public class MultiCursorController {}
    public class EditAssistantPostProcessOperation {}
    public class EditAssistantPreProcessOperation {}
    public class SourceCodeEditorDFRController {}
    public class SourceCodeEditorSelectionObserver {}
    public class SourceCodeMarkupView {}
    public class StructuredSelectionActionMenuController {}
    public class StructuredEditingDelegate {}
    public class SelectionContext {}
	public class PlaceholderMetadata {}
	public class SourceEditorLineLayer {}
	public class SourceEditorAuxiliaryView {}
	public class SourceEditorSubstitutionView {}
    public enum SourceEditorSelectionModifiers: UInt64
	{
		case Case_0 = 0
		case Case_1
		case Case_2
		case Case_3
		case Case_4
		case Case_5
		case Case_6
		case Case_7
		case Case_8
		case Case_9
		init()
		{
			self = .Case_9
		}
	}
    public class FoldingControllerDelegate {}
    public class Fold {}
    public class SelectionLayer {}
    public class SourceEditorTextAttributeOverride {}
    public class JournalRecord {}
    public class SourceEditorDiagnostic {}
    public class SourceEditorDiagnosticProvider {}
    public class Landmark {}
    public class SourceEditorTextualUndoType {}
    public class UndoStackOperation {}
    public class SourceEditorGutterAnnotation: Hashable {public var hashValue: Int { return 0 }; public static func ==(lhs: SourceEditorGutterAnnotation, rhs: SourceEditorGutterAnnotation) -> Bool { return false; }}
    public class SourceEditorFontSmoothingTextLayer {}
    public class SourceEditorDiagnosticProviderContext {}
    public class SourceEditorRangeHighlight {}
    public class InvisibleCharacterType: Hashable {public var hashValue: Int { return 0 }; public static func ==(lhs: InvisibleCharacterType, rhs: InvisibleCharacterType) -> Bool { return false; }}
    public class LanguageServiceHostExtension {}
    public class SourceEditorBuffer {}
    public class LandmarkRangeResolvingDocument {}
    public class AnnotationsAccessibilityGroup {}
    public class SourceEditorLineAnnotationGroup {}
    public class SourceEditorLineAnnotationView {}
    public class SourceEditorLanguage {}
    public class SourceEditorLanguageService {}
    public class SourceEditorDataSourceObserverToken {}
    public class SourceEditorDocumentSettings {}
    public class SourceEditorDataSourceDelegate {}
    public class LineHighlightLayer {}
    public class SourceEditorLineAnnotationLayout {}
    public class ContentGeneratingLanguageService {}
    public class EditableRangeSnapshot {}
    public class LanguageServiceContentGenerationCoordinator {}
    public class StackEntry<T> {}
    public class xxx {}
}
public class SourceCodeAdjustNodeTypesRequest {}
extension SourceEditorScrollView {
    public class `Type` {}
}
extension SourceEditor.ContentGeneratingLanguageService {
    public class `Type` {}
}
extension SourceEditor.SourceEditorSelectionDisplay {
    public class TransientCursor {}
}
extension IDEPegasusSourceEditor.SourceCodeDocument {
    public class GeneratedContentContext {}
}
extension SourceEditor.EditableRangeSnapshot {
    public class `Type` {}
}
extension SourceEditor.RangePopLayoutVisualization {
    public class RangePop {}
}
extension SourceEditor.SelectedSymbolHighlight {
    public class SymbolHighlight {}
}
extension SourceEditor.SourceEditorViewDraggingSource {
    public class SourceEditorViewDraggingSession {}
}
extension SourceModelSupport.SourceModelLanguageService {
    public class `Type` {}
}
extension SourceModelSupport.SourceModelEditorLanguage {
    public class `Type` {}
}
extension SourceEditor.SourceEditorGutterAnnotation {
    public class Interaction {}
}
extension SourceEditor.SourceEditorGutterAnnotation.Interaction {
    public class Intent {}
}
extension SourceEditor.SourceEditorLineAnnotation {
    public class Interaction {}
}
extension SourceEditor.StructuredSelectionVisualization {
    public class LozengeContext {}
}
extension IDEPegasusSourceEditor {
    public class StaticAnalyzerStepVisualization {}
    public class LandmarkRangeResolvingDocument {}
    public class SourceCodeEditorDFRController {}
    public class SourceCodeEditorSelectionObserver {}
    public class SourceCodeMarkupView {}
    public class StructuredSelectionActionMenuController {}
    public class RenameOperation {}
}

