namespace Rivet
{
	public enum DataType
	{
		// Exact Numerics
		BigInt,
		Bit,
		Decimal,
		Int,
		Money,
		Numeric,
		SmallInt,
		SmallMoney,
		TinyInt,

		// Approximate Numerics
		Float,
		Real,

		// Date and Time
		Date,
		DateTime2,
		DateTime,
		DateTimeOffset,
		SmallDateTime,
		Time,

		// Character Strings
		Char,
		Text,
		VarChar,

		// Unicode Character Strings
		NChar,
		NText,
		NVarChar,

		// Binary Strings
		Binary,
		Image,
		VarBinary,

		// Other Data Types
		HierarchyID,
		SqlVariant,
		TimeStamp,
		UniqueIdentifier,
		Xml
	}
}