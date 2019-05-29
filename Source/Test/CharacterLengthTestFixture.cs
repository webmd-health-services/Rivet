using System;
using System.Collections.Generic;
using System.Text;
using NUnit.Framework;

namespace Rivet.Test
{
    [TestFixture]
    public sealed class CharacterLengthTestFixture
    {
        [Test]
        public void ShouldCreateExpressionForMaxColumns()
        {
            var size = new CharacterLength();
            Assert.That(size.ToString(), Is.EqualTo("(max)"));
        }

        [Test]
        public void ShouldCreateExpression()
        {
            var size = new CharacterLength(393);
            Assert.That(size.ToString(), Is.EqualTo("(393)"));
        }
    }
}
