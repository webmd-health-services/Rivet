﻿using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class RemoveTriggerOperationTestFixture
	{
		const string SchemaName = "schemaName";
		const string TriggerName = "triggerName";

		[Test]
		public void ShouldSetPropertiesForRemoveTrigger()
		{
			var op = new RemoveTriggerOperation(SchemaName, TriggerName);
			Assert.AreEqual(SchemaName, op.SchemaName);
			Assert.AreEqual(TriggerName, op.Name);
			Assert.That(op.ObjectName, Is.EqualTo(string.Format("{0}.{1}", SchemaName, TriggerName)));
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