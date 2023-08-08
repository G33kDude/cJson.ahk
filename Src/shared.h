#ifndef SHARED_HEADER
#define SHARED_HEADER

#define UNICODE

#include <MCL.h>
#include <oaidl.h>

#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>

// #define NULL 0

static IDispatch *objTrue;
MCL_EXPORT_GLOBAL(objTrue, Ptr);
static IDispatch *objFalse;
MCL_EXPORT_GLOBAL(objFalse, Ptr);
static IDispatch *objNull;
MCL_EXPORT_GLOBAL(objNull, Ptr);
static IDispatch *fnGetMap;
MCL_EXPORT_GLOBAL(fnGetMap, Ptr);
static IDispatch *fnGetArray;
MCL_EXPORT_GLOBAL(fnGetArray, Ptr);

static bool bBoolsAsInts = true;
MCL_EXPORT_GLOBAL(bBoolsAsInts, Int);

static bool bNullsAsStrings = true;
MCL_EXPORT_GLOBAL(bNullsAsStrings, Int);

static bool bEscapeUnicode = true;
MCL_EXPORT_GLOBAL(bEscapeUnicode, Int);

#endif