using NUnit.Framework;

namespace Rivet.Test
{
	[TestFixture]
	public sealed class IndexNameTestFixture
	{
		[Test]
		public void ShouldReturnIndexConstraintName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };

			var cons = new IndexName(schemaName, tableName, columnName, false);
			var expectedConstraintString = "IX_schemaName_tableName_column1_column2";
			Assert.AreEqual(expectedConstraintString, cons.ToString());
		}

		[Test]
		public void ShouldReturnUniqueIndexConstraintName()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };

			var cons = new IndexName(schemaName, tableName, columnName, true);
			var expectedConstraintString = "UIX_schemaName_tableName_column1_column2";
			Assert.AreEqual(expectedConstraintString, cons.ToString());
		}

		[Test]
		public void ShouldReturnUniqueIndexConstraintNameInDboSchema()
		{
			var schemaName = "dbo";
			var tableName = "tableName";
			string[] columnName = new string[] { "column1", "column2" };

			var cons = new IndexName(schemaName, tableName, columnName, true);
			var expectedConstraintString = "UIX_tableName_column1_column2";
			Assert.AreEqual(expectedConstraintString, cons.ToString());
		}

	}
}
