using System;
using System.Collections.Generic;

namespace Rivet.Operations
{
	public enum Datatypeoperation
	{
		From,
		Assembly,
		Table
	}
	
	public sealed class AddDataTypeOperation : Operation
	{
		// Create an alias type
		public AddDataTypeOperation(string schemaName, string name, string from)
		{
			Type = Datatypeoperation.From;
			SchemaName = schemaName;
			Name = name;
			From = from;
		}
		 
		// Create a user-defined type
		public AddDataTypeOperation(string schemaName, string name, string assemblyName, string className)
		{
			Type = Datatypeoperation.Assembly;
			SchemaName = schemaName;
			Name = name;
			AssemblyName = assemblyName;
			ClassName = className;
		}

		// Create a user-defined table type
		public AddDataTypeOperation(string schemaName, string name, Column[] asTable, string[] tableConstraint)
		{
			Type = Datatypeoperation.Table;
			SchemaName = schemaName;
			Name = name;
			AsTable = new List<Column>(asTable ?? new Column[0]);
			TableConstraint = new List<string>(tableConstraint ?? new string[0]);
		}


		private Datatypeoperation Type { get; set; }
		public string SchemaName { get; private set; }
		public string Name { get; private set; }
		public string From { get; private set; }
		public string AssemblyName { get; private set; }
		public string ClassName { get; private set; }
		public List<Column> AsTable { get; private set; }
		public List<string> TableConstraint { get; private set; }

		public override string ToQuery()
		{
			switch (Type)
			{
				case Datatypeoperation.From:
					return string.Format("create type [{0}].{1} from {2}", SchemaName, Name, From);
				case Datatypeoperation.Assembly:
					return string.Format("create type [{0}].{1} external name {2}.[{3}] ", SchemaName, Name, AssemblyName, ClassName);
				case Datatypeoperation.Table:
					var columnDefinitionList = new List<string>();
					foreach (Column column in AsTable)
					{
						columnDefinitionList.Add(column.GetColumnDefinition(Name,SchemaName,false));
					}
					string columnDefinitionClause = string.Join(", ", columnDefinitionList.ToArray());
					var tableConstraintClause = string.Join(", ", TableConstraint.ToArray());
					columnDefinitionClause = string.Format("({0} {1})", columnDefinitionClause, tableConstraintClause);
					var query = string.Format("create type [{0}].{1} as table {2}", SchemaName, Name, columnDefinitionClause);
					return query;
				default:
					throw new ArgumentOutOfRangeException();
			}
		}
	}
}