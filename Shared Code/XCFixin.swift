
import Foundation
import ObjectiveC.runtime
import Swift
import Cocoa
import ObjectiveC

func unwrapOptional<T>(_ any: T) -> Any
{
	let mirrored = Mirror(reflecting:any)
	if (isValidOptional(any)) {
        return mirrored.children.first!.value
    }
    return any
}

func isImplicitlyUnwrappedOptional<T>(_ any: T) -> Bool
{
	let mirrored = Mirror(reflecting:any)
	if (mirrored.description.starts(with: "Mirror for ImplicitlyUnwrappedOptional<")) {
		return true;
	}
    return false
}

func isOptional<T>(_ any: T) -> Bool
{
	let mirrored = Mirror(reflecting:any)
	if (mirrored.description.starts(with: "Mirror for Optional<") || mirrored.description.starts(with: "Mirror for ImplicitlyUnwrappedOptional<")) {
		return true;
	}
    return false
}

func isValidOptional<T>(_ any: T) -> Bool
{
	let mirrored = Mirror(reflecting:any)
	if (isOptional(any) && mirrored.children.first != nil) {
        return true
    }
    return false
}

func isSet<T>(_ any: T) -> Bool
{
	let mirrored = Mirror(reflecting:any)
	if (mirrored.description.starts(with: "Mirror for Set<")) {
		return true;
	}
    return false
}

func isCollection<T>(_ any: T) -> Bool
{
	let mirrored = Mirror(reflecting:any)
	if
		(
			mirrored.description.starts(with: "Mirror for Collection<")
		)
	{
		return true;
	}
    return false
}

func isArray<T>(_ any: T) -> Bool
{
	let mirrored = Mirror(reflecting:any)
	if
		(
			mirrored.description.starts(with: "Mirror for Array<")
			|| mirrored.description.starts(with: "Mirror for _ArrayBuffer<")
		)
	{
		return true;
	}
    return false
}

func isTuple<T>(_ any: T) -> Bool
{
	let mirrored = Mirror(reflecting:any)
	if (mirrored.description.starts(with: "Mirror for Tuple<")) {
		return true;
	}
    return false
}

func isDictionary<T>(_ any: T) -> Bool
{
	let mirrored = Mirror(reflecting:any)
	if (mirrored.description.starts(with: "Mirror for Dictionary<")) {
		return true;
	}
    return false
}

class ExploreClass {
	var exploredTypes: Set<String> = [];
	var outputTypes: Set<String> = [];
	var definedSubclasses: Set<String> = [];
	var typesToExplore: Dictionary<String, Any> = [:];


	func typeName(_ mirror: Mirror) -> String {
		return fg_ExtractInType(String(reflecting: mirror.subjectType));
	}
	func typeNameObject(_ any: Any) -> String {
		return fg_ExtractInType(String(reflecting: type(of: any)));
	}

	func addValueToExplore(_ any : Any) {
		var value: Any;
		if (isOptional(any)) {
			if (!isValidOptional(any)) {
				return
			}
			value = unwrapOptional(any);
		} else {
			value = any
		}

		let childMirror = Mirror(reflecting: value);
		let displayStyle = childMirror.displayStyle;
		if displayStyle == nil {
			return
		}

		if (isSet(value)) {
			if value is Set<AnyHashable> {
				let unwrapped = (value as! Set<AnyHashable>);
				for item in unwrapped {
					addValueToExplore(item);
				}
			}
		}
		else if (isArray(value)) {
			if value is Array<Any> {
				let unwrapped = (value as! Array<Any>);
				for item in unwrapped {
					addValueToExplore(item);
				}
			}
		}
		else if (isCollection(value)) {
			let unwrapped = (value as! AnyCollection<Any>);
			for item in unwrapped {
				addValueToExplore(item);
			}
		}
		else if (isTuple(value)) {
			for (value) in Mirror(reflecting: value).children {
				addValueToExplore(value.value);
			}
		}
		else if (isDictionary(value)) {
			if value is Dictionary<AnyHashable, Any> {
				let unwrapped = value as! Dictionary<AnyHashable, Any>
				for item in unwrapped {
					addValueToExplore(item.key);
					addValueToExplore(item.value);
				}
			} else if value is Dictionary<String, Any> {
				let unwrapped = value as! Dictionary<String, Any>
				for item in unwrapped {
					addValueToExplore(item.key);
					addValueToExplore(item.value);
				}
			}
		}
		else
		{
			typesToExplore.updateValue(value, forKey: typeNameObject(value));
		}
	}

	func exploreInternal(mirror : Mirror)
	{
		if (mirror.displayStyle == nil) {
			return
		}

		var displayStyle = mirror.displayStyle!;

		if mirror.displayStyle! == .`enum` && mirror.children.first != nil {
			displayStyle = Mirror.DisplayStyle.`struct`;
		}

		var typeClass: String = "";
		switch displayStyle {
			case Mirror.DisplayStyle.`class` : typeClass = "class";
			case Mirror.DisplayStyle.`enum` : typeClass = "enum";
			case Mirror.DisplayStyle.`struct` : typeClass = "struct";
			default: return;
		}

		let name = typeName(mirror)

		if fg_IsBuiltinType(name) {
			return; // NS class
		}

		if outputTypes.contains(name) {
			return
		}
		outputTypes.update(with: name)

		print("// \(mirror.description)");

		let classes : [String] = fg_SplitString(name, ".");

		if (fg_IsBuiltinType(classes.first!)) {
			return;
		}

		var fullName = "";

		for subClass in classes {
			if (subClass == classes.last){
				break;
			}
			let parentName = fullName;
			if (!fullName.isEmpty) {
				fullName += ".";
			}
			fullName += subClass
			if definedSubclasses.contains(fullName) {
				continue
			}
			definedSubclasses.update(with: fullName)
			if (!parentName.isEmpty) {
				print("extension \(parentName) { ");
			}

			print("class \(subClass) { ");
			print("}");
			if (!parentName.isEmpty) {
				print("}");
			}
		}

		if (!fullName.isEmpty) {
			print("extension \(fullName) { ");
		}

		definedSubclasses.update(with: name)

		if (mirror.superclassMirror != nil) {
			//SwiftObject
			let parentMirror = mirror.superclassMirror!
			var parentName = typeName(parentMirror)
			if (parentName == name && parentMirror.superclassMirror != nil) {
				parentName = typeName(parentMirror.superclassMirror!)
			}
			if (parentName == name) {
				parentName = "NSObject"
			}
			if (parentName == "SwiftObject") {
				print("public \(typeClass) \(classes.last!) {");
			} else {
				print("public \(typeClass) \(classes.last!): \(parentName) {");
			}
		} else {
			print("\(typeClass) \(classes.last!) {");
		}

		if displayStyle == .`enum` {
			print("\tcase None")
			print("")
			print("\tinit() {")
			print("\t\tself = .None")
			print("\t}")
		} else {
			if displayStyle == .`struct` {
				print("\tinit() {")
				print("\t}")
			}
			for child in mirror.children {
				let type = typeNameObject(child.value);
				let varName = fg_FixVariableName(child.label ?? "----Unknown---");
				if type == "Bool" {
					print("    var \(varName!): \(type) = false;");
				} else if
					type == "Int"
						|| type == "UInt"
						|| type == "Int8"
						|| type == "Int16"
						|| type == "Int32"
						|| type == "Int64"
						|| type == "UInt8"
						|| type == "UInt16"
						|| type == "UInt32"
						|| type == "UInt64"
				{
					print("    var \(varName!): \(type) = 0;");
				} else if (!isOptional(child.value)) {
					print("    var \(varName!): \(type) = \(type)();");
				} else {
					print("    var \(varName!): \(type) = nil;");
				}

				addValueToExplore(child.value);
			}
		}

		if (!fullName.isEmpty) {
			print("}");
		}

		print("}");

		if (mirror.superclassMirror != nil) {
			exploreInternal(mirror: mirror.superclassMirror!)
		}
	}

	func explore<T>(item : T)
	{
		addValueToExplore(item);

		print("import Foundation")
		print("import Cocoa")
		print("import ObjectiveC.runtime")
		print("import Swift")
		print("import ObjectiveC")
		print("import Dispatch")


		while true {
			var newTypes: Dictionary<String, Any> = [:];
			for type in typesToExplore {
				if exploredTypes.contains(type.key) {
					continue
				}
				exploredTypes.update(with: type.key)
				newTypes.updateValue(type.value, forKey: type.key)
			}
			if newTypes.isEmpty {
				break;
			}
			for type in newTypes {
				exploreInternal(mirror: Mirror(reflecting: type.value))
			}
		}

		print("extension SourceEditor {");
		print("\tpublic class SourceEditorViewDelegate {}");
		print("\tpublic class TextFindPanel {}");
		print("\tpublic class TextFindResult {}");
		print("\tpublic class TextFindValue {}");
		print("\tpublic class LanguageServiceCodeCompletionStrategy {}");
		print("\tpublic class SourceEditorCodeCompletionController {}");
		print("\tpublic class SourceEditorSizableAssociatedView {}");
		print("\tpublic class SourceEditorViewContextualMenuItemProvider {}");
		print("\tpublic class SourceEditorViewStructuredSelectionDelegate {}");
		print("\tpublic class SourceEditorViewEventConsumer {}");
		print("\tpublic class SourceEditorViewDraggingExtension {}");
		print("\tpublic class CodeCoverageVisualization {}");
		print("\tpublic class LayoutVisualization {}");
		print("\tpublic class TextAttributeOverrideProvider {}");
		print("\tpublic class SourceEditorLineAnnotationInteractionDelegate {}");
		print("\tpublic class SourceEditorLineAnnotation {}");
		print("\tpublic class SourceEditorLineAnnotationDropdown {}");
		print("\tpublic class SourceEditorLineIdentifier: Hashable {public var hashValue: Int { return 0 }; public static func ==(lhs: SourceEditorLineIdentifier, rhs: SourceEditorLineIdentifier) -> Bool { return false; }}");

		print("\tpublic class SourceEditorFontTheme {}");
		print("\tpublic class SourceEditorColorTheme {}");
		print("\tpublic class TextFindableDisplayable {}");
		print("\tpublic class SourceEditorGutterInteractionDelegate {}");
		print("\tpublic class SourceEditorGutterAnnotationInteractionDelegate {}");
		print("\tpublic class SourceEditorVerticalAnchor {}");
		print("\tpublic class SourceEditorLayoutManagerDelegate {}");
		print("\tpublic class SourceEditorLayoutContainer {}");
		print("\tpublic class ShowInvisiblesTheme {}");
		print("\tpublic class InvisibleCharactersOverlayProvider {}");
		print("\tpublic class LineWrappingStyle {}");
		print("\tpublic class LineLayoutColumnShift {}");
		print("\tpublic class SourceEditorMarginAccessory {}");
		print("\tpublic class LayoutOverrideProvider {}");
		print("\tpublic class MultiCursorController {}");
		print("\tpublic class EditAssistantPostProcessOperation {}");
		print("\tpublic class EditAssistantPreProcessOperation {}");
		print("\tpublic class SourceCodeEditorDFRController {}");
		print("\tpublic class SourceCodeEditorSelectionObserver {}");
		print("\tpublic class SourceCodeMarkupView {}");
		print("\tpublic class StructuredSelectionActionMenuController {}");
		print("\tpublic class StructuredEditingDelegate {}");
		print("\tpublic class SelectionContext {}");
		print("\tpublic class SourceEditorSelectionModifiers {}");
		print("\tpublic class FoldingControllerDelegate {}");
		print("\tpublic class Fold {}");
		print("\tpublic class SelectionLayer {}");
		print("\tpublic class SourceEditorTextAttributeOverride {}");
		print("\tpublic class SourceEditorLineData {}");
		print("\tpublic class JournalRecord {}");
		print("\tpublic class SourceEditorDiagnostic {}");
		print("\tpublic class SourceEditorDiagnosticProvider {}");
		print("\tpublic class Landmark {}");
		print("\tpublic class SourceEditorTextualUndoType {}");
		print("\tpublic class UndoStackOperation {}");
		print("\tpublic class SourceEditorGutterAnnotation: Hashable {public var hashValue: Int { return 0 }; public static func ==(lhs: SourceEditorGutterAnnotation, rhs: SourceEditorGutterAnnotation) -> Bool { return false; }}");
		print("\tpublic class SourceEditorFontSmoothingTextLayer {}");
		print("\tpublic class SourceEditorDiagnosticProviderContext {}");
		print("\tpublic class SourceEditorRangeHighlight {}");
		print("\tpublic class InvisibleCharacterType: Hashable {public var hashValue: Int { return 0 }; public static func ==(lhs: InvisibleCharacterType, rhs: InvisibleCharacterType) -> Bool { return false; }}");
		print("\tpublic class LanguageServiceHostExtension {}");
		print("\tpublic class SourceEditorBuffer {}");
		print("\tpublic class LandmarkRangeResolvingDocument {}");
		print("\tpublic class AnnotationsAccessibilityGroup {}");
		print("\tpublic class SourceEditorLineAnnotationGroup {}");
		print("\tpublic class SourceEditorLineAnnotationView {}");
		print("\tpublic class SourceEditorLanguage {}");
		print("\tpublic class SourceEditorLanguageService {}");
		print("\tpublic class SourceEditorDataSourceObserverToken {}");
		print("\tpublic class SourceEditorDocumentSettings {}");
		print("\tpublic class SourceEditorDataSourceDelegate {}");
		print("\tpublic class LineHighlightLayer {}");
		print("\tpublic class SourceEditorLineAnnotationLayout {}");
		print("\tpublic class ContentGeneratingLanguageService {}");
		print("\tpublic class EditableRangeSnapshot {}");
		print("\tpublic class LanguageServiceContentGenerationCoordinator {}");
		print("\tpublic class StackEntry<T> {}");
		print("\tpublic class xxx {}");



		print("}");


		print("public class SourceCodeAdjustNodeTypesRequest {}");

		print("extension SourceEditorScrollView {");
		print("\tpublic class `Type` {}");
		print("}");

		print("extension SourceEditor.ContentGeneratingLanguageService {");
		print("\tpublic class `Type` {}");
		print("}");

		print("extension SourceEditor.SourceEditorSelectionDisplay {");
		print("\tpublic class TransientCursor {}");
		print("}");

		print("extension IDEPegasusSourceEditor.SourceCodeDocument {");
		print("\tpublic class GeneratedContentContext {}");
		print("}");

		print("extension SourceEditor.EditableRangeSnapshot {");
		print("\tpublic class `Type` {}");
		print("}");

		print("extension SourceEditor.RangePopLayoutVisualization {");
		print("\tpublic class RangePop {}");
		print("}");

		print("extension SourceEditor.SelectedSymbolHighlight {");
		print("\tpublic class SymbolHighlight {}");
		print("}");

		print("extension SourceEditor.SourceEditorViewDraggingSource {");
		print("\tpublic class SourceEditorViewDraggingSession {}");
		print("}");


		print("extension SourceModelSupport.SourceModelLanguageService {");
		print("\tpublic class `Type` {}");
		print("}");
		print("extension SourceModelSupport.SourceModelEditorLanguage {");
		print("\tpublic class `Type` {}");
		print("}");

		print("extension SourceEditor.SourceEditorGutterAnnotation {");
		print("\tpublic class Interaction {}");
		print("}");

		print("extension SourceEditor.SourceEditorGutterAnnotation.Interaction {");
		print("\tpublic class Intent {}");
		print("}");

		print("extension SourceEditor.SourceEditorLineAnnotation {");
		print("\tpublic class Interaction {}");
		print("}");

		print("extension SourceEditor.StructuredSelectionVisualization {");
		print("\tpublic class LozengeContext {}");
		print("}");

		print("extension IDEPegasusSourceEditor {");
		print("\tpublic class StaticAnalyzerStepVisualization {}");
		print("\tpublic class LandmarkRangeResolvingDocument {}");
		print("\tpublic class SourceCodeEditorDFRController {}");
		print("\tpublic class SourceCodeEditorSelectionObserver {}");
		print("\tpublic class SourceCodeMarkupView {}");
		print("\tpublic class StructuredSelectionActionMenuController {}");
		print("\tpublic class RenameOperation {}");

		print("}");

		print()
	}
}

@objc public class XCFixinSwiftReflector : NSObject {
	@objc public class func dumpObjectTypes(_ object : Any) {
		ExploreClass().explore(item: object)
	}
}
