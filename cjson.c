
#define MCODE_LIBRARY
#include "ahk.h"
typedef uint32_t DWORD;

#include <stdint.h>
#include <stdbool.h>

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

int itow(int64_t number, LPTSTR *ppszString, DWORD *pcchString);
int itoh(TCHAR number, LPTSTR *ppszString, DWORD *pcchString);
int escape(LPTSTR stronk, LPTSTR *ppszString, DWORD *pcchString);

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

MCODE_EXPORT(dumps);
int dumps(Object *pobjIn, LPTSTR *ppszString, DWORD *pcchString, Object *pobjTrue, Object *pobjFalse, Object *pobjNull)
{

	// Probably a COM Object -- or an empty object, apparently
	if (pobjIn->dummy[0] != pobjNull->dummy[0])
	{
		write_str("\"Unknown_Object_");
		itow((int64_t)pobjIn, ppszString, pcchString);
		write('"');
		return 0;

	}
	// if (!pobjIn->pFields)
	// {
	// }

	// Check if the object is a sequentially indexed array
	bool isIndexed = true;
	if (pobjIn->iObjectKeysOffset == pobjIn->cFields)
	{ // All numeric fields
		for (int i = 0; isIndexed && i < pobjIn->cFields; i++)
		{
			Field *currentField = pobjIn->pFields + i;
			isIndexed = currentField->iKey == i + 1;
		}
	}
	else
	{
		isIndexed = false;
	}

	// Output opening brace
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

		if (!isIndexed)
		{
			// Output key
			if (i < pobjIn->iObjectKeysOffset)
			{
				// Integer
				write('"');
				itow(currentField->iKey, ppszString, pcchString);
				write('"');
			}
			else if (i < pobjIn->iStringKeysOffset)
			{
				// Object
				write_str("\"Object_");
				itow(currentField->iKey, ppszString, pcchString);
				write('"');
			}
			else
			{
				// String
				escape(currentField->pstrKey, ppszString, pcchString);
			}

			// Output colon key-value separator
			write(':');
			write(' ');
		}

		// Output Value
		if (currentField->SymbolType == SYM_OPERAND)
		{
			// String
			escape(currentField->pstrValue, ppszString, pcchString);
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
		else if (currentField->SymbolType == PURE_INTEGER)
		{
			// Integer
			itow(currentField->iValue, ppszString, pcchString);
		}
		else
		{
			// Unknown
			write_str("\"Unknown_Value_");
			itow(currentField->iValue, ppszString, pcchString);
			write('"');
		}
	}

	// Output closing brace
	write(isIndexed ? ']' : '}');

	return 0;
}

int escape(LPTSTR pt, LPTSTR *ppszString, DWORD *pcchString)
{
	// String
	write('"');
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
			itoh(*pt, ppszString, pcchString);
		}
		else
		{
			write(*pt);
		}
	}
	write('"');
}

int itoh(TCHAR number, LPTSTR *ppszString, DWORD *pcchString)
{
	TCHAR buf[4];
	char *lookup = "0123456789ABCDEF";

	// Extract the hex values
	for (int i = 0; i < 4; ++i)
	{
		// buf[i] = number % 16 + 'A'; //lookup[number % 16];
		buf[i] = lookup[number % 16];
		number /= 16;
	}

	for (int i = 3; i >= 0; --i)
	{
		write(buf[i]);
	}

	return 0;
}

int itow(int64_t number, LPTSTR *ppszString, DWORD *pcchString)
{
	// write('&');
	// return 0;

	// enough to fit the longest int64_t -9223372036854775808
	TCHAR buf[20];

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
		buf[i++] = (TCHAR)(number % 10 + '0');
		number /= 10;
	} while (number != 0);

	// Add the negative sign
	if (sign)
	{
		buf[i++] = '-';
	}

	// Reverse area of memory
	// for (int j = 0; j*2 < i; j++) {
	//	 TCHAR t = buf[j];
	//	 buf[j] = buf[i-1-j];
	//	 buf[i-1-j] = t;
	// }

	for (--i; i >= 0; --i)
	{
		write(buf[i]);
	}

	return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Loads
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

union OutType
{
	int64_t outint;
	double outdub;
	intptr_t outptr;
};

#define skipws                                                                          \
	while (**ppJson == ' ' || **ppJson == '\n' || **ppJson == '\r' || **ppJson == '\t') \
	{                                                                                   \
		(*ppJson)++;                                                                    \
	}

typedef int fnPush(intptr_t obj, int action, intptr_t value, intptr_t typeValue, intptr_t key, intptr_t typeKey);
typedef intptr_t fnGetObj(int type);

MCODE_EXPORT(loads);
int loads(fnPush *pfnPush, fnGetObj *pfnGetObj, short **ppJson, union OutType *pResult, int *pResultType)
{
	pResult->outint = 0;
	*pResultType = 0;

	skipws if (**ppJson == '{')
	{									 ///////////////////////////////////////////////////////////////// Object
		intptr_t pObj = (*pfnGetObj)(5); // Get object from host script
		(*ppJson)++;					 // Open brace

		while (**ppJson != 0)
		{
			union OutType tmpKey;
			int tmpKeyType;
			skipws;
			if (**ppJson == '}')
			{
				break;
			} // Close brace check
			if (loads(pfnPush, pfnGetObj, ppJson, &tmpKey, &tmpKeyType))
			{
				return -1;
			} // Key

			skipws;
			if (**ppJson != ':')
			{
				return -1;
			}
			(*ppJson)++; // Colon
			if (loads(pfnPush, pfnGetObj, ppJson, pResult, pResultType))
			{
				return -1;
			}													   // Value
			if ((*pfnPush)(pObj, 5, pResult->outptr, *pResultType, // Push
						   tmpKey.outint, tmpKeyType))
			{
				return -1;
			} // ^^^^
			skipws;
			if (**ppJson != ',')
			{
				break;
			}
			(*ppJson)++; // Comma check
		}

		if (**ppJson != '}')
		{
			return -1;
		}
		(*ppJson)++; // Close brace

		pResult->outptr = pObj;
		*pResultType = 5;

		return 0;
	}
	else if (**ppJson == '[')
	{									 ////////////////////////////////////////////////////////// Array
		intptr_t pObj = (*pfnGetObj)(4); // Get array from host script
		(*ppJson)++;					 // Open bracket

		while (**ppJson != 0)
		{
			skipws;
			if (**ppJson == ']')
			{
				break;
			} // Close bracket check
			if (loads(pfnPush, pfnGetObj, ppJson, pResult, pResultType))
			{
				return -1;
			} // Value
			if ((*pfnPush)(pObj, 4, pResult->outptr, *pResultType, 0, 0))
			{
				return -1;
			} // Push
			skipws;
			if (**ppJson != ',')
			{
				break;
			}
			(*ppJson)++; // Comma check
		}

		if (**ppJson != ']')
		{
			return -1;
		}
		(*ppJson)++; // Close bracket

		*pResultType = 4;
		pResult->outptr = pObj;

		return 0;
	}
	else if (**ppJson == '"')
	{ ////////////////////////////////////////////////////////// String
		short *pTarget = *ppJson;
		pResult->outptr = (intptr_t)*ppJson;
		*pResultType = 3;
		(*ppJson)++;

		while (**ppJson != '"')
		{

			if (**ppJson == 0)
			{
				return -1;
			} // Unexpected null
			else if (**ppJson == '\\')
			{				 // Escape sequence
				(*ppJson)++; // Move past backslash

				if (**ppJson == '"')
				{
					*pTarget = '"';
					pTarget++;
					(*ppJson)++;
				} // Quotation mark
				else if (**ppJson == '\\')
				{
					*pTarget = '\\';
					pTarget++;
					(*ppJson)++;
				} // Reverse solidus
				else if (**ppJson == '/')
				{
					*pTarget = '/';
					pTarget++;
					(*ppJson)++;
				} // Solidus
				else if (**ppJson == 'b')
				{
					*pTarget = '\b';
					pTarget++;
					(*ppJson)++;
				} // Backspace
				else if (**ppJson == 'f')
				{
					*pTarget = '\f';
					pTarget++;
					(*ppJson)++;
				} // Form feed
				else if (**ppJson == 'n')
				{
					*pTarget = '\n';
					pTarget++;
					(*ppJson)++;
				} // Line feed
				else if (**ppJson == 'r')
				{
					*pTarget = '\r';
					pTarget++;
					(*ppJson)++;
				} // Return carriage
				else if (**ppJson == 't')
				{
					*pTarget = '\t';
					pTarget++;
					(*ppJson)++;
				} // Tab
				else if (**ppJson == 'u')
				{ // Unicode codepoint

					*pTarget = 0;
					for (int i = 0; i < 4; ++i)
					{
						(*ppJson)++;
						*pTarget *= 16;
						if (**ppJson >= '0' && **ppJson <= '9')
						{
							*pTarget += **ppJson - '0';
						}
						else if (**ppJson >= 'A' && **ppJson <= 'F')
						{
							*pTarget += **ppJson - 'A' + 10;
						}
						else if (**ppJson >= 'a' && **ppJson <= 'f')
						{
							*pTarget += **ppJson - 'a' + 10;
						}
						else
						{
							return -1;
						}
					}
					pTarget++;
					(*ppJson)++;
				}
				else
				{
					return -1;
				} // Unknown character or null
			}
			else
			{

				// Copy character to target and increase both pointers
				*pTarget = **ppJson;
				pTarget++;
				(*ppJson)++;
			}
		}

		*pTarget = 0; // Null terminate
		(*ppJson)++;  // Pass end quote

		return 0;
	}
	else if (**ppJson == '-' || (**ppJson >= '0' && **ppJson <= '9'))
	{ ////////////////// Number
		int polarity = 1;
		pResult->outint = 0;
		*pResultType = 1;

		if (**ppJson == '-')
		{
			polarity = -1;
			(*ppJson)++;
		} // Negative

		if (**ppJson == '0')
		{
			pResult->outint = 0;
			(*ppJson)++;
		} // Just Zero
		else if (**ppJson >= '1' && **ppJson <= '9')
		{ // if 1-9 then
			while (**ppJson >= '0' && **ppJson <= '9')
			{									   //   for digit 0-9+
				pResult->outint *= 10;			   //     output *= 10
				pResult->outint += **ppJson - '0'; //     output += digit
				(*ppJson)++;
			}
		}
		else
		{
			return -1;
		}

		// Decimal
		if (**ppJson == '.')
		{
			(*ppJson)++;
			pResult->outdub = pResult->outint;
			*pResultType = 2;
			int divisor = 1;
			while (**ppJson >= '0' && **ppJson <= '9')
			{
				divisor *= 10;
				pResult->outdub += (double)(**ppJson - '0') / divisor;
				(*ppJson)++;
			}
		}

		// Exponentation
		if (**ppJson == 'e' || **ppJson == 'E')
		{
			(*ppJson)++;
			if (*pResultType == 1)
			{ // Cast to double if necessary
				pResult->outdub = pResult->outint;
				*pResultType = 2;
			}

			// Choose to multiply or divide
			int divide = 0;
			if (**ppJson == '-')
			{
				divide = 1;
				(*ppJson)++;
			}
			else if (**ppJson == '+')
			{
				divide = 0;
				(*ppJson)++;
			}

			// Decode exponent
			int exponent = 0;
			if (!(**ppJson >= '0' && **ppJson <= '9'))
			{
				return -1;
			}
			while (**ppJson >= '0' && **ppJson <= '9')
			{
				exponent = (exponent * 10) + (**ppJson - '0');
				(*ppJson)++;
			}

			// Apply the exponent
			int factor = 1;
			for (int i = 0; i < exponent; ++i)
			{
				factor *= 10;
			}
			if (divide)
			{
				pResult->outdub /= (double)factor;
			}
			else
			{
				pResult->outdub *= (double)factor;
			}
			// if (divide) { for (int i = 0; i < exponent; ++i) { pResult->outdub /= 10; } }
			// else { for (int i = 0; i < exponent; ++i) { pResult->outdub *= 10; } }
		}

		if (*pResultType == 1)
			pResult->outint *= polarity;
		else if (*pResultType == 2)
			pResult->outdub *= polarity;

		return 0;
	}
	else if (**ppJson == 't')
	{ ////////////////////////////////////////////////////////// true
		(*ppJson)++;
		if (**ppJson != 'r')
		{
			return -1;
		}
		(*ppJson)++;
		if (**ppJson != 'u')
		{
			return -1;
		}
		(*ppJson)++;
		if (**ppJson != 'e')
		{
			return -1;
		}
		(*ppJson)++;
		*pResultType = 6;
		pResult->outint = 1;
		return 0;
	}
	else if (**ppJson == 'f')
	{ ///////////////////////////////////////////////////////// false
		(*ppJson)++;
		if (**ppJson != 'a')
		{
			return -1;
		}
		(*ppJson)++;
		if (**ppJson != 'l')
		{
			return -1;
		}
		(*ppJson)++;
		if (**ppJson != 's')
		{
			return -1;
		}
		(*ppJson)++;
		if (**ppJson != 'e')
		{
			return -1;
		}
		(*ppJson)++;
		*pResultType = 6;
		pResult->outint = 0;
		return 0;
	}
	else if (**ppJson == 'n')
	{ ///////////////////////////////////////////////////////// null
		(*ppJson)++;
		if (**ppJson != 'u')
		{
			return -1;
		}
		(*ppJson)++;
		if (**ppJson != 'l')
		{
			return -1;
		}
		(*ppJson)++;
		if (**ppJson != 'l')
		{
			return -1;
		}
		(*ppJson)++;
		*pResultType = 7;
		pResult->outint = 0;
		return 0;
	}

	return -1;
}
