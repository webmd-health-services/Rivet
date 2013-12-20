using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveSchemaOperationTestFixture
	{
		[Test]
		public void ShouldSetPropertiesForSchema()
		{
			var schemaName = "schemaName";

			var op_remove = new RemoveSchemaOperation(schemaName);
			Assert.That(op_remove.Name, Is.EqualTo(schemaName));

			var expectedQuery = string.Format("drop schema [{0}]", schemaName);
			Assert.That(op_remove.ToQuery(), Is.EqualTo(expectedQuery));
		}
	}
}
