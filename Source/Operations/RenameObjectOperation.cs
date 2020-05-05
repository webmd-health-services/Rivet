using System;

namespace Rivet.Operations
{
	public class RenameObjectOperation : RenameOperation
	{
		public RenameObjectOperation(string schemaName, string name, string newName) :
			base(schemaName, name, newName, "OBJECT")
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

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}') is not null and object_id('{SchemaName}.{NewName}') is null{Environment.NewLine}" +
			       $"begin{Environment.NewLine}" +
			       $"    {ToIndentedQuery()}{Environment.NewLine}" +
			       "end";
		}
	}
}
