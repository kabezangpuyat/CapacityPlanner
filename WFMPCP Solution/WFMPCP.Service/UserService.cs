using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity.SqlServer;
using System.Linq;
using WFMPCP.Core;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class UserService : IUserService
	{
		private string _serviceURL;
		private IRestSharpService _restSharpService;

		#region Constructor(s)

		public UserService()
		{
			this._serviceURL = ConfigurationManager.AppSettings["EmployeeProfile.ServiceUrl"];
		}

		public UserService(IRestSharpService restSharpService)
		{
			this._serviceURL = ConfigurationManager.AppSettings["EmployeeProfile.ServiceUrl"];
			this._restSharpService = restSharpService;
		}

		#endregion Constructor(s)

		#region Method(s)

		#region User Grow

		public UserResult GetUser(int? id = null, string employeeID = null)
		{
			UserResult user = new UserResult();
			if (id!= null && employeeID==null)
				user = this.GetAllUser().Where(x => x.ID == (int)id).FirstOrDefault();

			if (id==null && employeeID != null)
				user = this.GetAllUser().Where(x => x.EmployeeID == employeeID).FirstOrDefault();

			return user;
		}

		public List<UserResult> GetAllBySite(string site)
		{
			var employeeIDs = this.GetAllUserDetail()
							.Where(x => x.Site == site)
							.Select(x => SqlFunctions.StringConvert((double)x.EmployeeID))
							.ToList();

			var users = this.GetAllUser()
							.Where(x => employeeIDs.Contains(x.EmployeeID))
							.ToList();

			return users;
		}

		public List<UserResult> GetAllUser()
		{
			string qry = @"SELECT
							ID
							,[User_ID] EmployeeID
							,FullName
							,UserLevel
							,[Password]
							,Campaign
							,LOB LoB
							,Others
							,Email
							,MobilePhone
							,AD_Login ADLogin
							,Field11
							,System_Source RoleName
						FROM [dbo].[uvw_EmployeeMasterTableGrow] (NOLOCK)";
			List<UserResult> users = new List<UserResult>();
			EPMSContext epmsContext = new Core.EPMSContext();
			users = epmsContext.GetList<UserResult>(qry);

			return users;
		}

		public List<string> GetUserLevel()
		{
			List<string> data = null;

			data = this.GetAllUser().Where(x => x.UserLevel != null || x.UserLevel != "").Select(x => x.UserLevel.Trim()).Distinct().ToList();
			return data;
		}

		#endregion User Grow

		#region Operations

		public List<UserDetailSuperiorResult> GetAllUserDetailBySuperior(string superiorID)
		{
			string qry = string.Format(@"SELECT
								o.ID ID
								,o.Employee_ID EmployeeID
								,Name = u.FullName
								,Position=o.Position_JobDescription
								,SupEmployeeID=o.IS_ID
								FROM [dbo].[uvw_EmployeeMasterCoaching] o (NOLOCK)
								INNER JOIN [dbo].[uvw_EmployeeMasterTableGrow] u (NOLOCK) ON u.[User_ID]=o.Employee_ID
								WHERE o.IS_ID='{0}'", superiorID);

			List<UserDetailSuperiorResult> userDetails = new List<UserDetailSuperiorResult>();
			userDetails = new EPMSContext().GetList<UserDetailSuperiorResult>(qry);

			return userDetails;
		}

		public List<UserDetailResult> GetAllUserDetail()
		{
			string qry = @"SELECT
							ID
							,Employee_ID EmployeeID
							,LastName
							,MiddleName
							,FirstName
							,Position_JobDescription JobDescription
							,Campaign
							,LOB LoB
							,CampaignCategory
							,Location
							,[Site]
							,IS_ID ISID
							,IS_LastName ISLastName
							,IS_FirstName ISFirstName
							,Coach_ID CoachID
							,Coach_Name CoachName
							,QA_ID QAID
							,QA_Name QAName
							,Trainer_ID TrainerID
							,Trainer_Name TrainerName
							,Operations_Manager OperationsManager
							,Senior_Operations_Manager SeniorOperationsManager
							,[Status]
							,Department
							,Status_Approval StatusApproval
						FROM [dbo].[uvw_EmployeeMasterCoaching] (NOLOCK) ";

			List<UserDetailResult> userDetails = new List<UserDetailResult>();
			userDetails = new EPMSContext().GetList<UserDetailResult>(qry);

			return userDetails;
		}

		public UserDetailResult GetUserDetail(int? id = null, string employeeID = null)
		{
			UserDetailResult userDetail = new UserDetailResult();
			if (id != null && employeeID == null)
				userDetail = this.GetAllUserDetail().Where(x => x.ID == (int)id).FirstOrDefault();

			if (id == null && employeeID != null)
				userDetail = this.GetAllUserDetail().Where(x => x.EmployeeID == Convert.ToInt32(employeeID.Trim())).FirstOrDefault();

			return userDetail;
		}

		#endregion Operations

		#region User Site

		public List<string> GetAllUserSite()
		{
			List<string> retValue = this.GetAllUserDetail()
									.Where(x => x.Site.Trim() != "")
									.OrderBy(x => x.Site)
									.Select(x => x.Site)
									.Distinct()
									.ToList();

			return retValue;
		}

		#endregion User Site

		#endregion Method(s)
	}
}