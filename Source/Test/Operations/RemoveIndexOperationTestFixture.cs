using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveIndexOperationTestFixture
	{

		[Test]
		public void ShouldSetPropertiesForRemoveIndex()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var columnName = new[] { "column1", "column2" };
			var smokeColumnName = new[] { "column1" };

			var op = new RemoveIndexOperation(schemaName, tableName, columnName, ConstraintType.Index);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
		}

		[Test]
		public void ShouldSetPropertiesForRemoveIndexWithOptionalConstraintName()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var optionalConstraintName = "optionalConstraintName";

			var op = new RemoveIndexOperation(schemaName, tableName, optionalConstraintName);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.That(op.ColumnName, Is.Null);
			Assert.AreEqual(optionalConstraintName, op.Name.ToString());
		}

		[Test]
		public void ShouldWriteQueryForRemoveIndex()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var columnName = new[] { "column1", "column2" };

			var op = new RemoveIndexOperation(schemaName, tableName, columnName, ConstraintType.Index);
			const string expectedQuery = "drop index [IX_schemaName_tableName_column1_column2] on [schemaName].[tableName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForRemoveIndexWithOptionalConstraintName()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var optionalConstraintName = "optionalConstraintName";

			var op = new RemoveIndexOperation(schemaName, tableName, optionalConstraintName);
			const string expectedQuery = "drop index [optionalConstraintName] on [schemaName].[tableName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldAllowCustomIndexType()
		{
			var schemaName = "blah";
			var tableName = "bar";
			var columnName = "foo";

			var op = new RemoveIndexOperation(schemaName, tableName, new[] {columnName}, ConstraintType.UniqueIndex);
			Assert.That(op.Name.Type, Is.EqualTo(ConstraintType.UniqueIndex));
			Assert.That(op.Name.ToString(), Is.EqualTo("UIX_blah_bar_foo"));
		}

	}
}
