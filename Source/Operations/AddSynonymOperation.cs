using System;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveSynonymOperation))]
	public sealed class AddSynonymOperation : ObjectOperation
	{
		public AddSynonymOperation(string schemaName, string name, string targetSchemaName, string targetDatabaseName, string targetObjectName)
			: base(schemaName, name)
		{
			TargetSchemaName = targetSchemaName;
			TargetDatabaseName = targetDatabaseName;
			TargetObjectName = targetObjectName;
		}

		public string TargetSchemaName { get; set; }

		public string TargetDatabaseName { get; set; }

		public string TargetObjectName { get; set; }

		protected override MergeResult DoMerge(Operation operation)
		{
			if (base.DoMerge(operation) == MergeResult.Stop)
				return MergeResult.Stop;

			if ( !String.IsNullOrEmpty(TargetDatabaseName) )
				return MergeResult.Continue;

			if( !(operation is RenameObjectOperation otherAsRenameOp) )
				return MergeResult.Continue;

			if( $"{TargetSchemaName}.{TargetObjectName}".Equals($"{otherAsRenameOp.SchemaName}.{otherAsRenameOp.Name}", StringComparison.InvariantCultureIgnoreCase) )
			{
				TargetObjectName = otherAsRenameOp.NewName;
				operation.Disabled = true;
				return MergeResult.Continue;
			}

			return MergeResult.Continue;
		}

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}', 'SN') is null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			if (string.IsNullOrEmpty(TargetDatabaseName))
			{
				return string.Format("create synonym [{0}].[{1}] for [{2}].[{3}]", SchemaName, Name, TargetSchemaName, TargetObjectName);
			}
			return string.Format("create synonym [{0}].[{1}] for [{2}].[{3}].[{4}]", SchemaName, Name, TargetDatabaseName, TargetSchemaName, TargetObjectName);
		}
	}
}