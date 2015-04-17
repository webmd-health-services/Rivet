using System;

namespace Rivet.Operations
{
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