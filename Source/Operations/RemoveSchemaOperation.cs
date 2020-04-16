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
			return string.Format("if exists (select * from sys.schemas where name = '{0}'){1}\t{2}", Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("drop schema [{0}]", Name);
		}
	}
}
