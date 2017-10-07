
#ifndef XCFixin_EmulateVisualStudio_h
#define XCFixin_EmulateVisualStudio_h

#import "Xcode.h"
#import "../Shared Code/XCFixin.h"

void *fg_GetLocalSymbol(char const *_pImageName, char const *_pSymbolName);

struct CPosition
{
	int64_t line;
	int64_t column;
};

struct CSourceEditorRange
{
    struct CPosition start;
    struct CPosition end;
	int64_t dummy1;
	int64_t dummy2;
};

struct CSourceEditorRangeRet
{
    struct CPosition start;
    struct CPosition end;
};

void Call_SourceEditor_SourceEditorView_clearSelectionAnchors(id _pSourceView);
void Call_SourceEditor_SourceEditorView_selectTextRange(id _pSourceView, struct CSourceEditorRange *_pRange, void *_pScrollPlacement, bool _bAlwaysScroll);
void Call_SourceEditor_SourceEditorView_deleteSourceRange(id _pSourceView, struct CSourceEditorRangeRet _Range, bool _bForward, bool _bUseKillRing);
void Call_SourceEditor_SourceEditorView_moveWordForwardAndModifySelection(id self_, id arg1, SEL _cmd);
void Call_SourceEditor_SourceEditorView_moveWordBackwardAndModifySelection(id self_, id arg1, SEL _cmd);

struct CSourceEditorRangeRet Call_SourceEditor_SourceEditorLayoutManager_expandRangeIfNeeded(id _pLayoutManager, struct CSourceEditorRangeRet range);

#endif /* XCFixin_EmulateVisualStudio_h */
