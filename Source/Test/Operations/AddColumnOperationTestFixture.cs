using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddColumnOperationTestFixture
	{
		[SetUp]
		public void SetUp()
		{
			
		}

		[Test]
		public void ShouldSetPropertiesforColumn()
		{
			var tableName = "tableName";
			var schemaName = "schemaName";
			var column = Column.VarChar("name", new CharacterLength(50), null, Nullable.NotNull, "''", "varchar column");
			var withValues = true;
			var op = new AddColumnOperation(tableName, schemaName, column, withValues);
			Assert.That(op.TableName, Is.EqualTo(tableName));
			Assert.That(op.SchemaName, Is.EqualTo(schemaName));
			Assert.That(op.Column, Is.SameAs(column));
			Assert.That(op.WithValues, Is.True);

			var expectedQuery = string.Format("alter table [{0}].[{1}] add {2}", schemaName, tableName,
			                                  column.GetColumnDefinition(tableName, schemaName, withValues));
			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));

		}
	}
}
