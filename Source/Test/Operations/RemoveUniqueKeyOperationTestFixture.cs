﻿using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveUniqueKeyTestFixture
	{
		[Test]
		public void ShouldSetPropertiesForRemoveUniqueConstraint()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			const string name = "name";

			var op = new RemoveUniqueKeyOperation(schemaName, tableName, name, new[] { "column" });
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.That(op.Name, Is.EqualTo(name));
			Assert.That(op.ObjectName, Is.EqualTo($"{schemaName}.{name}"));
			Assert.That(op.TableObjectName, Is.EqualTo($"{schemaName}.{tableName}"));
			var expectedQuery = string.Format("alter table [{0}].[{1}] drop constraint [{2}]", schemaName, tableName, name);
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}