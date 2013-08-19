using NUnit.Framework;

namespace Rivet.Test
{
	[TestFixture]
	public sealed class ColumnTestFixture
	{
		private static readonly Identity DefaultIdentity = new Identity();
		private static readonly Identity DefaultNotForReplicationIdentity = new Identity(true);
		private static readonly Identity SeedIncrementIdentity = new Identity(3, 4);
		private static readonly Identity SeedIncrementNotForReplicationIdentity = new Identity(3, 4);
		private static readonly Identity[] Identities = new[] {DefaultIdentity, DefaultNotForReplicationIdentity, SeedIncrementIdentity, SeedIncrementNotForReplicationIdentity};

		private static readonly PrecisionScale PrecisionNoScale = new PrecisionScale(1);
		private static readonly PrecisionScale PrecisionWithScale = new PrecisionScale(2, 1);
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

			[Values("description",null)]
			string description)
		{
			var c  = Column.BigInt(name, nullable, defaultExpression, description);
			GivenColumn(c);
			ThenColumnShouldBe(name, DataType.BigInt, nullable, defaultExpression, description);
		}

		[Test]
		public void ShouldCreateBigIntIdentityColumn()
		{
			foreach (var identity in Identities)
			{
				GivenColumn(Column.BigInt("BigIntIdentity", identity, "(2)", "big int identity"));
				ThenColumnShouldBe("BigIntIdentity", DataType.BigInt, identity, "(2)", "big int identity");
			}
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
			
			[Values("varbinary")]
			string description)
		{
			var size = (length == null) ? null : new CharacterLength(length.Value);
			GivenColumn(Column.Binary(name, size, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.Binary, size, nullable, defaultExpression, description);
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

			[Values("bit column")]
			string description
			)
		{
			GivenColumn(Column.Bit(name, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.Bit, nullable, defaultExpression, description);
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
			
			[Values("char")]
			string description)
		{
			var size = (length == null) ? null : new CharacterLength(length.Value);
			GivenColumn(Column.Char(name, size, collation, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.Char, size, collation, nullable, defaultExpression, description);
		}
		#endregion Char

		#region Date
		[Test]
		public void ShouldCreateDateColumn(
			[Values("date")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,
			
			[Values("getdate()", null)]
			string defaultExpression,

			[Values("bit column", null)]
			string description
			)
		{
			GivenColumn(Column.Date(name, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.Date, nullable, defaultExpression, description);
		}
		#endregion Date

		#region DateTime2
		[Test]
		public void ShouldCreateDateTime2Column(
			[Values("CreatedAt")]
			string name,
			
			[Values(7, null)]
			int? precision,

			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable,

			[Values("getdate()", null)]
			string defaultExpression,
			
			[Values("datetime2 column", null)]
			string description)
		{
			var size = (precision == null) ? null : new PrecisionScale(precision.Value);
			GivenColumn(Column.DateTime2(name, size, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.DateTime2,  size, nullable, defaultExpression, description);
		}
		#endregion DateTime2

		#region DateTimeOffset
		[Test]
		public void ShouldCreateDateTimeoffsetColumn(
			[Values("CreatedAtTZ")]
			string name,

			[Values(7, null)]
			int? precision,

			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable,

			[Values("getdate()", null)]
			string defaultExpression,

			[Values("datetimeoffset column", null)]
			string description)
		{
			var size = (precision == null) ? null : new PrecisionScale(precision.Value);
			GivenColumn(Column.DateTimeOffset(name, size, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.DateTimeOffset, size, nullable, defaultExpression, description);
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
			var c = Column.Decimal(name, null, nullable, "1.0", "decimal");
			GivenColumn(c);
			ThenColumnShouldBe(name, DataType.Decimal, nullable, "1.0", "decimal");
		}

		[Test]
		public void ShouldCreateDecimalIdentityColumn()
		{
			foreach (var identity in Identities)
			{
				GivenColumn(Column.Decimal("DecimalIdentity", null, identity, "2.0", "decimal identity"));
				ThenColumnShouldBe("DecimalIdentity", DataType.Decimal, identity, "2.0", "decimal identity");
			}
		}

		[Test]
		public void ShouldCreateDecimalWithPrecisionAndScale(
			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable)
		{
			foreach (var ps in Precisions)
			{
				var c = Column.Decimal("DecimalWithPrecision", ps, nullable, "3.0", "decimal with scale");
				GivenColumn(c);
				ThenColumnShouldBe("DecimalWithPrecision", DataType.Decimal, ps, nullable, "3.0", "decimal with scale");
			}
		}

		[Test]
		public void ShouldCreateDecimalIdentityWithPrecisionAndScale()
		{
			foreach (var identity in Identities)
			{
				foreach (var ps in Precisions)
				{
					var c = Column.Decimal("DecimalWithPrecision", ps, identity, "4.0", "decimal identity");
					GivenColumn(c);
					ThenColumnShouldBe("DecimalWithPrecision", DataType.Decimal, ps, identity, "4.0", "decimal identity");
				}
			}
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

			[Values("2.9999999999999", null)]
			string defaultExpression,

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

			GivenColumn(Column.Float(name, size, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.Float, size, nullable, defaultExpression, description);
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

			[Values("5", null)]
			string defaultExpression,

			[Values("hierarchyid column", null)]
			string description
			)
		{
			GivenColumn(Column.HierarchyID(name, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.HierarchyID, nullable, defaultExpression, description);
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
			var c = Column.Int(name, nullable, "(0)", "int collumn");
			GivenColumn(c);
			ThenColumnShouldBe(name, DataType.Int, nullable, "(0)", "int collumn");
		}

		[Test]
		public void ShouldCreateIntIdentityColumn()
		{
			foreach (var identity in Identities)
			{
				GivenColumn(Column.Int("IntIdentity", identity, "(1)", "int identity"));
				ThenColumnShouldBe("IntIdentity", DataType.Int, identity, "(1)", "int identity");
			}
		}

		#endregion

		#region Money
		[Test]
		public void ShouldCreateMoneyColumn(
			[Values("money")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("5.00", null)]
			string defaultExpression,

			[Values("money column", null)]
			string description
			)
		{
			GivenColumn(Column.Money(name, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.Money, nullable, defaultExpression, description);
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

			[Values("char")]
			string description)
		{
			var size = (length == null) ? null : new CharacterLength(length.Value);
			GivenColumn(Column.NChar(name, size, collation, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.NChar, size, collation, nullable, defaultExpression, description);
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

			[Values("''", "DEFAULT", null)]
			string defaultExpression,

			[Values("''", "varchar")]
			string description)
		{
			var size = length == null ? null : new CharacterLength(length.Value);
			GivenColumn(Column.NVarChar(name, size, collation, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.NVarChar, size, collation, nullable, defaultExpression, description);
		}
		#endregion NVarChar

		#region Numeric

		[Test]
		public void ShouldCreateNumericColumn(
			[Values("Numeric")]
			string name,
			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable)
		{
			var c = Column.Numeric(name, null, nullable, "10.0", "numeric");
			GivenColumn(c);
			ThenColumnShouldBe(name, DataType.Numeric, nullable, "10.0", "numeric");
		}

		[Test]
		public void ShouldCreateNumericIdentityColumn()
		{
			foreach (var identity in Identities)
			{
				GivenColumn(Column.Numeric("NumericIdentity", null, identity, "11.0", "numeric identity"));
				ThenColumnShouldBe("NumericIdentity", DataType.Numeric, identity, "11.0", "numeric identity");
			}
		}

		[Test]
		public void ShouldCreateNumericWithPrecisionAndScale(
			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable)
		{
			foreach (var ps in Precisions)
			{
				var c = Column.Numeric("NumericWithPrecision", ps, nullable, "12.0", "numeric precision");
				GivenColumn(c);
				ThenColumnShouldBe("NumericWithPrecision", DataType.Numeric, ps, nullable, "12.0", "numeric precision");
			}
		}

		[Test]
		public void ShouldCreateNumericIdentityWithPrecisionAndScale()
		{
			foreach (var identity in Identities)
			{
				foreach (var ps in Precisions)
				{
					var c = Column.Numeric("NumericWithPrecision", ps, identity, "13.0", "numeric identity precision");
					GivenColumn(c);
					ThenColumnShouldBe("NumericWithPrecision", DataType.Numeric, ps, identity, "13.0", "numeric identity precision");
				}
			}
		}

		#endregion

		#region Real
		[Test]
		public void ShouldCreateRealColumn(
			[Values("real")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("5.00", null)]
			string defaultExpression,

			[Values("real column", null)]
			string description
			)
		{
			GivenColumn(Column.Real(name, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.Real, nullable, defaultExpression, description);
		}
		#endregion Money

		#region RowVersion
		[Test]
		public void ShouldCreateRowVersionColumn(
			[Values("rowv")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("1", null)]
			string defaultExpression,

			[Values("rowversion column", null)]
			string description
			)
		{
			GivenColumn(Column.RowVersion(name, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.RowVersion, nullable, defaultExpression, description);
		}
		#endregion RowVersion

		#region SmallDateTime
		[Test]
		public void ShouldCreateSmallDateTimeColumn(
			[Values("smalldt")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("getdate()", null)]
			string defaultExpression,

			[Values("smalldatetime column", null)]
			string description
			)
		{
			GivenColumn(Column.SmallDateTime(name, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.SmallDateTime, nullable, defaultExpression, description);
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
			var c = Column.SmallInt(name, nullable, "(4)", "small int");
			GivenColumn(c);
			ThenColumnShouldBe(name, DataType.SmallInt, nullable, "(4)", "small int");
		}

		[Test]
		public void ShouldCreateSmallIntIdentityColumn()
		{
			foreach (var identity in Identities)
			{
				GivenColumn(Column.SmallInt("SmallIntIdentity", identity, "(1)", "small int identity"));
				ThenColumnShouldBe("SmallIntIdentity", DataType.SmallInt, identity, "(1)", "small int identity");
			}
		}

		#endregion

		#region SqlVariant
		[Test]
		public void ShouldCreateSqlVariantColumn(
			[Values("var")]
			string name,

			[Values(Nullable.NotNull, Nullable.Null, Nullable.Sparse)]
			Nullable nullable,

			[Values("'35'", null)]
			string defaultExpression,

			[Values("sql_variant column", null)]
			string description
			)
		{
			GivenColumn(Column.SqlVariant(name, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.SqlVariant, nullable, defaultExpression, description);
		}
		#endregion SqlVariant

		#region Time
		[Test]
		public void ShouldCreateTimeColumn(
			[Values("Schedule")]
			string name,

			[Values(7, null)]
			int? precision,

			[Values(Nullable.Null, Nullable.NotNull, Nullable.Sparse)]
			Nullable nullable,

			[Values("gettime()", null)]
			string defaultExpression,

			[Values("time column", null)]
			string description)
		{
			var size = (precision == null) ? null : new PrecisionScale(precision.Value);
			GivenColumn(Column.Time(name, size, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.Time, size, nullable, defaultExpression, description);
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
			var c = Column.TinyInt(name, nullable, "(6)", "tinyint");
			GivenColumn(c);
			ThenColumnShouldBe(name, DataType.TinyInt, nullable, "(6)", "tinyint");
		}

		[Test]
		public void ShouldCreateTinyIntIdentityColumn()
		{
			foreach (var identity in Identities)
			{
				GivenColumn(Column.TinyInt("TinyIntIdentity", identity, "(7)", "tinyint identity"));
				ThenColumnShouldBe("TinyIntIdentity", DataType.TinyInt, identity, "(7)", "tinyint identity");
			}
		}

		#endregion

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

			[Values("varbinary")]
			string description)
		{
			var size = (length == null) ? null : new CharacterLength(length.Value);
			GivenColumn(Column.VarBinary(name, size, filestream, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.VarBinary, size, filestream, nullable, defaultExpression, description);
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
			
			[Values("''", "DEFAULT", null)]
			string defaultExpression, 
			
			[Values("''", "varchar")]
			string description)
		{
			var size = length == null ? null : new CharacterLength(length.Value);
			GivenColumn(Column.VarChar(name, size, collation, nullable, defaultExpression, description));
			ThenColumnShouldBe(name, DataType.VarChar, size, collation, nullable, defaultExpression, description);
		}

		private void ThenColumnShouldBe(string name, DataType dataType, CharacterLength size, string collation, Nullable nullable, string defaultExpression, string description)
		{
			ThenColumnShouldBe(name, dataType, defaultExpression, description);
			Assert.That(_column.Nullable, Is.EqualTo(nullable));

			var sizeClause = "(max)";
			if (size == null )
			{
				if (dataType.ToString().Contains("Var"))
				{
					Assert.That(_column.Size, Is.Not.Null);
					Assert.That(_column.Size.Precision, Is.EqualTo(0));
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
				Assert.That(_column.Size.Precision, Is.EqualTo(size.Precision));
				sizeClause = string.Format("({0})", _column.Size.Precision);
			}
			Assert.That(_column.Collation, Is.EqualTo(collation));

			var collationClause = "";
			if (collation != null)
			{
				collationClause = string.Format(" collate {0}", collation);
			}

			var notNullClause = "";
			if (nullable == Nullable.NotNull)
			{
				notNullClause = " not null";
			}

			var sparseClause = "";
			if (nullable == Nullable.Sparse)
			{
				sparseClause = " sparse";
			}

			var expectedDefintion = string.Format("[{0}] {1}{2}{3}{4}{5}", name, dataType.ToString().ToLowerInvariant(), sizeClause, collationClause, notNullClause,
			                                      sparseClause);
			Assert.That(_column.GetColumnDefinition(), Is.EqualTo(expectedDefintion));
		}

		#endregion VarChar

		private void GivenColumn(Column column)
		{
			_column = column;
		}

		private void ThenColumnShouldBe(string name, DataType dataType, string defaultExpression, string description)
		{
			Assert.That(_column.Name, Is.EqualTo(name));
			Assert.That(_column.DataType, Is.EqualTo(dataType));
			Assert.That(_column.DefaultExpression, Is.EqualTo(defaultExpression));
			Assert.That(_column.Description, Is.EqualTo(description));
		}

		private void ThenColumnShouldBe(string name, DataType dataType, Nullable nullable, string defaultExpression, string description)
		{
			ThenColumnShouldBe(name, dataType, defaultExpression, description);
			Assert.That(_column.Nullable, Is.EqualTo(nullable));

			var notNullClause = "";
			if (nullable == Nullable.NotNull)
			{
				notNullClause = " not null";
			}
			else if (nullable == Nullable.Sparse)
			{
				notNullClause = " sparse";
			}

			var dataTypeName = dataType.ToString().ToLowerInvariant();
			if (dataType == DataType.SqlVariant)
			{
				dataTypeName = "sql_variant";
			}
			Assert.That(_column.GetColumnDefinition(), Is.EqualTo(string.Format("[{0}] {1}{2}", name, dataTypeName, notNullClause)));
		}

		private void ThenColumnShouldBe(string name, DataType dataType, PrecisionScale size, bool filestream,
		                                Nullable nullable, string defaultExpression, string description)
		{
			Assert.That(_column.FileStream, Is.EqualTo(filestream));
			ThenColumnShouldBe(name, dataType, size, nullable, defaultExpression, description);
		}

		private void ThenColumnShouldBe(string name, DataType dataType, PrecisionScale size, Nullable nullable, string defaultExpression, string description)
		{
			ThenColumnShouldBe(name, dataType, defaultExpression, description);
			var sizeClause = "";
			if (size == null)
			{
				if (dataType.ToString().Contains("Var"))
				{
					Assert.That(_column.Size, Is.Not.Null);
					Assert.That(_column.Size.GetType(), Is.EqualTo(typeof (CharacterLength)));
					Assert.That(_column.Size.Precision, Is.EqualTo(0));
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
				Assert.That(_column.Size.Precision, Is.EqualTo(size.Precision));
				Assert.That(_column.Size.Scale, Is.EqualTo(size.Scale));
				Assert.That(_column.Size.ToString(), Is.EqualTo(size.ToString()));
				sizeClause = size.ToString();
			}
			Assert.That(_column.Nullable, Is.EqualTo(nullable));
			
			var notNullClause = "";
			if (nullable == Nullable.NotNull)
			{
				notNullClause = " not null";
			}
			else if (nullable == Nullable.Sparse)
			{
				notNullClause = " sparse";
			}

			var filestreamClause = "";
			if (_column.FileStream)
			{
				filestreamClause = " filestream";
			}

			var expectedDefinition = string.Format("[{0}] {1}{2}{3}{4}", name, dataType.ToString().ToLowerInvariant(), sizeClause, filestreamClause, notNullClause);
			Assert.That(_column.GetColumnDefinition(), Is.EqualTo(expectedDefinition));
		}

		private void ThenColumnShouldBe(string name, DataType dataType, Identity identity, string defaultExpression, string description)
		{
			ThenColumnShouldBe(name, dataType, defaultExpression, description);
			Assert.That(_column.Nullable, Is.EqualTo(Nullable.NotNull));
			Assert.That(_column.Identity.Seed, Is.EqualTo(identity.Seed));
			Assert.That(_column.Identity.Increment, Is.EqualTo(identity.Increment));
			Assert.That(_column.Identity.NotForReplication, Is.EqualTo(identity.NotForReplication));
			Assert.That(_column.Identity.ToString(), Is.EqualTo(identity.ToString()));
			Assert.That(_column.GetColumnDefinition(), Contains.Substring(identity.ToString()));
			var expectedDefinition = string.Format("[{0}] {1} {2}", name, dataType.ToString().ToLowerInvariant(), identity);
			Assert.That(_column.GetColumnDefinition(), Is.EqualTo(expectedDefinition));
		}

		private void ThenColumnShouldBe(string name, DataType dataType, PrecisionScale size, Identity identity, string defaultExpression, string description)
		{
			ThenColumnShouldBe(name, dataType, defaultExpression, description);
			Assert.That(_column.Size, Is.Not.Null);
			Assert.That(_column.Size.Precision, Is.EqualTo(size.Precision));
			Assert.That(_column.Size.Scale, Is.EqualTo(size.Scale));
			Assert.That(_column.Size.ToString(), Is.EqualTo(size.ToString()));
			Assert.That(_column.Identity.Seed, Is.EqualTo(identity.Seed));
			Assert.That(_column.Identity.Increment, Is.EqualTo(identity.Increment));
			Assert.That(_column.Identity.NotForReplication, Is.EqualTo(identity.NotForReplication));
			Assert.That(_column.Identity.ToString(), Is.EqualTo(identity.ToString()));
			var expectedDefinition = string.Format("[{0}] {1}{2} {3}", name, dataType.ToString().ToLowerInvariant(), size, identity);
			Assert.That(_column.GetColumnDefinition(), Is.EqualTo(expectedDefinition));
		}
	}


}
