
#pragma once

@class IDEIndexCollection;

typedef void (^CDUnknownBlockType)(void);
typedef void (*CDUnknownFunctionPointerType)(void);

struct _DVTTextLineOffsetTable {
    unsigned long long capacity;
    unsigned long long count;
    unsigned long long *offsets;
    unsigned long long deferredAdjustmentIndex;
    long long deferredAdjustment;
};

struct sqlite3_stmt;

typedef struct {
    unsigned long long _field1;
    id const *_field2;
    unsigned long long *_field3;
    unsigned long long _field4[5];
} CDStruct_70511ce9;

struct stat;

struct _DVTFindBarFlags {
    unsigned int findResultsValid:1;
    unsigned int userIsChangingFindString:1;
    unsigned int userIsChangingReplaceString:1;
    unsigned int userIsRestoringHistory:1;
    unsigned int dismissRestoresSelection:1;
    unsigned int ignoreNextInvalidate:1;
    unsigned int viewIsInstalled:1;
    unsigned int _reserved:29;
};

struct SBDebugger {
};

struct SBProcess {
};

struct SBError {
};

struct SBTarget {
};

struct _DVTLayoutManagerFlags {
    unsigned int disableAnnotationAdjustment:1;
    unsigned int severeBubbleAnnotationsMiniaturized:1;
    unsigned int temporaryLinkIsAlternate:1;
    unsigned int autoHighlightTokensEnabled:1;
    unsigned int delegateRespondsToTokenizableRangesWithRange:1;
};

struct DVTStringBuilder {
    unsigned short _field1[512];
    unsigned short *_field2;
    unsigned long long _field3;
    unsigned long long _field4;
};

struct DVTMacroNameLookupCursor {
    void* _field1;
    unsigned long long _field2;
    void* _field3;
    void* _field4;
    struct DVTMacroValueAssignment *_field5;
    void* _field6;
};

#ifndef classdump_DVTNestedMacroExpansionState
#define classdump_DVTNestedMacroExpansionState
struct DVTNestedMacroExpansionState {
    void * _field1; //(id)
    unsigned int _field2;
    struct DVTMacroNameLookupCursor _field3;
    void * _field4; //(id)
    struct DVTNestedMacroExpansionState *_field5;
};
#endif

#ifndef classdump_ArrayBuilder
#define classdump_ArrayBuilder
struct ArrayBuilder {
    void * _field1[62]; //(id)
    void* *_field2; //(id *)
    unsigned int _field3;
    unsigned int _field4;
};
#endif

#ifndef classdump___va_list_tag
#define classdump___va_list_tag
struct __va_list_tag {
    unsigned int _field1;
    unsigned int _field2;
    void *_field3;
    void *_field4;
};
#endif

 struct shared_ptr_c987a6b6 {
	struct IndexerCallbacks *__ptr_;
	struct __shared_weak_count *__cntrl_;
};
