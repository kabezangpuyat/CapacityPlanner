using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface ISiteCampaignService
    {
        IQueryable<SiteCampaignViewModel> GetAll();
        List<SiteCampaignViewModel> GetAllSiteCampaignBySiteID( long siteID, bool? active );

        List<SiteCampaignViewModel> GetAllSiteCampaignByCampaignID( long campaignID, bool? active );

        List<SiteCampaignViewModel> GetAllSiteCampaignByLobID( long lobID, bool? active );

        SiteCampaignViewModel Get( long id, bool? active );

        SiteCampaignViewModel Create( SiteCampaignViewModel model );

        void Create( long campaignID, string siteIDs );

        void Deactivate( long campaignID );

        //void Delete( string siteIDs );
        //IQueryable<CampaignViewModel> GetAll();
        //List<CampaignViewModel> GetAllBySiteID( long siteID, bool? active );
        //CampaignViewModel GetByID( long id );
        //void Deactivate( long id, string ntLogin );
        //void Update( CampaignViewModel model );
        //CampaignViewModel Create( CampaignViewModel model );
    }
}
