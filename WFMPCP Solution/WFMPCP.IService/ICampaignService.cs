using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface ICampaignService
    {
        IQueryable<CampaignViewModel> GetAll();
        List<CampaignViewModel> GetAllBySiteID( long siteID, bool? active );
        CampaignViewModel GetByID( long id );
        void Deactivate( long id, string ntLogin );
        void Update( CampaignViewModel model );
        CampaignViewModel Create( CampaignViewModel model );
    }
}
