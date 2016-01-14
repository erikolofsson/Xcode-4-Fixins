#pragma once

#import <Foundation/Foundation.h>


#ifdef _DEBUG
#define XCFixinLog(...) NSLog(__VA_ARGS__)
#else
#define XCFixinLog(...) ((void)0)
#endif

#define XCFixinPreflight(_LoadInXcodeBuild)                         \
    if (!XCFixinShouldLoad(_LoadInXcodeBuild))                      \
        return;                                    \
                                                   \
    static NSUInteger loadAttempt = 0;             \
    loadAttempt++;                                 \
    XCFixinLog(@"%@ initialization attempt %ju/%ju...", \
      NSStringFromClass([self class]),         \
      (uintmax_t)loadAttempt,                  \
      (uintmax_t)XCFixinMaxLoadAttempts);

#define XCFixinPostflight()                                                                                 \
    XCFixinLog(@"%@ initialization successful!", NSStringFromClass([self class]));                               \
    return;                                                                                                 \
    failed:                                                                                                 \
    {                                                                                                       \
        XCFixinLog(@"%@ initialization failed.", NSStringFromClass([self class]));                               \
                                                                                                            \
        if (loadAttempt < XCFixinMaxLoadAttempts)                                                           \
        {                                                                                                   \
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), \
                ^(void)                                                                                     \
                {                                                                                           \
                    [self pluginDidLoad: plugin];                                                           \
                });                                                                                         \
        }                                                                                                   \
                                                                                                            \
        else XCFixinLog(@"%@ failing permanently. :(", NSStringFromClass([self class]));                         \
    }

#define XCFixinAssertMessageFormat @"Assertion failed (file: %s, function: %s, line: %u): %s\n"
#define XCFixinNoOp (void)0

#define XCFixinAssertOrPerform(condition, action)                                                      \
({                                                                                                     \
    bool __evaluated_condition = false;                                                                \
                                                                                                       \
    __evaluated_condition = (condition);                                                               \
                                                                                                       \
    if (!__evaluated_condition)                                                                        \
    {                                                                                                  \
        XCFixinLog(XCFixinAssertMessageFormat, __FILE__, __PRETTY_FUNCTION__, __LINE__, (#condition));      \
        action;                                                                                        \
    }                                                                                                  \
})

#define XCFixinAssertOrRaise(condition) XCFixinAssertOrPerform((condition), [NSException raise: NSGenericException format: @"An XCFixin exception occurred"])

#define XCFixinConfirmOrPerform(condition, action)      \
({                                                      \
    if (!(condition))                                   \
    {                                                   \
        action;                                         \
    }                                                   \
})

BOOL XCFixinShouldLoad(BOOL _LoadInXcodeBuild);
extern const NSUInteger XCFixinMaxLoadAttempts;

/* This function overrides a method at the given class level, and returns the old implementation. If no method existed at
   the given class' level, a new method is created at that level, and the superclass' (or super-superclass', and so on)
   implementation is returned.
   
   This function returns nil on failure. */
IMP XCFixinOverrideMethod(Class class0, SEL selector, IMP newImplementation);
#define XCFixinOverrideMethodString(className, selector, newImplementation) XCFixinOverrideMethod(NSClassFromString(className), selector, newImplementation)

@class NSTextView;
NSTextView *XCFixinFindIDETextView(BOOL log);
IMP XCFixinOverrideStaticMethod(Class class0, SEL selector, IMP newImplementation);
#define XCFixinOverrideStaticMethodString(className, selector, newImplementation) XCFixinOverrideStaticMethod(NSClassFromString(className), selector, newImplementation)
@class NSLayoutManager;
void XCFixinUpdateTempAttributes(NSLayoutManager *layoutManager, NSRange range);
