using System;
using System.Collections.Generic;
using System.Linq;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class ErlangCSercvice : IErlangCSercvice
	{
		#region Constructor(s)

		public ErlangCSercvice()
		{
		}

		#endregion Constructor(s)

		#region IErlangCSercvice Implementation

		public ErlangCViewModel Calculate(long numberOfCalls, long ahtInSeconds, decimal requiredServiceLevel,
			long targetAnswerTimeInSeconds, decimal shrinkage, long? newN = null)
		{
			ErlangCViewModel model = new ErlangCViewModel();

			#region Declare Variable(s)

			long a = 0;
			long n = 0;
			long numberOfCallsPerHour = 0;
			decimal x = 0;
			decimal y = 0;
			decimal pw = 0;
			decimal pwPerc = 0;
			decimal sl = 0;
			decimal slPerc = 0;
			decimal asa = 0;
			decimal immediateAnswerPerc = 0;
			decimal occupancyPerc = 0;
			long numberOfAgentsRequired = 0;

			#endregion Declare Variable(s)

			#region 2. Work Out the Number of Calls Per Hour

			numberOfCallsPerHour = numberOfCalls;

			#endregion 2. Work Out the Number of Calls Per Hour

			#region 3. Work Out the Traffic Intensity (A)

			long ahtInMinutes = ahtInSeconds/60;
			a = (numberOfCalls*ahtInMinutes)/60;

			#endregion 3. Work Out the Traffic Intensity (A)

			#region 4. Estimate the Raw Number of Agents Required (N)

			//Initial value is A+1
			if (newN==null)
				n=(a+1);
			else
				n=(long)newN;

			//n = newN ?? (a+1);

			#endregion 4. Estimate the Raw Number of Agents Required (N)

			//	--5.Calculate the Erlang Formula for Probability a Call Waits(SKIP)
			//   --6.Work Out N!(N Factorial) (SKIP)
			// --7.Be Careful With Large Factorials (SKIP)
			//--                           n
			//--8.Work Out the Powers – A(SKIP)
			//--9.Let’s Simplify the Erlang C Formula
			//--       X  / (Y + X)

			#region 10. Let’s Work Out the Top Row of the Erlang Formula (X)

			//			--NUMERATOR FIRST(X)
			//--   n
			//-- A* N
			//	--___       ___
			//	-- N!N-A
			decimal numeratorA, numeratorB;

			numeratorA = (decimal)Math.Pow(a, n)/this.Factorial(n);
			numeratorB = (decimal)n/((decimal)n-(decimal)a);
			x = numeratorA*numeratorB;

			#endregion 10. Let’s Work Out the Top Row of the Erlang Formula (X)

			#region 11. Work Out the Sum of a Series (Y) or ΣApowerofI/i!

			//loop n
			decimal i = 0;
			decimal eaPowOfiDivIFact = 0;
			List<TableY> tblY = new List<TableY>();

			while (i<=(n-1))
			{
				decimal iFact, aPowI, aPowOfiDivIFact;

				iFact = i == 0 ? 1 : this.Factorial(i);
				aPowI = (decimal)Math.Pow(a, (double)i);
				aPowOfiDivIFact =   aPowI/iFact;
				eaPowOfiDivIFact = eaPowOfiDivIFact + aPowOfiDivIFact;

				tblY.Add(new TableY()
				{
					i = i,
					iFactorial = iFact,
					aPowerOfi = aPowI,
					aPowerOfiDivideIFactorial = aPowOfiDivIFact,
					SumOfAPowerofIDivideIFactorial = eaPowOfiDivIFact
				});

				i++;
			}

			y = tblY.OrderByDescending(s => s.SumOfAPowerofIDivideIFactorial).FirstOrDefault().SumOfAPowerofIDivideIFactorial;

			#endregion 11. Work Out the Sum of a Series (Y) or ΣApowerofI/i!

			#region 12. Put X and Y into the Erlang C Formula (The probability a call has to wait)

			pw = x/(x+y);
			pwPerc = pw * 100;

			#endregion 12. Put X and Y into the Erlang C Formula (The probability a call has to wait)

			#region 13. Calculate the Service Level

			#region 13.1 Let’s work out -(N – A) * (TargetTime / AHT)

			double exponent = 0;
			exponent =  -((n-a)*((double)targetAnswerTimeInSeconds/(double)ahtInSeconds));

			#endregion 13.1 Let’s work out -(N – A) * (TargetTime / AHT)

			sl =  1-(pw*(decimal)Math.Exp(exponent));
			slPerc = sl*100;

			if (slPerc<requiredServiceLevel)
			{
				long nIncrement = n + 1;
				model = this.Calculate(numberOfCalls, ahtInSeconds, requiredServiceLevel, targetAnswerTimeInSeconds, shrinkage, nIncrement);
			}
			else
			{
				#region 15.  Average Speed of Answer (ASA)

				//ASA = Pw(AHT)/(No.of Agents-Traffic Intesity)
				asa = (pw*ahtInSeconds)/(n-a);

				#endregion 15.  Average Speed of Answer (ASA)

				#region 16. Percentage of Calls Answered Immediately

				//Immediate Answer = (1-Pw)x100
				immediateAnswerPerc=(1-pw)*100;

				#endregion 16. Percentage of Calls Answered Immediately

				#region 17. Check Maximum Occupancy

				//Occupancy = (([TrafficIntensity or A])/[RawAgents or N] )* 100
				occupancyPerc = ((decimal)a/(decimal)n)*100;
				if (occupancyPerc > 85)
					occupancyPerc = (decimal)a/(occupancyPerc/100);

				#endregion 17. Check Maximum Occupancy

				#region 18. Factor In Shrinkage

				//DECLARE @ShrinkagePerc NUMERIC(18,3) = 30 --The industry average is around 30–35%, in this case we used 30%. Note that we can change it
				//NumberOfAgentsRequired = [Raw Agents or N]/(1-(Shrinkage/100))
				numberOfAgentsRequired = (long)Math.Ceiling((decimal)n/(1-(shrinkage/100)));

				#endregion 18. Factor In Shrinkage

				model.NumberOfAgentsRequired = numberOfAgentsRequired;
				model.ServiceLevel = sl;
				model.ServiceLevelPerc = Math.Round(slPerc, 2);
				model.PwErlang = pw;
				model.PwErlangPerc = Math.Round(pwPerc, 2);
				model.ASA = Math.Round(asa, 2);
				model.ImmediateAnswerPerc  = Math.Round(immediateAnswerPerc, 2);
				model.TargetAnswerTimeInSecond = targetAnswerTimeInSeconds;
				model.AHTSec = ahtInSeconds;
				model.RequiredServiceLevelPerc = Math.Round(requiredServiceLevel, 2);
				model.N = n;
				model.X = x;
				model.Y = y;
				model.A = a;
				model.OccupancyPerc =Math.Round(occupancyPerc, 2);
			}

			#endregion 13. Calculate the Service Level

			return model;
		}

		public decimal Factorial(decimal target)
		{
			decimal retValue;

			if (target <=1)
				retValue = target;
			else
				retValue = target * this.Factorial(target -1);

			return retValue;
		}

		#endregion IErlangCSercvice Implementation
	}
}