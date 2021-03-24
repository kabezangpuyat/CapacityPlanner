using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface ISegmentCategoryService
    {
        IQueryable<SegmentCategoryViewModel> GetAll();
        SegmentCategoryViewModel GetByID( int id );
        void Deactivate( int id, string ntLogin );
        void Update( SegmentCategoryViewModel model );
        SegmentCategoryViewModel Create( SegmentCategoryViewModel model );
    }
}
