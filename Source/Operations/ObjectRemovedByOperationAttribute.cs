using Rivet.Operations;
using System;

namespace Rivet.Operations
{
	internal sealed class ObjectRemovedByOperationAttribute : Attribute
	{
		internal ObjectRemovedByOperationAttribute(Type type)
		{
			RemovedBy = type;
		}

		internal Type RemovedBy { get; private set; }
	}
}
