using Ninject;

using WFMPCP.Core;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Service;

namespace WFMPCP.Website.IoC
{
	public class NinjectConfigurator
	{
		public void Configure(IKernel kernel)
		{
			AddBindings(kernel);
		}

		public void AddBindings(IKernel kernel)
		{
			kernel.Bind<IWFMPCPContext>().To<WFMPCPContext>();
			kernel.Bind<IEPMSContext>().To<EPMSContext>();
			kernel.Bind<IActiveDirectoryService>().To<ActiveDirectoryService>();
			kernel.Bind<IAuditTrailService>().To<AuditTrailService>();
			kernel.Bind<ICampaignService>().To<CampaignService>();
			kernel.Bind<ILoBService>().To<LoBService>();
			kernel.Bind<IModuleRolePermissionService>().To<ModuleRolePermissionService>();
			kernel.Bind<IModuleService>().To<ModuleService>();
			kernel.Bind<IPermissionService>().To<PermissionService>();
			kernel.Bind<IRestSharpService>().To<RestSharpService>();
			kernel.Bind<IRoleService>().To<RoleService>();
			kernel.Bind<ISiteService>().To<SiteService>();
			kernel.Bind<IUserRoleService>().To<UserRoleService>();
			kernel.Bind<IUserService>().To<UserService>();
			kernel.Bind<ISegmentCategoryService>().To<SegmentCategoryService>();
			kernel.Bind<ISegmentService>().To<SegmentService>();
			kernel.Bind<IDatapointService>().To<DatapointService>();
			kernel.Bind<IAssumptionHeadcountService>().To<AssumptionHeadcountService>();
			kernel.Bind<ICommonService>().To<CommonService>();
			kernel.Bind<IWeeklyDatapointService>().To<WeeklyDatapointService>();
			kernel.Bind<IStaffSegmentService>().To<StaffSegmentService>();
			kernel.Bind<IStaffDatapointService>().To<StaffDatapointService>();
			kernel.Bind<IHiringDatapointService>().To<HiringDatapointService>();
			kernel.Bind<ISiteCampaignService>().To<SiteCampaignService>();
			kernel.Bind<ISiteCampaignLoBService>().To<SiteCampaignLoBService>();
			kernel.Bind<ISummaryDatapointService>().To<SummaryDatapointService>();
			kernel.Bind<IHiringOutlookService>().To<HiringOutlookService>();
			kernel.Bind<IExcessDeficitService>().To<ExcessDeficitService>();
			kernel.Bind<IDynamicFormulaService>().To<DynamicFormulaService>();
			kernel.Bind<ISiteCampaignLoBFormulaService>().To<SiteCampaignLoBFormulaService>();
			kernel.Bind<IUploadAHCService>().To<UploadAHCService>();
			kernel.Bind<IStagingWeeklyDatapointService>().To<StagingWeeklyDatapointService>();
			kernel.Bind<IErlangCSercvice>().To<ErlangCSercvice>();
		}
	}
}