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
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}.FK_{0}_{1}_{2}_{3}", schemaName, tableName, referencesSchemaName, referencesTableName)));
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