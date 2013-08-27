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
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			bool unique = true;
			bool clustered = true;
			string[] options = new string[] { "option1", "option2" };
			string[] smokeOptions = new string[] { "option2" };
			var whereString = "whereString";
			var onString = "onString";
			var filestreamonString = "filestreamonString";

			var op = new AddIndexOperation(schemaName, tableName, columnName, unique, clustered, options, whereString, onString, filestreamonString);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
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
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			bool unique = true;
			bool clustered = true;
			string[] options = new string[] { "option1", "option2" };
			string[] smokeOptions = new string[] { "option2" };
			var whereString = "whereString";
			var onString = "onString";
			var filestreamonString = "filestreamonString";

			var op = new AddIndexOperation(schemaName, tableName, columnName, unique, clustered, options, whereString, onString, filestreamonString);
			var expectedQuery = "create unique clustered index IX_schemaName_tableName_column1_column2 on schemaName.tableName (column1,column2) with ( option1, option2 ) where ( whereString ) on onString filestream_on filestreamonString";

			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryForAddIndexWithAllOptionsFalse()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1" };
			string[] smokeColumnName = new string[] { "column1" };
			bool unique = false;
			bool clustered = false;
			string[] options = new string[] { };
			string[] smokeOptions = new string[] { "option2" };
			var whereString = "";
			var onString = "";
			var filestreamonString = "";

			
			var op = new AddIndexOperation(schemaName, tableName, columnName, unique, clustered, options, whereString, onString, filestreamonString);
			var expectedQuery = "create  index IX_schemaName_tableName_column1 on schemaName.tableName (column1)    ";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldSetPropertiesForRemoveIndex()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };

			var op = new RemoveIndexOperation(schemaName, tableName, columnName);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
		}

		[Test]
		public void ShouldWriteQueryForRemoveIndex()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };

			var op = new RemoveIndexOperation(schemaName, tableName, columnName);
			var expectedQuery = "drop index IX_schemaName_tableName_column1_column2 on schemaName.tableName";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}