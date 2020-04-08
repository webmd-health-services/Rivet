using System;
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
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			const string name = "name";

			var op = new RemoveForeignKeyOperation(schemaName, tableName, name);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.That(op.ObjectName, Is.EqualTo($"{schemaName}.{name}"));
			Assert.That(op.TableObjectName, Is.EqualTo($"{schemaName}.{tableName}"));
			Assert.That(op.Name, Is.EqualTo(name));
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
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			const string name = "fubar";

			var op = new RemoveForeignKeyOperation(schemaName, tableName, name);
			var expectedQuery = string.Format("alter table [{0}].[{1}] drop constraint [{2}]", schemaName, tableName, name);
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}
}