using System;

namespace Rivet.Operations
{
	public sealed class RemoveDataTypeOperation : ObjectOperation
	{
		public RemoveDataTypeOperation(string schemaName, string name)
			: base(schemaName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return String.Format("if object_id('{0}.{1}', 'TT') is not null or type_id('{0}.{1}') is not null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("drop type [{0}].[{1}]", SchemaName, Name);
		}
	}
}