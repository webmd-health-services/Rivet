using System.Text;

namespace Rivet.Operations
{
	public abstract class ExtendedPropertyOperation : ObjectOperation
	{
		// Schema
		protected ExtendedPropertyOperation(string schemaName, string name)
			: base(schemaName, name)
		{
			ForSchema = true;
		}

		// Table or View
		protected ExtendedPropertyOperation(string schemaName, string tableViewName, string name, bool forView)
			: this(schemaName, name)
		{
			if (forView)
			{
				ForView = true;
			}
			else
			{
				ForTable = true;
			}
			TableViewName = tableViewName;
		}

		// Column
		protected ExtendedPropertyOperation(string schemaName, string tableViewName, string columnName, string name, bool forView)
			: this(schemaName, tableViewName, name, forView)
		{
			ForColumn = true;
			ColumnName = columnName;
		}

		public string ColumnName { get; private set; }
		public bool ForSchema { get; private set; }
		public bool ForTable { get; private set; }
		public bool ForView { get; private set; }
		public bool ForColumn { get; private set; }

		public override string ObjectName
		{
			get
			{
				var objectName = new StringBuilder(SchemaName);
				objectName.Append(".");
				if (ForTable || ForView)
				{
					objectName.Append(TableViewName);
					objectName.Append(".");
					if (ForColumn)
					{
						objectName.Append(ColumnName);
						objectName.AppendFormat(".");
					}
				}
				objectName.Append("@");
				objectName.Append(Name);
				return objectName.ToString();
			}
		}

		public string TableViewName { get; private set; }
	}
}
