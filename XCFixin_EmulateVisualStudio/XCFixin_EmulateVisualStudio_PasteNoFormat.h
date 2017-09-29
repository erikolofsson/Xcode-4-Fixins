
//- (void) pasteAndPreserveFormatting:(id) arg1;
static void SourceEditor_SourceEditorView_pasteAndPreserveFormatting(IDEFindNavigatorScopeChooserController *self_, SEL _cmd, id arg1)
{
	((void (*)(id, SEL, id))original_SourceEditor_SourceEditorView_paste)(self_, _cmd, arg1);
}

// - (void) paste:(id) arg1;
static void SourceEditor_SourceEditorView_paste(IDEFindNavigatorScopeChooserController *self_, SEL _cmd, id arg1)
{
	((void (*)(id, SEL, id))original_SourceEditor_SourceEditorView_pasteAndPreserveFormatting)(self_, _cmd, arg1);
}
