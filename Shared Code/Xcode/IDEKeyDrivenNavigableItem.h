//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

//
// SDK Root: /Developer/SDKs/MacOSX/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk.sdk
//

#import "IDENavigableItem.h"

@class NSDictionary;

@interface IDEKeyDrivenNavigableItem : IDENavigableItem
{
    NSDictionary *_cachedPropertyValues;
    struct {
        unsigned int _invalidatingChildItems:1;
        unsigned int _disposing:1;
        unsigned int _reserved:30;
    } _idekdniFlags;
}

+ (void)_customizeNewNavigableItemClass:(Class)arg1 forModelObjectClass:(Class)arg2 extension:(id)arg3;
+ (id)_automatic_keyPathsForValuesAffectingMajorGroup;
+ (id)keyPathsForValuesAffectingFileReference;
+ (id)keyPathsForValuesAffectingGroupIdentifier;
+ (id)keyPathsForValuesAffectingToolTip;
+ (id)keyPathsForValuesAffectingImage;
+ (id)keyPathsForValuesAffectingName;
+ (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
+ (unsigned long long)countOfNavigableItemsForRepresentedObject:(id)arg1;
+ (id)navigableItemsForRepresentedObject:(id)arg1;
+ (id)keyPathsForValuesAffectingConflictStateForUpdateOrMerge;
+ (id)keyPathsForValuesAffectingSourceControlCurrentRevision;
+ (id)keyPathsForValuesAffectingSourceControlLastModifiedDate;
+ (id)keyPathsForValuesAffectingSourceControlServerStatusFlag;
+ (id)keyPathsForValuesAffectingSourceControlServerStatus;
+ (id)keyPathsForValuesAffectingSourceControlLocalStatusFlag;
+ (id)keyPathsForValuesAffectingSourceControlLocalStatus;
+ (id)keyPathsForValuesAffectingProgressValue;
- (unsigned long long)indexOfChildItemForIdentifier:(id)arg1;
- (id)identifierForChildItem:(id)arg1;
- (BOOL)_automatic_isMajorGroup;
- (BOOL)isMajorGroup;
- (id)contentDocumentLocation;
- (id)documentType;
- (id)fileReference;
- (id)groupIdentifier;
- (id)toolTip;
- (id)image;
- (id)name;
- (void)_setRepresentedObject:(id)arg1;
- (void)invalidateValueForKey:(id)arg1;
- (id)cachedValueForProperty:(id)arg1;
- (void)cacheValue:(id)arg1 forProperty:(id)arg2;
- (id)cachedPropertyValues;
- (id)_cachedPropertyValues;
- (void)_configurePropertyObservingForKey:(id)arg1;
- (void)_propagateFilterPredicateToChildItems;
- (BOOL)isLeaf;
- (id)childRepresentedObjects;
- (id)_childItemsKeyPath;
- (id)childItemsKeyPath;
- (void)willAccessChildItems;
- (void)invalidateChildItems;
- (void)_refreshChildItem:(id)arg1;
- (void)_setCoordinator:(id)arg1;
- (void)primitiveInvalidate;
- (void)_removeFromNavigableItemByRepresentedObjectMap;
- (void)_registerInNavigableItemByRepresentedObjectMap;
- (BOOL)representedObjectSupportsVariableConformanceString;
- (id)initWithRepresentedObject:(id)arg1;
- (id)sourceControlSourceTreeName;
- (unsigned long long)conflictStateForUpdateOrMerge;
- (id)sourceControlCurrentRevision;
- (id)sourceControlLastModifiedDate;
- (id)sourceControlServerStatus;
- (int)sourceControlServerStatusFlag;
- (id)sourceControlLocalStatus;
- (int)sourceControlLocalStatusFlag;
- (long long)progressValue;

@end

