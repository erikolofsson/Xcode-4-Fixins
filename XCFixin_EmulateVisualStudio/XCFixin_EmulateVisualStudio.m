#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#include "../Shared Code/XCFixin.h"
#import "../Shared Code/Xcode5/DVTKit/DVTSourceTextView.h"
#import "../Shared Code/Xcode5/IDEKit/IDENavigatorOutlineView.h"
#import "../Shared Code/Xcode5/IDEKit/IDEBatchFindResultsOutlineController.h"
#import "../Shared Code/Xcode5/IDEKit/IDEIssueNavigator.h"
#import "../Shared Code/Xcode5/IDEKit/IDEIssueNavigableItem.h"

static IMP original_doCommandBySelector = nil;
static IMP original_shouldIndentPastedText = nil;
static IMP original_didSelectTabViewItem = nil;




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

//-----------------------------------------------------------------------------------------------
- (id) init {
//-----------------------------------------------------------------------------------------------
  self = [super init];
  if (self) {

    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver: self
                           selector: @selector( frameChanged: )
                               name: NSViewFrameDidChangeNotification
                             object: nil];
	  
    [notificationCenter addObserver: self
                           selector: @selector( windowDidBecomeKey: )
                               name: NSWindowDidBecomeKeyNotification
                             object: nil];
	  
 
	eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent *(NSEvent *event) 
	{
		unsigned short keyCode = [event keyCode];
		//XCFixinLog(@"%d %@ %@\n", keyCode, [event characters], [event charactersIgnoringModifiers]);
		NSUInteger ModifierFlags = [event modifierFlags];
		if ((keyCode == 45) && (ModifierFlags & (NSCommandKeyMask | NSControlKeyMask | NSAlternateKeyMask)) == NSCommandKeyMask) 
		{
			if (m_pActiveView && [m_pActiveView isValid])
			{
				if (m_pActiveViewControllerBatchFind)
				{
					if (ModifierFlags & NSShiftKeyMask)
						[m_pActiveView doCommandBySelector:@selector(moveUp:)];
					else
						[m_pActiveView doCommandBySelector:@selector(moveDown:)];
				
					[m_pActiveViewControllerBatchFind openSelectedNavigableItemsKeyAction:m_pActiveView];
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
					NSWindow* keyWindow = [NSApp keyWindow];
					NSEvent* pEvent = [
						NSEvent keyEventWithType:NSKeyDown 
						location:[keyWindow mouseLocationOutsideOfEventStream] 
						modifierFlags:0xa00100
						timestamp:0.0
						windowNumber:[keyWindow windowNumber]
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
						[m_pActiveViewControllerIssues openSelectedNavigableItemsKeyAction:m_pActiveView];
				  }
			  }
			  return nil;
		  }
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

IDENavigatorOutlineView* m_pActiveView = nil;
IDEBatchFindResultsOutlineController* m_pActiveViewControllerBatchFind = nil;
IDEIssueNavigator* m_pActiveViewControllerIssues = nil;

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	NSWindow *window = [notification object];
	
	//NSString* pDesc = [[window contentView] _subtreeDescription];
	//XCFixinLog(@"%@\n", pDesc);
	potentialView((IDENavigatorOutlineView*)findSubViewWithClassName([window contentView], "IDENavigatorOutlineView"));
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
static BOOL didSelectTabViewItem( NSView *self_, SEL _cmd, NSTabView *tabView, NSTabViewItem *_pItem)
{
	potentialView((IDENavigatorOutlineView*)findSubViewWithClassName([_pItem view], "IDENavigatorOutlineView"));
	return ((BOOL (*)(id, SEL, id, id))original_didSelectTabViewItem)(self_, _cmd, tabView, _pItem);
}


static void doCommandBySelector( id self_, SEL _cmd, SEL selector )
{
	DVTSourceTextView *self = (DVTSourceTextView *)self_;
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

+ (void) pluginDidLoad:(NSBundle *)plugin
{
	XCFixinPreflight();

	singleton = [[XCFixin_EmulateVisualStudio alloc] init];

	if (!singleton)
	{
		XCFixinLog(@"%s: Emulate visual studio init failed.\n",__FUNCTION__);
	}
	
	original_doCommandBySelector = XCFixinOverrideMethodString(@"DVTSourceTextView", @selector(doCommandBySelector:), (IMP)&doCommandBySelector);
	XCFixinAssertOrPerform(original_doCommandBySelector, goto failed);

	original_shouldIndentPastedText = XCFixinOverrideMethodString(@"DVTSourceTextView", @selector(shouldIndentPastedText:), (IMP)&shouldIndentPastedText);
	XCFixinAssertOrPerform(original_shouldIndentPastedText, goto failed);
	
	original_didSelectTabViewItem = XCFixinOverrideMethodString(@"DVTTabSwitcher", @selector(tabView:didSelectTabViewItem:), (IMP)&didSelectTabViewItem);
	XCFixinAssertOrPerform(original_didSelectTabViewItem, goto failed);
	
	XCFixinPostflight();
}
@end
