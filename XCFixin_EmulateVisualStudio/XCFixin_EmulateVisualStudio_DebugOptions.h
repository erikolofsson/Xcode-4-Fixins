// - (id)compositeEnvironmentVariables
static NSDictionary *compositeEnvironmentVariables(id self_, SEL _Sel)
{
	NSDictionary *pRet = ((id (*)(id self_, SEL _Sel))original_compositeEnvironmentVariables)(self_, _Sel);

	NSMutableDictionary *pNewDictionary = [pRet mutableCopy];

	if (g_bDisableDyldLibraries)
	{
		[pNewDictionary removeObjectForKey:@"DYLD_LIBRARY_PATH"];
		[pNewDictionary removeObjectForKey:@"DYLD_FRAMEWORK_PATH"];
		[pNewDictionary removeObjectForKey:@"__XPC_DYLD_LIBRARY_PATH"];
		[pNewDictionary removeObjectForKey:@"__XPC_DYLD_FRAMEWORK_PATH"];
	}

	if (g_bDisableDyldInsertLibraries)
	{
		[pNewDictionary removeObjectForKey:@"DYLD_INSERT_LIBRARIES"];
	}

	return pNewDictionary;
}
