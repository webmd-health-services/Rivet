using System.Diagnostics;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveCheckConstraintOperationTestFixture
	{

		// ReSharper disable InconsistentNaming
		const string _schemaName = "schemaName";
		const string _tableName = "tableName";
		const string _constraintName = "constraintName";
		// ReSharper restore InconsistentNaming

		[Test]
		public void ShouldSetPropertiesForRemoveCheckConstraint()
		{

			var op = new RemoveCheckConstraintOperation(_schemaName, _tableName, _constraintName);
			Assert.AreEqual(_schemaName, op.SchemaName);
			Assert.AreEqual(_tableName, op.TableName);
			Assert.AreEqual(_constraintName, op.Name);
			Assert.That(op.ObjectName, Is.EqualTo($"{_schemaName}.{_constraintName}"));
			Assert.That(op.TableObjectName, Is.EqualTo($"{_schemaName}.{_tableName}"));
		}

		[Test]
		public void ShouldWriteQueryForRemoveCheckConstraint()
		{
			var op = new RemoveCheckConstraintOperation(_schemaName, _tableName, _constraintName);
			Trace.WriteLine(op.ToQuery());
			const string expectedQuery = "alter table [schemaName].[tableName] drop constraint [constraintName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
	}

}
