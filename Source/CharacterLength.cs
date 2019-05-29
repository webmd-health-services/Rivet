namespace Rivet
{
    public sealed class CharacterLength : ColumnSize
    {
        public const int Max = -1;

        public CharacterLength(int length) : base(length)
        {
            IsMax = false;
        }

        public CharacterLength() : base(Max)
        {
            IsMax = true;
        }

        public bool IsMax { get; private set; }

        public override string ToString()
        {
            return IsMax ? "(max)" : base.ToString();
        }
    }
}