using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddRemoveIndexOperationTestFixture
	{
		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForAddIndex()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var columnName = new[] { "column1", "column2" };
			var smokeColumnName = new[] { "column1" };
			const bool unique = true;
			const bool clustered = true;
			var options = new[] { "option1", "option2" };
			var smokeOptions = new[] { "option2" };
			const string whereString = "whereString";
			const string onString = "onString";
			const string filestreamonString = "filestreamonString";

			var op = new AddIndexOperation(schemaName, tableName, columnName, unique, clustered, options, whereString, onString, filestreamonString);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(false, op.SomeColumnsDesc);
			Assert.AreEqual(unique, op.Unique);
			Assert.AreEqual(clustered, op.Clustered);
			Assert.AreEqual(options, op.Options);
			Assert.AreNotEqual(smokeOptions, op.Options);
			Assert.AreEqual(whereString, op.Where);
			Assert.AreEqual(onString, op.On);
			Assert.AreEqual(filestreamonString, op.FileStreamOn);
		}

		[Test]
		public void ShouldSetPropertiesForAddIndexWithOptionalConstraintName()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var columnName = new[] { "column1", "column2" };
			var smokeColumnName = new[] { "column1" };
			var optionalConstraintName = "optionalConstraintName";
			const bool unique = true;
			const bool clustered = true;
			var options = new[] { "option1", "option2" };
			var smokeOptions = new[] { "option2" };
			const string whereString = "whereString";
			const string onString = "onString";
			const string filestreamonString = "filestreamonString";

			var op = new AddIndexOperation(schemaName, tableName, columnName, optionalConstraintName, unique, clustered, options, whereString, onString, filestreamonString);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(optionalConstraintName, op.ConstraintName.ToString());
			Assert.AreEqual(false, op.SomeColumnsDesc);
			Assert.AreEqual(unique, op.Unique);
			Assert.AreEqual(clustered, op.Clustered);
			Assert.AreEqual(options, op.Options);
			Assert.AreNotEqual(smokeOptions, op.Options);
			Assert.AreEqual(whereString, op.Where);
			Assert.AreEqual(onString, op.On);
			Assert.AreEqual(filestreamonString, op.FileStreamOn);
		}

		[Test]
		public void ShouldSetPropertiesForAddIndexWithDescending()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var columnName = new[] { "column1", "column2" };
			var smokeColumnName = new[] { "column1" };
			bool[] descending = {true, false};
			const bool unique = true;
			const bool clustered = true;
			var options = new[] { "option1", "option2" };
			var smokeOptions = new[] { "option2" };
			const string whereString = "whereString";
			const string onString = "onString";
			const string filestreamonString = "filestreamonString";

			var op = new AddIndexOperation(schemaName, tableName, columnName, descending, unique, clustered, options, whereString, onString, filestreamonString);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(descending, op.Descending);
			Assert.AreEqual(true, op.SomeColumnsDesc);
			Assert.AreEqual(unique, op.Unique);
			Assert.AreEqual(clustered, op.Clustered);
			Assert.AreEqual(options, op.Options);
			Assert.AreNotEqual(smokeOptions, op.Options);
			Assert.AreEqual(whereString, op.Where);
			Assert.AreEqual(onString, op.On);
			Assert.AreEqual(filestreamonString, op.FileStreamOn);
		}

		[Test]
		public void ShouldSetPropertiesForAddIndexWithDescendingAndOptionalConstraintName()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var columnName = new[] { "column1", "column2" };
			var smokeColumnName = new[] { "column1" };
			var optionalConstraintName = "optionalConstraintName";
			bool[] descending = { true, false };
			const bool unique = true;
			const bool clustered = true;
			var options = new[] { "option1", "option2" };
			var smokeOptions = new[] { "option2" };
			const string whereString = "whereString";
			const string onString = "onString";
			const string filestreamonString = "filestreamonString";

			var op = new AddIndexOperation(schemaName, tableName, columnName, optionalConstraintName, descending, unique, clustered, options, whereString, onString, filestreamonString);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(optionalConstraintName, op.ConstraintName.ToString());
			Assert.AreEqual(descending, op.Descending);
			Assert.AreEqual(true, op.SomeColumnsDesc);
			Assert.AreEqual(unique, op.Unique);
			Assert.AreEqual(clustered, op.Clustered);
			Assert.AreEqual(options, op.Options);
			Assert.AreNotEqual(smokeOptions, op.Options);
			Assert.AreEqual(whereString, op.Where);
			Assert.AreEqual(onString, op.On);
			Assert.AreEqual(filestreamonString, op.FileStreamOn);
		}

		[Test]
		public void ShouldWriteQueryForAddIndexWithAllOptionsTrue()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var columnName = new[] { "column1", "column2" };
			bool[] descending = { true, false };
			const bool unique = true;
			const bool clustered = true;
			var options = new[] { "option1", "option2" };
			const string whereString = "whereString";
			const string onString = "onString";
			const string filestreamonString = "filestreamonString";

			var op = new AddIndexOperation(schemaName, tableName, columnName, descending, unique, clustered, options, whereString, onString, filestreamonString);
			const string expectedQuery = "create unique clustered index [UIX_schemaName_tableName_column1_column2] on [schemaName].[tableName] (column1 DESC,column2 ASC) with ( option1, option2 ) where ( whereString ) on onString filestream_on filestreamonString";

			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForAddIndexWithAllOptionsTrueWithOptionalConstraintName()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var columnName = new[] { "column1", "column2" };
			var optionalConstraintName = "optionalConstraintName";
			bool[] descending = { true, false };
			const bool unique = true;
			const bool clustered = true;
			var options = new[] { "option1", "option2" };
			const string whereString = "whereString";
			const string onString = "onString";
			const string filestreamonString = "filestreamonString";

			var op = new AddIndexOperation(schemaName, tableName, columnName, optionalConstraintName, descending, unique, clustered, options, whereString, onString, filestreamonString);
			const string expectedQuery = "create unique clustered index [optionalConstraintName] on [schemaName].[tableName] (column1 DESC,column2 ASC) with ( option1, option2 ) where ( whereString ) on onString filestream_on filestreamonString";

			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForAddIndexWithAllOptionsFalse()
		{
			const string schemaName = "schemaName";
			const string tableName = "tableName";
			var columnName = new[] { "column1" };
			bool[] descending = { false };
			const bool unique = false;
			const bool clustered = false;
			var options = new string[] { };
			const string whereString = "";
			const string onString = "";
			const string filestreamonString = "";
			
			var op = new AddIndexOperation(schemaName, tableName, columnName, descending, unique, clustered, options, whereString, onString, filestreamonString);
			const string expectedQuery = "create  index [IX_schemaName_tableName_column1] on [schemaName].[tableName] (column1 ASC)    ";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}


	}
}