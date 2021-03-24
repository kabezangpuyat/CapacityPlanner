using System;
using System.Collections.Generic;
using System.Linq;
using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class HiringOutlookService : IHiringOutlookService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public HiringOutlookService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region Method(s)

		public List<OverAllHiringOutlookSummaryViewModel> GetCampaignSummary(DateTime start, DateTime end)
		{
			List<OverAllHiringOutlookSummaryViewModel> ret = new List<OverAllHiringOutlookSummaryViewModel>();
			_context.AsQueryable<WeeklyHiringDatapoint>()
				 .Where(x => (x.Date >= start && x.Date <= end)
						&& x.Site.Active == true && x.Campaign.Active == true && x.LoB.Active == true)
				 .Select(x => new OverAllHiringOutlookSummaryViewModel()
				 {
					 Name = x.Campaign.Name,
					 Data = x.Data
				 }).ToList()
				 .ForEach(a =>
						ret.Add(new OverAllHiringOutlookSummaryViewModel()
						{
							HiringTotal = Convert.ToInt32(a.Data),
							Name = a.Name
						})
					 );

			if (ret != null)
				if (ret.Count() > 0)
				{
					ret = ret.GroupBy(g => g.Name)
						.Select(x => new OverAllHiringOutlookSummaryViewModel { Name = x.Key, HiringTotal = x.Sum(i => i.HiringTotal) })
						.OrderBy(x => x.Name)
						.ToList();
				}
			return ret;
		}

		public List<OverAllHiringOutlookSummaryViewModel> GetSiteSummary(DateTime start, DateTime end)
		{
			List<OverAllHiringOutlookSummaryViewModel> ret = new List<OverAllHiringOutlookSummaryViewModel>();
			_context.AsQueryable<WeeklyHiringDatapoint>()
				 .Where(x => (x.Date >= start && x.Date <= end)
					   && x.Site.Active == true && x.Campaign.Active == true && x.LoB.Active == true)
				 .Select(x => new OverAllHiringOutlookSummaryViewModel()
				 {
					 Name = x.Site.Name,
					 Data = x.Data
				 }).ToList()
				 .ForEach(a =>
						ret.Add(new OverAllHiringOutlookSummaryViewModel()
						{
							HiringTotal = Convert.ToInt32(a.Data),
							Name = a.Name
						})
					 );

			if (ret != null)
				if (ret.Count() > 0)
				{
					ret = ret.GroupBy(g => g.Name)
						.Select(x => new OverAllHiringOutlookSummaryViewModel { Name = x.Key, HiringTotal = x.Sum(i => i.HiringTotal) })
						.OrderBy(x => x.Name)
						.ToList();
				}
			return ret;
		}

		public List<Dictionary<string, object>> GetSiteMonthlySummary(string start, string end)
		{
			string procName = "wfmpcp_GetSiteMonthlyHiringPlan_sp";
			string[] parameters = { "Start", "End" };
			object[] inputParams = { start, end };
			return _context.Read(procName, parameters, inputParams);
		}

		public List<Dictionary<string, object>> GetCampaignMonthlySummary(string start, string end)
		{
			string procName = "wfmpcp_GetCampaignMonthlyHiringPlan_sp";
			string[] parameters = { "Start", "End" };
			object[] inputParams = { start, end };
			return _context.Read(procName, parameters, inputParams);
		}

		public List<Dictionary<string, object>> GetSiteWeeklySummary(string start, string end)
		{
			string procName = "wfmpcp_GetSiteWeeklyHiringPlan_sp";
			string[] parameters = { "Start", "End" };
			object[] inputParams = { start, end };
			return _context.Read(procName, parameters, inputParams);
		}

		public List<Dictionary<string, object>> GetCampaignWeeklySummary(string start, string end, string siteID)
		{
			string procName = "wfmpcp_GetCampaignWeeklyHiringPlan_sp";
			string[] parameters = { "Start", "End", "SiteID" };
			object[] inputParams = { start, end, siteID };
			return _context.Read(procName, parameters, inputParams);
		}

		public List<Dictionary<string, object>> GetLoBWeeklySummary(string start, string end, string campaignID)
		{
			string procName = "wfmpcp_GetLoBWeeklyHiringPlan_sp";
			string[] parameters = { "Start", "End", "CampaignID" };
			object[] inputParams = { start, end, campaignID };
			return _context.Read(procName, parameters, inputParams);
		}

		public void MaxMinYear(ref int min, ref int max)
		{
			try
			{
				min = _context.AsQueryable<WeeklyStaffDatapoint>().Min(x => x.Date).Year;
				max = _context.AsQueryable<WeeklyStaffDatapoint>().Max(x => x.Date).Year;
			}
			catch
			{
				min = DateTime.Now.Year;
				max = min;
			}
		}

		#endregion Method(s)
	}
}