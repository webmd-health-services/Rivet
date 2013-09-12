using System.Collections.Generic;

namespace Rivet.Operations
{
	public sealed class AddTableOperation : Operation
	{
		public AddTableOperation(string schemaName, string tableName, Column[] columns, bool fileTable, string fileGroup,
		                         string textImageFileGroup, string fileStreamFileGroup, string[] options, string description)
		{
			SchemaName = schemaName;
			TableName = tableName;
			Columns = new List<Column>(columns ?? new Column[0]);
			FileTable = fileTable;
			FileGroup = fileGroup;
			TextImageFileGroup = textImageFileGroup;
			FileStreamFileGroup = fileStreamFileGroup;
			Options = new List<string>(options ?? new string[0]);
			Description = description;
		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public List<Column> Columns { get; private set; }
		public bool FileTable { get; private set; }
		public string FileGroup { get; private set; }
		public string TextImageFileGroup { get; private set; }
		public string FileStreamFileGroup { get; private set; }
		public List<string> Options { get; private set; }
		public string Description { get; private set; }

		public override string ToQuery()
		{
			var columnDefinitionClause = "";
			if (FileTable)
			{
				columnDefinitionClause = "as FileTable";
			}
			else
			{
				var columnDefinitionList = new List<string>();
				foreach (Column column in Columns)
				{
					columnDefinitionList.Add(column.GetColumnDefinition(TableName, SchemaName, false));
				}
				columnDefinitionClause = string.Join(", \r\n", columnDefinitionList.ToArray());
				columnDefinitionClause = string.Format("( {0} )", columnDefinitionClause);
			}

			var fileGroupClause = "";
			if (!string.IsNullOrEmpty(FileGroup))
			{
				fileGroupClause = string.Format("on {0}", FileGroup);
			}

			var textImageFileGroupClause = "";
			if (!string.IsNullOrEmpty(TextImageFileGroup))
			{
				textImageFileGroupClause = string.Format("textimage_on {0}", TextImageFileGroup);
			}

			var fileStreamFileGroupClause = "";
			if (!string.IsNullOrEmpty(FileStreamFileGroup))
			{
				fileStreamFileGroupClause = string.Format("filestream_on {0}", FileStreamFileGroup);
			}

			var optionsClause = "";
			if (Options.Count > 0)
			{
				optionsClause = string.Join(", ", Options.ToArray());
				optionsClause = string.Format("with ( {0} )", optionsClause);
			}

			var query = string.Format(@"
			create table [{0}].[{1}] {2}
						{3}
						{4}
						{5}
						{6}", SchemaName, TableName, columnDefinitionClause, fileGroupClause, textImageFileGroupClause, fileStreamFileGroupClause, optionsClause);

			return query;
		}
	}
}
