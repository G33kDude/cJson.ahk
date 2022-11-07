#ifndef SHARED_HEADER
#define SHARED_HEADER

#define UNICODE

#include <MCL.h>
#include <oaidl.h>

#include <stdint.h>
#include <stdbool.h>

#include "ahk.h"

#define NULL 0

static IDispatch *objTrue;
MCL_EXPORT_GLOBAL(objTrue);
static IDispatch *objFalse;
MCL_EXPORT_GLOBAL(objFalse);
static IDispatch *objNull;
MCL_EXPORT_GLOBAL(objNull);
static IDispatch *fnGetObj;
MCL_EXPORT_GLOBAL(fnGetObj);

static bool bBoolsAsInts = true;
MCL_EXPORT_GLOBAL(bBoolsAsInts);

static bool bNullsAsStrings = true;
MCL_EXPORT_GLOBAL(bNullsAsStrings);

static bool bEscapeUnicode = true;
MCL_EXPORT_GLOBAL(bEscapeUnicode);

#endif