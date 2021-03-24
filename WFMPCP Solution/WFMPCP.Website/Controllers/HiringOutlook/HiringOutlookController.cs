using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using System;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WFMPCP.IService;
using WFMPCP.Model;


namespace WFMPCP.Website.Controllers.HiringOutlook
{
    [Authorize]
    public class HiringOutlookController : Controller
    {
        #region Private variable(s)
        private ApplicationUserManager _userManager;
        public ApplicationUserManager UserManager
        {
            get
            {
                return _userManager ?? HttpContext.GetOwinContext().GetUserManager<ApplicationUserManager>();
            }
            private set
            {
                _userManager = value;
            }
        }

        private IHiringOutlookService _hiringOutlookService;
        private ISiteService _siteService;
        private ICommonService _commonService;
        #endregion

        #region Constructor
        public HiringOutlookController(IHiringOutlookService hiringOutlookService, ISiteService siteService,
            ICommonService commonService )
        {
            this._hiringOutlookService = hiringOutlookService;
            this._siteService = siteService;
            this._commonService = commonService;
        }
        #endregion

        #region ActionResult(s)
        // GET: HiringOutlook
        #region Summary Overall
        public ActionResult SummaryOverall()
        {
            ViewBag.User = User.Identity.GetUserName();

			SummaryOverAllHiringOutlookViews model = new SummaryOverAllHiringOutlookViews();
			int min = 0, max = 0;
			_hiringOutlookService.MaxMinYear(ref min, ref max);
			model.MinYear = min;
			model.MaxYear = max;

			return View(model);
        }
        [HttpPost]
        public ActionResult GenerateOverallSummary( string startMonth )
        {
            return Json( this.SummaryViewModel( startMonth ), JsonRequestBehavior.AllowGet );
        } 
        #endregion

        #region Site Monthly Summary
        public ActionResult SiteMonthlySummary()
        {
            ViewBag.User = User.Identity.GetUserName();

			#region Start and End date
			//DateTime startDate = _commonService.StartOfWeek(DateTime.Now, DayOfWeek.Monday);
			//DateTime endDate = _commonService.GetLastMondayOfMonth(startDate.AddMonths(2));
			#endregion

			SummaryOverAllHiringOutlookViews model = new SummaryOverAllHiringOutlookViews();
            SummaryOverAllHiringOutlookViews partialViewModel = new SummaryOverAllHiringOutlookViews();
            partialViewModel.SitePivot=_hiringOutlookService.GetSiteMonthlySummary(string.Empty,string.Empty);
           //partialViewModel.SitePivot = _hiringOutlookService.GetSiteMonthlySummary( startDate.ToString("yyyy-MM-dd"), endDate.ToString("yyyy-MM-dd") );
           string siteSummaryHTML = RenderPartialViewToString( "_SiteMonthlySummary", partialViewModel );

            model.SiteSummaryHTML = siteSummaryHTML;           

            return View( model );
        }
        [HttpPost]
        public ActionResult GenerateSiteMonthlySummary( string start, string end )
        {
            SummaryOverAllHiringOutlookViews model = new SummaryOverAllHiringOutlookViews();
            SummaryOverAllHiringOutlookViews partialViewModel = new SummaryOverAllHiringOutlookViews();
            partialViewModel.SitePivot = _hiringOutlookService.GetSiteMonthlySummary( start, end );
            string siteSummaryHTML = RenderPartialViewToString( "_SiteMonthlySummary", partialViewModel );

            model.SiteSummaryHTML = siteSummaryHTML;

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        #endregion

        #region Site Weekly Summary
        public ActionResult SiteWeeklySummary()
        {
            ViewBag.User = User.Identity.GetUserName();

			#region Start and End date
			DateTime startDate = _commonService.StartOfWeek(DateTime.Now, DayOfWeek.Monday);
			DateTime endDate = _commonService.GetLastMondayOfMonth(startDate.AddMonths(2));
			#endregion

			SummaryOverAllHiringOutlookViews model = new SummaryOverAllHiringOutlookViews();
            SummaryOverAllHiringOutlookViews partialViewModel = new SummaryOverAllHiringOutlookViews();
            partialViewModel.SitePivot = _hiringOutlookService.GetSiteWeeklySummary( startDate.ToString("yyyy-MM-dd"), endDate.ToString("yyyy-MM-dd") );
            string siteSummaryHTML = RenderPartialViewToString( "_SiteWeeklySummary", partialViewModel );

			model = partialViewModel;
			model.SiteSummaryHTML = siteSummaryHTML;

            return View( model );
        }
        [HttpPost]
        public ActionResult GenerateSiteWeeklySummary( string start, string end )
        {

			#region Start and End date
			DateTime startDate = new DateTime();
			DateTime endDate = new DateTime();

			if (string.IsNullOrEmpty(start))
			{
				startDate = _commonService.StartOfWeek(DateTime.Now, DayOfWeek.Monday);
				endDate = _commonService.GetLastMondayOfMonth(startDate.AddMonths(2));

				start = startDate.ToString("yyyy-MM-dd");
				end = endDate.ToString("yyyy-MM-dd");
			}
			startDate = _commonService.StartOfWeek(DateTime.Now, DayOfWeek.Monday);
			endDate = _commonService.GetLastMondayOfMonth(startDate.AddMonths(2));
			#endregion

			SummaryOverAllHiringOutlookViews model = new SummaryOverAllHiringOutlookViews();
            SummaryOverAllHiringOutlookViews partialViewModel = new SummaryOverAllHiringOutlookViews();
            partialViewModel.SitePivot = _hiringOutlookService.GetSiteWeeklySummary( start, end );
            string siteSummaryHTML = RenderPartialViewToString( "_SiteWeeklySummary", partialViewModel );

			model = partialViewModel;
			model.SiteSummaryHTML = siteSummaryHTML;

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        #endregion

        #region Campaign Monthly SUmmary
        public ActionResult CampaignMonthlySummary()
        {
            ViewBag.User = User.Identity.GetUserName();

			#region Start and End date
			//DateTime startDate = _commonService.StartOfWeek(DateTime.Now, DayOfWeek.Monday);
			//DateTime endDate = _commonService.GetLastMondayOfMonth(startDate.AddMonths(2));
			#endregion

			SummaryOverAllHiringOutlookViews model = new SummaryOverAllHiringOutlookViews();
            SummaryOverAllHiringOutlookViews partialViewModel = new SummaryOverAllHiringOutlookViews();
            partialViewModel.SitePivot=_hiringOutlookService.GetCampaignMonthlySummary(string.Empty,string.Empty);
           //partialViewModel.SitePivot = _hiringOutlookService.GetCampaignMonthlySummary( startDate.ToString("yyyy-MM-dd"), endDate.ToString("yyyy-MM-dd") );
           string campaignHTML = RenderPartialViewToString( "_CampaignMonthlySummary", partialViewModel );

            model.SiteSummaryHTML = campaignHTML;

            return View( model );
        }
        [HttpPost]
        public ActionResult GenerateCampaignMonthlySummary( string start, string end )
        {
            SummaryOverAllHiringOutlookViews model = new SummaryOverAllHiringOutlookViews();
            SummaryOverAllHiringOutlookViews partialViewModel = new SummaryOverAllHiringOutlookViews();
            partialViewModel.SitePivot = _hiringOutlookService.GetCampaignMonthlySummary( start, end );
            string campaignHTML = RenderPartialViewToString( "_CampaignMonthlySummary", partialViewModel );

            model.SiteSummaryHTML = campaignHTML;

            return Json( model, JsonRequestBehavior.AllowGet );
        }
        #endregion

        #region Campaign Weekly SUmmary
        public ActionResult CampaignWeeklySummary()
        {
            ViewBag.User = User.Identity.GetUserName();
			#region Start and End date
			DateTime startDate = _commonService.StartOfWeek(DateTime.Now, DayOfWeek.Monday);
			DateTime endDate = _commonService.GetLastMondayOfMonth(startDate.AddMonths(2));
			#endregion
			SummaryOverAllHiringOutlookViews model = new SummaryOverAllHiringOutlookViews();
            SummaryOverAllHiringOutlookViews partialViewModel = new SummaryOverAllHiringOutlookViews();
            partialViewModel.SitePivot = _hiringOutlookService.GetCampaignWeeklySummary( startDate.ToString("yyyy-MM-dd"), endDate.ToString("yyyy-MM-dd"), string.Empty );
            partialViewModel.SiteID = string.Empty;
            string campaignHTML = RenderPartialViewToString( "_CampaignWeeklySummary", partialViewModel );

            model.Sites = _siteService.GetAll().Where( x => x.Active == true ).ToList();
            model.SiteSummaryHTML = campaignHTML;

            return View( model );
        }
        [HttpPost]
        public ActionResult GenerateCampaignWeeklySummary( string start, string end, string siteID )
        {
            SummaryOverAllHiringOutlookViews model = new SummaryOverAllHiringOutlookViews();
            SummaryOverAllHiringOutlookViews partialViewModel = new SummaryOverAllHiringOutlookViews();
            partialViewModel.SitePivot = _hiringOutlookService.GetCampaignWeeklySummary( start, end, siteID );
            partialViewModel.SiteID = siteID;
            //partialViewModel.LobPivot = _hiringOutlookService.GetLoBWeeklySummary( start, end, "" );

            string campaignHTML = RenderPartialViewToString( "_CampaignWeeklySummary", partialViewModel );

            model.SiteSummaryHTML = campaignHTML;

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        [HttpPost]
        public ActionResult GenerateLobWeeklySummary(string start, string end, string campaignID )
        {
            SummaryOverAllHiringOutlookViews model = new SummaryOverAllHiringOutlookViews();
            SummaryOverAllHiringOutlookViews partialViewModel = new SummaryOverAllHiringOutlookViews();

            partialViewModel.LobPivot = _hiringOutlookService.GetLoBWeeklySummary( start, end, campaignID );

            string lobSummaryHTML = RenderPartialViewToString( "_LobWeeklySummary", partialViewModel );

            model.SiteSummaryHTML = lobSummaryHTML;

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        #endregion
        #endregion

        #region Private Method(s)
        private SummaryOverAllHiringOutlookViews SummaryViewModel(string startMonth)
        {
            SummaryOverAllHiringOutlookViews model = new SummaryOverAllHiringOutlookViews();
            var partialViewModel = this.SummaryOverAllViews( startMonth );
          
			model = partialViewModel;

            return model;
        }
        private SummaryOverAllHiringOutlookViews SummaryOverAllViews(string startMonth)
        {
            DateTime date = DateTime.Now;
            if( !string.IsNullOrEmpty( startMonth ) )
                date = DateTime.Parse( startMonth );

            DateTime firstDayOfMonth1 = new DateTime( date.Year, date.Month, 1 );
            DateTime lastDayOfMonth1 = firstDayOfMonth1.AddMonths( 1 ).AddDays( -1 );

            DateTime firstDayOfMonth2 = firstDayOfMonth1.AddMonths( 1 );
            DateTime lastDayOfMonth2 = firstDayOfMonth2.AddMonths( 1 ).AddDays( -1 );

            DateTime firstDayOfMonth3 = firstDayOfMonth2.AddMonths( 1 );
            DateTime lastDayOfMonth3 = firstDayOfMonth3.AddMonths( 1 ).AddDays( -1 );

            SummaryOverAllHiringOutlookViews model = new SummaryOverAllHiringOutlookViews();
            model.FirstMonthSite = _hiringOutlookService.GetSiteSummary(_commonService.GetFirstMondayOfMonth( firstDayOfMonth1 ),_commonService.GetLastMondayOfMonth( lastDayOfMonth1 ) );
            model.SecondMonthSite = _hiringOutlookService.GetSiteSummary( _commonService.GetFirstMondayOfMonth( firstDayOfMonth2 ), _commonService.GetLastMondayOfMonth( lastDayOfMonth2 ) );
            model.ThirdMonthSite = _hiringOutlookService.GetSiteSummary( _commonService.GetFirstMondayOfMonth( firstDayOfMonth3 ), _commonService.GetLastMondayOfMonth( lastDayOfMonth3 ) );

            model.FirstMonthCampaign = _hiringOutlookService.GetCampaignSummary( _commonService.GetFirstMondayOfMonth( firstDayOfMonth1 ), _commonService.GetLastMondayOfMonth( lastDayOfMonth1 ) );
            model.SecondMonthCampaign = _hiringOutlookService.GetCampaignSummary( _commonService.GetFirstMondayOfMonth( firstDayOfMonth2 ), _commonService.GetLastMondayOfMonth( lastDayOfMonth2 ) );
            model.ThirdMonthCampaign = _hiringOutlookService.GetCampaignSummary( _commonService.GetFirstMondayOfMonth( firstDayOfMonth3 ), _commonService.GetLastMondayOfMonth( lastDayOfMonth3 ) );

            int campaignTotal1 = model.FirstMonthCampaign.Sum( x => x.HiringTotal );
            int campaignTotal2 = model.SecondMonthCampaign.Sum( x => x.HiringTotal );
            int campaignTotal3 = model.ThirdMonthCampaign.Sum( x => x.HiringTotal );

            model.MonthCampaignTotal1 = campaignTotal1;
            model.MonthCampaignTotal2 = campaignTotal2;
            model.MonthCampaignTotal3 = campaignTotal3;
            model.ThreeMonthsSiteTotal = campaignTotal1 + campaignTotal2 + campaignTotal3;

            model.Month1 = firstDayOfMonth1.ToString( "MMMM" );
            model.Month2 = firstDayOfMonth2.ToString( "MMMM" );
            model.Month3 = firstDayOfMonth3.ToString( "MMMM" );
            model.MonthYear1 = firstDayOfMonth1.ToString( "MMMM yyyy" );
            model.MonthYear2 = firstDayOfMonth2.ToString( "MMMM yyyy" );
            model.MonthYear3 = firstDayOfMonth3.ToString( "MMMM yyyy" );
			
			int min = 0, max = 0;
            _hiringOutlookService.MaxMinYear( ref min, ref max );
            model.MinYear = min;
            model.MaxYear = max;
            return model;
        }
		
        protected string RenderPartialViewToString( string viewName, object model )
        {
            if( string.IsNullOrEmpty( viewName ) )
                viewName = ControllerContext.RouteData.GetRequiredString( "action" );

            ViewData.Model = model;

            using( StringWriter sw = new StringWriter() )
            {
                ViewEngineResult viewResult = ViewEngines.Engines.FindPartialView( ControllerContext, viewName );
                ViewContext viewContext = new ViewContext( ControllerContext, viewResult.View, ViewData, TempData, sw );
                viewResult.View.Render( viewContext, sw );
                return sw.GetStringBuilder().ToString();
            }
        }
        #endregion
    }
}