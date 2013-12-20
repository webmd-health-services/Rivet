using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddSchemaOperationTestFixture
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
			Assert.That(op.Name, Is.EqualTo(schemaName));
			Assert.That(op.Owner, Is.EqualTo(schemaOwner));

			var expectedQuery = string.Format("create schema [{0}] authorization [{1}]", schemaName, schemaOwner);
			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));

			//Test for Input with Schema Only
			op = new AddSchemaOperation(schemaName, null);
			Assert.That(op.Name, Is.EqualTo(schemaName));
			Assert.That(op.Owner, Is.EqualTo(null));

			expectedQuery = string.Format("create schema [{0}]", schemaName);
			Assert.That(op.ToQuery(), Is.EqualTo(expectedQuery));

		}
	}
}
