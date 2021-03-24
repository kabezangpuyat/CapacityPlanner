using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IStaffDatapointService
    {
        IQueryable<StaffDatapointViewModel> GetAll();
        IQueryable<StaffDatapointViewModel> GetAll(bool? active, bool? visible);
        StaffDatapointViewModel GetByID( long id );
        StaffDatapointViewModel GetByID( long id, bool? active, bool? visible );
        void Deactivate( long id, string ntLogin );
        void Hide( long id, string ntLogin );

        void Show( long id, string ntLogin );
        void Update( StaffDatapointViewModel model );
        StaffDatapointViewModel Create( StaffDatapointViewModel model );
    }
}
