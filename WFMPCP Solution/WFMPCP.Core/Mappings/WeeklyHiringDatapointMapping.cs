using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;

using WFMPCP.Data.Entities;

namespace WFMPCP.Core.Mappings
{
    public class WeeklyHiringDatapointMapping : EntityTypeConfiguration<WeeklyHiringDatapoint>
    {
        public WeeklyHiringDatapointMapping()
        {
            this.ToTable( "WeeklyHiringDatapoint" )
                .HasKey( x => x.ID );

            this.Property( x => x.ID ).HasColumnName( "ID" );
            this.Property( x => x.SiteID ).HasColumnName( "SiteID" ).IsOptional();
            this.Property( x => x.CampaignID ).HasColumnName( "CampaignID" ).IsOptional();
            this.Property( x => x.LoBID ).HasColumnName( "LoBID" ).IsOptional();
            this.Property( x => x.DatapointID ).HasColumnName( "DatapointID" );
            this.Property( x => x.Week ).HasColumnName( "Week" );
            this.Property( x => x.Data ).HasColumnName( "Data" );
            this.Property( x => x.Date ).HasColumnName( "Date" );
            this.Property( x => x.CreatedBy ).HasColumnName( "CreatedBy" );
            this.Property( x => x.ModifiedBy ).HasColumnName( "ModifiedBy" );
            this.Property( x => x.DateCreated ).HasColumnName( "DateCreated" );
            this.Property( x => x.DateModified ).HasColumnName( "DateModified" ).IsOptional();

            //site mapping
            this.HasOptional( x => x.Site )
                .WithMany( x => x.WeeklyHiringDatapoints )
                .HasForeignKey( x => x.SiteID );

            //campaign mapping
            this.HasOptional( x => x.Campaign )
                .WithMany( x => x.WeeklyHiringDatapoints )
                .HasForeignKey( x => x.CampaignID );

            //lob mapping
            this.HasOptional( x => x.LoB )
                .WithMany( x => x.WeeklyHiringDatapoints )
                .HasForeignKey( x => x.LoBID );

            //datapoint mapping
            this.HasRequired( x => x.HiringDatapoint )
                .WithMany( x => x.WeeklyHiringDatapoints )
                .HasForeignKey( x => x.DatapointID );
        }
    }
}
