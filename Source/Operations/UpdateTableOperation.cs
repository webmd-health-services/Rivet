using System;
using System.Collections.Generic;
using System.Text;

namespace Rivet.Operations
{

	public sealed class UpdateTableOperation : Operation
	{
		public UpdateTableOperation(string schemaName, string name, Column[] addColumns, Column[] updateColumns)
		{
			SchemaName = schemaName;
			Name = name;
			AddColumns = new List<Column>(addColumns ?? new Column[0]);
			UpdateColumns = new List<Column>(updateColumns ?? new Column[0]);
		}

		public string SchemaName { get; private set; }
		public string Name { get; private set; }
		public List<Column> AddColumns { get; private set; }
		public List<Column> UpdateColumns { get; private set; }

		public override string ToIdempotentQuery()
		{
			return ToQuery(true);
		}

		public override string ToQuery()
		{
			return ToQuery(false);
		}

		private string ToQuery(bool idempotent)
		{
			var query = new StringBuilder();

			foreach (var column in AddColumns)
			{
				if (idempotent)
				{
					query.AppendFormat(
						"if not exists (select * from sys.columns where object_id('{0}.{1}', 'U') = object_id and name='{2}'){3}\t",
						SchemaName, Name, Name, Environment.NewLine);
				}
				var definition = column.GetColumnDefinition(Name, SchemaName, false);
				query.AppendFormat("alter table [{0}].[{1}] add {2}{3}", SchemaName, Name, definition, Environment.NewLine);
			}

			foreach (var column in UpdateColumns)
			{
				var definition = column.GetColumnDefinition(Name, SchemaName, false);
				query.AppendFormat("alter table [{0}].[{1}] alter column {2}{3}", SchemaName, Name, definition, Environment.NewLine);
			}

			return query.ToString();
		}
	}

}