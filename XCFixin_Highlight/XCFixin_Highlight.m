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
#import "../Shared Code/Xcode/IDESourceCodeEditor.h"
#import "../Shared Code/Xcode/IDEIndex.h"


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

static NSColor* fs_GetColor(DVTTextStorage* _pTextStorage, short _NodeType)
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
		return pCharacter;
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

static NSColor* colorAtCharacterIndex(id self_, SEL _cmd, unsigned long long _Index, struct _NSRange *_pEffectiveRange, NSDictionary* _pContext)
{
	DVTTextStorage* textStorage = self_;
	DVTSourceCodeLanguage* pLanguage = [textStorage language];
	
	long long NodeType = [textStorage nodeTypeAtCharacterIndex:_Index effectiveRange:_pEffectiveRange context:_pContext];
//	NSColor* OriginalRet = ((NSColor* (*)(id, SEL, unsigned long long, struct _NSRange *, id))original_colorAtCharacterIndex)(self_, _cmd, _Index, _pEffectiveRange, _pContext);
	
	if (pLanguage)
	{
		if (NodeType == NodeType_Identifier)
			NodeType = NodeType_IdentifierPlain; // Mimic the behaviour in Xcode implementation of colorAtCharacterIndex
	
		if (!pNodeTypeDict)
			pNodeTypeDict = [NSMutableDictionary dictionary];
		
		/*
		NSNumber *pToFind = @(NodeType);
		
		NSString *pNode = [pNodeTypeDict objectForKey:pToFind];
		if (!pNode)
		{
			[pNodeTypeDict setObject:[DVTSourceNodeTypes nodeTypeNameForId:NodeType] forKey:pToFind];
			XCFixinLog(@"NodeType: %@\n", [DVTSourceNodeTypes nodeTypeNameForId:NodeType]);
		}*/
		//double Time = CFAbsoluteTimeGetCurrent();
		
		NSString* pIdentifier = [pLanguage identifier];
		
		BOOL bSupportedLanguage = false;

		if ([pIdentifier hasPrefix:@"Xcode.SourceCodeLanguage."])
			bSupportedLanguage = true;

		if (!bSupportedLanguage)
		{
//			XCFixinLog(@"Language not supported: %@\n", pIdentifier);
			return fs_GetColor(textStorage, NodeType);
		}

		NSArray* pViews = [textStorage _associatedTextViews];
		DVTSourceTextView* pTextView = nil;
		if (pViews && [pViews count] > 0)
		{
			pTextView = [pViews lastObject];
		}
		
		if (!pTextView)
		{
			return fs_GetColor(textStorage, NodeType);
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
			return FixupCommentBackground2(pTextView, fs_GetColor(textStorage, NodeType), NSIntersectionRange(*_pEffectiveRange, Bounds), true, pViewState);
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
			return FixupCommentBackground2(pTextView, fs_GetColor(textStorage, NodeType), NSIntersectionRange(*_pEffectiveRange, Bounds), false, pViewState);
		}
		if (NodeType == NodeType_String || NodeType == NodeType_Character)
		{
			// Don't color strings, numbers and characters
			return FixupCommentBackground2(pTextView, fs_GetColor(textStorage, NodeType), NSIntersectionRange(*_pEffectiveRange, Bounds), false, pViewState);
		}
		
		NSUInteger iChar = _Index;
		unichar Character = [pString characterAtIndex: iChar];
		
		if (_pEffectiveRange->location > 0 && _pEffectiveRange->location < iChar)
		{
			if ([pIdentifierCharacterSet characterIsMember:Character])
			{
				// Walk backwords finding start of identifier
				while (iChar > _pEffectiveRange->location)
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
				return FixupCommentBackground2(pTextView, fs_GetColor(textStorage, NodeType), NSIntersectionRange(SafeRange, Bounds), false, pViewState);
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

				return FixupCommentBackground2(pTextView, pOperator, NSIntersectionRange(*_pEffectiveRange, Bounds), false, pViewState);
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
				return FixupCommentBackground2(pTextView, fs_GetColor(textStorage, NodeType_Number), NSIntersectionRange(Range, Bounds), false, pViewState);
			}*/
			else if ([pStartIdentifierCharacterSet characterIsMember:Character])
			{
				NSUInteger iStart = iChar;
				
				++iChar;
				while (iChar < Length)
				{
					Character = [pString characterAtIndex: iChar];
					if (![pIdentifierCharacterSet characterIsMember:Character])
						break;
					++iChar;
				}
				
				NSRange Range;
				Range.location = iStart;
				Range.length = iChar - iStart;

				NSString *pIdentifier = [pString substringWithRange: Range];
				
				NSColor* pColor = [pDefaultKeywords objectForKey:pIdentifier];

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
		
		NSColor *pColor = fs_GetColor(textStorage, NodeType);
		
/*		CGFloat Red;
		CGFloat Green;
		CGFloat Blue;
		CGFloat Alpha;
		[pColor getRed:&Red green:&Green blue:&Blue alpha:&Alpha];
		XCFixinLog(@"Color: %f %f %f - %f\n", Red, Green, Blue, Alpha);*/
		
		return FixupCommentBackground2(pTextView, pColor, NSIntersectionRange(SafeRange, Bounds), false, pViewState);
	}

	return fs_GetColor(textStorage, NodeType);
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
		, {"CFStr", &pType, false}										ignore( CFStr ) // Compatibility with core foundation
		, {"CFWStr", &pType, false}										ignore( CFWStr ) // Compatibility with core foundation
		, {"CFUStr", &pType, false}										ignore( CFUStr ) // Compatibility with core foundation
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

static NSColor* CreateColor(unsigned int _Color)
{
	CGFloat Colors[] = {((_Color >> 16) & 0xFF)/255.0, ((_Color >> 8) & 0xFF)/255.0, ((_Color >> 0) & 0xFF)/255.0, 1.0};
	//return [NSColor colorWithColorSpace:[NSColorSpace adobeRGB1998ColorSpace] components:Colors count:4];
	return [NSColor colorWithSRGBRed:Colors[0] green:Colors[1] blue:Colors[2] alpha:Colors[3]];
}

static void fs_GenerateHTMLTableStart()
{
//	printf("<div>%s</div>\n", _pHeading);
	printf("<div style=\"background-color:black;color:white\"><font face=\"Unbroken,Menlo,Consolas,monospace\" style=\"font-size:10px\"><table border=\"0\" cellspacing=\"0\" style=\"margin-left:2px;border-spacing:5px\"><tbody>\n");
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
	pKeywordTypedef = pKeywordDefault;
	pKeywordUsing = pKeywordDefault;
	pKeywordThis = pKeywordDefault;
	pKeywordOperator = pKeywordDefault;
	pKeywordVirtual = pKeywordDefault;
	pKeywordCasts = pKeywordDefault;
	pKeywordPure = pKeywordDefault;
	
		
	
	// Qualifiers
	AddDefaultKeyword(@"const", pKeywordQualifier);
	AddDefaultKeyword(@"volatile", pKeywordQualifier);

	// Storage class
	AddDefaultKeyword(@"register", pKeywordStorageClass);
	AddDefaultKeyword(@"static", pKeywordStorageClass);
	AddDefaultKeyword(@"extern", pKeywordStorageClass);
	AddDefaultKeyword(@"mutable", pKeywordStorageClass);

	// built in types
	AddDefaultKeyword(@"bool", pKeywordBulitInTypes);
	AddDefaultKeyword(@"void", pKeywordBulitInTypes);
	AddDefaultKeyword(@"bint", pKeywordBulitInTypes);
	AddDefaultKeyword(@"zbint", pKeywordBulitInTypes);
	AddDefaultKeyword(@"zbool", pKeywordBulitInTypes);

	// built in character types
	AddDefaultKeyword(@"char", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword(@"__wchar_t", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword(@"wchar_t", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword(@"ch8", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword(@"ch16", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword(@"ch32", pKeywordBulitInCharacterTypes);

	AddDefaultKeyword(@"zch8", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword(@"zch16", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword(@"zch32", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword(@"zuch8", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword(@"zuch16", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword(@"zuch32", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword(@"char16_t", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword(@"char32_t", pKeywordBulitInCharacterTypes);
	AddDefaultKeyword(@"zuch32", pKeywordBulitInCharacterTypes);


	// built in integer types
	AddDefaultKeyword(@"int", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"size_t", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"__int16", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"__int32", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"__int64", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"__int8", pKeywordBulitInIntegerTypes);

	AddDefaultKeyword(@"int8", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"int16", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"int32", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"int64", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"int80", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"int128", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"int160", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"int256", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"int512", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"int1024", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"int2048", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"int4096", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"int8192", pKeywordBulitInIntegerTypes);


	AddDefaultKeyword(@"uint8", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"uint16", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"uint32", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"uint64", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"uint80", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"uint128", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"uint160", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"uint256", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"uint512", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"uint1024", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"uint2048", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"uint4096", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"uint8192", pKeywordBulitInIntegerTypes);

	AddDefaultKeyword(@"zint8", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuint8", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zint16", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuint16", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zint32", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuint32", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zint64", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuint64", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zint80", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuint80", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zint128", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuint128", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zint160", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuint160", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zint256", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuint256", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zint512", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuint512", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zint1024", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuint1024", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zint2048", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuint2048", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zint4096", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuint4096", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zint8192", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuint8192", pKeywordBulitInIntegerTypes);

	AddDefaultKeyword(@"mint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"smint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"umint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"aint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"uaint", pKeywordBulitInIntegerTypes);

	AddDefaultKeyword(@"zmint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zumint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zsmint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zamint", pKeywordBulitInIntegerTypes);
	AddDefaultKeyword(@"zuamint", pKeywordBulitInIntegerTypes);


	// builtin type modifiers
	AddDefaultKeyword(@"long", pKeywordBulitInTypeModifiers);
	AddDefaultKeyword(@"short", pKeywordBulitInTypeModifiers);
	AddDefaultKeyword(@"signed", pKeywordBulitInTypeModifiers);
	AddDefaultKeyword(@"unsigned", pKeywordBulitInTypeModifiers);

	// built in vector types
	AddDefaultKeyword(@"__m128", pKeywordBulitInVectorTypes);
	AddDefaultKeyword(@"__m64", pKeywordBulitInVectorTypes);
	AddDefaultKeyword(@"__w64", pKeywordBulitInVectorTypes);
	AddDefaultKeyword(@"__m128i", pKeywordBulitInVectorTypes);
	AddDefaultKeyword(@"__m128d", pKeywordBulitInVectorTypes);

	// built in floating point types
	AddDefaultKeyword(@"float", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"double", pKeywordBulitInFloatTypes);

	AddDefaultKeyword(@"fp8", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"fp16", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"fp32", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"fp64", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"fp80", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"fp128", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"fp256", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"fp512", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"fp1024", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"fp2048", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"fp4096", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"ufp8", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"ufp16", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"ufp32", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"ufp64", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"ufp80", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"ufp128", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"ufp256", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"ufp512", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"ufp1024", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"ufp2048", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"ufp4096", pKeywordBulitInFloatTypes);

	AddDefaultKeyword(@"zfp8", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zfp16", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zfp32", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zfp64", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zfp80", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zfp128", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zfp256", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zfp512", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zfp1024", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zfp2048", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zfp4096", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zufp8", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zufp16", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zufp32", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zufp64", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zufp80", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zufp128", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zufp256", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zufp512", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zufp1024", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zufp2048", pKeywordBulitInFloatTypes);
	AddDefaultKeyword(@"zufp4096", pKeywordBulitInFloatTypes);

	// bult in constants
	AddDefaultKeyword(@"false", pKeywordBulitInConstants);
	AddDefaultKeyword(@"true", pKeywordBulitInConstants);
	AddDefaultKeyword(@"nullptr", pKeywordBulitInConstants);
	AddDefaultKeyword(@"NULL", pKeywordBulitInConstants);

	// Exception handling
	AddDefaultKeyword(@"try", pKeywordExceptionHandling);
	AddDefaultKeyword(@"throw", pKeywordExceptionHandling);
	AddDefaultKeyword(@"catch", pKeywordExceptionHandling);
	AddDefaultKeyword(@"__try", pKeywordExceptionHandling);
	AddDefaultKeyword(@"__except", pKeywordExceptionHandling);
	AddDefaultKeyword(@"__finally", pKeywordExceptionHandling);
	AddDefaultKeyword(@"__leave", pKeywordExceptionHandling);
	AddDefaultKeyword(@"__raise", pKeywordExceptionHandling);
	AddDefaultKeyword(@"finally", pKeywordExceptionHandling);

	// Type introspection/type traits
	AddDefaultKeyword(@"__alignof", pKeywordIntrospection);
	AddDefaultKeyword(@"sizeof", pKeywordIntrospection);
	AddDefaultKeyword(@"decltype", pKeywordIntrospection);
	AddDefaultKeyword(@"__uuidof", pKeywordIntrospection);
	AddDefaultKeyword(@"typeid", pKeywordIntrospection);

	// Static assert
	AddDefaultKeyword(@"static_assert", pKeywordStaticAssert);

	// Control statements
	AddDefaultKeyword(@"while", pKeywordControlStatement);
	AddDefaultKeyword(@"for", pKeywordControlStatement);
	AddDefaultKeyword(@"goto", pKeywordControlStatement);
	AddDefaultKeyword(@"if", pKeywordControlStatement);
	AddDefaultKeyword(@"do", pKeywordControlStatement);
	AddDefaultKeyword(@"break", pKeywordControlStatement);
	AddDefaultKeyword(@"case", pKeywordControlStatement);
	AddDefaultKeyword(@"continue", pKeywordControlStatement);
	AddDefaultKeyword(@"default", pKeywordControlStatement);
	AddDefaultKeyword(@"else", pKeywordControlStatement);
	AddDefaultKeyword(@"return", pKeywordControlStatement);
	AddDefaultKeyword(@"switch", pKeywordControlStatement);

	AddDefaultKeyword(@"likely", pKeywordControlStatement);
	AddDefaultKeyword(@"unlikely", pKeywordControlStatement);



	// Optimization
	AddDefaultKeyword(@"__asm", pKeywordOptimization);
	AddDefaultKeyword(@"__assume", pKeywordOptimization);

	// Property modifiers
	AddDefaultKeyword(@"__unaligned", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"__declspec", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"__based", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"deprecated", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"dllexport", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"dllimport", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"naked", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"noinline", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"noreturn", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"nothrow", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"noexcept", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"novtable", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"property", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"selectany", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"thread", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"uuid", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"explicit", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"__forceinline", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"__inline", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"inline", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"__cdecl", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"__thiscall", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"__fastcall", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"__stdcall", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"inline_small", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"inline_always", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"inline_never", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"inline_medium", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"inline_large", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"inline_extralarge", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"inline_always_debug", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"module_export", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"module_import", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"only_parameters_aliased", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"return_not_aliased", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"function_does_not_return", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"variable_not_aliased", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"constexpr", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"__pragma", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"__attribute__", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"__restrict__", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"assure_used", pKeywordPropertyModifiers);                
	AddDefaultKeyword(@"align_cacheline", pKeywordPropertyModifiers);                

	// new/delete operators
	AddDefaultKeyword(@"delete", pKeywordNewDelete);
	AddDefaultKeyword(@"new", pKeywordNewDelete);

	// CLR
	AddDefaultKeyword(@"__abstract", pKeywordCLR);
	AddDefaultKeyword(@"abstract", pKeywordCLR);
	AddDefaultKeyword(@"__box", pKeywordCLR);
	AddDefaultKeyword(@"__delegate", pKeywordCLR);
	AddDefaultKeyword(@"__gc", pKeywordCLR);
	AddDefaultKeyword(@"__hook", pKeywordCLR);
	AddDefaultKeyword(@"__nogc", pKeywordCLR);
	AddDefaultKeyword(@"__pin", pKeywordCLR);
	AddDefaultKeyword(@"__property", pKeywordCLR);
	AddDefaultKeyword(@"__sealed", pKeywordCLR);
	AddDefaultKeyword(@"__try_cast", pKeywordCLR);
	AddDefaultKeyword(@"__unhook", pKeywordCLR);
	AddDefaultKeyword(@"__value", pKeywordCLR);
	// AddDefaultKeyword(@"array", pKeywordCLR); // used in stdlib
	// AddDefaultKeyword(@"delegate", pKeywordCLR); // too generic
	AddDefaultKeyword(@"event", pKeywordCLR);
	AddDefaultKeyword(@"__identifier", pKeywordCLR);
	AddDefaultKeyword(@"friend_as", pKeywordCLR);
	AddDefaultKeyword(@"interface", pKeywordCLR);
	AddDefaultKeyword(@"interior_ptr", pKeywordCLR);
	AddDefaultKeyword(@"gcnew", pKeywordCLR);
	AddDefaultKeyword(@"generic", pKeywordCLR);
	AddDefaultKeyword(@"initonly", pKeywordCLR);
	AddDefaultKeyword(@"literal", pKeywordCLR);
	AddDefaultKeyword(@"ref", pKeywordCLR);
	AddDefaultKeyword(@"safecast", pKeywordCLR);
//	AddDefaultKeyword(@"value", pKeywordCLR); // used in stdlib

	// Other keywords
	AddDefaultKeyword(@"__event", pKeywordOther);
	AddDefaultKeyword(@"__if_exists", pKeywordOther);
	AddDefaultKeyword(@"__if_not_exists", pKeywordOther);
	AddDefaultKeyword(@"__interface", pKeywordOther);
	AddDefaultKeyword(@"__multiple_inheritance", pKeywordOther);
	AddDefaultKeyword(@"__single_inheritance", pKeywordOther);
	AddDefaultKeyword(@"__virtual_inheritance", pKeywordOther);
	AddDefaultKeyword(@"__super", pKeywordOther);
	AddDefaultKeyword(@"__noop", pKeywordOther);

	// Type specification keywords
	AddDefaultKeyword(@"union", pKeywordTypeSpecification);
	AddDefaultKeyword(@"class", pKeywordTypeSpecification);
	AddDefaultKeyword(@"enum", pKeywordTypeSpecification);
	AddDefaultKeyword(@"struct", pKeywordTypeSpecification);

	// namespace
	AddDefaultKeyword(@"namespace", pKeywordNamespace);

	// typename
	AddDefaultKeyword(@"typename", pKeywordTypename);

	// template
	AddDefaultKeyword(@"template", pKeywordTemplate);

	// typedef
	AddDefaultKeyword(@"typedef", pKeywordTypedef);

	// using
	AddDefaultKeyword(@"using", pKeywordUsing);

	// auto
	AddDefaultKeyword(@"auto", pKeywordAuto);

	// this
	AddDefaultKeyword(@"this", pKeywordThis);

	// operator
	AddDefaultKeyword(@"operator", pKeywordOperator);

	// Access keywords
	AddDefaultKeyword(@"friend", pKeywordAccess);
	AddDefaultKeyword(@"private", pKeywordAccess);
	AddDefaultKeyword(@"public", pKeywordAccess);
	AddDefaultKeyword(@"protected", pKeywordAccess);

	// Virtual keywords
	AddDefaultKeyword(@"final", pKeywordVirtual);
	AddDefaultKeyword(@"sealed", pKeywordVirtual);
	AddDefaultKeyword(@"override", pKeywordVirtual);
	AddDefaultKeyword(@"virtual", pKeywordVirtual);
	AddDefaultKeyword(@"pure", pKeywordPure);

	// casts
	AddDefaultKeyword(@"const_cast", pKeywordCasts);
	AddDefaultKeyword(@"dynamic_cast", pKeywordCasts);
	AddDefaultKeyword(@"reinterpret_cast", pKeywordCasts);
	AddDefaultKeyword(@"static_cast", pKeywordCasts);

	// ignore
	AddDefaultKeyword(@"ignore", CreateColor(0x707070));

	NSColor *pPreprocessorDirective = CreateColor(0xFFFFFF);
	// Preprocessor directive
	AddDefaultKeyword(@"#define", pPreprocessorDirective);
	AddDefaultKeyword(@"#error", pPreprocessorDirective);
	AddDefaultKeyword(@"#import", pPreprocessorDirective);
	AddDefaultKeyword(@"#undef", pPreprocessorDirective);
	AddDefaultKeyword(@"#elif", pPreprocessorDirective);
	AddDefaultKeyword(@"#if", pPreprocessorDirective);
	AddDefaultKeyword(@"#include", pPreprocessorDirective);
	AddDefaultKeyword(@"#using", pPreprocessorDirective);
	AddDefaultKeyword(@"#else", pPreprocessorDirective);
	AddDefaultKeyword(@"#ifdef", pPreprocessorDirective);
	AddDefaultKeyword(@"#line", pPreprocessorDirective);
	AddDefaultKeyword(@"#endif", pPreprocessorDirective);
	AddDefaultKeyword(@"#ifndef", pPreprocessorDirective);
	AddDefaultKeyword(@"#pragma", pPreprocessorDirective);

	AddDefaultKeyword(@"define", pPreprocessorDirective);
	AddDefaultKeyword(@"error", pPreprocessorDirective);
	AddDefaultKeyword(@"import", pPreprocessorDirective);
	AddDefaultKeyword(@"undef", pPreprocessorDirective);
	AddDefaultKeyword(@"elif", pPreprocessorDirective);
	//AddDefaultKeyword(@"if", pPreprocessorDirective);
	AddDefaultKeyword(@"include", pPreprocessorDirective);
	AddDefaultKeyword(@"using", pPreprocessorDirective);
	//AddDefaultKeyword(@"else", pPreprocessorDirective);
	AddDefaultKeyword(@"ifdef", pPreprocessorDirective);
	AddDefaultKeyword(@"line", pPreprocessorDirective);
	AddDefaultKeyword(@"endif", pPreprocessorDirective);
	AddDefaultKeyword(@"ifndef", pPreprocessorDirective);
	AddDefaultKeyword(@"pragma", pPreprocessorDirective);

	// std lib
	AddDefaultKeyword(@"std", pNamespace);
	AddDefaultKeyword(@"atomic", pTemplateType);
	AddDefaultKeyword(@"set", pTemplateType);
	AddDefaultKeyword(@"multiset", pTemplateType);
	AddDefaultKeyword(@"map", pTemplateType);
	AddDefaultKeyword(@"multimap", pTemplateType);
	AddDefaultKeyword(@"unordered_set", pTemplateType);
	AddDefaultKeyword(@"unordered_multiset", pTemplateType);
	AddDefaultKeyword(@"unordered_map", pTemplateType);
	AddDefaultKeyword(@"unordered_multimap", pTemplateType);
	AddDefaultKeyword(@"list", pTemplateType);
	AddDefaultKeyword(@"vector", pTemplateType);
	AddDefaultKeyword(@"queue", pTemplateType);
	AddDefaultKeyword(@"priority_queue", pTemplateType);
	AddDefaultKeyword(@"forward_list", pTemplateType);
	AddDefaultKeyword(@"deque", pTemplateType);
	AddDefaultKeyword(@"array", pTemplateType);
	AddDefaultKeyword(@"stack", pTemplateType);
	AddDefaultKeyword(@"basic_ifstream", pTemplateType);
	AddDefaultKeyword(@"basic_ofstream", pTemplateType);
	AddDefaultKeyword(@"basic_fstream", pTemplateType);
	AddDefaultKeyword(@"basic_filebuf", pTemplateType);
	AddDefaultKeyword(@"basic_string", pTemplateType);
	AddDefaultKeyword(@"char_traits", pTemplateType);
	AddDefaultKeyword(@"tuple", pTemplateType);
	AddDefaultKeyword(@"pair", pTemplateType);

	AddDefaultKeyword(@"string", pType);
	AddDefaultKeyword(@"u16string", pType);
	AddDefaultKeyword(@"u32string", pType);
	AddDefaultKeyword(@"wstring", pType);
	AddDefaultKeyword(@"ifstream", pType);
	AddDefaultKeyword(@"ofstream", pType);
	AddDefaultKeyword(@"fstream", pType);
	AddDefaultKeyword(@"filebuf", pType);
	AddDefaultKeyword(@"wifstream", pType);
	AddDefaultKeyword(@"wofstream", pType);
	AddDefaultKeyword(@"wfstream", pType);
	AddDefaultKeyword(@"wfilebuf", pType);
	AddDefaultKeyword(@"atomic_flag", pType);
	AddDefaultKeyword(@"iterator", pType);
	AddDefaultKeyword(@"const_iterator", pType);
	AddDefaultKeyword(@"value_type", pType);
	AddDefaultKeyword(@"allocator_type", pType);
	AddDefaultKeyword(@"type", pType);
	AddDefaultKeyword(@"reference", pType);
	AddDefaultKeyword(@"const_reference", pType);
	AddDefaultKeyword(@"pointer", pType);
	AddDefaultKeyword(@"const_pointer", pType);
	AddDefaultKeyword(@"reverse_iterator", pType);
	AddDefaultKeyword(@"const_reverse_iterator", pType);
	AddDefaultKeyword(@"difference_type", pType);
	AddDefaultKeyword(@"size_type", pType);
	AddDefaultKeyword(@"key_compare", pType);
	AddDefaultKeyword(@"value_compare", pType);
	AddDefaultKeyword(@"key_type", pType);
	AddDefaultKeyword(@"mapped_type", pType);
	AddDefaultKeyword(@"hasher", pType);
	AddDefaultKeyword(@"key_equal", pType);
	AddDefaultKeyword(@"local_iterator", pType);
	AddDefaultKeyword(@"const_local_iterator", pType);
	AddDefaultKeyword(@"char_type", pType);
	AddDefaultKeyword(@"traits_type", pType);
	AddDefaultKeyword(@"int_type", pType);
	AddDefaultKeyword(@"pos_type", pType);
	AddDefaultKeyword(@"off_type", pType);
	AddDefaultKeyword(@"state_type", pType);
	

	AddDefaultKeyword(@"length", pMemberFunctionPublic);
	AddDefaultKeyword(@"fill", pMemberFunctionPublic);
	AddDefaultKeyword(@"data", pMemberFunctionPublic);
	AddDefaultKeyword(@"size", pMemberFunctionPublic);
	AddDefaultKeyword(@"empty", pMemberFunctionPublic);
	AddDefaultKeyword(@"max_size", pMemberFunctionPublic);
	AddDefaultKeyword(@"at", pMemberFunctionPublic);
	AddDefaultKeyword(@"insert", pMemberFunctionPublic);
	AddDefaultKeyword(@"erase", pMemberFunctionPublic);
	AddDefaultKeyword(@"clear", pMemberFunctionPublic);
	AddDefaultKeyword(@"emplace", pMemberFunctionPublic);
	AddDefaultKeyword(@"emplace_hint", pMemberFunctionPublic);
	AddDefaultKeyword(@"key_comp", pMemberFunctionPublic);
	AddDefaultKeyword(@"value_comp", pMemberFunctionPublic);
	AddDefaultKeyword(@"find", pMemberFunctionPublic);
	AddDefaultKeyword(@"count", pMemberFunctionPublic);
	AddDefaultKeyword(@"lower_bound", pMemberFunctionPublic);
	AddDefaultKeyword(@"upper_bound", pMemberFunctionPublic);
	AddDefaultKeyword(@"equal_range", pMemberFunctionPublic);
	AddDefaultKeyword(@"get_allocator", pMemberFunctionPublic);
	AddDefaultKeyword(@"front", pMemberFunctionPublic);
	AddDefaultKeyword(@"back", pMemberFunctionPublic);
	AddDefaultKeyword(@"push", pMemberFunctionPublic);
	AddDefaultKeyword(@"pop", pMemberFunctionPublic);
	AddDefaultKeyword(@"top", pMemberFunctionPublic);
	AddDefaultKeyword(@"assign", pMemberFunctionPublic);
	AddDefaultKeyword(@"emplace_front", pMemberFunctionPublic);
	AddDefaultKeyword(@"emplace_back", pMemberFunctionPublic);
	AddDefaultKeyword(@"push_front", pMemberFunctionPublic);
	AddDefaultKeyword(@"push_back", pMemberFunctionPublic);
	AddDefaultKeyword(@"pop_front", pMemberFunctionPublic);
	AddDefaultKeyword(@"pop_back", pMemberFunctionPublic);
	AddDefaultKeyword(@"resize", pMemberFunctionPublic);
	AddDefaultKeyword(@"splice", pMemberFunctionPublic);
	AddDefaultKeyword(@"remove", pMemberFunctionPublic);
	AddDefaultKeyword(@"remove_if", pMemberFunctionPublic);
	AddDefaultKeyword(@"unique", pMemberFunctionPublic);
	AddDefaultKeyword(@"merge", pMemberFunctionPublic);
	AddDefaultKeyword(@"sort", pMemberFunctionPublic);
	AddDefaultKeyword(@"reverse", pMemberFunctionPublic);
	AddDefaultKeyword(@"before_begin", pMemberFunctionPublic);
	AddDefaultKeyword(@"cbefore_begin", pMemberFunctionPublic);
	AddDefaultKeyword(@"emplace_after", pMemberFunctionPublic);
	AddDefaultKeyword(@"insert_after", pMemberFunctionPublic);
	AddDefaultKeyword(@"erase_after", pMemberFunctionPublic);
	AddDefaultKeyword(@"splice_after", pMemberFunctionPublic);
	AddDefaultKeyword(@"shrink_to_fit", pMemberFunctionPublic);
	AddDefaultKeyword(@"bucket_count", pMemberFunctionPublic);
	AddDefaultKeyword(@"bucket_size", pMemberFunctionPublic);
	AddDefaultKeyword(@"bucket", pMemberFunctionPublic);
	AddDefaultKeyword(@"max_bucket_count", pMemberFunctionPublic);
	AddDefaultKeyword(@"load_factor", pMemberFunctionPublic);
	AddDefaultKeyword(@"max_load_factor", pMemberFunctionPublic);
	AddDefaultKeyword(@"rehash", pMemberFunctionPublic);
	AddDefaultKeyword(@"reserve", pMemberFunctionPublic);
	AddDefaultKeyword(@"hash_fuction", pMemberFunctionPublic);
	AddDefaultKeyword(@"key_eq", pMemberFunctionPublic);
	AddDefaultKeyword(@"capacity", pMemberFunctionPublic);
	AddDefaultKeyword(@"c_str", pMemberFunctionPublic);
	AddDefaultKeyword(@"find", pMemberFunctionPublic);
	AddDefaultKeyword(@"rfind", pMemberFunctionPublic);
	AddDefaultKeyword(@"copy", pMemberFunctionPublic);
	AddDefaultKeyword(@"find_first_of", pMemberFunctionPublic);
	AddDefaultKeyword(@"find_last_of", pMemberFunctionPublic);
	AddDefaultKeyword(@"find_first_not_of", pMemberFunctionPublic);
	AddDefaultKeyword(@"fint_last_not_of", pMemberFunctionPublic);
	AddDefaultKeyword(@"substr", pMemberFunctionPublic);
	AddDefaultKeyword(@"compare", pMemberFunctionPublic);

	AddDefaultKeyword(@"memory_order", pEnum);
	AddDefaultKeyword(@"memory_order_relaxed", pEnumerator);
	AddDefaultKeyword(@"memory_order_consume", pEnumerator);
	AddDefaultKeyword(@"memory_order_acquire", pEnumerator);
	AddDefaultKeyword(@"memory_order_release", pEnumerator);
	AddDefaultKeyword(@"memory_order_acq_rel", pEnumerator);
	AddDefaultKeyword(@"memory_order_seq_cst", pEnumerator);
	
	AddDefaultKeyword(@"is_lock_free", pMemberFunctionPublic);
	AddDefaultKeyword(@"store", pMemberFunctionPublic);
	AddDefaultKeyword(@"load", pMemberFunctionPublic);
	AddDefaultKeyword(@"exchange", pMemberFunctionPublic);
	AddDefaultKeyword(@"compare_exchange_weak", pMemberFunctionPublic);
	AddDefaultKeyword(@"compare_exchange_strong", pMemberFunctionPublic);
	AddDefaultKeyword(@"fetch_add", pMemberFunctionPublic);
	AddDefaultKeyword(@"fetch_sub", pMemberFunctionPublic);
	AddDefaultKeyword(@"fetch_and", pMemberFunctionPublic);
	AddDefaultKeyword(@"fetch_or", pMemberFunctionPublic);
	AddDefaultKeyword(@"fetch_xor", pMemberFunctionPublic);

	AddDefaultKeyword(@"tie", pFunction);
	AddDefaultKeyword(@"make_tuple", pFunction);
	AddDefaultKeyword(@"forward_as_tuple", pFunction);
	AddDefaultKeyword(@"tuple_cat", pFunction);

	AddDefaultKeyword(@"npos", pMemberConstantPublic);
	AddDefaultKeyword(@"value", pMemberConstantPublic);
	AddDefaultKeyword(@"getline", pFunction);
	AddDefaultKeyword(@"min", pFunction);
	AddDefaultKeyword(@"max", pFunction);
	AddDefaultKeyword(@"assert", pMacro);
	
	AddDefaultKeyword(@"integral_constant", pTemplateType);
	AddDefaultKeyword(@"true_type", pType);
	AddDefaultKeyword(@"false_type", pType);

	AddDefaultKeyword(@"is_array", pTemplateType);
	AddDefaultKeyword(@"is_class", pTemplateType);
	AddDefaultKeyword(@"is_enum", pTemplateType);
	AddDefaultKeyword(@"is_floating_point", pTemplateType);
	AddDefaultKeyword(@"is_function", pTemplateType);
	AddDefaultKeyword(@"is_integral", pTemplateType);
	AddDefaultKeyword(@"is_lvalue_reference", pTemplateType);
	AddDefaultKeyword(@"is_member_function_pointer", pTemplateType);
	AddDefaultKeyword(@"is_member_object_pointer", pTemplateType);
	AddDefaultKeyword(@"is_pointer", pTemplateType);
	AddDefaultKeyword(@"is_rvalue_reference", pTemplateType);
	AddDefaultKeyword(@"is_union", pTemplateType);
	AddDefaultKeyword(@"is_void", pTemplateType);

	AddDefaultKeyword(@"is_arithmetic", pTemplateType);
	AddDefaultKeyword(@"is_compound", pTemplateType);
	AddDefaultKeyword(@"is_fundamental", pTemplateType);
	AddDefaultKeyword(@"is_member_pointer", pTemplateType);
	AddDefaultKeyword(@"is_object", pTemplateType);
	AddDefaultKeyword(@"is_reference", pTemplateType);
	AddDefaultKeyword(@"is_scalar", pTemplateType);

	AddDefaultKeyword(@"is_abstract", pTemplateType);
	AddDefaultKeyword(@"is_const", pTemplateType);
	AddDefaultKeyword(@"is_empty", pTemplateType);
	AddDefaultKeyword(@"is_literal_type", pTemplateType);
	AddDefaultKeyword(@"is_pod", pTemplateType);
	AddDefaultKeyword(@"is_polymorphic", pTemplateType);
	AddDefaultKeyword(@"is_signed", pTemplateType);
	AddDefaultKeyword(@"is_standard_layout", pTemplateType);
	AddDefaultKeyword(@"is_trivial", pTemplateType);
	AddDefaultKeyword(@"is_trivially_copyable", pTemplateType);
	AddDefaultKeyword(@"is_unsigned", pTemplateType);
	AddDefaultKeyword(@"is_volatile", pTemplateType);

	AddDefaultKeyword(@"has_virtual_destructor", pTemplateType);
	AddDefaultKeyword(@"is_assignable", pTemplateType);
	AddDefaultKeyword(@"is_constructible", pTemplateType);
	AddDefaultKeyword(@"is_copy_assignable", pTemplateType);
	AddDefaultKeyword(@"is_copy_constructible", pTemplateType);
	AddDefaultKeyword(@"is_destructible", pTemplateType);
	AddDefaultKeyword(@"is_default_constructible", pTemplateType);
	AddDefaultKeyword(@"is_move_assignable", pTemplateType);
	AddDefaultKeyword(@"is_move_constructible", pTemplateType);
	AddDefaultKeyword(@"is_trivially_assignable", pTemplateType);
	AddDefaultKeyword(@"is_trivially_constructible", pTemplateType);
	AddDefaultKeyword(@"is_trivially_copy_assignable", pTemplateType);
	AddDefaultKeyword(@"is_trivially_copy_constructible", pTemplateType);
	AddDefaultKeyword(@"is_trivially_destructible", pTemplateType);
	AddDefaultKeyword(@"is_trivially_default_constructible", pTemplateType);
	AddDefaultKeyword(@"is_trivially_move_assignable", pTemplateType);
	AddDefaultKeyword(@"is_trivially_move_constructible", pTemplateType);
	AddDefaultKeyword(@"is_nothrow_assignable", pTemplateType);
	AddDefaultKeyword(@"is_nothrow_constructible", pTemplateType);
	AddDefaultKeyword(@"is_nothrow_copy_assignable", pTemplateType);
	AddDefaultKeyword(@"is_nothrow_copy_constructible", pTemplateType);
	AddDefaultKeyword(@"is_nothrow_destructible", pTemplateType);
	AddDefaultKeyword(@"is_nothrow_default_constructible", pTemplateType);
	AddDefaultKeyword(@"is_nothrow_move_assignable", pTemplateType);
	AddDefaultKeyword(@"is_nothrow_move_constructible", pTemplateType);

	AddDefaultKeyword(@"is_base_of", pTemplateType);
	AddDefaultKeyword(@"is_convertible", pTemplateType);
	AddDefaultKeyword(@"is_same", pTemplateType);

	AddDefaultKeyword(@"alignment_of", pTemplateType);
	AddDefaultKeyword(@"extent", pTemplateType);
	AddDefaultKeyword(@"rank", pTemplateType);


	AddDefaultKeyword(@"add_const", pTemplateType);
	AddDefaultKeyword(@"add_cv", pTemplateType);
	AddDefaultKeyword(@"add_volatile", pTemplateType);
	AddDefaultKeyword(@"remove_const", pTemplateType);
	AddDefaultKeyword(@"remove_cv", pTemplateType);
	AddDefaultKeyword(@"remove_volatile", pTemplateType);

	AddDefaultKeyword(@"add_pointer", pTemplateType);
	AddDefaultKeyword(@"add_lvalue_reference", pTemplateType);
	AddDefaultKeyword(@"add_rvalue_reference", pTemplateType);
	AddDefaultKeyword(@"decay", pTemplateType);
	AddDefaultKeyword(@"make_signed", pTemplateType);
	AddDefaultKeyword(@"make_unsigned", pTemplateType);
	AddDefaultKeyword(@"remove_all_extents", pTemplateType);
	AddDefaultKeyword(@"remove_extent", pTemplateType);
	AddDefaultKeyword(@"remove_pointer", pTemplateType);
	AddDefaultKeyword(@"remove_reference", pTemplateType);
	AddDefaultKeyword(@"underlying_type", pTemplateType);

	AddDefaultKeyword(@"aligned_storage", pTemplateType);
	AddDefaultKeyword(@"aligned_union", pTemplateType);
	AddDefaultKeyword(@"common_type", pTemplateType);
	AddDefaultKeyword(@"conditional", pTemplateType);
	AddDefaultKeyword(@"enable_if", pTemplateType);
	AddDefaultKeyword(@"result_of", pTemplateType);

	
	AddDefaultKeyword(@"make_pair", pFunction);
	AddDefaultKeyword(@"forward", pFunction);
	AddDefaultKeyword(@"move", pFunction);
	AddDefaultKeyword(@"move_if_noexcept", pFunction);
	AddDefaultKeyword(@"declval", pFunction);
	
	AddDefaultKeyword(@"bind", pFunction);
	AddDefaultKeyword(@"function", pTemplateType);
	
	AddDefaultKeyword(@"allocator", pTemplateType);
	AddDefaultKeyword(@"auto_ptr_ref", pTemplateType);
	AddDefaultKeyword(@"shared_ptr", pTemplateType);
	AddDefaultKeyword(@"weak_ptr", pTemplateType);
	AddDefaultKeyword(@"unique_ptr", pTemplateType);
	AddDefaultKeyword(@"default_delete", pTemplateType);
	
	AddDefaultKeyword(@"make_shared", pFunction);
	AddDefaultKeyword(@"allocate_shared", pFunction);
	AddDefaultKeyword(@"static_pointer_cast", pFunction);
	AddDefaultKeyword(@"dynamic_pointer_cast", pFunction);
	AddDefaultKeyword(@"const_pointer_cast", pFunction);
	AddDefaultKeyword(@"get_deleter", pFunction);

	AddDefaultKeyword(@"owner_less", pTemplateType);
	AddDefaultKeyword(@"enable_shared_from_this", pTemplateType);
	
	AddDefaultKeyword(@"CFStr", pType);
	AddDefaultKeyword(@"CFWStr", pType);
	AddDefaultKeyword(@"CFUStr", pType);
	
	AddDefaultKeyword(@"str_utf8", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"str_utf16", pKeywordPropertyModifiers);
	AddDefaultKeyword(@"str_utf32", pKeywordPropertyModifiers);

#if 0
	// Let's not pollute the namespace here
	AddDefaultKeyword(@"event_callback", pType_Function);
	AddDefaultKeyword(@"failure", pMemberFunctionPublic);
	AddDefaultKeyword(@"fmtflags", pEnum);
	AddDefaultKeyword(@"iostate", pEnum);
	AddDefaultKeyword(@"openmode", pEnum);
	AddDefaultKeyword(@"seekdir", pEnum);
	AddDefaultKeyword(@"sentry", pMemberFunctionPublic);

	AddDefaultKeyword(@"open", pMemberFunctionPublic);
	AddDefaultKeyword(@"is_open", pMemberFunctionPublic);
	AddDefaultKeyword(@"close", pMemberFunctionPublic);
	AddDefaultKeyword(@"rdbuf", pMemberFunctionPublic);

	AddDefaultKeyword(@"gcount", pMemberFunctionPublic);
	AddDefaultKeyword(@"getline", pMemberFunctionPublic);
	AddDefaultKeyword(@"peek", pMemberFunctionPublic);
	AddDefaultKeyword(@"read", pMemberFunctionPublic);
	AddDefaultKeyword(@"readsome", pMemberFunctionPublic);
	AddDefaultKeyword(@"putback", pMemberFunctionPublic);
	AddDefaultKeyword(@"unget", pMemberFunctionPublic);
	AddDefaultKeyword(@"tellg", pMemberFunctionPublic);
	AddDefaultKeyword(@"seekg", pMemberFunctionPublic);
	AddDefaultKeyword(@"sync", pMemberFunctionPublic);

	AddDefaultKeyword(@"good", pMemberFunctionPublic);
	AddDefaultKeyword(@"eof", pMemberFunctionPublic);
	AddDefaultKeyword(@"fail", pMemberFunctionPublic);
	AddDefaultKeyword(@"bad", pMemberFunctionPublic);
	AddDefaultKeyword(@"rdstate", pMemberFunctionPublic);
	AddDefaultKeyword(@"setstate", pMemberFunctionPublic);
	AddDefaultKeyword(@"copyfmt", pMemberFunctionPublic);
	AddDefaultKeyword(@"exceptions", pMemberFunctionPublic);
	AddDefaultKeyword(@"imbue", pMemberFunctionPublic);
	AddDefaultKeyword(@"tie", pMemberFunctionPublic);
	AddDefaultKeyword(@"rdbuf", pMemberFunctionPublic);
	AddDefaultKeyword(@"narrow", pMemberFunctionPublic);
	AddDefaultKeyword(@"widen", pMemberFunctionPublic);

	AddDefaultKeyword(@"flags", pMemberFunctionPublic);
	AddDefaultKeyword(@"setf", pMemberFunctionPublic);
	AddDefaultKeyword(@"unsetf", pMemberFunctionPublic);
	AddDefaultKeyword(@"precision", pMemberFunctionPublic);
	AddDefaultKeyword(@"width", pMemberFunctionPublic);
	AddDefaultKeyword(@"imbue", pMemberFunctionPublic);
	AddDefaultKeyword(@"getloc", pMemberFunctionPublic);
	AddDefaultKeyword(@"xalloc", pMemberFunctionPublic);
	AddDefaultKeyword(@"iword", pMemberFunctionPublic);
	AddDefaultKeyword(@"pword", pMemberFunctionPublic);
	AddDefaultKeyword(@"register_callback", pMemberFunctionPublic);
	AddDefaultKeyword(@"sync_with_stdio", pMemberFunctionPublic);
	
	AddDefaultKeyword(@"begin", pFunction);
	AddDefaultKeyword(@"end", pFunction);
	AddDefaultKeyword(@"rbegin", pFunction);
	AddDefaultKeyword(@"rend", pFunction);
	AddDefaultKeyword(@"cbegin", pFunction);
	AddDefaultKeyword(@"cend", pFunction);
	AddDefaultKeyword(@"crbegin", pFunction);
	AddDefaultKeyword(@"crend", pFunction);
	AddDefaultKeyword(@"swap", pFunction);
	AddDefaultKeyword(@"get", pFunction);
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

+ (void) pluginDidLoad: (NSBundle*)plugin
{
	// Singleton instance

	XCFixinPreflight();

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
		[pValidConceptCharacters addCharactersInString:@"bcfinp"];
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

	XCFixinPostflight();
}

@end


