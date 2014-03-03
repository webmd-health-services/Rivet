using System;

namespace Rivet.Operations
{
	public sealed class RemoveStoredProcedureOperation : ObjectOperation
	{
		public RemoveStoredProcedureOperation(string schemaName, string name)
			: base(schemaName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}', 'P') is not null or object_id('{0}.{1}', 'PC') is not null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("drop procedure [{0}].[{1}]", SchemaName, Name);
		}
	}
}
