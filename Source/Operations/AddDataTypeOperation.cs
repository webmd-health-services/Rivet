using System;
using System.Collections.Generic;

namespace Rivet.Operations
{
	public enum DatatypeOperation
	{
		From,
		Assembly,
		Table
	}
	
	public sealed class AddDataTypeOperation : ObjectOperation
	{
		// Create an alias type
		public AddDataTypeOperation(string schemaName, string name, string from)
			: base(schemaName, name)
		{
			Type = DatatypeOperation.From;
			From = from;
		}
		 
		// Create a user-defined type
		public AddDataTypeOperation(string schemaName, string name, string assemblyName, string className)
			: base(schemaName, name)
		{
			Type = DatatypeOperation.Assembly;
			AssemblyName = assemblyName;
			ClassName = className;
		}

		// Create a user-defined table type
		public AddDataTypeOperation(string schemaName, string name, Column[] asTable, string[] tableConstraint)
			: base(schemaName, name)
		{
			Type = DatatypeOperation.Table;
			AsTable = new List<Column>(asTable ?? new Column[0]);
			TableConstraint = new List<string>(tableConstraint ?? new string[0]);
		}


		public string AssemblyName { get; private set; }
		public List<Column> AsTable { get; private set; }
		public string ClassName { get; private set; }
		public string From { get; private set; }
		public List<string> TableConstraint { get; private set; }
		private DatatypeOperation Type { get; set; }

		public override string ToIdempotentQuery()
		{
			if (Type == DatatypeOperation.Table)
			{
				return String.Format("if object_id('{0}.{1}', 'TT') is null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
			}
			return string.Format("if type_id('{0}.{1}') is null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			switch (Type)
			{
				case DatatypeOperation.From:
					return string.Format("create type [{0}].[{1}] from {2}", SchemaName, Name, From);
				case DatatypeOperation.Assembly:
					return string.Format("create type [{0}].[{1}] external name {2}.[{3}]", SchemaName, Name, AssemblyName, ClassName);
				case DatatypeOperation.Table:
					var columnDefinitionList = new List<string>();
					foreach (Column column in AsTable)
					{
						columnDefinitionList.Add(column.GetColumnDefinition(Name,SchemaName,false));
					}
					string columnDefinitionClause = string.Join(", ", columnDefinitionList.ToArray());
					var tableConstraintClause = string.Join(", ", TableConstraint.ToArray());
					columnDefinitionClause = string.Format("({0} {1})", columnDefinitionClause, tableConstraintClause);
					var query = string.Format("create type [{0}].[{1}] as table {2}", SchemaName, Name, columnDefinitionClause);
					return query;
				default:
					throw new ArgumentOutOfRangeException();
			}
		}
	}
}