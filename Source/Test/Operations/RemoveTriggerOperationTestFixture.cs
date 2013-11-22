using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveTriggerOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string TriggerName = "triggerName";

		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForRemoveTrigger()
		{
			var op = new RemoveTriggerOperation(SchemaName, TriggerName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TriggerName, op.Name);
		}

		[Test]
		public void ShouldWriteQueryForRemoveTrigger()
		{
			var op = new RemoveTriggerOperation(SchemaName, TriggerName);
			const string expectedQuery = "drop trigger [schemaName].[triggerName]";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}