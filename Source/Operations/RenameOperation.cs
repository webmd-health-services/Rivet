using System;
using System.Collections.Generic;
using System.Text;

namespace Rivet.Operations
{
	public abstract class RenameOperation : Operation
	{
		protected RenameOperation(string schemaName, string name, string newName, string type)
		{
			SchemaName = schemaName;
			Name = name;
			NewName = newName;
			Type = type;
		}

		public string Name { get; set; }

		public string NewName { get; set; }

		public string SchemaName { get; set; }

		public abstract string ObjectName { get; }

		public override OperationQueryType QueryType => OperationQueryType.Scalar;

		public string Type { get; set; }

		protected abstract string GetSpRenameObjNameParameter();

		protected override MergeResult DoMerge(Operation operation)
		{
			if (base.DoMerge(operation) == MergeResult.Stop)
				return MergeResult.Stop;

			if (operation is RenameOperation otherAsRenameOp &&
				ObjectName.Equals(otherAsRenameOp.ObjectName, StringComparison.InvariantCultureIgnoreCase) )
			{
				Name = otherAsRenameOp.NewName;
				otherAsRenameOp.Disabled = true;
				return MergeResult.Continue;
			}

			return MergeResult.Continue;
		}

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}') is not null and object_id('{0}.{2}') is null{3}begin{3}\t{4}{3}end", SchemaName, Name, NewName, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("declare @result{0} int{1}exec @result{0} = sp_rename @objname = '{2}', @newname = '{3}', @objtype = '{4}'{1}select @result{0}", Guid.NewGuid().ToString("N"), Environment.NewLine, GetSpRenameObjNameParameter(), NewName, Type);
		}
	}
}
