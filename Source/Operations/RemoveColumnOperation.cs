using System;

namespace Rivet.Operations
{
	public sealed class RemoveColumnOperation : Operation
	{
		public RemoveColumnOperation(string schemaName, string tableName, string name)
		{
			SchemaName = schemaName;
			TableName = tableName;
			Name = name;
		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string Name { get; private set; }

		public override string ToIdempotentQuery()
		{
			return
				string.Format(
					"if exists (select * from sys.columns where object_id('{0}.{1}', 'U') = object_id and name='{2}'){3}\t{4}",
					SchemaName, TableName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			var query = string.Format("alter table [{0}].[{1}] drop column [{2}]", SchemaName, TableName, Name);
			return query;
		}
	}
}
