
# cJson.ahk

The first and only AutoHotkey JSON library to use embedded compiled C for high
performance.

## Compatibility

This library is compatible with AutoHotkey v2.0 U64 and U32.

## Using cJson

Converting an AHK Object to JSON:

```ahk
#Include <JSON>

; Create an object with every supported data type
obj := ["abc", 123, {true: true, false: false, null: ""}, [JSON.true, JSON.false, JSON.null]]

; Convert to JSON
MsgBox JSON.Dump(obj) ; Expect: ["abc", 123, {"false": 0, "null": "", "true": 1}, [true, false, null]]
```

Converting JSON to an AHK Object:

```ahk
#Include <JSON>

; Create some JSON
str := '["abc", 123, {"true": 1, "false": 0, "null": ""}, [true, false, null]]'
obj := JSON.Load(str)

; Convert using default settings
MsgBox (
	str "`n"
	"`n"
	"obj[1]: " obj[1] " (expect abc)`n"
	"obj[2]: " obj[2] " (expect 123)`n"
	"`n"
	"obj[3]['true']: " obj[3]['true'] " (expect 1)`n"
	"obj[3]['false']: " obj[3]['false'] " (expect 0)`n"
	"obj[3]['null']: " obj[3]['null'] " (expect blank)`n"
	"`n"
	"obj[4][1]: " obj[4][1] " (expect 1)`n"
	"obj[4][2]: " obj[4][2] " (expect 0)`n"
	"obj[4][3]: " obj[4][3] " (expect blank)`n"
)

; Convert Bool and Null values to objects instead of native types
JSON.BoolsAsInts := false
JSON.NullsAsStrings := false
obj := JSON.Load(str)
MsgBox obj[4][1] == JSON.True ; 1
MsgBox obj[4][2] == JSON.False ; 1
MsgBox obj[4][3] == JSON.Null ; 1
```

## Notes

### Data Types

AutoHotkey does not provide types that uniquely identify all the possible values
that may be encoded or decoded. To work around this problem, cJson provides
magic objects that give you greater control over how things are encoded. By
default, cJson will behave according to the following table:

| Value         | Encodes as            | Decodes as            |
|---------------|---------------------- |---------------------- |
| `true`        | `1`                   | `1` *                 |
| `false`       | `0`                   | `0` *                 |
| `null`        | N/A                   | `""` *                |
| `0.1` †       | `0.10000000000000001` | `0.10000000000000001` |
| `JSON.True`   | `true`                | N/A                   |
| `JSON.False`  | `false`               | N/A                   |
| `JSON.Null`   | `null`                | N/A                   |

\* To avoid type data loss when decoding `true` and `false`, the class property
   `JSON.BoolsAsInts` can be set `:= false`. Once set, boolean true and false
   will decode to `JSON.True` and `JSON.False` respectively. Similarly, for
   Nulls `JSON.NullsAsStrings` can be set `:= false`. Once set, null will decode
   to `JSON.Null`.

† In AutoHotkey, numbers with a fractional component are represented internally
  as double-precision floating point values. Floating point values are
  effectively a base-2 fraction, and just like how not all base-10 fractions can
  convert cleanly into base-10 decimals (see: 2/3 to 0.333...) not all base-2
  fractions can convert cleanly into base-10 decimals. This results in
  situations where you write a simple base-10 decimal of 0.1, but it shows as a
  really ugly 0.10000000000000001 when your code displays it. Although
  AutoHotkey v1 used a bunch of tricks to hide this imprecision, such as by
  rounding aggressively to six places and by storing decimal values written in
  your code as strings until used for calculation, AutoHotkey v2 does not try to
  hide this. Similarly, cJson does not either.

## Roadmap

* Allow changing the indent style for pretty print mode.
* Export differently packaged versions of the library (e.g. JSON, cJson, and
  Jxon) for better compatibility.
* Add methods to extract values from the JSON blob without loading the full
  object into memory.
* Add methods to replace values in the JSON blob without fully parsing and
  reformatting the blob.
* Integrate with a future MCLib-hosted COM-based hash-table style object for
  even greater performance.

---

## [Download cJson.ahk](https://github.com/G33kDude/cJson.ahk/releases)