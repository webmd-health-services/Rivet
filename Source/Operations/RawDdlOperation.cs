﻿namespace Rivet.Operations
{
	public class RawDdlOperation : Operation
	{
		public RawDdlOperation(string query)
		{
			Query = query;
		}

		public string Query { get; set; }

		public override OperationQueryType QueryType => OperationQueryType.Ddl;

		public override string ToIdempotentQuery()
		{
			return ToQuery();
		}

		public override string ToQuery()
		{
			return Query;
		}
	}
}
