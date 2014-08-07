#import "XCFixin.h"
#import <objc/runtime.h>
#import <Cocoa/Cocoa.h>

BOOL XCFixinShouldLoad(void)
{
    BOOL result = NO;
    
    /* Prevent our plugins from loading in non-IDE processes, like xcodebuild. */
    NSString *processName = [[NSProcessInfo processInfo] processName];
        XCFixinConfirmOrPerform([processName caseInsensitiveCompare: @"xcode"] == NSOrderedSame, return NO);
    
    /* Prevent our plugins from loading in Xcode versions < 4. */
    NSArray *versionComponents = [[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"] componentsSeparatedByString: @"."];
        XCFixinConfirmOrPerform(versionComponents && [versionComponents count], return NO);
    NSInteger xcodeMajorVersion = [[versionComponents objectAtIndex: 0] integerValue];
        XCFixinConfirmOrPerform(xcodeMajorVersion >= 4, return NO);
    
    result = YES;
    
    return result;
}

const NSUInteger XCFixinMaxLoadAttempts = 3;
IMP XCFixinOverrideMethod(Class class, SEL selector, IMP newImplementation)
{
    Method *classMethods = nil;
    IMP result = nil;
    
        XCFixinAssertOrPerform(class, goto cleanup);
        XCFixinAssertOrPerform(selector, goto cleanup);
        XCFixinAssertOrPerform(newImplementation, goto cleanup);
    
    Method originalMethod = class_getInstanceMethod(class, selector);
        XCFixinAssertOrPerform(originalMethod, goto cleanup);
    
    IMP originalImplementation = method_getImplementation(originalMethod);
    unsigned int classMethodsCount = 0;
    classMethods = class_copyMethodList(class, &classMethodsCount);
        XCFixinAssertOrPerform(classMethods, goto cleanup);
    
    /* Check to see if the method is defined at the level of 'class', rather than at a super class' level. */
    BOOL methodDefined = NO;
    for (unsigned int i = 0; i < classMethodsCount; i++)
    {
        if (classMethods[i] == originalMethod)
        {
            methodDefined = YES;
            break;
        }
    }
    
    /* If the method's defined at the level of 'class', then we'll just set its implementation. */
    if (methodDefined)
    {
        IMP setImplementationResult = method_setImplementation(originalMethod, newImplementation);
            XCFixinAssertOrPerform(setImplementationResult, goto cleanup);
    }
    
    /* If the method isn't defined at the level of 'class' (and therefore it's defined at a superclass' level), then
       we need to add a method to the level of 'class'. */
    else
    {
        /* Use the return/argument types for the existing method. */
        const char *types = method_getTypeEncoding(originalMethod);
            XCFixinAssertOrPerform(types, goto cleanup);
        
        BOOL addMethodResult = class_addMethod(class, selector, newImplementation, types);
            XCFixinAssertOrPerform(addMethodResult, goto cleanup);
    }
    
    result = originalImplementation;
    
    cleanup:
    {
        if (classMethods)
            free(classMethods),
            classMethods = nil;
    }
    
    return result;
}

NSTextView *XCFixinFindIDETextView(BOOL log)
{
  NSWindow *mainWindow=[[NSApplication sharedApplication] mainWindow];
  if(!mainWindow)
  {
    if(log)
      NSLog(@"Can't find IDE text view - no main window.\n");
    
    return nil;
  }
  
  Class DVTCompletingTextView=objc_getClass("DVTCompletingTextView");
  if(!DVTCompletingTextView)
  {
    if(log)
      NSLog(@"Can't find IDE text view - DVTCompletingTextView class unavailable.\n");
    
    return nil;
  }
  
  id textView=nil;
  
  for(NSResponder *responder=[mainWindow firstResponder];responder;responder=[responder nextResponder])
  {
    if([responder isKindOfClass:DVTCompletingTextView])
    {
      textView=responder;
      break;
    }
  }
  
  if(!textView)
  {
    if(log)
      NSLog(@"Can't find IDE text view - no DVTCompletingTextView in the responder chain.\n");
    
    return nil;
  }
  
  return textView;
}

IMP XCFixinOverrideStaticMethod(Class class, SEL selector, IMP newImplementation)
{
  IMP result = nil;
    
  XCFixinAssertOrPerform(class, goto cleanup);
  XCFixinAssertOrPerform(selector, goto cleanup);
  XCFixinAssertOrPerform(newImplementation, goto cleanup);
    
  Method originalMethod = class_getClassMethod(class, selector);
  XCFixinAssertOrPerform(originalMethod, goto cleanup);
    
  IMP originalImplementation = method_getImplementation(originalMethod);
  IMP setImplementationResult = method_setImplementation(originalMethod, newImplementation);
  XCFixinAssertOrPerform(setImplementationResult, goto cleanup);
    
  result = originalImplementation;
    
cleanup:
    
    return result;
}

static CGFloat XCFixinAddColor(CGFloat color0, CGFloat color1)
{
  CGFloat color = color0 + color1;
  if (color > 1.0)
    color = 1.0;
  
  return color;
}

void XCFixinUpdateTempAttributes(NSLayoutManager* layoutManager, NSRange range)
{
  NSUInteger iLocation = range.location;
  NSUInteger iEndLocation = range.location + range.length;
  
  Class nsStringClass = [NSString class];
  NSString *pBestKey = nil;
  
  while (iLocation < iEndLocation)
  {
    NSColor* newColor = nil;
    NSRange effectiveRange;
    NSRange expectedRange;
    expectedRange.location = iLocation;
    expectedRange.length = iEndLocation - iLocation;
    NSDictionary *pCurrentAttributes = [layoutManager temporaryAttributesAtCharacterIndex:iLocation longestEffectiveRange:&effectiveRange inRange:expectedRange];
    NSEnumerator *keyEnumerator = [pCurrentAttributes keyEnumerator];
    for (id key = [keyEnumerator nextObject]; key != nil; key = [keyEnumerator nextObject])
    {
      if ([key isKindOfClass: nsStringClass])
      {
        if ([((NSString *)key) hasPrefix:@"XCFixinTempAttribute"])
        {
          NSColor *pColor = [pCurrentAttributes objectForKey:key];
          if (newColor == nil || [((NSString *)key) compare:pBestKey] > 0)
          {
            pBestKey = ((NSString *)key);
            newColor = pColor;
          }
          /*
          else
          {
            
            CGFloat Red;
            CGFloat Green;
            CGFloat Blue;
            CGFloat Alpha;
            [newColor getRed:&Red green:&Green blue:&Blue alpha:&Alpha];

            CGFloat NewRed;
            CGFloat NewGreen;
            CGFloat NewBlue;
            CGFloat NewAlpha;
            [pColor getRed:&NewRed green:&NewGreen blue:&NewBlue alpha:&NewAlpha];
             
            Red = XCFixinAddColor(Red * Alpha, NewRed * NewAlpha);
            Green = XCFixinAddColor(Green * Alpha, NewGreen * NewAlpha);
            Blue = XCFixinAddColor(Blue * Alpha, NewBlue * NewAlpha);
            Alpha = XCFixinAddColor(Alpha, NewAlpha);
            
            
            newColor = [NSColor colorWithCalibratedRed:Red green:Green blue:Blue alpha:Alpha];
            //newColor = [newColor blendedColorWithFraction:Alpha*NewAlpha ofColor:pColor];
          }*/
        }
      }
    }
    
    if (newColor != nil)
      [layoutManager addTemporaryAttribute: NSBackgroundColorAttributeName value: newColor forCharacterRange: effectiveRange];
    else
      [layoutManager removeTemporaryAttribute: NSBackgroundColorAttributeName forCharacterRange: effectiveRange];
    
    iLocation = effectiveRange.location + effectiveRange.length;
  }

  dispatch_async(dispatch_get_main_queue(),  ^(void){
    [layoutManager invalidateDisplayForCharacterRange: range];
  });
}

