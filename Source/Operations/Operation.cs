namespace Rivet.Operations
{
	public abstract class Operation
	{
		public abstract string ToQuery();

		public abstract string ToIdempotentQuery();

	}
}
