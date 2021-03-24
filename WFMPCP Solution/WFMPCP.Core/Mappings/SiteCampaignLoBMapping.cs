using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;

using WFMPCP.Data.Entities;

namespace WFMPCP.Core.Mappings
{
    public class SiteCampaignLoBMapping : EntityTypeConfiguration<SiteCampaignLoB>
    {
        public SiteCampaignLoBMapping()
        {
            this.ToTable( "SiteCampaignLoB" )
                .HasKey( x => x.ID );

            this.Property( x => x.ID ).HasColumnName( "ID" );
            this.Property( x => x.SiteID ).HasColumnName( "SiteID" );
            this.Property( x => x.CampaignID ).HasColumnName( "CampaignID" );
            this.Property( x => x.LoBID ).HasColumnName( "LobID" );
            this.Property( x => x.Active ).HasColumnName( "Active" );

            //Site 
            this.HasRequired( x => x.Site )
                .WithMany( x => x.SiteCampaignLoBs )
                .HasForeignKey( x => x.SiteID );

            //Campaign
            this.HasRequired( x => x.Campaign )
                .WithMany( x => x.SiteCampaignLoBs )
                .HasForeignKey( x => x.CampaignID );

            //Lob
            this.HasRequired( x => x.LoB )
                .WithMany( x => x.SiteCampaignLoBs )
                .HasForeignKey( x => x.LoBID );
        }
    }
}
