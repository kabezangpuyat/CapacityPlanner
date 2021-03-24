using System;
using System.Collections.Generic;
using System.Linq;
using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class ExcessDeficitService : IExcessDeficitService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public ExcessDeficitService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region Method(s)

		public List<OverAllExcessDeficitSummaryViewModel> GetCampaignSummary(DateTime start, DateTime end)
		{
			List<OverAllExcessDeficitSummaryViewModel> ret = new List<OverAllExcessDeficitSummaryViewModel>();
			_context.AsQueryable<WeeklyStaffDatapoint>()
				 .Where(x => (x.Date >= start && x.Date <= end) && x.DatapointID == 23
						   && x.Site.Active == true && x.Campaign.Active == true && x.LoB.Active == true)
				 .Select(x => new OverAllExcessDeficitSummaryViewModel()
				 {
					 Name = x.Campaign.Name,
					 Data = x.Data
				 }).ToList()
				 .ForEach(a =>
						ret.Add(new OverAllExcessDeficitSummaryViewModel()
						{
							ExcessDeficitTotal = Convert.ToDouble(a.Data),
							Name = a.Name
						})
					 );

			if (ret != null)
				if (ret.Count() > 0)
				{
					ret = ret.GroupBy(g => g.Name)
						.Select(x => new OverAllExcessDeficitSummaryViewModel { Name = x.Key, ExcessDeficitTotal = Math.Round(x.Average(i => i.ExcessDeficitTotal), 0) })
						.OrderBy(x => x.Name)
						.ToList();
				}
			return ret;
		}

		public List<OverAllExcessDeficitSummaryViewModel> GetSiteSummary(DateTime start, DateTime end)
		{
			List<OverAllExcessDeficitSummaryViewModel> ret = new List<OverAllExcessDeficitSummaryViewModel>();
			_context.AsQueryable<WeeklyStaffDatapoint>()
				 .Where(x => (x.Date >= start && x.Date <= end) && x.DatapointID == 23
					   && x.Site.Active == true && x.Campaign.Active == true && x.LoB.Active == true)
				 .Select(x => new OverAllExcessDeficitSummaryViewModel()
				 {
					 Name = x.Site.Name,
					 CampaignName = x.Campaign.Name,
					 Data = x.Data
				 }).ToList()
				 .ForEach(a =>
						ret.Add(new OverAllExcessDeficitSummaryViewModel()
						{
							ExcessDeficitTotal = Convert.ToDouble(a.Data),
							Name = a.Name,
							CampaignName = a.CampaignName
						})
					 );

			if (ret != null)
				if (ret.Count() > 0)
				{
					ret = ret.GroupBy(g => g.Name)
						.Select(x => new OverAllExcessDeficitSummaryViewModel { Name = x.Key, ExcessDeficitTotal = Math.Round(x.Average(i => i.ExcessDeficitTotal), 0) })
						.OrderBy(x => x.Name)
						.ToList();
					//var a = ret.GroupBy( g => new { g.Name, g.CampaignName } )
					//    .Select( x => new OverAllExcessDeficitSummaryViewModel { Name = x.Key.Name, CampaignName=x.Key.CampaignName, ExcessDeficitTotal = Math.Round( x.Average( i => i.ExcessDeficitTotal ), 0 ) } )
					//    .OrderBy( x => x.Name )
					//    .ToList();

					//ret = a.GroupBy(g=> g.Name)
					//    .Select( x => new OverAllExcessDeficitSummaryViewModel { Name = x.Key, ExcessDeficitTotal = Math.Round( x.Average( i => i.ExcessDeficitTotal ), 0 ) } )
					//    .OrderBy( x => x.Name )
					//    .ToList();
				}
			return ret;
		}

		public List<Dictionary<string, object>> GetSiteMonthlySummary(string start, string end)
		{
			string procName = "wfmpcp_GetSiteMonthlyExcessDeficit_sp";
			string[] parameters = { "Start", "End" };
			object[] inputParams = { start, end };
			return _context.Read(procName, parameters, inputParams);
		}

		public List<Dictionary<string, object>> GetCampaignMonthlySummary(string start, string end)
		{
			string procName = "wfmpcp_GetCampaignMonthlyExcessDeficit_sp";
			string[] parameters = { "Start", "End" };
			object[] inputParams = { start, end };
			return _context.Read(procName, parameters, inputParams);
		}

		public List<Dictionary<string, object>> GetSiteWeeklySummary(string start, string end)
		{
			string procName = "wfmpcp_GetSiteWeeklyExcessDeficit_sp";
			string[] parameters = { "Start", "End" };
			object[] inputParams = { start, end };
			return _context.Read(procName, parameters, inputParams);
		}

		public List<Dictionary<string, object>> GetExcessDeficitVsActualHeadcount(string start, string end, string siteID)
		{
			string procName = "wfmpcp_GetExcessDeficitVsActualHC_sp";
			string[] parameters = { "Start", "End", "SiteID" };
			object[] inputParams = { start, end, siteID };
			return _context.Read(procName, parameters, inputParams);
		}

		public List<Dictionary<string, object>> GetCampaignWeeklySummary(string start, string end, string siteID)
		{
			string procName = "wfmpcp_GetCampaignWeeklyExcessDeficit_sp";
			string[] parameters = { "Start", "End", "SiteID" };
			object[] inputParams = { start, end, siteID };
			return _context.Read(procName, parameters, inputParams);
		}

		public List<Dictionary<string, object>> GetLoBWeeklySummary(string start, string end, string campaignID)
		{
			string procName = "wfmpcp_GetLoBWeeklyExcessDeficit_sp";
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