using System;

namespace Rivet.Operations
{
	public sealed class RawQueryOperation : Operation
	{
		public RawQueryOperation(string query)
		{
			Query = query;
		}

		public string Query { get; private set; }

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
