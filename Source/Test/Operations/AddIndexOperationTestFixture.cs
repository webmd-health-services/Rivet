using System;
using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddIndexOperationTestFixture
	{
		[Test]
		public void ShouldSetPropertiesForAddIndexWith()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var columnName = new[] { "column1", "column2" };
			var smokeColumnName = new[] { "column1" };
			const string name = "indexName";
			const bool unique = true;
			const bool clustered = true;
			var options = new[] { "option1", "option2" };
			var smokeOptions = new[] { "option2" };
			const string whereString = "whereString";
			const string onString = "onString";
			const string fileStreamOnString = "fileStreamOnString";
            var include = new[] { "include1", "include2" };

			var op = new AddIndexOperation(schemaName, tableName, name, columnName, unique, clustered, options, whereString, onString, fileStreamOnString, include);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(name, op.Name.ToString());
			Assert.AreEqual(unique, op.Unique);
			Assert.AreEqual(clustered, op.Clustered);
			Assert.AreEqual(options, op.Options);
			Assert.AreNotEqual(smokeOptions, op.Options);
			Assert.AreEqual(whereString, op.Where);
			Assert.AreEqual(onString, op.On);
			Assert.AreEqual(fileStreamOnString, op.FileStreamOn);
		}

		[Test]
		public void ShouldSetPropertiesForAddIndexWithDescendingAnd()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var columnName = new[] { "column1", "column2" };
			var smokeColumnName = new[] { "column1" };
			var name = "indexName";
			bool[] descending = { true, false };
			const bool unique = true;
			const bool clustered = true;
			var options = new[] { "option1", "option2" };
			var smokeOptions = new[] { "option2" };
			const string whereString = "whereString";
			const string onString = "onString";
			const string fileStreamOnString = "fileStreamOnString";
            var include = new[] { "include1", "include2" };

			var op = new AddIndexOperation(schemaName, tableName, name, columnName, @descending, unique, clustered, options, whereString, onString, fileStreamOnString, include);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(name, op.Name.ToString());
			Assert.AreEqual(descending, op.Descending);
			Assert.AreEqual(unique, op.Unique);
			Assert.AreEqual(clustered, op.Clustered);
			Assert.AreEqual(options, op.Options);
			Assert.AreNotEqual(smokeOptions, op.Options);
			Assert.AreEqual(whereString, op.Where);
			Assert.AreEqual(onString, op.On);
			Assert.AreEqual(fileStreamOnString, op.FileStreamOn);
		}

		[Test]
		public void ShouldWriteQueryForAddIndexWithAllOptionsTrueWith()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var columnName = new[] { "column1", "column2" };
			var name = "";
			bool[] descending = { true, false };
			const bool unique = true;
			const bool clustered = true;
			var options = new[] { "option1", "option2" };
			const string whereString = "whereString";
			const string onString = "onString";
			const string fileStreamOnString = "fileStreamOnString";
            var include = new[] { "include1", "include2" };

			var op = new AddIndexOperation(schemaName, tableName, name, columnName, @descending, unique, clustered, options, whereString, onString, fileStreamOnString, include);
			var expectedQuery = $"create unique clustered index [{name}] on [{schemaName}].[{tableName}] ([{columnName[0]}] desc, [{columnName[1]}]) " +
			                             $"include ( [{string.Join("], [", include)}] ) with ( {string.Join(", ", options)} ) " +
			                             // ReSharper disable once StringLiteralTypo
			                             $"where ( {whereString} ) on {onString} filestream_on {fileStreamOnString}";

			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldAllowChangingIndexName()
		{
			var op = new AddIndexOperation("schema", "table", "name", new[] {"column"}, false, false, null, null, null, null, null);
			op.Name = "new name";
			Assert.That(op.Name, Is.EqualTo("new name"));
		}

		[Test]
		public void ShouldDisableWhenMergedWithRemoveOperation()
		{
			var op = new AddIndexOperation("schema", "table", "name", new string[0], false, false, new string[0], "where", "on", "filestreamon", new string[0]);
			var removeOp = new RemoveIndexOperation("SCHEMA", "TABLE", "NAME");
			op.Merge(removeOp);
			Assert.That(op.Disabled, Is.True);
			Assert.That(removeOp.Disabled, Is.True);
		}
	}
}