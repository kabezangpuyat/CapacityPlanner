using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;

using WFMPCP.Data.Entities;

namespace WFMPCP.Core.Mappings
{
    public class SiteCampaignMapping : EntityTypeConfiguration<SiteCampaign>
    {
        public SiteCampaignMapping()
        {
            this.ToTable( "SiteCampaign" )
                .HasKey( x => x.ID );

            this.Property( x => x.ID ).HasColumnName( "ID" );
            this.Property( x => x.SiteID ).HasColumnName( "SiteID" );
            this.Property( x => x.CampaignID ).HasColumnName( "CampaignID" );
            this.Property( x => x.Active ).HasColumnName( "Active" );

            //Site 
            this.HasRequired( x => x.Site )
                .WithMany( x => x.SiteCampaigns )
                .HasForeignKey( x => x.SiteID );

            //Campaign
            this.HasRequired( x => x.Campaign )
                .WithMany( x => x.SiteCampaigns )
                .HasForeignKey( x => x.CampaignID );
        }
    }
}
