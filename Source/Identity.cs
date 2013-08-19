namespace Rivet
{
	public sealed class Identity
	{
		public const int DefaultSeed = 1;
		public const int DefaultIncrement = 1;

		private bool _defaultIdentity = true;

		public Identity() 
		{
			_defaultIdentity = true;
		}

		public Identity(int seed, int increment)
		{
			Seed = seed;
			Increment = increment;
			_defaultIdentity = false;
		}

		public Identity(bool notForReplication) 
		{
			NotForReplication = notForReplication;
			_defaultIdentity = true;
		}

		public Identity(int seed, int increment, bool notForReplication)
		{
			Seed = seed;
			Increment = increment;
			NotForReplication = notForReplication;
			_defaultIdentity = false;
		}

		public int Seed { get; private set; }
		public int Increment { get; private set; }
		public bool NotForReplication { get; private set; }

		public override string ToString()
		{
			var notForReplicationClause = "";
			if (NotForReplication)
			{
				notForReplicationClause = " not for replication";
			}

			var seedIncrementClause = "";
			if (!_defaultIdentity)
			{
				seedIncrementClause = string.Format(" ({0},{1})", Seed, Increment);
			}

			return string.Format("identity{0}{1}", seedIncrementClause, notForReplicationClause);
		}
	}
}
