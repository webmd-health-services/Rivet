using System;

namespace Rivet.Operations
{
	public sealed class RemoveRowOperation : Operation
	{
		// Drop Specific Rows
		public RemoveRowOperation(string schemaName, string tableName, string where)
		{
			All = false;
			SchemaName = schemaName;
			TableName = tableName;
			Where = where;
		}

		// Drop All Rows
		public RemoveRowOperation(string schemaName, string tableName, bool truncate)
		{
			All = true;
			SchemaName = schemaName;
			TableName = tableName;
			Truncate = truncate;
		}

		public bool All { get; set; }

		public string SchemaName { get; set; }

		public string TableName { get; set; }

		public bool Truncate { get; set; }

		public string Where { get; set; }

		public override OperationQueryType QueryType => OperationQueryType.NonQuery;

		public override string ToIdempotentQuery()
		{
			return ToQuery();
		}

		public override string ToQuery()
		{
			var query = "";

			switch (All)
			{
				case false: //Drop Specific Rows
					query = String.Format("delete from [{0}].[{1}] where {2}", SchemaName, TableName, Where);
					break;
				case true: //Drop All Rows
					query = String.Format(Truncate == false ? "delete from [{0}].[{1}]" : "truncate table  [{0}].[{1}]", SchemaName, TableName);
					break;
			}

			return query;
		}
	}
}