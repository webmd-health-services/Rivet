using NUnit.Framework;

namespace Rivet.Test
{
	[TestFixture]
	public sealed class ConstraintNameTestFixture
	{
		
		[SetUp]
		public void SetUp()
		{
			
		}

		[Test]
		public void ShouldSetPropertiesForConstraintNameClassTestFixture()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };

			var cons = new ConstraintName(schemaName, tableName, columnName, ConstraintType.Default);

			Assert.AreEqual(schemaName, cons.SchemaName);
			Assert.AreEqual(tableName, cons.TableName);
			Assert.AreEqual(columnName, cons.ColumnName);
			Assert.AreNotEqual(smokeColumnName, cons.ColumnName);
			Assert.AreEqual(ConstraintType.Default, cons.Type);
		}

		[Test]
		public void ShouldReturnDefaultConstraintNameForConstraintNameClassTestFixture()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			ConstraintType c_type = ConstraintType.Default;

			var cons = new ConstraintName(schemaName, tableName, columnName, c_type);
			var expectedConstraintString = "DF_schemaName_tableName_column1_column2";
			Assert.AreEqual(expectedConstraintString, cons.ToString());
		}

		[Test]
		public void ShouldReturnDefaultConstraintNameWithSingleColumnForConstraintNameClassTestFixture()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1" };
			string[] smokeColumnName = new string[] { "column1" };
			ConstraintType c_type = ConstraintType.Default;

			var cons = new ConstraintName(schemaName, tableName, columnName, c_type);
			var expectedConstraintString = "DF_schemaName_tableName_column1";
			Assert.AreEqual(expectedConstraintString, cons.ToString());
		}


		[Test]
		public void ShouldReturnDefaultConstraintNameWithDBOSchemaForConstraintNameClassTestFixture()
		{
			var schemaName = "dbo";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			ConstraintType c_type = ConstraintType.Default;

			var cons = new ConstraintName(schemaName, tableName, columnName, c_type);
			var expectedConstraintString = "DF_tableName_column1_column2";
			Assert.AreEqual(expectedConstraintString, cons.ToString());
		}

		[Test]
		public void ShouldReturnPrimaryKeyConstraintNameForConstraintNameClassTestFixture()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			ConstraintType c_type = ConstraintType.PrimaryKey;

			var cons = new ConstraintName(schemaName, tableName, columnName, c_type);
			var expectedConstraintString = "PK_schemaName_tableName_column1_column2";
			Assert.AreEqual(expectedConstraintString, cons.ToString());
		}

		[Test]
		public void ShouldReturnForeignKeyConstraintNameForConstraintNameClassTestFixture()
		{
			var sourceSchema = "sourceSchema";
			var sourceTable = "sourceTable";
			var targetSchema = "targetSchema";
			var targetTable = "targetTable";


			var cons = new ForeignKeyConstraintName(sourceSchema, sourceTable, targetSchema, targetTable);
			var expectedConstraintString = "FK_sourceSchema_sourceTable_targetSchema_targetTable";
			Assert.AreEqual(expectedConstraintString, cons.ToString());
		}

		[Test]
		public void ShouldReturnIndexConstraintNameForConstraintNameClassTestFixture()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			ConstraintType c_type = ConstraintType.Index;

			var cons = new ConstraintName(schemaName, tableName, columnName, c_type);
			var expectedConstraintString = "IX_schemaName_tableName_column1_column2";
			Assert.AreEqual(expectedConstraintString, cons.ToString());
		}

		[Test]
		public void ShouldReturnUniqueConstraintNameForConstraintNameClassTestFixture()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };
			string[] smokeColumnName = new string[] { "column1" };
			ConstraintType c_type = ConstraintType.Unique;

			var cons = new ConstraintName(schemaName, tableName, columnName, c_type);
			var expectedConstraintString = "AK_schemaName_tableName_column1_column2";
			Assert.AreEqual(expectedConstraintString, cons.ToString());
		}


	}
}
