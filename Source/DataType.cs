using System;

namespace Rivet
{
    public struct DataType
    {
        public DataType(string name)
        {
            if (string.IsNullOrEmpty(name))
                throw new ArgumentException("DataType name is mandatory and can't be null or empty.", "name");

            Name = name;
        }

        public string Name { get; }

        public override int GetHashCode()
        {
            return Name.GetHashCode();
        }

        public override bool Equals(object obj)
        {
            return obj != null &&
                   obj is DataType dataType &&
                   Equals(dataType);
        }

        public bool Equals(DataType dataType)
        {
            return string.Equals(Name, dataType.Name, StringComparison.InvariantCultureIgnoreCase);
        }

        public static bool operator ==(DataType left, DataType right)
        {
            return left.Equals(right);
        }

        public static bool operator !=(DataType left, DataType right)
        {
            return !(left == right);
        }

        public override string ToString()
        {
            return Name;
        }

        // Exact Numerics
        public static DataType BigInt = new DataType("bigint");
        public static DataType Bit = new DataType("bit");
        public static DataType Decimal = new DataType("decimal");
        public static DataType Int = new DataType("int");
        public static DataType SmallMoney = new DataType("smallmoney");
        public static DataType Money = new DataType("money");
        public static DataType SmallInt = new DataType("smallint");
        public static DataType TinyInt = new DataType("tinyint");


        //// Approximate Numerics
        public static DataType Float = new DataType("float");
        public static DataType Real = new DataType("real");

        //// Date and Time
        public static DataType Date = new DataType("date");
        public static DataType DateTime2 = new DataType("datetime2");
        public static DataType DateTimeOffset = new DataType("datetimeoffset");
        public static DataType SmallDateTime = new DataType("smalldatetime");
        public static DataType Time = new DataType("time");

        //// Character Strings
        public static DataType Char = new DataType("char");
        public static DataType VarChar = new DataType("varchar");

        //// Unicode Character Strings
        public static DataType NChar = new DataType("nchar");
        public static DataType NVarChar = new DataType("nvarchar");

        //// Binary Strings
        public static DataType Binary = new DataType("binary");
        public static DataType VarBinary = new DataType("varbinary");

        //// Other Data Types
        public static DataType HierarchyID = new DataType("hierarchyid");
        public static DataType SqlVariant = new DataType("sql_variant");
        public static DataType RowVersion = new DataType("rowversion");
        public static DataType UniqueIdentifier = new DataType("uniqueidentifier");
        public static DataType Xml = new DataType("xml");

        //// Custom
        //Custom
    }
}