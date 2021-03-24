using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;

using WFMPCP.Data.Entities;

namespace WFMPCP.Core.Mappings
{
    public class WeeklyDatapointLogMapping : EntityTypeConfiguration<WeeklyDatapointLog>
    {
        public WeeklyDatapointLogMapping()
        {
            this.ToTable( "WeeklyAHDatapointLog" );

            this.Property( x => x.ID ).HasColumnName( "ID" );
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
            this.Property( x => x.DateEntered ).HasColumnName( "DateEntered" ).IsOptional();

            //campaign mapping
            this.HasOptional( x => x.Campaign )
                .WithMany( x => x.WeeklyDatapointLogs )
                .HasForeignKey( x => x.CampaignID );

            //lob mapping
            this.HasOptional( x => x.LoB )
                .WithMany( x => x.WeeklyDatapointLogs )
                .HasForeignKey( x => x.LoBID );

            //datapoint mapping
            this.HasRequired( x => x.Datapoint )
                .WithMany( x => x.WeeklyDatapointLogs )
                .HasForeignKey( x => x.DatapointID );
        }
    }
}
