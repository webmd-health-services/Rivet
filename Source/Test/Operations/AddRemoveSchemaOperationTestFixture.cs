using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddRemoveSchemaOperationTestFixture
	{
		[SetUp]
		public void SetUp()
		{
			
		}

		[Test]
		public void ShouldSetPropertiesForSchema()
		{
			var schemaName = "schemaName";
			var schemaOwner = "schemaOwner";

			/** ADD SCHEMA OPERATION **/

            //Test for Input with Both Schema and Owner
            var op = new AddSchemaOperation(schemaName, schemaOwner);
            Assert.That(op.SchemaName, Is.EqualTo(schemaName));
            Assert.That(op.SchemaOwner, Is.EqualTo(schemaOwner));

            var expectedQuery = string.Format("create schema [{0}] authorization [{1}]", schemaName, schemaOwner);
            Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));

            //Test for Input with Schema Only
            op = new AddSchemaOperation(schemaName, null);
            Assert.That(op.SchemaName, Is.EqualTo(schemaName));
            Assert.That(op.SchemaOwner, Is.EqualTo(null));

            expectedQuery = string.Format("create schema [{0}]", schemaName);
            Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));

			/** REMOVE SCHEMA OPERATION **/

			var op_remove = new RemoveSchemaOperation(schemaName);
			Assert.That(op_remove.SchemaName, Is.EqualTo(schemaName));

			expectedQuery = string.Format("drop schema [{0}]", schemaName);
			Assert.That(op_remove.ToQuery(), Is.EqualTo(expectedQuery));
		}
	}
}
