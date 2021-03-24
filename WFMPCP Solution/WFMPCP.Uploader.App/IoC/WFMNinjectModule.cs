
using Ninject.Modules;
using WFMPCP.Core;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Service;

namespace WFMPCP.Uploader.App.IoC
{
    public class WFMNinjectModule : NinjectModule
    {
        public override void Load()
        {
            Bind( typeof(IWFMPCPContext) ).To( typeof( WFMPCPContext ) ).InSingletonScope();
            Bind( typeof( IUploadAHCService ) ).To( typeof( UploadAHCService ) ).InSingletonScope();
            Bind( typeof( IStagingWeeklyDatapointService ) ).To( typeof( StagingWeeklyDatapointService ) ).InSingletonScope();
            Bind( typeof( IAssumptionHeadcountService ) ).To( typeof( AssumptionHeadcountService ) ).InSingletonScope();
			Bind(typeof(IErlangCSercvice)).To(typeof(ErlangCSercvice)).InSingletonScope();
		}
    }
}
