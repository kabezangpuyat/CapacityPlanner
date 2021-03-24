using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using System;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WFMPCP.IService;
using WFMPCP.Model;
using WFMPCP.Model.Web;

namespace WFMPCP.Website.Controllers.PCPManagement
{
    [Authorize]
    public class AssumptionsHeadcountManagementController : Controller
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
        private ISiteCampaignService _siteCampaignService;
        private ISiteCampaignLoBService _siteCampaignLobService;
		private IAuditTrailService _auditTrailService;
		private IUploadAHCService _uploadService;
		private IStagingWeeklyDatapointService _stagingWeeklyDatapointService;
		//private ISegmentService _segmentService;
		#endregion

		#region Constructor(s)
		public AssumptionsHeadcountManagementController()
        {

        }
        //public AssumptionsHeadcountManagementController( IAssumptionHeadcountService ahcService, IDatapointService datapointService,
        //  ISiteService siteService, ICampaignService campaignService, ILoBService lobService )
        //{
        //    this._ahcService = ahcService;
        //    this._datapointService = datapointService;
        //    this._siteService = siteService;
        //    this._campaignService = campaignService;
        //    this._lobService = lobService;
        //}
        public AssumptionsHeadcountManagementController( IAssumptionHeadcountService ahcService, IDatapointService datapointService,
            ISiteService siteService, ICampaignService campaignService, ILoBService lobService, IWeeklyDatapointService weeklyDatapointService,
            ISiteCampaignService siteCampaignService, ISiteCampaignLoBService siteCampaignLobService, IAuditTrailService auditTrailService,
			IUploadAHCService uploadAHCService, IStagingWeeklyDatapointService stagingWeeklyDatapointService)
        {
            this._ahcService = ahcService;
            this._datapointService = datapointService;
            this._siteService = siteService;
            this._campaignService = campaignService;
            this._lobService = lobService;
            this._weeklyDatepointService = weeklyDatapointService;
            this._siteCampaignService = siteCampaignService;
            this._siteCampaignLobService = siteCampaignLobService;
			this._auditTrailService = auditTrailService;
			this._uploadService=uploadAHCService;
			this._stagingWeeklyDatapointService = stagingWeeklyDatapointService;
        }
        #endregion

        #region ActionResult(s)
        public ActionResult ManageAHC()
        {
            ViewBag.User = User.Identity.GetUserName();
            AHCViews models = new AHCViews();

            //var reader = _ahcService.GetPivotData( 0, includeDatapoint: 1 );
            //var pivotData = _ahcService.Read( reader ).ToList();
            //////var segments = _ahcService.GetAllSegmentCategories().OrderBy( sc => sc.SortOrder ).Select( sc => sc.Segments );
            //////var segments = _ahcService.GetAllSegments().Where( x => x.Visible == true && x.Active == true );
            //var datapoints = _datapointService.GetAll().Where( x => x.Visible == true && x.Active == true ).AsEnumerable();
            var sites = _siteService.GetAll().Where( x => x.Active == true ).OrderBy( x => x.Name ).AsEnumerable();
            var segments = _ahcService.GetAllSegments().Where( x => x.Visible == true && x.Active == true ).ToList();


            //models.Pivot = pivotData;
            models.Segments = segments;
            //models.Datapoints = datapoints;
            models.IsLoadDataGrid = false;
            models.Sites = sites;


            return View( models );
        }        

		[HttpPost]
		public JsonResult UploadCSV()
		{
			string message = string.Empty;
			bool isError = false;
			bool isFileOpen = false;
			string ntLogin = User.Identity.GetUserName();
			try
			{
				//for (int i = 0; i < Request.Files.Count; i++)
				//{
				if (Request.Files.Count==1)
				{
					HttpPostedFileBase file = Request.Files[0]; //Uploaded file
																//Use the following properties to get file's name, size and MIMEType
					int fileSize = file.ContentLength;
					string fileName = file.FileName;
					string mimeType = file.ContentType;
					Stream fileContent = file.InputStream;
					//To save file, use SaveAs method
					string path = Path.Combine(Server.MapPath("~/UploadedFiles/") + fileName);

					if (System.IO.File.Exists(path))
						System.IO.File.Delete(path);

					file.SaveAs(path); //File will be saved in application root
									   //}
									   //TODO: Extract CSV
					bool isSuccess = _uploadService.ExtractCSV(path, ntLogin);

					
					if (isSuccess)
						message = "File uploaded.";
					else
						message="File upload failed. Please contact your System Administrator.";

					fileContent.Dispose();
				}
			
			}
			catch (Exception ex)
			{
				isError = true;
				//TODO: Log here
				string[] err = { "the process cannot access the file", "because it is being used by another process" };

				if(!string.IsNullOrEmpty(ex.Message))
					if(ex.Message.ToLower().Contains("because it is being used by another process"))
					{
						isFileOpen = true;
						message += "<br /> File successfully uploaded.";
					}
						
				
				message += "<br /> Unexpected error encountered. Please contact your system administrator.";
				message += string.Format("<br /> Error: {0}", ex.Message);
			}
			finally
			{
				if (!isError)
					message = "File successfully uploaded.";
				else
				{
					if (isFileOpen)
					{
						message = "File uploaded successfully.";
					}
				}
				
					
			}

			return Json(new { Message=message}, JsonRequestBehavior.AllowGet);
		}

		[HttpPost]
        public string GenerateAHC( AHCViews input )
        {
            var lobid = long.Parse( input.LobID );
            AHCViews models = new AHCViews();
            //var reader = _ahcService.GetPivotData( lobid, includeDatapoint: 1 );
            var pivotData = _ahcService.Read( lobid,start: input.StartDate, end:input.EndDate, includeDatapoint: 1, 
                siteID:input.SiteID, campaignID:input.CampaignID );
                //_ahcService.Read( reader ).ToList();
            var datapoints = _datapointService.GetAll().Where( x => x.Visible == true && x.Active == true ).AsEnumerable();
            
            models.Pivot = pivotData;
            models.Datapoints = datapoints;
            models.IsLoadDataGrid = true;

            string HtmlString = RenderPartialViewToString( "_AssumptionAHC", models );
            return HtmlString;
        }

        [HttpPost]
        public ActionResult GetCampaignBySite(long siteID)
        {
            var campaigns = _siteCampaignService.GetAllSiteCampaignBySiteID( siteID, true )
                .OrderBy( x => x.CampaignVM.Name )
                .Select( x => new CampaignViewModel()
                {
                    ID = x.CampaignVM.ID,
                    Name = x.CampaignVM.Name
                } )
                .ToList();                
                //_campaignService.GetAllBySiteID( siteID, true ).OrderBy( x => x.Name ).ToList();
            return Json( campaigns, JsonRequestBehavior.AllowGet );
        }

        [HttpPost]
        public ActionResult GetLoBByCampaign( long siteID, long campaignID )
        {
            var lobs = _siteCampaignLobService.GetAllLoBBySiteCampaign( siteID, campaignID, true ).OrderBy( x => x.LobVM.Name )
                .Select( x => new LoBViewModel()
                {
                    ID = x.LobVM.ID,
                    Name = x.LobVM.Name
                } ).ToList();
                
                //_lobService.GetAllByCampaignID( campaignID, true ).OrderBy( x => x.Name ).ToList();
            return Json( lobs, JsonRequestBehavior.AllowGet );
        }

        [HttpPost]
        public ActionResult LoadWeeklyDatapoints(DateTime date, long campaignID, long lobID)
        {
            //WeeklyDatapointViewModel model = new WeeklyDatapointViewModel();
            var model = _weeklyDatepointService.GetAll().Where( x => x.Date == date && x.LoBID == lobID ).ToList();

            return Json( model, JsonRequestBehavior.AllowGet );
        }

        [HttpPost]
        public ActionResult Save(string datapointValues, string date, string campaignID, string lobID, string siteID)
        {
            //string[] splitDatapointIds = datapointIds.TrimEnd( ',' ).Split( ',' );
            string[] splitDatapointValues = datapointValues.TrimEnd( ',' ).Split( ',' );
            string message = string.Empty;

            #region Create Data set
            //DataSet dataset = new DataSet();
            //dataset.Locale = CultureInfo.InvariantCulture;
            DataTable datatable = new DataTable();
                //dataset.Tables.Add( "AHCData" );

            datatable.Columns.Add( "DatapointID", typeof(long) );
            datatable.Columns.Add( "SiteID", typeof( long ) );
            datatable.Columns.Add( "CampaignID", typeof( long ) );
            datatable.Columns.Add( "LoBID", typeof( long ) );
            datatable.Columns.Add( "Date", typeof(DateTime) );
            //datatable.Columns.Add( "Date", typeof( string ) );
            datatable.Columns.Add( "DataValue", typeof(string) );
            datatable.Columns.Add( "UserName", typeof( string ) );
            datatable.Columns.Add( "DateModified", typeof( DateTime ) );
            string datemodified = DateTime.Now.ToString();
            string user = User.Identity.GetUserName();

            DataRow datarow; 
	        #endregion

            try
            {
                foreach( var datapointValue in splitDatapointValues )
                {
                    long id = 0;
                    string dt = string.Empty;
                    string value = string.Empty;
                    string[] splitDatapointValue = datapointValue.Split( ':' );
                    string[] splitIdDate = splitDatapointValue[0].Split( '_' );

                    id = Convert.ToInt64( splitIdDate[1] );
                    dt = splitIdDate[0].Replace( "x", "-" );

                    value = splitDatapointValue[1].ToString().Replace("%","").Trim();
                   
                    datarow = datatable.NewRow();
                    datarow["DatapointID"] = id;
                    datarow["SiteID"] = siteID;
                    datarow["CampaignID"] = campaignID;
                    datarow["LoBID"] = lobID;
                    datarow["Date"] = dt;
                    datarow["DataValue"] = value;
                    datarow["UserName"] = user;
                    datarow["DateModified"] = datemodified;

                    datatable.Rows.Add( datarow );
                }

                _ahcService.Save( datatable );
                message = "Data saved.";
            }
            catch(Exception ex)
            {
                message = "Unexpected error encountered. Please contact your system administrator.";
				string auditEntry = string.Empty;

				auditEntry += @"Error saving Assumption and Headcount. \n";
				auditEntry += string.Format("ErrorMessage: {0} \n", ex.Message);
				auditEntry += string.Format("TargetName: {0} \n", ex.TargetSite.Name);
				auditEntry += string.Format("StackTrace: {0} \n", ex.StackTrace);

				AuditTrailViewModel audit = new AuditTrailViewModel()
				{
					AuditEntry = auditEntry,
					CreatedBy = User.Identity.GetUserName(),
					DateCreated = DateTime.Now,
					DateModified = null
				};
				_auditTrailService.Create(audit);
			}

             var model = new Model.Web.CommonView() { Message = message };
            return Json( model, JsonRequestBehavior.AllowGet );
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