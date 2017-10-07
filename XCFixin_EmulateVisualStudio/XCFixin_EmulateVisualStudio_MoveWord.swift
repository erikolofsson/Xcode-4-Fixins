import Foundation

func == (lhs: CPosition, rhs: CPosition) -> Bool {
	return lhs.column == rhs.column && lhs.line == rhs.line
}

func < (lhs: CPosition, rhs: CPosition) -> Bool {
	if (lhs.line < rhs.line) {
		return true
	}
	else if (lhs.line > rhs.line) {
		return false
	}
	return lhs.column < rhs.column
}

func > (lhs: CPosition, rhs: CPosition) -> Bool {
	if (lhs.line > rhs.line) {
		return true
	}
	else if (lhs.line < rhs.line) {
		return false
	}
	return lhs.column > rhs.column
}

func binarySearchLine(_ lineData: [SourceEditor.SourceEditorLineData], characterPos: Int) -> Int {
	var lowerBound = 0
	var upperBound = lineData.count
	var iIter = 0;
	while lowerBound < upperBound {
		iIter += 1;
		let midIndex = lowerBound + (upperBound - lowerBound) / 2
		if lineData[midIndex].lineContentRange.location == characterPos {
			return midIndex
		} else if lineData[midIndex].lineContentRange.location < characterPos {
			lowerBound = midIndex + 1
		} else {
			upperBound = midIndex
		}
	}
	return upperBound
}

func getCodeCharSet() -> CharacterSet {
	let AlphaNumericSpace = CharacterSet.alphanumerics;
	var CodeCharSet = CharacterSet();
	CodeCharSet.formUnion(AlphaNumericSpace)
	CodeCharSet.insert(charactersIn: "_")
	return CodeCharSet;
}

let g_WhiteSpace = CharacterSet.whitespaces;
let g_NewLine = CharacterSet.newlines;
let g_CodeCharSet = getCodeCharSet();

func positionFromCharPos(_ dataSource: SourceEditor.SourceEditorDataSource, _ charPos: Int) -> CPosition {
	let iLine: Int = max(binarySearchLine(dataSource.lineData, characterPos: charPos) - 1, 0);

	for iSearch in iLine..<(iLine + 3) {
		let lineContentRange = dataSource.lineData[iSearch].lineContentRange;
		if (charPos >= lineContentRange.location) && (charPos <= (lineContentRange.location + lineContentRange.length)) {
			return CPosition(line: Int64(iSearch), column: Int64(charPos - lineContentRange.location));
		}
	}

	abort()
}

func charPosFromPosition(_ dataSource: SourceEditor.SourceEditorDataSource, _ pos: CPosition) -> Int {
	let lineData = dataSource.lineData[Int(pos.line)];
	return lineData.lineContentRange.location + Int(pos.column);
}

func getNextWordPosition(_ dataSource: SourceEditor.SourceEditorDataSource, fromPos: CPosition) -> CPosition {
	let contents = dataSource.contents;

	var iCharPos = charPosFromPosition(dataSource, fromPos);

	let nCharacters = contents.length;

	// Move to end of word
	if (iCharPos < nCharacters)
	{
		let StartChar = Unicode.Scalar(contents.character(at: iCharPos))!
		if (g_CodeCharSet.contains(StartChar))
		{
			while (iCharPos < nCharacters)
			{
				if (!g_CodeCharSet.contains(Unicode.Scalar(contents.character(at: iCharPos))!)) {
					break
				}
				iCharPos += 1
			}
		}
		else if (!g_WhiteSpace.contains(StartChar))
		{
			if (iCharPos < nCharacters) {
				iCharPos += 1
			}
		}

		// Move over any white space
		while (iCharPos < nCharacters)
		{
			if (!g_WhiteSpace.contains(Unicode.Scalar(contents.character(at: iCharPos))!)) {
				break
			}
			iCharPos += 1
		}
	}

	if (iCharPos > nCharacters) {
		iCharPos = nCharacters;
	}

	return positionFromCharPos(dataSource, iCharPos);
}

func getPrevWordPosition(_ dataSource: SourceEditor.SourceEditorDataSource, fromPos: CPosition) -> CPosition {
	let contents = dataSource.contents;

	var iCharPos = charPosFromPosition(dataSource, fromPos);

	let nCharacters = contents.length;

	if (iCharPos > 0) {
		iCharPos -= 1;
	}

	var StartChar = Unicode.Scalar(contents.character(at: iCharPos))!;

	if (g_NewLine.contains(StartChar))
	{
		if (iCharPos > 0)
		{
			if (StartChar == "\n")
			{
				iCharPos -= 1;
				StartChar = Unicode.Scalar(contents.character(at: iCharPos))!;
				if (StartChar == "\r")
				{
					iCharPos -= 1;
					StartChar = Unicode.Scalar(contents.character(at: iCharPos))!;
				}
			}
			else if (StartChar == "\r")
			{
				iCharPos -= 1;
				StartChar = Unicode.Scalar(contents.character(at: iCharPos))!;
			}
		}
	}

	while (iCharPos > 0)
	{
		StartChar = Unicode.Scalar(contents.character(at: iCharPos))!;

		if (!g_WhiteSpace.contains(StartChar)) {
			break;
		}
		iCharPos -= 1;
	}

	if (g_NewLine.contains(StartChar))
	{
		if (iCharPos < nCharacters) {
			iCharPos += 1;
		}
	}
	else
	{
		// Move to beginning of word
		if (g_CodeCharSet.contains(StartChar))
		{
			while (iCharPos > 0)
			{
				StartChar = Unicode.Scalar(contents.character(at: iCharPos))!;

				if (!g_CodeCharSet.contains(StartChar))
				{
					if (iCharPos < nCharacters) {
						iCharPos += 1;
					}
					break;
				}
				iCharPos -= 1;
			}
		}
	}

	if (iCharPos < 0) {
		iCharPos = 0;
	}

	return positionFromCharPos(dataSource, iCharPos);
}

@objc public class XCFixinEmulateVisualStudio : NSObject {

	class func moveWord(_ sourceView: IDEPegasusSourceEditor.SourceCodeEditorView, forward: Bool) {
		if (sourceView.selection == nil) {
			return;
		}

		var position = CPosition();

		if (sourceView.selectionController == nil || sourceView.selectionController!.selectionAnchor == nil) {
			position = CPosition(line: Int64(sourceView.selection!.range.start.line), column: Int64(sourceView.selection!.range.start.col));
		} else {
			let anchor = CPosition(line: Int64(sourceView.selectionController!.selectionAnchor!.start.line), column: Int64(sourceView.selectionController!.selectionAnchor!.start.col));
			let startPosition = CPosition(line: Int64(sourceView.selection!.range.start.line), column: Int64(sourceView.selection!.range.start.col));
			let endPosition = CPosition(line: Int64(sourceView.selection!.range.end.line), column: Int64(sourceView.selection!.range.end.col));

			if (startPosition == anchor) {
				position = endPosition
			} else {
				position = startPosition
			}
			Call_SourceEditor_SourceEditorView_clearSelectionAnchors(sourceView);
		}

		var newPosition : CPosition = CPosition();
		if (forward) {
			newPosition = getNextWordPosition(sourceView.structuredEditingController!.dataSource!, fromPos: position);
		} else {
			newPosition = getPrevWordPosition(sourceView.structuredEditingController!.dataSource!, fromPos: position);
		}

		var range : CSourceEditorRange = CSourceEditorRange(start: newPosition, end: newPosition, dummy1: 0, dummy2: 0);

		Call_SourceEditor_SourceEditorView_selectTextRange(sourceView, &range, nil, false);
	}

	class func deleteWord(_ sourceView: IDEPegasusSourceEditor.SourceCodeEditorView, forward: Bool) {
		if (sourceView.selection == nil) {
			return;
		}
		let selection = sourceView.selection!;

		var position = CPosition();

		if (sourceView.selectionController == nil || sourceView.selectionController!.selectionAnchor == nil) {
			position = CPosition(line: Int64(sourceView.selection!.range.start.line), column: Int64(sourceView.selection!.range.start.col));
		} else {
			let anchor = CPosition(line: Int64(sourceView.selectionController!.selectionAnchor!.start.line), column: Int64(sourceView.selectionController!.selectionAnchor!.start.col));
			let startPosition = CPosition(line: Int64(selection.range.start.line), column: Int64(selection.range.start.col));
			let endPosition = CPosition(line: Int64(selection.range.end.line), column: Int64(selection.range.end.col));

			if (startPosition == anchor) {
				position = endPosition
			} else {
				position = startPosition
			}
			Call_SourceEditor_SourceEditorView_clearSelectionAnchors(sourceView);
		}

		var newPosition : CPosition = CPosition();
		if (forward) {
			newPosition = getNextWordPosition(sourceView.structuredEditingController!.dataSource!, fromPos: position);
		} else {
			newPosition = getPrevWordPosition(sourceView.structuredEditingController!.dataSource!, fromPos: position);
		}

		var range : CSourceEditorRangeRet = CSourceEditorRangeRet();

		if (newPosition == position) {
			return;
		}

		if (newPosition > position) {
			range.start = position
			range.end = newPosition
		} else {
			range.start = newPosition
			range.end = position
		}

		let fixedRange = Call_SourceEditor_SourceEditorLayoutManager_expandRangeIfNeeded(sourceView.layoutManager, range);

		Call_SourceEditor_SourceEditorView_deleteSourceRange(sourceView, fixedRange, false, false);
	}

	class func moveWordAndModifySelection(_ sourceView: IDEPegasusSourceEditor.SourceCodeEditorView, arg1 : Any, arg2: Selector, forward: Bool) {
		if (sourceView.selection == nil) {
			return;
		}

		var position = CPosition();
		var bPositionSet = false;

		if (sourceView.selectionController == nil) {
			position = CPosition(line: Int64(sourceView.selection!.range.start.line), column: Int64(sourceView.selection!.range.start.col));
			bPositionSet = true
			Call_SourceEditor_SourceEditorView_moveWordForwardAndModifySelection(sourceView, arg1, arg2);
			if (sourceView.selectionController == nil) {
				return;
			}
		}
		if (sourceView.selectionController!.selectionAnchor == nil) {
			position = CPosition(line: Int64(sourceView.selection!.range.start.line), column: Int64(sourceView.selection!.range.start.col));
			bPositionSet = true
			Call_SourceEditor_SourceEditorView_moveWordForwardAndModifySelection(sourceView, arg1, arg2);
			if (sourceView.selectionController!.selectionAnchor == nil) {
				return
			}
		}

		if (sourceView.structuredEditingController?.dataSource == nil) {
			return
		}

		let anchor = CPosition(line: Int64(sourceView.selectionController!.selectionAnchor!.start.line), column: Int64(sourceView.selectionController!.selectionAnchor!.start.col));
		let startPosition = CPosition(line: Int64(sourceView.selection!.range.start.line), column: Int64(sourceView.selection!.range.start.col));
		let endPosition = CPosition(line: Int64(sourceView.selection!.range.end.line), column: Int64(sourceView.selection!.range.end.col));

		if (!bPositionSet) {
			if (startPosition == anchor) {
				position = endPosition
			} else {
				position = startPosition
			}
		}

		var newPosition : CPosition = CPosition();
		if (forward) {
			newPosition = getNextWordPosition(sourceView.structuredEditingController!.dataSource!, fromPos: position);
		} else {
			newPosition = getPrevWordPosition(sourceView.structuredEditingController!.dataSource!, fromPos: position);
		}

		var range : CSourceEditorRange = CSourceEditorRange();
		if (newPosition > anchor) {
			range.start = anchor
			range.end = newPosition
		} else {
			range.start = newPosition
			range.end = anchor
		}

		Call_SourceEditor_SourceEditorView_selectTextRange(sourceView, &range, nil, false);
	}

	@objc public class func moveWordForward(_ sourceView: IDEPegasusSourceEditor.SourceCodeEditorView, arg1 : Any) {
		return moveWord(sourceView, forward: true);
	}

	@objc public class func moveWordBackward(_ sourceView: IDEPegasusSourceEditor.SourceCodeEditorView, arg1 : Any) {
		return moveWord(sourceView, forward: false);
	}

	@objc public class func moveWordBackwardAndModifySelection(_ sourceView: IDEPegasusSourceEditor.SourceCodeEditorView, arg1 : Any, arg2: Selector) {
		return moveWordAndModifySelection(sourceView, arg1: arg1, arg2: arg2, forward: false)
	}

	@objc public class func moveWordForwardAndModifySelection(_ sourceView: IDEPegasusSourceEditor.SourceCodeEditorView, arg1 : Any, arg2: Selector) {
		return moveWordAndModifySelection(sourceView, arg1: arg1, arg2: arg2, forward: true)
	}

	@objc public class func deleteWordForward(_ sourceView: IDEPegasusSourceEditor.SourceCodeEditorView, arg1 : Any) {
		return deleteWord(sourceView, forward: true);
	}

	@objc public class func deleteWordBackward(_ sourceView: IDEPegasusSourceEditor.SourceCodeEditorView, arg1 : Any) {
		return deleteWord(sourceView, forward: false);
	}

}
