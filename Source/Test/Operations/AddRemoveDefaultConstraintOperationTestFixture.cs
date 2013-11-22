using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddRemoveDefaultConstraintOperationTestFixture
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
			var expectedQuery = @"alter table [schemaName].[tableName] add constraint [DF_schemaName_tableName_columnName] default expression for columnName with values";
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
			var expectedQuery = @"alter table [dbo].[tableName] add constraint [DF_tableName_columnName] default expression for columnName ";
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
			var expectedQuery = @"alter table [schemaName].[tableName] add constraint [optionalConstraintName] default expression for columnName with values";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldSetPropertiesForRemoveDefaultConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var columnName = "columnName";

			var op = new RemoveDefaultConstraintOperation(schemaName, tableName, columnName);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
		}

		[Test]
		public void ShouldWriteQueryForRemoveDefaultConstrait()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var columnName = "columnName";

			var op = new RemoveDefaultConstraintOperation(schemaName, tableName, columnName);
			var expectedQuery = "alter table [schemaName].[tableName] drop constraint [DF_schemaName_tableName_columnName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForRemoveDefaultConstraitWithOptionalConstraintName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var columnName = "columnName";
			var optionalConstraintName = "optionalConstraintName";

			var op = new RemoveDefaultConstraintOperation(schemaName, tableName, columnName, optionalConstraintName);
			var expectedQuery = "alter table [schemaName].[tableName] drop constraint [optionalConstraintName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}

}
