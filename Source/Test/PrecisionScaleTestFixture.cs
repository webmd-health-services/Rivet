using NUnit.Framework;

namespace Rivet.Test
{
    [TestFixture]
    public sealed class PrecisionScaleTestFixture
    {
        [Test]
        public void ShouldCreateExpressionWhenOnlyPrecisionGiven()
        {
            var size = new PrecisionScale(3);
            Assert.That(size.ToString(), Is.EqualTo("(3)"));
        }

        [Test]
        public void ShouldCreateExpressionWhenPrecisionAndScaleGiven()
        {
            var size = new PrecisionScale(4, 2);
            Assert.That(size.ToString(), Is.EqualTo("(4,2)"));
        }
    }
}
