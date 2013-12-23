using System;
using System.Collections.Generic;
using System.Text;

namespace Rivet.Operations
{

	public sealed class UpdateTableOperation : ObjectOperation
	{
		public UpdateTableOperation(string schemaName, string name, Column[] addColumns, Column[] updateColumns, string[] removeColumns)
			: base(schemaName, name)
		{
			AddColumns = new List<Column>(addColumns ?? new Column[0]);
			UpdateColumns = new List<Column>(updateColumns ?? new Column[0]);
			RemoveColumns = new List<string>(removeColumns ?? new string[0]);
		}

		public List<Column> AddColumns { get; private set; }
		public List<string> RemoveColumns { get; private set; } 
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
				if (query.Length > 0)
				{
					query.AppendLine();
				}
				if (idempotent)
				{
					query.AppendFormat(
						"if not exists (select * from sys.columns where object_id('{0}.{1}', 'U') = [object_id] and [name]='{2}'){3}\t",
						SchemaName, Name, column.Name, Environment.NewLine);
				}
				var definition = column.GetColumnDefinition(Name, SchemaName, false);
				query.AppendFormat("alter table [{0}].[{1}] add {2}", SchemaName, Name, definition);
			}

			foreach (var column in UpdateColumns)
			{
				if (query.Length > 0)
				{
					query.AppendLine();
				}

				var definition = column.GetColumnDefinition(Name, SchemaName, false);
				query.AppendFormat("alter table [{0}].[{1}] alter column {2}", SchemaName, Name, definition);
			}

			foreach (var columnName in RemoveColumns)
			{
				if (query.Length > 0)
				{
					query.AppendLine();
				}
				if (idempotent)
				{
					query.AppendFormat("if exists (select * from sys.columns where object_id('{0}.{1}', 'U') = [object_id] and [name]='{2}'){3}\t",
						SchemaName, Name, columnName, Environment.NewLine);
				}
				query.AppendFormat("alter table [{0}].[{1}] drop column [{2}]", SchemaName, Name, columnName);
			}

			return query.ToString();
		}
	}

}