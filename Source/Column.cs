using System;
using static System.String;

namespace Rivet
{
	public enum Nullable
	{
		Null,
		NotNull,
		Sparse
	}

	public sealed class Column
	{
		public Column(string name, DataType dataType, ColumnSize size, Identity identity, bool rowGuidCol, string description, bool fileStream) 
			: this(name, dataType, size, Nullable.NotNull, null, rowGuidCol, null, null, description, fileStream)
		{
			if (identity != null)
			{
				Identity = identity;
			}
		}

		public Column(string name, DataType dataType, ColumnSize size, Nullable nullable, string collation, bool rowGuidCol, 
					  string defaultExpression, string defaultConstraintName, string description, bool fileStream)
		{
			Name = name;
			DataType = dataType;

			if (size != null)
			{
				Size = size;
			}

			Nullable = nullable;

			if (collation != null)
			{
				Collation = collation;
			}

			RowGuidCol = rowGuidCol;

			if (!IsNullOrEmpty(defaultConstraintName))
			{
				DefaultConstraintName = defaultConstraintName;
			}

			if (!IsNullOrEmpty(defaultExpression))
			{
				// TODO: Once default constraint names on columns becomes mandatory, call EnsureDatabaseConstraintName().
				DefaultExpression = defaultExpression;
			}

			if (description != null)
			{
				Description = description;
			}

			FileStream = fileStream;
		}

		public string Collation { get; set; }

		public DataType DataType { get; set; }

		public string CustomDefinition { get; set; }

		public string DefaultExpression { get; set; }

		public string DefaultConstraintName { get; set; }

		public string Description { get; set; }

		public bool FileStream { get; set; }

		public Identity Identity { get; private set; }

		public string Name { get; set; }

		public bool NotNull => Nullable == Nullable.NotNull;

		public bool Null => Nullable == Nullable.Null || Nullable == Nullable.Sparse;

		public Nullable Nullable { get; set; }

		public ColumnSize Size { get; set; }

		public bool RowGuidCol { get; set; }

		public bool Sparse => Nullable == Nullable.Sparse;

		#region Columns
		public static Column BigInt(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.BigInt, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column BigInt(string name, Identity identity, string description)
		{
			return new Column(name, DataType.BigInt, null, identity, false, description, false);
		}

		public static Column Binary(string name, CharacterLength size, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.Binary, size, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column Bit(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.Bit, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column Char(string name, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.Char, size, nullable, collation, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column Date(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.Date, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column DateTime2(string name, Scale size, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.DateTime2, size, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column DateTimeOffset(string name, Scale size, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.DateTimeOffset, size, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column Decimal(string name, PrecisionScale size, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.Decimal, size, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column Decimal(string name, PrecisionScale size, Identity identity, string description)
		{
			return new Column(name, DataType.Decimal, size, identity, false, description, false);
		}

		public static Column Float(string name, PrecisionScale size, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.Float, size, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

// ReSharper disable InconsistentNaming
		public static Column HierarchyID(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
// ReSharper restore InconsistentNaming
		{
			return new Column(name, DataType.HierarchyID, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column Int(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.Int, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column Int(string name, Identity identity, string description)
		{
			return new Column(name, DataType.Int, null, identity, false, description, false);
		}

		public static Column Money(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.Money, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column NChar(string name, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.NChar, size, nullable, collation, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column NVarChar(string name, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.NVarChar, size, nullable, collation, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column Real(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.Real, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column RowVersion(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.RowVersion, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column SmallDateTime(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.SmallDateTime, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column SmallInt(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.SmallInt, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column SmallInt(string name, Identity identity, string description)
		{
			return new Column(name, DataType.SmallInt, null, identity, false, description, false);
		}

		public static Column SmallMoney(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.SmallMoney, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column SqlVariant(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.SqlVariant, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column Time(string name, Scale size, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.Time, size, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column TinyInt(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.TinyInt, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column TinyInt(string name, Identity identity, string description)
		{
			return new Column(name, DataType.TinyInt, null, identity, false, description, false);
		}

		public static Column UniqueIdentifier(string name, bool rowGuidCol, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.UniqueIdentifier, null, nullable, null, rowGuidCol, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column VarBinary(string name, CharacterLength size, bool fileStream, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.VarBinary, size, nullable, null, false, defaultExpression, defaultConstraintName, description, fileStream);
		}

		public static Column VarChar(string name, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.VarChar, size, nullable, collation, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column Xml(string name, bool isDocument, string xmlSchemaCollection, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.Xml, new XmlPrecisionScale(isDocument, xmlSchemaCollection), nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}

		public static Column Xml(string name, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			return new Column(name, DataType.Xml, null, nullable, null, false, defaultExpression, defaultConstraintName, description, false);
		}
		#endregion

		public override string ToString()
		{
			return Name;
		}

		public string GetColumnDefinition(bool withValues)
		{
			var fileStreamClause = "";
			if (FileStream)
			{
				// ReSharper disable once StringLiteralTypo
				fileStreamClause = " filestream";
			}

			var collateClause = "";
			if (!IsNullOrEmpty(Collation))
			{
				collateClause = $" collate {Collation}";
			}

			var notNullClause = "";
			var sparseClause = "";
			if (NotNull)
			{
				notNullClause = " not null";
			}
			else
			{
				if (Sparse)
				{
					sparseClause = " sparse";
				}
			}

			var identityClause = "";
			if (Identity != null)
			{
				identityClause = $" {Identity}";
			}

			var defaultClause = "";
			if (!IsNullOrEmpty(DefaultExpression))
			{
				EnsureDefaultConstraintName();

				var withValuesClause = "";
				if (withValues)
				{
					withValuesClause = " with values";
				}
				defaultClause = $" constraint [{DefaultConstraintName}] default {DefaultExpression}{withValuesClause}";
			}

			var rowGuidColClause = "";
			if (RowGuidCol)
			{
				// ReSharper disable once StringLiteralTypo
				rowGuidColClause = " rowguidcol";
			}

			return
				$"[{Name}] {DataType}{Size}{fileStreamClause}{collateClause}{identityClause}{notNullClause}{defaultClause}{rowGuidColClause}{sparseClause}";
		}

		private void EnsureDefaultConstraintName()
		{
			if (IsNullOrEmpty(DefaultConstraintName))
			{
				throw new ApplicationException(
					$"Missing {Name} column's default constraint name. When creating a column with a default value, you must also provide the name of the default constraint to create.");
			}
		}
	}
}
