using Ninject;
using System;
using System.Web.Mvc;

using WFMPCP.Core;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Service;

namespace WFMPCP.Website.IoC
{
	public class NinjectControllerFactory : DefaultControllerFactory
	{
		private IKernel _kernel;

		public NinjectControllerFactory()
		{
			_kernel = new StandardKernel();
			AddBindings();
		}

		private void AddBindings()
		{
			_kernel.Bind<IWFMPCPContext>().To<WFMPCPContext>();
			_kernel.Bind<IEPMSContext>().To<EPMSContext>();
			_kernel.Bind<IActiveDirectoryService>().To<ActiveDirectoryService>();
			_kernel.Bind<IAuditTrailService>().To<AuditTrailService>();
			_kernel.Bind<ICampaignService>().To<CampaignService>();
			_kernel.Bind<ILoBService>().To<LoBService>();
			_kernel.Bind<IModuleRolePermissionService>().To<ModuleRolePermissionService>();
			_kernel.Bind<IModuleService>().To<ModuleService>();
			_kernel.Bind<IPermissionService>().To<PermissionService>();
			_kernel.Bind<IRestSharpService>().To<RestSharpService>();
			_kernel.Bind<IRoleService>().To<RoleService>();
			_kernel.Bind<ISiteService>().To<SiteService>();
			_kernel.Bind<IUserRoleService>().To<UserRoleService>();
			_kernel.Bind<IUserService>().To<UserService>();
			_kernel.Bind<ISegmentCategoryService>().To<SegmentCategoryService>();
			_kernel.Bind<ISegmentService>().To<SegmentService>();
			_kernel.Bind<IDatapointService>().To<DatapointService>();
			_kernel.Bind<IAssumptionHeadcountService>().To<AssumptionHeadcountService>();
			_kernel.Bind<ICommonService>().To<CommonService>();
			_kernel.Bind<IWeeklyDatapointService>().To<WeeklyDatapointService>();
			_kernel.Bind<IStaffSegmentService>().To<StaffSegmentService>();
			_kernel.Bind<IStaffDatapointService>().To<StaffDatapointService>();
			_kernel.Bind<IHiringDatapointService>().To<HiringDatapointService>();
			_kernel.Bind<ISiteCampaignService>().To<SiteCampaignService>();
			_kernel.Bind<ISiteCampaignLoBService>().To<SiteCampaignLoBService>();
			_kernel.Bind<ISummaryDatapointService>().To<SummaryDatapointService>();
			_kernel.Bind<IHiringOutlookService>().To<HiringOutlookService>();
			_kernel.Bind<IExcessDeficitService>().To<ExcessDeficitService>();
			_kernel.Bind<IDynamicFormulaService>().To<DynamicFormulaService>();
			_kernel.Bind<ISiteCampaignLoBFormulaService>().To<SiteCampaignLoBFormulaService>();
			_kernel.Bind<IUploadAHCService>().To<UploadAHCService>();
			_kernel.Bind<IStagingWeeklyDatapointService>().To<StagingWeeklyDatapointService>();
			_kernel.Bind<IErlangCSercvice>().To<ErlangCSercvice>();
		}

		protected override IController GetControllerInstance(System.Web.Routing.RequestContext requestContext, Type controllerType)
		{
			return controllerType == null
				? null
				: (IController)_kernel.Get(controllerType);
		}
	}
}