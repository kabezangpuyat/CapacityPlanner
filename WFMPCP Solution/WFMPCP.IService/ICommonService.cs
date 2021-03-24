using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.IService
{
    public interface ICommonService
    {
        /// <summary>
        /// Get First date of year display as string
        /// </summary>
        /// <returns>dd  MONTH yyyy</returns>
        string GetFirstDateOfYear();

        DateTime GetLastMondayOfMonth( DateTime now );

        DateTime GetFirstMondayOfMonth( DateTime now );

        string GetBetween( string source, string start, string end );

		DateTime StartOfWeek(DateTime dt, DayOfWeek startOfWeek);

	}
}
