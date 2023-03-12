
#include "shared.h"

int write_dec_int64(int64_t *number, LPTSTR *ppszString, DWORD *pcchString);
int write_hex_uint16(unsigned short number, LPTSTR *ppszString, DWORD *pcchString);
int write_escaped(LPTSTR stronk, LPTSTR *ppszString, DWORD *pcchString);

static IDispatch *fnCastString;
MCL_EXPORT_GLOBAL(fnCastString);

static bool bEmptyObjectsAsArrays = false;
MCL_EXPORT_GLOBAL(bEmptyObjectsAsArrays);

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

MCL_EXPORT(dumps);
int dumps(Object *pobjIn, LPTSTR *ppszString, DWORD *pcchString, bool bPretty, int iLevel)
{

	// Check the vtable against a known AHK object to verify it is not a COM object
	if (pobjIn->lpVtbl != objNull->lpVtbl)
	{
		write_str("\"Unknown_Object_");
		int64_t val = (intptr_t)pobjIn;
		write_dec_int64(&val, ppszString, pcchString);
		write('"');
		return 0;
	}

	// Check if the object is a sequentially indexed array
	bool isIndexed = false;
	if (pobjIn->cFields == 0) // No fields
	{
		isIndexed = bEmptyObjectsAsArrays;
	}
	else if (pobjIn->iObjectKeysOffset == pobjIn->cFields) // Are all fields numeric?
	{
		// Check that all numeric keys' values match their index
		isIndexed = true;
		for (int i = 0; isIndexed && i < pobjIn->cFields; i++)
		{
			Field *currentField = pobjIn->pFields + i;
			isIndexed = currentField->iKey == i + 1;
		}
	}

	// Output the opening brace
	write(isIndexed ? '[' : '{');
	if (bPretty)
	{
		write_str("\r\n");
	}

	// Enumerate fields
	for (int i = 0; i < pobjIn->cFields; i++)
	{
		Field *currentField = pobjIn->pFields + i;

		// Output field separator
		if (i > 0)
		{
			write(',');
			if (bPretty)
			{
				write_str("\r\n");
			}
			else
			{
				write(' ');
			}
		}

		if (bPretty)
		{
			write_indent(iLevel + 1);
		}

		// Output the key and colon
		if (!isIndexed)
		{
			if (i < pobjIn->iObjectKeysOffset)
			{
				// Integer
				write('"');
				int64_t val = currentField->iKey;
				write_dec_int64(&val, ppszString, pcchString);
				write('"');
			}
			else if (i < pobjIn->iStringKeysOffset)
			{
				// Object
				write_str("\"Object_");
				int64_t val = currentField->iKey;
				write_dec_int64(&val, ppszString, pcchString);
				write('"');
			}
			else
			{
				// String
				write_escaped(currentField->pstrKey, ppszString, pcchString);
			}

			// Output colon key-value separator
			write(':');
			write(' ');
		}

		// Output the value
		if (currentField->SymbolType == PURE_INTEGER)
		{
			// Integer
			write_dec_int64(&currentField->iValue, ppszString, pcchString);
		}
		else if (currentField->SymbolType == SYM_OBJECT)
		{
			// Object
			if (currentField->pobjValue == (Object *)objTrue)
			{
				write_str("true");
			}
			else if (currentField->pobjValue == (Object *)objFalse)
			{
				write_str("false");
			}
			else if (currentField->pobjValue == (Object *)objNull)
			{
				write_str("null");
			}
			else
			{
				dumps(currentField->pobjValue, ppszString, pcchString, bPretty, iLevel + 1);
			}
		}
		else if (currentField->SymbolType == SYM_OPERAND)
		{
			// String
			write_escaped(currentField->pstrValue, ppszString, pcchString);
		}
		else if (currentField->SymbolType == PURE_FLOAT)
		{
			// Float
			VARIANT result;
			vt_bstr_from_double(&currentField->dblValue, &result);
			write_str(result.bstrVal);
		}
		else
		{
			// Unknown
			write_str("\"Unknown_Value_");
			write_dec_int64(&currentField->iValue, ppszString, pcchString);
			write('"');
		}
	}

	// Output the closing brace
	if (bPretty)
	{
		write_str("\r\n");
		write_indent(iLevel);
	}
	write(isIndexed ? ']' : '}');

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