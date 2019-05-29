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
        public Column(string name, DataType dataType, ColumnSize size, Identity identity, bool rowGuidCol, string description, bool fileStream) 
            : this(name, dataType, size, Nullable.NotNull, null, rowGuidCol, null, description, fileStream)
        {
            if (identity != null)
            {
                Identity = identity;
            }
        }

        public Column(string name, DataType dataType, ColumnSize size, Nullable nullable, string collation, bool rowGuidCol, string defaultExpression, string description, bool fileStream)
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

            if (defaultExpression != null)
            {
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

		public ColumnSize Size { get; set; }

		public bool RowGuidCol { get; set; }

		public bool Sparse
		{
			get { return Nullable == Nullable.Sparse; }
		}

		#region Columns
		public static Column BigInt(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.BigInt, null, nullable, null, false, defaultExpression, description, false);
		}

		public static Column BigInt(string name, Identity identity, string description)
		{
			return new Column(name, DataType.BigInt, null, identity, false, description, false);
		}

		public static Column Binary(string name, CharacterLength size, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Binary, size, nullable, null, false, defaultExpression, description, false);
		}

		public static Column Bit(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Bit, null, nullable, null, false, defaultExpression, description, false);
		}

		public static Column Char(string name, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Char, size, nullable, collation, false, defaultExpression, description, false);
		}

		public static Column Date(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Date, null, nullable, null, false, defaultExpression, description, false);
		}

		public static Column DateTime2(string name, Scale size, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.DateTime2, size, nullable, null, false, defaultExpression, description, false);
		}

		public static Column DateTimeOffset(string name, Scale size, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.DateTimeOffset, size, nullable, null, false, defaultExpression, description, false);
		}

		public static Column Decimal(string name, PrecisionScale size, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Decimal, size, nullable, null, false, defaultExpression, description, false);
		}

		public static Column Decimal(string name, PrecisionScale size, Identity identity, string description)
		{
			return new Column(name, DataType.Decimal, size, identity, false, description, false);
		}

		public static Column Float(string name, PrecisionScale size, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Float, size, nullable, null, false, defaultExpression, description, false);
		}

// ReSharper disable InconsistentNaming
		public static Column HierarchyID(string name, Nullable nullable, string defaultExpression, string description)
// ReSharper restore InconsistentNaming
		{
			return new Column(name, DataType.HierarchyID, null, nullable, null, false, defaultExpression, description, false);
		}

		public static Column Int(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Int, null, nullable, null, false, defaultExpression, description, false);
		}

		public static Column Int(string name, Identity identity, string description)
		{
			return new Column(name, DataType.Int, null, identity, false, description, false);
		}

		public static Column Money(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Money, null, nullable, null, false, defaultExpression, description, false);
		}

		public static Column NChar(string name, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.NChar, size, nullable, collation, false, defaultExpression, description, false);
		}

		public static Column NVarChar(string name, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.NVarChar, size, nullable, collation, false, defaultExpression, description, false);
		}

		public static Column Real(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Real, null, nullable, null, false, defaultExpression, description, false);
		}

		public static Column RowVersion(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.RowVersion, null, nullable, null, false, defaultExpression, description, false);
		}

		public static Column SmallDateTime(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.SmallDateTime, null, nullable, null, false, defaultExpression, description, false);
		}

		public static Column SmallInt(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.SmallInt, null, nullable, null, false, defaultExpression, description, false);
		}

		public static Column SmallInt(string name, Identity identity, string description)
		{
			return new Column(name, DataType.SmallInt, null, identity, false, description, false);
		}

		public static Column SmallMoney(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.SmallMoney, null, nullable, null, false, defaultExpression, description, false);
		}

		public static Column SqlVariant(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.SqlVariant, null, nullable, null, false, defaultExpression, description, false);
		}

		public static Column Time(string name, Scale size, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Time, size, nullable, null, false, defaultExpression, description, false);
		}

		public static Column TinyInt(string name, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.TinyInt, null, nullable, null, false, defaultExpression, description, false);
		}

		public static Column TinyInt(string name, Identity identity, string description)
		{
			return new Column(name, DataType.TinyInt, null, identity, false, description, false);
		}

		public static Column UniqueIdentifier(string name, bool rowGuidCol, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.UniqueIdentifier, null, nullable, null, rowGuidCol, defaultExpression, description, false);
		}

		public static Column VarBinary(string name, CharacterLength size, bool filestream, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.VarBinary, size, nullable, null, false, defaultExpression, description, filestream);
		}

		public static Column VarChar(string name, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.VarChar, size, nullable, collation, false, defaultExpression, description, false);
		}

		public static Column Xml(string name, bool isDocument, string xmlSchemaCollection, Nullable nullable, string defaultExpression, string description)
		{
			return new Column(name, DataType.Xml, new XmlPrecisionScale(isDocument, xmlSchemaCollection), nullable, null, false, defaultExpression, description, false);
		}

        public static Column Xml(string name, Nullable nullable, string defaultExpression, string description)
        {
            return new Column(name, DataType.Xml, null, nullable, null, false, defaultExpression, description, false);
        }
        #endregion

		public override string ToString()
		{
			return Name;
		}

		public virtual string GetColumnDefinition(string tableName, string schemaName, bool withValues)
		{
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

			return string.Format("[{0}] {1}{2}{3}{4}{5}{6}{7}{8}{9}", Name, DataType, Size, fileStreamClause, collateClause, identityClause, notNullClause, defaultClause, rowGuidColClause, sparseClause);
		}
	}
}
