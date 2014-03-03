using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class AddTriggerOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string TriggerName = "triggerName";
		const string Definition = "as definition";

		[SetUp]
		public void SetUp()
		{

		}

		[Test]
		public void ShouldSetPropertiesForAddTrigger()
		{
			var op = new AddTriggerOperation(SchemaName, TriggerName, Definition);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TriggerName, op.Name);
			Assert.AreEqual(Definition, op.Definition);
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}", SchemaName, TriggerName)));
		}

		[Test]
		public void ShouldWriteQueryForAddTrigger()
		{
			var op = new AddTriggerOperation(SchemaName, TriggerName, Definition);
			const string expectedQuery = "create trigger [schemaName].[triggerName] as definition";
			Assert.AreEqual(expectedQuery, op.ToQuery());
		}

	}
}