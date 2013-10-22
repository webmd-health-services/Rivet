using System;
using System.Collections.Generic;

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

		public override string ToQuery()
		{
			//Add
			var addColumnClause = "";
			if (AddColumns.Count > 0)
			{
				
				var addColumnList = new List<string>();
				foreach (Column column in AddColumns)
				{
					addColumnList.Add(column.GetColumnDefinition(Name, SchemaName, false));
				}
				addColumnClause = string.Join(", ", addColumnList.ToArray());
				addColumnClause = string.Format("alter table [{0}].[{1}] add {2} {3}", SchemaName, Name, addColumnClause, Environment.NewLine);
			}
			//Update
			var updateColumnClause = "";
			if (UpdateColumns.Count > 0)
			{
				var updateColumnList = new List<string>();
				foreach (Column column in UpdateColumns)
				{
					updateColumnList.Add(column.GetColumnDefinition(Name, SchemaName, false));
				}

				for (var i = 0; i < updateColumnList.Count; i++)
				{
					updateColumnList[i] = string.Format("alter table [{0}].[{1}] alter column {2}", SchemaName, Name, updateColumnList[i]);
				}

				updateColumnClause = string.Join(Environment.NewLine, updateColumnList.ToArray());
			}

			return string.Format("{0}{1}", addColumnClause, updateColumnClause);
		}
	}

}