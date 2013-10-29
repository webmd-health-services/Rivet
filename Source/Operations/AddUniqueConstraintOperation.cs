using System.Collections.Generic;

namespace Rivet.Operations
{
	public sealed class AddUniqueConstraintOperation : Operation
	{
		//System Generated Constraint Name
		public AddUniqueConstraintOperation(string schemaName, string tableName, string[] columnName, bool clustered,
		                                    int fillFactor, string[] options, string filegroup)
		{
			ConstraintName = new ConstraintName(schemaName, tableName, columnName, ConstraintType.Unique);
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

		//Custom Constraint Name
		public AddUniqueConstraintOperation(string schemaName, string tableName, string[] columnName, string customConstraintName, bool clustered,
									int fillFactor, string[] options, string filegroup)
		{
			ConstraintName = new ConstraintName(customConstraintName);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone();
			Clustered = clustered;
			FillFactor = fillFactor;
			if (options != null)
			{
				Options = (string[])options.Clone();
			}
			else
			{
				Options = null;
			}
			FileGroup = filegroup;
		}

		public ConstraintName ConstraintName { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string[] ColumnName { get; private set; }
		public bool Clustered { get; private set; }
		public int FillFactor { get; private set; }
		public string[] Options { get; private set; }
		public string FileGroup { get; private set; }

		public override string ToQuery()
		{
			var clusteredClause = "";
			if (Clustered)
			{
				clusteredClause = "clustered";
			}

			var fillFactorClause = "";
			var optionClause = "";		// (1)

			if (Options != null && FillFactor == 0) //Options, but no FillFactor (2)
			{
				optionClause = string.Join(", ", Options);
				optionClause = string.Format("with ({0})", optionClause);
			}

			if (Options == null && FillFactor > 0) //No Options, but with FillFactor (3)
			{
				fillFactorClause = string.Format("fillfactor = {0}", FillFactor.ToString());
				optionClause = string.Format("with ({0})", fillFactorClause);
			}

			if (Options != null && FillFactor > 0) //Options and FillFactor (4)
			{
				fillFactorClause = string.Format("fillfactor = {0}", FillFactor.ToString());
				List<string> optionsList = new List<string>(Options);
				optionsList.Add(fillFactorClause);
				Options = optionsList.ToArray();
				optionClause = string.Join(", ", Options);
				optionClause = string.Format("with ({0})", optionClause);
			}

			var fileGroupClause = "";
			if (!string.IsNullOrEmpty(FileGroup))
			{
				fileGroupClause = string.Format("on {0}", FileGroup);
			}

			var columnClause = string.Join(",", ColumnName);

			return string.Format("alter table [{0}].[{1}] add constraint [{2}] unique {3}({4}) {5} {6}", 
				SchemaName, TableName, ConstraintName.ToString(), clusteredClause, columnClause, optionClause, fileGroupClause);

		}
	}
}
