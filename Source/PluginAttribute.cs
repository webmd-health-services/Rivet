using System;

namespace Rivet
{
    public sealed class PluginAttribute : Attribute
    {
        public PluginAttribute(Events respondsTo)
        {
            this.RespondsTo = respondsTo;
        }

        public Events RespondsTo { get; set; }
    }
}
