using System.Diagnostics;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddRemoveCheckConstraintOperationTestFixture
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
			var name = "constraintName";
			var expression = "expression";
			bool notForReplication = true;

			var op = new AddCheckConstraintOperation(schemaName, tableName, name, expression, notForReplication);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(name, op.Name);
			Assert.AreEqual(expression, op.Expression);
			Assert.AreEqual(notForReplication, op.NotForReplication);
		}

		[Test]
		public void ShouldWriteQueryForAddCheckConstrait()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var name = "constraintName";
			var expression = "expression";
			bool notForReplication = true;

			var op = new AddCheckConstraintOperation(schemaName, tableName, name, expression, notForReplication);
			
			var expectedQuery = @"alter table [schemaName].[tableName] add constraint [constraintName] check not for replication (expression) ";
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

			var op = new AddCheckConstraintOperation(schemaName, tableName, name, expression, notForReplication);
			Trace.WriteLine(op.ToQuery());
			var expectedQuery = @"alter table [schemaName].[tableName] add constraint [constraintName] check (expression) ";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		
		[Test]
		public void ShouldSetPropertiesForRemoveCheckConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var constraintName = "constraintName";

			var op = new RemoveCheckConstraintOperation(schemaName, tableName, constraintName);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(constraintName, op.Name);
		}

		[Test]
		public void ShouldWriteQueryForRemoveCheckConstrait()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var constraintName = "constraintName";

			var op = new RemoveCheckConstraintOperation(schemaName, tableName, constraintName);
			Trace.WriteLine(op.ToQuery());
			var expectedQuery = "alter table [schemaName].[tableName] drop constraint [constraintName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
		

	}

}
