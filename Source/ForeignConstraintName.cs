using System.Collections.Generic;

namespace Rivet
{
	public class ForeignConstraintName
	{
		public ForeignConstraintName(string sourceSchema, string sourceTable, string targetSchema, string targetTable)
		{
			SourceSchema = sourceSchema;
			SourceTable = sourceTable;
			TargetSchema = targetSchema;
			TargetTable = targetTable;

		}

		public string SourceSchema { get; private set; }
		public string SourceTable { get; private set; }
		public string TargetSchema { get; private set; }
		public string TargetTable { get; private set; }

		public string ReturnConstraintName()
		{
			var name = string.Format("FK_{0}_{1}_{2}_{3}", SourceSchema, SourceTable, TargetSchema, TargetTable);
			if (string.Equals(SourceSchema, "dbo") && string.Equals(TargetSchema, "dbo"))
			{
				name = string.Format("FK_{0}_{1}", SourceTable, TargetTable);
			}
			return name;
		}
	}
}