using NUnit.Framework;

namespace Rivet.Test
{
	[TestFixture]
	internal sealed class ColumnTestFixture
	{

		private static readonly PrecisionScale PrecisionNoScale = new PrecisionScale(4);
		private static readonly PrecisionScale PrecisionWithScale = new PrecisionScale(4, 2);
		private static readonly PrecisionScale[] Precisions = new [] { PrecisionNoScale, PrecisionWithScale};

		private Column _column;

		[SetUp]
		public void SetUp()
		{
			_column = null;
		}

		#region BigInt
		[Test]
		public void ShouldCreateBigIntColumn(
			[Values("BigInt")]
			string name, 

			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable,

			[Values("defaultExpression",null)]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("description",null)]
			string description)
		{
			var c  = Column.BigInt(name, nullable, defaultExpression, defaultConstraintName, description);
			GivenColumn(c);
			ThenColumnShouldBe(name, DataType.BigInt, nullable, defaultExpression, defaultConstraintName, description);
		}

        #endregion

        #region IDENTITIES
        [Test]
        public void ShouldCreateDefaultIdentityColumn()
        {
            GivenColumn(Column.BigInt("BigIntIdentity", new Identity(), "big int identity"));
            ThenColumnShouldBe("[BigIntIdentity] bigint identity not null");
        }

        [Test]
        public void ShouldCreateNotForReplicationIdentityColumn()
        { 
            GivenColumn(Column.BigInt("BigIntIdentity", new Identity(true), "big int identity"));
            ThenColumnShouldBe("[BigIntIdentity] bigint identity not for replication not null");
        }

        [Test]
        public void ShouldCreateIdentityWithCustomSeedColumn()
        {
            GivenColumn(Column.BigInt("BigIntIdentity", new Identity(101,103), "big int identity"));
            ThenColumnShouldBe($"[BigIntIdentity] bigint identity (101,103) not null");
        }

        [Test]
        public void ShouldCreateIdentityWithCustomSeedAndNotForReplicationColumn()
        {
            GivenColumn(Column.BigInt("BigIntIdentity", new Identity(105,107, true), "big int identity"));
            ThenColumnShouldBe($"[BigIntIdentity] bigint identity (105,107) not for replication not null");
        }
        #endregion

		#region Binary
		[Test]
		public void ShouldCreateBinaryColumn(
			[Values("binary")]
			string name, 
			
			[Values(1, null)]
			int? length, 
			
			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable, 
			
			[Values("'Hello'")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("varbinary")]
			string description)
		{
			var size = (length == null) ? null : new CharacterLength(length.Value);
			GivenColumn(Column.Binary(name, size, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.Binary, size, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion Binary

		#region Bit
		[Test]
		public void ShouldCreateBitColumn(
			[Values("bit")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,
			
			[Values("1", "0")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("bit column")]
			string description
			)
		{
			GivenColumn(Column.Bit(name, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.Bit, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion Bit

		#region Char
		[Test]
		public void ShouldCreateCharColumn(
			[Values("char")]
			string name, 
			
			[Values(15,null)]
			int? length, 
			
			[Values("collation")]
			string collation,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable, 
			
			[Values("richard cory")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,
			
			[Values("char")]
			string description)
		{
			var size = (length == null) ? null : new CharacterLength(length.Value);
			GivenColumn(Column.Char(name, size, collation, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.Char, size, collation, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion Char

		#region Date
		[Test]
		public void ShouldCreateDateColumn(
			[Values("date")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,
			
			[Values("getdate()")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("bit column", null)]
			string description
			)
		{
			GivenColumn(Column.Date(name, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.Date, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion Date

		#region DateTime2
		[Test]
		public void ShouldCreateDateTime2Column(
			[Values("CreatedAt")]
			string name,
			
			[Values(7, null)]
			int? scale,

			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable,

			[Values("getdate()")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("datetime2 column", null)]
			string description)
		{
			var size = (scale == null) ? null : new Scale(scale.Value);
			GivenColumn(Column.DateTime2(name, size, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.DateTime2,  size, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion DateTime2

		#region DateTimeOffset
		[Test]
		public void ShouldCreateDateTimeoffsetColumn(
			[Values("CreatedAtTZ")]
			string name,

			[Values(7, null)]
			int? scale,

			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable,

			[Values("getdate()")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("datetimeoffset column", null)]
			string description)
		{
			var size = (scale == null) ? null : new Scale(scale.Value);
			GivenColumn(Column.DateTimeOffset(name, size, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.DateTimeOffset, size, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion DateTime2

		#region Decimal
		[Test]
		public void ShouldCreateDecimalColumn(
			[Values("Decimal")]
			string name,

			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable)
		{
			var c = Column.Decimal(name, null, nullable, "1.0", "default constraint name", "decimal");
			GivenColumn(c);
			ThenColumnShouldBe(name, DataType.Decimal, nullable, "1.0", "default constraint name", "decimal");
		}

		[Test]
		public void ShouldCreateDecimalWithPrecisionAndScale(
			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable)
		{
			foreach (var ps in Precisions)
			{
				var c = Column.Decimal("DecimalWithPrecision", ps, nullable, "3.0", "default constraint name", "decimal with scale");
				GivenColumn(c);
				ThenColumnShouldBe("DecimalWithPrecision", DataType.Decimal, ps, nullable, "3.0", "default constraint name", "decimal with scale");
			}
		}

		[Test]
		public void ShouldCreateDecimalIdentityWithPrecisionAndScale()
		{
			var c = Column.Decimal("DecimalWithPrecision", new PrecisionScale(5,2), new Identity(), "decimal identity");
			GivenColumn(c);
			ThenColumnShouldBe("[DecimalWithPrecision] decimal(5,2) identity not null");
		}
		#endregion

		#region Float
		[Test]
		public void ShouldCreateFloatColumn(
			[Values("somefloat")]
			string name,

			[Values(7, null)]
			int? precision,

			[Values(4, null)]
			int? scale,

			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable,

			[Values("2.9999999999999")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("float column", null)]
			string description)
		{
            PrecisionScale size = null;
			if (precision == null && scale == null)
			{
			}
			else if (precision != null && scale == null)
			{
				size = new PrecisionScale(precision.Value);
			}
			else if( precision != null )
			{
				size = new PrecisionScale(precision.Value, scale.Value);
			}

			GivenColumn(Column.Float(name, size, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.Float, size, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion Float

		#region HierarchyID
		[Test]
// ReSharper disable InconsistentNaming
		public void ShouldCreateHierarchyIDColumn(
// ReSharper restore InconsistentNaming
			[Values("hid")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("5")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("hierarchyid column", null)]
			string description
			)
		{
			GivenColumn(Column.HierarchyID(name, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.HierarchyID, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion HierarchyID

		#region Int

		[Test]
		public void ShouldCreateIntColumn(
			[Values("Int")]
			string name, 
			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable)
		{
			var c = Column.Int(name, nullable, "(0)", "default constraint name", "int column");
			GivenColumn(c);
			ThenColumnShouldBe(name, DataType.Int, nullable, "(0)", "default constraint name", "int column");
		}
		#endregion

		#region Money
		[Test]
		public void ShouldCreateMoneyColumn(
			[Values("money")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("5.00")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("money column", null)]
			string description
			)
		{
			GivenColumn(Column.Money(name, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.Money, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion Money

		#region NChar
		[Test]
		public void ShouldCreateNCharColumn(
			[Values("char")]
			string name,

			[Values(15, null)]
			int? length,

			[Values("collation")]
			string collation,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("richard cory")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("char")]
			string description)
		{
			var size = (length == null) ? null : new CharacterLength(length.Value);
			GivenColumn(Column.NChar(name, size, collation, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.NChar, size, collation, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion Char

		#region NVarChar

		[Test]
		public void ShouldCreateNVarCharColumn(
			[Values("Name")]
			string name,

			[Values(50, null)]
			int? length,

			[Values(null, "collation")]
			string collation,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("DEFAULT")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("''", "varchar")]
			string description)
		{
			var size = length == null ? null : new CharacterLength(length.Value);
			GivenColumn(Column.NVarChar(name, size, collation, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.NVarChar, size, collation, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion NVarChar

		#region Real
		[Test]
		public void ShouldCreateRealColumn(
			[Values("real")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("5.00")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("real column", null)]
			string description
			)
		{
			GivenColumn(Column.Real(name, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.Real, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion Money

		#region RowVersion
		[Test]
		public void ShouldCreateRowVersionColumn(
			[Values("rowv")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("1")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("rowversion column", null)]
			string description
			)
		{
			GivenColumn(Column.RowVersion(name, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.RowVersion, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion RowVersion

		#region SmallDateTime
		[Test]
		public void ShouldCreateSmallDateTimeColumn(
			[Values("smalldt")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("getdate()")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("smalldatetime column", null)]
			string description
			)
		{
			GivenColumn(Column.SmallDateTime(name, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.SmallDateTime, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion SmallDateTime

		#region SmallInt

		[Test]
		public void ShouldCreateSmallIntColumn(
			[Values("Int")]
			string name, 
			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable)
		{
			var c = Column.SmallInt(name, nullable, "(4)", "default constraint name", "small int");
			GivenColumn(c);
			ThenColumnShouldBe(name, DataType.SmallInt, nullable, "(4)", "default constraint name", "small int");
		}
		#endregion

		#region SmallMoney
		[Test]
		public void ShouldCreateSmallMoneyColumn(
			[Values("cheapprice")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("5.00")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("money column", null)]
			string description
			)
		{
			GivenColumn(Column.SmallMoney(name, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.SmallMoney, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion SmallMoney

		#region SqlVariant
		[Test]
		public void ShouldCreateSqlVariantColumn(
			[Values("var")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("'35'")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("sql_variant column", null)]
			string description
			)
		{
			GivenColumn(Column.SqlVariant(name, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.SqlVariant, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion SqlVariant

		#region Time
		[Test]
		public void ShouldCreateTimeColumn(
			[Values("Schedule")]
			string name,

			[Values(7, null)]
			int? scale,

			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable,

			[Values("gettime()")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("time column", null)]
			string description)
		{
			var size = (scale == null) ? null : new Scale(scale.Value);
			GivenColumn(Column.Time(name, size, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.Time, size, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion DateTime2

		#region TinyInt

		[Test]
		public void ShouldCreateTinyIntColumn(
			[Values("Int")]
			string name, 
			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable)
		{
			var c = Column.TinyInt(name, nullable, "(6)", "default constraint name", "tinyint");
			GivenColumn(c);
			ThenColumnShouldBe(name, DataType.TinyInt, nullable, "(6)", "default constraint name", "tinyint");
		}
		#endregion

		#region UniqueIdentifier
		[Test]
		public void ShouldCreateUniqueIdentifierColumn(
			[Values("guid")]
			string name,

			[Values(true,false)]
			bool rowGuidCol,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("newsequentialid()")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,
			[Values("uniqueidentifier column", null)]
			string description
			)
		{
			GivenColumn(Column.UniqueIdentifier(name, rowGuidCol, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.UniqueIdentifier, rowGuidCol, nullable, defaultExpression, defaultConstraintName, description);
		}

		#endregion UniqueIdentifier

		#region VarBinary

		[Test]
		public void ShouldCreateVarBinaryColumn(
			[Values("varbinary")]
			string name,

			[Values(100, null)]
			int? length,

			[Values(true,false)]
			bool filestream,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("'Hello'")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("varbinary")]
			string description)
		{
			var size = (length == null) ? null : new CharacterLength(length.Value);
			GivenColumn(Column.VarBinary(name, size, filestream, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.VarBinary, size, filestream, nullable, defaultExpression, defaultConstraintName, description);
		}

		#endregion Binary

		#region VarChar

		[Test]
		public void ShouldCreateVarCharColumn(
			[Values("Name")]
			string name,

			[Values(50, null)]
			int? length,

			[Values(null, "collation")]
			string collation,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("DEFAULT")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,
			
			[Values("''", "varchar")]
			string description)
		{
			var size = length == null ? null : new CharacterLength(length.Value);
			GivenColumn(Column.VarChar(name, size, collation, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.VarChar, size, collation, nullable, defaultExpression, defaultConstraintName, description);
		}

		#endregion VarChar

		#region Xml

		[Test]
		public void ShouldCreateXmlColumn(
			[Values("xmldoc")]
			string name,

			[Values(true,false)]
			bool isDocument,

			[Values("schema1")]
			string xmlSchemaCollection,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("<hello/>")]
			string defaultExpression,

			[Values("default constraint name")]
			string defaultConstraintName,

			[Values("xml column", null)]
			string description
			)
		{
			GivenColumn(Column.Xml(name, isDocument, xmlSchemaCollection, nullable, defaultExpression, defaultConstraintName, description));
			ThenColumnShouldBe(name, DataType.Xml, isDocument, xmlSchemaCollection, nullable, defaultExpression, defaultConstraintName, description);
		}
		#endregion

		private void ThenColumnShouldBe(string name, DataType dataType, bool isDocument, string xmlSchemaCollection, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			ThenColumnShouldBe(name, dataType, defaultExpression, defaultConstraintName, description);
			Assert.That(_column.Nullable, Is.EqualTo(nullable));

			var notNullClause = ConvertToNotNullClause(nullable);
			var sparseClause = ConvertToSparseClause(nullable);
			var defaultClause = ConvertToDefaultClause(defaultExpression, defaultConstraintName, true);

			var size = new XmlPrecisionScale(isDocument, xmlSchemaCollection);
			Assert.That(_column.Size.ToString(), Is.EqualTo(size.ToString()));

			var columnDefinition = $"[{name}] xml{size}{notNullClause}{defaultClause}{sparseClause}";
			Assert.That(_column.GetColumnDefinition(true), Is.EqualTo(columnDefinition));
		}

		private string ConvertToDefaultClause(string defaultExpression, string defaultConstraintName, bool withValues)
		{
			if (string.IsNullOrEmpty(defaultExpression))
			{
				return "";
			}

			var withValuesClause = "";
			if (withValues)
			{
				withValuesClause = " with values";
			}

			return $" constraint [{defaultConstraintName}] default {defaultExpression}{withValuesClause}";
		}

		private void GivenColumn(Column column)
		{
			_column = column;
		}

        private void ThenColumnShouldBe(string expectedValue)
        {
            Assert.That(_column.GetColumnDefinition(false), Is.EqualTo(expectedValue));
        }

        private void ThenColumnShouldBe(string name, DataType dataType, bool rowGuidCol, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			ThenColumnShouldBe(name, dataType, defaultExpression, defaultConstraintName, description);
			Assert.That(_column.Nullable, Is.EqualTo(nullable));

			var notNullClause = ConvertToNotNullClause(nullable);
			var sparseClause = ConvertToSparseClause(nullable);
			var defaultClause = ConvertToDefaultClause(defaultExpression, defaultConstraintName, false);

			var rowGuidColClause = "";
			if (rowGuidCol)
			{
				// ReSharper disable once StringLiteralTypo
				rowGuidColClause = " rowguidcol";
			}

			var dataTypeName = dataType.ToString().ToLowerInvariant();
			var expectedDefinition = $"[{name}] {dataTypeName}{notNullClause}{defaultClause}{rowGuidColClause}{sparseClause}";
			Assert.That(_column.GetColumnDefinition(false), Is.EqualTo(expectedDefinition));
		}

		private void ThenColumnShouldBe(string name, DataType dataType, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			ThenColumnShouldBe(name, dataType, defaultExpression, defaultConstraintName, description);
			Assert.That(_column.Nullable, Is.EqualTo(nullable));

			var sizeClause = "(max)";
			if (size == null )
			{
				if (dataType.ToString().Contains("Var"))
				{
					Assert.That(_column.Size, Is.Not.Null);
					Assert.That(_column.Size.Value, Is.EqualTo(CharacterLength.Max));
					Assert.That(((CharacterLength)_column.Size).IsMax, Is.True);
					Assert.That(_column.Size.ToString(), Is.EqualTo("(max)"));
				}
				else
				{
					Assert.That(_column.Size, Is.Null);
					sizeClause = "";
				}
			}
			else
			{
				Assert.That(_column.Size.Value, Is.EqualTo(size.Value));
				sizeClause = string.Format("({0})", _column.Size.Value);
			}
			Assert.That(_column.Collation, Is.EqualTo(collation));

			var collationClause = "";
			if (collation != null)
			{
				collationClause = string.Format(" collate {0}", collation);
			}

			var notNullClause = ConvertToNotNullClause(nullable);
			var sparseClause = ConvertToSparseClause(nullable);
			var defaultClause = ConvertToDefaultClause(defaultExpression, defaultConstraintName, true);

			var expectedDefintion = string.Format("[{0}] {1}{2}{3}{4}{5}{6}", name, dataType.ToString().ToLowerInvariant(), sizeClause, collationClause, notNullClause,
			                                      defaultClause,sparseClause);
			Assert.That(_column.GetColumnDefinition(true), Is.EqualTo(expectedDefintion));
		}

		private void ThenColumnShouldBe(string name, DataType dataType, string defaultExpression, string defaultConstraintName, string description)
		{
			Assert.That(_column.Name, Is.EqualTo(name));
			Assert.That(_column.DataType, Is.EqualTo(dataType));
			Assert.That(_column.DefaultExpression, Is.EqualTo(defaultExpression));
			Assert.That(_column.DefaultConstraintName, Is.EqualTo(defaultConstraintName));
			Assert.That(_column.Description, Is.EqualTo(description));
		}

		private void ThenColumnShouldBe(string name, DataType dataType, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			ThenColumnShouldBe(name, dataType, defaultExpression, defaultConstraintName, description);
			Assert.That(_column.Nullable, Is.EqualTo(nullable));

			var notNullClause = ConvertToNotNullClause(nullable);
			var sparseClause = ConvertToSparseClause(nullable);
			var defaultClause = ConvertToDefaultClause(defaultExpression, defaultConstraintName, false);

			Assert.That(_column.GetColumnDefinition(false), Is.EqualTo(string.Format("[{0}] {1}{2}{3}{4}", name, dataType, notNullClause, defaultClause, sparseClause)));
		}

		private void ThenColumnShouldBe(string name, DataType dataType, ColumnSize size, bool filestream,
		                                Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			Assert.That(_column.FileStream, Is.EqualTo(filestream));
			ThenColumnShouldBe(name, dataType, size, nullable, defaultExpression, defaultConstraintName, description);
		}

		private void ThenColumnShouldBe(string name, DataType dataType, ColumnSize size, Nullable nullable, string defaultExpression, string defaultConstraintName, string description)
		{
			ThenColumnShouldBe(name, dataType, defaultExpression, defaultConstraintName, description);
			var sizeClause = "";
			if (size == null)
			{
				if (dataType.ToString().Contains("Var"))
				{
					Assert.That(_column.Size, Is.Not.Null);
					Assert.That(_column.Size.GetType(), Is.EqualTo(typeof (CharacterLength)));
					Assert.That(_column.Size.Value, Is.EqualTo(CharacterLength.Max));
					Assert.That(_column.Size.ToString(), Is.EqualTo("(max)"));
					sizeClause = "(max)";
				}
				else
				{
					Assert.That(_column.Size, Is.Null);
				}
			}
			else
			{
				Assert.That(_column.Size, Is.Not.Null);
				Assert.That(_column.Size.Value, Is.EqualTo(size.Value));
				Assert.That(_column.Size.ToString(), Is.EqualTo(size.ToString()));
				sizeClause = size.ToString();
			}
			Assert.That(_column.Nullable, Is.EqualTo(nullable));
			
			var notNullClause = ConvertToNotNullClause(nullable);
			var sparseClause = ConvertToSparseClause(nullable);
			var defaultClause = ConvertToDefaultClause(defaultExpression, defaultConstraintName, true);

			var fileStreamClause = "";
			if (_column.FileStream)
			{
				// ReSharper disable once StringLiteralTypo
				fileStreamClause = " filestream";
			}

			var expectedDefinition =
				$"[{name}] {dataType.ToString().ToLowerInvariant()}{sizeClause}{fileStreamClause}{notNullClause}{defaultClause}{sparseClause}";
			Assert.That(_column.GetColumnDefinition(true), Is.EqualTo(expectedDefinition));
		}

		private void ThenColumnShouldBe(string name, DataType dataType, Identity identity, string description)
		{
			ThenColumnShouldBe(name, dataType, null, null as string, description);
			Assert.That(_column.Nullable, Is.EqualTo(Nullable.NotNull));
			Assert.That(_column.Identity.Seed, Is.EqualTo(identity.Seed));
			Assert.That(_column.Identity.Increment, Is.EqualTo(identity.Increment));
			Assert.That(_column.Identity.NotForReplication, Is.EqualTo(identity.NotForReplication));
			Assert.That(_column.Identity.ToString(), Is.EqualTo(identity.ToString()));
			Assert.That(_column.GetColumnDefinition(false), Contains.Substring(identity.ToString()));
			var expectedDefinition = $"[{name}] {dataType.ToString().ToLowerInvariant()} {identity}";
			Assert.That(_column.GetColumnDefinition(false), Is.EqualTo(expectedDefinition));
		}

		private void ThenColumnShouldBe(string name, DataType dataType, ColumnSize size, Identity identity, string description)
		{
			ThenColumnShouldBe(name, dataType, null, null as string, description);
			Assert.That(_column.Size, Is.Not.Null);
			Assert.That(_column.Size.ToString(), Is.EqualTo(size.ToString()));
			Assert.That(_column.Identity.Seed, Is.EqualTo(identity.Seed));
			Assert.That(_column.Identity.Increment, Is.EqualTo(identity.Increment));
			Assert.That(_column.Identity.NotForReplication, Is.EqualTo(identity.NotForReplication));
			Assert.That(_column.Identity.ToString(), Is.EqualTo(identity.ToString()));
			var expectedDefinition = $"[{name}] {dataType.ToString().ToLowerInvariant()}{size} {identity}";
			Assert.That(_column.GetColumnDefinition(true), Is.EqualTo(expectedDefinition));
		}

		private static string ConvertToNotNullClause(Nullable nullable)
		{
			var notNullClause = "";
			if (nullable == Nullable.NotNull)
			{
				notNullClause = " not null";
			}
			return notNullClause;
		}

		private static string ConvertToSparseClause(Nullable nullable)
		{
			var sparseClause = "";
			if (nullable == Nullable.Sparse)
			{
				sparseClause = " sparse";
			}
			return sparseClause;
		}
	}


}
