using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WFMPCP.Model;

namespace WFMPCP.IService
{
    public interface ISiteCampaignLoBService
    {
        IQueryable<SiteCampaignLoBViewModel> GetAll();
        List<SiteCampaignLoBViewModel> GetAllLoBBySiteCampaign( long siteID, long campaignID, bool? active );
        int Count( long? siteID, long campaignID, string lobName, bool? active );
        int Count( long? siteID, long campaignID, long lobid, bool? active );
        SiteCampaignLoBViewModel Create( SiteCampaignLoBViewModel model );
        void Update( SiteCampaignLoBViewModel model );

        void Create( long lobID, long siteID, long campaignID );
        void Deactivate( long lobID );
    }
}
