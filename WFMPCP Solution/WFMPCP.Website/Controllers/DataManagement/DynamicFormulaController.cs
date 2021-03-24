using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Web;
using System.Web.Mvc;
using WFMPCP.IService;
using WFMPCP.Model;
using WFMPCP.Model.Web;

namespace WFMPCP.Website.Controllers.DataManagement
{
    [Authorize]
	public class DynamicFormulaController : Controller
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

		private IDynamicFormulaService _dynamicFormulaService;
		private ISiteCampaignLoBFormulaService _siteCampaignLobFormulaService;
		private ILoBService _lobService;
		private ICampaignService _campaignService;
		private ISiteService _siteService;
		private ISiteCampaignService _siteCampaignService;
		private ISiteCampaignLoBService _siteCampaignLobService;
		#endregion

		#region Constructor(s)
		public DynamicFormulaController()
		{

		}
		public DynamicFormulaController(IDynamicFormulaService dynamicFormulaService, ISiteCampaignLoBFormulaService siteCampaignLobFormulaService,
			ICampaignService campaignService, ISiteService siteService, ILoBService lobService,ISiteCampaignService siteCampaignService,
			ISiteCampaignLoBService siteCampaignLobService)
		{
			this._campaignService = campaignService;
			this._siteService = siteService;
			this._lobService = lobService;
			this._siteCampaignService = siteCampaignService;
			this._siteCampaignLobService = siteCampaignLobService;
			this._dynamicFormulaService = dynamicFormulaService;
			this._siteCampaignLobFormulaService = siteCampaignLobFormulaService;
		}
		#endregion

		#region Action Result View
		public ActionResult MapFormula()
		{
			ViewBag.User = User.Identity.GetUserName();
			IQueryable<SiteViewModel> sites = _siteService.GetAll().Where(x => x.Active == true).OrderBy(x => x.Name).AsQueryable();
			IQueryable<DynamicFormulaViewModel> formulas = _dynamicFormulaService.GetAll().Where(x => x.Active == true).OrderBy(x => x.Name).AsQueryable();
			return View(Tuple.Create(sites,formulas));
		}

		[HttpPost]
		public ActionResult LoadDetails(long id)
		{
			var siteCampaignLobFormula = _siteCampaignLobFormulaService.GetByID(id);
			DynamicFormulaView model = new DynamicFormulaView();
			if(siteCampaignLobFormula != null)
				if (siteCampaignLobFormula.ID == id)
				{
					model.ID = siteCampaignLobFormula.ID;
					model.SiteID = siteCampaignLobFormula.SiteID;
					model.CampaignID = siteCampaignLobFormula.CampaignID;
					model.LobID = siteCampaignLobFormula.LoBID;
					model.FormulaID = siteCampaignLobFormula.DynamicFormulaID;
					model.FormulaName = siteCampaignLobFormula.DynamicFormulaVM.Name;
					model.FormulaDescription = siteCampaignLobFormula.DynamicFormulaVM.Description;
				}

			return Json(model, JsonRequestBehavior.AllowGet);
		}

		[HttpPost]
		public ActionResult Save(DynamicFormulaView data)
		{
			string username = User.Identity.GetUserName();
			CommonView model = new CommonView();
			string message = string.Empty;

			try
			{
				var sclf = new SiteCampaignLobFormulaViewModel()
				{
					ID = data.ID,
					SiteID = data.SiteID,
					CampaignID = data.CampaignID,
					LoBID = data.LobID,
					DynamicFormulaID = data.FormulaID,
					Active = true
				};

				if (data.ID == 0)
				{
					_siteCampaignLobFormulaService.Create(sclf);
					if (sclf.ID > 0)
					{
						message = "Data added.";
						data.ID = sclf.ID;
					}
				}
				else
				{
					//update
					_siteCampaignLobFormulaService.Update(sclf);

					message = "Data updated.";
				}
				
				model.Message = message;
			}
			catch (Exception ex)
			{
				if (ex.GetType() == typeof(ArgumentException))
					model.Message = ((ArgumentException)ex).Message;
				else
					model.Message = "Unable to save data. Please contact your system administrator.";
			}
			
			return Json(model, JsonRequestBehavior.AllowGet);
		}

		[HttpPost]
		public ActionResult Delete(long id)
		{
			string username = User.Identity.GetUserName();
			CommonView model = new CommonView();

			try
			{
				_siteCampaignLobFormulaService.Deactivate(id);
				model.Message = "Data deleted.";
			}
			catch (Exception ex)
			{
				if (ex.GetType() == typeof(ArgumentException))
					model.Message = ((ArgumentException)ex).Message;
				else
					model.Message = "Unable to delete data. Please contact your system administrator.";
			}

			return Json(model, JsonRequestBehavior.AllowGet);
		}
		#endregion

		#region Method(s)
		private IQueryable<DynamicFormulaView> DyanmicFormulaWebViews
		{
			get
			{
				var data = _dynamicFormulaService.GetAllWebView().Where(x=>x.Active==true).OrderBy(x => x.FormulaName).AsQueryable();
			
				return data;
			}
		}

		#endregion

		#region JQGRID
		#region GridView
		private void SearchGrid(string searchOper, string searchField, string searchString,
			IQueryable<DynamicFormulaView> gridData, ref IQueryable<DynamicFormulaView> filteredData)
		{
			switch (searchOper)
			{
				case "eq":
					if (searchField.Trim().ToLower() == "sitename")
					{ filteredData = gridData.Where(x => x.SiteName.ToLower() == searchString.ToLower()).AsQueryable(); }
					if (searchField.Trim().ToLower() == "campaignname")
					{ filteredData = gridData.Where(x => x.CampaignName.ToLower() == searchString.ToLower()).AsQueryable(); }
					if (searchField.Trim().ToLower() == "lobname")
					{ filteredData = gridData.Where(x => x.LobName.ToLower() == searchString.ToLower()).AsQueryable(); }
					if (searchField.Trim().ToLower() == "formulaname")
					{ filteredData = gridData.Where(x => x.FormulaName.ToLower() == searchString.ToLower()).AsQueryable(); }
					break;
				case "cn":
					if (searchField.Trim().ToLower() == "sitename")
					{ filteredData = gridData.Where(s => s.SiteName.ToLower().Contains(searchString.ToLower())).AsQueryable(); }
					if (searchField.Trim().ToLower() == "campaignname")
					{ filteredData = gridData.Where(s => s.CampaignName.ToLower().Contains(searchString.ToLower())).AsQueryable(); }
					if (searchField.Trim().ToLower() == "lobname")
					{ filteredData = gridData.Where(s => s.LobName.ToLower().Contains(searchString.ToLower())).AsQueryable(); }
					if (searchField.Trim().ToLower() == "formulaname")
					{ filteredData = gridData.Where(s => s.FormulaName.ToLower().Contains(searchString.ToLower())).AsQueryable(); }

					break;
			}
		}
		[HttpPost]
		public ActionResult LoadjqData(string sidx, string sord, int page, int rows,
				bool _search, string searchField, string searchOper, string searchString)
		{
			IQueryable<DynamicFormulaView> gridData = this.DyanmicFormulaWebViews;
			// If search, filter the list against the search condition.
			// Only "contains" search is implemented here.
			var filteredData = gridData;
			if (_search)
			{
				this.SearchGrid(searchOper, searchField, searchString, gridData, ref filteredData);
			}
			// Sort the student list
			IEnumerable<DynamicFormulaView> sortedRoles = null;

			#region New Condition
			sortedRoles = SortIQueryable<DynamicFormulaView>(filteredData, sidx, sord).AsEnumerable();
			#endregion

			// Calculate the total number of pages
			var totalRecords = filteredData.Count();
			var totalPages = (int)Math.Ceiling((double)totalRecords / (double)rows);

			// NOTE:XXXX Prepare the data to fit the requirement of jQGrid
			var data =
				sortedRoles.Select(s => new
				{
					id = s.ID,
					cell = new object[] {
						s.ID,
						s.SiteName,
						s.CampaignName,
						s.LobName,
						s.FormulaName
					},
				}).ToArray();

			// Send the data to the jQGrid
			var jsonData = new
			{
				total = totalPages,
				page = page,
				records = totalRecords,
				rows = data.Skip((page - 1) * rows).Take(rows)
			};
			return Json(jsonData, JsonRequestBehavior.AllowGet);

		}

		#endregion
		#region SORT QUERY
		// Utility method to sort IQueryable given a field name as "string"
		// May consider to put in a cental place to be shared
		private IQueryable<T> SortIQueryable<T>(IQueryable<T> data, string fieldName, string sortOrder)
		{
			if (string.IsNullOrWhiteSpace(fieldName))
				return data;
			if (string.IsNullOrWhiteSpace(sortOrder))
				return data;

			var param = Expression.Parameter(typeof(T), "i");
			Expression conversion = Expression.Property(param, fieldName.Split(',').Select(x => x).FirstOrDefault());
			var mySortExpression = Expression.Lambda<Func<T, object>>(conversion, param);

			return (sortOrder == "desc") ? data.OrderByDescending(mySortExpression)
				: data.OrderBy(mySortExpression);
		}
		#endregion
		#endregion
	}
}