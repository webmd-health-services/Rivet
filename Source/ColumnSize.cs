namespace Rivet
{
    public abstract class ColumnSize
    {
        public const int NoSize = -1;

        protected ColumnSize(int size)
        {
            Value = size;
        }

        public int Value { get; private set; }

        public override string ToString()
        {
            return $"({Value})";
        }
    }
}