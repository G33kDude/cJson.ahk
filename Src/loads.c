
#include "shared.h"

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

void comobjset(IDispatch *pObj, BSTR key, VARIANT *value)
{
	// Get the DispID for DISPATCH_PROPERTYPUT
	DISPID dispid = 0;
	pObj->lpVtbl->GetIDsOfNames(pObj, NULL, &key, 1, 0, &dispid);

	// Set the property
	DISPPARAMS dispparams = {
		.cArgs = 1,
		.cNamedArgs = 0,
		.rgvarg = value};
	pObj->lpVtbl->Invoke(pObj, dispid, NULL, 0, DISPATCH_PROPERTYPUT, &dispparams, NULL, NULL, NULL);

	// Decrement the reference count of the object given by pfnGetObj
	if (value->vt == VT_DISPATCH)
	{
		value->pdispVal->lpVtbl->Release(value->pdispVal);
	}
	else if (value->vt == VT_I4 && (value->llVal > 2147483647 || value->llVal < -2147483648)) // Fix integer overflow
	{
		Field *field;
		if (obj_get_field_str((Object *)pObj, key, &field))
		{
			field->iValue = value->llVal;
		}
	}
}

void comobjset_i(IDispatch *pObj, unsigned int key, VARIANT *value)
{
	// A buffer large enough to fit the longest uint64_t (18446744073709551615) plus null terminator
	short str[21];
	str[20] = 0;

	unsigned int n = key;

	// Extract the decimal values
	int i = 20;
	do
	{
		str[--i] = (short)(key % 10 + '0');
		key /= 10;
	} while (key != 0);

	comobjset(pObj, &str[i], value);
}

BSTR pszEmpty = { 0 };

MCL_EXPORT(loads);
int loads(short **ppJson, VARIANT *pResult)
{
	pResult->vt = VT_I8;
	pResult->llVal = 0;

	// Skip over any leading whitespace
	skip_whitespace;

	if (**ppJson == '{') //////////////////////////////////////////////////////////////////////////////////////// Object
	{
		// Skip the open brace
		(*ppJson)++;

		// Get an object from the host script to populate
		DISPPARAMS dispparams = {.cArgs = 0, .cNamedArgs = 0};
		VARIANT pObjVt;
		fnGetObj->lpVtbl->Invoke(fnGetObj, 0, NULL, 0, DISPATCH_METHOD, &dispparams, &pObjVt, NULL, NULL);
		IDispatch *pObj = pObjVt.pdispVal;

		// Process key/value pairs
		while (true)
		{
			VARIANT tmpKey;

			// Break at the end of the object/input
			skip_whitespace;
			if (**ppJson == '}' || **ppJson == 0)
				break;

			// Require string keys
			if (**ppJson != '"')
				return -1;

			// Load the pair key into &tmpKey
			if (loads(ppJson, &tmpKey))
				return -1;

			// Skip the colon separator or error on unexpected character
			skip_whitespace;
			if (**ppJson != ':')
				return -1;
			(*ppJson)++;

			// Load the pair value into pResult
			if (loads(ppJson, pResult))
				return -1;

			comobjset(pObj, tmpKey.bstrVal, pResult);

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
		pResult->vt = VT_DISPATCH;
		pResult->pdispVal = pObj;
		return 0;
	}
	else if (**ppJson == '[') //////////////////////////////////////////////////////////////////////////////////// Array
	{
		// Skip the opening bracket
		(*ppJson)++;

		// Get an array from the host script to populate
		DISPPARAMS dispparams = {.cArgs = 0, .cNamedArgs = 0};
		VARIANT pObjVt;
		fnGetObj->lpVtbl->Invoke(fnGetObj, 0, NULL, 0, DISPATCH_METHOD, &dispparams, &pObjVt, NULL, NULL);
		IDispatch *pObj = pObjVt.pdispVal;

		// Process values pairs
		for (unsigned int keyNum = 1;; ++keyNum)
		{
			// Break at the end of the array/input
			skip_whitespace;
			if (**ppJson == ']' || **ppJson == 0)
				break;

			// Load the value into pResult
			if (loads(ppJson, pResult))
				return -1;

			comobjset_i(pObj, keyNum, pResult);

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
		pResult->vt = VT_DISPATCH;
		pResult->pdispVal = pObj;
		return 0;
	}
	else if (**ppJson == '"') /////////////////////////////////////////////////////////////////////////////////// String
	{
		// Skip the opening quote
		(*ppJson)++;

		// We'll re-use the area of memory where the encoded string is to form
		// the unescaped string. Use pszOut to point to the end of the
		// output string.
		BSTR pszOut = *ppJson;

		// Go ahead and set the output pointer before we start advancing pszOut
		pResult->bstrVal = pszOut;
		pResult->vt = VT_BSTR;

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

		// Populate the BSTR size prefix
		*((uint32_t *)(pResult->bstrVal - 2)) = (pszOut - pResult->bstrVal) * 2;

		*pszOut = 0; // Null terminate
		(*ppJson)++; // Pass end quote

		return 0;
	}
	else if (**ppJson == '-' || (**ppJson >= '0' && **ppJson <= '9')) /////////////////////////////////////////// Number
	{
		// Assume a positive integer, real type checked later
		int polarity = 1;
		pResult->vt = VT_I8;
		pResult->llVal = 0;

		// Check if negative
		if (**ppJson == '-')
		{
			polarity = -1;
			(*ppJson)++;
		}

		// Process the integer portion
		if (**ppJson == '0') // Just a zero
		{
			pResult->llVal = 0;
			(*ppJson)++;
		}
		else if (**ppJson >= '1' && **ppJson <= '9') // Starts with 1-9
		{
			// Process digits 0-9
			while (**ppJson >= '0' && **ppJson <= '9')
				pResult->llVal = (pResult->llVal * 10) + *(*ppJson)++ - '0';
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
			pResult->dblVal = pResult->llVal;
			pResult->vt = VT_R8;

			// Process digits 0-9
			int divisor = 1;
			while (**ppJson >= '0' && **ppJson <= '9')
			{
				divisor *= 10;
				pResult->dblVal += (double)(*(*ppJson)++ - '0') / divisor;
			}
		}

		// Process any exponential notation
		if (**ppJson == 'e' || **ppJson == 'E')
		{
			// Skip the leading 'e'
			(*ppJson)++;

			// Cast the output to double if it was not already cast to double
			if (pResult->vt == VT_I8)
			{
				pResult->dblVal = pResult->llVal;
				pResult->vt = VT_R8;
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
				pResult->dblVal /= (double)factor;
			else
				pResult->dblVal *= (double)factor;
		}

		// Apply the polarity modifier
		if (pResult->vt == VT_I8)
			pResult->llVal *= polarity;
		else if (pResult->vt == VT_R8)
			pResult->dblVal *= polarity;

		// AHK workaround for setting pure integer values
		// Native object code will fix any overflow problems
		if (pResult->vt == VT_I8)
		{
			pResult->vt = VT_I4;
		}

		return 0;
	}
	else if (**ppJson == 't') ///////////////////////////////////////////// true
	{
		expect_str("true");

		if (bBoolsAsInts)
		{
			pResult->vt = VT_I4;
			pResult->llVal = 1;
		}
		else
		{
			pResult->vt = VT_DISPATCH;
			pResult->pdispVal = objTrue;
			objTrue->lpVtbl->AddRef(objTrue);
		}
		return 0;
	}
	else if (**ppJson == 'f') //////////////////////////////////////////// false
	{
		expect_str("false");

		if (bBoolsAsInts)
		{
			pResult->vt = VT_I4;
			pResult->llVal = 0;
		}
		else
		{
			pResult->vt = VT_DISPATCH;
			pResult->pdispVal = objFalse;
			objFalse->lpVtbl->AddRef(objFalse);
		}
		return 0;
	}
	else if (**ppJson == 'n') ///////////////////////////////////////////// null
	{
		expect_str("null");

		if (bNullsAsStrings)
		{
			pResult->vt = VT_BSTR;
			pResult->bstrVal = pszEmpty;
		}
		else
		{
			pResult->vt = VT_DISPATCH;
			pResult->pdispVal = objNull;
			objNull->lpVtbl->AddRef(objNull);
		}
		return 0;
	}

	return -1;
}