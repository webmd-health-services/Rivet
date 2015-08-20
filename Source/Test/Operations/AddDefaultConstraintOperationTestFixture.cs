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
		public void ShouldSetPropertiesForAddDefaultConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var columnName = "columnName";
			var expression = "expression";
			bool withValues = true;

			var op = new AddDefaultConstraintOperation(schemaName, tableName, expression, columnName, withValues);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreEqual(expression, op.Expression);
			Assert.AreEqual(withValues, op.WithValues);
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}.DF_{0}_{1}_{2}", schemaName, tableName, columnName)));
			Assert.That(op.ConstraintType, Is.EqualTo(ConstraintType.Default));
		}

		[Test]
		public void ShouldSetPropertiesForAddDefaultConstraintWithOptionalName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var columnName = "columnName";
			var expression = "expression";
			var optionalConstraintName = "optionalConstraintName";
			bool withValues = true;

			var op = new AddDefaultConstraintOperation(schemaName, tableName, expression, columnName, optionalConstraintName, withValues);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreEqual(expression, op.Expression);
			Assert.AreEqual(optionalConstraintName, op.Name.ToString());
			Assert.AreEqual(withValues, op.WithValues);
		}

		[Test]
		public void ShouldWriteQueryForAddDefaultConstrait()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var columnName = "columnName";
			var expression = "expression";
			bool withValues = true;

			var op = new AddDefaultConstraintOperation(schemaName, tableName, expression, columnName, withValues);
			var expectedQuery = @"alter table [schemaName].[tableName] add constraint [DF_schemaName_tableName_columnName] default expression for [columnName] with values";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryWithDBOSchemaAndWithValuesFalseForAddDefaultConstrait()
		{
			var schemaName = "dbo";
			var tableName = "tableName";
			var columnName = "columnName";
			var expression = "expression";
			bool withValues = false;

			var op = new AddDefaultConstraintOperation(schemaName, tableName, expression, columnName, withValues);
			var expectedQuery = @"alter table [dbo].[tableName] add constraint [DF_tableName_columnName] default expression for [columnName] ";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryWithOptionalConstraintNameForAddDefaultConstrait()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var columnName = "columnName";
			var expression = "expression";
			var optionalConstraintName = "optionalConstraintName";
			bool withValues = true;

			var op = new AddDefaultConstraintOperation(schemaName, tableName, expression, columnName, optionalConstraintName, withValues);
			var expectedQuery = @"alter table [schemaName].[tableName] add constraint [optionalConstraintName] default expression for [columnName] with values";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldAllowChangingConstraintName()
		{
			var op = new AddDefaultConstraintOperation("schema", "table", "name", "1", false);
			op.SetConstraintName("new name");
			Assert.That(op.Name, Is.EqualTo("new name"));
		}
	}

}
