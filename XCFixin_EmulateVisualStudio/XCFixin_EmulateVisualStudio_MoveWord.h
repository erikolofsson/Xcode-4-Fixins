
__attribute((swiftcall)) void (*g_fSourceEditor_SourceEditorView_clearSelectionAnchors)(id __attribute__((swift_context)) _pContext);
void Call_SourceEditor_SourceEditorView_clearSelectionAnchors(id _pSourceView)
{
	if (!g_fSourceEditor_SourceEditorView_clearSelectionAnchors)
		g_fSourceEditor_SourceEditorView_clearSelectionAnchors = fg_GetLocalSymbol("SourceEditor.framework/Versions/A/SourceEditor", "__T012SourceEditor0aB4ViewC21clearSelectionAnchorsyyF");

	return g_fSourceEditor_SourceEditorView_clearSelectionAnchors(_pSourceView);
}

__attribute((swiftcall)) void (*g_fSourceEditor_SourceEditorView_selectTextRange)(struct CSourceEditorRange *_pRange, void *_pScrollPlacement, int64_t _bAlwaysScroll, id __attribute__((swift_context)) _pContext);
__attribute((noinline)) void Call_SourceEditor_SourceEditorView_selectTextRange(id _pSourceView, struct CSourceEditorRange *_pRange, void *_pScrollPlacement, bool _bAlwaysScroll)
{
	_pRange->dummy1 = 0;
	_pRange->dummy2 = 0;
	if (!g_fSourceEditor_SourceEditorView_selectTextRange)
		g_fSourceEditor_SourceEditorView_selectTextRange = fg_GetLocalSymbol("SourceEditor.framework/Versions/A/SourceEditor", "__T012SourceEditor0aB4ViewC15selectTextRangeyAA0abF0VSg_AA15ScrollPlacementOSg06scrollH0Sb06alwaysG0tF");

	g_fSourceEditor_SourceEditorView_selectTextRange(_pRange, _pScrollPlacement, _bAlwaysScroll, _pSourceView);
}

// __T012SourceEditor0aB4ViewC06deleteA5RangeyAA0abE0V5range_Sb7forwardSb11useKillRingtF
// _SourceEditor.SourceEditorView.deleteSourceRange(range: SourceEditor.SourceEditorRange, forward: Swift.Bool, useKillRing: Swift.Bool) -> ()

__attribute((swiftcall)) void (*g_fSourceEditor_SourceEditorView_deleteSourceRange)(struct CSourceEditorRangeRet _Range, bool _bForward, bool _bUseKillRing, id __attribute__((swift_context)) _pContext);
__attribute((noinline)) void Call_SourceEditor_SourceEditorView_deleteSourceRange(id _pSourceView, struct CSourceEditorRangeRet _Range, bool _bForward, bool _bUseKillRing)
{
	if (!g_fSourceEditor_SourceEditorView_deleteSourceRange)
		g_fSourceEditor_SourceEditorView_deleteSourceRange = fg_GetLocalSymbol("SourceEditor.framework/Versions/A/SourceEditor", "__T012SourceEditor0aB4ViewC06deleteA5RangeyAA0abE0V5range_Sb7forwardSb11useKillRingtF");

	g_fSourceEditor_SourceEditorView_deleteSourceRange(_Range, _bForward, _bUseKillRing, _pSourceView);
}

// __T012SourceEditor0aB13LayoutManagerC19expandRangeIfNeededAA0abF0VAFF
// _SourceEditor.SourceEditorLayoutManager.expandRangeIfNeeded(SourceEditor.SourceEditorRange) -> SourceEditor.SourceEditorRange

__attribute((swiftcall)) struct CSourceEditorRangeRet (*g_fSourceEditor_SourceEditorLayoutManager_expandRangeIfNeeded)(struct CSourceEditorRangeRet range, id __attribute__((swift_context)) _pContext);
__attribute((noinline)) struct CSourceEditorRangeRet Call_SourceEditor_SourceEditorLayoutManager_expandRangeIfNeeded(id _pLayoutManager, struct CSourceEditorRangeRet range)
{
	if (!g_fSourceEditor_SourceEditorLayoutManager_expandRangeIfNeeded)
		g_fSourceEditor_SourceEditorLayoutManager_expandRangeIfNeeded = fg_GetLocalSymbol("SourceEditor.framework/Versions/A/SourceEditor", "__T012SourceEditor0aB13LayoutManagerC19expandRangeIfNeededAA0abF0VAFF");

	struct CSourceEditorRangeRet Ret = g_fSourceEditor_SourceEditorLayoutManager_expandRangeIfNeeded(range, _pLayoutManager);
	return Ret;
}

// - (void) moveWordForward:(id) arg1;
__attribute((noinline)) static void SourceEditor_SourceEditorView_moveWordForward(SourceCodeEditorView * self_, SEL _cmd, id arg1)
{
	[XCFixinEmulateVisualStudio moveWordForward: self_ arg1: arg1];
}

__attribute((noinline)) static void SourceEditor_SourceEditorView_moveWordForwardAndModifySelection(SourceCodeEditorView * self_, SEL _cmd, id arg1)
{
	[XCFixinEmulateVisualStudio moveWordForwardAndModifySelection: self_ arg1: arg1 arg2: _cmd];
}

__attribute((noinline)) void Call_SourceEditor_SourceEditorView_moveWordForwardAndModifySelection(id self_, id arg1, SEL _cmd)
{
	((void (*)(id, SEL, id))original_SourceEditor_SourceEditorView_moveWordForwardAndModifySelection)(self_, _cmd, arg1);
}

// - (void) moveWordForward:(id) arg1;
__attribute((noinline)) static void SourceEditor_SourceEditorView_moveWordBackward(SourceCodeEditorView * self_, SEL _cmd, id arg1)
{
	[XCFixinEmulateVisualStudio moveWordBackward: self_ arg1: arg1];
}

__attribute((noinline)) static void SourceEditor_SourceEditorView_moveWordBackwardAndModifySelection(SourceCodeEditorView * self_, SEL _cmd, id arg1)
{
	[XCFixinEmulateVisualStudio moveWordBackwardAndModifySelection: self_ arg1: arg1 arg2: _cmd];
}

__attribute((noinline)) void Call_SourceEditor_SourceEditorView_moveWordBackwardAndModifySelection(id self_, id arg1, SEL _cmd)
{
	((void (*)(id, SEL, id))original_SourceEditor_SourceEditorView_moveWordBackwardAndModifySelection)(self_, _cmd, arg1);
}

__attribute((noinline)) static void SourceEditor_SourceEditorView_deleteWordForward(SourceCodeEditorView * self_, SEL _cmd, id arg1)
{
	[XCFixinEmulateVisualStudio deleteWordForward: self_ arg1: arg1];
}

__attribute((noinline)) static void SourceEditor_SourceEditorView_deleteWordBackward(SourceCodeEditorView * self_, SEL _cmd, id arg1)
{
	[XCFixinEmulateVisualStudio deleteWordBackward: self_ arg1: arg1];
}


/*
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

				unsigned long start;

				if (selectedRange.location == lineRange.location || selectedRange.location > lineRange.location + codeStartRange.location)
					start = lineRange.location + codeStartRange.location;
				else
					start = lineRange.location;

				unsigned long end;
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
					unsigned long temp = end;
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

*/
