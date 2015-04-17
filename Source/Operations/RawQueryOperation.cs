namespace Rivet.Operations
{
	public class RawQueryOperation : Operation
	{
		public RawQueryOperation(string query)
		{
			Query = query;
		}

		public string Query { get; set; }

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
