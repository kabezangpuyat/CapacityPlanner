using WFMPCP.Model;

namespace WFMPCP.IService
{
	public interface IErlangCSercvice
	{
		ErlangCViewModel Calculate(long numberOfCalls, long ahtInSeconds, decimal requiredServiceLevel, long targetAnswerTimeInSeconds, decimal shrinkage, long? newN = null);
		decimal Factorial(decimal target);
	}
}