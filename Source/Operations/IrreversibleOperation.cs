using System;

namespace Rivet.Operations
{
	public sealed class IrreversibleOperation : Operation
	{

		public IrreversibleOperation(string errorMessage)
		{
			ErrorMessage = errorMessage;
		}

		public string ErrorMessage { get; private set; }

		public override string ToQuery()
		{
			throw new Exception(ErrorMessage);
		}

		public override string ToIdempotentQuery()
		{
			throw new Exception(ErrorMessage);
		}
	}
}
