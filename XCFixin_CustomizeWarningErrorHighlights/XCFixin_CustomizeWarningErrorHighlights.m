#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import "XCFixin.h"

#import "../Shared Code/Xcode/DVTTextAnnotation.h"
#import "../Shared Code/Xcode/DVTMessageBubbleView.h"
#import "../Shared Code/Xcode/DVTTextAnnotationTheme.h"


//#import "DVTKit.h"

static IMP gOriginalnewMessageAttributesForFont = nil;
static IMP gOriginal_defaultMessageFontSize = nil;

@interface XCFixin_CustomizeWarningErrorHighlights : NSObject
{
}

@end

static DVTTextAnnotationTheme * warningTheme;
static DVTTextAnnotationTheme * errorTheme;
static DVTTextAnnotationTheme * analyzerTheme;
static DVTTextAnnotationTheme * debuggerTheme;
static DVTTextAnnotationTheme * grayTheme;

@implementation XCFixin_CustomizeWarningErrorHighlights

static double override_defaultMessageFontSize(SEL _cmd)
{	
	double Return = ((double (*)(SEL))gOriginal_defaultMessageFontSize)(_cmd );
	return Return*0.9;
	//return 7.0*1.5;
}


static void overridenewMessageAttributesForFont(id self, SEL _cmd, DVTTextAnnotationTheme* arg1, id arg2)
{
	const char* className = class_getName([self class]);
	DVTTextAnnotationTheme * newTheme  = arg1;
	
	if ( strcmp(className, "IDEBuildIssueStaticAnalyzerResultAnnotation") == 0 ||
		 strcmp(className, "IDEBuildIssueStaticAnalyzerEventStepAnnotation") == 0 ){	// apply our own theme for Warning Messages	
		newTheme = analyzerTheme;
	}else
	
	if (  strcmp(className, "IDEDiagnosticWarningAnnotation") == 0 ||
		strcmp(className, "IDEBuildIssueWarningAnnotation") == 0 ){	// apply our own theme for Warning Messages	
		newTheme = warningTheme;
	}else

	if (  strcmp(className, "IDEDiagnosticErrorAnnotation") == 0 ||
		strcmp(className, "IDEBuildIssueErrorAnnotation") == 0  ){		// apply our own theme for Error Messages	
		newTheme = errorTheme;
	}else

	if (  strcmp(className, "DBGInstructionPointerAnnotation") == 0 ){	// apply our own theme for debugging annotations	
		newTheme = debuggerTheme;
	}else

	if (  strcmp(className, "IDEBuildIssueNoticeAnnotation") == 0 ){	// apply our own theme for Build Issue Notice annotations	
		newTheme = grayTheme;
	}else
	
	if (  strcmp(className, "IBAnnotation") == 0 || strcmp(className, "DBGBreakpointAnnotation") == 0 ){	
		// nothing to be done here... those anotations are only for the sidebar, so no overlay applied
		//on top of the source code for those ones
	}else{
		/// what the heck is it then?
		XCFixinLog(@">>> %s\n", className);
	}

    ((void (*)(id, SEL, DVTTextAnnotationTheme*, id))gOriginalnewMessageAttributesForFont)(self, _cmd , newTheme, arg2);
}



+ (void)pluginDidLoad: (NSBundle *)plugin{
	
	XCFixinPreflight(false);
	float lineAlpha = 0.50;	//whole line
	float topAlpha = 0.8;	//the right-hand label

	//define gradient for warning text highlight
	NSColor * warningColor = [NSColor colorWithDeviceRed:0.5 green:0.5 blue:0 alpha: lineAlpha];
	//define warning text highlight theme
	warningTheme = 
	[[DVTTextAnnotationTheme alloc] initWithHighlightColor: warningColor 
											borderTopColor: [NSColor clearColor]
										 borderBottomColor: [NSColor clearColor]
											 overlayGradient: nil
									 overlayTintedGradient: nil
									messageBubbleBorderColor: [warningColor colorWithAlphaComponent: topAlpha]
									 messageBubbleGradient: nil
												caretColor: [NSColor yellowColor]  
								 highlightedRangeBorderColor: [NSColor clearColor] 
	 ];

	warningTheme.darkVariant = warningTheme;


	//define gradient for error text highlight
	NSColor * errorColor = [NSColor colorWithDeviceRed:0.5 green:0 blue:0 alpha: lineAlpha];
	//define error text highlight theme
	errorTheme = 
	[[DVTTextAnnotationTheme alloc] initWithHighlightColor: errorColor 
											borderTopColor: [NSColor clearColor]
										 borderBottomColor: [NSColor clearColor]
											 overlayGradient: nil
									 overlayTintedGradient: nil
									messageBubbleBorderColor: [errorColor colorWithAlphaComponent: topAlpha]
									 messageBubbleGradient: nil
												caretColor: [NSColor redColor]  
								 highlightedRangeBorderColor: [NSColor clearColor] 
	];

	errorTheme.darkVariant = errorTheme;

	//define gradient for static Analyzer text highlight
	NSColor * analyzerColor = [NSColor colorWithDeviceRed:0.25 green:0.25 blue:0.5 alpha: lineAlpha];
	//define static Analyzer text highlight theme
	analyzerTheme = 
	[[DVTTextAnnotationTheme alloc] initWithHighlightColor: analyzerColor 
											borderTopColor: [NSColor clearColor]
										 borderBottomColor: [NSColor clearColor]
											 overlayGradient: nil
									 overlayTintedGradient: nil
									messageBubbleBorderColor: [analyzerColor colorWithAlphaComponent: topAlpha]
									 messageBubbleGradient: nil
												caretColor: [NSColor blueColor]  
								 highlightedRangeBorderColor: [NSColor clearColor] 
	 ];

	analyzerTheme.darkVariant = analyzerTheme;

	//define gradient for debugger text highlight
	NSColor * debuggerColor = [NSColor colorWithDeviceRed:0.4 green:0.5 blue:0.4 alpha: 0.6];
	//define static debugger text highlight theme
	debuggerTheme = 
	[[DVTTextAnnotationTheme alloc] initWithHighlightColor: debuggerColor 
											borderTopColor: [NSColor clearColor]
										 borderBottomColor: [NSColor clearColor]
											 overlayGradient: nil
									 overlayTintedGradient: nil
									messageBubbleBorderColor: [debuggerColor colorWithAlphaComponent: topAlpha]
									 messageBubbleGradient: nil
												caretColor: [NSColor greenColor]  
								 highlightedRangeBorderColor: [NSColor clearColor] 
	 ];

	debuggerTheme.darkVariant = debuggerTheme;

	//define gradient for Notice text highlight
	NSColor * noticeColor = [NSColor colorWithDeviceRed:0.15 green:0.15 blue:0.15 alpha: lineAlpha];
	//define Notice text highlight theme
	grayTheme = 
	[[DVTTextAnnotationTheme alloc] initWithHighlightColor: noticeColor 
											borderTopColor: [NSColor clearColor]
										 borderBottomColor: [NSColor clearColor]
											 overlayGradient: nil
									 overlayTintedGradient: nil
									messageBubbleBorderColor: [noticeColor colorWithAlphaComponent: topAlpha]
									 messageBubbleGradient: nil
												caretColor: [NSColor grayColor]  
								 highlightedRangeBorderColor: [NSColor clearColor] 
	 ];

	grayTheme.darkVariant = grayTheme;

	//	pAnnotationFont = [NSFont fontWithName:@"Lucida Grande" size:7.5];

	gOriginalnewMessageAttributesForFont = XCFixinOverrideMethodString(@"DVTTextAnnotation", @selector(setTheme:forState:), (IMP)&overridenewMessageAttributesForFont);
	XCFixinAssertOrPerform(gOriginalnewMessageAttributesForFont, goto failed);

	gOriginal_defaultMessageFontSize = XCFixinOverrideStaticMethodString(@"DVTMessageBubbleView", @selector(_defaultMessageFontSize), (IMP)&override_defaultMessageFontSize);
	XCFixinAssertOrPerform(gOriginal_defaultMessageFontSize, goto failed);


	XCFixinPostflight();
}

@end
