using System;

namespace Rivet.Operations
{
	public sealed class RemoveSchemaOperation : Operation
	{
		public RemoveSchemaOperation(string name)
		{
			Name = name;
		}

		public string Name { get; set; }

		public override OperationQueryType QueryType => OperationQueryType.Ddl;

		public override string ToIdempotentQuery()
		{
			return $"if exists (select * from sys.schemas where name = '{Name}'){Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"drop schema [{Name}]";
		}
	}
}
