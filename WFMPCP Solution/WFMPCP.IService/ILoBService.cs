using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface ILoBService
    {
        IQueryable<LoBViewModel> GetAll();
        List<LoBViewModel> GetAllByCampaignID( long campaignID, bool? active );
        LoBViewModel GetByID( long id );
        void Deactivate( long id, string ntLogin );
        void Update( LoBViewModel model );
        void CreateWeeklyDatapoints( long siteID, long campaignID, long lobID );

        LoBViewModel Create( LoBViewModel model );
    }
}
