#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#include "../Shared Code/XCFixin.h"
#import "../Shared Code/Xcode/IDEEditorDocument.h"
#import <AppKit/AppKit.h>

static IMP original__unlockIfNeededCompletionBlock = nil;
static Class g_EditorDocumentClass;

@interface XCFixin_P4Checkout : NSObject
@end

@implementation XCFixin_P4Checkout

#define DYNAMIC_CAST(x, cls)	\
	({	\
		cls *inst_ = (cls *)(x);	\
		[inst_ isKindOfClass:[cls class]] ? inst_ : nil;	\
	})

static int runCommand(NSString *commandToRun, NSString **pStdOut, double timeout)
{
	NSTask *task;
	task = [[NSTask alloc] init];
	[task setLaunchPath: @"/bin/sh"];
	
	NSArray *arguments = [NSArray arrayWithObjects:
							@"-c" ,
							[NSString stringWithFormat:@"%@", commandToRun],
							nil];
	[task setArguments: arguments];
	
	NSDictionary *pCurEnv = [[NSProcessInfo processInfo] environment];
	NSMutableDictionary *pEnv = [[NSMutableDictionary alloc] init];
	if (pCurEnv)
	{
		[pEnv setDictionary: pCurEnv];
	}
	
	NSString *CurrentPath = [pEnv objectForKey:@"PATH"];
	
	if (!CurrentPath)
		CurrentPath = @"/opt/local/bin";
	else
		CurrentPath = [@"/opt/local/bin:" stringByAppendingString:CurrentPath];
	
	[pEnv setObject:CurrentPath forKey:@"PATH"];
	
	[task setEnvironment: pEnv];
	
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	[task setStandardOutput: pipe];
	[task setStandardError: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];
	
	[task launch];
	
	*pStdOut = [[NSString alloc] init];
	
	if (timeout > 0.0)
	{
		dispatch_after
			(
				dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * timeout)
				, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
				, ^(void)
				{
					if ([task isRunning])
					{
						[task interrupt];
					}
				}
			)
		;
	}

	NSData *data;
	data = [file readDataToEndOfFile];

	*pStdOut = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	
	[task waitUntilExit];
	
	if ([task terminationReason] == NSTaskTerminationReasonExit)
		return [task terminationStatus];
	else 
		return 55;
}

static void _unlockIfNeededCompletionBlock(id self_, SEL _cmd, void (^completion)(BOOL _bCanWrite) )
{
	IDEEditorDocument *pEditor = (IDEEditorDocument *)self_;
	if (![pEditor isKindOfClass:g_EditorDocumentClass])
		pEditor = nil;
	
	if (pEditor)
	{
		int ReadOnlyStatus = [pEditor readOnlyStatus];

		//XCFixinLog(@"_unlockIfNeededCompletionBlock %d", ReadOnlyStatus);
		
		NSURL *pURL = [pEditor fileURL];
		if (ReadOnlyStatus != 0 && pURL && [pURL isFileURL])
		{
			NSString *pPath = [pURL path];
			NSString *pDirectory = [pPath stringByDeletingLastPathComponent];
			//XCFixinLog(@"URL: %@", pPath);
			//XCFixinLog(@"Dir: %@", pDirectory);
			double timeout = 2.5;

			{
				NSString *pResults = @"No results";
				int Result = runCommand([NSString stringWithFormat:@"p4 -d \"%@\" set", pDirectory], &pResults, timeout);
				
				if (Result)
				{
					NSAlert* msgBox = [[NSAlert alloc] init];
					[msgBox setMessageText: [NSString stringWithFormat:@"Failed to get p4 config:\n\n%@", pResults]];
					[msgBox addButtonWithTitle: @"OK"];
					[msgBox addButtonWithTitle: @"Unlock with Xcode"];
					NSInteger Button = [msgBox runModal];
					
					NSLog(@"Button: %d", (int)Button);
					
					if (Button == NSAlertSecondButtonReturn)
						return ((void (*)(id, SEL, id))original__unlockIfNeededCompletionBlock)(self_, _cmd, completion);
					else
					{
						dispatch_async
							(
								dispatch_get_main_queue()
								, ^
								{
									completion(false);
								}
							 )
						;
						return;
					}
				}
				
				if ([pResults rangeOfString:@"(config 'noconfig')"].location != NSNotFound)
				{
					// Not inside a perforce config directory
					return ((void (*)(id, SEL, id))original__unlockIfNeededCompletionBlock)(self_, _cmd, completion);
				}
				
			}

			NSString *CheckoutCommand = [NSString stringWithFormat:@"p4 -d \"%@\" open \"%@\"", pDirectory, pPath];
			
			NSString *pResults = @"No results";

			int exitCode = runCommand(CheckoutCommand, &pResults, timeout);
			
			BOOL bSuccess 
				= [pResults rangeOfString:@"- opened for edit"].location != NSNotFound
				|| [pResults rangeOfString:@"- currently opened for edit"].location != NSNotFound
			;

			NSAlert* msgBox = [[NSAlert alloc] init];
			if (!bSuccess)
			{
				if (exitCode == 255 && [pResults compare:@""] == NSOrderedSame)
					pResults = @"Timed out waiting for perforce command to finish";
				
				[msgBox setMessageText: [NSString stringWithFormat:@"Failed to open file for edit:\n\n%@", pResults]];
				[msgBox addButtonWithTitle: @"OK"];
				[msgBox addButtonWithTitle: @"Unlock with Xcode"];
				NSInteger Button = [msgBox runModal];
				
				if (Button == NSAlertSecondButtonReturn)
					return ((void (*)(id, SEL, id))original__unlockIfNeededCompletionBlock)(self_, _cmd, completion);
			}

			[pEditor _updateReadOnlyStatus];
			ReadOnlyStatus = [pEditor readOnlyStatus];

			dispatch_async
				(
					dispatch_get_main_queue()
					, ^
					{
						completion(bSuccess);
					}
				 )
			;
			
			return;
		}
	}
	
	return ((void (*)(id, SEL, id))original__unlockIfNeededCompletionBlock)(self_, _cmd, completion);
}


+ (void) pluginDidLoad:(NSBundle *)plugin
{
	XCFixinPreflight(false);

	g_EditorDocumentClass = NSClassFromString(@"IDEEditorDocument");
	XCFixinAssertOrPerform(g_EditorDocumentClass, goto failed);

	original__unlockIfNeededCompletionBlock = XCFixinOverrideMethodString(@"IDEEditorDocument", @selector(_unlockIfNeededCompletionBlock:), (IMP)&_unlockIfNeededCompletionBlock);
	XCFixinAssertOrPerform(original__unlockIfNeededCompletionBlock, goto failed);
		
	XCFixinPostflight();
}
@end
