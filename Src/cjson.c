
#include <MCL.h>

#include <stdint.h>
#include <stdbool.h>

typedef uint32_t DWORD;

typedef struct Object Object;
typedef struct Field Field;

typedef uint16_t TCHAR;
typedef TCHAR *LPTSTR;
typedef int HRESULT;

struct Field
{
	union
	{
		int64_t iValue;
		struct Object *pobjValue;
		LPTSTR pstrValue;
	};

	int64_t ccValue;

	union
	{
		int64_t iKey;
		LPTSTR pstrKey;
		struct Object *pobjKey;
	};

	union
	{
		int8_t SymbolType;
		int64_t Padding;
	};
};

struct Object
{
	int64_t dummy[2];
	void *pBase;
	Field *pFields;
	int64_t cFields;
	int64_t cFieldsMax;

	int64_t iObjectKeysOffset;
	int64_t iStringKeysOffset;
};

#define SYM_STRING 0
#define PURE_INTEGER 1
#define PURE_FLOAT 2
#define SYM_OPERAND 5
#define SYM_OBJECT 6

int write_dec_int64(int64_t number, LPTSTR *ppszString, DWORD *pcchString);
int write_hex_uint16(TCHAR number, LPTSTR *ppszString, DWORD *pcchString);
int write_escaped(LPTSTR stronk, LPTSTR *ppszString, DWORD *pcchString);

#define write(char)              \
	if (ppszString)              \
		*(*ppszString)++ = char; \
	else                         \
		(*pcchString)++;

#define write_str(str)                \
	for (int i = 0; str[i] != 0; ++i) \
	{                                 \
		write(str[i]);                \
	}

MCL_EXPORT(dumps);
int dumps(Object *pobjIn, LPTSTR *ppszString, DWORD *pcchString, Object *pobjTrue, Object *pobjFalse, Object *pobjNull)
{

	// Check the vtable against a known AHK object to verify it is not a COM object
	if (pobjIn->dummy[0] != pobjNull->dummy[0])
	{
		write_str("\"Unknown_Object_");
		write_dec_int64((int64_t)pobjIn, ppszString, pcchString);
		write('"');
		return 0;
	}

	// Check if the object is a sequentially indexed array
	bool isIndexed = false;
	if (pobjIn->iObjectKeysOffset == pobjIn->cFields) // Are all fields numeric?
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

	// Enumerate fields
	for (int i = 0; i < pobjIn->cFields; i++)
	{
		Field *currentField = pobjIn->pFields + i;

		// Output field separator
		if (i > 0)
		{
			write(',');
			write(' ');
		}

		// Output the key and colon
		if (!isIndexed)
		{
			if (i < pobjIn->iObjectKeysOffset)
			{
				// Integer
				write('"');
				write_dec_int64(currentField->iKey, ppszString, pcchString);
				write('"');
			}
			else if (i < pobjIn->iStringKeysOffset)
			{
				// Object
				write_str("\"Object_");
				write_dec_int64(currentField->iKey, ppszString, pcchString);
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
			write_dec_int64(currentField->iValue, ppszString, pcchString);
		}
		else if (currentField->SymbolType == SYM_OBJECT)
		{
			// Object
			if (currentField->pobjValue == pobjTrue)
			{
				write_str("true");
			}
			else if (currentField->pobjValue == pobjFalse)
			{
				write_str("false");
			}
			else if (currentField->pobjValue == pobjNull)
			{
				write_str("null");
			}
			else
			{
				dumps(currentField->pobjValue, ppszString, pcchString, pobjTrue, pobjFalse, pobjNull);
			}
		}
		else if (currentField->SymbolType == SYM_OPERAND)
		{
			// String
			write_escaped(currentField->pstrValue, ppszString, pcchString);
		}
		else
		{
			// Unknown
			write_str("\"Unknown_Value_");
			write_dec_int64(currentField->iValue, ppszString, pcchString);
			write('"');
		}
	}

	// Output the closing brace
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
		else if (*pt < ' ' || *pt > '~') // outside printable ascii
		{
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

int write_hex_uint16(uint16_t number, LPTSTR *ppszString, DWORD *pcchString)
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

int write_dec_int64(int64_t number, LPTSTR *ppszString, DWORD *pcchString)
{
	// A buffer large enough to fit the longest int64_t (-9223372036854775808)
	TCHAR buffer[20];

	bool sign = 0;
	int i = 0;

	// Check if negative
	if (number < 0)
	{
		sign = 1;
		number = -number;
	}

	// Extract the decimal values
	do
	{
		buffer[i++] = (TCHAR)(number % 10 + '0');
		number /= 10;
	} while (number != 0);

	// Add the negative sign
	if (sign)
		buffer[i++] = '-';

	// Output in reverse-buffer order
	for (--i; i >= 0; --i)
		write(buffer[i]);

	return 0;
}

////////////////////////////////////////////////////////////////////////////////
// Loads
////////////////////////////////////////////////////////////////////////////////

union OutType
{
	int64_t outint;
	double outdub;
	intptr_t outptr;
};

#define skip_whitespace                                                                 \
	while (**ppJson == ' ' || **ppJson == '\n' || **ppJson == '\r' || **ppJson == '\t') \
	{                                                                                   \
		(*ppJson)++;                                                                    \
	}

#define expect_str(str)               \
	for (int i = 0; str[i] != 0; ++i) \
	{                                 \
		if (str[i] != **ppJson)       \
			return -1;                \
		(*ppJson)++;                  \
	}

typedef int fnPush(intptr_t obj, int action, intptr_t value, intptr_t typeValue, intptr_t key, intptr_t typeKey);
typedef intptr_t fnGetObj(int type);

MCL_EXPORT(loads);
int loads(fnPush *pfnPush, fnGetObj *pfnGetObj, short **ppJson, union OutType *pResult, int *pResultType)
{
	pResult->outint = 0;
	*pResultType = 0;

	// Skip over any leading whitespace
	skip_whitespace;

	if (**ppJson == '{') //////////////////////////////////////////////////////////////////////////////////////// Object
	{
		// Skip the open brace
		(*ppJson)++;

		// Get an object from the host script to populate
		intptr_t pObj = (*pfnGetObj)(5);

		// Process key/value pairs
		while (true)
		{
			union OutType tmpKey;
			int tmpKeyType;

			// Break at the end of the object/input
			skip_whitespace;
			if (**ppJson == '}' || **ppJson == 0)
				break;

			// Load the pair key into &tmpKey
			if (loads(pfnPush, pfnGetObj, ppJson, &tmpKey, &tmpKeyType))
				return -1;

			// Skip the colon separator or error on unexpected character
			skip_whitespace;
			if (**ppJson != ':')
				return -1;
			(*ppJson)++;

			// Load the pair value into pResult
			if (loads(pfnPush, pfnGetObj, ppJson, pResult, pResultType))
				return -1;

			// Call the host push function with our key/value pair
			if ((*pfnPush)(pObj, 5, pResult->outptr, *pResultType, tmpKey.outint, tmpKeyType))
				return -1;

			// Skip the comma separator or break on other character
			skip_whitespace;
			if (**ppJson != ',')
				break;
			(*ppJson)++;
		}

		// Skip the closing brace or error on unexpected character
		if (**ppJson != '}')
			return -1;
		(*ppJson)++;

		// Yield the object
		pResult->outptr = pObj;
		*pResultType = 5;
		return 0;
	}
	else if (**ppJson == '[') //////////////////////////////////////////////////////////////////////////////////// Array
	{
		// Skip the opening bracket
		(*ppJson)++;

		// Get an array from the host script to populate
		intptr_t pObj = (*pfnGetObj)(4);

		// Process values pairs
		while (true)
		{
			// Break at the end of the array/input
			skip_whitespace;
			if (**ppJson == ']' || **ppJson == 0)
				break;

			// Load the value into pResult
			if (loads(pfnPush, pfnGetObj, ppJson, pResult, pResultType))
				return -1;

			// Call the host push function with our value
			if ((*pfnPush)(pObj, 4, pResult->outptr, *pResultType, 0, 0))
				return -1;

			// Skip the comma separator or break on other character
			skip_whitespace;
			if (**ppJson != ',')
				break;
			(*ppJson)++;
		}

		// Skip the closing bracket or error on unexpected character
		if (**ppJson != ']')
			return -1;
		(*ppJson)++;

		// Yield the array
		*pResultType = 4;
		pResult->outptr = pObj;
		return 0;
	}
	else if (**ppJson == '"') /////////////////////////////////////////////////////////////////////////////////// String
	{
		// Skip the opening quote
		(*ppJson)++;

		// We'll re-use the area of memory where the encoded string is to form
		// the unescaped string. Use pszOut to point to the end of the
		// output string.
		short *pszOut = *ppJson;

		// Go ahead and set the output pointer before we start advancing pszOut
		pResult->outptr = (intptr_t)pszOut;
		*pResultType = 3;

		while (**ppJson != '"')
		{
			// Error at the unexpected end of the input
			if (**ppJson == 0)
				return -1;

			// Process any escape sequence
			if (**ppJson == '\\')
			{
				// Skip the backslash
				(*ppJson)++;

				if (**ppJson == '"') // Quotation mark
				{
					*pszOut++ = '"';
					(*ppJson)++;
				}
				else if (**ppJson == '\\') // Reverse solidus
				{
					*pszOut++ = '\\';
					(*ppJson)++;
				}
				else if (**ppJson == '/') // Solidus
				{
					*pszOut++ = '/';
					(*ppJson)++;
				}
				else if (**ppJson == 'b') // Backspace
				{
					*pszOut++ = '\b';
					(*ppJson)++;
				}
				else if (**ppJson == 'f') // Form feed
				{
					*pszOut++ = '\f';
					(*ppJson)++;
				}
				else if (**ppJson == 'n') // Line feed
				{
					*pszOut++ = '\n';
					(*ppJson)++;
				}
				else if (**ppJson == 'r') // Return carriage
				{
					*pszOut++ = '\r';
					(*ppJson)++;
				}
				else if (**ppJson == 't') // Tab
				{
					*pszOut++ = '\t';
					(*ppJson)++;
				}
				else if (**ppJson == 'u') // Unicode codepoint
				{
					// Skip the leading 'u'
					(*ppJson)++;

					// Calculate character value from next 4 hex digits
					*pszOut = 0;
					for (int i = 0; i < 4; ++i)
					{
						*pszOut *= 16;
						if (**ppJson >= '0' && **ppJson <= '9')
							*pszOut += **ppJson - '0';
						else if (**ppJson >= 'A' && **ppJson <= 'F')
							*pszOut += **ppJson - 'A' + 10;
						else if (**ppJson >= 'a' && **ppJson <= 'f')
							*pszOut += **ppJson - 'a' + 10;
						else
							return -1;
						(*ppJson)++;
					}

					// Advance the output pointer
					pszOut++;
				}
				else // Unknown character or unexpected null
					return -1;
			}
			else // Perform a 1:1 copy from input to output
				*pszOut++ = *(*ppJson)++;
		}

		*pszOut = 0; // Null terminate
		(*ppJson)++; // Pass end quote

		return 0;
	}
	else if (**ppJson == '-' || (**ppJson >= '0' && **ppJson <= '9')) /////////////////////////////////////////// Number
	{
		// Assume a positive integer, real type checked later
		int polarity = 1;
		pResult->outint = 0;
		*pResultType = 1;

		// Check if negative
		if (**ppJson == '-')
		{
			polarity = -1;
			(*ppJson)++;
		}

		// Process the integer portion
		if (**ppJson == '0') // Just a zero
		{
			pResult->outint = 0;
			(*ppJson)++;
		}
		else if (**ppJson >= '1' && **ppJson <= '9') // Starts with 1-9
		{
			// Process digits 0-9
			while (**ppJson >= '0' && **ppJson <= '9')
				pResult->outint = (pResult->outint * 10) + *(*ppJson)++ - '0';
		}
		else
		{
			return -1;
		}

		// Process the decimal portion
		if (**ppJson == '.')
		{
			// Skip the leading decimal point
			(*ppJson)++;

			// Cast a double from the integer
			pResult->outdub = pResult->outint;
			*pResultType = 2;

			// Process digits 0-9
			int divisor = 1;
			while (**ppJson >= '0' && **ppJson <= '9')
			{
				divisor *= 10;
				pResult->outdub += (double)(*(*ppJson)++ - '0') / divisor;
			}
		}

		// Process any exponential notation
		if (**ppJson == 'e' || **ppJson == 'E')
		{
			// Skip the leading 'e'
			(*ppJson)++;

			// Cast the output to double if it was not already cast to double
			if (*pResultType == 1)
			{
				pResult->outdub = pResult->outint;
				*pResultType = 2;
			}

			// Choose to multiply or divide
			bool divide = false;
			if (**ppJson == '-')
			{
				divide = true;
				(*ppJson)++;
			}
			else if (**ppJson == '+')
			{
				divide = false;
				(*ppJson)++;
			}

			// Error on missing exponent
			if (!(**ppJson >= '0' && **ppJson <= '9'))
				return -1;

			// Process digits 0-9
			int exponent = 0;
			while (**ppJson >= '0' && **ppJson <= '9')
				exponent = (exponent * 10) + (*(*ppJson)++ - '0');

			// Calculate the multiplier/divisor from the exponent
			int factor = 1;
			for (int i = 0; i < exponent; ++i)
				factor *= 10;

			// Apply the multiplier/divisor
			if (divide)
				pResult->outdub /= (double)factor;
			else
				pResult->outdub *= (double)factor;
		}

		// Apply the polarity modifier
		if (*pResultType == 1)
			pResult->outint *= polarity;
		else if (*pResultType == 2)
			pResult->outdub *= polarity;

		return 0;
	}
	else if (**ppJson == 't') ///////////////////////////////////////////// true
	{
		expect_str("true");

		*pResultType = 6;
		pResult->outint = 1;
		return 0;
	}
	else if (**ppJson == 'f') //////////////////////////////////////////// false
	{
		expect_str("false");

		*pResultType = 6;
		pResult->outint = 0;
		return 0;
	}
	else if (**ppJson == 'n') ///////////////////////////////////////////// null
	{ 
		expect_str("null");

		*pResultType = 7;
		pResult->outint = 0;
		return 0;
	}

	return -1;
}
