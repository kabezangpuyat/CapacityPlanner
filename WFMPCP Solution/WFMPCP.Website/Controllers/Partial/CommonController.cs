using Microsoft.AspNet.Identity;
using System;
using System.Linq;
using System.Web.Mvc;
using WFMPCP.IService;
using WFMPCP.Model;
using WFMPCP.Model.Web;

namespace WFMPCP.Website.Controllers.Partial
{
    public class CommonController : Controller
    {
        //private IModuleService _moduleService;
        private IModuleService _moduleService;
		private IUserRoleService _userRoleService;
		private IErlangCSercvice _erlangService;
        #region Constructor(s)
        public CommonController( IModuleService moduleService, IUserRoleService userRoleService, IErlangCSercvice erlangService )
        {
            this._userRoleService = userRoleService;
            this._moduleService = moduleService;
			this._erlangService = erlangService;
        } 
        #endregion

        // GET: Common
        public ActionResult _NavigationList()
        {
            var userId = Convert.ToInt32( User.Identity.GetUserId() );
            long roleID = 0;
            var userRole = _userRoleService.GetByID( userId );
            if( userRole != null )
                roleID = (long)userRole.RoleID;

            var parent = _moduleService.GetAllByRoleID(roleID)
                                .Where( x => x.Active == true && x.ParentID == 0 )
                                .OrderBy( x => x.SortOrder )
                                .ToList();

            var children = _moduleService.GetAllByRoleID( roleID )
                                .Where( x => x.Active == true && x.ParentID > 0 )
                                .OrderBy( x => x.SortOrder )
                                .ToList();

            //_moduleService.GetAll()
            //                .Where( x => x.Active == true && x.ParentID > 0 )
            //                .ToList();

            NavigationView model = new NavigationView();
            model.Parent = parent;
            model.Children = children;

            return View(model);
        }

        #region DivLoading
        public PartialViewResult _DivLoading()
        {
            return PartialView();
        }

		public PartialViewResult _ErlangCCalculator()
		{
			return PartialView();
		}
        #endregion

        #region Error Page(s)
        public ActionResult Error()
        {
            ViewBag.User = User.Identity.GetUserName();
            return View();
        }
		#endregion

		#region JsonResult
		[HttpPost]
		public ActionResult ComputeErlangC(long numberOfCalls, long ahtInSeconds, decimal requiredServiceLevel,
			long targetAnswerTimeInSeconds, decimal shrinkage)
		{
			string msg = string.Empty;

			ErlangCViewModel erlangModel = new ErlangCViewModel();
			try
			{
				erlangModel = _erlangService.Calculate(numberOfCalls, ahtInSeconds, requiredServiceLevel, targetAnswerTimeInSeconds, shrinkage);
			}
			catch (Exception ex)
			{
				msg = ex.Message;
			}
			ErlangCCalculatorResult model = new ErlangCCalculatorResult()
			{
				ErlangCViewModel = erlangModel,
				Message = msg
			};
	
			return Json(model, JsonRequestBehavior.AllowGet);
		}
		#endregion
	}
}