namespace Rivet
{
	public sealed class OperationResult
	{
		public OperationResult(Migration migration, Operation operation, string query, int rowsAffected)
		{
			Migration = migration;
			Operation = operation;
			Query = query;
			RowsAffected = rowsAffected;
		}

		public Migration Migration { get; private set; }

		public Operation Operation { get; private set; }

		public string Query { get; private set; }

		public int RowsAffected { get; private set; }

	}
}
