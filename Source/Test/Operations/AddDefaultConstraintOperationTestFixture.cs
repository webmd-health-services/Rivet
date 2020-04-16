using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddDefaultConstraintOperationTestFixture
	{
		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForAddDefaultConstraintWithValues()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			const string columnName = "columnName";
			const string expression = "expression";
			const string name = "name";
			const bool withValues = true;

			var op = new AddDefaultConstraintOperation(schemaName, tableName, name, columnName, expression, withValues);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreEqual(expression, op.Expression);
			Assert.AreEqual(name, op.Name.ToString());
			Assert.AreEqual(withValues, op.WithValues);
			var expectedQuery = $"alter table [{schemaName}].[{tableName}] add constraint [{name}] default {expression} for [{columnName}] with values";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}


		[Test]
		public void ShouldSetPropertiesForAddDefaultConstraintWithNoValues()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			const string columnName = "columnName";
			const string expression = "expression";
			const string name = "name";
			const bool withValues = false;

			var op = new AddDefaultConstraintOperation(schemaName, tableName, name, columnName, expression, withValues);
			Assert.AreEqual(withValues, op.WithValues);
			var expectedQuery = $"alter table [{schemaName}].[{tableName}] add constraint [{name}] default {expression} for [{columnName}]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldAllowChangingConstraintName()
		{
			var op = new AddDefaultConstraintOperation("schema", "table", "name", "1", "expression", false);
			op.Name = "new name";
			Assert.That(op.Name, Is.EqualTo("new name"));
		}

		[Test]
		public void ShouldDisableWhenMergedWithRemoveOperation()
		{
			var op = new AddDefaultConstraintOperation("schema", "table", "name", "column", "expression", false);
			var removeOp = new RemoveDefaultConstraintOperation("SCHEMA", "TABLE", "COLUMN", "NAME");
			op.Merge(removeOp);
			Assert.That(op.Disabled, Is.True);
			Assert.That(removeOp.Disabled, Is.True);
		}
	}
}
