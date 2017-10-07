extern "C" {
	#import "XCFixin.h"
}

#import <objc/runtime.h>
#import <Cocoa/Cocoa.h>
#include <string>

extern "C" NSArray<NSString *> *fg_SplitString(NSString *_pString, NSString *_pSeparator)
{
	std::string Input = _pString.UTF8String;

	char const *pParse = Input.c_str();
	char const *pParseStart = pParse;

	size_t nParen = 0;
	size_t nBracket = 0;
	size_t nSquareBracket = 0;

	NSMutableArray<NSString *> *pArray = [[NSMutableArray<NSString *> alloc] init];

	while (*pParse)
	{
		if (*pParse == '.' && !nParen && !nBracket && !nSquareBracket)
		{
			[pArray addObject: [NSString stringWithUTF8String: std::string{pParseStart, pParse}.c_str()]];
			++pParse;
			pParseStart = pParse;
			continue;
		}
		switch (*pParse)
		{
		case '<': ++nBracket; break;
		case '>': --nBracket; break;
		case '(': ++nParen; break;
		case ')': --nParen; break;
		case '[': ++nSquareBracket; break;
		case ']': --nSquareBracket; break;
		}
		++pParse;
	}

	if (pParseStart != pParse)
		[pArray addObject: [NSString stringWithUTF8String: std::string{pParseStart, pParse}.c_str()]];

    return pArray;
}

