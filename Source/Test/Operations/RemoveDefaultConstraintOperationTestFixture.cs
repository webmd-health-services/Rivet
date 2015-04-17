using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveDefaultConstraintOperationTestFixture
	{

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
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}.DF_{0}_{1}_{2}", schemaName, tableName, columnName)));
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
