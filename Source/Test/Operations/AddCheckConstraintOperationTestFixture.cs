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
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}.{2}", schemaName, tableName, name)));
		}

		[Test]
		public void ShouldWriteQueryForAddCheckConstrait()
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

		
	}

}
