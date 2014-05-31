#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#include "../Shared Code/XCFixin.h"
#import "../Shared Code/Xcode5/DVTKit/DVTSourceTextView.h"
#import "../Shared Code/Xcode5/DVTKit/DVTTextStorage.h"
#import "../Shared Code/Xcode5/DVTKit/DVTFontAndColorTheme.h"
#import "../Shared Code/Xcode5/DVTFoundation/DVTSourceNodeTypes.h"
#import "../Shared Code/Xcode5/DVTFoundation/DVTSourceModelItem.h"
#import "../Shared Code/Xcode5/DVTFoundation/DVTSourceCodeLanguage.h"
#import "../Shared Code/Xcode5/DVTFoundation/DVTLanguageSpecification.h"
#import "../Shared Code/Xcode5/Plugins/IDESourceEditor/IDESourceCodeEditor.h"


static IMP original_colorAtCharacterIndex = nil;

@interface XCFixin_Highlight : NSObject
@end

@implementation XCFixin_Highlight

//-----------------------------------------------------------------------------------------------
- (id) init {
//-----------------------------------------------------------------------------------------------
  self = [super init];
  if (self) {

    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver: self
                           selector: @selector( applicationReady: )
                               name: NSApplicationDidFinishLaunchingNotification
                             object: nil];

    [notificationCenter addObserver: self
                           selector: @selector( frameChanged: )
                               name: NSViewFrameDidChangeNotification
                             object: nil];

    [notificationCenter addObserver: self
                           selector: @selector( selectionChanged: )
                               name: NSTextViewDidChangeSelectionNotification
                             object: nil];
  }
  return self;
}

//-----------------------------------------------------------------------------------------------
- (void) dealloc {
//-----------------------------------------------------------------------------------------------
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//static DVTTextStorage *textStorage;
//static NSTextView *textView;

- (void) updateTextView {
/*	textView = XCFixinFindIDETextView(NO);

	if (textView)
	{
		//DVTSourceTextView *dvtTextView = (DVTSourceTextView *)textView;
		//NSLog(@"%s: textView = %@", __FUNCTION__, dvtTextView);
		textStorage = (DVTTextStorage *)[textView textStorage];
		//NSLog(@"%s: textStorage = %@", __FUNCTION__, textStorage);
	}
	else
		textStorage = nil;*/
}


//-----------------------------------------------------------------------------------------------
- (void) applicationReady:(NSNotification*)notification {
	[self updateTextView];
}

//-----------------------------------------------------------------------------------------------
- (void) frameChanged:(NSNotification*)notification {
	[self updateTextView];
}

//-----------------------------------------------------------------------------------------------
- (void) selectionChanged:(NSNotification*)notification {
	[self updateTextView];
}

static id highlighter = nil;

static BOOL MatchVariablePrefix(NSString* _pIdentifier, NSString* _pToMatch)
{
	if (![_pIdentifier hasPrefix:_pToMatch])
		return false;
	
	NSUInteger MatchLength = [_pToMatch length];
	NSUInteger IdentLength = [_pIdentifier length];
	if (IdentLength == MatchLength)
		return false;
	
	unichar Character = [_pIdentifier characterAtIndex:MatchLength];
	
	if ([pUpperCaseChars characterIsMember:Character])
		return true;
	
	if (![pValidConceptCharacters characterIsMember:Character])
		return false;

	if (IdentLength == MatchLength + 1)
		return false;

	Character = [_pIdentifier characterAtIndex:MatchLength + 1];
	
	if ([pUpperCaseChars characterIsMember:Character])
		return true;
	
	return false;
}

static BOOL MatchOtherPrefix(NSString* _pIdentifier, NSString* _pToMatch)
{
	if ([_pIdentifier hasPrefix:_pToMatch] && [pUpperCaseChars characterIsMember:[_pIdentifier characterAtIndex:[_pToMatch length]]])
		return true;
	return false;
}

static NSColor* colorAtCharacterIndex(id self_, SEL _cmd, unsigned long long _Index, struct _NSRange *_pEffectiveRange, NSDictionary* _pContext)
{
	DVTTextStorage* textStorage = self_;
	DVTSourceCodeLanguage* pLanguage = [textStorage language];
	
	long long NodeType = [textStorage nodeTypeAtCharacterIndex:_Index effectiveRange:_pEffectiveRange context:_pContext];
	
	//NSColor* Ret = ((NSColor* (*)(id, SEL, unsigned long long, struct _NSRange *, id))original_colorAtCharacterIndex)(self_, _cmd, _Index, _pEffectiveRange, _pContext);
	if (pLanguage)
	{
		//double Time = CFAbsoluteTimeGetCurrent();

		NSString* pIdentifier = [pLanguage identifier];
		
		BOOL bSupportedLanguage = false;

		if ([pIdentifier compare:@"Xcode.SourceCodeLanguage.C-Plus-Plus"] == 0)
			bSupportedLanguage = true;
		else if ([pIdentifier compare:@"Xcode.SourceCodeLanguage.C"] == 0)
			bSupportedLanguage = true;
		else if ([pIdentifier compare:@"Xcode.SourceCodeLanguage.Objective-C-Plus-Plus"] == 0)
			bSupportedLanguage = true;
		else if ([pIdentifier compare:@"Xcode.SourceCodeLanguage.Objective-C"] == 0)
			bSupportedLanguage = true;
		
		if (!bSupportedLanguage)
		{
//			XCFixinLog(@"Language not supported: %@\n", pIdentifier);
			DVTFontAndColorTheme *pTheme = [textStorage fontAndColorTheme];
			return [pTheme colorForNodeType:NodeType];
		}

		static short CommentNodeType = -1;
		if (CommentNodeType == -1)
			CommentNodeType = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.comment"];
		static short CommentDocNodeType = -1;
		if (CommentDocNodeType == -1)
			CommentDocNodeType = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.comment.doc"];
		static short TypeIdentifier = -1;
		if (TypeIdentifier == -1)
			TypeIdentifier = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.identifier.type"];
		static short StringIdentifier = -1;
		if (StringIdentifier == -1)
			StringIdentifier = [DVTSourceNodeTypes registerNodeTypeNamed:@"xcode.syntax.string"];

		if (NodeType == CommentNodeType || NodeType == CommentDocNodeType || NodeType == StringIdentifier)
		{
			// Don't color comments or strings
			DVTFontAndColorTheme *pTheme = [textStorage fontAndColorTheme];
			return [pTheme colorForNodeType:NodeType];
		}
		
 		NSString *pString = [textStorage string];
		NSUInteger Length = [pString length];
		
		NSUInteger iChar = _Index;
		unichar Character = [pString characterAtIndex: iChar];
		
		if (_pEffectiveRange->location > 0 && _pEffectiveRange->location < iChar)
		{

			if ([pIdentifierCharacterSet characterIsMember:Character])
			{
				iChar = _pEffectiveRange->location;
				Character = [pString characterAtIndex: iChar];
				while (iChar < Length)
				{
					Character = [pString characterAtIndex: iChar];
					if ([pStartIdentifierCharacterSet characterIsMember:Character])
						break;
					++iChar;
				}
//				XCFixinLog(@"%@: %d\n", [DVTSourceNodeTypes nodeTypeNameForId:NodeType], Character);
			}
		}
/*		
		{
			NSRange Range = *_pEffectiveRange;
			NSString *pIdentifier = [pString substringWithRange: Range];
			XCFixinLog(@"%@: %@\n", [DVTSourceNodeTypes nodeTypeNameForId:NodeType], pIdentifier);
		}*/
		
		
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
				DVTFontAndColorTheme *pTheme = [textStorage fontAndColorTheme];
				return [pTheme colorForNodeType:NodeType];
			}
			else if ([pOperatorCharacters characterIsMember:Character])
			{
				
				NSUInteger iStart = iChar;
				++iChar;
				while (iChar < Length)
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

				//NSString *pIdentifier = [pString substringWithRange: Range];
				//XCFixinLog(@"%@: %@\n", pIdentifier, [DVTSourceNodeTypes nodeTypeNameForId:NodeType]);
				
				return pOperator;
			}
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

				//XCFixinLog(@"Parsed Identifier (%@): %f ms\n", pIdentifier, (CFAbsoluteTimeGetCurrent() - Time) * 1000.0);
				
				if (pColor)
				{
					*_pEffectiveRange = Range;
					return pColor;
				}

				NSUInteger Length = [pIdentifier length];
				if (Length >= 3)
				{
					if (Length >= 6)
					{
						if (MatchOtherPrefix(pIdentifier, @"tf_PF"))
						{
							*_pEffectiveRange = Range;
							return pFunctionTemplateTypeParam;
						}
						else if (MatchOtherPrefix(pIdentifier, @"fsgr_"))
						{
							*_pEffectiveRange = Range;
							return pStaticFunction;
						}
						else if (MatchOtherPrefix(pIdentifier, @"fspr_"))
						{
							// TODO: Figure out function private/protected
							*_pEffectiveRange = Range;
							return pMemberStaticFunctionPrivate;
							// return pMemberStaticFunctionProtected;
						}
						
					}
					if (Length >= 5)
					{
						if (MatchOtherPrefix(pIdentifier, @"tf_C") || MatchOtherPrefix(pIdentifier, @"tf_F"))
						{
							*_pEffectiveRange = Range;
							return pFunctionTemplateTypeParam;
						}
						else if (MatchOtherPrefix(pIdentifier, @"tf_T"))
						{
							*_pEffectiveRange = Range;
							return pFunctionTemplateTemplateParam;
						}
						else if (MatchOtherPrefix(pIdentifier, @"t_PF"))
						{
							*_pEffectiveRange = Range;
							return pTemplateTypeParam;
						}
						else if (MatchOtherPrefix(pIdentifier, @"fgr_"))
						{
							*_pEffectiveRange = Range;
							return pFunction;
						}
						else if (MatchOtherPrefix(pIdentifier, @"fsg_"))
						{
							*_pEffectiveRange = Range;
							return pStaticFunction;
						}
						else if (MatchOtherPrefix(pIdentifier, @"fpr_"))
						{
							// TODO: Figure out function private/protected
							*_pEffectiveRange = Range;
							return pMemberFunctionPrivate;
							// return pMemberFunctionProtected;
						}
						else if (MatchOtherPrefix(pIdentifier, @"fsp_"))
						{
							// TODO: Figure out function private/protected
							*_pEffectiveRange = Range;
							return pMemberStaticFunctionPrivate;
							// return pMemberStaticFunctionProtected;
						}
						else if (MatchOtherPrefix(pIdentifier, @"fsr_"))
						{
							*_pEffectiveRange = Range;
							return pMemberStaticFunctionPublic;
						}
						else if (MatchVariablePrefix(pIdentifier, @"msp_"))
						{
							*_pEffectiveRange = Range;
							return pMemberStaticVariablePrivate;
							// return pMemberStaticVariableProtected;
						}
						else if (MatchVariablePrefix(pIdentifier, @"mcp_"))
						{
							*_pEffectiveRange = Range;
							return pMemberConstantPrivate;
							// return pMemberConstantProtected;
						}
					}
					if (Length >= 4)
					{
						if (MatchOtherPrefix(pIdentifier, @"t_C") || MatchOtherPrefix(pIdentifier, @"t_F"))
						{
							*_pEffectiveRange = Range;
							return pTemplateTypeParam;
						}
						else if (MatchOtherPrefix(pIdentifier, @"t_T"))
						{
							*_pEffectiveRange = Range;
							return pTemplateTemplateParam;
						}
						else if (MatchVariablePrefix(pIdentifier, @"tf_"))
						{
							*_pEffectiveRange = Range;
							return pFunctionTemplateNonTypeParam;
						}
						else if (MatchOtherPrefix(pIdentifier, @"TIC"))
						{
							*_pEffectiveRange = Range;
							return pTemplateType;
						}
						else if (MatchOtherPrefix(pIdentifier, @"fg_"))
						{
							*_pEffectiveRange = Range;
							return pFunction;
						}
						else if (MatchOtherPrefix(pIdentifier, @"fp_"))
						{
							*_pEffectiveRange = Range;
							// TODO: Figure out function private/protected
							return pMemberFunctionPrivate;
							// return pMemberFunctionProtected;
						}
						else if (MatchOtherPrefix(pIdentifier, @"fr_"))
						{
							*_pEffectiveRange = Range;
							return pMemberFunctionPublic;
						}
						else if (MatchOtherPrefix(pIdentifier, @"fs_"))
						{
							*_pEffectiveRange = Range;
							return pMemberStaticFunctionPublic;
						}
						else if (MatchVariablePrefix(pIdentifier, @"mp_"))
						{
							*_pEffectiveRange = Range;
							return pMemberVariablePrivate;
							// return pMemberVariableProtected;
						}
						else if (MatchVariablePrefix(pIdentifier, @"ms_"))
						{
							*_pEffectiveRange = Range;
							return pMemberStaticVariablePublic;
						}
						else if (MatchVariablePrefix(pIdentifier, @"gs_"))
						{
							*_pEffectiveRange = Range;
							return pGlobalStaticVariable;
						}
						else if (MatchVariablePrefix(pIdentifier, @"mc_"))
						{
							*_pEffectiveRange = Range;
							return pMemberConstantPublic;
						}
						else if (MatchVariablePrefix(pIdentifier, @"gc_"))
						{
							*_pEffectiveRange = Range;
							return pGlobalConstant;
							// return pGlobalStaticConstant;
						}
					}

					if (MatchOtherPrefix(pIdentifier, @"TC"))
					{
						*_pEffectiveRange = Range;
						return pTemplateType;
					}
					else if (MatchOtherPrefix(pIdentifier, @"f_"))
					{
						*_pEffectiveRange = Range;
						return pMemberFunctionPublic;
					}
					else if (MatchOtherPrefix(pIdentifier, @"t_"))
					{
						*_pEffectiveRange = Range;
						return pTemplateNonTypeParam;
					}
					else if (MatchOtherPrefix(pIdentifier, @"d_"))
					{
						*_pEffectiveRange = Range;
						return pMacroParameter;
					}
					else if (MatchVariablePrefix(pIdentifier, @"m_"))
					{
						*_pEffectiveRange = Range;
						return pMemberVariablePublic;
					}
					else if (MatchVariablePrefix(pIdentifier, @"g_"))
					{
						*_pEffectiveRange = Range;
						return pGlobalVariable;
					}
					else if (MatchOtherPrefix(pIdentifier, @"IC") || MatchOtherPrefix(pIdentifier, @"PF"))
					{
						*_pEffectiveRange = Range;
						return pType;
					}
					else if (MatchOtherPrefix(pIdentifier, @"C") || MatchOtherPrefix(pIdentifier, @"F"))
					{
						*_pEffectiveRange = Range;
						return pType;
					}
					else if (MatchOtherPrefix(pIdentifier, @"N"))
					{
						*_pEffectiveRange = Range;
						return pNamespace;
					}
					else if (MatchOtherPrefix(pIdentifier, @"E"))
					{
						// XCFixinLog(@"Enum(%@): %@\n", pIdentifier, [DVTSourceNodeTypes nodeTypeNameForId:NodeType]);

						*_pEffectiveRange = Range;
						
						if (NodeType == TypeIdentifier)
							return pEnum;
						else
							return pEnumerator;
					}
					else if (MatchOtherPrefix(pIdentifier, @"D"))
					{
						*_pEffectiveRange = Range;
						return pMacro;
					}
					else if (MatchVariablePrefix(pIdentifier, @"_"))
					{
						*_pEffectiveRange = Range;
						return pFunctionParameter;
					}
					
				}
			}
		}
		
		//XCFixinLog(@"ParseTime: %f ms\n", (CFAbsoluteTimeGetCurrent() - Time) * 1000.0);
	}

	DVTFontAndColorTheme *pTheme = [textStorage fontAndColorTheme];
	return [pTheme colorForNodeType:NodeType];
}


static NSColor* pType = nil;
static NSColor* pNamespace = nil;
static NSColor* pTemplateTypeParam = nil;
static NSColor* pTemplateNonTypeParam = nil;
static NSColor* pTemplateTemplateParam = nil;
static NSColor* pFunctionTemplateTypeParam = nil;
static NSColor* pFunctionTemplateNonTypeParam = nil;
static NSColor* pFunctionTemplateTemplateParam = nil;
static NSColor* pTemplateType = nil;
static NSColor* pEnumerator = nil;
static NSColor* pFunctionParameter = nil;
static NSColor* pMacroParameter = nil;
static NSColor* pMemberFunctionPrivate = nil;
static NSColor* pMemberFunctionProtected = nil;
static NSColor* pMemberFunctionPublic = nil;
static NSColor* pMemberStaticFunctionPrivate = nil;
static NSColor* pMemberStaticFunctionProtected = nil;
static NSColor* pMemberStaticFunctionPublic = nil;
static NSColor* pMemberVariablePrivate = nil;
static NSColor* pMemberVariableProtected = nil;
static NSColor* pMemberVariablePublic = nil;
static NSColor* pMemberStaticVariablePrivate = nil;
static NSColor* pMemberStaticVariableProtected = nil;
static NSColor* pMemberStaticVariablePublic = nil;
static NSColor* pStaticFunction = nil;
static NSColor* pGlobalVariable = nil;
static NSColor* pGlobalStaticVariable = nil;
static NSColor* pMemberConstantPrivate = nil;
static NSColor* pMemberConstantProtected = nil;
static NSColor* pMemberConstantPublic = nil;
static NSColor* pGlobalConstant = nil;
static NSColor* pGlobalStaticConstant = nil;
static NSColor* pTypedef = nil;
static NSColor* pFunction = nil;
static NSColor* pEnum = nil;
static NSColor* pMacro = nil;
static NSColor* pOperator = nil;

static void AddDefaultKeyword(NSString* _pKeyword, NSColor* _pColor)
{
	[pDefaultKeywords setObject:_pColor forKey:_pKeyword];
}

static NSColor* CreateColor(unsigned int _Color)
{
	return [NSColor colorWithCalibratedRed:((_Color >> 0) & 0xFF)/255.0 green:((_Color >> 8) & 0xFF)/255.0 blue:((_Color >> 16) & 0xFF)/255.0 alpha:1.0];
}

static void AddDefaultKeywords()
{
	pDefaultKeywords = [[NSMutableDictionary alloc] init];
	
	pType = CreateColor(0x00FF9DA7);
	pNamespace = CreateColor(0x00CD9CA2);
	pTemplateTypeParam = CreateColor(0x00FF7987);
	pTemplateNonTypeParam = CreateColor(0x00AD5BFF);
	pTemplateTemplateParam = CreateColor(0x00FF7987);
	pFunctionTemplateTypeParam = CreateColor(0x00FFC6CB);
	pFunctionTemplateNonTypeParam = CreateColor(0x00DBB7FF);
	pFunctionTemplateTemplateParam = CreateColor(0x00FFC6CB);
	pTemplateType = CreateColor(0x00FF9DA7);
	pEnumerator = CreateColor(0x00C58AFF);
	pFunctionParameter = CreateColor(0x0000FFE6);
	pMacroParameter = CreateColor(0x0080BFFF);
	pMemberFunctionPrivate = CreateColor(0x0080D58A);
	pMemberFunctionProtected = CreateColor(0x0080D58A);
	pMemberFunctionPublic = CreateColor(0x0000FF26);
	pMemberStaticFunctionPrivate = CreateColor(0x0080D58A);
	pMemberStaticFunctionProtected = CreateColor(0x0080D58A);
	pMemberStaticFunctionPublic = CreateColor(0x0000FF26);
	pMemberVariablePrivate = CreateColor(0x00539DC6);
	pMemberVariableProtected = CreateColor(0x00539DC6);
	pMemberVariablePublic = CreateColor(0x0000A6FF);
	pMemberStaticVariablePrivate = CreateColor(0x00539DC6);
	pMemberStaticVariableProtected = CreateColor(0x00539DC6);
	pMemberStaticVariablePublic = CreateColor(0x0000A6FF);
	pStaticFunction = CreateColor(0x0000B91C);
	pGlobalVariable = CreateColor(0x000026FF);
	pGlobalStaticVariable = CreateColor(0x000026FF);
	pMemberConstantPrivate = CreateColor(0x00C5A8E1);
	pMemberConstantProtected = CreateColor(0x00C5A8E1);
	pMemberConstantPublic = CreateColor(0x00C58AFF);
	pGlobalConstant = CreateColor(0x00C58AFF);
	pGlobalStaticConstant = CreateColor(0x00C58AFF);
	pTypedef = CreateColor(0x00FF9DA7);
	pFunction = CreateColor(0x0000B91C);
	pEnum = CreateColor(0x00FF9DA7);
	pMacro = CreateColor(0x00097DFF);
	pOperator = CreateColor(0x00FFFFFF);
	
	NSColor* pKeywordBulitInTypes = CreateColor(0x006659FF);
	NSColor* pKeywordBulitInCharacterTypes = CreateColor(0x006659FF);
	NSColor* pKeywordBulitInIntegerTypes = CreateColor(0x006659FF);
	NSColor* pKeywordBulitInVectorTypes = CreateColor(0x006659FF);
	NSColor* pKeywordBulitInTypeModifiers = CreateColor(0x006659FF);
	NSColor* pKeywordBulitInFloatTypes = CreateColor(0x006659FF);
	NSColor* pKeywordBulitInConstants = CreateColor(0x00C58AFF);
	NSColor* pKeywordControlStatement = CreateColor(0x00FFFFFF);
	NSColor* pKeywordPropertyModifiers = CreateColor(0x00C0C0C0);
	NSColor* pKeywordStorageClass = CreateColor(0x00FFFFFF);
	NSColor* pKeywordExceptionHandling = CreateColor(0x00FFFFFF);
	NSColor* pKeywordIntrospection = CreateColor(0x00FFFFFF);
	NSColor* pKeywordStaticAssert = CreateColor(0x00FFFFFF);
	NSColor* pKeywordOptimization = CreateColor(0x00FFFFFF);
	NSColor* pKeywordNewDelete = CreateColor(0x00FFFFFF);
	NSColor* pKeywordCLR = CreateColor(0x00FFFFFF);
	NSColor* pKeywordOther = CreateColor(0x00FFFFFF);
	NSColor* pKeywordTypeSpecification = CreateColor(0x00FFFFFF);
	NSColor* pKeywordNamespace = CreateColor(0x00FFFFFF);
	NSColor* pKeywordTemplate = CreateColor(0x00FFFFFF);
	NSColor* pKeywordTypedef = CreateColor(0x00FFFFFF);
	NSColor* pKeywordUsing = CreateColor(0x00FFFFFF);
	NSColor* pKeywordAuto = CreateColor(0x00FFFFFF);
	NSColor* pKeywordThis = CreateColor(0x00FFFFFF);
	NSColor* pKeywordOperator = CreateColor(0x00FFFFFF);
	NSColor* pKeywordVirtual = CreateColor(0x00FFFFFF);
	NSColor* pKeywordCasts = CreateColor(0x00FFFFFF);
	NSColor* pKeywordTypename = CreateColor(0x00C0C0C0);
	NSColor* pKeywordAccess = CreateColor(0x00BEBED8);
	NSColor* pKeywordPure = CreateColor(0x00FFFFFF);
	NSColor* pKeywordQualifier = CreateColor(0x0080B6FF);
	
	
	
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
	AddDefaultKeyword(@"array", pKeywordCLR);
	AddDefaultKeyword(@"delegate", pKeywordCLR);
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
	AddDefaultKeyword(@"value", pKeywordCLR);

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
}

static NSMutableCharacterSet *pStartIdentifierCharacterSet = nil;
static NSMutableCharacterSet *pIdentifierCharacterSet = nil;
static NSMutableCharacterSet *pValidConceptCharacters = nil;
static NSMutableCharacterSet *pOperatorCharacters = nil;
static NSCharacterSet *pUpperCaseChars = nil;
static NSCharacterSet *pWhitespaceChars = nil;
static NSMutableDictionary *pDefaultKeywords = nil;

//-----------------------------------------------------------------------------------------------
+ (void) pluginDidLoad: (NSBundle*)plugin
//-----------------------------------------------------------------------------------------------
{
	// Singleton instance

	XCFixinPreflight();

	{
		pUpperCaseChars = [NSCharacterSet uppercaseLetterCharacterSet];
		pWhitespaceChars = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	}
	{
		pStartIdentifierCharacterSet = [[NSMutableCharacterSet alloc] init];
		[pStartIdentifierCharacterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
		[pStartIdentifierCharacterSet removeCharactersInString:@"0123456789"];
		[pStartIdentifierCharacterSet addCharactersInString:@"_"];
	}
	{
		pIdentifierCharacterSet = [[NSMutableCharacterSet alloc] init];
		[pIdentifierCharacterSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
		[pIdentifierCharacterSet addCharactersInString:@"_"];
	}
	{
		pValidConceptCharacters = [[NSMutableCharacterSet alloc] init];
		[pValidConceptCharacters addCharactersInString:@"bnihpf"];
	}
	{
		pOperatorCharacters = [[NSMutableCharacterSet alloc] init];
		[pOperatorCharacters addCharactersInString:@":;+-()[]{}<>!~*&.,/%=^|?"];
	}
	
	
	AddDefaultKeywords();
/*	
	{
		NSCharacterSet *pAlphaNumericSpace = [NSCharacterSet decimalDigitCharacterSet];
		pNumberCharacterSet = [[NSMutableCharacterSet alloc] init];
		[pNumberCharacterSet formUnionWithCharacterSet:pAlphaNumericSpace];
		[pNumberCharacterSet addCharactersInString:@"_"];
	}
	*/
	highlighter = [[XCFixin_Highlight alloc] init];

	if (!highlighter) {
		XCFixinLog(@"%s: highlighter init failed.\n",__FUNCTION__);
	}
	/*
	unsigned int outCount = 0;
	Method *pMethods = class_copyMethodList(NSClassFromString(@"DVTTextStorage"), &outCount);
	
	for (unsigned int i = 0; i < outCount; ++i)
	{
		XCFixinLog(@"Name: %s\n", sel_getName(method_getDescription(pMethods[i])->name));
	}

	*/
	
	original_colorAtCharacterIndex = XCFixinOverrideMethodString(@"DVTTextStorage", @selector(colorAtCharacterIndex: effectiveRange: context:), (IMP)&colorAtCharacterIndex);
	XCFixinAssertOrPerform(original_colorAtCharacterIndex, goto failed);

	XCFixinPostflight();
}

@end


