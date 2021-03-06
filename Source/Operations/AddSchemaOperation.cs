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
			var query = string.Format("create schema [{0}]", Name);
			
			if (!string.IsNullOrEmpty(Owner)) 
			{
				query = string.Format("{0} authorization [{1}]", query, Owner);
			}

			return string.Format("if not exists (select * from sys.schemas where name = '{0}'){1}\t exec sp_executesql N'{2}'",
				Name, Environment.NewLine, query);
		}
	}
}
