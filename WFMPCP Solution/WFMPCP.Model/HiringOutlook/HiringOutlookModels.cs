using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.Model
{
    public class OverAllHiringOutlookSummaryViewModel
    {
        public string Name { get; set; }
        public int HiringTotal { get; set; }
        public string Data { get; set; }
    }

    public class CampaignOverallHiringOutlookSummaryViewModel
    {

    }
    #region Summary(OverAll) View Model
    public class SummaryOverAllHiringOutlookViews
    {
        public List<OverAllHiringOutlookSummaryViewModel> FirstMonthSite { get; set; }
        public List<OverAllHiringOutlookSummaryViewModel> SecondMonthSite { get; set; }
        public List<OverAllHiringOutlookSummaryViewModel> ThirdMonthSite { get; set; }

        public List<OverAllHiringOutlookSummaryViewModel> FirstMonthCampaign { get; set; }
        public List<OverAllHiringOutlookSummaryViewModel> SecondMonthCampaign { get; set; }
        public List<OverAllHiringOutlookSummaryViewModel> ThirdMonthCampaign { get; set; }

        public List<Dictionary<string, object>> SitePivot { get; set; }

        public List<Dictionary<string, object>> CampaignPivot { get; set; }

        public List<Dictionary<string, object>> LobPivot { get; set; }

        public List<SiteViewModel> Sites { get; set; }

        public string SiteID { get; set; }

        public string Month1Start { get; set; }
        public string Month1End { get; set; }

        public string Month2Start { get; set; }
        public string Month2End { get; set; }

        public string Month3Start { get; set; }
        public string Month3End { get; set; }

        public string Month1 { get; set; }
        public string Month2 { get; set; }
        public string Month3 { get; set; }
        public string MonthYear1 { get; set; }
        public string MonthYear2 { get; set; }
        public string MonthYear3 { get; set; }

        public string MonthID { get; set; }
        public string Year { get; set; }

        public string SiteSummaryHTML { get; set; }
        public string CampaignSummaryHTML { get; set; }

		public int ThreeMonthsSiteTotal { get; set; }

        public int MonthCampaignTotal1 { get; set; }
        public int MonthCampaignTotal2 { get; set; }
        public int MonthCampaignTotal3 { get; set; }
        public int MinYear { get; set; }
        public int MaxYear { get; set; }
    }
    #endregion
}
