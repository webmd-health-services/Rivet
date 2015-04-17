using System;

namespace Rivet
{
	public class ForeignKeyConstraintName
	{
		private readonly string _name;

		public ForeignKeyConstraintName(string schemaName, string tableName, string referencesSchemaName, string referencesTableName)
		{
			SchemaName = schemaName;
			TableName = tableName;
			ReferencesSchemaName = referencesSchemaName;
			ReferencesTableName = referencesTableName;
		}

		public ForeignKeyConstraintName(string name)
		{
			_name = name;
		}

		public string SchemaName { get; set; }
		public string TableName { get; set; }
		public string ReferencesSchemaName { get; set; }
		public string ReferencesTableName { get; set; }
		public string Name { get { return ToString();  } }

		public override string ToString()
		{
			if (!String.IsNullOrEmpty(_name))
			{
				return _name;
			}

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