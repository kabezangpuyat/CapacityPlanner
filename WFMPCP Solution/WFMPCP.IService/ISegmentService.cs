using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface ISegmentService
    {
        IQueryable<SegmentViewModel> GetAll();
        IQueryable<SegmentViewModel> GetAll(bool? active, bool? visible);
        SegmentViewModel GetByID( long id );
        SegmentViewModel GetByID( long id, bool? active, bool? visible );
        void Deactivate( long id, string ntLogin );
        void Hide( long id, string ntLogin );

        void Show( long id, string ntLogin );
        void Update( SegmentViewModel model );
        SegmentViewModel Create( SegmentViewModel model );
    }
}
