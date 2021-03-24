using System;
using WFMPCP.IService;

namespace WFMPCP.Service
{
    public class CommonService : ICommonService
    {
        public string GetFirstDateOfYear()
        {
            int year = DateTime.Now.Year;
            DateTime firstDay = new DateTime( year, 1, 1 );
            return firstDay.ToString( "dd MMM yyyy" );
        }

        public DateTime GetFirstMondayOfMonth( DateTime now )
        {
            var firstDayOfMonth = new DateTime( now.Year, now.Month, 1 );
            var monday = firstDayOfMonth;

            var ctr = 1;
            if( firstDayOfMonth.DayOfWeek == DayOfWeek.Tuesday || firstDayOfMonth.DayOfWeek == DayOfWeek.Wednesday
                || firstDayOfMonth.DayOfWeek == DayOfWeek.Thursday )
                ctr = -1;

            while( monday.DayOfWeek != DayOfWeek.Monday )
                monday = monday.AddDays( ctr );

            return monday;
        }

        public DateTime GetLastMondayOfMonth( DateTime now )
        {
            var lastDayOfMonth = new DateTime( now.Year, now.Month, DateTime.DaysInMonth( now.Year, now.Month ) );
            var monday = lastDayOfMonth;

            while( monday.DayOfWeek != DayOfWeek.Monday )
            {
                monday = monday.AddDays( -1 );
            }

            //once you get the last monday of month get the difference between lastmonday and lastday
            var dateDiff = ( lastDayOfMonth - monday ).TotalDays + 1;

            if( dateDiff < 4 )
            {
                monday = monday.AddDays( -1 );
                while( monday.DayOfWeek != DayOfWeek.Monday )
                {
                    monday = monday.AddDays( -1 );
                }
            }
            return monday;
        }

        public string GetBetween( string source, string start, string end )
        {
            int Start, End;
            if( source.Contains( start ) && source.Contains( end ) )
            {
                Start = source.IndexOf( start, 0 ) + start.Length;
                End = source.IndexOf( end, Start );
                return source.Substring( Start, End - Start ).Trim();
            }
            else
            {
                return "";
            }
        }

		public DateTime StartOfWeek(DateTime dt, DayOfWeek startOfWeek)
		{
			int diff = (7 + (dt.DayOfWeek - startOfWeek)) % 7;
			//DateTime d = dt.AddDays(-1 * diff).Date;
			return dt.AddDays(-1 * diff).Date;
		}
	}
}
