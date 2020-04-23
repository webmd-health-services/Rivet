using System;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveSchemaOperation))]
	public sealed class AddSchemaOperation : Operation
	{
		public AddSchemaOperation(string name, string owner)
		{
			Name = name;
			Owner = owner;
		}

		public string Name { get; set; }

		public string Owner { get; set; }

		public override OperationQueryType QueryType => OperationQueryType.Ddl;

		public override string ToIdempotentQuery()
		{
			return ToQuery();
		}

		public override string ToQuery()
		{
			var query = $"create schema [{Name}]";
			
			if (!string.IsNullOrEmpty(Owner)) 
			{
				query = $"{query} authorization [{Owner}]";
			}

			return $"if not exists (select * from sys.schemas where name = '{Name}'){Environment.NewLine}" +
			       $"    exec sp_executesql N'{query}'";
		}
	}
}
