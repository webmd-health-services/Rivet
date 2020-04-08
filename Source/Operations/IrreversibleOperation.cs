using System;

namespace Rivet.Operations
{
	public sealed class IrreversibleOperation : Operation
	{

		public IrreversibleOperation(string errorMessage)
		{
			ErrorMessage = errorMessage;
		}

		public string ErrorMessage { get; set; }

		public override OperationQueryType QueryType => throw new NotImplementedException();

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
