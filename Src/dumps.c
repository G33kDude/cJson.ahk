
#define UNICODE

#include <MCL.h>
#include <oaidl.h>

#include <stdint.h>
#include <stdbool.h>

typedef struct Object Object;
typedef struct Field Field;

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
int write_hex_uint16(unsigned short number, LPTSTR *ppszString, DWORD *pcchString);
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