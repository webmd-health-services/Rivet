using System;

namespace Rivet.Operations
{
	public sealed class RemoveViewOperation : ObjectOperation
	{
		public RemoveViewOperation(string schemaName, string name)
			: base(schemaName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}', 'V') is not null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("drop view [{0}].[{1}]", SchemaName, Name);
		}
	}
}
