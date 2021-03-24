using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface IHiringDatapointService
    {
        IQueryable<HiringDatapointViewModel> GetAll();
        IQueryable<HiringDatapointViewModel> GetAll(bool? active, bool? visible);
        HiringDatapointViewModel GetByID( long id );
        HiringDatapointViewModel GetByID( long id, bool? active, bool? visible );
        
        void Deactivate( long id, string ntLogin );
        void Hide( long id, string ntLogin );

        void Show( long id, string ntLogin );
        void Update( HiringDatapointViewModel model );
        HiringDatapointViewModel Create( HiringDatapointViewModel model );
    }
}
