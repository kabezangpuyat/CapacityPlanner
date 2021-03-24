using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using System;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WFMPCP.IService;
using WFMPCP.Model.Web;

namespace WFMPCP.Website.Controllers.CapacityPlan
{
    [Authorize]
    public class CapacityPlannerController : Controller
    {
        #region Local Variable(s)
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

        private IAssumptionHeadcountService _ahcService;
        private IDatapointService _datapointService;
        private ISiteService _siteService;
        private ICampaignService _campaignService;
        private ILoBService _lobService;
        private IWeeklyDatapointService _weeklyDatepointService;
        private IStaffDatapointService _staffDatapointService;
        private IHiringDatapointService _hiringDatapointService;
        private ISiteCampaignLoBService _siteCampaignLobService;
        //private ISegmentService _segmentService;
        #endregion

        #region Constructor(s)
        public CapacityPlannerController()
        {

        }
        public CapacityPlannerController( IAssumptionHeadcountService ahcService, IDatapointService datapointService,
            ISiteService siteService, ICampaignService campaignService, ILoBService lobService, 
            IWeeklyDatapointService weeklyDatapointService, IStaffDatapointService staffDatapointService,
            IHiringDatapointService hiringDatapointService, ISiteCampaignLoBService siteCampaignLobService )
        {
            this._ahcService = ahcService;
            this._datapointService = datapointService;
            this._siteService = siteService;
            this._campaignService = campaignService;
            this._lobService = lobService;
            this._weeklyDatepointService = weeklyDatapointService;
            this._staffDatapointService = staffDatapointService;
            this._hiringDatapointService = hiringDatapointService;
            this._siteCampaignLobService = siteCampaignLobService;
        }
        #endregion

        #region Action Results

        public ActionResult AHC()
        {
            ViewBag.User = User.Identity.GetUserName();
            AHCViews models = new AHCViews();

            var sites = _siteService.GetAll().Where( x => x.Active == true ).OrderBy( x => x.Name ).AsEnumerable();

            models.IsLoadDataGrid = false;
            models.Sites = sites;

            return View( models );
        }

        public ActionResult StaffPlanner()
        {
            ViewBag.User = User.Identity.GetUserName();
            AHCViews models = new AHCViews();

            var sites = _siteService.GetAll().Where( x => x.Active == true ).OrderBy( x => x.Name ).AsEnumerable();

            models.IsLoadDataGrid = false;
            models.Sites = sites;

            return View( models );
        }

        public ActionResult HiringRequirements()
        {
            ViewBag.User = User.Identity.GetUserName();
            AHCViews models = new AHCViews();

            var sites = _siteService.GetAll().Where( x => x.Active == true ).OrderBy( x => x.Name ).AsEnumerable();

            models.IsLoadDataGrid = false;
            models.Sites = sites;

            return View( models );
        }

        public ActionResult Summary()
        {
            ViewBag.User = User.Identity.GetUserName();
            AHCViews models = new AHCViews();

            var sites = _siteService.GetAll().Where( x => x.Active == true ).OrderBy( x => x.Name ).AsEnumerable();

            models.IsLoadDataGrid = false;
            models.Sites = sites;

            return View( models );
        }

        [HttpPost]
        public string GenerateStaffPlanner( AHCViews input )
        {
            var lobid = long.Parse( input.LobID );
            AHCViews models = new AHCViews();

            var pivotData = _ahcService.Read( lobid, start: input.StartDate, end: input.EndDate, includeDatapoint: 1, tablename: "WeeklyStaffDatapoint",
                siteID: input.SiteID, campaignID: input.CampaignID );
          
            var datapoints = _staffDatapointService.GetAll().Where( x => x.Visible == true && x.Active == true ).ToList();

            models.Pivot = pivotData;
            models.StaffDatapoints = datapoints;
            models.IsLoadDataGrid = true;

            string HtmlString = RenderPartialViewToString( "_StaffPlanner", models );
            return HtmlString;
        }

        [HttpPost]
        public string GenerateHiringRequirements( AHCViews input )
        {
            var lobid = 0;
            AHCViews models = new AHCViews();

            var pivotData = _ahcService.Read( lobid, start: input.StartDate, end: input.EndDate, includeDatapoint: 1, tablename: "WeeklyHiringDatapoint",
                siteID: input.SiteID, campaignID: input.CampaignID );

            var pivotHiringTotal = _ahcService.Read( lobid, start: input.StartDate, end: input.EndDate, includeDatapoint: 1, tablename: "WeeklyHiringDatapointTotal",
                siteID: input.SiteID, campaignID: input.CampaignID );

            models.Pivot = pivotData;
            models.PivotHiringTotal = pivotHiringTotal;
      
            models.IsLoadDataGrid = true;

            string HtmlString = RenderPartialViewToString( "_HiringRequirements", models );
            return HtmlString;
        }

        [HttpPost]
        public string GenerateSummary( AHCViews input )
        {
            var lobid = Convert.ToInt64( input.LobID );
            AHCViews models = new AHCViews();

            var pivotData = _ahcService.Read( lobid, start: input.StartDate, end: input.EndDate, includeDatapoint: 1, tablename: "WeeklySummaryDatapoint",
                siteID: input.SiteID, campaignID: input.CampaignID );

            //var pivotHiringTotal = _ahcService.Read( lobid, start: input.StartDate, end: input.EndDate, includeDatapoint: 1, tablename: "WeeklyHiringDatapointTotal",
            //    siteID: input.SiteID, campaignID: input.CampaignID );

            models.Pivot = pivotData;
            //models.PivotHiringTotal = pivotHiringTotal;

            models.IsLoadDataGrid = true;

            string HtmlString = RenderPartialViewToString( "_Summary", models );
            return HtmlString;
        }

        [HttpPost]
        public string GenerateAHC( AHCViews input )
        {
            var lobid = long.Parse( input.LobID );
            AHCViews models = new AHCViews();
            //var reader = _ahcService.GetPivotData( lobid, includeDatapoint: 1 );
            var pivotData = _ahcService.Read( (lobid == 0 ? (long?)null : lobid), start: input.StartDate, end: input.EndDate, includeDatapoint: 1,
                                            siteID: input.SiteID, campaignID: input.CampaignID );
            //var assumptionPivot = _ahcService.Read( lobid, start: input.StartDate, end: input.EndDate, includeDatapoint: 1, segmentCategoryID: "1" );
            //var headcountPivot= _ahcService.Read( lobid, start: input.StartDate, end: input.EndDate, includeDatapoint: 1, segmentCategoryID: "2" );
            //_ahcService.Read( reader ).ToList();
            var datapoints = _datapointService.GetAll().Where( x => x.Visible == true && x.Active == true ).AsEnumerable();

            models.Pivot = pivotData;
            //models.AssumptionPivot = assumptionPivot;
            //models.HeadCountPivot = headcountPivot;
            models.Datapoints = datapoints;
            models.IsLoadDataGrid = true;

            string HtmlString = RenderPartialViewToString( "_AHC", models );
            return HtmlString;
        }

        #endregion

        #region Private Method(s)

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