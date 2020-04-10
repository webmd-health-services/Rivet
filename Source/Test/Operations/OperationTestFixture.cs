using NUnit.Framework;
using Rivet.Operations;
using System;
using System.Collections;
using System.Linq;

namespace Rivet.Test
{
	[TestFixture]
	internal sealed class OperationTestFixture
	{
		private class TestOperation : Operation
		{
			public bool MergeCalled { get; private set; }

			public Operation OtherOperation { get; private set; }

			public override OperationQueryType QueryType => throw new NotImplementedException();

			protected override MergeResult DoMerge(Operation op)
			{
				MergeCalled = true;
				OtherOperation = op;
				return MergeResult.Continue;
			}

			public override string ToIdempotentQuery()
			{
				throw new NotImplementedException();
			}

			public override string ToQuery()
			{
				throw new NotImplementedException();
			}
		}

		[Test]
		public void ShouldNotMergeIfReceivingOperationDisabled()
		{
			var op = new TestOperation
			{
				Disabled = true
			};
			var otherOp = new TestOperation();
			op.Merge(otherOp);
			Assert.That(op.MergeCalled, Is.False);
		}

		[Test]
		public void ShouldMergeIfOtherOperationDisabled()
		{
			var op = new TestOperation();
			var otherOp = new TestOperation
			{
				Disabled = true
			};
			op.Merge(otherOp);
			Assert.That(op.MergeCalled, Is.True);
		}

		[Test]
		public void ShouldNotMergeIfRightOperationNull()
		{
			Assert.Throws<ArgumentNullException>(() => new TestOperation().Merge(null));
		}

		[Test]
		public void ShouldMerge()
		{
			var op = new TestOperation();
			var otherOp = new TestOperation();
			op.Merge(otherOp);
			Assert.That(op.MergeCalled, Is.True);
			Assert.That(op.OtherOperation, Is.SameAs(otherOp));
		}

		[Test]
		public void ShouldNotRenameObjectIfDifferentObject()
		{
			var op = new AddStoredProcedureOperation("schema", "name", "definition");
			var renameOp = new RenameObjectOperation("SCHEMA", "another_object", "newname");
			op.Merge(renameOp);
			Assert.That(op.Disabled, Is.False);
			Assert.That(renameOp.Disabled, Is.False);
			Assert.That(op.Name, Is.EqualTo("name"));
		}

		[Test]
		public void ShouldAutomaticallyRemoveAddOperation()
		{
			var addOps = new Operation[]
			{
				new AddCheckConstraintOperation("schema", "table", "name", "expression", false, false),
				new AddDataTypeOperation("schema", "name", "from"),
				new AddDefaultConstraintOperation("schema", "table", "expression", "column", "name", false),
				new AddForeignKeyOperation("schema", "table", "name", new string[0], "ref schema", "ref table", new string[0], "on delete", "on update", false, false), 
				new AddIndexOperation("schema", "table", new string[0], "name", false, false, new string[0], "where", "on", "file stream on", new string[0]), 
				new AddPrimaryKeyOperation("schema", "table", "name", new string[0], false, new string[0]),
				new AddRowGuidColOperation("schema", "table", "column"),
				new AddSchemaOperation("schema", "owner"),
				new AddStoredProcedureOperation("schema", "name", "definition"),
				new AddSynonymOperation("schema", "name", "target schema name", "target database name", "target object name"), 
				new AddTableOperation("schema", "name", new Column[0], false, "file group", "text image file group", "file stream file group", new string[0]),
				new AddTriggerOperation("schema", "name", "definition"),
				new AddUniqueKeyOperation("schema", "table", "name", new string[0], false, 0, new string[0], "file group"),
				new AddUserDefinedFunctionOperation("schema", "name", "definition"),
				new AddViewOperation("schema", "name", "definition"),
				new UpdateStoredProcedureOperation("schema", "name", "definition"),
				new UpdateTableOperation("schema", "name", new Column[0], new Column[0], new string[0]),
				new UpdateTriggerOperation("schema", "name", "definition"),
				new UpdateUserDefinedFunctionOperation("schema", "name", "definition"),
				new UpdateViewOperation("schema", "name", "definition"),
			};
			var removeOps = new Operation[]
			{
				new RemoveCheckConstraintOperation("SCHEMA", "TABLE", "NAME"),
				new RemoveDataTypeOperation("SCHEMA", "NAME"),
				new RemoveDefaultConstraintOperation("SCHEMA", "TABLE", "COLUMN", "NAME"),
				new RemoveForeignKeyOperation("SCHEMA", "TABLE", "NAME"),
				new RemoveIndexOperation("SCHEMA", "TABLE", "NAME"),
				new RemovePrimaryKeyOperation("SCHEMA", "TABLE", "NAME"),
				new RemoveRowGuidColOperation("SCHEMA", "TABLE", "COLUMN"),
				new RemoveSchemaOperation("SCHEMA"),
				new RemoveStoredProcedureOperation("SCHEMA", "NAME"),
				new RemoveSynonymOperation("SCHEMA", "NAME"),
				new RemoveTableOperation("SCHEMA", "NAME"),
				new RemoveTriggerOperation("SCHEMA", "NAME"),
				new RemoveUniqueKeyOperation("SCHEMA", "TABLE", "NAME"),
				new RemoveUserDefinedFunctionOperation("SCHEMA", "NAME"),
				new RemoveViewOperation("SCHEMA", "NAME"),
				new RemoveStoredProcedureOperation("SCHEMA", "NAME"),
				new RemoveTableOperation("SCHEMA", "NAME"),
				new RemoveTriggerOperation("SCHEMA", "NAME"),
				new RemoveUserDefinedFunctionOperation("SCHEMA", "NAME"),
				new RemoveViewOperation("SCHEMA", "NAME"),
			};

			var missingOps = AppDomain.CurrentDomain.GetAssemblies()
				.Where(assembly => assembly.GetName().Name == "Rivet")
				.SelectMany(assembly => assembly.GetTypes())
				.Where(type => type.GetCustomAttributes(false).Any(a => a is ObjectRemovedByOperationAttribute))
				.Where(type => addOps.All(op => op.GetType() != type));

			Assert.That(missingOps, Is.Empty,
				$"Missing instances of types that have {typeof(ObjectRemovedByOperationAttribute)}");

			for (var idx = 0; idx < addOps.Length; ++idx)
			{
				var addOp = addOps[idx];
				var removeOp = removeOps[idx];
				addOp.Merge(removeOp);
				Assert.That(addOp.Disabled, Is.True);
				Assert.That(removeOp.Disabled, Is.True);
			}
		}
	}
}
