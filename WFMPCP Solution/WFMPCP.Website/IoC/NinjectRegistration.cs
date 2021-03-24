using Ninject.Modules;
using WFMPCP.Core;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Service;

namespace WFMPCP.Website.IoC
{
	public class NinjectRegistration : NinjectModule
	{
		public override void Load()
		{
			Bind<IWFMPCPContext>().To<WFMPCPContext>();
			Bind<IEPMSContext>().To<EPMSContext>();
			Bind<IActiveDirectoryService>().To<ActiveDirectoryService>();
			Bind<IAuditTrailService>().To<AuditTrailService>();
			Bind<ICampaignService>().To<CampaignService>();
			Bind<ILoBService>().To<LoBService>();
			Bind<IModuleRolePermissionService>().To<ModuleRolePermissionService>();
			Bind<IModuleService>().To<ModuleService>();
			Bind<IPermissionService>().To<PermissionService>();
			Bind<IRestSharpService>().To<RestSharpService>();
			Bind<IRoleService>().To<RoleService>();
			Bind<ISiteService>().To<SiteService>();
			Bind<IUserRoleService>().To<UserRoleService>();
			Bind<IUserService>().To<UserService>();
			Bind<ISegmentCategoryService>().To<SegmentCategoryService>();
			Bind<ISegmentService>().To<SegmentService>();
			Bind<IDatapointService>().To<DatapointService>();
			Bind<IAssumptionHeadcountService>().To<AssumptionHeadcountService>();
			Bind<ICommonService>().To<CommonService>();
			Bind<IWeeklyDatapointService>().To<WeeklyDatapointService>();
			Bind<IStaffSegmentService>().To<StaffSegmentService>();
			Bind<IStaffDatapointService>().To<StaffDatapointService>();
			Bind<IHiringDatapointService>().To<HiringDatapointService>();
			Bind<ISiteCampaignService>().To<SiteCampaignService>();
			Bind<ISiteCampaignLoBService>().To<SiteCampaignLoBService>();
			Bind<ISummaryDatapointService>().To<SummaryDatapointService>();
			Bind<IHiringOutlookService>().To<HiringOutlookService>();
			Bind<IExcessDeficitService>().To<ExcessDeficitService>();
			Bind<IDynamicFormulaService>().To<DynamicFormulaService>();
			Bind<ISiteCampaignLoBFormulaService>().To<SiteCampaignLoBFormulaService>();
			Bind<IUploadAHCService>().To<UploadAHCService>();
			Bind<IStagingWeeklyDatapointService>().To<StagingWeeklyDatapointService>();
			Bind<IErlangCSercvice>().To<ErlangCSercvice>();
		}
	}
}