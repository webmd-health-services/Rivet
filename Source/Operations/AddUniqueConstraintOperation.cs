using System;
using System.Collections.Generic;

namespace Rivet.Operations
{
	public sealed class AddUniqueConstraintOperation : Operation
	{
		public AddUniqueConstraintOperation(string schemaName, string tableName, string[] columnName, bool clustered,
		                                    int fillFactor, string[] options, string filegroup)
		{
			Cons = new ConstraintName(schemaName, tableName, columnName, ConstraintType.Unique);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone();
			Clustered = clustered;
			FillFactor = fillFactor;
			if (options != null) {
				Options = (string[])options.Clone();
			} else {
				Options = null;
			}
			FileGroup = filegroup;
		}

		public ConstraintName Cons { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string[] ColumnName { get; private set; }
		public bool Clustered { get; private set; }
		public int FillFactor { get; private set; }
		public string[] Options { get; private set; }
		public string FileGroup { get; private set; }

		public override string ToQuery()
		{
			var ClusteredClause = "";
			if (Clustered)
			{
				ClusteredClause = "clustered";
			}

			var FillFactorClause = "";
			var OptionClause = "";		// (1)

			if (Options != null && FillFactor == 0) //Options, but no FillFactor (2)
			{
				OptionClause = string.Join(", ", Options);
				OptionClause = string.Format("with ({0})", OptionClause);
			}

			if (Options == null && FillFactor > 0) //No Options, but with FillFactor (3)
			{
				FillFactorClause = string.Format("fillfactor = {0}", FillFactor.ToString());
				OptionClause = string.Format("with ({0})", FillFactorClause);
			}

			if (Options != null && FillFactor > 0) //Options and FillFactor (4)
			{
				FillFactorClause = string.Format("fillfactor = {0}", FillFactor.ToString());
				List<string> OptionsList = new List<string>(Options);
				OptionsList.Add(FillFactorClause);
				Options = OptionsList.ToArray();
				OptionClause = string.Join(", ", Options);
				OptionClause = string.Format("with ({0})", OptionClause);
			}

			var FileGroupClause = "";
			if (!string.IsNullOrEmpty(FileGroup))
			{
				FileGroupClause = string.Format("on {0}", FileGroup);
			}

			var ColumnClause = string.Join(",", ColumnName);

			return string.Format("alter table {0}.{1} add constraint {2} unique {3}({4}) {5} {6}", 
				SchemaName, TableName, Cons.ReturnConstraintName(), ClusteredClause, ColumnClause, OptionClause, FileGroupClause);

		}
	}
}
