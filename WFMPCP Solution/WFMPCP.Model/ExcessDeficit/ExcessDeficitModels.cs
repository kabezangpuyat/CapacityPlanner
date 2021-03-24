using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WFMPCP.Model
{
    public class OverAllExcessDeficitSummaryViewModel
    {
        public string Name { get; set; }
        public string CampaignName { get; set; }
        public double ExcessDeficitTotal { get; set; }
        public string Data { get; set; }
    }

    public class CampaignOverallExcessDeficitSummaryViewModel
    {

    }
    #region Summary(OverAll) View Model
    public class SummaryOverAllExcessDeficitViews
    {
        //public List<OverAllExcessDeficitSummaryViewModel> FirstMonthSite { get; set; }
        public List<Dictionary<string, object>> FirstMonthSite { get; set; }
        //public List<OverAllExcessDeficitSummaryViewModel> SecondMonthSite { get; set; }
        public List<Dictionary<string, object>> SecondMonthSite { get; set; }
        public List<Dictionary<string, object>> ThirdMonthSite { get; set; }
        //public List<OverAllExcessDeficitSummaryViewModel> ThirdMonthSite { get; set; }

        //public List<OverAllExcessDeficitSummaryViewModel> FirstMonthCampaign { get; set; }
        //public List<OverAllExcessDeficitSummaryViewModel> SecondMonthCampaign { get; set; }
        //public List<OverAllExcessDeficitSummaryViewModel> ThirdMonthCampaign { get; set; }
        public List<Dictionary<string, object>> FirstMonthCampaign { get; set; }
        public List<Dictionary<string, object>> SecondMonthCampaign { get; set; }
        public List<Dictionary<string, object>> ThirdMonthCampaign { get; set; }

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

        public double ThreeMonthsSiteTotal { get; set; }

        public double MonthCampaignTotal1 { get; set; }
        public double MonthCampaignTotal2 { get; set; }
        public double MonthCampaignTotal3 { get; set; }

        public int MinYear { get; set; }
        public int MaxYear { get; set; }
    }
    #endregion
}
