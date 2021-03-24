using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface ISummaryDatapointService
    {
        IQueryable<SummaryDatapointViewModel> GetAll();
        IQueryable<SummaryDatapointViewModel> GetAll(bool? active, bool? visible);
        SummaryDatapointViewModel GetByID( long id );
        SummaryDatapointViewModel GetByID( long id, bool? active, bool? visible );
        void Deactivate( long id, string ntLogin );
        void Hide( long id, string ntLogin );

        void Show( long id, string ntLogin );
        void Update( SummaryDatapointViewModel model );
        SummaryDatapointViewModel Create( SummaryDatapointViewModel model );
    }
}
