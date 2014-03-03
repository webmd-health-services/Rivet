using System;

namespace Rivet.Operations
{
	public sealed class RemoveTableOperation : ObjectOperation
	{
		public RemoveTableOperation(string schemaName, string name)
			: base(schemaName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}', 'U') is not null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("drop table [{0}].[{1}]", SchemaName, Name);
		}
	}
}
