namespace Rivet
{
    public class PrecisionScale : ColumnSize
    {
		private readonly bool _hasScale;

		public PrecisionScale(int precision) : base(precision)
		{
            Scale = NoSize;
			_hasScale = false;
		}

		public PrecisionScale(int precision, int scale) : base(precision)
		{
			Scale = scale;
			_hasScale = true;
		}

		public int Precision
        {
            get { return Value; }
        }

        public int Scale { get; private set; }

		public override string ToString()
		{
			var scaleClause = "";
			if (_hasScale)
			{
				scaleClause = $",{Scale}";
			}
			return $"({Precision}{scaleClause})";
		}
	}
}
