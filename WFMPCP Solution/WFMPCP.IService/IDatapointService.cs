using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IDatapointService
    {
        IQueryable<DatapointViewModel> GetAll();
        IQueryable<DatapointViewModel> GetAll(bool? active, bool? visible);
        DatapointViewModel GetByID( long id );
        DatapointViewModel GetByID( long id, bool? active, bool? visible );
        void Deactivate( long id, string ntLogin );
        void Hide( long id, string ntLogin );

        void Show( long id, string ntLogin );
        void Update( DatapointViewModel model );
        DatapointViewModel Create( DatapointViewModel model );
    }
}
