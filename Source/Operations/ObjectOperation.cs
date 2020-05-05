using System;

namespace Rivet.Operations
{
	public abstract class ObjectOperation : Operation
	{
		protected ObjectOperation(string schemaName, string name)
		{
			SchemaName = schemaName;
			Name = name;
		}

		/// <summary>
		/// The name of the object.
		/// </summary>
		public string Name { get; set; }

		public override OperationQueryType QueryType => OperationQueryType.Ddl;

		public virtual string ObjectName => $"{SchemaName}.{Name}";

		public string SchemaName { get; set; }

		protected override MergeResult DoMerge(Operation operation)
		{
			if (base.DoMerge(operation) == MergeResult.Stop)
				return MergeResult.Stop;

			// Ignore object operations that don't operate on this object.
			if (operation is ObjectOperation otherAsObjectOp &&
				!ObjectName.Equals(otherAsObjectOp.ObjectName, StringComparison.InvariantCultureIgnoreCase))
				return MergeResult.Stop;

			if (operation is RenameObjectOperation otherAsRenameOp)
			{
				// If the object is being renamed.
				if (ObjectName.Equals(otherAsRenameOp.ObjectName, StringComparison.InvariantCultureIgnoreCase))
				{
					Name = otherAsRenameOp.NewName;
					otherAsRenameOp.Disabled = true;
					return MergeResult.Stop;
				}
			}

			return MergeResult.Continue;
		}
	}
}
