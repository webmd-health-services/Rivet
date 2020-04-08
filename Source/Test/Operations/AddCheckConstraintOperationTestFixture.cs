using System.Diagnostics;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddCheckConstraintOperationTestFixture
	{
		[Test]
		public void ShouldSetPropertiesForAddDefaultConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var name = "constraintName";
			var expression = "expression";
			bool notForReplication = true;
			bool withNoCheck = true;

			var op = new AddCheckConstraintOperation(schemaName, tableName, name, expression, notForReplication, withNoCheck);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(name, op.Name);
			Assert.AreEqual(expression, op.Expression);
			Assert.AreEqual(notForReplication, op.NotForReplication);
			Assert.AreEqual(withNoCheck, op.WithNoCheck);
			Assert.That(op.ObjectName, Is.EqualTo($"{schemaName}.{name}"));
			Assert.That(op.TableObjectName, Is.EqualTo($"{schemaName}.{tableName}"));
			Assert.That(op.ConstraintType, Is.EqualTo(ConstraintType.Check));
		}

		[Test]
		public void ShouldWriteQueryForAddCheckConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var name = "constraintName";
			var expression = "expression";
			bool notForReplication = true;
			bool withNoCheck = true;

			var op = new AddCheckConstraintOperation(schemaName, tableName, name, expression, notForReplication, withNoCheck);

			var expectedQuery = @"alter table [schemaName].[tableName] with nocheck add constraint [constraintName] check not for replication (expression)";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryWithDBOSchemaAndWithValuesFalseForAddCheckConstrait()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var name = "constraintName";
			var expression = "expression";
			bool notForReplication = false;

			var op = new AddCheckConstraintOperation(schemaName, tableName, name, expression, notForReplication, false);
			Trace.WriteLine(op.ToQuery());
			var expectedQuery = @"alter table [schemaName].[tableName] add constraint [constraintName] check (expression)";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldAllowChangingConstraintName()
		{
			var op = new AddCheckConstraintOperation("schema", "table", "name", "1", true, true);
			op.Name = "new name";
			Assert.That(op.Name, Is.EqualTo("new name"));
		}

		[Test]
		public void ShouldDisableWhenMergedWithRemoveCheckConstraint()
		{
			var op = new AddCheckConstraintOperation("schema", "table", "name", "1", true, true);
			var removeOp = new RemoveCheckConstraintOperation("SCHEMA", "TABLE", "NAME");
			op.Merge(removeOp);
			Assert.That(op.Disabled, Is.True);
			Assert.That(removeOp.Disabled, Is.True);
		}
	}
}
