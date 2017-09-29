#import "XCFixin.h"
#import <objc/runtime.h>
#import <Cocoa/Cocoa.h>

BOOL XCFixinShouldLoad(BOOL _LoadInXcodeBuild)
{
    BOOL result = NO;
   
    if (!_LoadInXcodeBuild)
    {
        /* Prevent our plugins from loading in non-IDE processes, like xcodebuild. */
        NSString *processName = [[NSProcessInfo processInfo] processName];
        XCFixinConfirmOrPerform([processName caseInsensitiveCompare: @"xcode"] == NSOrderedSame, return NO);
    }
    
    /* Prevent our plugins from loading in Xcode versions < 4. */
    NSArray *versionComponents = [[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"] componentsSeparatedByString: @"."];
        XCFixinConfirmOrPerform(versionComponents && [versionComponents count], return NO);
    NSInteger xcodeMajorVersion = [[versionComponents objectAtIndex: 0] integerValue];
    NSInteger xcodeMinorVersion = [[versionComponents objectAtIndex: 1] integerValue];

    // Limit to this Xcode versions
    XCFixinConfirmOrPerform(xcodeMajorVersion == 9, return NO);
    XCFixinConfirmOrPerform(xcodeMinorVersion == 0, return NO);

    result = YES;
    
    return result;
}

const NSUInteger XCFixinMaxLoadAttempts = 3;
IMP XCFixinOverrideMethod(Class class0, SEL selector, IMP newImplementation)
{
    Method *classMethods = nil;
    IMP result = nil;
    
        XCFixinAssertOrPerform(class0, goto cleanup);
        XCFixinAssertOrPerform(selector, goto cleanup);
        XCFixinAssertOrPerform(newImplementation, goto cleanup);
    
    Method originalMethod = class_getInstanceMethod(class0, selector);
        XCFixinAssertOrPerform(originalMethod, goto cleanup);
    
    IMP originalImplementation = method_getImplementation(originalMethod);
    unsigned int classMethodsCount = 0;
    classMethods = class_copyMethodList(class0, &classMethodsCount);
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
        
        BOOL addMethodResult = class_addMethod(class0, selector, newImplementation, types);
            XCFixinAssertOrPerform(addMethodResult, goto cleanup);
    }
    
    result = originalImplementation;
    
    cleanup:
    {
        if (classMethods)
        {
            free(classMethods);
            classMethods = nil;
        }
    }
    
    return result;
}

IMP XCFixinOverrideStaticMethod(Class class0, SEL selector, IMP newImplementation)
{
  IMP result = nil;
    
  XCFixinAssertOrPerform(class0, goto cleanup);
  XCFixinAssertOrPerform(selector, goto cleanup);
  XCFixinAssertOrPerform(newImplementation, goto cleanup);
    
  Method originalMethod = class_getClassMethod(class0, selector);
  XCFixinAssertOrPerform(originalMethod, goto cleanup);
    
  IMP originalImplementation = method_getImplementation(originalMethod);
  IMP setImplementationResult = method_setImplementation(originalMethod, newImplementation);
  XCFixinAssertOrPerform(setImplementationResult, goto cleanup);
    
  result = originalImplementation;
    
cleanup:
    
    return result;
}

static void DumpIvars(Class clz)
{
    unsigned int count;
    Ivar* ivars=class_copyIvarList(clz, &count);
    for(int i=0; i<count; i++)
    {
        Ivar ivar= ivars[i];
        printf("\t%s %s\n", ivar_getTypeEncoding(ivar), ivar_getName(ivar));

    }
    free(ivars);
}

static NSArray *ParseTypeString (NSString *rawTypeString);

static NSString *ReadableTypeString (NSString *typestring) {
    NSArray *chunks = ParseTypeString (typestring);
    NSString *result = [chunks componentsJoinedByString: @", "];
    return result;
} // ReadableTypeString

static void DumpObjcMethods(Class clz, bool isInstance)
{
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(clz, &methodCount);

    printf("Found %d methods on '%s'\n", methodCount, class_getName(clz));

    if (isInstance)
    DumpIvars(clz);
    for (unsigned int i = 0; i < methodCount; i++)
    {
        Method method = methods[i];

        char buffer[100];

        buffer[0] = '\0';
        method_getReturnType (method, buffer, sizeof(buffer));
        NSString *returnTypeString = ReadableTypeString (@(buffer));

        unsigned int argumentCount = method_getNumberOfArguments (method);
        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity: argumentCount];
        // Skip over self and selector.
        for (int i = 2; i < argumentCount; i++) {
            method_getArgumentType (method, i, buffer, sizeof(buffer));
            [arguments addObject: ReadableTypeString (@(buffer))];
        }

        NSString *argumentString = @"nothing";
        if (arguments.count > 0) {
            argumentString = [arguments componentsJoinedByString: @", "];
        }

        printf("\t'%s' has method named '%s (%s) %s' with args '%s' of encoding '%s'\n",
               class_getName(clz),
               (isInstance) ? "-" : "+",
               returnTypeString.UTF8String,
               sel_getName(method_getName(method)),
               argumentString.UTF8String,
               method_getTypeEncoding(method)
               )
        ;
    }

    free(methods);
}

static NSString *getClassHierarchyNames(Class theClass)
{
    NSString *pClasses = @"";
    Class pClass = theClass;
    while (pClass)
    {
        pClasses = [NSString stringWithFormat: @"%@ %s", pClasses, object_getClassName(pClass)];
        pClass = class_getSuperclass(pClass);
    }
    return pClasses;
}

void XCFixinTraceViewHierarchy(NSView* _pView, int _Depth)
{
  if (_Depth >= 0)
      NSLog(@"%@%@", [@"" stringByPaddingToLength:_Depth*3 withString: @" " startingAtIndex:0], getClassHierarchyNames([_pView class]));

  for (NSView * pView in [_pView subviews])
      XCFixinTraceViewHierarchy(pView, _Depth + 1);
}

void XCFixinDumpClass(Class theClass)
{
    char const *pClassName = class_getName(theClass);
    if (strstr(pClassName, "NS") == pClassName)
    {
        printf("%s\n", class_getName(theClass));
    }
    else
    {
        DumpObjcMethods(theClass, true);
        DumpObjcMethods(object_getClass(theClass), false);
    }
    Class pClass = class_getSuperclass(theClass);
    if (pClass)
        XCFixinDumpClass(pClass);
}


// From https://gist.github.com/markd2/5961219

static NSString *StructEncoding (char **typeScan);

// Remove all numbers from the string.  Some type encoding strings include
// offsets and/or sizes, and they're often wrong.  yay?

static NSString *ScrubNumbers (NSString *string) {
    NSCharacterSet *numbers = [NSCharacterSet decimalDigitCharacterSet];
    NSString *numberFree = [[string componentsSeparatedByCharactersInSet: numbers]
                               componentsJoinedByString: @""];
    return numberFree;

} // ScrubNumbers


// Convert simple types.
// |typeScan| is scooted over to account for any consumed characters
static NSString *SimpleEncoding (char **typeScan) {
    typedef struct TypeMap {
        unichar discriminator;
        char *name;
    } TypeMap;

    static TypeMap s_typeMap[] = {
        { 'c', "char" },
        { 'i', "int" },
        { 's', "short" },
        { 'l', "long" },
        { 'q', "longlong" },
        { 'C', "unsigned char" },
        { 'I', "unsigned int" },
        { 'S', "unsigned short" },
        { 'L', "unsiged long" },
        { 'Q', "unsigned long long" },
        { 'f', "float" },
        { 'd', "double" },
        { 'B', "bool" },
        { 'v', "void" },
        { '*', "char*" },
        { '#', "class" },
        { ':', "selector" },
        { '?', "unknown" },
    };

    NSString *result = nil;

    TypeMap *scan = s_typeMap;
    TypeMap *stop = scan + sizeof(s_typeMap) / sizeof(*s_typeMap);

    while (scan < stop) {
        if (scan->discriminator == **typeScan) {
            result = @( scan->name );
            (*typeScan)++;
            break;
        }
        scan++;
    }

    return result;

} // SimpleEncoding


// Process object/id/block types.  Some type strings include the class name in "quotes"
// |typeScan| is scooted over to account for any consumed characters.
static NSString *ObjectEncoding (char **typeScan) {
    assert (**typeScan == '@');
    (*typeScan)++; // eat the '@'

    NSString *result = @"id";

    if (**typeScan == '"') {
        (*typeScan)++; // eat the double-quote
        char *closeQuote = *typeScan;
        while (*closeQuote && *closeQuote != '"') {
            closeQuote++;
        }
        *closeQuote = '\000';
        result = [NSString stringWithUTF8String: *typeScan];
        *closeQuote = '\"';
        *typeScan = closeQuote;

    } else if (**typeScan == '?') {
        result = @"block";
        (*typeScan)++;
    }

    return result;

} // ObjectEncoding


// Process pointer types.  Recursive since pointers are people too.
// |typeScan| is scooted over to account for any consumed characters
static NSString *PointerEncoding (char **typeScan) {
    assert (**typeScan == '^');
    (*typeScan)++; // eat the '^'

    NSString *result = @"";

    if (**typeScan == '^') {
        result = PointerEncoding (typeScan);

    } else if (**typeScan == '{') {
        result = StructEncoding (typeScan);
    } else {
        result = SimpleEncoding (typeScan);
    }

    result = [result stringByAppendingString: @"*"];
    return result;

} // PointerEncoding


// Process structure types.  Pull out the name of the first structure encountered
// and not worry about any embedded structures.
// |typeScan| is scooted over to account for any consumed characters
static NSString *StructEncoding (char **typeScan) {
    assert (**typeScan == '{');
    (*typeScan)++; // eat the '{'

    NSString *result = @"";

    // find the equal sign after the struct name
    char *equalSign = *typeScan;
    while (*equalSign && *equalSign != '=') {
        equalSign++;
    }
    *equalSign = '\000';
    result = [NSString stringWithUTF8String: *typeScan];
    *equalSign = '=';


    // Eat the rest of the potentially nested structures.
    int openCount = 1;
    while (**typeScan && openCount) {
        if (**typeScan == '{') openCount++;
        if (**typeScan == '}') openCount--;
        (*typeScan)++;
    }

    return result;

} // StructEncoding


// Given an Objective-C type encoding string, return an array of human-readable
// strings that describe each of the types.
static NSArray *ParseTypeString (NSString *rawTypeString) {
    NSString *typeString = ScrubNumbers (rawTypeString);
    char *base = strdup ([typeString UTF8String]);
    char *scan = base;

    NSMutableArray *chunks = [NSMutableArray array];

    while (*scan) {
        NSString *stuff = SimpleEncoding (&scan);

        if (stuff) {
            [chunks addObject: stuff];
            continue;
        }

        if (*scan == '@') {
            stuff = ObjectEncoding (&scan);
            [chunks addObject: stuff];
            continue;
        }

        if (*scan == '^') {
            stuff = PointerEncoding (&scan);
            if (stuff)
                [chunks addObject: stuff];
            continue;
        }

        if (*scan == '{') {
            stuff = StructEncoding (&scan);
            [chunks addObject: stuff];
            continue;
        }

        // If we hit this, more work needs to be done.
        stuff = [NSString stringWithFormat: @"(that was unexpected: %c)", *scan];
        scan++;
    }

    free (base);

    return chunks;

} // ParseTypeString
