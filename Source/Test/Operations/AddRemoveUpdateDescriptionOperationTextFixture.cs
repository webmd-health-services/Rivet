using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddRemoveUpdateDescriptionOperationTestFixture
	{
		[SetUp]
		public void SetUp()
		{
		}

		[Test]
		public void ShouldSetPropertiesForDescription()
		{
			var schemaName = "schemaName";
			var tableName = "tableName";
			var description = "new description";
			var columnName = "add_description";

			/** ADD DESCRIPTION OPERATION **/

			//For Table
			var op = new AddDescriptionOperation(schemaName, tableName, description);
			Assert.That(op.SchemaName, Is.EqualTo(schemaName));
			Assert.That(op.TableName, Is.EqualTo(tableName));
			Assert.That(op.Description, Is.EqualTo(description));
			Assert.That(op.ForTable, Is.EqualTo(true));
			Assert.That(op.ForColumn, Is.EqualTo(false));

			var expectedQuery = string.Format(@"
			EXEC sys.sp_addextendedproperty @name=N'MS_Description',
											@value='{0}',
											@level0type=N'SCHEMA', @level0name='{1}', 
											@level1type=N'TABLE',  @level1name='{2}'", description.Replace("'", "''"), schemaName, tableName);
			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));

			//For Column
			op = new AddDescriptionOperation(schemaName, tableName, columnName, description);
			Assert.That(op.SchemaName, Is.EqualTo(schemaName));
			Assert.That(op.TableName, Is.EqualTo(tableName));
			Assert.That(op.Description, Is.EqualTo(description));
			Assert.That(op.ForTable, Is.EqualTo(false));
			Assert.That(op.ForColumn, Is.EqualTo(true));

			expectedQuery += string.Format(",\n											@level2type=N'COLUMN', @level2name='{0}'", columnName);
			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));

		}
	}
}
