using System;
using System.Text;

namespace Rivet.Operations
{
	public abstract class ExtendedPropertyOperation : Operation
	{
		public readonly static string DescriptionPropertyName = "MS_Description";

		// TODO: change tableViewName to be ObjectName and change bool forView to ExtendedPropertyObjectType enumeration.
		// Schema
		protected ExtendedPropertyOperation(string schemaName, string name)
		{
			SchemaName = schemaName;
			Name = name;
			ForSchema = true;
		}

		// Table or View
		protected ExtendedPropertyOperation(string schemaName, string tableViewName, string name, bool forView)
			: this(schemaName, name)
		{
			ForSchema = false;
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

		public string ColumnName { get; set; }

		public bool ForSchema { get; set; }

		public bool ForTable { get; set; }

		public bool ForView { get; set; }

		public bool ForColumn { get; set; }

		public string Name { get; set; }

		private static string GetPropertyName(ExtendedPropertyOperation operation)
		{
			var tableOrViewPart = "";
			if (operation.ForTable || operation.ForView || operation.ForColumn)
			{
				tableOrViewPart = $".{operation.TableViewName}";
			}
			var columnPart = "";
			if (operation.ForColumn)
			{
				columnPart = $".{operation.ColumnName}";
			}
			return $"{operation.SchemaName}{tableOrViewPart}{columnPart}.@{operation.Name}";
		}

		public override OperationQueryType QueryType => OperationQueryType.Ddl;

		public string SchemaName { get; set; }

		protected abstract string StoredProcedureName { get; }

		public string TableViewName { get; set; }

		public string TableViewObjectName => (ForTable || ForView || ForColumn) ? $"{SchemaName}.{TableViewName}" : string.Empty;

		public string Value { get; set; }

		protected override MergeResult DoMerge(Operation operation)
		{
			if (base.DoMerge(operation) == MergeResult.Stop)
				return MergeResult.Stop;

			switch (operation)
			{
				case RemoveExtendedPropertyOperation otherAsRemovePropertyOp:
				{
					var thisPropertyName = GetPropertyName(this);
					var otherPropertyName = GetPropertyName(otherAsRemovePropertyOp);
					if( thisPropertyName.Equals(otherPropertyName, StringComparison.InvariantCultureIgnoreCase) )
					{
						Disabled = operation.Disabled = true;
						return MergeResult.Stop;
					}

					break;
				}

				case RemoveSchemaOperation otherAsRemoveSchemaOp when ForSchema &&
					SchemaName.Equals(otherAsRemoveSchemaOp.Name, StringComparison.InvariantCultureIgnoreCase):
					Disabled = true;
					break;

				case RemoveTableOperation otherAsRemoveTableOp when ForTable && 
																	TableViewObjectName.Equals(otherAsRemoveTableOp.ObjectName, StringComparison.InvariantCultureIgnoreCase):
					Disabled = true;
					break;

				case RemoveViewOperation otherAsRemoveViewOp when ForView && 
																  TableViewObjectName.Equals(otherAsRemoveViewOp.ObjectName, StringComparison.InvariantCultureIgnoreCase):
					Disabled = true;
					break;

				case RenameColumnOperation otherAsRenameColumnOp when TableViewObjectName.Equals(otherAsRenameColumnOp.TableObjectName, StringComparison.InvariantCultureIgnoreCase) && ForColumn && ColumnName.Equals(otherAsRenameColumnOp.Name, StringComparison.InvariantCultureIgnoreCase):
					ColumnName = otherAsRenameColumnOp.NewName;
					break;

				case RenameObjectOperation otherAsRenameOp when TableViewObjectName.Equals(otherAsRenameOp.ObjectName, StringComparison.InvariantCultureIgnoreCase):
					TableViewName = otherAsRenameOp.NewName;
					break;

				case UpdateExtendedPropertyOperation updateExtendedPropOp when !(this is RemoveExtendedPropertyOperation):
				{
					var thisPropertyName = GetPropertyName(this);
					var otherPropertyName = GetPropertyName(updateExtendedPropOp);
					if( thisPropertyName.Equals(otherPropertyName, StringComparison.InvariantCultureIgnoreCase) )
					{
						Value = updateExtendedPropOp.Value;
						updateExtendedPropOp.Disabled = true;
						return MergeResult.Continue;
					}

					break;
				}

				case UpdateTableOperation otherAsUpdateTableOp when ForTable &&
																	ForColumn &&
																	TableViewObjectName.Equals(otherAsUpdateTableOp.ObjectName, StringComparison.InvariantCultureIgnoreCase):
				{
					foreach (var deletedColumnName in otherAsUpdateTableOp.RemoveColumns)
					{
						if (ColumnName.Equals(deletedColumnName, StringComparison.InvariantCultureIgnoreCase))
						{
							Disabled = true;
							return MergeResult.Stop;
						}
					}

					break;
				}
			}

			return MergeResult.Continue;
		}

		public override string ToQuery()
		{
			var tableClause = string.Empty;
			if (ForTable)
				tableClause = $", @level1type=N'TABLE', @level1name='{TableViewName}'";

			var viewClause = string.Empty;
			if (ForView)
				viewClause = $", @level1type=N'VIEW', @level1name='{TableViewName}'";

			var columnClause = string.Empty;
			if( ForColumn )
				columnClause = $", @level2type=N'COLUMN', @level2name='{ColumnName}'";

			var valueClause = string.Empty;
			if( !(this is RemoveExtendedPropertyOperation) )
				valueClause = (Value == null) ? ", @value=null" : $", @value=N'{Value.Replace("'", "''")}'";

			return $"exec sys.{StoredProcedureName} @name=N'{Name}'{valueClause}, @level0type=N'SCHEMA', @level0name=N'{SchemaName}'{tableClause}{viewClause}{columnClause}";
		}

	}
}
