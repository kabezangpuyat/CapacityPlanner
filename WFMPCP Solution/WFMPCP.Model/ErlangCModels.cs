using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.Model
{
	public class ErlangCViewModel
	{
		public long NumberOfAgentsRequired { get; set; }
		public decimal ServiceLevel { get; set; }
		public decimal ServiceLevelPerc { get; set; }
		public decimal PwErlang { get; set; }
		public decimal PwErlangPerc { get; set; }
		public decimal ProbabilityOfCallToWaitPerc { get; set; }
		public decimal ASA { get; set; }
		public decimal ImmediateAnswerPerc { get; set; }
		public long TargetAnswerTimeInSecond { get; set; }
		public decimal RequiredServiceLevelPerc { get; set; }
		public decimal AHTSec { get; set; }
		public decimal OccupancyPerc { get; set; }
		public long N { get; set; }
		public decimal X { get; set; }
		public decimal Y { get; set; }
		public long A { get; set; }

	}

	public class ErlangCCalculatorResult
	{
		public ErlangCViewModel ErlangCViewModel { get; set; }
		public string Message { get; set; }
	}

	public class TableY
	{
		public decimal i { get; set; }
		public decimal iFactorial { get; set; }
		public decimal aPowerOfi { get; set; }
		public decimal aPowerOfiDivideIFactorial { get; set; }
		public decimal SumOfAPowerofIDivideIFactorial { get; set; }
	}
}
