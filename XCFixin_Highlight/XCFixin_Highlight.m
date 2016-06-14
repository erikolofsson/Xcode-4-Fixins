#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#include "../Shared Code/XCFixin.h"
#import "../Shared Code/Xcode/DVTSourceTextView.h"
#import "../Shared Code/Xcode/DVTTextStorage.h"
#import "../Shared Code/Xcode/DVTFontAndColorTheme.h"
#import "../Shared Code/Xcode/DVTSourceNodeTypes.h"
#import "../Shared Code/Xcode/DVTSourceModelItem.h"
#import "../Shared Code/Xcode/DVTSourceCodeLanguage.h"
#import "../Shared Code/Xcode/DVTLanguageSpecification.h"
#import "../Shared Code/Xcode/IDESourceCodeEditor.h"
#import "../Shared Code/Xcode/IDEIndex.h"
#import "../Shared Code/Xcode/DVTLayoutManager.h"


@interface XCFixin_Highlight_ViewState : NSObject
{
	NSMutableIndexSet* _m_pIndexSet;
	NSRange _m_CachedVisibleRange;
	bool _m_CacheValid;
}
@property NSMutableIndexSet* m_pIndexSet;
@property NSRange m_CachedVisibleRange;
@property bool m_CachedValid;
- (NSMutableIndexSet*)getIndexSet;
@end

@implementation XCFixin_Highlight_ViewState
- (id) init
{
  self = [super init];
  if (self)
  {
	  _m_CacheValid = false;
	  _m_pIndexSet = NULL;
  }
  return self;
}
- (NSMutableIndexSet*)getIndexSet
{
	if (_m_pIndexSet)
		return _m_pIndexSet;
	
	_m_pIndexSet = [[NSMutableIndexSet alloc] init];
	return _m_pIndexSet;
}
@end

static IMP original_colorAtCharacterIndex = nil;
static IMP original_IDESourceCodeEditor_doInitialSetup = nil;

@interface XCFixin_Highlight : NSObject
@end

@implementation XCFixin_Highlight

#include <objc/runtime.h>

static XCFixin_Highlight_ViewState* GetViewState(NSLayoutManager* _pLayoutManager)
{
	char const* pKey = "XCFixinHighlightViewState";
	id pViewState = objc_getAssociatedObject(_pLayoutManager, pKey);
	if (pViewState)
		return pViewState;
	XCFixin_Highlight_ViewState *pNewViewState = [[XCFixin_Highlight_ViewState alloc] init];
	objc_setAssociatedObject(_pLayoutManager, pKey, pNewViewState, OBJC_ASSOCIATION_RETAIN);
	return pNewViewState;
}

static NSString* pAttributeName = @"XCFixinTempAttribute00";

- (id) init {
  self = [super init];
  if (self) {

    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver: self
                           selector: @selector( frameChanged: )
                               name: NSViewFrameDidChangeNotification
                             object: nil];

    [notificationCenter addObserver: self
                           selector: @selector( boundsChanged: )
                               name: NSViewBoundsDidChangeNotification
                             object: nil];
	  
    [notificationCenter addObserver: self
                           selector: @selector( textStorageWillProcessEditing: )
                               name: NSTextStorageWillProcessEditingNotification
                             object: nil];
	  
	  
  }
  return self;
}

- (void)textStorageWillProcessEditing:(NSNotification *)notification
{
	if ([notification.object isKindOfClass:[DVTTextStorage class]])
	{
		DVTTextStorage* pStorage = (DVTTextStorage*)notification.object;
		NSArray* pLayoutManagers = [pStorage layoutManagers];
		if ([pLayoutManagers count] < 1)
			return;
		NSLayoutManager* pLayoutManager = (NSLayoutManager *)pLayoutManagers[0];
		XCFixin_Highlight_ViewState* pViewState = GetViewState(pLayoutManager);
		pViewState.m_CachedValid = false;
	}
}


- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//static DVTTextStorage *textStorage;
//static NSTextView *textView;

static void parseAwayWhitespace(NSString *_pString, NSUInteger _Length, NSRange *_pRange)
{
	// Parse away white space
	NSUInteger iChar = _pRange->location + _pRange->length;
	while (iChar < _Length)
	{
		unichar Character = [_pString characterAtIndex: iChar];
		if (![pWhitespaceNoNewLineChars characterIsMember:Character])
			break;
		++iChar;
	}

	if (iChar < _Length)
	{
		unichar Character = [_pString characterAtIndex: iChar];
		if ([pNewLineChars characterIsMember:Character])
		{
			// Parse away new line
			if (Character == '\r')
			{
				++iChar;
				if (iChar < _Length)
					Character = [_pString characterAtIndex: iChar];
			}
			if (Character == '\n')
				++iChar;
			_pRange->length = iChar - _pRange->location;
		}
	}
	else
		_pRange->length = iChar - _pRange->location;
}

static void updateTextView(DVTSourceTextView *_pTextView, XCFixin_Highlight_ViewState* _pViewState)
{
	DVTTextStorage* textStorage = [_pTextView textStorage];
	DVTSourceCodeLanguage* pLanguage = [textStorage language];
	IDESourceCodeEditor* pSourceCodeEditor = (IDESourceCodeEditor*)[_pTextView delegate];
	NSLayoutManager* pLayoutManager = [_pTextView layoutManager];
	if (pLanguage && pSourceCodeEditor && pLayoutManager)
	{
		NSRange Bounds;
		if (!_pViewState)
		{
			Bounds = [_pTextView visibleCharacterRange];
			_pViewState = GetViewState(pLayoutManager);
			_pViewState.m_CachedValid = true;
			_pViewState.m_CachedVisibleRange = Bounds;
		}
		else
		{
			if (!_pViewState.m_CachedValid)
			{
				Bounds = [_pTextView visibleCharacterRange];
				_pViewState.m_CachedValid = true;
				_pViewState.m_CachedVisibleRange = Bounds;
			}
			else
				Bounds = _pViewState.m_CachedVisibleRange;
		}

		NSString* pIdentifier = [pLanguage identifier];
		
		BOOL bSupportedLanguage = false;

		if ([pIdentifier hasPrefix:@"Xcode.SourceCodeLanguage."])
			bSupportedLanguage = true;
		
		if (!bSupportedLanguage)
			return;

		NSMutableIndexSet* pIndexSet = [_pViewState getIndexSet];
		
		NSMutableIndexSet* pNewIndexSet = [[NSMutableIndexSet alloc] init];
		
		unsigned long long iCharacter = Bounds.location;
		unsigned long long iCharacterEnd = Bounds.location + Bounds.length;
		
		while (iCharacter < iCharacterEnd)
		{
			NSRange EffectiveRange;
			long long NodeType = [textStorage nodeTypeAtCharacterIndex:iCharacter effectiveRange:&EffectiveRange context:nil];
			
			if (NodeType == NodeType_CommentDoc || NodeType == NodeType_CommentDocKeyword || NodeType == NodeType_Comment || NodeType == NodeType_URL)
				[pNewIndexSet addIndexesInRange:NSIntersectionRange(EffectiveRange, Bounds)];
			
			if (EffectiveRange.length == 0)
				++iCharacter;
			else
				iCharacter = EffectiveRange.location + EffectiveRange.length;
		}

		if (
				[pIndexSet countOfIndexesInRange:Bounds] != [pNewIndexSet countOfIndexesInRange:Bounds]
				|| ![pIndexSet containsIndexes:pNewIndexSet]
			)
		{
			[pIndexSet removeIndexesInRange:Bounds];
			[pIndexSet addIndexes:pNewIndexSet];
			[pLayoutManager removeTemporaryAttribute: pAttributeName forCharacterRange: Bounds];
			
			[
				pNewIndexSet enumerateRangesInRange:Bounds options:0 usingBlock:^(NSRange _Range, BOOL *_pbStop) 
				{
					[pLayoutManager addTemporaryAttribute: pAttributeName value: pCommentBackground forCharacterRange: _Range];
				}
			];
			XCFixinUpdateTempAttributes(pLayoutManager, Bounds);
		}
	}
}

- (void) frameChanged:(NSNotification*)notification {
	if ([notification.object isKindOfClass:[NSClipView class]])
	{
		NSClipView *pClipView = (NSClipView *)notification.object;
		DVTSourceTextView *pTextView = (DVTSourceTextView *)[pClipView documentView];
		if ([pTextView isKindOfClass: [DVTSourceTextView class]])
		{
			updateTextView(pTextView, NULL);
		}
	}
}

- (void) boundsChanged:(NSNotification*)notification {
	
	if ([notification.object isKindOfClass:[NSClipView class]])
	{
		NSClipView *pClipView = (NSClipView *)notification.object;
		DVTSourceTextView *pTextView = (DVTSourceTextView *)[pClipView documentView];
		if ([pTextView isKindOfClass: [DVTSourceTextView class]])
		{
			updateTextView(pTextView, NULL);
		}
	}
}

static id highlighter = nil;

static BOOL MatchVariablePrefix(NSString* _pIdentifier, NSString* _pToMatch, size_t _MatchLength, size_t _IdentLength)
{
	if (![_pIdentifier hasPrefix:_pToMatch])
		return false;
	
	NSUInteger MatchLength = _MatchLength;
	NSUInteger IdentLength = _IdentLength;
	if (IdentLength <= MatchLength)
		return false;
	
	unichar Character = [_pIdentifier characterAtIndex:MatchLength];
	
	if ([pUpperCaseChars characterIsMember:Character])
		return true;
	
	if (![pValidConceptCharacters characterIsMember:Character])
		return false;

	if (IdentLength <= MatchLength + 1)
		return false;

	Character = [_pIdentifier characterAtIndex:MatchLength + 1];
	
	if ([pUpperCaseChars characterIsMember:Character])
		return true;
	
	return false;
}

static BOOL MatchOtherPrefix(NSString* _pIdentifier, NSString* _pToMatch, size_t _MatchLength, size_t _IdentLength)
{
	if (_IdentLength <= _MatchLength)
		return false;
	if ([_pIdentifier hasPrefix:_pToMatch] && [pUpperCaseChars characterIsMember:[_pIdentifier characterAtIndex:[_pToMatch length]]])
		return true;
	return false;
}

static NSColor* FixupCommentBackground2(DVTSourceTextView* _pTextView, NSColor* _pColor, NSRange _Range, bool _bComment, XCFixin_Highlight_ViewState* _pViewState)
{
	if (_Range.length == 0)
		return _pColor;
	bool bChanged = false;
	NSColor* pReturn = FixupCommentBackground([_pTextView layoutManager], _pColor, _Range, _bComment, &bChanged, _pViewState);
	
	if (bChanged)
		updateTextView(_pTextView, _pViewState);
	
	return pReturn;
}
static bool MakeSureOfAttributes(NSLayoutManager* _pLayoutManager, NSRange _Range)
{
	NSUInteger iLocation = _Range.location;
	NSUInteger iEndLocation = _Range.location + _Range.length;
  
	Class nsStringClass = [NSString class];
	
	NSRange ChangedRange;
	ChangedRange.location = 0;
	ChangedRange.length = 0;

	bool bChanged = false;
	while (iLocation < iEndLocation)
	{
		NSRange EffectiveRange;
		NSRange ThisRange;
		ThisRange.location = iLocation;
		ThisRange.length = iEndLocation - iLocation;
		NSDictionary *pCurrentAttributes = [_pLayoutManager temporaryAttributesAtCharacterIndex:iLocation longestEffectiveRange:&EffectiveRange inRange:ThisRange];
		NSEnumerator *keyEnumerator = [pCurrentAttributes keyEnumerator];
		bool bFound = false;
		for (id key = [keyEnumerator nextObject]; key != nil; key = [keyEnumerator nextObject])
		{
			if ([key isKindOfClass: nsStringClass] && [((NSString *)key) compare:pAttributeName] == NSOrderedSame)
			{
				bFound = true;
				break;
			}
		}
		
		if (!bFound)
		{
			if (ChangedRange.length == 0)
				ChangedRange = EffectiveRange;
			else
				ChangedRange = NSUnionRange(ChangedRange, EffectiveRange);
			//XCFixinLog(@"AddForRange: %@\n", [[[_pLayoutManager textStorage] string] substringWithRange:EffectiveRange]);
			[_pLayoutManager addTemporaryAttribute:pAttributeName value:pCommentBackground forCharacterRange:EffectiveRange];
			bChanged = true;
		}
		
		iLocation = EffectiveRange.location + EffectiveRange.length;
	}
	
	if (bChanged)
	{
		//XCFixinLog(@"Changed: %@\n", [[[_pLayoutManager textStorage] string] substringWithRange:ChangedRange]);
		XCFixinUpdateTempAttributes(_pLayoutManager, ChangedRange);
	}
	return bChanged;
}

static NSColor* FixupCommentBackground(NSLayoutManager* _pLayoutManager, NSColor* _pColor, NSRange _Range, bool _bComment, bool *_pChanged, XCFixin_Highlight_ViewState* _pViewState)
{
	NSMutableIndexSet* pIndexSet = [_pViewState getIndexSet];
	if (_bComment)
	{
		if (![pIndexSet containsIndexesInRange:_Range])
		{
			[pIndexSet addIndexesInRange:_Range];
			[_pLayoutManager addTemporaryAttribute: pAttributeName value: pCommentBackground forCharacterRange: _Range];
			XCFixinUpdateTempAttributes(_pLayoutManager, _Range);
			*_pChanged = true;
		}
		else
		{
			MakeSureOfAttributes(_pLayoutManager, _Range);
		}
	}
	else
	{
		if ([pIndexSet intersectsIndexesInRange:_Range])
		{
			[pIndexSet removeIndexesInRange:_Range];
			[_pLayoutManager removeTemporaryAttribute: pAttributeName forCharacterRange: _Range];
			XCFixinUpdateTempAttributes(_pLayoutManager, _Range);
			*_pChanged = true;
		}
	}
	
	return _pColor;
}

static short NodeType_Comment = -1;
static short NodeType_CommentDoc = -1;
static short NodeType_CommentDocKeyword = -1;
static short NodeType_URL = -1;
static short NodeType_String = -1;
static short NodeType_Character = -1;
static short NodeType_Number = -1;
static short NodeType_Keyword = -1;
static short NodeType_Preprocessor = -1;

static short NodeType_Identifier = -1;
static short NodeType_IdentifierPlain = -1;

static short NodeType_IdentifierMacro = -1;
static short NodeType_IdentifierMacroSystem = -1;
	
static short NodeType_IdentifierConstant = -1;
static short NodeType_IdentifierConstantSystem = -1;
	
static short NodeType_IdentifierClass = -1;
static short NodeType_IdentifierClassSystem = -1;
	
static short NodeType_IdentifierType = -1;
static short NodeType_IdentifierTypeSystem = -1;
	
static short NodeType_IdentifierFunction = -1;
static short NodeType_IdentifierFunctionSystem = -1;
	
static short NodeType_IdentifierVariable = -1;
static short NodeType_IdentifierVariableSystem = -1;

static NSMutableDictionary *pNodeTypeDict = NULL;
static NSMutableDictionary *pLanguageDict = NULL;


static NSColor* fs_GetColor(DVTTextStorage* _pTextStorage, short _NodeType, bool _bJS)
{
	
	if (_NodeType == NodeType_Comment)
		return pCommentForeground;
	else if (_NodeType == NodeType_CommentDoc)
		return pDocumentationCommentForeground;
	else if (_NodeType == NodeType_CommentDocKeyword)
		return pDocumentationCommentForegroundKeyword;
	else if (_NodeType == NodeType_URL)
		return pCommentURL;
	else if (_NodeType == NodeType_String)
		return pString;
	else if (_NodeType == NodeType_Character)
	{
		if (_bJS)
			return pString;
		else
			return pCharacter;
	}
	else if (_NodeType == NodeType_Number)
		return pNumber;
	else if (_NodeType == NodeType_Keyword)
		return pKeywordDefault;
	else if (_NodeType == NodeType_Preprocessor)
		return pMacro;
	else if (_NodeType == NodeType_Identifier)
		return pPlainText;
	else if (_NodeType == NodeType_IdentifierPlain)
		return pPlainText;
	else if (_NodeType == NodeType_IdentifierMacro)
		return pMacro;
	else if (_NodeType == NodeType_IdentifierMacroSystem)
		return pMacro;
	else if (_NodeType == NodeType_IdentifierConstant)
		return pGlobalConstant;
	else if (_NodeType == NodeType_IdentifierConstantSystem)
		return pGlobalConstant;
	else if (_NodeType == NodeType_IdentifierClass)
		return pType;
	else if (_NodeType == NodeType_IdentifierClassSystem)
		return pType;
	else if (_NodeType == NodeType_IdentifierType)
		return pType;
	else if (_NodeType == NodeType_IdentifierTypeSystem)
		return pType;
	else if (_NodeType == NodeType_IdentifierFunction)
		return pFunction;
	else if (_NodeType == NodeType_IdentifierFunctionSystem)
		return pFunction;
	else if (_NodeType == NodeType_IdentifierVariable)
		return pPlainText;
	else if (_NodeType == NodeType_IdentifierVariableSystem)
		return pPlainText;
	
	return [[_pTextStorage fontAndColorTheme] colorForNodeType:_NodeType];
}


static void IDESourceCodeEditor_doInitialSetup(IDESourceCodeEditor *self_, SEL _cmd)
{
	((void (*)(id, SEL))original_IDESourceCodeEditor_doInitialSetup)(self_, _cmd);

	DVTSourceTextView *pTextView = [self_ textView];
	if (pTextView)
	{
		updateTextView(pTextView, NULL);
	}

}
static NSColor* colorAtCharacterIndex(id self_, SEL _cmd, unsigned long long _Index, struct _NSRange *_pEffectiveRange, NSDictionary* _pContext)
{
	DVTTextStorage* textStorage = self_;
	DVTSourceCodeLanguage* pLanguage = [textStorage language];
	
	bool bJS = false;
	long long NodeType = [textStorage nodeTypeAtCharacterIndex:_Index effectiveRange:_pEffectiveRange context:_pContext];
//	NSColor* OriginalRet = ((NSColor* (*)(id, SEL, unsigned long long, struct _NSRange *, id))original_colorAtCharacterIndex)(self_, _cmd, _Index, _pEffectiveRange, _pContext);
	
	if (pLanguage)
	{
		if (NodeType == NodeType_Identifier)
			NodeType = NodeType_IdentifierPlain; // Mimic the behaviour in Xcode implementation of colorAtCharacterIndex

		/*
		if (!pNodeTypeDict)
			pNodeTypeDict = [NSMutableDictionary dictionary];
		
		NSNumber *pToFind = @(NodeType);
		
		NSString *pNode = [pNodeTypeDict objectForKey:pToFind];
		if (!pNode)
		{
			[pNodeTypeDict setObject:[DVTSourceNodeTypes nodeTypeNameForId:NodeType] forKey:pToFind];
			XCFixinLog(@"NodeType: %@\n", [DVTSourceNodeTypes nodeTypeNameForId:NodeType]);
		}*/
		//double Time = CFAbsoluteTimeGetCurrent();
		
		NSString* pIdentifier = [pLanguage identifier];
/*
		{
			if (!pLanguageDict)
				pLanguageDict = [NSMutableDictionary dictionary];
			NSString *pNode = [pLanguageDict objectForKey:pIdentifier];
			if (!pNode)
			{
				[pLanguageDict setObject:@"" forKey:pIdentifier];
				XCFixinLog(@"Language: %@\n", pIdentifier);
			}
		}
*/		
		BOOL bSupportedLanguage = false;

		if ([pIdentifier hasPrefix:@"Xcode.SourceCodeLanguage."])
			bSupportedLanguage = true;
		
		NSMutableDictionary *pExtraDefaultKeywords = nil;
		NSMutableDictionary *pExtraDefaultKeywords2 = nil;
		NSMutableDictionary *pExtraDefaultKeywords3 = nil;
		bool bIsCpp = false;

		if ([pIdentifier hasPrefix:@"Xcode.SourceCodeLanguage.C-Plus-Plus"] || [pIdentifier hasPrefix:@"Xcode.SourceCodeLanguage.Objective-C-Plus-Plus"])
		{
			bIsCpp = true;
			pExtraDefaultKeywords = pDefaultKeywords_Cpp;
			pExtraDefaultKeywords2 = pDefaultKeywords_C;
			pExtraDefaultKeywords3 = pDefaultKeywords_CLike;
		}
		else if ([pIdentifier compare:@"Xcode.SourceCodeLanguage.C"] == NSOrderedSame || [pIdentifier compare:@"Xcode.SourceCodeLanguage.Objective-C"] == NSOrderedSame)
		{
			pExtraDefaultKeywords = pDefaultKeywords_C;
			pExtraDefaultKeywords2 = pDefaultKeywords_CLike;
		}
		else if ([pIdentifier hasPrefix:@"Xcode.SourceCodeLanguage.JavaScript"])
		{
			pExtraDefaultKeywords = pDefaultKeywords_JS;
			pExtraDefaultKeywords2 = pDefaultKeywords_CLike;
			bJS = true;
		}
		else if ([pIdentifier hasPrefix:@"Xcode.SourceCodeLanguage.CSS"])
			pExtraDefaultKeywords = pDefaultKeywords_CSS;

		
//		if ([pIdentifier hasPrefix:@"Xcode.SourceCodeLanguage. "])
//			bSupportedLanguage = true;

		if (!bSupportedLanguage)
		{
//			XCFixinLog(@"Language not supported: %@\n", pIdentifier);
			return fs_GetColor(textStorage, NodeType, bJS);
		}

		NSArray* pViews = [textStorage _associatedTextViews];
		DVTSourceTextView* pTextView = nil;
		if (pViews && [pViews count] > 0)
		{
			pTextView = [pViews lastObject];
		}
		
		if (!pTextView)
		{
			return fs_GetColor(textStorage, NodeType, bJS);
		}
		
		NSLayoutManager* pLayoutManager = [pTextView layoutManager];
		XCFixin_Highlight_ViewState* pViewState = GetViewState(pLayoutManager);
		if (!pViewState.m_CachedValid)
		{
			pViewState.m_CachedVisibleRange = [pTextView visibleCharacterRange];
			pViewState.m_CachedValid = true;
		}
		NSRange Bounds = pViewState.m_CachedVisibleRange;

 		NSString *pString = [textStorage string];
		NSUInteger Length = [pString length];
		
		
//		XCFixinLog(@"%lld(%@): %@\n", NodeType, [DVTSourceNodeTypes nodeTypeNameForId:NodeType], [pString substringWithRange:*_pEffectiveRange]);
		if (NodeType == NodeType_Comment || NodeType == NodeType_CommentDoc || NodeType == NodeType_CommentDocKeyword || NodeType == NodeType_URL)
		{
			//parseAwayWhitespace(pString, Length, _pEffectiveRange);
			return FixupCommentBackground2(pTextView, fs_GetColor(textStorage, NodeType, bJS), NSIntersectionRange(*_pEffectiveRange, Bounds), true, pViewState);
		}
		if (NodeType == NodeType_Number)
		{
			NSUInteger iChar = _pEffectiveRange->location + _pEffectiveRange->length;
			while (iChar < Length)
			{
				unichar Character = [pString characterAtIndex: iChar];
				if (![pIdentifierCharacterSet characterIsMember:Character])
					break;
				++iChar;
			}
			_pEffectiveRange->length = iChar - _pEffectiveRange->location;
			return FixupCommentBackground2(pTextView, fs_GetColor(textStorage, NodeType, bJS), NSIntersectionRange(*_pEffectiveRange, Bounds), false, pViewState);
		}
		if (NodeType == NodeType_String || NodeType == NodeType_Character)
		{
			// Don't color strings, numbers and characters
			return FixupCommentBackground2(pTextView, fs_GetColor(textStorage, NodeType, bJS), NSIntersectionRange(*_pEffectiveRange, Bounds), false, pViewState);
		}
		
		NSUInteger iChar = _Index;
		unichar Character = [pString characterAtIndex: iChar];
		
		//if (_pEffectiveRange->location > 0 && _pEffectiveRange->location < iChar)
		{
			if ([pIdentifierCharacterSet characterIsMember:Character])
			{
				// Walk backwords finding start of identifier
				//while (iChar > _pEffectiveRange->location)
				while (iChar > 0)
				{
					--iChar;
					Character = [pString characterAtIndex: iChar];
					if (![pIdentifierCharacterSet characterIsMember:Character])
					{
						++iChar;
						Character = [pString characterAtIndex: iChar];
						break;
					}
				}
			}
		}

		if (iChar < Length)
		{
		
			if ([pWhitespaceChars characterIsMember:Character])
			{
				// Keep white space separate
				NSUInteger iStart = iChar;
				++iChar;
				while (iChar < Length)
				{
					Character = [pString characterAtIndex: iChar];
					if (![pWhitespaceChars characterIsMember:Character])
						break;
					++iChar;
				}
				NSRange Range;
				Range.location = iStart;
				Range.length = iChar - iStart;
				*_pEffectiveRange = Range;

				NSRange SafeRange = *_pEffectiveRange;
				if (NodeType == 0 && SafeRange.location < _Index)
				{
					SafeRange.length -= _Index - SafeRange.location;
					SafeRange.location = _Index;
				}
				return FixupCommentBackground2(pTextView, fs_GetColor(textStorage, NodeType, bJS), NSIntersectionRange(SafeRange, Bounds), false, pViewState);
			}
			else if ([pPreprocessorOperatorCharacters characterIsMember:Character])
			{
				NSUInteger iEnd = MIN(_pEffectiveRange->location + _pEffectiveRange->length, Length);
				NSUInteger iStart = iChar;
				++iChar;
				while (iChar < iEnd)
				{
					Character = [pString characterAtIndex: iChar];
					if (![pPreprocessorOperatorCharacters characterIsMember:Character])
						break;
					++iChar;
				}
				NSRange Range;
				Range.location = iStart;
				Range.length = iChar - iStart;
				*_pEffectiveRange = Range;

				return FixupCommentBackground2(pTextView, pPreprocessorOperator, NSIntersectionRange(*_pEffectiveRange, Bounds), false, pViewState);
			}
			else if ([pPreprocessorEscapeCharacters characterIsMember:Character])
			{
				NSUInteger iEnd = MIN(_pEffectiveRange->location + _pEffectiveRange->length, Length);
				NSUInteger iStart = iChar;
				++iChar;
				while (iChar < iEnd)
				{
					Character = [pString characterAtIndex: iChar];
					if (![pPreprocessorEscapeCharacters characterIsMember:Character])
						break;
					++iChar;
				}
				NSRange Range;
				Range.location = iStart;
				Range.length = iChar - iStart;
				*_pEffectiveRange = Range;

				return FixupCommentBackground2(pTextView, pPreprocessorEscape, NSIntersectionRange(*_pEffectiveRange, Bounds), false, pViewState);
			}
			else if ([pOperatorCharacters characterIsMember:Character])
			{
				NSColor *pColor = pOperator;

				if (iChar > 1)
				{
					char PrevChar0 = [pString characterAtIndex: iChar - 1];
					
					if (PrevChar0 == '_' && Character == '.')
						pColor = pJSONConstants; 
				}
				
				NSUInteger iEnd = MIN(_pEffectiveRange->location + _pEffectiveRange->length, Length);
				NSUInteger iStart = iChar;
				++iChar;
				while (iChar < iEnd)
				{
					Character = [pString characterAtIndex: iChar];
					if (![pOperatorCharacters characterIsMember:Character])
						break;
					++iChar;
				}
				NSRange Range;
				Range.location = iStart;
				Range.length = iChar - iStart;
				*_pEffectiveRange = Range;

				return FixupCommentBackground2(pTextView, pColor, NSIntersectionRange(*_pEffectiveRange, Bounds), false, pViewState);
			}
/* 			else if ([pStartNumberCharacterSet characterIsMember:Character])
			{
				NSUInteger iStart = iChar;
				
				++iChar;
				while (iChar < Length)
				{
					Character = [pString characterAtIndex: iChar];
					if (![pNumberCharacterSet characterIsMember:Character])
						break;
					++iChar;
				}
				
				NSRange Range;
				Range.location = iStart;
				Range.length = iChar - iStart;
				
				*_pEffectiveRange = Range;
				return FixupCommentBackground2(pTextView, fs_GetColor(textStorage, NodeType_Number, bJS), NSIntersectionRange(Range, Bounds), false, pViewState);
			}*/
			else if ([pStartIdentifierCharacterSet characterIsMember:Character])
			{
				NSUInteger iStart = iChar;
				
				char StartCharacter = [pString characterAtIndex: iChar];
				
				if (iChar < Length)
				{
					++iChar;
					Character = [pString characterAtIndex: iChar];

					if (StartCharacter == '_' && Character == '.')
					{
						++iChar;
						NSRange Range;
						Range.location = iStart;
						Range.length = iChar - iStart;
						*_pEffectiveRange = Range;

						return FixupCommentBackground2(pTextView, pJSONConstants, NSIntersectionRange(*_pEffectiveRange, Bounds), false, pViewState);
					}
					else if (StartCharacter == '_' && Character == '=')
					{
						++iChar;
						NSRange Range;
						Range.location = iStart;
						Range.length = iChar - iStart;
						*_pEffectiveRange = Range;

						return FixupCommentBackground2(pTextView, pOperator, NSIntersectionRange(*_pEffectiveRange, Bounds), false, pViewState);
					}
				}
				
				while (iChar < Length)
				{
					if (![pIdentifierCharacterSet characterIsMember:Character])
						break;
					++iChar;
					Character = [pString characterAtIndex: iChar];
				}
				
				NSRange Range;
				Range.location = iStart;
				Range.length = iChar - iStart;

				NSString *pIdentifier = [pString substringWithRange: Range];
				
				NSColor* pColor = nil;
				
				if (!pColor && pExtraDefaultKeywords)
					pColor = [pExtraDefaultKeywords objectForKey:pIdentifier];
				if (!pColor && pExtraDefaultKeywords2)
					pColor = [pExtraDefaultKeywords2 objectForKey:pIdentifier];
				if (!pColor && pExtraDefaultKeywords3)
					pColor = [pExtraDefaultKeywords3 objectForKey:pIdentifier];
				if (!pColor)
					pColor = [pDefaultKeywords objectForKey:pIdentifier];

//				XCFixinLog(@"Parsed Identifier (%@)\n", pIdentifier);
				
				
				NSUInteger Length = [pIdentifier length];
				if (!pColor && Length >= 3)
				{
					for (int i = gc_MaxPrefixLen; i >= 0; --i)
					{
						if (i > Length)
							continue;
						
						NSString *pToFind = [pIdentifier substringToIndex: i];
						
						if (ms_PrefixMapInfo[i])
						{
							pColor = [ms_PrefixMapInfo[i] objectForKey:pToFind];
							if (pColor)
							{
								if (MatchOtherPrefix(pIdentifier, pToFind, i, Length))
								{
									if (i == 1 && [pToFind compare:@"E"] == NSOrderedSame)
									{
										if (NodeType == NodeType_IdentifierType)
											pColor = pEnum;
										else
											pColor = pEnumerator;
									}

									if (i == 2 && [pToFind compare:@"CF"] == NSOrderedSame)
									{
										if ([pIdentifier hasSuffix:@"Ref"])
											pColor = pType;
									}
									break;
								}
							}
						}
						if (ms_PrefixMapInfoVar[i])
						{
							pColor = [ms_PrefixMapInfoVar[i] objectForKey:pToFind];
							if (pColor)
							{
								if (MatchVariablePrefix(pIdentifier, pToFind, i, Length))
									break;
							}
						}
					}
				}

				if (pColor)
				{
					*_pEffectiveRange = Range;
					return FixupCommentBackground2(pTextView, pColor, NSIntersectionRange(*_pEffectiveRange, Bounds), false, pViewState);
				}
			}
		}
		
		NSRange SafeRange = *_pEffectiveRange;
		if (NodeType == 0 && SafeRange.location < _Index)
		{
			SafeRange.length -= _Index - SafeRange.location;
			SafeRange.location = _Index;
		}
		
		if (bIsCpp)
		{
			// Disable broken function parsing in Xcode
			if (NodeType == NodeType_IdentifierFunction || NodeType == NodeType_IdentifierFunctionSystem)
				NodeType = NodeType_IdentifierPlain;
		}
		
		NSColor *pColor = fs_GetColor(textStorage, NodeType, bJS);
		
/*		CGFloat Red;
		CGFloat Green;
		CGFloat Blue;
		CGFloat Alpha;
		[pColor getRed:&Red green:&Green blue:&Blue alpha:&Alpha];
		XCFixinLog(@"Color: %f %f %f - %f\n", Red, Green, Blue, Alpha);*/
		
		return FixupCommentBackground2(pTextView, pColor, NSIntersectionRange(SafeRange, Bounds), false, pViewState);
	}

	return fs_GetColor(textStorage, NodeType, bJS);
}


static NSColor* pKeywordDefault = nil;
static NSColor* pType = nil;
static NSColor* pNamespace = nil;
static NSColor* pTemplateTypeParam_Class = nil;
static NSColor* pTemplateNonTypeParam = nil;
static NSColor* pTemplateTemplateParam = nil;
static NSColor* pFunctionTemplateTypeParam_Class = nil;
static NSColor* pFunctionTemplateNonTypeParam = nil;
static NSColor* pFunctionTemplateTemplateParam = nil;
static NSColor* pTemplateType = nil;
static NSColor* pEnumerator = nil;
static NSColor* pFunctionParameter = nil;
static NSColor* pFunctionParameter_Output = nil;
static NSColor* pFunctionParameter_Output_Pack = nil;
static NSColor* pFunctionParameter_Pack = nil;
static NSColor* pMacroParameter = nil;
static NSColor* pMemberFunctionPrivate = nil;
static NSColor* pMemberFunctionPublic = nil;
static NSColor* pMemberStaticFunctionPrivate = nil;
static NSColor* pMemberStaticFunctionPublic = nil;
static NSColor* pMemberVariablePrivate = nil;
static NSColor* pMemberVariablePublic = nil;
static NSColor* pMemberStaticVariablePrivate = nil;
static NSColor* pMemberStaticVariablePublic = nil;
static NSColor* pStaticFunction = nil;
static NSColor* pGlobalVariable = nil;
static NSColor* pGlobalStaticVariable = nil;
static NSColor* pMemberConstantPrivate = nil;
static NSColor* pMemberConstantPublic = nil;
static NSColor* pGlobalConstant = nil;
static NSColor* pTypedef = nil;
static NSColor* pFunction = nil;
static NSColor* pEnum = nil;
static NSColor* pMacro = nil;
static NSColor* pOperator = nil;
static NSColor* pJSONConstants = nil;
static NSColor* pPreprocessorEscape = nil;
static NSColor* pPreprocessorOperator = nil;
static NSColor* pCommentBackground = nil;
static NSColor* pCommentForeground = nil;
static NSColor* pDocumentationCommentForeground = nil;
static NSColor* pDocumentationCommentForegroundKeyword = nil;
static NSColor* pCommentURL = nil;

static NSColor* pString = NULL;
static NSColor* pCharacter = NULL;
static NSColor* pNumber = NULL;
static NSColor* pPlainText = NULL;

static NSColor* pVariable_Fuctor = nil;
static NSColor* pStaticVariable = nil;
static NSColor* pConstantVariable = nil;

static NSColor* pKeywordBulitInConstants = NULL;
static NSColor* pKeywordControlStatement = NULL;
static NSColor* pKeywordStorageClass = NULL;
static NSColor* pKeywordExceptionHandling = NULL;
static NSColor* pKeywordIntrospection = NULL;
static NSColor* pKeywordStaticAssert = NULL;
static NSColor* pKeywordOptimization = NULL;
static NSColor* pKeywordNewDelete = NULL;
static NSColor* pKeywordCLR = NULL;
static NSColor* pKeywordOther = NULL;
static NSColor* pKeywordTypeSpecification = NULL;
static NSColor* pKeywordNamespace = NULL;
static NSColor* pKeywordTemplate = NULL;
static NSColor* pKeywordFunction = NULL;
static NSColor* pKeywordIn = NULL;
static NSColor* pKeywordTypedef = NULL;
static NSColor* pKeywordUsing = NULL;
static NSColor* pKeywordThis = NULL;
static NSColor* pKeywordOperator = NULL;
static NSColor* pKeywordVirtual = NULL;
static NSColor* pKeywordCasts = NULL;
static NSColor* pKeywordPure = NULL;

static NSColor* pKeywordBulitInTypes = NULL;
static NSColor* pKeywordBulitInCharacterTypes = NULL;
static NSColor* pKeywordBulitInIntegerTypes = NULL;
static NSColor* pKeywordBulitInVectorTypes = NULL;
static NSColor* pKeywordBulitInTypeModifiers = NULL;
static NSColor* pKeywordBulitInFloatTypes = NULL;

static NSColor* pKeywordPropertyModifiers = NULL;
static NSColor* pKeywordAuto = NULL;
static NSColor* pKeywordTypename = NULL;
static NSColor* pKeywordAccess = NULL;
static NSColor* pKeywordQualifier = NULL;

static NSColor* pTemplateNonTypeParam_Pack = NULL;
static NSColor* pFunctionTemplateNonTypeParam_Pack = NULL;
static NSColor* pTemplateTypeParam_Class_Pack = NULL;
static NSColor* pTemplateTemplateParam_Pack = NULL;
static NSColor* pTemplateTypeParam_Function = NULL;
static NSColor* pTemplateTypeParam_Function_Pack = NULL;
static NSColor* pTemplateType_Interface = NULL;
static NSColor* pType_Interface = NULL;
static NSColor* pType_Function = NULL;
static NSColor* pFunctionTemplateTypeParam_Class_Pack = NULL;
static NSColor* pFunctionTemplateTypeParam_Function_Pack = NULL;
static NSColor* pFunctionTemplateTemplateParam_Pack = NULL;
static NSColor* pFunctionTemplateTypeParam_Function = NULL;

static NSColor* pStaticFunction_Recursive = NULL;
static NSColor* pFunction_Recursive = NULL;

static NSColor* pMemberStaticFunctionPrivate_Recursive = NULL;
static NSColor* pMemberFunctionPrivate_Recursive = NULL;
static NSColor* pMemberStaticFunctionPublic_Recursive = NULL;
static NSColor* pMemberFunctionPublic_Recursive = NULL;

static NSColor* pFunctionParameter_Functor = NULL;
static NSColor* pFunctionParameter_Pack_Functor = NULL;
static NSColor* pFunctionParameter_Output_Functor = NULL;
static NSColor* pFunctionParameter_Output_Pack_Functor = NULL;
static NSColor* pMemberVariablePublic_Functor = NULL;
static NSColor* pMemberVariablePrivate_Functor = NULL;
static NSColor* pMemberStaticVariablePublic_Functor = NULL;
static NSColor* pMemberStaticVariablePrivate_Functor = NULL;
static NSColor* pGlobalStaticVariable_Functor = NULL;
static NSColor* pGlobalVariable_Functor = NULL;
static NSColor* pStaticVariable_Functor = NULL;

struct CPrefixMap
{
	char const* m_pPrefix;
	NSColor* const* m_pColor;
	bool m_bVariable;
};

#define ignore(_Var)
static struct CPrefixMap ms_PrefixMap[] = 
	{
		{"t_", &pTemplateNonTypeParam, true}							ignore( t_Test )
		, {"tp_", &pTemplateNonTypeParam_Pack, true}					ignore( tp_Test )
		, {"E", &pEnumerator, false}									ignore( ETest_Value ) // pEnum if NodeType == NodeType_IdentifierType
		, {"k", &pEnumerator, false}									ignore( kCFCompareCaseInsensitive ) // Compatibility with OSX system headers
		, {"c_", &pConstantVariable, true}								ignore( c_Test )
		, {"gc_", &pGlobalConstant, true}								ignore( gc_Test )
		, {"mc_", &pMemberConstantPublic, true}							ignore( mc_Test )
		, {"mcp_", &pMemberConstantPrivate, true}						ignore( mcp_Test )
		, {"tf_", &pFunctionTemplateNonTypeParam, true}					ignore( tf_Test )
		, {"tfp_", &pFunctionTemplateNonTypeParam_Pack, true}			ignore( tfp_Test )

		, {"N", &pNamespace, false}										ignore( NTest )

		, {"t_C", &pTemplateTypeParam_Class, false}						ignore( t_CTest )
		, {"t_F", &pTemplateTypeParam_Function, false}					ignore( t_FTest )
		, {"t_TC", &pTemplateTemplateParam, false}						ignore( t_TCTest )
		, {"tp_C", &pTemplateTypeParam_Class_Pack, false}				ignore( tp_CTest )
		, {"tp_F", &pTemplateTypeParam_Function_Pack, false}			ignore( tp_FTest )
		, {"tp_TC", &pTemplateTemplateParam_Pack, false}				ignore( tp_TCTest )
		, {"C", &pType, false}											ignore( CTest )
		, {"F", &pType_Function, false}									ignore( FTest )
		, {"NS", &pType, false}											ignore( NSTest ) // Compatibility with Cocoa
		, {"UI", &pType, false}											ignore( UITest ) // Compatibility with UIKit
		, {"IC", &pType_Interface, false}								ignore( ICTest )
		, {"TC", &pTemplateType, false}									ignore( TCTest )
		, {"TIC", &pTemplateType_Interface, false}						ignore( TICTest )
		, {"CFStr", &pType, false}										ignore( CFStr256 ) // Compatibility with core foundation
		, {"CFWStr", &pType, false}										ignore( CFWStr256 ) // Compatibility with core foundation
		, {"CFUStr", &pType, false}										ignore( CFUStr256 ) // Compatibility with core foundation
		, {"tf_C", &pFunctionTemplateTypeParam_Class, false}			ignore( tf_CTest )
		, {"tf_F", &pFunctionTemplateTypeParam_Function, false}			ignore( tf_FTest )
		, {"tf_TC", &pFunctionTemplateTemplateParam, false}				ignore( tf_TCTest )
		, {"tfp_C", &pFunctionTemplateTypeParam_Class_Pack, false}		ignore( tfp_CTest )
		, {"tfp_F", &pFunctionTemplateTypeParam_Function_Pack, false}	ignore( tfp_FTest )
		, {"tfp_TC", &pFunctionTemplateTemplateParam_Pack, false}		ignore( tfp_TCTest )
		
		, {"_f", &pFunctionParameter_Functor, false}					ignore( _fTest )
		, {"p_f", &pFunctionParameter_Pack_Functor, false}				ignore( p_fTest ) 
		, {"o_f", &pFunctionParameter_Output_Functor, false}			ignore( o_fTest )
		, {"po_f", &pFunctionParameter_Output_Pack_Functor, false}		ignore( po_fTest )

		, {"_of", &pFunctionParameter_Output_Functor, false}			ignore( _ofTest ) // Deprecate?
		, {"p_of", &pFunctionParameter_Output_Pack_Functor, false}		ignore( p_ofTest ) // Deprecate?
		
		, {"f", &pVariable_Fuctor, false}								ignore( fTest ), {"fl_", &pVariable_Fuctor, false} // To be deprecated
		
		, {"m_f", &pMemberVariablePublic_Functor, false}				ignore( m_fTest )
		, {"mp_f", &pMemberVariablePrivate_Functor, false}				ignore( mp_fTest )
		
		, {"f_", &pMemberFunctionPublic, false}							ignore( f_Test )
		, {"fr_", &pMemberFunctionPublic_Recursive, false}				ignore( fr_Test )
		, {"f_r", &pMemberFunctionPublic_Recursive, false}				ignore( f_rTest )
		, {"fs_", &pMemberStaticFunctionPublic, false}					ignore( fs_Test )
		, {"fsr_", &pMemberStaticFunctionPublic_Recursive, false}		ignore( fsr_Test )
		, {"fs_r", &pMemberStaticFunctionPublic_Recursive, false}		ignore( fs_rTest )
		, {"fp_", &pMemberFunctionPrivate, false}						ignore( fp_Test )
		, {"fpr_", &pMemberFunctionPrivate_Recursive, false}			ignore( fpr_Test )
		, {"fp_r", &pMemberFunctionPrivate_Recursive, false}			ignore( fp_rTest )
		, {"fsp_", &pMemberStaticFunctionPrivate, false}				ignore( fsp_Test )
		, {"fspr_", &pMemberStaticFunctionPrivate_Recursive, false}		ignore( fspr_Test )
		, {"fsp_r", &pMemberStaticFunctionPrivate_Recursive, false}		ignore( fsp_rTest )
		, {"fg_", &pFunction, false}									ignore( fg_Test )
		, {"CF", &pFunction, false}										ignore( CFRelease ) // Compatibility with core foundation
		, {"fgr_", &pFunction_Recursive, false}							ignore( fgr_Test )
		, {"fg_r", &pFunction_Recursive, false}							ignore( fg_rTest )
		, {"fsg_", &pStaticFunction, false}								ignore( fsg_Test )
		, {"fsgr_", &pStaticFunction_Recursive, false}					ignore( fsgr_Test )
		, {"fsg_r", &pStaticFunction_Recursive, false}					ignore( fsg_rTest )

		, {"_", &pFunctionParameter, true}								ignore( _Test )
		, {"p_", &pFunctionParameter_Pack, true}						ignore( p_Test ) 
		, {"o_", &pFunctionParameter_Output, true}						ignore( o_Test )
		, {"po_", &pFunctionParameter_Output_Pack, true}				ignore( po_Test )

		
		, {"_o", &pFunctionParameter_Output, true}						ignore( _oTest ) // Deprecate?
		, {"p_o", &pFunctionParameter_Output_Pack, true}				ignore( p_oTest ) // Deprecate?
		
		
		, {"m_", &pMemberVariablePublic, true}							ignore( m_Test )
		, {"mp_", &pMemberVariablePrivate, true}						ignore( mp_Test )

		, {"D", &pMacro, false}											ignore( DTest )
		, {"d_", &pMacroParameter, true}								ignore( d_Test )

		, {"ms_", &pMemberStaticVariablePublic, true}					ignore( ms_Test )
		, {"ms_f", &pMemberStaticVariablePublic_Functor, false}			ignore( ms_fTest )
		, {"msp_", &pMemberStaticVariablePrivate, true}					ignore( msp_Test )
		, {"msp_f", &pMemberStaticVariablePrivate_Functor, false}		ignore( msp_fTest )
		
		, {"gs_", &pGlobalStaticVariable, true}							ignore( gs_Test )
		, {"gs_f", &pGlobalStaticVariable_Functor, false}				ignore( gs_fTest )
		, {"g_", &pGlobalVariable, true}								ignore( g_Test )
		, {"g_f", &pGlobalVariable_Functor, false}						ignore( g_fTest )
		, {"s_", &pStaticVariable, true}								ignore( s_Test )
		, {"s_f", &pStaticVariable_Functor, false}						ignore( s_fTest )

		
	}
;

const static int gc_MaxPrefixLen = 6;


static NSMutableDictionary * ms_PrefixMapInfoVar[gc_MaxPrefixLen + 1] = {0};
static NSMutableDictionary * ms_PrefixMapInfo[gc_MaxPrefixLen + 1] = {0};

static void fs_CreatePrefixMap()
{
	int nPrefixes = sizeof(ms_PrefixMap) / sizeof(ms_PrefixMap[0]);
	
	for (int i = 0; i < nPrefixes; ++i)
	{
		struct CPrefixMap *pPrefix = &ms_PrefixMap[i];
		
		size_t PrefixLen = strlen(pPrefix->m_pPrefix);
		
		NSMutableDictionary * __strong *pMapInfo = NULL;
		if (pPrefix->m_bVariable)
			pMapInfo = &ms_PrefixMapInfoVar[PrefixLen];
		else
			pMapInfo = &ms_PrefixMapInfo[PrefixLen];
		
		if (!*pMapInfo)
			*pMapInfo = [NSMutableDictionary dictionary];
		
		[*pMapInfo setObject:*pPrefix->m_pColor forKey:@(pPrefix->m_pPrefix)];
		
	}	
}



static void AddDefaultKeyword(NSString* _pKeyword, NSColor* _pColor)
{
	[pDefaultKeywords setObject:_pColor forKey:_pKeyword];
}

static void AddDefaultKeyword_Cpp(NSString* _pKeyword, NSColor* _pColor)
{
	[pDefaultKeywords_Cpp setObject:_pColor forKey:_pKeyword];
}

static void AddDefaultKeyword_CLike(NSString* _pKeyword, NSColor* _pColor)
{
	[pDefaultKeywords_CLike setObject:_pColor forKey:_pKeyword];
}

static void AddDefaultKeyword_C(NSString* _pKeyword, NSColor* _pColor)
{
	[pDefaultKeywords_C setObject:_pColor forKey:_pKeyword];
}

static void AddDefaultKeyword_JS(NSString* _pKeyword, NSColor* _pColor)
{
	[pDefaultKeywords_JS setObject:_pColor forKey:_pKeyword];
}

static void AddDefaultKeyword_CSS(NSString* _pKeyword, NSColor* _pColor)
{
	[pDefaultKeywords_CSS setObject:_pColor forKey:_pKeyword];
}

static NSColor* CreateColor(unsigned int _Color)
{
	CGFloat Colors[] = {((_Color >> 16) & 0xFF)/255.0, ((_Color >> 8) & 0xFF)/255.0, ((_Color >> 0) & 0xFF)/255.0, 1.0};
	//return [NSColor colorWithColorSpace:[NSColorSpace adobeRGB1998ColorSpace] components:Colors count:4];
	return [NSColor colorWithSRGBRed:Colors[0] green:Colors[1] blue:Colors[2] alpha:Colors[3]];
}

static void fs_GenerateHTMLTableStart()
{
//	printf("<div>%s</div>\n", _pHeading);
	//printf("<div style=\"background-color:black;color:white\"><font face=\"Unbroken,Menlo,Consolas,monospace\" style=\"font-size:10px\"><table border=\"0\" cellspacing=\"0\" style=\"margin-left:2px;border-spacing:5px\"><tbody>\n");
	printf("<div class=\"code_table\"><font face=\"Unbroken,Menlo,Consolas,monospace\" style=\"font-size:10px\"><table border=\"0\" cellspacing=\"0\" style=\"margin-left:2px;border-spacing:5px\"><tbody>\n");
}

static void fs_GenerateHTMLSectionStart(char const *_pHeading)
{
//	printf("<div>%s</div>\n", _pHeading);
	printf("<tr><th style=\"width:120px;background-color:black;color:white\">%s</th><th style=\"width:30px;background-color:black;color:white\"></th><th style=\"width:30px;background-color:black;color:white\"></th><th style=\"background-color:black;color:white\"></th><th style=\"background-color:black;color:white\"></th></tr>\n", _pHeading);
}
static void fs_GenerateHTMLSectionStartDual(char const *_pHeading)
{
//	printf("<div>%s</div>\n", _pHeading);
	printf("<tr><th style=\"width:120px;background-color:black;color:white\">%s</th><th style=\"width:30px;background-color:black;color:white\"></th><th style=\"width:30px;background-color:black;color:white\"></th><th style=\"width:30px;background-color:black;color:white\"></th><th style=\"width:30px;background-color:black;color:white\"></th><th style=\"background-color:black;color:white\"></th><th style=\"background-color:black;color:white\"></th></tr>\n", _pHeading);
}
static void fs_GenerateHTMLColor(char const *_pExample, NSColor *_pColor)
{
	CGFloat Components[4];
	[_pColor getComponents:Components];
	
	unsigned int Color = (int)(Components[0] * 255.0) << 16 | (int)(Components[1] * 255.0) << 8 | (int)(Components[2] * 255.0) << 0;
	
	printf("<tr><td></td><td>#%06x</td><td style=\"background-color:#%06x\"></td><td style=\"color:#%06x\">%s</td><td>%s</td></tr>\n", Color, Color, Color, _pExample, "");
}
static void fs_GenerateHTMLColorDual(char const *_pExample, NSColor *_pColorB, NSColor *_pColorF)
{

	CGFloat ComponentsB[4];
	[_pColorB getComponents:ComponentsB];
	CGFloat ComponentsF[4];
	[_pColorF getComponents:ComponentsF];
	
	unsigned int ColorB = (int)(ComponentsB[0] * 255.0) << 16 | (int)(ComponentsB[1] * 255.0) << 8 | (int)(ComponentsB[2] * 255.0) << 0;
	unsigned int ColorF = (int)(ComponentsF[0] * 255.0) << 16 | (int)(ComponentsF[1] * 255.0) << 8 | (int)(ComponentsF[2] * 255.0) << 0;
	
	printf("<tr><td></td><td>#%06x</td><td>#%06x</td><td style=\"background-color:#%06x\"></td><td style=\"background-color:#%06x\"></td><td style=\"background-color:#%06x;color:#%06x\">%s</td><td>%s</td></tr>\n", ColorB, ColorF, ColorB, ColorF, ColorB, ColorF, _pExample, "");
	
}
static void fs_GenerateHTMLSectionEnd()
{
}
static void fs_GenerateHTMLTableEnd()
{
	printf("</tbody></table></font></div>\n");
//	printf("<br>\n");
}

static void fs_GenerateHTML()
{
	fs_GenerateHTMLTableStart();
	
	fs_GenerateHTMLSectionStart("Language");
	fs_GenerateHTMLColor("= * + - % {} [] () <>", pOperator);
	fs_GenerateHTMLColor("#", pPreprocessorOperator);
	fs_GenerateHTMLColor("for if while do", pKeywordDefault);
	fs_GenerateHTMLColor("typename", pKeywordTypename);
	fs_GenerateHTMLColor("inline", pKeywordPropertyModifiers);
	fs_GenerateHTMLColor("\\", pPreprocessorEscape);
	fs_GenerateHTMLColor("public private protected friend", pKeywordAccess);
	fs_GenerateHTMLColor("const volatile", pKeywordQualifier);
	fs_GenerateHTMLSectionEnd();

	fs_GenerateHTMLSectionStart("Builtin types");
	fs_GenerateHTMLColor("int bool void uint32", pKeywordBulitInTypes);
	fs_GenerateHTMLSectionEnd();
	
	fs_GenerateHTMLSectionStart("Constant values");
	fs_GenerateHTMLColor("15 60.6", pNumber);
	fs_GenerateHTMLColor("t_Test", pTemplateNonTypeParam);
	fs_GenerateHTMLColor("gc_Test ETest_Value mc_Test gc_Test c_Test true false nullptr", pGlobalConstant);
	fs_GenerateHTMLColor("mcp_Test", pMemberConstantPrivate);
	fs_GenerateHTMLColor("tf_Test", pFunctionTemplateNonTypeParam);
	fs_GenerateHTMLSectionEnd();

	fs_GenerateHTMLSectionStart("Character");
	fs_GenerateHTMLColor("'T'", pCharacter);
	fs_GenerateHTMLSectionEnd();
	
	fs_GenerateHTMLSectionStart("Namespace");
	fs_GenerateHTMLColor("NTest", pNamespace);
	fs_GenerateHTMLSectionEnd();
	
	fs_GenerateHTMLSectionStart("Types");
	fs_GenerateHTMLColor("t_CTest t_TTest", pTemplateTypeParam_Class);
	fs_GenerateHTMLColor("tf_CTest tf_TTest", pFunctionTemplateTypeParam_Class);
	fs_GenerateHTMLColor("CTest TCTest ETest", pType);
	fs_GenerateHTMLColor("auto", pKeywordAuto);
	fs_GenerateHTMLSectionEnd();

	fs_GenerateHTMLSectionStart("String");
	fs_GenerateHTMLColor("\"String\"", pString);
	fs_GenerateHTMLSectionEnd();

	fs_GenerateHTMLSectionStart("Functors");
	fs_GenerateHTMLColor("_fTest", pFunctionParameter_Functor);
	fs_GenerateHTMLColor("o_fTest", pFunctionParameter_Output_Functor);
	fs_GenerateHTMLColor("fTest", pVariable_Fuctor);
	fs_GenerateHTMLColor("m_fTest", pMemberVariablePublic_Functor);
	fs_GenerateHTMLColor("mp_fTest", pMemberVariablePrivate_Functor);
	fs_GenerateHTMLSectionEnd();
	
	fs_GenerateHTMLSectionStart("Functions");
	fs_GenerateHTMLColor("f_Test fs_Test", pMemberFunctionPublic);
	fs_GenerateHTMLColor("fg_Test fsg_Test", pFunction);
	fs_GenerateHTMLColor("fp_Test fsp_Test ", pMemberFunctionPrivate);
	fs_GenerateHTMLSectionEnd();
	
	fs_GenerateHTMLSectionStart("Parameters");
	fs_GenerateHTMLColor("_Test p_Test", pFunctionParameter);
	fs_GenerateHTMLColor("p_Test po_Test", pFunctionParameter_Output);
	fs_GenerateHTMLSectionEnd();

	fs_GenerateHTMLSectionStart("Variables");
	fs_GenerateHTMLColor("Var", pPlainText);
	fs_GenerateHTMLSectionEnd();

	fs_GenerateHTMLSectionStart("Member variables");
	fs_GenerateHTMLColor("m_Test ms_Test", pMemberVariablePublic);
	fs_GenerateHTMLColor("mp_Test msp_Test", pMemberVariablePrivate);
	fs_GenerateHTMLSectionEnd();
	
	fs_GenerateHTMLSectionStart("Macros");
	fs_GenerateHTMLColor("DTest", pMacro);
	fs_GenerateHTMLColor("d_Test", pMacroParameter);
	fs_GenerateHTMLSectionEnd();	
	
	fs_GenerateHTMLSectionStart("Globals");
	fs_GenerateHTMLColor("ms_Test", pMemberStaticVariablePublic);
	fs_GenerateHTMLColor("g_Test gs_Test", pGlobalVariable);
	fs_GenerateHTMLColor("msp_Test", pMemberStaticVariablePrivate);
	fs_GenerateHTMLSectionEnd();
	fs_GenerateHTMLTableEnd();
	
	fs_GenerateHTMLTableStart();
	
	fs_GenerateHTMLSectionStartDual("Comments");
	fs_GenerateHTMLColorDual("// Comment", pCommentBackground, pCommentForeground);
	fs_GenerateHTMLColorDual("/// Documentation comment", pCommentBackground, pDocumentationCommentForeground);
	fs_GenerateHTMLColorDual("@Keyword", pCommentBackground, pDocumentationCommentForegroundKeyword);
	fs_GenerateHTMLColorDual("http://example.com", pCommentBackground, pCommentURL);
	fs_GenerateHTMLSectionEnd();
	
	fs_GenerateHTMLTableEnd();
	
}

///
/// Doc comment
/// http://example.com

//
// Normal comment
// http://example.com


static void AddDefaultKeywords()
{
	pDefaultKeywords = [[NSMutableDictionary alloc] init];
	pDefaultKeywords_Cpp = [[NSMutableDictionary alloc] init];
	pDefaultKeywords_C = [[NSMutableDictionary alloc] init];
	pDefaultKeywords_CLike = [[NSMutableDictionary alloc] init];
	pDefaultKeywords_JS = [[NSMutableDictionary alloc] init];
	pDefaultKeywords_CSS = [[NSMutableDictionary alloc] init];



#if 0
	uint32
#endif
	pKeywordBulitInTypes = CreateColor(0xFF5966);
	pKeywordBulitInCharacterTypes = pKeywordBulitInTypes;
	pKeywordBulitInIntegerTypes = pKeywordBulitInTypes;
	pKeywordBulitInVectorTypes = pKeywordBulitInTypes;
	pKeywordBulitInTypeModifiers = pKeywordBulitInTypes;
	pKeywordBulitInFloatTypes = pKeywordBulitInTypes;
	
#if 0
	55.6 7
	t_Test
	gc_Test ETest_Value mc_Test nullptr true false NULL c_Test
	mcp_Test
	tf_Test
#endif
	pNumber = CreateColor(0xFF0080);
	
	pTemplateNonTypeParam = CreateColor(0xFF5BAD);
	pTemplateNonTypeParam_Pack = pTemplateNonTypeParam;
	
	pGlobalConstant = CreateColor(0xFF8AC5);
	pEnumerator = pGlobalConstant;
	pMemberConstantPublic = pGlobalConstant;
	pKeywordBulitInConstants = pGlobalConstant;
	pConstantVariable = pGlobalConstant;
	
	pJSONConstants = CreateColor(0xa8a8a8);

	pMemberConstantPrivate = CreateColor(0xCA97B1);

	pFunctionTemplateNonTypeParam = CreateColor(0xFFB7DB);
	pFunctionTemplateNonTypeParam_Pack = pFunctionTemplateNonTypeParam;
	
#if 0
	'T'
#endif
	pCharacter = CreateColor(0xFF48F0);
	
#if 0
	NTest
#endif
	pNamespace = CreateColor(0xD785FF); // 0xA29CCD

	
#if 0
	t_CTest
	tf_CTest
	CTest
	auto
#endif
	pTemplateTypeParam_Class = CreateColor(0x8269FF); // 0x8779FF
	pTemplateTypeParam_Class_Pack = pTemplateTypeParam_Class;
	pTemplateTypeParam_Function = pTemplateTypeParam_Class;
	pTemplateTypeParam_Function_Pack = pTemplateTypeParam_Function;
	pTemplateTemplateParam = pTemplateTypeParam_Class; // CreateColor(0xc854ff); // 0x8779FF
	pTemplateTemplateParam_Pack = pTemplateTemplateParam;
	
	pFunctionTemplateTypeParam_Class = CreateColor(0xCDC3FF); // 0xCBC6FF
	pFunctionTemplateTypeParam_Class_Pack = pFunctionTemplateTypeParam_Class;
	pFunctionTemplateTypeParam_Function = pFunctionTemplateTypeParam_Class;
	pFunctionTemplateTypeParam_Function_Pack = pFunctionTemplateTypeParam_Function;
	pFunctionTemplateTemplateParam = pFunctionTemplateTypeParam_Class; //CreateColor(0xd67eff); // 0xCBC6FF
	pFunctionTemplateTemplateParam_Pack = pFunctionTemplateTemplateParam;
	
	pType = CreateColor(0xB8AAFF); // 0xA79DFF
	pType_Function = pType;
	pType_Interface = pType;
	pTemplateType = pType; // CreateColor(0xe3a2ff); // 0xA79DFF
	pTemplateType_Interface = pTemplateType;
	pTypedef = pType;
	pEnum = pType;
	pKeywordAuto = CreateColor(0xDBD3FF); // 0xC8C0FF
	
#if 0
	"Test"
#endif
	pString = CreateColor(0x009EFF);

#if 0
	_fTest
	o_fTest
	fTest
	m_fTest
	mp_fTest
#endif

	pFunctionParameter_Functor = CreateColor(0x00e4e6);
	pFunctionParameter_Pack_Functor = pFunctionParameter_Functor;
	pFunctionParameter_Output_Functor = CreateColor(0x36e8cd);
	pFunctionParameter_Output_Pack_Functor = pFunctionParameter_Output_Functor;

	pVariable_Fuctor = CreateColor(0x00edae);

	pMemberVariablePublic_Functor = CreateColor(0x00f265);
	
	pMemberVariablePrivate_Functor = CreateColor(0x4fc17e);
	

#if 0
	f_Test
	fg_Test
	fp_Test
#endif
	pMemberFunctionPublic = CreateColor(0x26FF00);
	pMemberFunctionPublic_Recursive = pMemberFunctionPublic;
	pMemberStaticFunctionPublic = pMemberFunctionPublic;
	pMemberStaticFunctionPublic_Recursive = pMemberStaticFunctionPublic;

	pFunction = CreateColor(0x1CB900);
	pFunction_Recursive = pFunction;
	pStaticFunction = pFunction;
	pStaticFunction_Recursive = pStaticFunction;
	
	pMemberFunctionPrivate = CreateColor(0x8DD580);
	pMemberFunctionPrivate_Recursive = pMemberFunctionPrivate;
	pMemberStaticFunctionPrivate = pMemberFunctionPrivate;
	pMemberStaticFunctionPrivate_Recursive = pMemberStaticFunctionPrivate;
	
#if 0
	_Test
	o_Test
#endif
	pFunctionParameter = CreateColor(0xE6FF00);
	pFunctionParameter_Pack = pFunctionParameter;

	pFunctionParameter_Output = CreateColor(0xFFF54B); // 0xE6FF00
	pFunctionParameter_Output_Pack = pFunctionParameter_Output; // 0xE6FF00
	
#if 0
	PlainVar
#endif
	pPlainText = CreateColor(0xFFD700);
	
#if 0
	m_Test
	mp_Test
#endif
	pMemberVariablePublic = CreateColor(0xFFA600);

	pMemberVariablePrivate = CreateColor(0xC59D53);
	
#if 0
	DTest
	d_Test
#endif
	pMacro = CreateColor(0xFF7700);
	pMacroParameter = CreateColor(0xFFBC81);
	
	
#if 0
	ms_Test
	g_Test
	msp_Test
#endif
	
	pMemberStaticVariablePublic = CreateColor(0xFF3F1C);
	pMemberStaticVariablePublic_Functor = pMemberStaticVariablePublic;
	
	pGlobalVariable = CreateColor(0xE13819);
	pGlobalVariable_Functor = pGlobalVariable;
	pGlobalStaticVariable = pGlobalVariable;
	pGlobalStaticVariable_Functor = pGlobalStaticVariable;
	pStaticVariable = pGlobalVariable;
	pStaticVariable_Functor = pStaticVariable;
	
	pMemberStaticVariablePrivate = CreateColor(0xD56955);
	pMemberStaticVariablePrivate_Functor = pMemberStaticVariablePrivate;

	
#if 0
	= * / +
	for
	inline
	typename
	# \
	private public protected friend 
	const volatile 
#endif
	
	pOperator = CreateColor(0xFFFFFF);
	pKeywordDefault = CreateColor(0xFFFFFF);
	pPreprocessorOperator = pOperator;
	
	pKeywordPropertyModifiers = CreateColor(0xC0C0C0);
	pKeywordTypename = CreateColor(0xC0C0C0);
	pPreprocessorEscape = CreateColor(0x808080);
	pKeywordAccess = CreateColor(0xFFC8CA);
	pKeywordQualifier = CreateColor(0xFFB680);
	
	
	// Test http://www.example.com
	/// Test http://www.example.com \brief @brief
	
	
	pCommentBackground = CreateColor(0x003737);
	pCommentForeground = CreateColor(0xFF9F3B);
	pDocumentationCommentForeground = CreateColor(0x9BCDE6);
	pDocumentationCommentForegroundKeyword = CreateColor(0xF070B6);
	pCommentURL = CreateColor(0x9DFF70);
	
	
	pKeywordControlStatement = pKeywordDefault;
	pKeywordStorageClass = pKeywordDefault;
	pKeywordExceptionHandling = pKeywordDefault;
	pKeywordIntrospection = pKeywordDefault;
	pKeywordStaticAssert = pKeywordDefault;
	pKeywordOptimization = pKeywordDefault;
	pKeywordNewDelete = pKeywordDefault;
	pKeywordCLR = pKeywordDefault;
	pKeywordOther = pKeywordDefault;
	pKeywordTypeSpecification = pKeywordDefault;
	pKeywordNamespace = pKeywordDefault;
	pKeywordTemplate = pKeywordDefault;
	pKeywordFunction = pKeywordDefault;
	pKeywordIn = pKeywordDefault;
	pKeywordTypedef = pKeywordDefault;
	pKeywordUsing = pKeywordDefault;
	pKeywordThis = pKeywordDefault;
	pKeywordOperator = pKeywordDefault;
	pKeywordVirtual = pKeywordDefault;
	pKeywordCasts = pKeywordDefault;
	pKeywordPure = pKeywordDefault;
	
		
	
	// Qualifiers
	AddDefaultKeyword_C(@"const", pKeywordQualifier);
	AddDefaultKeyword_C(@"volatile", pKeywordQualifier);

	// Storage class
	AddDefaultKeyword_C(@"register", pKeywordStorageClass);
	AddDefaultKeyword_C(@"static", pKeywordStorageClass);
	AddDefaultKeyword_C(@"extern", pKeywordStorageClass);
	AddDefaultKeyword_C(@"mutable", pKeywordStorageClass);

	// built in types
	AddDefaultKeyword_C(@"bool", pKeywordBulitInTypes);
	AddDefaultKeyword_CLike(@"void", pKeywordBulitInTypes);
	AddDefaultKeyword_C(@"bint", pKeywordBulitInTypes);
	AddDefaultKeyword_C(@"zbint", pKeywordBulitInTypes);
	AddDefaultKeyword_C(@"zbool", pKeywordBulitInTypes);

	// built in character types
	AddDefaultKeyword_C(@"char", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"__wchar_t", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"wchar_t", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"ch8", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"ch16", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"ch32", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"uch8", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"uch16", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"uch32", pKeywordBulitInCharacterTypes);

	AddDefaultKeyword_C(@"zch8", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"zch16", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"zch32", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"zuch8", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"zuch16", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"zuch32", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"char16_t", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"char32_t", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword_C(@"zuch32", pKeywordBulitInCharacterTypes);


	// built in integer types
	AddDefaultKeyword_C(@"int", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"size_t", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"__int16", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"__int32", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"__int64", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"__int8", pKeywordBulitInIntegerTypes);

	AddDefaultKeyword_C(@"int8", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"int16", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"int32", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"int64", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"int80", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"int128", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"int160", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"int256", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"int512", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"int1024", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"int2048", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"int4096", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"int8192", pKeywordBulitInIntegerTypes);


	AddDefaultKeyword_C(@"uint8", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"uint16", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"uint32", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"uint64", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"uint80", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"uint128", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"uint160", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"uint256", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"uint512", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"uint1024", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"uint2048", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"uint4096", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"uint8192", pKeywordBulitInIntegerTypes);

	AddDefaultKeyword_C(@"zint8", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuint8", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zint16", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuint16", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zint32", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuint32", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zint64", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuint64", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zint80", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuint80", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zint128", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuint128", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zint160", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuint160", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zint256", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuint256", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zint512", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuint512", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zint1024", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuint1024", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zint2048", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuint2048", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zint4096", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuint4096", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zint8192", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuint8192", pKeywordBulitInIntegerTypes);

	AddDefaultKeyword_C(@"mint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"smint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"umint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"aint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"uaint", pKeywordBulitInIntegerTypes);

	AddDefaultKeyword_C(@"zmint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zumint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zsmint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zamint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword_C(@"zuamint", pKeywordBulitInIntegerTypes);


	// builtin type modifiers
	AddDefaultKeyword_C(@"long", pKeywordBulitInTypeModifiers);
	AddDefaultKeyword_C(@"short", pKeywordBulitInTypeModifiers);
	AddDefaultKeyword_C(@"signed", pKeywordBulitInTypeModifiers);
	AddDefaultKeyword_C(@"unsigned", pKeywordBulitInTypeModifiers);

	// built in vector types
	AddDefaultKeyword_C(@"__m128", pKeywordBulitInVectorTypes);
	AddDefaultKeyword_C(@"__m64", pKeywordBulitInVectorTypes);
	AddDefaultKeyword_C(@"__w64", pKeywordBulitInVectorTypes);
	AddDefaultKeyword_C(@"__m128i", pKeywordBulitInVectorTypes);
	AddDefaultKeyword_C(@"__m128d", pKeywordBulitInVectorTypes);

	// built in floating point types
	AddDefaultKeyword_C(@"float", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"double", pKeywordBulitInFloatTypes);

	AddDefaultKeyword_C(@"fp8", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"fp16", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"fp32", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"fp64", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"fp80", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"fp128", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"fp256", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"fp512", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"fp1024", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"fp2048", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"fp4096", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"ufp8", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"ufp16", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"ufp32", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"ufp64", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"ufp80", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"ufp128", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"ufp256", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"ufp512", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"ufp1024", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"ufp2048", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"ufp4096", pKeywordBulitInFloatTypes);

	AddDefaultKeyword_C(@"zfp8", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zfp16", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zfp32", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zfp64", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zfp80", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zfp128", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zfp256", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zfp512", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zfp1024", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zfp2048", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zfp4096", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zufp8", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zufp16", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zufp32", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zufp64", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zufp80", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zufp128", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zufp256", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zufp512", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zufp1024", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zufp2048", pKeywordBulitInFloatTypes);
	AddDefaultKeyword_C(@"zufp4096", pKeywordBulitInFloatTypes);

	// bult in constants
	AddDefaultKeyword(@"false", pKeywordBulitInConstants);
	AddDefaultKeyword(@"true", pKeywordBulitInConstants);
	AddDefaultKeyword_C(@"nullptr", pKeywordBulitInConstants);
	AddDefaultKeyword_C(@"NULL", pKeywordBulitInConstants);
	
	AddDefaultKeyword_JS(@"null", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"undefined", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"Infinity", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"NaN", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"E", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"LN2", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"LN10", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"LOG2E", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"LOG10E", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"MAX_VALUE", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"MIN_VALUE", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"NEGATIVE_INFINITY", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"PI", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"POSITIVE_INFINITY", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"SQRT1_2", pKeywordBulitInConstants);
	AddDefaultKeyword_JS(@"SQRT2", pKeywordBulitInConstants);

	
	// JSON constants
	AddDefaultKeyword_C(@"_", pJSONConstants);

	// Exception handling
	AddDefaultKeyword_CLike(@"try", pKeywordExceptionHandling);
	AddDefaultKeyword_CLike(@"throw", pKeywordExceptionHandling);
	AddDefaultKeyword_CLike(@"catch", pKeywordExceptionHandling);
	AddDefaultKeyword_C(@"__try", pKeywordExceptionHandling);
	AddDefaultKeyword_C(@"__except", pKeywordExceptionHandling);
	AddDefaultKeyword_C(@"__finally", pKeywordExceptionHandling);
	AddDefaultKeyword_C(@"__leave", pKeywordExceptionHandling);
	AddDefaultKeyword_C(@"__raise", pKeywordExceptionHandling);
	AddDefaultKeyword_CLike(@"finally", pKeywordExceptionHandling);

	// Type introspection/type traits
	AddDefaultKeyword_C(@"__alignof", pKeywordIntrospection);
	AddDefaultKeyword_C(@"sizeof", pKeywordIntrospection);
	AddDefaultKeyword_C(@"decltype", pKeywordIntrospection);
	AddDefaultKeyword_JS(@"typeof", pKeywordIntrospection);
	AddDefaultKeyword_JS(@"instanceof", pKeywordIntrospection);
	AddDefaultKeyword_C(@"__uuidof", pKeywordIntrospection);
	AddDefaultKeyword_C(@"typeid", pKeywordIntrospection);

	// Static assert
	AddDefaultKeyword_C(@"static_assert", pKeywordStaticAssert);

	// Control statements
	AddDefaultKeyword_CLike(@"while", pKeywordControlStatement);
	AddDefaultKeyword_CLike(@"for", pKeywordControlStatement);
	AddDefaultKeyword_CLike(@"goto", pKeywordControlStatement);
	AddDefaultKeyword_CLike(@"if", pKeywordControlStatement);
	AddDefaultKeyword_CLike(@"do", pKeywordControlStatement);
	AddDefaultKeyword_CLike(@"break", pKeywordControlStatement);
	AddDefaultKeyword_CLike(@"case", pKeywordControlStatement);
	AddDefaultKeyword_CLike(@"continue", pKeywordControlStatement);
	AddDefaultKeyword_CLike(@"default", pKeywordControlStatement);
	AddDefaultKeyword_CLike(@"else", pKeywordControlStatement);
	AddDefaultKeyword_CLike(@"return", pKeywordControlStatement);
	AddDefaultKeyword_CLike(@"switch", pKeywordControlStatement);

	AddDefaultKeyword_C(@"likely", pKeywordControlStatement);
	AddDefaultKeyword_C(@"unlikely", pKeywordControlStatement);
	AddDefaultKeyword_C(@"assume", pKeywordControlStatement);
	
	AddDefaultKeyword_C(@"yield_cpu", pKeywordControlStatement);
	

	AddDefaultKeyword_C(@"constant_int64", pKeywordControlStatement);
	AddDefaultKeyword_C(@"constant_uint64", pKeywordControlStatement);
	
	// Optimization
	AddDefaultKeyword_C(@"__asm", pKeywordOptimization);
	AddDefaultKeyword_C(@"__assume", pKeywordOptimization);

	// Property modifiers
	AddDefaultKeyword_C(@"__unaligned", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"__declspec", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"__based", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"deprecated", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"dllexport", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"dllimport", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"naked", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"noinline", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"noreturn", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"nothrow", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"noexcept", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"novtable", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"property", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"selectany", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"thread", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"uuid", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"explicit", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"__forceinline", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"__inline", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"inline", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"__cdecl", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"__thiscall", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"__fastcall", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"__stdcall", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"calling_convention_c", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"cdecl", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"stdcall", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"fastcall", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"inline_small", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"inline_always", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"inline_never", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"inline_never_debug", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"inline_medium", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"inline_large", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"inline_extralarge", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"inline_always_debug", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"module_export", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"module_import", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"only_parameters_aliased", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"return_not_aliased", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"function_does_not_return", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"variable_not_aliased", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"constexpr", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"__pragma", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"__attribute__", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"__restrict__", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"assure_used", pKeywordPropertyModifiers);                
	AddDefaultKeyword_C(@"align_cacheline", pKeywordPropertyModifiers);
	AddDefaultKeyword_C(@"intrinsic", pKeywordPropertyModifiers);

	// new/delete operators
	AddDefaultKeyword_CLike(@"delete", pKeywordNewDelete);
	AddDefaultKeyword_CLike(@"new", pKeywordNewDelete);

	// CLR
	AddDefaultKeyword_C(@"__abstract", pKeywordCLR);
	AddDefaultKeyword_C(@"abstract", pKeywordCLR);
	AddDefaultKeyword_C(@"__box", pKeywordCLR);
	AddDefaultKeyword_C(@"__delegate", pKeywordCLR);
	AddDefaultKeyword_C(@"__gc", pKeywordCLR);
	AddDefaultKeyword_C(@"__hook", pKeywordCLR);
	AddDefaultKeyword_C(@"__nogc", pKeywordCLR);
	AddDefaultKeyword_C(@"__pin", pKeywordCLR);
	AddDefaultKeyword_C(@"__property", pKeywordCLR);
	AddDefaultKeyword_C(@"__sealed", pKeywordCLR);
	AddDefaultKeyword_C(@"__try_cast", pKeywordCLR);
	AddDefaultKeyword_C(@"__unhook", pKeywordCLR);
	AddDefaultKeyword_C(@"__value", pKeywordCLR);
	// AddDefaultKeyword_C(@"array", pKeywordCLR); // used in stdlib
	// AddDefaultKeyword_C(@"delegate", pKeywordCLR); // too generic
	AddDefaultKeyword_C(@"event", pKeywordCLR);
	AddDefaultKeyword_C(@"__identifier", pKeywordCLR);
	AddDefaultKeyword_C(@"friend_as", pKeywordCLR);
	AddDefaultKeyword_C(@"interface", pKeywordCLR);
	AddDefaultKeyword_C(@"interior_ptr", pKeywordCLR);
	AddDefaultKeyword_C(@"gcnew", pKeywordCLR);
	AddDefaultKeyword_C(@"generic", pKeywordCLR);
	AddDefaultKeyword_C(@"initonly", pKeywordCLR);
	AddDefaultKeyword_C(@"literal", pKeywordCLR);
	AddDefaultKeyword_C(@"ref", pKeywordCLR);
	AddDefaultKeyword_C(@"safecast", pKeywordCLR);
//	AddDefaultKeyword_C(@"value", pKeywordCLR); // used in stdlib

	// Other keywords
	AddDefaultKeyword_C(@"__event", pKeywordOther);
	AddDefaultKeyword_C(@"__if_exists", pKeywordOther);
	AddDefaultKeyword_C(@"__if_not_exists", pKeywordOther);
	AddDefaultKeyword_C(@"__interface", pKeywordOther);
	AddDefaultKeyword_C(@"__multiple_inheritance", pKeywordOther);
	AddDefaultKeyword_C(@"__single_inheritance", pKeywordOther);
	AddDefaultKeyword_C(@"__virtual_inheritance", pKeywordOther);
	AddDefaultKeyword_C(@"__super", pKeywordOther);
	AddDefaultKeyword_C(@"__noop", pKeywordOther);

	// Type specification keywords
	AddDefaultKeyword_C(@"union", pKeywordTypeSpecification);
	AddDefaultKeyword_C(@"class", pKeywordTypeSpecification);
	AddDefaultKeyword_C(@"enum", pKeywordTypeSpecification);
	AddDefaultKeyword_C(@"struct", pKeywordTypeSpecification);

	// namespace
	AddDefaultKeyword_C(@"namespace", pKeywordNamespace);

	// typename
	AddDefaultKeyword_C(@"typename", pKeywordTypename);

	// template
	AddDefaultKeyword_C(@"template", pKeywordTemplate);

	// function
	AddDefaultKeyword_JS(@"function", pKeywordFunction);

	// in
	AddDefaultKeyword_JS(@"in", pKeywordIn);

	// typedef
	AddDefaultKeyword_C(@"typedef", pKeywordTypedef);

	// using
	AddDefaultKeyword_C(@"using", pKeywordUsing);

	// auto
	AddDefaultKeyword_Cpp(@"auto", pKeywordAuto);
	AddDefaultKeyword_JS(@"var", pKeywordAuto);

	// this
	AddDefaultKeyword_CLike(@"this", pKeywordThis);
	AddDefaultKeyword_CLike(@"self", pKeywordThis);

	// operator
	AddDefaultKeyword_CLike(@"operator", pKeywordOperator);

	// Access keywords
	AddDefaultKeyword_C(@"friend", pKeywordAccess);
	AddDefaultKeyword_C(@"private", pKeywordAccess);
	AddDefaultKeyword_C(@"public", pKeywordAccess);
	AddDefaultKeyword_C(@"protected", pKeywordAccess);

	// Virtual keywords
	AddDefaultKeyword_C(@"final", pKeywordVirtual);
	AddDefaultKeyword_C(@"sealed", pKeywordVirtual);
	AddDefaultKeyword_C(@"override", pKeywordVirtual);
	AddDefaultKeyword_C(@"virtual", pKeywordVirtual);
	AddDefaultKeyword_C(@"pure", pKeywordPure);

	// casts
	AddDefaultKeyword_C(@"const_cast", pKeywordCasts);
	AddDefaultKeyword_C(@"dynamic_cast", pKeywordCasts);
	AddDefaultKeyword_C(@"reinterpret_cast", pKeywordCasts);
	AddDefaultKeyword_C(@"static_cast", pKeywordCasts);

	// ignore
	AddDefaultKeyword_C(@"ignore", CreateColor(0x707070));

	NSColor *pPreprocessorDirective = CreateColor(0xFFFFFF);
	// Preprocessor directive
	AddDefaultKeyword_C(@"#define", pPreprocessorDirective);
	AddDefaultKeyword_C(@"#error", pPreprocessorDirective);
	AddDefaultKeyword_C(@"#import", pPreprocessorDirective);
	AddDefaultKeyword_C(@"#undef", pPreprocessorDirective);
	AddDefaultKeyword_C(@"#elif", pPreprocessorDirective);
	AddDefaultKeyword_C(@"#if", pPreprocessorDirective);
	AddDefaultKeyword_C(@"#include", pPreprocessorDirective);
	AddDefaultKeyword_C(@"#using", pPreprocessorDirective);
	AddDefaultKeyword_C(@"#else", pPreprocessorDirective);
	AddDefaultKeyword_C(@"#ifdef", pPreprocessorDirective);
	AddDefaultKeyword_C(@"#line", pPreprocessorDirective);
	AddDefaultKeyword_C(@"#endif", pPreprocessorDirective);
	AddDefaultKeyword_C(@"#ifndef", pPreprocessorDirective);
	AddDefaultKeyword_C(@"#pragma", pPreprocessorDirective);

	AddDefaultKeyword_C(@"define", pPreprocessorDirective);
	AddDefaultKeyword_C(@"error", pPreprocessorDirective);
	AddDefaultKeyword_C(@"import", pPreprocessorDirective);
	AddDefaultKeyword_C(@"undef", pPreprocessorDirective);
	AddDefaultKeyword_C(@"elif", pPreprocessorDirective);
	//AddDefaultKeyword(@"if", pPreprocessorDirective);
	AddDefaultKeyword_C(@"include", pPreprocessorDirective);
	AddDefaultKeyword_C(@"once", pPreprocessorDirective);
	AddDefaultKeyword_C(@"defined", pPreprocessorDirective);
	AddDefaultKeyword_C(@"using", pPreprocessorDirective);
	//AddDefaultKeyword(@"else", pPreprocessorDirective);
	AddDefaultKeyword_C(@"ifdef", pPreprocessorDirective);
	AddDefaultKeyword_C(@"line", pPreprocessorDirective);
	AddDefaultKeyword_C(@"endif", pPreprocessorDirective);
	AddDefaultKeyword_C(@"ifndef", pPreprocessorDirective);
	AddDefaultKeyword_C(@"pragma", pPreprocessorDirective);

	AddDefaultKeyword_JS(@"use", pPreprocessorDirective);
	AddDefaultKeyword_JS(@"strict", pPreprocessorDirective);
	
	// JS

	// Type and namespace
	AddDefaultKeyword_JS(@"object", pType);
	AddDefaultKeyword_JS(@"Array", pType);
	AddDefaultKeyword_JS(@"ArrayBuffer", pType);
	AddDefaultKeyword_JS(@"arguments", pFunctionParameter_Pack);
	AddDefaultKeyword_JS(@"Boolean", pType);
	AddDefaultKeyword_JS(@"DataView", pType);
	AddDefaultKeyword_JS(@"Date", pType);
	AddDefaultKeyword_JS(@"Debug", pType);
	AddDefaultKeyword_JS(@"Enumerator", pType);
	AddDefaultKeyword_JS(@"Error", pType);
	AddDefaultKeyword_JS(@"Float32Array", pType);
	AddDefaultKeyword_JS(@"Float64Array", pType);
	AddDefaultKeyword_JS(@"Function", pType);
	AddDefaultKeyword_JS(@"Global", pNamespace);
	AddDefaultKeyword_JS(@"Int8Array", pType);
	AddDefaultKeyword_JS(@"Int16Array", pType);
	AddDefaultKeyword_JS(@"Intl", pNamespace);
	AddDefaultKeyword_JS(@"Collator", pType);
	AddDefaultKeyword_JS(@"DateTimeFormat", pType);
	AddDefaultKeyword_JS(@"NumberFormat", pType);
	AddDefaultKeyword_JS(@"JSON", pNamespace);
	AddDefaultKeyword_JS(@"Map", pType);
	AddDefaultKeyword_JS(@"Math", pNamespace);
	AddDefaultKeyword_JS(@"Number", pType);
	AddDefaultKeyword_JS(@"Object", pType);
	AddDefaultKeyword_JS(@"Promise", pType);
	AddDefaultKeyword_JS(@"RegExp", pType);
	AddDefaultKeyword_JS(@"Set", pType);
	AddDefaultKeyword_JS(@"String", pType);
	AddDefaultKeyword_JS(@"Uint8Array", pType);
	AddDefaultKeyword_JS(@"Uint16Array", pType);
	AddDefaultKeyword_JS(@"Uint32Array", pType);
	AddDefaultKeyword_JS(@"Uint8ClampedArray", pType);
	AddDefaultKeyword_JS(@"VBArray", pType);
	AddDefaultKeyword_JS(@"WeakMap", pType);
	
	// Properties
	AddDefaultKeyword_JS(@"__proto__", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"__proto__", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"$1", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"$2", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"$3", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"$4", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"$5", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"$6", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"$7", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"$8", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"$9", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"callee", pMemberVariablePublic_Functor);
	AddDefaultKeyword_JS(@"caller", pMemberVariablePublic_Functor);
	AddDefaultKeyword_JS(@"constructor", pMemberVariablePublic_Functor);
	AddDefaultKeyword_JS(@"description", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"global", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"ignoreCase", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"index", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"input", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"lastIndex", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"lastMatch", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"lastParen", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"leftContext", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"length", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"message", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"multiline", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"name", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"number", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"prototype", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"rightContext", pMemberVariablePublic);
	AddDefaultKeyword_JS(@"source", pMemberVariablePublic);
	
	// Functions
	AddDefaultKeyword_JS(@"source", pFunction);
	AddDefaultKeyword_JS(@"abs", pFunction);
	AddDefaultKeyword_JS(@"acos", pFunction);
	AddDefaultKeyword_JS(@"asin", pFunction);
	AddDefaultKeyword_JS(@"atan", pFunction);
	AddDefaultKeyword_JS(@"atan2", pFunction);
	AddDefaultKeyword_JS(@"ceil", pFunction);
	AddDefaultKeyword_JS(@"cos", pFunction);
	AddDefaultKeyword_JS(@"create", pFunction);
	AddDefaultKeyword_JS(@"decodeURI", pFunction);
	AddDefaultKeyword_JS(@"decodeURIComponent", pFunction);
	AddDefaultKeyword_JS(@"defineProperties", pFunction);
	AddDefaultKeyword_JS(@"defineProperty", pFunction);
	AddDefaultKeyword_JS(@"encodeURI", pFunction);
	AddDefaultKeyword_JS(@"encodeURIComponent", pFunction);
	AddDefaultKeyword_JS(@"escape", pFunction);
	AddDefaultKeyword_JS(@"eval", pFunction);
	AddDefaultKeyword_JS(@"exp", pFunction);
	AddDefaultKeyword_JS(@"floor", pFunction);
	AddDefaultKeyword_JS(@"freeze", pFunction);
	AddDefaultKeyword_JS(@"fromCharCode", pFunction);
	AddDefaultKeyword_JS(@"GetObject", pFunction);
	AddDefaultKeyword_JS(@"getOwnPropertyDescriptor", pFunction);
	AddDefaultKeyword_JS(@"getOwnPropertyNames", pFunction);
	AddDefaultKeyword_JS(@"getPrototypeOf", pFunction);
	AddDefaultKeyword_JS(@"isArray", pFunction);
	AddDefaultKeyword_JS(@"isExtensible", pFunction);
	AddDefaultKeyword_JS(@"isFinite", pFunction);
	AddDefaultKeyword_JS(@"isFrozen", pFunction);
	AddDefaultKeyword_JS(@"isNaN", pFunction);
	AddDefaultKeyword_JS(@"isSealed", pFunction);
	AddDefaultKeyword_JS(@"keys", pFunction);
	AddDefaultKeyword_JS(@"log", pFunction);
	AddDefaultKeyword_JS(@"max", pFunction);
	AddDefaultKeyword_JS(@"min", pFunction);
	AddDefaultKeyword_JS(@"now", pFunction);
	AddDefaultKeyword_JS(@"parse", pFunction);
	AddDefaultKeyword_JS(@"parse", pFunction);
	AddDefaultKeyword_JS(@"parseFloat", pFunction);
	AddDefaultKeyword_JS(@"parseInt", pFunction);
	AddDefaultKeyword_JS(@"pow", pFunction);
	AddDefaultKeyword_JS(@"preventExtensions", pFunction);
	AddDefaultKeyword_JS(@"random", pFunction);
	AddDefaultKeyword_JS(@"round", pFunction);
	AddDefaultKeyword_JS(@"ScriptEngine", pFunction);
	AddDefaultKeyword_JS(@"ScriptEngineBuildVersion", pFunction);
	AddDefaultKeyword_JS(@"ScriptEngineMajorVersion", pFunction);
	AddDefaultKeyword_JS(@"ScriptEngineMinorVersion", pFunction);
	AddDefaultKeyword_JS(@"seal", pFunction);
	AddDefaultKeyword_JS(@"sin", pFunction);
	AddDefaultKeyword_JS(@"sqrt", pFunction);
	AddDefaultKeyword_JS(@"stringify", pFunction);
	AddDefaultKeyword_JS(@"tan", pFunction);
	AddDefaultKeyword_JS(@"unescape", pFunction);
	AddDefaultKeyword_JS(@"UTC", pFunction);
	AddDefaultKeyword_JS(@"write", pFunction);
	AddDefaultKeyword_JS(@"writeln", pFunction);
	
	// Methods
	
	AddDefaultKeyword_JS(@"anchor", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"apply", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"atEnd", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"big", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"bind", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"blink", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"bold", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"call", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"charAt", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"charCodeAt", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"compile", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"concat", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"dimensions", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"every", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"exec", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"filter", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"fixed", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"fontcolor", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"fontsize", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"forEach", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getDate", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getDay", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getFullYear", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getHours", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getItem", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getMilliseconds", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getMinutes", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getMonth", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getSeconds", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getTime", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getTimezoneOffset", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getUTCDate", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getUTCDay", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getUTCFullYear", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getUTCHours", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getUTCMilliseconds", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getUTCMinutes", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getUTCMonth", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getUTCSeconds", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getVarDate", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getYear", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"hasOwnProperty", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"indexOf", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"isPrototypeOf", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"italics", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"item", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"join", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"lastIndexOf", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"lbound", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"link", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"localeCompare", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"map", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"match", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"moveFirst", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"moveNext", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"pop", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"propertyIsEnumerable", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"push", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"reduce", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"reduceRight", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"replace", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"reverse", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"search", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setDate", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setFullYear", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setHours", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setMilliseconds", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setMinutes", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setMonth", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setSeconds", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setTime", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setUTCDate", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setUTCFullYear", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setUTCHours", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setUTCMilliseconds", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setUTCMinutes", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setUTCMonth", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setUTCSeconds", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setYear", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"shift", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"slice", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"small", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"some", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"sort", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"splice", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"split", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"strike", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"sub", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"substr", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"substring", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"sup", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"test", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toArray", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toDateString", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toExponential", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toFixed", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toGMTString", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toISOString", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toJSON", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toLocaleDateString", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toLocaleLowerCase", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toLocaleString", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toLocaleTimeString", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toLocaleUpperCase", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toLowerCase", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toPrecision", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toString", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toTimeString", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toUpperCase", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"toUTCString", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"trim", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"ubound", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"unshift", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"valueOf", pMemberFunctionPublic);
	
	// Meteor
	AddDefaultKeyword_JS(@"Meteor", pNamespace);
	AddDefaultKeyword_JS(@"Router", pNamespace);
	AddDefaultKeyword_JS(@"Template", pNamespace);
	AddDefaultKeyword_JS(@"FastClick", pType);
	
	AddDefaultKeyword_JS(@"window", pGlobalVariable);
	AddDefaultKeyword_JS(@"console", pGlobalVariable);
	AddDefaultKeyword_JS(@"Session", pGlobalVariable);

	AddDefaultKeyword_JS(@"render", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"get", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"set", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"setDefault", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"userId", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"insert", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"getKey", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"attach", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"events", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"helpers", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"route", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"startup", pMemberFunctionPublic);
	AddDefaultKeyword_JS(@"helpers", pMemberFunctionPublic);
	
	// std lib
	AddDefaultKeyword_Cpp(@"std", pNamespace);
	AddDefaultKeyword_Cpp(@"atomic", pTemplateType);
	AddDefaultKeyword_Cpp(@"set", pTemplateType);
	AddDefaultKeyword_Cpp(@"multiset", pTemplateType);
	AddDefaultKeyword_Cpp(@"map", pTemplateType);
	AddDefaultKeyword_Cpp(@"multimap", pTemplateType);
	AddDefaultKeyword_Cpp(@"unordered_set", pTemplateType);
	AddDefaultKeyword_Cpp(@"unordered_multiset", pTemplateType);
	AddDefaultKeyword_Cpp(@"unordered_map", pTemplateType);
	AddDefaultKeyword_Cpp(@"unordered_multimap", pTemplateType);
	AddDefaultKeyword_Cpp(@"list", pTemplateType);
	AddDefaultKeyword_Cpp(@"vector", pTemplateType);
	AddDefaultKeyword_Cpp(@"queue", pTemplateType);
	AddDefaultKeyword_Cpp(@"priority_queue", pTemplateType);
	AddDefaultKeyword_Cpp(@"forward_list", pTemplateType);
	AddDefaultKeyword_Cpp(@"deque", pTemplateType);
	AddDefaultKeyword_Cpp(@"array", pTemplateType);
	AddDefaultKeyword_Cpp(@"stack", pTemplateType);
	AddDefaultKeyword_Cpp(@"basic_ifstream", pTemplateType);
	AddDefaultKeyword_Cpp(@"basic_ofstream", pTemplateType);
	AddDefaultKeyword_Cpp(@"basic_fstream", pTemplateType);
	AddDefaultKeyword_Cpp(@"basic_filebuf", pTemplateType);
	AddDefaultKeyword_Cpp(@"basic_string", pTemplateType);
	AddDefaultKeyword_Cpp(@"char_traits", pTemplateType);
	AddDefaultKeyword_Cpp(@"tuple", pTemplateType);
	AddDefaultKeyword_Cpp(@"pair", pTemplateType);

	AddDefaultKeyword_Cpp(@"string", pType);
	AddDefaultKeyword_Cpp(@"u16string", pType);
	AddDefaultKeyword_Cpp(@"u32string", pType);
	AddDefaultKeyword_Cpp(@"wstring", pType);
	AddDefaultKeyword_Cpp(@"ifstream", pType);
	AddDefaultKeyword_Cpp(@"ofstream", pType);
	AddDefaultKeyword_Cpp(@"fstream", pType);
	AddDefaultKeyword_Cpp(@"filebuf", pType);
	AddDefaultKeyword_Cpp(@"wifstream", pType);
	AddDefaultKeyword_Cpp(@"wofstream", pType);
	AddDefaultKeyword_Cpp(@"wfstream", pType);
	AddDefaultKeyword_Cpp(@"wfilebuf", pType);
	AddDefaultKeyword_Cpp(@"atomic_flag", pType);
	AddDefaultKeyword_Cpp(@"iterator", pType);
	AddDefaultKeyword_Cpp(@"const_iterator", pType);
	AddDefaultKeyword_Cpp(@"value_type", pType);
	AddDefaultKeyword_Cpp(@"allocator_type", pType);
	AddDefaultKeyword_Cpp(@"type", pType);
	AddDefaultKeyword_Cpp(@"reference", pType);
	AddDefaultKeyword_Cpp(@"const_reference", pType);
	AddDefaultKeyword_Cpp(@"pointer", pType);
	AddDefaultKeyword_Cpp(@"const_pointer", pType);
	AddDefaultKeyword_Cpp(@"reverse_iterator", pType);
	AddDefaultKeyword_Cpp(@"const_reverse_iterator", pType);
	AddDefaultKeyword_Cpp(@"difference_type", pType);
	AddDefaultKeyword_Cpp(@"size_type", pType);
	AddDefaultKeyword_Cpp(@"key_compare", pType);
	AddDefaultKeyword_Cpp(@"value_compare", pType);
	AddDefaultKeyword_Cpp(@"key_type", pType);
	AddDefaultKeyword_Cpp(@"mapped_type", pType);
	AddDefaultKeyword_Cpp(@"hasher", pType);
	AddDefaultKeyword_Cpp(@"key_equal", pType);
	AddDefaultKeyword_Cpp(@"local_iterator", pType);
	AddDefaultKeyword_Cpp(@"const_local_iterator", pType);
	AddDefaultKeyword_Cpp(@"char_type", pType);
	AddDefaultKeyword_Cpp(@"traits_type", pType);
	AddDefaultKeyword_Cpp(@"int_type", pType);
	AddDefaultKeyword_Cpp(@"pos_type", pType);
	AddDefaultKeyword_Cpp(@"off_type", pType);
	AddDefaultKeyword_Cpp(@"state_type", pType);
	

	AddDefaultKeyword_Cpp(@"length", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"fill", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"data", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"size", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"empty", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"max_size", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"at", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"insert", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"erase", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"clear", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"emplace", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"emplace_hint", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"key_comp", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"value_comp", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"find", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"count", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"lower_bound", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"upper_bound", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"equal_range", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"get_allocator", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"front", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"back", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"push", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"pop", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"top", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"assign", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"emplace_front", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"emplace_back", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"push_front", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"push_back", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"pop_front", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"pop_back", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"resize", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"splice", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"remove", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"remove_if", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"unique", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"merge", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"sort", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"reverse", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"before_begin", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"cbefore_begin", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"emplace_after", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"insert_after", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"erase_after", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"splice_after", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"shrink_to_fit", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"bucket_count", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"bucket_size", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"bucket", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"max_bucket_count", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"load_factor", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"max_load_factor", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"rehash", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"reserve", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"hash_fuction", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"key_eq", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"capacity", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"c_str", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"find", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"rfind", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"copy", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"find_first_of", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"find_last_of", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"find_first_not_of", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"fint_last_not_of", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"substr", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"compare", pMemberFunctionPublic);

	AddDefaultKeyword_Cpp(@"memory_order", pEnum);
	AddDefaultKeyword_Cpp(@"memory_order_relaxed", pEnumerator);
	AddDefaultKeyword_Cpp(@"memory_order_consume", pEnumerator);
	AddDefaultKeyword_Cpp(@"memory_order_acquire", pEnumerator);
	AddDefaultKeyword_Cpp(@"memory_order_release", pEnumerator);
	AddDefaultKeyword_Cpp(@"memory_order_acq_rel", pEnumerator);
	AddDefaultKeyword_Cpp(@"memory_order_seq_cst", pEnumerator);
	
	AddDefaultKeyword_Cpp(@"is_lock_free", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"store", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"load", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"exchange", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"compare_exchange_weak", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"compare_exchange_strong", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"fetch_add", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"fetch_sub", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"fetch_and", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"fetch_or", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"fetch_xor", pMemberFunctionPublic);

	AddDefaultKeyword_Cpp(@"tie", pFunction);
	AddDefaultKeyword_Cpp(@"make_tuple", pFunction);
	AddDefaultKeyword_Cpp(@"forward_as_tuple", pFunction);
	AddDefaultKeyword_Cpp(@"tuple_cat", pFunction);

	AddDefaultKeyword_Cpp(@"npos", pMemberConstantPublic);
	AddDefaultKeyword_Cpp(@"value", pMemberConstantPublic);
	AddDefaultKeyword_Cpp(@"getline", pFunction);
	AddDefaultKeyword_Cpp(@"min", pFunction);
	AddDefaultKeyword_Cpp(@"max", pFunction);
	AddDefaultKeyword_Cpp(@"assert", pMacro);
	
	AddDefaultKeyword_Cpp(@"integral_constant", pTemplateType);
	AddDefaultKeyword_Cpp(@"true_type", pType);
	AddDefaultKeyword_Cpp(@"false_type", pType);

	AddDefaultKeyword_Cpp(@"is_array", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_class", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_enum", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_floating_point", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_function", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_integral", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_lvalue_reference", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_member_function_pointer", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_member_object_pointer", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_pointer", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_rvalue_reference", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_union", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_void", pTemplateType);

	AddDefaultKeyword_Cpp(@"is_arithmetic", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_compound", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_fundamental", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_member_pointer", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_object", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_reference", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_scalar", pTemplateType);

	AddDefaultKeyword_Cpp(@"is_abstract", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_const", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_empty", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_literal_type", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_pod", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_polymorphic", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_signed", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_standard_layout", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_trivial", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_trivially_copyable", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_unsigned", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_volatile", pTemplateType);

	AddDefaultKeyword_Cpp(@"has_virtual_destructor", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_assignable", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_constructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_copy_assignable", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_copy_constructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_destructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_default_constructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_move_assignable", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_move_constructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_trivially_assignable", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_trivially_constructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_trivially_copy_assignable", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_trivially_copy_constructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_trivially_destructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_trivially_default_constructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_trivially_move_assignable", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_trivially_move_constructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_nothrow_assignable", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_nothrow_constructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_nothrow_copy_assignable", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_nothrow_copy_constructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_nothrow_destructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_nothrow_default_constructible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_nothrow_move_assignable", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_nothrow_move_constructible", pTemplateType);

	AddDefaultKeyword_Cpp(@"is_base_of", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_convertible", pTemplateType);
	AddDefaultKeyword_Cpp(@"is_same", pTemplateType);

	AddDefaultKeyword_Cpp(@"alignment_of", pTemplateType);
	AddDefaultKeyword_Cpp(@"extent", pTemplateType);
	AddDefaultKeyword_Cpp(@"rank", pTemplateType);


	AddDefaultKeyword_Cpp(@"add_const", pTemplateType);
	AddDefaultKeyword_Cpp(@"add_cv", pTemplateType);
	AddDefaultKeyword_Cpp(@"add_volatile", pTemplateType);
	AddDefaultKeyword_Cpp(@"remove_const", pTemplateType);
	AddDefaultKeyword_Cpp(@"remove_cv", pTemplateType);
	AddDefaultKeyword_Cpp(@"remove_volatile", pTemplateType);

	AddDefaultKeyword_Cpp(@"add_pointer", pTemplateType);
	AddDefaultKeyword_Cpp(@"add_lvalue_reference", pTemplateType);
	AddDefaultKeyword_Cpp(@"add_rvalue_reference", pTemplateType);
	AddDefaultKeyword_Cpp(@"decay", pTemplateType);
	AddDefaultKeyword_Cpp(@"make_signed", pTemplateType);
	AddDefaultKeyword_Cpp(@"make_unsigned", pTemplateType);
	AddDefaultKeyword_Cpp(@"remove_all_extents", pTemplateType);
	AddDefaultKeyword_Cpp(@"remove_extent", pTemplateType);
	AddDefaultKeyword_Cpp(@"remove_pointer", pTemplateType);
	AddDefaultKeyword_Cpp(@"remove_reference", pTemplateType);
	AddDefaultKeyword_Cpp(@"underlying_type", pTemplateType);

	AddDefaultKeyword_Cpp(@"aligned_storage", pTemplateType);
	AddDefaultKeyword_Cpp(@"aligned_union", pTemplateType);
	AddDefaultKeyword_Cpp(@"common_type", pTemplateType);
	AddDefaultKeyword_Cpp(@"conditional", pTemplateType);
	AddDefaultKeyword_Cpp(@"enable_if", pTemplateType);
	AddDefaultKeyword_Cpp(@"result_of", pTemplateType);

	
	AddDefaultKeyword_Cpp(@"make_pair", pFunction);
	AddDefaultKeyword_Cpp(@"forward", pFunction);
	AddDefaultKeyword_Cpp(@"move", pFunction);
	AddDefaultKeyword_Cpp(@"move_if_noexcept", pFunction);
	AddDefaultKeyword_Cpp(@"declval", pFunction);
	
	AddDefaultKeyword_Cpp(@"bind", pFunction);
	AddDefaultKeyword_Cpp(@"function", pTemplateType);
	
	AddDefaultKeyword_Cpp(@"allocator", pTemplateType);
	AddDefaultKeyword_Cpp(@"auto_ptr_ref", pTemplateType);
	AddDefaultKeyword_Cpp(@"shared_ptr", pTemplateType);
	AddDefaultKeyword_Cpp(@"weak_ptr", pTemplateType);
	AddDefaultKeyword_Cpp(@"unique_ptr", pTemplateType);
	AddDefaultKeyword_Cpp(@"default_delete", pTemplateType);
	
	AddDefaultKeyword_Cpp(@"make_shared", pFunction);
	AddDefaultKeyword_Cpp(@"allocate_shared", pFunction);
	AddDefaultKeyword_Cpp(@"static_pointer_cast", pFunction);
	AddDefaultKeyword_Cpp(@"dynamic_pointer_cast", pFunction);
	AddDefaultKeyword_Cpp(@"const_pointer_cast", pFunction);
	AddDefaultKeyword_Cpp(@"get_deleter", pFunction);

	AddDefaultKeyword_Cpp(@"owner_less", pTemplateType);
	AddDefaultKeyword_Cpp(@"enable_shared_from_this", pTemplateType);
	
	AddDefaultKeyword_Cpp(@"CFStr", pType);
	AddDefaultKeyword_Cpp(@"CFWStr", pType);
	AddDefaultKeyword_Cpp(@"CFUStr", pType);
	
	AddDefaultKeyword_Cpp(@"str_utf8", pKeywordPropertyModifiers);
	AddDefaultKeyword_Cpp(@"str_utf16", pKeywordPropertyModifiers);
	AddDefaultKeyword_Cpp(@"str_utf32", pKeywordPropertyModifiers);

#if 0
	// Let's not pollute the namespace here
	AddDefaultKeyword_Cpp(@"event_callback", pType_Function);
	AddDefaultKeyword_Cpp(@"failure", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"fmtflags", pEnum);
	AddDefaultKeyword_Cpp(@"iostate", pEnum);
	AddDefaultKeyword_Cpp(@"openmode", pEnum);
	AddDefaultKeyword_Cpp(@"seekdir", pEnum);
	AddDefaultKeyword_Cpp(@"sentry", pMemberFunctionPublic);

	AddDefaultKeyword_Cpp(@"open", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"is_open", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"close", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"rdbuf", pMemberFunctionPublic);

	AddDefaultKeyword_Cpp(@"gcount", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"getline", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"peek", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"read", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"readsome", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"putback", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"unget", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"tellg", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"seekg", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"sync", pMemberFunctionPublic);

	AddDefaultKeyword_Cpp(@"good", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"eof", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"fail", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"bad", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"rdstate", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"setstate", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"copyfmt", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"exceptions", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"imbue", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"tie", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"rdbuf", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"narrow", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"widen", pMemberFunctionPublic);

	AddDefaultKeyword_Cpp(@"flags", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"setf", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"unsetf", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"precision", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"width", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"imbue", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"getloc", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"xalloc", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"iword", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"pword", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"register_callback", pMemberFunctionPublic);
	AddDefaultKeyword_Cpp(@"sync_with_stdio", pMemberFunctionPublic);
	
	AddDefaultKeyword_Cpp(@"begin", pFunction);
	AddDefaultKeyword_Cpp(@"end", pFunction);
	AddDefaultKeyword_Cpp(@"rbegin", pFunction);
	AddDefaultKeyword_Cpp(@"rend", pFunction);
	AddDefaultKeyword_Cpp(@"cbegin", pFunction);
	AddDefaultKeyword_Cpp(@"cend", pFunction);
	AddDefaultKeyword_Cpp(@"crbegin", pFunction);
	AddDefaultKeyword_Cpp(@"crend", pFunction);
	AddDefaultKeyword_Cpp(@"swap", pFunction);
	AddDefaultKeyword_Cpp(@"get", pFunction);
#endif
	
	fs_CreatePrefixMap();
	
//	fs_GenerateHTML();
}

static NSMutableCharacterSet *pStartIdentifierCharacterSet = nil;
static NSMutableCharacterSet *pIdentifierCharacterSet = nil;
static NSMutableCharacterSet *pStartNumberCharacterSet = nil;
static NSMutableCharacterSet *pNumberCharacterSet = nil;
static NSMutableCharacterSet *pValidConceptCharacters = nil;
static NSMutableCharacterSet *pOperatorCharacters = nil;
static NSMutableCharacterSet *pPreprocessorOperatorCharacters = nil;
static NSMutableCharacterSet *pPreprocessorEscapeCharacters = nil;
static NSMutableCharacterSet *pUpperCaseChars = nil;
static NSCharacterSet *pWhitespaceChars = nil;
static NSCharacterSet *pWhitespaceNoNewLineChars = nil;
static NSCharacterSet *pNewLineChars = nil;
static NSMutableDictionary *pDefaultKeywords = nil;
static NSMutableDictionary *pDefaultKeywords_Cpp = nil;
static NSMutableDictionary *pDefaultKeywords_C = nil;
static NSMutableDictionary *pDefaultKeywords_CLike = nil;
static NSMutableDictionary *pDefaultKeywords_JS = nil;
static NSMutableDictionary *pDefaultKeywords_CSS = nil;

+ (void) pluginDidLoad: (NSBundle*)plugin
{
	// Singleton instance

	XCFixinPreflight(false);

	{
		pWhitespaceChars = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		pWhitespaceNoNewLineChars = [NSCharacterSet whitespaceCharacterSet];
		pNewLineChars = [NSCharacterSet newlineCharacterSet];
	}
	{
		pStartIdentifierCharacterSet = [[NSMutableCharacterSet alloc] init];
		[pStartIdentifierCharacterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
		[pStartIdentifierCharacterSet removeCharactersInString:@"0123456789"];
		[pStartIdentifierCharacterSet addCharactersInString:@"_"];
	}
	{
		pStartNumberCharacterSet = [[NSMutableCharacterSet alloc] init];
		[pStartNumberCharacterSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
	}
	{
		pIdentifierCharacterSet = [[NSMutableCharacterSet alloc] init];
		[pIdentifierCharacterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
		[pIdentifierCharacterSet addCharactersInString:@"_"];
	}
	{
		pNumberCharacterSet = [[NSMutableCharacterSet alloc] init];
		[pNumberCharacterSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
		[pNumberCharacterSet addCharactersInString:@".xXeEfF"];
		[pNumberCharacterSet formUnionWithCharacterSet:pIdentifierCharacterSet];
	}
	
	{
		pValidConceptCharacters = [[NSMutableCharacterSet alloc] init];
		[pValidConceptCharacters addCharactersInString:@"bcfinpt"];
	}
	{
		pOperatorCharacters = [[NSMutableCharacterSet alloc] init];
		[pOperatorCharacters addCharactersInString:@":;+-()[]{}<>!~*&.,/%=^|?"];
	}
	{
		pPreprocessorOperatorCharacters = [[NSMutableCharacterSet alloc] init];
		[pPreprocessorOperatorCharacters addCharactersInString:@"#"];
	}
	{
		pPreprocessorEscapeCharacters = [[NSMutableCharacterSet alloc] init];
		[pPreprocessorEscapeCharacters addCharactersInString:@"\\"];
	}
	{
		pUpperCaseChars = [[NSMutableCharacterSet alloc] init];
		[pUpperCaseChars formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
		[pUpperCaseChars formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
	}

	
	NodeType_Comment = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.comment"];
	NodeType_CommentDoc = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.comment.doc"];
	NodeType_CommentDocKeyword = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.comment.doc.keyword"];
	NodeType_URL = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.url"];
	NodeType_String = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.string"];
	NodeType_Character = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.character"];
	NodeType_Number = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.number"];
	NodeType_Keyword = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.keyword"];
	NodeType_Preprocessor = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.preprocessor"];

	NodeType_Identifier = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier"];
	NodeType_IdentifierPlain = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.plain"];
	
	NodeType_IdentifierMacro = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.macro"];
	NodeType_IdentifierMacroSystem = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.macro.system"];
	
	NodeType_IdentifierConstant = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.constant"];
	NodeType_IdentifierConstantSystem = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.constant.system"];
	
	NodeType_IdentifierClass = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.class"];
	NodeType_IdentifierClassSystem = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.class.system"];
	
	NodeType_IdentifierType = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.type"];
	NodeType_IdentifierTypeSystem = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.type.system"];
	
	NodeType_IdentifierFunction = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.function"];
	NodeType_IdentifierFunctionSystem = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.function.system"];
	
	NodeType_IdentifierVariable = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.variable"];
	NodeType_IdentifierVariableSystem = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.variable.system"];
	

#if 0
	// Potential node types to handle
	xcode.syntax.attribute
	xcode.syntax.call
	xcode.syntax.completionplaceholder
	xcode.syntax.declaration.class
	xcode.syntax.declaration.enum
	xcode.syntax.declaration.function
	xcode.syntax.declaration.method
	xcode.syntax.declaration.objc.interface
	xcode.syntax.declaration.property
	xcode.syntax.declaration.struct
	xcode.syntax.declaration.union
	xcode.syntax.definition.class
	xcode.syntax.definition.cpp.class
	xcode.syntax.definition.function
	xcode.syntax.definition.macro
	xcode.syntax.definition.method
	xcode.syntax.definition.protocol
	xcode.syntax.entity
	xcode.syntax.entity.start
	xcode.syntax.java.import
	xcode.syntax.java.package
	xcode.syntax.mark
	xcode.syntax.method.declarator
	xcode.syntax.name
	xcode.syntax.name.partial
	xcode.syntax.name.tree
	xcode.syntax.objc.import
	xcode.syntax.partialname
	xcode.syntax.plain
	xcode.syntax.preprocessor.identifier
	xcode.syntax.preprocessor.include
	xcode.syntax.preprocessor.keyword
	xcode.syntax.stmt.block
	xcode.syntax.typedef
	xcode.syntax.warning
#endif
	
	AddDefaultKeywords();

	highlighter = [[XCFixin_Highlight alloc] init];

	if (!highlighter)
	{
		XCFixinLog(@"%s: highlighter init failed.\n",__FUNCTION__);
	}
	
	original_colorAtCharacterIndex = XCFixinOverrideMethodString(@"DVTTextStorage", @selector(colorAtCharacterIndex: effectiveRange: context:), (IMP)&colorAtCharacterIndex);
	XCFixinAssertOrPerform(original_colorAtCharacterIndex, goto failed);

	original_IDESourceCodeEditor_doInitialSetup = XCFixinOverrideMethodString(@"IDESourceCodeEditor", @selector(_doInitialSetup), (IMP)&IDESourceCodeEditor_doInitialSetup);
	XCFixinAssertOrPerform(original_IDESourceCodeEditor_doInitialSetup, goto failed);
	
	XCFixinPostflight();
}

@end


