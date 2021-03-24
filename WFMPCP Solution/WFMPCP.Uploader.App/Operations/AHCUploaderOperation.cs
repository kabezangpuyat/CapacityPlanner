using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
//using Newtonsoft.Json;
using Ninject;
using WFMPCP.IService;
using WFMPCP.Service;
using WFMPCP.Uploader.App.IoC;

namespace WFMPCP.Uploader.App.Operations
{
    public class AHCUploaderOperation
    {
        private readonly IUploadAHCService _uploaderSvc;
        private readonly IStagingWeeklyDatapointService _weeklyDatapointService;
        private readonly IAssumptionHeadcountService _ahcService;
		private readonly IErlangCSercvice _erlangService;

        public AHCUploaderOperation()
        {
            IKernel kernel = new StandardKernel( new WFMNinjectModule() );
            _uploaderSvc = kernel.Get<UploadAHCService>();
            _weeklyDatapointService = kernel.Get<StagingWeeklyDatapointService>();
            _ahcService = kernel.Get<AssumptionHeadcountService>();
			_erlangService = kernel.Get<ErlangCSercvice>();
        }

        public bool Upload( string fileName, string origFileName, string column, int columns )
        {
            return _uploaderSvc.ExcelRead( fileName, column, columns );
        }

		public bool UploadCSV(string filelocation, string ntlogin)
		{
			return _uploaderSvc.ExtractCSV(filelocation, ntlogin);
		}

		public Model.ErlangCViewModel CalculateErlang(long numberOfCalls, long ahtInSeconds, decimal requiredServiceLevel, long targetAnswerTimeInSeconds, long shrinkage)
		{
			return _erlangService.Calculate(numberOfCalls, ahtInSeconds, requiredServiceLevel, targetAnswerTimeInSeconds, shrinkage);
		}
    }
}
