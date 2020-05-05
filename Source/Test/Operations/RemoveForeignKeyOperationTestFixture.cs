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
		public void ShouldWriteQueryForRemoveForeignKey()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			const string name = "constraintName";

			var op = new RemoveForeignKeyOperation(schemaName, tableName, name);
			var expectedQuery = $"alter table [{schemaName}].[{tableName}] drop constraint [{name}]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}
}