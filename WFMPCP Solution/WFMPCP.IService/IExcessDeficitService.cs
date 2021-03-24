using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IExcessDeficitService
    {
        List<OverAllExcessDeficitSummaryViewModel> GetCampaignSummary( DateTime start, DateTime end );
        List<OverAllExcessDeficitSummaryViewModel> GetSiteSummary( DateTime start, DateTime end );

        List<Dictionary<string, object>> GetSiteMonthlySummary( string start, string end );

        List<Dictionary<string, object>> GetCampaignMonthlySummary( string start, string end );

        List<Dictionary<string, object>> GetSiteWeeklySummary( string start, string end );

        List<Dictionary<string, object>> GetExcessDeficitVsActualHeadcount( string start, string end, string siteID );

        List<Dictionary<string, object>> GetCampaignWeeklySummary( string start, string end, string siteID );

        List<Dictionary<string, object>> GetLoBWeeklySummary( string start, string end, string campaignID );

        void MaxMinYear( ref int min, ref int max );
    }
}
