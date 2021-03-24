using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using System;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WFMPCP.IService;
using WFMPCP.Model;


namespace WFMPCP.Website.Controllers.ExcessDeficit
{
    [Authorize]
    public class ExcessDeficitController : Controller
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

        private IExcessDeficitService _excessDeficitService;
        private ISiteService _siteService;
        private ICommonService _commonService;
        #endregion

        #region Constructor
        public ExcessDeficitController( IExcessDeficitService hiringOutlookService, ISiteService siteService,
            ICommonService commonService )
        {
            this._excessDeficitService = hiringOutlookService;
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
			SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();
			int min = 0, max = 0;
			_excessDeficitService.MaxMinYear(ref min, ref max);
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
            //DateTime startDate = _commonService.StartOfWeek(DateTime.Now,DayOfWeek.Monday);
            //DateTime endDate = _commonService.GetLastMondayOfMonth(startDate.AddMonths(2));
            #endregion

            SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();
            SummaryOverAllExcessDeficitViews partialViewModel = new SummaryOverAllExcessDeficitViews();
            partialViewModel.SitePivot=_excessDeficitService.GetSiteMonthlySummary(string.Empty,string.Empty);
           //partialViewModel.SitePivot = _excessDeficitService.GetSiteMonthlySummary(startDate.ToString("yyyy-MM-dd"),startDate.ToString("yyyy-MM-dd"));
           string siteSummaryHTML = RenderPartialViewToString( "_SiteMonthlySummary", partialViewModel );

            model.SiteSummaryHTML = siteSummaryHTML;           

            return View( model );
        }
        [HttpPost]
        public ActionResult GenerateSiteMonthlySummary( string start, string end )
        {
            SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();
            SummaryOverAllExcessDeficitViews partialViewModel = new SummaryOverAllExcessDeficitViews();
            partialViewModel.SitePivot = _excessDeficitService.GetSiteMonthlySummary( start, end );
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
            DateTime startDate = _commonService.StartOfWeek(DateTime.Now,DayOfWeek.Monday);
            DateTime endDate = _commonService.GetLastMondayOfMonth(startDate.AddMonths(2));
            #endregion

            SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();
            SummaryOverAllExcessDeficitViews partialViewModel = new SummaryOverAllExcessDeficitViews();
            partialViewModel.SitePivot = _excessDeficitService.GetSiteWeeklySummary(startDate.ToString("yyyy-MM-dd"),startDate.ToString("yyyy-MM-dd"));
            string siteSummaryHTML = RenderPartialViewToString( "_SiteWeeklySummary", partialViewModel );

            model.SiteSummaryHTML = siteSummaryHTML;

            return View( model );
        }
        [HttpPost]
        public ActionResult GenerateSiteWeeklySummary( string start, string end )
        {
            SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();
            SummaryOverAllExcessDeficitViews partialViewModel = new SummaryOverAllExcessDeficitViews();
            partialViewModel.SitePivot = _excessDeficitService.GetSiteWeeklySummary( start, end );
            string siteSummaryHTML = RenderPartialViewToString( "_SiteWeeklySummary", partialViewModel );

            model.SiteSummaryHTML = siteSummaryHTML;

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        #endregion

        #region Campaign Monthly SUmmary
        public ActionResult CampaignMonthlySummary()
        {
            ViewBag.User = User.Identity.GetUserName();

            #region Start and End date
            //DateTime startDate = _commonService.StartOfWeek(DateTime.Now,DayOfWeek.Monday);
            //DateTime endDate = _commonService.GetLastMondayOfMonth(startDate.AddMonths(2));
            #endregion

            SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();
            SummaryOverAllExcessDeficitViews partialViewModel = new SummaryOverAllExcessDeficitViews();
            partialViewModel.SitePivot=_excessDeficitService.GetCampaignMonthlySummary(string.Empty,string.Empty);
           //partialViewModel.SitePivot = _excessDeficitService.GetCampaignMonthlySummary(startDate.ToString("yyyy-MM-dd"),startDate.ToString("yyyy-MM-dd"));
           string campaignHTML = RenderPartialViewToString( "_CampaignMonthlySummary", partialViewModel );

            model.SiteSummaryHTML = campaignHTML;

            return View( model );
        }
        [HttpPost]
        public ActionResult GenerateCampaignMonthlySummary( string start, string end )
        {
            SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();
            SummaryOverAllExcessDeficitViews partialViewModel = new SummaryOverAllExcessDeficitViews();
            partialViewModel.SitePivot = _excessDeficitService.GetCampaignMonthlySummary( start, end );
            string campaignHTML = RenderPartialViewToString( "_CampaignMonthlySummary", partialViewModel );

            model.SiteSummaryHTML = campaignHTML;

            return Json( model, JsonRequestBehavior.AllowGet );
        }
        #endregion

        #region Campaign Weekly SUmmary
        public ActionResult CampaignWeeklySummary()
        {
            ViewBag.User = User.Identity.GetUserName();

            SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();
            SummaryOverAllExcessDeficitViews partialViewModel = new SummaryOverAllExcessDeficitViews();
            partialViewModel.SitePivot = _excessDeficitService.GetCampaignWeeklySummary( string.Empty, string.Empty, string.Empty );
            partialViewModel.SiteID = string.Empty;
            string campaignHTML = RenderPartialViewToString( "_CampaignWeeklySummary", partialViewModel );

            model.Sites = _siteService.GetAll().Where( x => x.Active == true ).ToList();
            model.SiteSummaryHTML = campaignHTML;

            return View( model );
        }
        [HttpPost]
        public ActionResult GenerateCampaignWeeklySummary( string start, string end, string siteID )
        {
            SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();
            SummaryOverAllExcessDeficitViews partialViewModel = new SummaryOverAllExcessDeficitViews();
            partialViewModel.SitePivot = _excessDeficitService.GetCampaignWeeklySummary( start, end, siteID );
            partialViewModel.SiteID = siteID;
            //partialViewModel.LobPivot = _hiringOutlookService.GetLoBWeeklySummary( start, end, "" );

            string campaignHTML = RenderPartialViewToString( "_CampaignWeeklySummary", partialViewModel );

            model.SiteSummaryHTML = campaignHTML;

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        [HttpPost]
        public ActionResult GenerateLobWeeklySummary(string start, string end, string campaignID )
        {
            SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();
            SummaryOverAllExcessDeficitViews partialViewModel = new SummaryOverAllExcessDeficitViews();

            partialViewModel.LobPivot = _excessDeficitService.GetLoBWeeklySummary( start, end, campaignID );

            string lobSummaryHTML = RenderPartialViewToString( "_LobWeeklySummary", partialViewModel );

            model.SiteSummaryHTML = lobSummaryHTML;

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        #endregion

        #region Excess Deficit Vs Actual Headcount
        public ActionResult ExcessDeficitVsCurrentHeadCount()
        {
            ViewBag.User = User.Identity.GetUserName();

            SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();
            SummaryOverAllExcessDeficitViews partialViewModel = new SummaryOverAllExcessDeficitViews();
            partialViewModel.SitePivot = _excessDeficitService.GetExcessDeficitVsActualHeadcount( string.Empty, string.Empty, string.Empty );
            partialViewModel.SiteID = string.Empty;
            string campaignHTML = RenderPartialViewToString( "_ExcessDeficitVsCurrentHeadCount", partialViewModel );

            model.Sites = _siteService.GetAll().Where( x => x.Active == true ).ToList();
            model.SiteSummaryHTML = campaignHTML;

            return View( model );
        }

        [HttpPost]
        public ActionResult GenerateExcessDeficitVsActualHeadcount( string start, string end, string siteID )
        {
            SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();
            SummaryOverAllExcessDeficitViews partialViewModel = new SummaryOverAllExcessDeficitViews();
            partialViewModel.SitePivot = _excessDeficitService.GetExcessDeficitVsActualHeadcount( start, end, siteID );
            partialViewModel.SiteID = string.Empty;
            string campaignHTML = RenderPartialViewToString( "_ExcessDeficitVsCurrentHeadCount", partialViewModel );

            model.Sites = _siteService.GetAll().Where( x => x.Active == true ).ToList();
            model.SiteSummaryHTML = campaignHTML;

            return Json( model, JsonRequestBehavior.AllowGet );
        }
        #endregion
        #endregion

        #region Private Method(s)
        private SummaryOverAllExcessDeficitViews SummaryViewModel(string startMonth)
        {
            SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();
            model = this.SummaryOverAllViews( startMonth );

            return model;
        }
        private SummaryOverAllExcessDeficitViews SummaryOverAllViews(string startMonth)
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

            SummaryOverAllExcessDeficitViews model = new SummaryOverAllExcessDeficitViews();

            model.FirstMonthSite = _excessDeficitService.GetSiteMonthlySummary( firstDayOfMonth1.ToString( "yyyy-MM-dd" ), lastDayOfMonth1.ToString( "yyyy-MM-dd" ) );
            model.SecondMonthSite = _excessDeficitService.GetSiteMonthlySummary( firstDayOfMonth2.ToString( "yyyy-MM-dd" ), lastDayOfMonth2.ToString( "yyyy-MM-dd" ) );
            model.ThirdMonthSite = _excessDeficitService.GetSiteMonthlySummary( firstDayOfMonth3.ToString( "yyyy-MM-dd" ), lastDayOfMonth3.ToString( "yyyy-MM-dd" ) );

            model.FirstMonthCampaign = _excessDeficitService.GetCampaignMonthlySummary( firstDayOfMonth1.ToString( "yyyy-MM-dd" ), lastDayOfMonth1.ToString( "yyyy-MM-dd" ) );
            model.SecondMonthCampaign = _excessDeficitService.GetCampaignMonthlySummary( firstDayOfMonth2.ToString( "yyyy-MM-dd" ), lastDayOfMonth2.ToString( "yyyy-MM-dd" ) );
            model.ThirdMonthCampaign = _excessDeficitService.GetCampaignMonthlySummary( firstDayOfMonth3.ToString( "yyyy-MM-dd" ), lastDayOfMonth3.ToString( "yyyy-MM-dd" ) );

            model.Month1 = firstDayOfMonth1.ToString( "MMMM" );
            model.Month2 = firstDayOfMonth2.ToString( "MMMM" );
            model.Month3 = firstDayOfMonth3.ToString( "MMMM" );
            model.MonthYear1 = firstDayOfMonth1.ToString( "MMMM yyyy" );
            model.MonthYear2 = firstDayOfMonth2.ToString( "MMMM yyyy" );
            model.MonthYear3 = firstDayOfMonth3.ToString( "MMMM yyyy" );

            int min = 0, max = 0;
            _excessDeficitService.MaxMinYear( ref min, ref max );
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