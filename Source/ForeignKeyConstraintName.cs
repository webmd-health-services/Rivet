using System;
using System.Collections.Generic;

namespace Rivet
{
	public class ForeignKeyConstraintName
	{
		public ForeignKeyConstraintName(string schemaName, string tableName, string referencesSchemaName, string referencesTableName)
		{
			SchemaName = schemaName;
			TableName = tableName;
			ReferencesSchemaName = referencesSchemaName;
			ReferencesTableName = referencesTableName;
			Name = ToString();
		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string ReferencesSchemaName { get; private set; }
		public string ReferencesTableName { get; private set; }
		public string Name { get; private set; }

		public new string ToString()
		{
			
			var name = string.Format("FK_{0}_{1}_{2}_{3}", SchemaName, TableName, ReferencesSchemaName, ReferencesTableName);

			if (string.Equals(SchemaName, "dbo", StringComparison.InvariantCultureIgnoreCase) &&
			    !string.Equals(ReferencesSchemaName, "dbo", StringComparison.InvariantCultureIgnoreCase))
			{
				name = string.Format("FK_{0}_{1}_{2}", TableName, ReferencesSchemaName, ReferencesTableName);
			}

			if (!string.Equals(SchemaName, "dbo", StringComparison.InvariantCultureIgnoreCase) &&
				string.Equals(ReferencesSchemaName, "dbo", StringComparison.InvariantCultureIgnoreCase))
			{
				name = string.Format("FK_{0}_{1}_{2}", SchemaName, TableName, ReferencesTableName);
			}

			if (string.Equals(SchemaName, "dbo", StringComparison.InvariantCultureIgnoreCase) &&
				string.Equals(ReferencesSchemaName, "dbo", StringComparison.InvariantCultureIgnoreCase))
			{
				name = string.Format("FK_{0}_{1}", TableName, ReferencesTableName);
			}
			
			return name;
		}
	}
}