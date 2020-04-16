using NUnit.Framework;

namespace Rivet.Test
{
    [TestFixture]
    public sealed class ScaleTestFixture
    {
        [Test]
        public void ShouldCreateSizeExpression()
        {
            var scale = new Scale(4);
            Assert.That(scale.ToString(), Is.EqualTo("(4)"));
        }
    }
}
