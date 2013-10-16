using System.Diagnostics;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class UpdateColumnOperationTestFixture
	{
		public const string TableName = "tableName";
		public const string SchemaName = "schemaName";
		static readonly CharacterLength VarcharMaxLength = new CharacterLength();
		static readonly PrecisionScale Datetimeoffset7 = new PrecisionScale(34, 7);
		public Column Int = Column.Int("intColumn", Nullable.NotNull, null, null);
		public Column VarChar = Column.VarChar("varcharColumn", VarcharMaxLength, "Chinese_Taiwan_Stroke_CS_AS", Nullable.Sparse, null, null);
		public Column DateTimeOffset = Column.DateTimeOffset("datetimeoffsetColumn", Datetimeoffset7, Nullable.NotNull, null, null);

		[SetUp]
		public void SetUp()
		{
		}

		[Test]
		public void ShouldSetPropertiesforUpdateColumn()
		{
			var op = new UpdateColumnOperation(SchemaName, TableName, VarChar);
			Assert.That(op.TableName, Is.EqualTo(TableName));
			Assert.That(op.SchemaName, Is.EqualTo(SchemaName));
			Assert.AreEqual(VarChar, op.Column);
		}

		[Test]
		public void ShouldWriteQueryforUpdateColumnWithInt()
		{

			var op = new UpdateColumnOperation(SchemaName, TableName, Int);
			const string expectedQuery = "alter table [schemaName].[tableName] alter column [intColumn] int not null";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryforUpdateColumnWithVarChar()
		{

			var op = new UpdateColumnOperation(SchemaName, TableName, VarChar);
			const string expectedQuery = "alter table [schemaName].[tableName] alter column [varcharColumn] varchar(max) collate Chinese_Taiwan_Stroke_CS_AS sparse";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryforUpdateColumnWithDateTimeOffset()
		{
			var op = new UpdateColumnOperation(SchemaName, TableName, DateTimeOffset);
			Trace.WriteLine(op.ToQuery());
			const string expectedQuery = "alter table [schemaName].[tableName] alter column [datetimeoffsetColumn] datetimeoffset(34,7) not null";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}
}
