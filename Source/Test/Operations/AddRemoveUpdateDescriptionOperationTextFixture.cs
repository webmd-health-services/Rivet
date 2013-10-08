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
			var op = new AddExtendedPropertyOperation(schemaName, tableName, description);
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
			op = new AddExtendedPropertyOperation(schemaName, tableName, columnName, description);
			Assert.That(op.SchemaName, Is.EqualTo(schemaName));
			Assert.That(op.TableName, Is.EqualTo(tableName));
			Assert.That(op.Description, Is.EqualTo(description));
			Assert.That(op.ForTable, Is.EqualTo(false));
			Assert.That(op.ForColumn, Is.EqualTo(true));

			expectedQuery += string.Format(",\n											@level2type=N'COLUMN', @level2name='{0}'", columnName);
			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));

			/** REMOVE DESCRIPTION OPERATION **/

			//For Table
			var op_remove = new RemoveDescriptionOperation(schemaName, tableName);
			Assert.That(op_remove.SchemaName, Is.EqualTo(schemaName));
			Assert.That(op_remove.TableName, Is.EqualTo(tableName));
			Assert.That(op_remove.ForTable, Is.EqualTo(true));
			Assert.That(op_remove.ForColumn, Is.EqualTo(false));

			expectedQuery = string.Format(@"
			EXEC sys.sp_dropextendedproperty	@name=N'MS_Description',
												@level0type=N'SCHEMA', @level0name='{0}',
												@level1type=N'TABLE',  @level1name='{1}'", schemaName, tableName);
			Assert.That(op_remove.ToQuery(), Is.EqualTo(expectedQuery));

			//For Column
			op_remove = new RemoveDescriptionOperation(schemaName, tableName, columnName);
			Assert.That(op_remove.SchemaName, Is.EqualTo(schemaName));
			Assert.That(op_remove.TableName, Is.EqualTo(tableName));
			Assert.That(op_remove.ColumnName, Is.EqualTo(columnName));
			Assert.That(op_remove.ForTable, Is.EqualTo(false));
			Assert.That(op_remove.ForColumn, Is.EqualTo(true));

			expectedQuery += string.Format(",\n												@level2type=N'COLUMN', @level2name='{0}'", columnName);
			Assert.That(op_remove.ToQuery(), Is.EqualTo(expectedQuery));

			/** UPDATE DESCRIPTION OPERATION **/

			//For Table
			var op_update = new UpdateDescriptionOperation(schemaName, tableName, description);
			Assert.That(op_update.SchemaName, Is.EqualTo(schemaName));
			Assert.That(op_update.TableName, Is.EqualTo(tableName));
			Assert.That(op_update.Description, Is.EqualTo(description));
			Assert.That(op_update.ForTable, Is.EqualTo(true));
			Assert.That(op_update.ForColumn, Is.EqualTo(false));

			expectedQuery = string.Format(@"
			EXEC sys.sp_updateextendedproperty	@name=N'MS_Description',
												@value='{0}',
												@level0type=N'SCHEMA', @level0name='{1}', 
												@level1type=N'TABLE',  @level1name='{2}'", description.Replace("'", "''"), schemaName, tableName);
			Assert.That(op_update.ToQuery(), Is.EqualTo(expectedQuery));

			//For Column
			op_update = new UpdateDescriptionOperation(schemaName, tableName, columnName, description);
			Assert.That(op_update.ForTable, Is.EqualTo(false));
			Assert.That(op_update.ForColumn, Is.EqualTo(true));
			Assert.That(op_update.SchemaName, Is.EqualTo(schemaName));
			Assert.That(op_update.TableName, Is.EqualTo(tableName));
			Assert.That(op_update.ColumnName, Is.EqualTo(columnName));
			Assert.That(op_update.Description, Is.EqualTo(description));

			expectedQuery += string.Format(",\n												@level2type=N'COLUMN', @level2name='{0}'", columnName);
			Assert.That(op_update.ToQuery(), Is.EqualTo(expectedQuery));
		}
	}
}
