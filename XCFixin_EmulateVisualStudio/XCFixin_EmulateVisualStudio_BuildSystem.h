
// - (id)evaluatedStringListValueForMacroNamed:(id)arg1;
static id evaluatedStringListValueForMacroNamed(DVTMacroExpansionScope *self_, SEL _Sel, NSString *_pMacroName)
{
	NSArray *pFlags = ((id(*)(id, SEL, id))original_evaluatedStringListValueForMacroNamed)(self_, _Sel, _pMacroName);

	if ([_pMacroName hasPrefix:@"OTHER_C"])
	{
		NSMutableDictionary *ThreadDict = [[NSThread currentThread] threadDictionary];
		PBXFileType *pFileType = ThreadDict[@"EmulateVisualStudio_FileType"];

		if (pFileType)
		{
			NSArray *pOnlyFlags = nil;
			if ([pFileType.identifier isEqualToString:@"sourcecode.c.c"])
				pOnlyFlags = ((id(*)(id, SEL, id))original_evaluatedStringListValueForMacroNamed)(self_, _Sel, @"OTHER_CFLAGS_ONLY");
			else if ([pFileType.identifier isEqualToString:@"sourcecode.c.objc"])
				pOnlyFlags = ((id(*)(id, SEL, id))original_evaluatedStringListValueForMacroNamed)(self_, _Sel, @"OTHER_OBJCFLAGS_ONLY");
			else if ([pFileType.identifier isEqualToString:@"sourcecode.cpp.cpp"])
				pOnlyFlags = ((id(*)(id, SEL, id))original_evaluatedStringListValueForMacroNamed)(self_, _Sel, @"OTHER_CPLUSPLUSFLAGS_ONLY");
			else if ([pFileType.identifier isEqualToString:@"sourcecode.cpp.objcpp"])
				pOnlyFlags = ((id(*)(id, SEL, id))original_evaluatedStringListValueForMacroNamed)(self_, _Sel, @"OTHER_OBJCPLUSPLUSFLAGS_ONLY");
			else if ([pFileType.identifier isEqualToString:@"sourcecode.asm"])
			{
				pOnlyFlags = ((id(*)(id, SEL, id))original_evaluatedStringListValueForMacroNamed)(self_, _Sel, @"OTHER_ASSEMBLERFLAGS_ONLY");
				if (!pOnlyFlags || [pOnlyFlags count] == 0)
                    pOnlyFlags = ((id(*)(id, SEL, id))original_evaluatedStringListValueForMacroNamed)(self_, _Sel, @"OTHER_CPLUSPLUSFLAGS_ONLY");
				if (!pOnlyFlags || [pOnlyFlags count] == 0)
					pOnlyFlags = ((id(*)(id, SEL, id))original_evaluatedStringListValueForMacroNamed)(self_, _Sel, @"OTHER_CFLAGS_ONLY");
				if (!pOnlyFlags || [pOnlyFlags count] == 0)
					pOnlyFlags = ((id(*)(id, SEL, id))original_evaluatedStringListValueForMacroNamed)(self_, _Sel, @"OTHER_OBJCPLUSPLUSFLAGS_ONLY");
				if (!pOnlyFlags || [pOnlyFlags count] == 0)
					pOnlyFlags = ((id(*)(id, SEL, id))original_evaluatedStringListValueForMacroNamed)(self_, _Sel, @"OTHER_OBJCFLAGS_ONLY");
			}
            else
            {
                NSLog(@"Unknown identifier: %@", pFileType.identifier);
            }

			if (pOnlyFlags)
			{
				if (pFlags)
				{
					NSMutableArray *pMutableArray = [NSMutableArray array];
					[pMutableArray addObjectsFromArray: pFlags];
					[pMutableArray addObjectsFromArray: pOnlyFlags];
					pFlags = pMutableArray;
				}
				else
					pFlags = pOnlyFlags;
			}
		}
        else
            NSLog(@"Unknown file type: %@", _pMacroName);

	}

	return pFlags;
}

// - (id)adjustedFileTypeForInputFileAtPath:(id)arg1 originalFileType:(id)arg2 withMacroExpansionScope:(id)arg3;
static id adjustedFileTypeForInputFileAtPath(XCCompilerSpecification *self_, SEL _Sel, id arg1, id arg2, id arg3)
{
	NSMutableDictionary *ThreadDict = [[NSThread currentThread] threadDictionary];
	ThreadDict[@"EmulateVisualStudio_FileType"] = arg2;

	id Ret = ((id(*)(id, SEL, id, id, id))original_adjustedFileTypeForInputFileAtPath)(self_, _Sel, arg1, arg2, arg3);

	[ThreadDict removeObjectForKey: @"EmulateVisualStudio_FileType"];

	return Ret;
}

// - (id)compileSourceCodeFileAtPath:(id)arg1 ofType:(id)arg2 toOutputDirectory:(id)arg3 withMacroExpansionScope:(id)arg4;
static id compileSourceCodeFileAtPath(XCCompilerSpecification *self_, SEL _Sel, id arg1, id arg2, id arg3, id arg4)
{
	NSMutableDictionary *ThreadDict = [[NSThread currentThread] threadDictionary];
	ThreadDict[@"EmulateVisualStudio_FileType"] = arg2;

	id Ret = ((id(*)(id, SEL, id, id, id, id))original_compileSourceCodeFileAtPath)(self_, _Sel, arg1, arg2, arg3, arg4);

	[ThreadDict removeObjectForKey: @"EmulateVisualStudio_FileType"];

	return Ret;
}

static NSArray *filteredBuildFileReferencesWithMacroExpansionScope(XCBuildPhaseDGSnapshot *self_, SEL _Sel, XCMacroExpansionScope *_pScope)
{
	NSArray *pRet = ((id(*)(id, SEL, id))original_filteredBuildFileReferencesWithMacroExpansionScope)(self_, _Sel, _pScope);

	NSArray *pExcludedFileRefs = [_pScope evaluatedStringListValueForMacroNamed:@"EXCLUDED_FILE_REFS"];

	if (pExcludedFileRefs.count == 0)
		return pRet;

	NSSet *pExcludedSet = [NSSet setWithArray:pExcludedFileRefs];

	NSMutableArray *pNewArray = [NSMutableArray arrayWithCapacity: pRet.count];

	for (XCBuildFileRefArrayDGSnapshot *pBuildRef in pRet)
	{
		NSMutableArray *pAllRefs = [pBuildRef allReferences];
		bool bRemove = false;
		for (XCBuildFileRefDGSnapshot *pRef in pAllRefs)
		{
			if ([pExcludedSet containsObject: pRef.referenceGlobalID])
			{
				bRemove = true;
			}
		}
		if (!bRemove)
			[pNewArray addObject: pBuildRef];
	}

	return pNewArray;
}


// - (void)updateOperationConcurrency
static void updateOperationConcurrency(id self_, SEL _Sel)
{
	return; // Disable updates

//	return ((void(*)(id, SEL))original_updateOperationConcurrency)(self_, _Sel);
}

// - (void)changeMaximumOperationConcurrencyUsingThrottleFactor:(double)arg1;
static void changeMaximumOperationConcurrencyUsingThrottleFactor(id self_, SEL _Sel, double arg1)
{
	return; // Disable updates

//	return ((void(*)(id, SEL))original_changeMaximumOperationConcurrencyUsingThrottleFactor)(self_, _Sel, arg1);
}
