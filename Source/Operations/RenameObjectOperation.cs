using System;

namespace Rivet.Operations
{
	public class RenameObjectOperation : RenameOperation
	{
		public RenameObjectOperation(string schemaName, string name, string newName) :
			this(schemaName, name, newName, "OBJECT")
		{
		}

		public RenameObjectOperation(string schemaName, string name, string newName, string objectType) :
			base(schemaName, name, newName, objectType)
		{
		}

		public override string ObjectName => $"{SchemaName}.{Name}";

		protected override MergeResult DoMerge(Operation operation)
		{
			if (base.DoMerge(operation) == MergeResult.Stop)
				return MergeResult.Stop;

			if (operation is RenameTableObjectOperation otherAsRenameTableObjectOp &&
			    ObjectName.Equals(otherAsRenameTableObjectOp.TableObjectName, StringComparison.InvariantCultureIgnoreCase))

			{
				otherAsRenameTableObjectOp.TableName = Name;
				return MergeResult.Continue;
			}

			return MergeResult.Continue;
		}

		protected override string GetSpRenameObjNameParameter()
		{
			return $"[{SchemaName}].[{Name}]";
		}
	}
}
