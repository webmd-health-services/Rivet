using System;

namespace Rivet.Operations
{
	public sealed class UpdateColumnOperation : Operation
	{
		public UpdateColumnOperation(string schemaName, string tableName, Column changeInfo)
		{
			TableName = tableName;
			SchemaName = schemaName;
			ChangeInfo = changeInfo;
		}
		
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public Column ChangeInfo { get; private set; }

		public override string ToQuery()
		{
			var nullityClause = "";
			var sizeClause = "";
			var collateClause = "";

			//Extract type_name
			var datatype = ChangeInfo.DataType;

			//Extract NULL / NOTNULL
			if (ChangeInfo.Null)
			{
				nullityClause = " null";

				if (ChangeInfo.Sparse)
				{
					nullityClause = " sparse";
				}

			}
			else if (ChangeInfo.NotNull)
			{
				nullityClause = " not null";
			}


			if (!ReferenceEquals(ChangeInfo.Size,null))
			{
				sizeClause = String.Format(" {0}", ChangeInfo.Size.ToString());
			}

			if (datatype == DataType.VarChar || datatype == DataType.NVarChar || datatype == DataType.Char ||
			    datatype == DataType.NChar)
			{
				//Extract Collation 
				collateClause = String.Format(" collate {0}", ChangeInfo.Collation);
			}


			return string.Format("alter table [{0}].[{1}] alter column {2} {3}{4}{5}{6}", SchemaName, TableName, ChangeInfo.Name, datatype, sizeClause, collateClause, nullityClause);
		}
	}
}
