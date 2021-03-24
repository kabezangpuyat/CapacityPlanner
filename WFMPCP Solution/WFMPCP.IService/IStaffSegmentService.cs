using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IStaffSegmentService
    {
        IQueryable<StaffSegmentViewModel> GetAll();
        IQueryable<StaffSegmentViewModel> GetAll(bool? active, bool? visible);
        StaffSegmentViewModel GetByID( long id );
        StaffSegmentViewModel GetByID( long id, bool? active, bool? visible );
        void Deactivate( long id, string ntLogin );
        void Hide( long id, string ntLogin );

        void Show( long id, string ntLogin );
        void Update( StaffSegmentViewModel model );
        StaffSegmentViewModel Create( StaffSegmentViewModel model );
    }
}
