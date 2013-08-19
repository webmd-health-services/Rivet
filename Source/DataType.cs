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
		VarBinary,

		// Other Data Types
		HierarchyID,
		SqlVariant,
		RowVersion,
		UniqueIdentifier,
		Xml,

		// Custom
		Custom
	}
}