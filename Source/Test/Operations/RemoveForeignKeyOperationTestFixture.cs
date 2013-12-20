using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveForeignKeyConstraintTestFixture
	{
		[Test]
		public void ShouldSetPropertiesForRemoveForeignKey()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var referencesSchemaName = "rschemaName";
			var referencesTableName = "rtableName";

			var op = new RemoveForeignKeyOperation(schemaName, tableName, referencesSchemaName, referencesTableName);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(referencesSchemaName, op.ReferencesSchemaName);
			Assert.AreEqual(referencesTableName, op.ReferencesTableName);
		}

		[Test]
		public void ShouldSetPropertiesForRemoveForeignKeyWithOptionalConstraintName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var optionalConstraintName = "optionalConstraintName";

			var op = new RemoveForeignKeyOperation(schemaName, tableName, optionalConstraintName);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.That(op.ReferencesTableName, Is.Null);
			Assert.That(op.ReferencesSchemaName, Is.Null);
			Assert.AreEqual(optionalConstraintName, op.Name.ToString());
		}

		[Test]
		public void ShouldWriteQueryForRemoveForeignKey()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var referencesSchemaName = "rschemaName";
			var referencesTableName = "rtableName";

			var op = new RemoveForeignKeyOperation(schemaName, tableName, referencesSchemaName, referencesTableName);
			System.Console.WriteLine(op.ToQuery());
			var expectedQuery = "alter table [schemaName].[tableName] drop constraint [FK_schemaName_tableName_rschemaName_rtableName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForRemoveForeignKeyWithOptionalConstraintName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var optionalConstraintName = "optionalConstraintName";

			var op = new RemoveForeignKeyOperation(schemaName, tableName, optionalConstraintName);
			System.Console.WriteLine(op.ToQuery());
			var expectedQuery = "alter table [schemaName].[tableName] drop constraint [optionalConstraintName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}

}