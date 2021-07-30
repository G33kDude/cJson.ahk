#ifndef COM_HEADER
#define COM_HEADER

#include <MCL.h>
#include <stdint.h>

typedef union
{
    char Bytes[16];
    struct
    {
        unsigned long Data1;
        unsigned short Data2;
        unsigned short Data3;
        unsigned char Data4[8];
    };
    struct
    {
        long long int Low;
        long long int High;
    };
} GUID;

char GUIDEquals(GUID *Left, GUID *Right)
{
    return Left->Low == Right->Low && Left->High == Right->High;
}

typedef struct TagIUnkownVTable
{
    int (*QueryInterface)(struct TagIUnkownVTable *, GUID *, void **);
    int (*AddReference)(struct TagIUnkownVTable *);
    int (*Release)(struct TagIUnkownVTable *);
} IUnknownVTable;

typedef short *BSTR;
MCL_IMPORT(BSTR, OleAut32, SysAllocString, (const short *));
MCL_IMPORT(void, OleAut32, SysFreeString, (BSTR));

#define VT_EMPTY 0
#define VT_NULL 1
#define VT_I4 3
#define VT_R8 5
#define VT_BSTR 8
#define VT_DISPATCH 9
#define VT_BOOL 11
#define VT_UNKNOWN 13
#define VT_I8 20

// #define VARIANT_TRUE 0xFFFF
#define VARIANT_TRUE -1
#define VARIANT_FALSE 0x0000

typedef struct
{
    short Type;

    union
    {
        double Double;
        int64_t Integer;
        void *Pointer;
        BSTR BSTR;

        struct
        {
            int64_t Padding[2];
        };
    };
} VARIANT;

typedef struct
{
    VARIANT *Values;
    int *DispatchIDs;
    int VARIANTCount;
    int DispatchIDCount;
} DISPPARAMS;

typedef struct TagIDispatchVTable
{
    IUnknownVTable IUnknown;
    int (*GetTypeInfoCount)(struct TagIDispatchVTable *, int *);
    int (*GetTypeInfo)(struct TagIDispatchVTable *, int, int, void **);
    int (*GetIDsOfNames)(struct TagIDispatchVTable *, GUID *, short **, int, int, int *);
    int (*Invoke)(struct TagIDispatchVTable *, int, GUID *, int, short, DISPPARAMS *, VARIANT *, void *, int *);
} IDispatchVTable;

#define DISPATCH_METHOD 0x1
#define DISPATCH_PROPERTYGET 0x2
#define DISPATCH_PROPERTYPUT 0x4
#define DISPATCH_PROPERTYPUTREF 0x8
#define DISPID_NEWENUM -4

#define S_OK 0x00
#define S_FALSE 0x01
#define E_NOT_IMPLEMENTED 0x80004001
#define E_NO_INTERFACE 0x80004002
#define E_POINTER 0x80004003
#define E_UNEXPECTED 0x8000FFFF

#define DISP_E_MEMBERNOTFOUND 0x80020003
#define DISP_E_PARAMNOTOPTIONAL 0x80020004
#define DISP_E_UNKNOWNNAME 0x80020006
#define DISP_E_BADVARTYPE 0x80020008
#define DISP_E_BADPARAMCOUNT 0x8002000E

GUID IID_IUnknown = {.Bytes = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46}};
GUID IID_IDispatch = {.Bytes = {0x00, 0x02, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46}};
GUID IID_IEnumVARIANT = {.Bytes = {0x04, 0x04, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46}};
GUID IID_IObjectComCompatible = {.Bytes = {0x61, 0x9f, 0x7e, 0x25, 0x6d, 0x89, 0x4e, 0xb4, 0xb2, 0xfb, 0x18, 0xe7, 0xc7, 0x3c, 0x0e, 0xa6}};

#endif