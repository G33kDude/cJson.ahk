
#include "shared.h"

int write_dec_int64(int64_t *number, LPTSTR *ppszString, DWORD *pcchString);
int write_hex_uint16(unsigned short number, LPTSTR *ppszString, DWORD *pcchString);
int write_escaped(LPTSTR stronk, LPTSTR *ppszString, DWORD *pcchString);

static IDispatch *fnCastString;
MCL_EXPORT_GLOBAL(fnCastString, Ptr);

#define write(char)              \
	if (ppszString)              \
		*(*ppszString)++ = char; \
	else                         \
		(*pcchString)++;

#define write_str(str)                                                \
	for (int write_str_i = 0; (str)[write_str_i] != 0; ++write_str_i) \
	{                                                                 \
		write((str)[write_str_i]);                                    \
	}

#define write_indent(level)                                                \
	for (int write_indent_i = 0; write_indent_i < level; ++write_indent_i) \
	{                                                                      \
		write_str("\t");                                                   \
	}

static inline HRESULT vt_bstr_from_double(double *dbInput, VARIANT *pvOutput)
{
	// Convert field value to VARIANT
	VARIANT vArg = {.vt = VT_R8, .dblVal = *dbInput};

	// Stage the inputs and outputs
	DISPPARAMS dpArgs = {.cArgs = 1, .cNamedArgs = 0, .rgvarg = &vArg};

	// Call the host script's fnCastString to cast to string
	return fnCastString->lpVtbl->Invoke(fnCastString, 0, 0, 0, 1, &dpArgs, pvOutput, 0, 0);
}

static inline HRESULT vt_bstr_from_int64(int64_t *dbInput, VARIANT *pvOutput)
{
	// Convert field value to VARIANT
	VARIANT vArg = {.vt = VT_I8, .llVal = *dbInput};

	// Stage the inputs and outputs
	DISPPARAMS dpArgs = {.cArgs = 1, .cNamedArgs = 0, .rgvarg = &vArg};

	// Call the host script's fnCastString to cast to string
	return fnCastString->lpVtbl->Invoke(fnCastString, 0, 0, 0, 1, &dpArgs, pvOutput, 0, 0);
}

enum ObjectType {
	ARRAY,
	MAP,
	OBJECT
};

MCL_IMPORT(BSTR, OleAut32, SysAllocString, (const WCHAR *psz));
MCL_IMPORT(BSTR, OleAut32, SysFreeString, (BSTR bstrString));

static IID IID_NULL[16] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

MCL_EXPORT(dumps, Ptr, pObjIn, Ptr, ppszString, IntP, pcchString, Int, bPretty, Int, iLevel, CDecl_Ptr);
intptr_t dumps(IDispatch *pObjIn, LPTSTR *ppszString, DWORD *pcchString, bool bPretty, int iLevel)
{
	DISPID dispidHasMethod;
	LPOLESTR hasMethod = L"HasMethod";
	pObjIn->lpVtbl->GetIDsOfNames(pObjIn, IID_NULL, &hasMethod, 1, 0, &dispidHasMethod);
	if (dispidHasMethod == DISPID_UNKNOWN) {
		write_str("\"Unknown_Object_");
		int64_t val = (intptr_t)pObjIn;
		write_dec_int64(&val, ppszString, pcchString);
		write('"');
		return 0;
	}

	BSTR push = L"Push"; // SysAllocString(L"Push");
	VARIANT pushArg = { .vt = VT_BSTR, .bstrVal = push};

	DISPPARAMS hasMethodParams = {
		.cArgs = 1,
		.cNamedArgs = 0,
		.rgvarg = &pushArg
	};

	VARIANT hadPush = { .vt = VT_EMPTY };
	HRESULT hadPushResult = pObjIn->lpVtbl->Invoke(pObjIn, dispidHasMethod, NULL, 0, DISPATCH_METHOD, &hasMethodParams, &hadPush, NULL, NULL);

	BSTR set = L"Set"; // SysAllocString(L"Set");
	VARIANT setArg = { .vt = VT_BSTR, .bstrVal = set};

	hasMethodParams.rgvarg = &setArg;
	VARIANT hadSet = { .vt = VT_EMPTY };
	HRESULT hadSetResult = pObjIn->lpVtbl->Invoke(pObjIn, dispidHasMethod, NULL, 0, DISPATCH_METHOD, &hasMethodParams, &hadSet, NULL, NULL);

	BSTR ownProps = L"OwnProps"; // SysAllocString(L"OwnProps");
	VARIANT ownPropsArg = { .vt = VT_BSTR, .bstrVal = ownProps };
	hasMethodParams.rgvarg = &ownPropsArg;
	VARIANT hadOwnProps = { .vt = VT_EMPTY };
	HRESULT hadOwnPropsResult = pObjIn->lpVtbl->Invoke(pObjIn, dispidHasMethod, NULL, 0, DISPATCH_METHOD, &hasMethodParams, &hadOwnProps, NULL, NULL);

	enum ObjectType objectType;
	if (hadPush.vt == VT_I4 && hadPush.intVal != 0) // Has Push
	{
		objectType = ARRAY;
	}
	else if (hadSet.vt == VT_I4 && hadSet.intVal != 0) // Has Set
	{
		objectType = MAP;
	}
	else if (hadOwnProps.vt == VT_I4 && hadOwnProps.intVal != 0) // Has OwnProps
	{
		objectType = OBJECT;
	}
	else
	{
		write_str("\"Unknown_Object_");
		int64_t val = (intptr_t)pObjIn;
		write_dec_int64(&val, ppszString, pcchString);
		write('"');
		return 0;
	}

	// Retrieve an enumerator for two values
	VARIANT vtEnumFunc = { .vt = VT_EMPTY };
	if (objectType == OBJECT)
	{
		DISPID dispidOwnProps;
		LPOLESTR ownProps = L"OwnProps";
		pObjIn->lpVtbl->GetIDsOfNames(pObjIn, IID_NULL, &ownProps, 1, 0, &dispidOwnProps);
		if (dispidOwnProps == DISPID_UNKNOWN) {
			write_str("\"Unknown_Object_");
			int64_t val = (intptr_t)pObjIn;
			write_dec_int64(&val, ppszString, pcchString);
			write('"');
			return 0;
		}

		DISPPARAMS noParams = { .cArgs = 0, .cNamedArgs = 0 };
		VARIANT ownPropsResult = { .vt = VT_EMPTY };
		pObjIn->lpVtbl->Invoke(
			pObjIn,
			dispidOwnProps,
			NULL,
			0,
			DISPATCH_METHOD,
			&noParams,
			&vtEnumFunc, 
			NULL,
			NULL
		);
	}
	else
	{
		LPOLESTR nameEnum = L"__Enum";
		DISPID dispidEnum = 0;
		pObjIn->lpVtbl->GetIDsOfNames(pObjIn, NULL, &nameEnum, 1, 0, &dispidEnum);

		VARIANT two = { .vt = VT_I4, .intVal = 2 };
		DISPPARAMS dispparams = { .cArgs = 1, .cNamedArgs = 0, .rgvarg = &two };
		pObjIn->lpVtbl->Invoke(
			pObjIn,
			dispidEnum,
			NULL,
			0,
			DISPATCH_METHOD | DISPATCH_PROPERTYGET,
			&dispparams,
			&vtEnumFunc,
			NULL,
			NULL
		);
	}

	if (vtEnumFunc.vt != VT_DISPATCH) {
		write_str("\"Unknown_Object_");
		int64_t val = (intptr_t)pObjIn;
		write_dec_int64(&val, ppszString, pcchString);
		write('"');
		return 0;
	}

	// Output the opening brace
	write(objectType == ARRAY ? '[' : '{');
	if (bPretty)
	{
		write_str("\r\n");
	}

	// Enumerate fields
	VARIANT arg1_ = { .vt = VT_EMPTY };
	VARIANT arg2_ = { .vt = VT_EMPTY };
	VARIANT arg1 = { .vt = VT_BYREF | VT_VARIANT, .pvarVal = &arg1_ };
	VARIANT arg2 = { .vt = VT_BYREF | VT_VARIANT, .pvarVal = &arg2_ };
	VARIANT newResult = { .vt = VT_EMPTY };
	for (int i = 0; true; i++)
	{
		VARIANT argArray[2] = { arg2, arg1 };
		DISPPARAMS loopVars = { .cArgs = 2, .cNamedArgs = 0, .rgvarg = argArray };
		HRESULT response = vtEnumFunc.pdispVal->lpVtbl->Invoke(
			vtEnumFunc.pdispVal,
			0,
			NULL,
			0,
			DISPATCH_METHOD,
			&loopVars,
			&newResult,
			NULL,
			NULL
		);

		if (response != 0) {
			return response;
		}
		if (newResult.vt != VT_I4 || newResult.intVal == 0) {
			break;
		}

		// Output field separator
		if (i > 0)
		{
			write(',');
			if (bPretty)
			{
				write_str("\r\n");
			}
		}

		if (bPretty)
		{
			write_indent(iLevel + 1);
		}

		// Output the key and colon
		if (objectType == MAP || objectType == OBJECT)
		{
			if (arg1.pvarVal->vt == VT_I4)
			{
				// Integer
				write('"');
				int64_t val = arg1.pvarVal->intVal;
				write_dec_int64(&val, ppszString, pcchString);
				write('"');
			}
			else if (arg1.pvarVal->vt == VT_I8)
			{
				// 64-bit Integer
				write('"');
				write_dec_int64(&arg1.pvarVal->llVal, ppszString, pcchString);
				write('"');
			}
			else if (arg1.pvarVal->vt == VT_DISPATCH)
			{
				// Object
				write_str("\"Object_");
				int64_t val = (intptr_t)arg1_.pdispVal;
				write_dec_int64(&val, ppszString, pcchString);
				write('"');
			}
			else if (arg1.pvarVal->vt == VT_BSTR)
			{
				// String
				write_escaped(arg1.pvarVal->bstrVal, ppszString, pcchString);
			}
			else
			{
				write_str("\"Unknown_Type_");
				int64_t that = arg1.pvarVal->vt;
				write_dec_int64(&that, ppszString, pcchString);
				write('"');
			}

			// Output colon key-value separator
			write(':');
			if (bPretty)
			{
				write(' ');
			}
		}

		// Output the value
		if (arg2.pvarVal->vt == VT_I4)
		{
			// Integer
			int64_t val = arg2.pvarVal->intVal;
			write_dec_int64(&val, ppszString, pcchString);
		}
		else if (arg2.pvarVal->vt == VT_I8)
		{
			// 64-Bit Integer
			write_dec_int64(&arg2.pvarVal->llVal, ppszString, pcchString);
		}
		else if (arg2.pvarVal->vt == VT_DISPATCH)
		{
			// Object
			if (arg2.pvarVal->pdispVal == objTrue)
			{
				write_str("true");
			}
			else if (arg2.pvarVal->pdispVal == objFalse)
			{
				write_str("false");
			}
			else if (arg2.pvarVal->pdispVal == objNull)
			{
				write_str("null");
			}
			else
			{
				dumps(arg2.pvarVal->pdispVal, ppszString, pcchString, bPretty, iLevel + 1);
			}
		}
		else if (arg2.pvarVal->vt == VT_BSTR)
		{
			// String
			write_escaped(arg2.pvarVal->bstrVal, ppszString, pcchString);
		}
		else if (arg2.pvarVal->vt == VT_R8)
		{
			// Float
			VARIANT result;
			vt_bstr_from_double(&arg2.pvarVal->dblVal, &result);
			write_str(result.bstrVal);
		}
		else
		{
			// Unknown
			write_str("\"Unknown_Value_");
			write_dec_int64(&arg2.pvarVal->llVal, ppszString, pcchString);
			write('"');
		}
	}

	// Free the enumerator and arguments
	if (arg1.pvarVal->vt == VT_DISPATCH)
		arg1.pvarVal->pdispVal->lpVtbl->Release(arg1.pvarVal->pdispVal);
	else if (arg1.pvarVal->vt == VT_BSTR)
		SysFreeString(arg1.pvarVal->bstrVal);

	if (arg2.pvarVal->vt == VT_DISPATCH)
		arg2.pvarVal->pdispVal->lpVtbl->Release(arg2.pvarVal->pdispVal);
	else if (arg2.pvarVal->vt == VT_BSTR)
		SysFreeString(arg2.pvarVal->bstrVal);

	vtEnumFunc.pdispVal->lpVtbl->Release(vtEnumFunc.pdispVal);

	// Output the closing brace
	if (bPretty)
	{
		write_str("\r\n");
		write_indent(iLevel);
	}
	write(objectType == ARRAY ? ']' : '}');

	return 0;
}

int write_escaped(LPTSTR pt, LPTSTR *ppszString, DWORD *pcchString)
{
	// Output the opening quote
	write('"');

	// Process the input string until a null terminator is reached
	for (; (*pt) != 0; pt++)
	{
		if (*pt == '"') // quotation mark
		{
			write('\\');
			write('"');
		}
		else if (*pt == '\\') // reverse solidus
		{
			write('\\');
			write('\\');
		}
		else if (*pt == '\b') // backspace
		{
			write('\\');
			write('b');
		}
		else if (*pt == '\f') // formfeed
		{
			write('\\');
			write('f');
		}
		else if (*pt == '\n') // linefeed
		{
			write('\\');
			write('n');
		}
		else if (*pt == '\r') // carriage return
		{
			write('\\');
			write('r');
		}
		else if (*pt == '\t') // horizontal tab
		{
			write('\\');
			write('t');
		}
		else if (
			bEscapeUnicode
			? ((unsigned short)*pt < ' ' ||(unsigned short)*pt > '~') // Outside printable ascii
			: ((unsigned short)*pt < ' ' || ((unsigned short)*pt > '~' && (unsigned short)*pt < 0xA1)) // Outside printable ascii, allowing Unicode passthrough
		) {
			write('\\');
			write('u');
			write_hex_uint16(*pt, ppszString, pcchString);
		}
		else
		{
			write(*pt);
		}
	}
	write('"');
}

int write_hex_uint16(unsigned short number, LPTSTR *ppszString, DWORD *pcchString)
{
	uint16_t buffer[4];
	char *lookup = "0123456789ABCDEF";

	// Extract the hex values
	for (int i = 0; i < 4; ++i)
	{
		buffer[i] = lookup[number % 16];
		number /= 16;
	}

	// Output in reverse-buffer order
	for (int i = 3; i >= 0; --i)
		write(buffer[i]);

	return 0;
}

int write_dec_int64(int64_t *pNumber, LPTSTR *ppszString, DWORD *pcchString)
{
	// A buffer large enough to fit the longest int64_t (-9223372036854775808)
	TCHAR buffer[21];
	buffer[20] = 0;
	int i = 20;

#if defined(_WIN64)
	// Can be converted natively
	int64_t number = *pNumber;
#else
	// 64-bit division on 32-bit platforms links against the stdlib, which is
	// not available in MCL. For those numbers, call the host script's Format
	// function.
	if (*pNumber < -2147483648 || *pNumber > 2147483647)
	{
		VARIANT result;
		vt_bstr_from_int64(pNumber, &result);
		write_str(result.bstrVal);
		return 0;
	}

	// Any remaining values that fit into 32-bits can be converted natively
	int32_t number = *pNumber;
#endif

	// Extract the decimal values
	if (number < 0)
	{
		// Negative digits subtract from '0'
		do
		{
			buffer[--i] = (TCHAR)('0' - (number % 10));
			number /= 10;
		} while (number != 0);
		buffer[--i] = '-'; // Add the sign
	}
	else
	{
		// Positive digits add to '0'
		do
		{
			buffer[--i] = (TCHAR)((number % 10) + '0');
			number /= 10;
		} while (number != 0);
	}

	write_str(&buffer[i]);
	return 0;
}