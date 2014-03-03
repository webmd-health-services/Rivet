namespace Rivet
{
	public enum Nullable
	{
		Null,
		NotNull,
		Sparse
	}

	public class Column
	{
		private Column(string name, DataType dataType, PrecisionScale size, string collation, Nullable nullable, string defaultExpression, string description)
			: this(name, dataType, defaultExpression, description)
		{
			if (size != null)
			{
				Size = size;
			}

			if (!string.IsNullOrEmpty(collation))
			{
				Collation = collation;
			}

			Nullable = nullable;
		}

		private Column(string name, DataType dataType, PrecisionScale size, Nullable nullable, string defaultExpression, string description)
			: this(name, dataType, defaultExpression, description)
		{
			if (size != null)
			{
				Size = size;
			}
			Nullable = nullable;
		}

		private Column(string name, DataType dataType, PrecisionScale size, bool filestream, Nullable nullable, string defaultExpression, string description)
			: this(name, dataType, defaultExpression, description)
		{
			if (size != null)
			{
				Size = size;
			}
			Nullable = nullable;
			FileStream = filestream;
		}

		private Column(string name, DataType dataType, Nullable nullable, string defaultExpression, string description)
			: this(name, dataType, defaultExpression, description)
		{
			Nullable = nullable;
		}

		private Column(string name, DataType dataType, Identity identity, string description)
			: this(name, dataType, (string)null, description)
		{
			Identity = identity;
			Nullable = Nullable.NotNull;
		}

		private Column(string name, DataType dataType, PrecisionScale size, Identity identity, string description)
			: this(name, dataType, (string)null, description)
		{
			if (size != null)
			{
				Size = size;
			}

			Identity = identity;
			Nullable = Nullable.NotNull;
		}

		public Column(string name, string definition, Nullable nullable, string defaultExpression, string description)
			: this(name, DataType.Custom, defaultExpression, description)
		{
			CustomDefinition = definition;
			Nullable = nullable;
		}

		private Column(string name, DataType dataType, string defaultExpression, string description)
		{
			Name = name;
			DataType = dataType;

			if (defaultExpression != null)
			{
				DefaultExpression = defaultExpression;
			}

			if (description != null)
			{
				Description = description;
			}
			
		}

		private Column(string name, DataType dataType, bool rowGuidCol, Nullable nullable, string defaultExpression, string description)
			: this(name, dataType, defaultExpression, description)
		{
			RowGuidCol = rowGuidCol;
			Nullable = nullable;
		}

		public string Collation { get; set; }

		public DataType DataType { get; set; }

		public string CustomDefinition { get; set; }

		public string DefaultExpression { get; set; }

		public string Description { get; set; }

		public bool FileStream { get; set; }

		public Identity Identity { get; private set; }

		public string Name { get; set; }

		public bool NotNull
		{
			get { return Nullable == Nullable.NotNull; }
		}

		public bool Null
		{
			get { return Nullable == Nullable.Null || Nullable == Nullable.Sparse; }
		}

		public Nullable Nullable { get; set; }

		public PrecisionScale Size { get; set; }

		public bool RowGuidCol { get; set; }

		public bool Sparse
		{
			get { return Nullable == Nullable.Sparse; }
		}

		#region Columns
		public static Column BigInt(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.BigInt, nullable, defaultExpression, description);
		}

		public static Column BigInt(string name, Identity identity, string description)
		{
			return new Column(name, DataType.BigInt, identity, description);
		}

		public static Column Binary(string name, CharacterLength size, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Binary, size, nullable, defaultExpression, description);
		}

		public static Column Bit(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Bit, nullable, defaultExpression, description);
		}

		public static Column Char(string name, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Char, size, collation, nullable, defaultExpression, description);
		}

		public static Column Date(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Date, nullable, defaultExpression, description);
		}

		public static Column DateTime2(string name, PrecisionScale size, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.DateTime2, size, nullable, defaultExpression, description);
		}

		public static Column DateTimeOffset(string name, PrecisionScale size, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.DateTimeOffset, size, nullable, defaultExpression, description);
		}

		public static Column Decimal(string name, PrecisionScale size, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Decimal, size, nullable, defaultExpression, description);
		}

		public static Column Decimal(string name, PrecisionScale size, Identity identity, string description)
		{
			return new Column(name, DataType.Decimal, size, identity, description);
		}

		public static Column Float(string name, PrecisionScale size, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Float, size, nullable, defaultExpression, description);
		}

// ReSharper disable InconsistentNaming
		public static Column HierarchyID(string name, Nullable nullable, string defaultExpression, string description)
// ReSharper restore InconsistentNaming
		{
			return new Column(name, DataType.HierarchyID, nullable, defaultExpression, description);
		}

		public static Column Int(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Int, nullable, defaultExpression, description);
		}

		public static Column Int(string name, Identity identity, string description)
		{
			return new Column(name, DataType.Int, identity, description);
		}

		public static Column Money(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Money, nullable, defaultExpression, description);
		}

		public static Column NChar(string name, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.NChar, size, collation, nullable, defaultExpression, description);
		}

		public static Column NVarChar(string name, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.NVarChar, size ?? new CharacterLength(), collation, nullable, defaultExpression, description);
		}

		public static Column Real(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Real, nullable, defaultExpression, description);
		}

		public static Column RowVersion(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.RowVersion, nullable, defaultExpression, description);
		}

		public static Column SmallDateTime(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.SmallDateTime, nullable, defaultExpression, description);
		}

		public static Column SmallInt(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.SmallInt, nullable, defaultExpression, description);
		}

		public static Column SmallInt(string name, Identity identity, string description)
		{
			return new Column(name, DataType.SmallInt, identity, description);
		}

		public static Column SmallMoney(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.SmallMoney, nullable, defaultExpression, description);
		}

		public static Column SqlVariant(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.SqlVariant, nullable, defaultExpression, description);
		}

		public static Column Time(string name, PrecisionScale size, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Time, size, nullable, defaultExpression, description);
		}

		public static Column TinyInt(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.TinyInt, nullable, defaultExpression, description);
		}

		public static Column TinyInt(string name, Identity identity, string description)
		{
			return new Column(name, DataType.TinyInt, identity, description);
		}

		public static Column UniqueIdentifier(string name, bool rowGuidCol, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.UniqueIdentifier, rowGuidCol, nullable, defaultExpression, description);
		}

		public static Column VarBinary(string name, CharacterLength size, bool filestream, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.VarBinary, size ?? new CharacterLength(), filestream, nullable, defaultExpression, description);
		}

		public static Column VarChar(string name, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.VarChar, size ?? new CharacterLength(), collation, nullable, defaultExpression, description);
		}

		public static Column Xml(string name, bool isDocument, string xmlSchemaCollection, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Xml, new XmlPrecisionScale(isDocument, xmlSchemaCollection), nullable, defaultExpression, description);
		}
		#endregion

		public override string ToString()
		{
			return Name;
		}

		public virtual string GetColumnDefinition(string tableName, string schemaName, bool withValues)
		{
			string dataTypeClause = DataType.ToString().ToLowerInvariant();
			if (DataType == DataType.Custom)
			{
				dataTypeClause = CustomDefinition;
			}
			else if (DataType == DataType.SqlVariant)
			{
				dataTypeClause = "sql_variant";
			}

			var fileStreamClause = "";
			if (FileStream)
			{
				fileStreamClause = " filestream";
			}

			var collateClause = "";
			if (!string.IsNullOrEmpty(Collation))
			{
				collateClause = string.Format(" collate {0}", Collation);
			}

			var identityClause = "";
			var notNullClause = "";
			if (Identity == null)
			{
				if (NotNull)
				{
					notNullClause = " not null";
				}
			}
			else
			{
				identityClause = string.Format(" {0}", Identity);
			}

			var defaultClause = "";
			if (!string.IsNullOrEmpty(DefaultExpression))
			{
				var constraintName = new ConstraintName(schemaName, tableName, new[] {this.Name}, ConstraintType.Default);
				var withValuesClause = "";
				if (withValues)
				{
					withValuesClause = " with values";
				}
				defaultClause = string.Format(" constraint [{0}] default {1}{2}", constraintName, DefaultExpression, withValuesClause);
			}

			var rowGuidColClause = "";
			if (RowGuidCol)
			{
				rowGuidColClause = " rowguidcol";
			}

			var sparseClause = "";
			if (Sparse)
			{
				sparseClause = " sparse";
			}

			return string.Format("[{0}] {1}{2}{3}{4}{5}{6}{7}{8}{9}", Name, dataTypeClause, Size, fileStreamClause, collateClause, notNullClause, defaultClause, identityClause, rowGuidColClause, sparseClause);
		}
	}
}
