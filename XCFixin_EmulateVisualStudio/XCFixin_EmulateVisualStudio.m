#import <Cocoa/Cocoa.h>
#include <Carbon/Carbon.h>
#import <objc/runtime.h>
#include "../Shared Code/XCFixin.h"

#import "../Shared Code/Xcode5/DVTKit/DVTSourceTextView.h"
#import "../Shared Code/Xcode5/DVTKit/DVTDocumentLocation.h"
#import "../Shared Code/Xcode5/DVTKit/DVTTextDocumentLocation.h"
#import "../Shared Code/Xcode5/DVTKit/DVTFindBar.h"
#import "../Shared Code/Xcode5/DVTKit/DVTFindPatternFieldEditor.h"
#import "../Shared Code/Xcode5/DVTKit/DVTFindPatternTextField.h"
#import "../Shared Code/Xcode5/DVTKit/DVTFindBarOptionsCtrl.h"
#import "../Shared Code/Xcode5/DVTKit/DVTAnnotationManager.h"
#import "../Shared Code/Xcode5/DVTKit/DVTAnnotationProvider.h"
#import "../Shared Code/Xcode5/DVTKit/DBGBreakpointAnnotationProvider.h"
#import "../Shared Code/Xcode5/DVTKit/DVTAnnotation.h"
#import "../Shared Code/Xcode5/DVTKit/DBGBreakpointAnnotation.h"
#import "../Shared Code/Xcode5/DVTKit/DVTTextStorage.h"


#import "../Shared Code/Xcode5/IDEKit/IDENavigatorOutlineView.h"
#import "../Shared Code/Xcode5/IDEKit/IDEBatchFindResultsOutlineController.h"
#import "../Shared Code/Xcode5/IDEKit/IDEIssueNavigator.h"
#import "../Shared Code/Xcode5/IDEKit/IDEIssueNavigableItem.h"
#import "../Shared Code/Xcode5/IDEKit/IDESourceCodeEditorContainerView.h"
#import "../Shared Code/Xcode5/IDEKit/IDESourceCodeEditor.h"
#import "../Shared Code/Xcode5/IDEKit/IDEConsoleTextView.h"
#import "../Shared Code/Xcode5/IDEKit/IDEEditorCoordinator.h"
#import "../Shared Code/Xcode5/IDEKit/IDEEditorOpenSpecifier.h"
#import "../Shared Code/Xcode5/IDEKit/IDEWorkspaceWindow.h"
#import "../Shared Code/Xcode5/IDEKit/IDEWorkspaceWindowController.h"
#import "../Shared Code/Xcode5/IDEKit/IDEWorkspaceTabController.h"
#import "../Shared Code/Xcode5/IDEKit/IDEWorkspaceDocument.h"
#import "../Shared Code/Xcode5/IDEKit/IDEWorkspace.h"
#import "../Shared Code/Xcode5/IDEKit/IDERunContextManager.h"
#import "../Shared Code/Xcode5/IDEKit/IDEScheme.h"
#import "../Shared Code/Xcode5/IDEKit/IDELaunchSchemeAction.h"
#import "../Shared Code/Xcode5/IDEKit/IDECommandLineArgumentEntry.h"
#import "../Shared Code/Xcode5/IDEKit/IDEBatchFindStrategiesController.h"
#import "../Shared Code/Xcode5/IDEKit/IDEBatchFindNavigator.h"
#import "../Shared Code/Xcode5/IDEKit/IDEBreakpoint.h"
#import "../Shared Code/Xcode5/IDEKit/IDEBreakpointManager.h"
#import "../Shared Code/Xcode5/IDEKit/DBGLLDBDebugLocalService.h"
#import "../Shared Code/Xcode5/IDEKit/DBGLLDBLauncher.h"

#import "../Shared Code/Xcode5/AppKit/NSCarbonMenuImpl.h"

static IMP original_doCommandBySelector = nil;
static IMP original_shouldIndentPastedText = nil;
static IMP original_didSelectTabViewItem = nil;
static IMP original_mouseDownInConsole = nil;
static IMP original_becomeFirstResponder_Console = nil;
static IMP original_becomeFirstResponder_Search = nil;
static IMP original_becomeFirstResponder_NavigatorOutlineView = nil;
static IMP original_becomeFirstResponder_DVTFindPatternFieldEditor = nil;
static IMP original_resignFirstResponder_DVTFindPatternFieldEditor = nil;
static IMP original_menuItemWithKeyEquivalentMatchingEventRef = nil;
static IMP original_LLDBLauncherStart = nil;



enum EPreferredNextLocation
{
	EPreferredNextLocation_Undefined
	, EPreferredNextLocation_Search
	, EPreferredNextLocation_Issue
	, EPreferredNextLocation_Console
};

@interface NSView (SubtreeDescription)

- (NSString *)_subtreeDescription;

@end

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
//	XCFixinLog(@"%@\n", [nextResponder className]);
    if ([nextResponder isKindOfClass:ClassToFind]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[NSView class]]) {
        return [nextResponder traverseResponderChainForResponder:ClassToFind];
    } else {
        return nil;
    }
}
@end

@interface XCFixin_EmulateVisualStudio : NSObject
{
	id eventMonitor;
}
@end

@implementation XCFixin_EmulateVisualStudio

static void setEditorFocus(NSWindow* _pWindow)
{
	IDESourceCodeEditorContainerView* pView = getSourceCodeEditorView(_pWindow);
	
	if (pView)
	{
		IDESourceCodeEditor* pEditor = [pView editor];
		if (pEditor)
			[pEditor takeFocus];
	}
}

enum EPreferredNextLocation g_PreferredNextLocation = EPreferredNextLocation_Undefined;

static bool displayRecentsMenu(NSMenu* _pMenu, NSView* _pView, bool _bPretend)
{
	bool bFoundRecents = false;
	NSMenuItem* pFirstRecentItem = nil;
	for (NSMenuItem* pItem in [_pMenu itemArray])
	{
		if (bFoundRecents)
		{
			pFirstRecentItem = pItem;
			break;
		}
		if ([[pItem title] compare:@"Recent Results"] == NSOrderedSame)
			bFoundRecents = true;
	}
	
	if (pFirstRecentItem)
	{
		if (_bPretend)
			return true;
		NSPoint Location;
		Location.x = 0;
		Location.y = 0;
		[_pMenu popUpMenuPositioningItem:pFirstRecentItem atLocation:Location inView:_pView];
		return true;
	}
	return false;
}


bool findFieldHasFocusInBatchNavigator(IDEBatchFindNavigator* _pNavigator)
{
	DVTFindPatternTextField* pField = [_pNavigator _findField];
	if (pField)
	{
		DVTFindPatternFieldEditor* pFirstResponder = (DVTFindPatternFieldEditor*)[[pField window] firstResponder];
		if ([pFirstResponder isKindOfClass:[DVTFindPatternFieldEditor class]])
		{
			if ([pField _fieldEditor] == pFirstResponder)
				return true;
		}
	}
	return false;
}

bool replaceFieldHasFocusInBatchNavigator(IDEBatchFindNavigator* _pNavigator)
{
	DVTFindPatternTextField* pField = [_pNavigator _replaceField];
	if (pField)
	{
		DVTFindPatternFieldEditor* pFirstResponder = (DVTFindPatternFieldEditor*)[[pField window] firstResponder];
		if ([pFirstResponder isKindOfClass:[DVTFindPatternFieldEditor class]])
		{
			if ([pField _fieldEditor] == pFirstResponder)
				return true;
		}
	}
	return false;
}

static bool handleFieldEditorEvent(unsigned short keyCode, NSUInteger ModifierFlags, NSEvent *event)
{
	if ((ModifierFlags & (NSCommandKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSShiftKeyMask)) == NSControlKeyMask)
	{
		// Control
		
		if (keyCode == kVK_ANSI_H)
		{
			
			do
			{
				NSWindow* pWindow = nil;
				if (event)
					pWindow = [event window];
				else
					pWindow = [NSApp keyWindow];
					
				if (!pWindow)
					break;
				DVTSourceTextView *pSourceTextView = (DVTSourceTextView *)findSubViewWithClassName([pWindow contentView], "DVTSourceTextView");
				if (!pSourceTextView)
					break;
				
				NSRange SelectedRange = [pSourceTextView selectedRange];
				
				NSRange LineRange = [[pSourceTextView textStorage] lineRangeForCharacterRange: SelectedRange];
				
				DVTAnnotationManager* pAnnotationManager = [pSourceTextView annotationManager];
				if (!pAnnotationManager)
					break;

				IDEWorkspaceTabController* pTabController = getWorkspaceTabController(pWindow);
				if (!pTabController)
					break;
				
				IDEWorkspace* pWorkspace = [pTabController workspace];
				if (!pWorkspace)
					break;
				
				IDEBreakpointManager* pBreakpointManager = [pWorkspace breakpointManager];
				if (!pBreakpointManager)
					break;
				
				NSMutableArray* pBreakpointsToDelete = [[NSMutableArray alloc] initWithCapacity:16];
				for (NSDictionary* pProviderDict in [pAnnotationManager annotationProviders])
				{
					DVTAnnotationProvider* pProvider = (DVTAnnotationProvider*)[pProviderDict valueForKey:@"annotationProviderObject"];
					
					if ([pProvider isKindOfClass:NSClassFromString(@"DBGBreakpointAnnotationProvider")])
					{
						DBGBreakpointAnnotationProvider* pBreakpointProvider = (DBGBreakpointAnnotationProvider*)pProvider;
						
						for (DBGBreakpointAnnotation* pAnnotation in [pBreakpointProvider annotations])
						{
							NSRange BreakpointRange = [pAnnotation paragraphRange];

							if (NSIntersectionRange(LineRange, BreakpointRange).length == 0)
								continue;
							
							if ([[pAnnotation representedObject] isKindOfClass:NSClassFromString(@"IDEBreakpoint")])
							{
								IDEBreakpoint* pBreakpoint = (IDEBreakpoint*)[pAnnotation representedObject];

								[pBreakpointsToDelete addObject:pBreakpoint];
								
							}
						}
					}
				}
				
				if ([pBreakpointsToDelete count] > 0)
				{
					if (event)
						return true;
					
					for (IDEBreakpoint* pBreakpoint in pBreakpointsToDelete)
						[pBreakpointManager removeBreakpoint:pBreakpoint];
					
					return true;
				}
			}
			while (false)
				;
		}
	}
	
	DVTFindBar* pFindBar = getFindBar(g_pRespondingPatternFieldEditor);

	IDEBatchFindStrategiesController* pBatchFindController = nil;
	
	if (!pFindBar)
		pBatchFindController = getBatchFindStrategiesController(g_pRespondingPatternFieldEditor);
	
	if (!pFindBar && !g_pFindBarOptionsCtrl && !pBatchFindController)
		return false;
	
	if ((ModifierFlags & (NSCommandKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSShiftKeyMask)) == 0)
	{
		// Alone key
		if (keyCode == kVK_Tab)
		{
			if (pBatchFindController)
			{
				IDEBatchFindNavigator* pNavigator = getBatchFindNavigator(g_pRespondingPatternFieldEditor);
				if (pNavigator)
				{
					if (findFieldHasFocusInBatchNavigator(pNavigator))
					{
						DVTFindPatternTextField* pReplaceField = [pNavigator _replaceField];
						if (pReplaceField && [pNavigator findMode] == 1)
						{
							if (!event)
								return true;
							[pReplaceField becomeFirstResponder];
							return true;
						}
					}
				}
			}
			else if (pFindBar)
			{
				if ([pFindBar findFieldHasFocus] && [pFindBar finderMode] == 1)
				{
					if (!event)
						return true;
					[pFindBar selectReplaceField:nil];
					return true;
				}
			}
		}
		else if (keyCode == kVK_DownArrow)
		{
			if (pBatchFindController)
			{
				IDEBatchFindNavigator* pNavigator = getBatchFindNavigator(g_pRespondingPatternFieldEditor);
				if (pNavigator)
				{
					if (findFieldHasFocusInBatchNavigator(pNavigator))
					{
						DVTFindPatternTextField* pField = [pNavigator _findField];
						if (displayRecentsMenu([pNavigator _recentsMenu], pField, event != nil))
							return true;
					}
				}
			}
			else if (pFindBar)
			{
				if ([pFindBar findFieldHasFocus])
				{
					if (displayRecentsMenu([pFindBar _recentsMenu], [pFindBar findBarView], event != nil))
						return true;
				}
			}
		}
		else if (keyCode == kVK_Escape)
		{
			if (pBatchFindController)
			{
				if (!event)
					return true;
				
				setEditorFocus([event window]);
				return true;
			}
		}
	}
	if ((ModifierFlags & (NSCommandKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSShiftKeyMask)) == NSShiftKeyMask)
	{
		// Shift key
		if (keyCode == kVK_Tab )
		{
			if (pBatchFindController)
			{
				IDEBatchFindNavigator* pNavigator = getBatchFindNavigator(g_pRespondingPatternFieldEditor);
				if (pNavigator)
				{
					if (replaceFieldHasFocusInBatchNavigator(pNavigator))
					{
						DVTFindPatternTextField* pFindField = [pNavigator _findField];
						if (pFindField && [pNavigator findMode] == 1)
						{
							if (!event)
								return true;
							[pFindField becomeFirstResponder];
							return true;
						}
					}
				}
			}
			else if (pFindBar)
			{
				if ([pFindBar replaceFieldHasFocus] && [pFindBar finderMode] == 1)
				{
					if (!event)
						return true;
					[pFindBar selectFindField:nil];
					return true;
				}
			}
		}
	}
	if ((ModifierFlags & (NSCommandKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSShiftKeyMask)) == NSControlKeyMask)
	{
		// Control
		
		if (keyCode == kVK_ANSI_N && pFindBar)
		{
			if (!event)
				return true;
			[pFindBar findNext:nil];
			return true;
		}
		else if (keyCode == kVK_ANSI_R)
		{
			if (pBatchFindController)
			{
				IDEBatchFindNavigator* pNavigator = getBatchFindNavigator(g_pRespondingPatternFieldEditor);
				if (pNavigator && [pNavigator findMode] == 1)
				{
					if (!event)
						return true;
					if ([pNavigator canShowReplacePreview])
						[pNavigator showReplacePreview:nil];
					return true;
				}
			}
			else if (pFindBar && [pFindBar finderMode] == 1)
			{
				if (!event)
					return true;
				[pFindBar replaceAndFindNext:nil];
				return true;
			}
		}
		else if (keyCode == kVK_ANSI_A)
		{
			if (pBatchFindController)
			{
				IDEBatchFindNavigator* pNavigator = getBatchFindNavigator(g_pRespondingPatternFieldEditor);
				if (pNavigator && [pNavigator findMode] == 1)
				{
					if (!event)
						return true;
					if ([pNavigator canReplaceAll])
						[pNavigator replaceAllAction:nil];
					return true;
				}
			}
			else if (pFindBar && [pFindBar finderMode] == 1)
			{
				if (!event)
					return true;
				[pFindBar replaceAll:nil];
				return true;
			}
		}
		else if (keyCode == kVK_ANSI_O && pFindBar)
		{
			if (!event)
				return true;
			[pFindBar _showFindOptionsPopover:nil];
			return true;
		}
		else if (keyCode == kVK_ANSI_C)
		{
			if (pBatchFindController)
			{
				if (!event)
					return true;
				pBatchFindController.ignoresCase = !pBatchFindController.ignoresCase;
				return true;
			}
			else
			{
				DVTFindBarOptionsCtrl* pOptionsControl = g_pFindBarOptionsCtrl;
				if (!pOptionsControl)
					pOptionsControl = [pFindBar optionsCtrl];
				if (pOptionsControl)
				{
					if (!event)
						return true;
					pOptionsControl.findIgnoresCase = !pOptionsControl.findIgnoresCase;
					return true;
				}
			}
		}
		else if (keyCode == kVK_ANSI_E)
		{
			if (pBatchFindController)
			{
				if (!event)
					return true;
				if (pBatchFindController.findType == 0)
					pBatchFindController.findType = 1;
				else
					pBatchFindController.findType = 0;
				IDEBatchFindNavigator* pNavigator = getBatchFindNavigator(g_pRespondingPatternFieldEditor);
				if (pNavigator)
					[pNavigator updatePathbar];
				return true;
			}
			else
			{

				DVTFindBarOptionsCtrl* pOptionsControl = g_pFindBarOptionsCtrl;
				if (!pOptionsControl)
					pOptionsControl = [pFindBar optionsCtrl];
				if (pOptionsControl)
				{
					if (!event)
						return true;
					if (pOptionsControl.findType == 0)
						pOptionsControl.findType = 1;
					else
						pOptionsControl.findType = 0;
					return true;
				}
			}
		}
		else if (keyCode == kVK_ANSI_W)
		{
			if (pBatchFindController)
			{
				if (!event)
					return true;
				if (pBatchFindController.matchStyle == 0)
					pBatchFindController.matchStyle = 2;
				else
					pBatchFindController.matchStyle = 0;
				IDEBatchFindNavigator* pNavigator = getBatchFindNavigator(g_pRespondingPatternFieldEditor);
				if (pNavigator)
					[pNavigator updatePathbar];
				return true;
			}
			else
			{
				DVTFindBarOptionsCtrl* pOptionsControl = g_pFindBarOptionsCtrl;
				if (!pOptionsControl)
					pOptionsControl = [pFindBar optionsCtrl];
				if (pOptionsControl)
				{
					if (!event)
						return true;
					if (pOptionsControl.matchStyle == 0)
						pOptionsControl.matchStyle = 2;
					else
						pOptionsControl.matchStyle = 0;
					return true;
				}
			}
		}
		else if (keyCode == kVK_ANSI_L)
		{
			if (pBatchFindController)
			{
				IDEBatchFindNavigator* pNavigator = getBatchFindNavigator(g_pRespondingPatternFieldEditor);
				if (pNavigator)
				{
					if (!event)
						return true;
					[pNavigator showLocationPicker:nil];
					return true;
				}
			}
		}
	}
	if ((ModifierFlags & (NSCommandKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSShiftKeyMask)) == (NSControlKeyMask | NSShiftKeyMask))
	{
		// Control + shift
		if (keyCode == kVK_ANSI_N)
		{
			if (!event)
				return true;
			[pFindBar findPrevious:nil];
			return true;
		}
	}
	
	return false;
}

//-----------------------------------------------------------------------------------------------
- (id) init {
//-----------------------------------------------------------------------------------------------
	self = [super init];
	if (self) 
	{
		g_LLDBLaunchLock = [[NSLock alloc] init];


		NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];

		[notificationCenter addObserver: self
							   selector: @selector( frameChanged: )
								   name: NSViewFrameDidChangeNotification
								 object: nil];
		  
		[notificationCenter addObserver: self
							   selector: @selector( windowDidBecomeKey: )
								   name: NSWindowDidBecomeKeyNotification
								 object: nil];
		  
		[notificationCenter addObserver: self
							   selector: @selector( popoverDidShowNotification: )
								   name: NSPopoverDidShowNotification
								 object: nil];
		  
		[notificationCenter addObserver: self
							   selector: @selector( popoverWillCloseNotification: )
								   name: NSPopoverWillCloseNotification
								 object: nil];
		
		eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent *(NSEvent *event) 
		{
			unsigned short keyCode = [event keyCode];
			//XCFixinLog(@"%d %@ %@\n", keyCode, [event characters], [event charactersIgnoringModifiers]);
			NSUInteger ModifierFlags = [event modifierFlags];
			
			bool bHandled = false;

			do
			{
				if (handleFieldEditorEvent(keyCode, ModifierFlags, event))
					return nil;

				if ((keyCode == kVK_ANSI_G) && (ModifierFlags & (NSCommandKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSShiftKeyMask)) == NSCommandKeyMask) 
				{
					// Run
					
					IDEWorkspaceTabController* pTabController = getWorkspaceTabController([event window]);
					
					if (!pTabController)
						break;
					
					IDEWorkspace* pWorkspace = [pTabController workspace];
					if (!pWorkspace)
						break;

					IDERunContextManager* pRunContextManager = [pWorkspace runContextManager];
					if (!pRunContextManager)
						break;
					
					IDEScheme* pActiveScheme = [pRunContextManager activeRunContext];
					if (!pActiveScheme)
						break;
					
					IDELaunchSchemeAction* pLaunchAction = [pActiveScheme launchSchemeAction];
					
					if (!pLaunchAction)
						break;
					
					if ([pLaunchAction runnable])
						break; // User configured runnable
					
					NSString *pCustomWorkingDir = [pLaunchAction customWorkingDirectory];
					
					if ([pCustomWorkingDir compare:@"[MulitLaunchSchemes]"] != NSOrderedSame)
						break; // Magic enable for multil launch

					for (IDECommandLineArgumentEntry* pCommandLineArg in [pLaunchAction commandLineArgumentEntries])
					{
						if (!pCommandLineArg.isEnabled)
							continue;
						for (IDEScheme* pScheme in [pRunContextManager runContexts])
						{
							if ([[pScheme name] compare:[pCommandLineArg argument]] == NSOrderedSame)
							{
								[pTabController _runWithoutBuildingForScheme:pScheme runDestination:[pRunContextManager activeRunDestination] invocationRecord:nil];
								bHandled = true;
								//[NSThread sleepForTimeInterval:0.0];
								//XCFixinLog(@"pScheme %@\n", [pScheme name]);
							}
						}
					}
				}
				else if ((keyCode == kVK_ANSI_N) && (ModifierFlags & (NSCommandKeyMask | NSControlKeyMask | NSAlternateKeyMask)) == NSCommandKeyMask) 
				{
					if (g_PreferredNextLocation == EPreferredNextLocation_Console)
					{
						IDEConsoleTextView* pView = getConsoleTextView(nil);
						if (pView)
						{
							bHandled = true;
							navigateToLineInConsoleTextView(pView, true, ModifierFlags & NSShiftKeyMask);
						}
					}
					else if (m_pActiveView && [m_pActiveView isValid])
					{
						NSWindow* pWindow = [m_pActiveView window];
						bool bSetEditorFocus = false;
						if (m_pActiveViewControllerBatchFind)
						{
							if (ModifierFlags & NSShiftKeyMask)
								[m_pActiveView doCommandBySelector:@selector(moveUp:)];
							else
								[m_pActiveView doCommandBySelector:@selector(moveDown:)];
						
							[m_pActiveViewControllerBatchFind openSelectedNavigableItemsKeyAction:m_pActiveView];
							bSetEditorFocus = true;
							bHandled = true;
						}
						else
						{
							unsigned short KeyCode = 0;
							NSString* pCharacters;
							if (ModifierFlags & NSShiftKeyMask)
							{
								KeyCode = 126;
								pCharacters = @"";
							}
							else
							{
								KeyCode = 125;
								pCharacters = @"";
							}
							NSEvent* pEvent = [
								NSEvent keyEventWithType:NSKeyDown 
								location:[pWindow mouseLocationOutsideOfEventStream] 
								modifierFlags:0xa00100
								timestamp:0.0
								windowNumber:[pWindow windowNumber]
								context:nil 
								characters:pCharacters 
								charactersIgnoringModifiers:pCharacters
								isARepeat:false 
								keyCode:KeyCode
							];
							
							bool bDoNavigation = false;
							IDEIssueNavigableItem* pLastSelected = nil;
							do
							{
								NSArray* pSelected = [m_pActiveView selectedItems];
								if ([pSelected count] <= 0)
									break;
								pLastSelected = (IDEIssueNavigableItem*)pSelected[0];
							}
							while (false)
								;
							while (true)
							{
								{
									NSArray* pSelected = [m_pActiveView selectedItems];
									if ([pSelected count] <= 0)
										break;
									IDEIssueNavigableItem* pSelectedItem = (IDEIssueNavigableItem*)pSelected[0];
									pLastSelected = pSelectedItem;
									NSString* pClassName = [pSelectedItem className];
									if ([pClassName compare:@"IDEIssueNavigableItem_AnyIDEIssue"] == NSOrderedSame)
									{
										if (![pSelectedItem isLeaf])
											[m_pActiveView expandItem:pSelectedItem];
									}
								}
								[m_pActiveView keyDown:pEvent];
								NSArray* pSelected = [m_pActiveView selectedItems];
								if ([pSelected count] <= 0)
									break;
								
								IDEIssueNavigableItem* pSelectedItem = (IDEIssueNavigableItem*)pSelected[0];
								if (pLastSelected == pSelectedItem)
									break; // No change in selection
								pLastSelected = pSelectedItem;
								NSString* pClassName = [pSelectedItem className];
								//XCFixinLog(@"%@ %d", pClassName, [pSelectedItem isLeaf]);
								bDoNavigation = false;
								if ([pClassName compare:@"IDEIssueGroupNavigableItem_AnyIDEIssueGroup"] == NSOrderedSame)
									continue;
								else if ([pClassName compare:@"IDEIssueFileGroupNavigableItem_AnyIDEIssueFileGroup"] == NSOrderedSame)
									continue;
								else if ([pClassName compare:@"IDEIssueNavigableItem_AnyIDEIssue"] == NSOrderedSame)
								{
									bDoNavigation = true;
									if (![pSelectedItem isLeaf])
										[m_pActiveView expandItem:pSelectedItem];
								}
								break;
							}
							
							if (m_pActiveViewControllerIssues && bDoNavigation)
							{
								[m_pActiveViewControllerIssues openSelectedNavigableItemsKeyAction:m_pActiveView];
								bSetEditorFocus = true;
								bHandled = true;
							}
						}
						if (bSetEditorFocus)
							setEditorFocus(pWindow);
					}
					return nil;
				}
			}
			while (false)
				;
			if (bHandled)
				return nil;
			return event;
		}];
	}
	return self;
}

//-----------------------------------------------------------------------------------------------
- (void) dealloc {
//-----------------------------------------------------------------------------------------------
	[NSEvent removeMonitor:eventMonitor];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

static NSView* findSubViewWithClassName(NSView* _pView, char const* _pClassName)
{
	char const* pClassName = object_getClassName([_pView class]);
	if (strcmp(pClassName, _pClassName) == 0)
		return _pView;
	for (NSView * pView in [_pView subviews]) 
	{
		NSView * pFound;
		if ((pFound = findSubViewWithClassName(pView, _pClassName)))
			return pFound;
	}
	return NULL;
}

static NSView* findSubViewWithController(NSView* _pView, Class ClassToFind)
{
	NSViewController* pViewController = (NSViewController*)[_pView firstAvailableResponderOfClass:ClassToFind];
	if (pViewController)
		return _pView;
	for (NSView * pView in [_pView subviews]) 
	{
		
		NSView * pFound;
		if ((pFound = findSubViewWithController(pView, ClassToFind)))
			return pFound;
	}
	return NULL;
}

static NSView* findParentViewWithClassName(NSView* _pView, char const* _pClassName)
{
	char const* pClassName = object_getClassName([_pView class]);
	if (strcmp(pClassName, _pClassName) == 0)
		return _pView;
	NSView * pView;
	if ((pView = [_pView superview])) 
	{
		NSView * pFound;
		if ((pFound = findParentViewWithClassName(pView, _pClassName)))
			return pFound;
	}
	return NULL;
}

static NSView* findParentViewWithController(NSView* _pView, Class ClassToFind)
{
	NSViewController* pViewController = (NSViewController*)[_pView firstAvailableResponderOfClass:ClassToFind];
	if (pViewController)
		return _pView;
	NSView * pView;
	if ((pView = [_pView superview])) 
	{
		NSView * pFound;
		if ((pFound = findParentViewWithController(pView, ClassToFind)))
			return pFound;
	}
	return NULL;
}

IDENavigatorOutlineView* m_pActiveView = nil;
IDEBatchFindResultsOutlineController* m_pActiveViewControllerBatchFind = nil;
IDEIssueNavigator* m_pActiveViewControllerIssues = nil;

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	//g_PreferredNextLocation = EPreferredNextLocation_Undefined;
	
	NSWindow *window = [notification object];
	
	//NSString* pDesc = [[window contentView] _subtreeDescription];
	//XCFixinLog(@"%@\n", pDesc);
	g_pLastValidEditorTabItem = nil;
	g_pLastValidEditorTabView = nil;
	updateLastValidEditorTab(window);
	
	potentialView((IDENavigatorOutlineView*)findSubViewWithClassName([window contentView], "IDENavigatorOutlineView"));
}


- (void)popoverDidShowNotification:(NSNotification *)notification
{
	NSPopover* pPopover = [notification object];
	DVTFindBarOptionsCtrl* pViewController = (DVTFindBarOptionsCtrl*)[pPopover contentViewController];
	if ([pViewController isKindOfClass:[DVTFindBarOptionsCtrl class]])
	{
		g_pFindBarOptionsCtrl = pViewController;
	}
}

- (void)popoverWillCloseNotification:(NSNotification *)notification
{
	NSPopover* pPopover = [notification object];
	DVTFindBarOptionsCtrl* pViewController = (DVTFindBarOptionsCtrl*)[pPopover contentViewController];
	if ([pViewController isKindOfClass:[DVTFindBarOptionsCtrl class]])
	{
		if (g_pFindBarOptionsCtrl == pViewController)
			g_pFindBarOptionsCtrl = nil;
	}
}


//-----------------------------------------------------------------------------------------------
- (void) frameChanged:(NSNotification*)notification {
	
	if ([[notification.object className] compare:@"IDENavigatorOutlineView"] == NSOrderedSame)
	{
		NSWindow *keyWindow = [NSApp keyWindow];
		IDENavigatorOutlineView* pOutlineView = (IDENavigatorOutlineView*)notification.object;
		if (pOutlineView && [pOutlineView window] == keyWindow)
		{
			NSViewController* pActiveViewController = (NSViewController*)[pOutlineView firstAvailableResponderOfClass: [NSViewController class]];
			if (pActiveViewController)
				potentialView(pOutlineView);
		}
	}
}

static int clearSelection(id self_)
{
	NSTextView *self = (NSTextView *)self_;
	
	NSRange range = [self selectedRange];
	
	if (range.length == 0)
		return 0;
	
	int ret = 0;
	// Make the default extending direction correct
	NSResponder *selfResponder = (NSResponder *)self_;
	if (selfResponder)
	{
		[selfResponder moveBackwardAndModifySelection:self];
		NSRange rewRange = [self selectedRange];
		if (rewRange.location < range.location)
		{
			rewRange = NSMakeRange(range.location, 0);
			ret = 1;
		}
		else if (rewRange.length < range.length)
		{
			rewRange = NSMakeRange(range.location + range.length, 0);
			ret = 2;
		}
		else
			rewRange = NSMakeRange(range.location, 0);
		[self setSelectedRange:rewRange];
	}
	return ret;
}

static void moveRange(id self_, NSRange range, NSRange lastRange, int originalLocation)
{
	NSTextView *self = (NSTextView *)self_;

	[self setSelectedRange:range];
	
	int location = originalLocation;
	
	// Make the default extending direction correct
	NSResponder *selfResponder = (NSResponder *)self_;
	if (selfResponder && range.length > 0 && (range.location != lastRange.location || range.length != lastRange.length))
	{
		NSUInteger lastStart = lastRange.location;
		NSUInteger lastEnd = lastRange.location + lastRange.length;
		//NSUInteger newStart = range.location;
		NSUInteger newEnd = range.location + range.length;
		
		if (newEnd == lastEnd || (newEnd == lastStart))
			location = 1;
		else
			location = 2;
	}
	
	if (location == 1)
	{
		[selfResponder moveBackwardAndModifySelection:self];
		NSRange rewRange = [self selectedRange];
		if (rewRange.location < range.location)
			[selfResponder moveForwardAndModifySelection:self];
	}
	else if (location == 2)
	{
		[selfResponder moveForwardAndModifySelection:self];
		NSRange rewRange = [self selectedRange];
		if (rewRange.length > range.length)
			[selfResponder moveBackwardAndModifySelection:self];
	}
	
	[self scrollRangeToVisible:range];
}

static BOOL shouldIndentPastedText(id self, SEL _cmd, id arg1)
{
	return false;
}

static bool stringRangeContainsCharacters(NSString *text, NSRange range, NSCharacterSet *characters)
{
	NSString *rangeString = [text substringWithRange:range];
	NSRange codeStartRange = [rangeString rangeOfCharacterFromSet:characters];
	return codeStartRange.location != NSNotFound;
}


static void potentialView(IDENavigatorOutlineView* _pView)
{
//	IDEBatchFindResultsOutlineController
	NSViewController* pViewController = (NSViewController*)[_pView firstAvailableResponderOfClass: [	NSViewController class]];
	if (pViewController)
	{
		if ([pViewController isKindOfClass:[IDEBatchFindResultsOutlineController class]])
		{
			m_pActiveView = _pView;
			m_pActiveViewControllerBatchFind = (IDEBatchFindResultsOutlineController*)pViewController;
			m_pActiveViewControllerIssues = nil;
		}
		else if ([pViewController isKindOfClass:[IDEIssueNavigator class]])
		{
			m_pActiveView = _pView;
			m_pActiveViewControllerIssues = (IDEIssueNavigator*)pViewController;
			m_pActiveViewControllerBatchFind = nil;
		}
		else
		{
			m_pActiveView = nil;
			m_pActiveViewControllerIssues = nil;
			m_pActiveViewControllerBatchFind = nil;
 		}
	}
	else
	{
		m_pActiveView = nil;
		m_pActiveViewControllerIssues = nil;
		m_pActiveViewControllerBatchFind = nil;
	}
}

//- (void)tabView:(id)arg1 didSelectTabViewItem:(id)arg2;
NSTabViewItem* g_pLastValidEditorTabItem = nil;
NSTabView* g_pLastValidEditorTabView = nil;

static void updateLastValidEditorTab(NSWindow* _pWindow)
{
	NSTabView* pTabView = getWorkspaceTabView(_pWindow);
	if (!pTabView)
		return;
	
	NSTabViewItem* pSelectedItem = [pTabView selectedTabViewItem];
	
	if (!pSelectedItem)
		return;
	if (getSourceCodeEditorView(_pWindow))
	{
		g_pLastValidEditorTabItem = pSelectedItem;
		g_pLastValidEditorTabView = pTabView;
	}
}

static BOOL didSelectTabViewItem( NSView *self_, SEL _cmd, NSTabView *_pTabView, NSTabViewItem *_pItem)
{
	g_PreferredNextLocation = EPreferredNextLocation_Undefined;
	updateLastValidEditorTab([_pTabView window]);
	
	potentialView((IDENavigatorOutlineView*)findSubViewWithClassName([_pItem view], "IDENavigatorOutlineView"));
	return ((BOOL (*)(id, SEL, id, id))original_didSelectTabViewItem)(self_, _cmd, _pTabView, _pItem);
}

static IDESourceCodeEditorContainerView* getSourceCodeEditorView(NSWindow *_pWindow)
{
	if (_pWindow == nil)
		_pWindow = [NSApp keyWindow];
	return (IDESourceCodeEditorContainerView*)findSubViewWithClassName([_pWindow contentView], "IDESourceCodeEditorContainerView");
}
static IDEWorkspaceTabController* getWorkspaceTabController(NSWindow *_pWindow)
{
	if (_pWindow == nil)
		_pWindow = [NSApp keyWindow];
	NSTabView* pView = (NSTabView*)findSubViewWithClassName([_pWindow contentView], "DVTControllerContentView");
	if (pView)
	{
		NSViewController* pViewController = (NSViewController*)[pView firstAvailableResponderOfClass: [	NSViewController class]];
		if ([pViewController isKindOfClass:NSClassFromString(@"IDEWorkspaceTabController")])
		{
			return (IDEWorkspaceTabController*)pViewController;
		}
	}
	return nil;
}
static NSTabView* getWorkspaceTabView(NSWindow *_pWindow)
{
	if (_pWindow == nil)
		_pWindow = [NSApp keyWindow];
	NSTabView* pView = (NSTabView*)findSubViewWithClassName([_pWindow contentView], "NSTabView");
	return pView;
}

static IDEConsoleTextView* getConsoleTextView(NSWindow *_pWindow)
{
	if (_pWindow == nil)
		_pWindow = [NSApp keyWindow];
	IDEConsoleTextView* pView = (IDEConsoleTextView*)findSubViewWithClassName([_pWindow contentView], "IDEConsoleTextView");
	return pView;
}



static BOOL becomeFirstResponder_Console(IDEConsoleTextView* self_, SEL _cmd)
{
	g_PreferredNextLocation = EPreferredNextLocation_Console;
	//XCFixinLog(@"%@ become first responder\n", [self_ className]);
	return ((BOOL (*)(id, SEL))original_becomeFirstResponder_Console)(self_, _cmd);
}

static BOOL becomeFirstResponder_Search(id self_, SEL _cmd)
{
	g_PreferredNextLocation = EPreferredNextLocation_Search;
	//XCFixinLog(@"%@ become first responder\n", [self_ className]);
	return ((BOOL (*)(id, SEL))original_becomeFirstResponder_Search)(self_, _cmd);
}


static BOOL becomeFirstResponder_NavigatorOutlineView(IDENavigatorOutlineView* self_, SEL _cmd)
{
	potentialView(self_);
	if (m_pActiveViewControllerBatchFind)
		g_PreferredNextLocation = EPreferredNextLocation_Search;
	else if (m_pActiveViewControllerIssues)
		g_PreferredNextLocation = EPreferredNextLocation_Issue;
	//XCFixinLog(@"%@ become first responder\n", [self_ className]);
	return ((BOOL (*)(id, SEL))original_becomeFirstResponder_NavigatorOutlineView)(self_, _cmd);
}

DVTFindPatternFieldEditor* g_pRespondingPatternFieldEditor = nil;

DVTFindBarOptionsCtrl* g_pFindBarOptionsCtrl = nil;

static BOOL becomeFirstResponder_DVTFindPatternFieldEditor(DVTFindPatternFieldEditor* self_, SEL _cmd)
{
	//XCFixinLog(@"%@ become first responder\n", [self_ className]);
	g_pRespondingPatternFieldEditor = self_;
	return ((BOOL (*)(id, SEL))original_becomeFirstResponder_DVTFindPatternFieldEditor)(self_, _cmd);
}

static BOOL resignFirstResponder_DVTFindPatternFieldEditor(DVTFindPatternFieldEditor* self_, SEL _cmd)
{
	//XCFixinLog(@"%@ resign first responder\n", [self_ className]);
	if (g_pRespondingPatternFieldEditor == self_)
		g_pRespondingPatternFieldEditor = nil;
	return ((BOOL (*)(id, SEL))original_resignFirstResponder_DVTFindPatternFieldEditor)(self_, _cmd);
}

static DVTFindBar* getFindBar(DVTFindPatternFieldEditor* self_)
{
	NSView* pParentView = findParentViewWithClassName(self_, "DVTFindPatternFieldEditor");
	if (pParentView)
	{
		DVTFindBar* pViewController = (DVTFindBar*)[pParentView firstAvailableResponderOfClass:NSClassFromString(@"DVTFindBar")];
		if (pViewController)
			return pViewController;
	}
	
	return nil;
}

static IDEBatchFindStrategiesController* getBatchFindStrategiesController(DVTFindPatternFieldEditor* self_)
{
	NSView* pParentView = findParentViewWithClassName(self_, "DVTControllerContentView");
	if (pParentView)
	{
		IDEBatchFindNavigator* pViewController = (IDEBatchFindNavigator*)[pParentView firstAvailableResponderOfClass:NSClassFromString(@"IDEBatchFindNavigator")];
		if (pViewController)
			return [pViewController configurationController];
	}
	
	return nil;
}

static IDEBatchFindNavigator* getBatchFindNavigator(DVTFindPatternFieldEditor* self_)
{
	NSView* pParentView = findParentViewWithClassName(self_, "DVTControllerContentView");
	if (pParentView)
	{
		IDEBatchFindNavigator* pViewController = (IDEBatchFindNavigator*)[pParentView firstAvailableResponderOfClass:NSClassFromString(@"IDEBatchFindNavigator")];
		if (pViewController)
			return pViewController;
	}
	
	return nil;
}


NSLock<NSLocking> *g_LLDBLaunchLock = nil;
DVTDispatchLock *g_LLDBLifeCycleLock = nil;
Ivar g_LLDBLifeCycleLockIvar = nil;

// - (void)start;
static void LLDBLauncherStart(DBGLLDBLauncher* self_, SEL _Sel)
{
	[g_LLDBLaunchLock lock];
	if (!g_LLDBLifeCycleLock)
	{
		// Make all LLDB debuggers use the same serialization queue to improve stability
		Ivar IVar = class_getInstanceVariable(NSClassFromString(@"DBGLLDBLauncher"), "_lifeCycleLock");
		
		if (IVar)
		{
			g_LLDBLifeCycleLockIvar = IVar;
			g_LLDBLifeCycleLock = object_getIvar(self_, g_LLDBLifeCycleLockIvar);
		}
	}
	else
	{
		object_setIvar(self_, g_LLDBLifeCycleLockIvar, g_LLDBLifeCycleLock);
	}
//	XCFixinLog(@"LLDBLauncherStart: %p\n", self_);
	((void(*)(id self_, SEL _Sel))original_LLDBLauncherStart)(self_, _Sel);
//	XCFixinLog(@"LLDBLauncherStart finished: %p\n", self_);
	[g_LLDBLaunchLock unlock];
}


// + (struct _NSCarbonMenuSearchReturn)_menuItemWithKeyEquivalentMatchingEventRef:(struct OpaqueEventRef *)arg1 inMenu:(id)arg2;
static void menuItemWithKeyEquivalentMatchingEventRef(struct _NSCarbonMenuSearchReturn *_pRetVal, id self_, SEL _Sel, EventRef _pEventRef, id _pInMenu)
{
	OSType EventClass = GetEventClass(_pEventRef);
	
	if (EventClass == 'keyb')
	{
		UInt32 EventKind = GetEventKind(_pEventRef);
		if (EventKind == kEventRawKeyDown || EventKind == kEventRawKeyRepeat)
		{
			UInt32 KeyCode;
			UInt32 Modifiers;
			GetEventParameter(_pEventRef, kEventParamKeyModifiers, typeUInt32, NULL, sizeof(UInt32), NULL, &Modifiers);
			GetEventParameter(_pEventRef, kEventParamKeyCode, typeUInt32, NULL, sizeof(UInt32), NULL, &KeyCode);
			
			NSUInteger nsModifiers = 0;
			if (Modifiers & cmdKey)
				nsModifiers |= NSCommandKeyMask;
			if (Modifiers & controlKey)
				nsModifiers |= NSControlKeyMask;
			if (Modifiers & optionKey)
				nsModifiers |= NSAlternateKeyMask;
			if (Modifiers & shiftKey)
				nsModifiers |= NSShiftKeyMask;
			
			if (handleFieldEditorEvent(KeyCode, nsModifiers, nil))
			{
				// Don't let menu handle event
				_pRetVal->_field2 = nil;
				_pRetVal->_field1 = nil;
				_pRetVal->_field3 = 0;
				return;
			}
		}
	}
	
	return ((void(*)(struct _NSCarbonMenuSearchReturn *, id, SEL, EventRef, id))original_menuItemWithKeyEquivalentMatchingEventRef)(_pRetVal, self_, _Sel, _pEventRef, _pInMenu);
}


static bool navigateToLineInConsoleTextView(IDEConsoleTextView* _pTextView, bool _bNext, bool _bBackwards)
{
	
	NSRange selectedRange = _pTextView.selectedRange;
	NSString *text = _pTextView.string;
	NSRange lineRange = [text lineRangeForRange:selectedRange];
	NSString *line = [text substringWithRange:lineRange];
	
	NSArray *matches = [g_pSourceLocationRegex matchesInString:line
													   options:0
														 range:NSMakeRange(0, [line length])];

	if (matches.count > 0)
	{
		NSTextCheckingResult* pMatch = matches[0];
		NSUInteger nRanges = [pMatch numberOfRanges];
		if (nRanges == 4)
		{
			NSRange SourceRange = [pMatch rangeAtIndex:1];
			NSRange LineRange = [pMatch rangeAtIndex:2];
			NSString* pSource = [line substringWithRange:SourceRange];
			NSString* pLine = [line substringWithRange:LineRange];
//				NSString* pInfo = [line substringWithRange:[pMatch rangeAtIndex:3]];
			
//				XCFixinLog(@"Source: %@\n", pSource);
//				XCFixinLog(@"Line: %@\n", pLine);
			
			IDESourceCodeEditorContainerView* pView = getSourceCodeEditorView([_pTextView window]);
			if (!pView && g_pLastValidEditorTabItem)
			{
				NSTabView* pTabView = getWorkspaceTabView([_pTextView window]);
				if (pTabView)
				{
					bool bValid = false;
					for (NSTabViewItem* pItem in [pTabView tabViewItems])
					{
						if (pItem == g_pLastValidEditorTabItem)
						{
							bValid = true;
							break;
						}
					}

					if (bValid)
					{
						[g_pLastValidEditorTabView selectTabViewItem:g_pLastValidEditorTabItem];
						pView = getSourceCodeEditorView([_pTextView window]);
					}
				}
			}
			IDEWorkspaceTabController* pTabController = getWorkspaceTabController([_pTextView window]);
			
			if (pView && pTabController)
			{
				IDESourceCodeEditor* pEditor = [pView editor];
				if (pEditor)
				{
					//+[IDEEditorCoordinator _doOpenEditorOpenSpecifier:forWorkspaceTabController:editorContext:target:takeFocus:] ()
					
					NSNumber* pTimeStamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
					
					NSURL* pURL = [NSURL fileURLWithPath:pSource isDirectory: false];
					DVTTextDocumentLocation *documentLocation = 
						[
							[DVTTextDocumentLocation alloc] 
							initWithDocumentURL:pURL
							timestamp:pTimeStamp
							lineRange:NSMakeRange([pLine integerValue] - 1, 1)
						]
					;
					
					IDEWorkspaceDocument *pDocument = [pTabController workspaceDocument];
					
					if (pDocument)
					{
						NSRange NewRange;
						NewRange.location = lineRange.location + SourceRange.location;
						NewRange.length = (LineRange.location + LineRange.length) - SourceRange.location;
						if (NSEqualRanges(selectedRange, NewRange) && _bNext)
						{
							// Goto next line if this line is already selected
							goto End;
						}
						[_pTextView setSelectedRange:NewRange];
						[_pTextView scrollRangeToVisible:NewRange];
						
						IDEEditorOpenSpecifier *pSpecifier = [IDEEditorOpenSpecifier structureEditorOpenSpecifierForDocumentLocation:documentLocation
																															inWorkspace:[pDocument workspace]
																																  error:nil];
					
						[IDEEditorCoordinator _doOpenEditorOpenSpecifier:pSpecifier forWorkspaceTabController:pTabController editorContext:nil target:0 takeFocus:1];
						setEditorFocus([pView window]);
						return true;
					}
				}
			}
		}
	}
End:
	if (_bNext)
	{
		bool bWrapped = false;
		while (true)
		{
			NSRange StartRange = lineRange;
			if (_bBackwards)
			{
				if (lineRange.location > 0)
					lineRange.location = lineRange.location - 1;
			}
			else
				lineRange.location = lineRange.location + lineRange.length;
			lineRange.length = 0;
			
			lineRange = [text lineRangeForRange:lineRange];
			if (NSEqualRanges(lineRange, StartRange))
			{
				if (bWrapped)
					return false;
				bWrapped = true;
				if (_bBackwards)
				{
					lineRange.location = [text length] - 1;
					lineRange.length = 0;
				}
				else
				{
					lineRange.location = 0;
					lineRange.length = 0;
				}
				continue;
			}
			NSString *line = [text substringWithRange:lineRange];
			
			NSArray *matches = [g_pSourceLocationRegex matchesInString:line
															   options:0
																 range:NSMakeRange(0, [line length])];
			if (matches.count > 0)
			{
				NSTextCheckingResult* pMatch = matches[0];
				NSUInteger nRanges = [pMatch numberOfRanges];
				if (nRanges == 4)
				{
					lineRange.length = 0;
					[_pTextView setSelectedRange:lineRange];
					break;
				}
			}
		}
		
		return navigateToLineInConsoleTextView(_pTextView, false, false);
	}
	return false;
}


static void mouseDownInConsole(IDEConsoleTextView* self_, SEL _cmd, NSEvent* _pEvent)
{
	if ([_pEvent clickCount] >= 2)
	{
		if (navigateToLineInConsoleTextView(self_, false, false))
			return;
	}
	return ((void (*)(id, SEL, id))original_mouseDownInConsole)(self_, _cmd, _pEvent);
}

static void doCommandBySelector( id self_, SEL _cmd, SEL selector )
{
	DVTSourceTextView *self = (DVTSourceTextView *)self_;
//	updateLastValidEditorTab([self window]);
	bool bHandled = false;
	do {
		//- (BOOL)shouldIndentPastedText:(id)arg1;
		
//		XCFixinLog(@"Selector: %@\n", NSStringFromSelector(selector));
		
		if (selector == @selector(insertTab:))
		{
			NSRange selectedRange = self.selectedRange;
			if (stringRangeContainsCharacters(self.string, selectedRange, [NSCharacterSet newlineCharacterSet]))
			{
				[self shiftRight:nil];
				bHandled = true;
			}
		}
		if (selector == @selector(insertBacktab:))
		{
			NSRange selectedRange = self.selectedRange;
			if (stringRangeContainsCharacters(self.string, selectedRange, [NSCharacterSet newlineCharacterSet]))
			{
				[self shiftLeft:nil];
				bHandled = true;
			}
		}

		if (selector == @selector(moveWordRight:) || selector == @selector(moveWordRightAndModifySelection:)
			|| selector == @selector(moveWordLeft:) || selector == @selector(moveWordLeftAndModifySelection:))
		{
			bool bSelectionModified = selector == @selector(moveWordRightAndModifySelection:) || selector == @selector(moveWordLeftAndModifySelection:);
			bool bLeft = selector == @selector(moveWordLeft:) || selector == @selector(moveWordLeftAndModifySelection:);

			NSString *text = self.string;

			NSRange selectedRange = self.selectedRange;
			int originalLocation = clearSelection(self);
			NSUInteger position = self.selectedRange.location;
			NSUInteger originalPosition = position;
			NSUInteger length = [text length];
			
			NSCharacterSet *pNewLine = [NSCharacterSet newlineCharacterSet];
			NSCharacterSet *pWhiteSpace = [NSCharacterSet whitespaceCharacterSet];
			
			NSCharacterSet *pAlphaNumericSpace = [NSCharacterSet alphanumericCharacterSet];
			NSMutableCharacterSet *pCodeCharSet = [[NSMutableCharacterSet alloc] init];
			[pCodeCharSet formUnionWithCharacterSet:pAlphaNumericSpace];
			[pCodeCharSet addCharactersInString:@"_"];
			
			// Add commas and other

			if (bLeft)
			{
				if (position > 0)
					--position;

				unichar StartChar = [text characterAtIndex:position];
				
				if ([pNewLine characterIsMember:StartChar])
				{
					if (position > 0)
					{
						if (StartChar == '\n')
						{
							--position;
							StartChar = [text characterAtIndex:position];
							if (StartChar == '\r')
							{
								--position;
								StartChar = [text characterAtIndex:position];
							}
						}
						else if (StartChar == '\r')
						{
							--position;
							StartChar = [text characterAtIndex:position];
						}
					}
				}
				// Move over any white space
				while (position > 0)
				{
					StartChar = [text characterAtIndex:position];
					
					if (![pWhiteSpace characterIsMember:StartChar])
						break;
					--position;
				}

				if ([pNewLine characterIsMember:StartChar])
				{
					if (position < length)
						++position;
				}
				else
				{
					// Move to beginning of word
					if ([pCodeCharSet characterIsMember:StartChar])
					{
						while (position > 0)
						{
							StartChar = [text characterAtIndex:position];
							
							if (![pCodeCharSet characterIsMember:StartChar])
							{
								if (position < length)
									++position;
								break;
							}
							--position;
						}
					}
				}
			}
			else
			{
				// Move to end of word
				if (position < length)
				{
					unichar StartChar = [text characterAtIndex:position];
					if ([pCodeCharSet characterIsMember:StartChar])
					{
						while (position < length)
						{
							unichar StartChar = [text characterAtIndex:position];
							
							if (![pCodeCharSet characterIsMember:StartChar])
								break;
							++position;
						}
					}
					else if (![pWhiteSpace characterIsMember:StartChar])
					{
						if (position < length)
							++position;
					}
					
					// Move over any white space
					while (position < length)
					{
						unichar StartChar = [text characterAtIndex:position];
						
						if (![pWhiteSpace characterIsMember:StartChar])
							break;
						++position;
					}
				}
			}
			
			NSUInteger selectedStart = selectedRange.location;
			NSUInteger selectedEnd = selectedRange.location + selectedRange.length;
			NSRange newRange = selectedRange;
			if (bSelectionModified)
			{
				if (bLeft)
				{
					if (originalPosition == selectedRange.location)
					{
						// Move selection start
						if (position < selectedEnd)
							newRange = NSMakeRange(position, selectedEnd - position);
					}
					else
					{
						// Move selection end
						if (position > selectedStart)
							newRange = NSMakeRange(selectedStart, position - selectedStart);
						else
							newRange = NSMakeRange(position, selectedStart - position);
					}
				}
				else
				{
					if (originalPosition == selectedRange.location)
					{
						// Move selection start
						if (position > selectedEnd)
							newRange = NSMakeRange(selectedEnd, position - selectedEnd);
						else
							newRange = NSMakeRange(position, selectedEnd - position);
					}
					else
					{
						// Move selection end
						if (position > selectedEnd)
							newRange = NSMakeRange(selectedStart, position - selectedStart);
					}
				}
			}
			else
				newRange = NSMakeRange(position, 0);
			
			moveRange(self_, newRange, selectedRange, originalLocation);
			
			bHandled = true;
		}
		if (!bHandled)
		{
			bool bSelectionModified = selector == @selector(moveToBeginningOfLineAndModifySelection:) ||
				selector == @selector(moveToLeftEndOfLineAndModifySelection:);
			
			if (selector == @selector(moveToBeginningOfLine:) ||
				selector == @selector(moveToLeftEndOfLine:) || bSelectionModified)
			{
				NSString *text = self.string;
				NSRange originalSelectedRange = self.selectedRange;

				int originalLocation = clearSelection(self);
				
				NSRange selectedRange = self.selectedRange;
				
				NSRange lineRange = [text lineRangeForRange:selectedRange];
				
				if (lineRange.length == 0)
					break;
				
				NSString *line = [text substringWithRange:lineRange];
				NSRange codeStartRange = [line rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
				
				if (codeStartRange.location == NSNotFound)
					break;
				
				int start;
				
				if (selectedRange.location == lineRange.location || selectedRange.location > lineRange.location + codeStartRange.location)
					start = lineRange.location + codeStartRange.location;
				else
					start = lineRange.location;
				
				int end;
				if (bSelectionModified)
				{
					if (originalSelectedRange.location == selectedRange.location)
					{
						// We are changing the beginning of the selected range
						end = originalSelectedRange.location + originalSelectedRange.length;
					}
					else
					{
						// We are changing the end of the selected range
						end = start;
						start = originalSelectedRange.location;
					}
				}
				else
					end = start;
			
				if (start > end)
				{
					int temp = end;
					end = start;
					start = temp;
				}
				moveRange(self_, NSMakeRange(start, end - start), originalSelectedRange, originalLocation);
				
				bHandled = true;
			}
		}
	} while (0);

	if (!bHandled)
		((void (*)(id, SEL, SEL))original_doCommandBySelector)(self_, _cmd, selector);
	
	// NSRange currentRange = [self selectedRange];
	// XCFixinLog(@"Affinity: %u Location: %u Length: %u\n", (unsigned int)[self selectionAffinity], (unsigned int)currentRange.location , (unsigned int)currentRange.length);
	
	return;
}

static id singleton = nil;

NSRegularExpression *g_pSourceLocationRegex;


+ (void) pluginDidLoad:(NSBundle *)plugin
{
	if (singleton)
		return;
	XCFixinPreflight();

	singleton = [[XCFixin_EmulateVisualStudio alloc] init];

	if (!singleton)
	{
		XCFixinLog(@"%s: Emulate visual studio init failed.\n",__FUNCTION__);
	}
	
	NSError *error = NULL;
	g_pSourceLocationRegex = [NSRegularExpression regularExpressionWithPattern:@"(.*):([0-9]*):(.*)"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:&error];
	
	original_doCommandBySelector = XCFixinOverrideMethodString(@"DVTSourceTextView", @selector(doCommandBySelector:), (IMP)&doCommandBySelector);
	XCFixinAssertOrPerform(original_doCommandBySelector, goto failed);

	original_shouldIndentPastedText = XCFixinOverrideMethodString(@"DVTSourceTextView", @selector(shouldIndentPastedText:), (IMP)&shouldIndentPastedText);
	XCFixinAssertOrPerform(original_shouldIndentPastedText, goto failed);
	
	original_didSelectTabViewItem = XCFixinOverrideMethodString(@"DVTTabSwitcher", @selector(tabView:didSelectTabViewItem:), (IMP)&didSelectTabViewItem);
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
	XCFixinAssertOrPerform(original_menuItemWithKeyEquivalentMatchingEventRef, goto failed);

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
	
	
	XCFixinPostflight();
}
@end
