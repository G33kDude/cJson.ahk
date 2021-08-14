#ifndef AHK_HEADER
#define AHK_HEADER

#include <windows.h>
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
		struct
		{
			LPTSTR pstrValue;
			SIZE_T ccValue;
		};
		double dblValue;
	};

	union
	{
		INT_PTR iKey;
		LPTSTR pstrKey;
		struct Object *pobjKey;
	};

	int SymbolType;
};

struct Object
{
	void *lpVtbl;
	void *dummy;
	void *pBase;
	Field *pFields;
	intptr_t cFields;
	intptr_t cFieldsMax;

	intptr_t iObjectKeysOffset;
	intptr_t iStringKeysOffset;
};

#define SYM_STRING 0
#define PURE_INTEGER 1
#define PURE_FLOAT 2
#define SYM_OPERAND 5
#define SYM_OBJECT 6

int obj_get_field_str(Object *pobjIn, LPTSTR searchKey, Field **result)
{
	for (int iField = 0; iField < pobjIn->cFields; iField++)
	{
		Field *currentField = &pobjIn->pFields[iField];

		if (iField < pobjIn->iObjectKeysOffset)
		{
			// Integer

			// A buffer large enough to fit the longest int64_t (-9223372036854775808) plus null terminator
			WCHAR str[21];
			str[20] = 0;

			intptr_t key = currentField->iKey;
			bool negative = false;

			// Check if negative
			if (key < 0)
			{
				negative = true;
				key = -key;
			}

			// Extract the decimal values
			int i = 20;
			do
			{
				str[--i] = (WCHAR)(key % 10 + '0');
				key /= 10;
			} while (key != 0);

			if (negative)
			{
				str[--i] = '-';
			}

			WCHAR *a = &str[i];

			bool found = false;
			for (int i = 0;; ++i)
			{
				if (a[i] != searchKey[i])
				{
					break;
				}
				if (a[i] == 0 && searchKey[i] == 0)
				{
					found = true;
					break;
				}
				if (a[i] == 0 || searchKey[i] == 0)
				{
					break;
				}
			}

			if (found)
			{
				*result = currentField;
				return 1;
			}
		}
		else if (iField < pobjIn->iStringKeysOffset)
		{
			// Object
		}
		else
		{
			// String
			WCHAR *a = currentField->pstrKey;

			bool found = false;
			for (int i = 0;; ++i)
			{
				if (a[i] != searchKey[i])
				{
					break;
				}
				if (a[i] == 0 && searchKey[i] == 0)
				{
					found = true;
					break;
				}
				if (a[i] == 0 || searchKey[i] == 0)
				{
					break;
				}
			}

			if (found)
			{
				*result = currentField;
				return 1;
			}
		}
	}

	return 0;
}

#endif // AHK_HEADER