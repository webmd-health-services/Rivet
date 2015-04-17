using NUnit.Framework;
using Rivet.Operations;

namespace Rivet.Test.Operations
{
	[TestFixture]
	public sealed class ScriptFileOperationTestFixture
	{
		[Test]
		public void ShouldSetProperties()
		{
			var op = new ScriptFileOperation("path", "query");
			Assert.That(op.Path, Is.EqualTo("path"));
			Assert.That(op.Query, Is.EqualTo("query"));
		}
	}
}
