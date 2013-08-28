using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddRemoveUniqueConstraintTestFixture
	{
		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForAddUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			bool clustered = true;
			int fillfactor = 2;
			string[] options = new string[] { "option1", "option2" };
			string[] smokeOptions = new string[] { "option2" };
			string fileGroup = "fileGroup";

			var op = new AddUniqueConstraintOperation(schemaName, tableName, columnName, clustered, fillfactor, options, fileGroup);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(clustered, op.Clustered);
			Assert.AreEqual(fillfactor, op.FillFactor);
			Assert.AreEqual(options, op.Options);
			Assert.AreNotEqual(smokeOptions, op.Options);
			Assert.AreEqual(fileGroup, op.FileGroup);
		}

		[Test]
		public void ShouldSetPropertiesWithNullOptionsForAddUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			bool clustered = true;
			int fillfactor = 2;
			string[] options = null;
			string[] smokeOptions = new string[] { "option2" };
			string fileGroup = "fileGroup";

			var op = new AddUniqueConstraintOperation(schemaName, tableName, columnName, clustered, fillfactor, options, fileGroup);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
			Assert.AreEqual(clustered, op.Clustered);
			Assert.AreEqual(fillfactor, op.FillFactor);
			Assert.AreEqual(options, op.Options);
			Assert.AreNotEqual(smokeOptions, op.Options);
			Assert.AreEqual(fileGroup, op.FileGroup);
		}

		[Test]
		public void ShouldWriteQueryForAddUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			bool clustered = true;
			int fillfactor = 0;
			string[] options = null;
			string fileGroup = "fileGroup";

			var op = new AddUniqueConstraintOperation(schemaName, tableName, columnName, clustered, fillfactor, options, fileGroup);
			var expectedQuery = "alter table schemaName.tableName add constraint UQ_schemaName_tableName_column1_column2 unique clustered(column1,column2)  on fileGroup";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryWithOptionsForAddUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			bool clustered = true;
			int fillfactor = 0;
			string[] options = new string[] { "option1", "option2" };
			string fileGroup = "fileGroup";

			var op = new AddUniqueConstraintOperation(schemaName, tableName, columnName, clustered, fillfactor, options, fileGroup);
			var expectedQuery = "alter table schemaName.tableName add constraint UQ_schemaName_tableName_column1_column2 unique clustered(column1,column2) with (option1, option2) on fileGroup";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}
		

		[Test]
		public void ShouldWriteQueryWithNoOptionsForAddUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			bool clustered = true;
			int fillfactor = 80;
			string[] options = null;
			string fileGroup = "fileGroup";

			var op = new AddUniqueConstraintOperation(schemaName, tableName, columnName, clustered, fillfactor, options, fileGroup);
			var expectedQuery = "alter table schemaName.tableName add constraint UQ_schemaName_tableName_column1_column2 unique clustered(column1,column2) with (fillfactor = 80) on fileGroup";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldWriteQueryWithFillFactorAndOptionsForAddUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			bool clustered = true;
			int fillfactor = 80;
			string[] options = new string[] { "option1", "options2" };
			string fileGroup = "fileGroup";

			var op = new AddUniqueConstraintOperation(schemaName, tableName, columnName, clustered, fillfactor, options, fileGroup);
			var expectedQuery = "alter table schemaName.tableName add constraint UQ_schemaName_tableName_column1_column2 unique clustered(column1,column2) with (option1, options2, fillfactor = 80) on fileGroup";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

		[Test]
		public void ShouldSetPropertiesForRemoveUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };

			var op = new RemoveUniqueConstraintOperation(schemaName, tableName, columnName);
			Assert.AreEqual(schemaName, op.SchemaName);
			Assert.AreEqual(tableName, op.TableName);
			Assert.AreEqual(columnName, op.ColumnName);
			Assert.AreNotEqual(smokeColumnName, op.ColumnName);
		}

		[Test]
		public void ShouldWriteQueryForRemoveUniqueConstraint()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };

			var op = new RemoveUniqueConstraintOperation(schemaName, tableName, columnName);
			var expectedQuery = "alter table schemaName.tableName drop constraint UQ_schemaName_tableName_column1_column2";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}

}