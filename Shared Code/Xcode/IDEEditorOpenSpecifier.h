//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

//
// SDK Root: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX/Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//

#include "Shared.h"

@class DVTDocumentLocation, DVTFileDataType, DVTStackBacktrace, IDENavigableItemArchivableRepresentation, NSString, NSURL;

@interface IDEEditorOpenSpecifier : NSObject
{
    DVTStackBacktrace *_creationBacktrace;
    IDENavigableItemArchivableRepresentation *_archivableRepresentation;
    DVTDocumentLocation *_locationToSelect;
    NSURL *_documentURL;
    DVTFileDataType *_fileDataType;
    NSString *_documentExtensionIdentifier;
    id _annotationRepresentedObject;
    id _exploreAnnotationRepresentedObject;
    BOOL _annotationWantsIndicatorAnimation;
    BOOL _highlightSelection;
}

+ (id)structureEditorOpenSpecifierForDocumentURL:(id)arg1 inWorkspace:(id)arg2 annotationRepresentedObject:(id)arg3 wantsIndicatorAnimation:(BOOL)arg4 exploreAnnotationRepresentedObject:(id)arg5 error:(id *)arg6;
+ (id)structureEditorOpenSpecifierForDocumentLocation:(id)arg1 inWorkspace:(id)arg2 error:(id *)arg3;
+ (id)structureEditorOpenSpecifiersForNavigableItems:(id)arg1 inWorkspace:(id)arg2 error:(id *)arg3;
@property BOOL highlightSelection; // @synthesize highlightSelection=_highlightSelection;
@property(readonly) DVTFileDataType *fileDataType; // @synthesize fileDataType=_fileDataType;
@property(readonly) IDENavigableItemArchivableRepresentation *navigableItemRepresentation; // @synthesize navigableItemRepresentation=_archivableRepresentation;
@property(readonly) DVTDocumentLocation *locationToSelect; // @synthesize locationToSelect=_locationToSelect;
@property(readonly) NSString *documentExtensionIdentifier; // @synthesize documentExtensionIdentifier=_documentExtensionIdentifier;
@property(readonly) BOOL annotationWantsIndicatorAnimation; // @synthesize annotationWantsIndicatorAnimation=_annotationWantsIndicatorAnimation;
@property(readonly) id exploreAnnotationRepresentedObject; // @synthesize exploreAnnotationRepresentedObject=_exploreAnnotationRepresentedObject;
@property(readonly) id annotationRepresentedObject; // @synthesize annotationRepresentedObject=_annotationRepresentedObject;
// - (void).cxx_destruct;
- (id)initWithNavigableItemArchivableRepresentation:(id)arg1 documentExtensionIdentifier:(id)arg2 error:(id *)arg3;
- (id)initWithNavigableItemArchivableRepresentation:(id)arg1 locationToSelect:(id)arg2 error:(id *)arg3;
- (id)initWithNavigableItemArchivableRepresentation:(id)arg1 error:(id *)arg2;
- (id)initWithNavigableItem:(id)arg1 locationToSelect:(id)arg2 documentExtensionIdentifier:(id)arg3 error:(id *)arg4;
- (id)initWithNavigableItem:(id)arg1 documentExtensionIdentifier:(id)arg2 error:(id *)arg3;
- (id)initWithNavigableItem:(id)arg1 locationToSelect:(id)arg2 error:(id *)arg3;
- (id)initWithNavigableItem:(id)arg1 error:(id *)arg2;
- (id)_initWithNavigableItem:(id)arg1 locationToSelect:(id)arg2 documentExtensionIdentifier:(id)arg3 error:(id *)arg4;
- (id)_initWithNavigableItemArchivableRepresentation:(id)arg1 documentExtensionIdentifier:(id)arg2 locationToSelect:(id)arg3 annotationRepresentedObject:(id)arg4 wantsIndicatorAnimation:(BOOL)arg5 exploreAnnotationRepresentedObject:(id)arg6 error:(id *)arg7;
- (id)init;

@end

