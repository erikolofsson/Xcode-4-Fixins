
NSLock<NSLocking> *g_LLDBLaunchLock = nil;
DVTDispatchLock *g_LLDBLifeCycleLock = nil;
Ivar g_LLDBLifeCycleLockIvar = nil;

// - (void)start;
static void LLDBLauncherStart(DBGLLDBLauncher* self_, SEL _Sel)
{
	[g_LLDBLaunchLock lock];
	if (!g_LLDBLifeCycleLock)
	{
		// Make all LLDB debuggers use the same serialization queue to improve stability
		Ivar IVar = class_getInstanceVariable(NSClassFromString(@"DBGLLDBLauncher"), "_lifeCycleLock");

		if (IVar)
		{
			g_LLDBLifeCycleLockIvar = IVar;
			g_LLDBLifeCycleLock = object_getIvar(self_, g_LLDBLifeCycleLockIvar);
		}
	}
	else
	{
		object_setIvar(self_, g_LLDBLifeCycleLockIvar, g_LLDBLifeCycleLock);
	}
//	XCFixinLog(@"LLDBLauncherStart: %p\n", self_);
	((void(*)(id self_, SEL _Sel))original_LLDBLauncherStart)(self_, _Sel);
//	XCFixinLog(@"LLDBLauncherStart finished: %p\n", self_);
	[g_LLDBLaunchLock unlock];
}

