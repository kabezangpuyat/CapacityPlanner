using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;

using WFMPCP.Data.Entities;

namespace WFMPCP.Core.Mappings
{
    public class HiringDatapointMapping : EntityTypeConfiguration<HiringDatapoint>
    {
        public HiringDatapointMapping()
        {
            this.ToTable( "HiringDatapoint" )
                .HasKey( x => x.ID );

            this.Property( x => x.ID ).HasColumnName( "ID" );
            this.Property( x => x.SegmentID ).HasColumnName( "SegmentID" ).IsOptional();
            this.Property( x => x.ReferenceID ).HasColumnName( "ReferenceID" );
            this.Property( x => x.Name ).HasColumnName( "Name" );
            this.Property( x => x.Datatype ).HasColumnName( "Datatype" );
            this.Property( x => x.SortOrder ).HasColumnName( "SortOrder" );
            this.Property( x => x.CreatedBy ).HasColumnName( "CreatedBy" );
            this.Property( x => x.ModifiedBy ).HasColumnName( "ModifiedBy" );
            this.Property( x => x.DateCreated ).HasColumnName( "DateCreated" );
            this.Property( x => x.DateModified ).HasColumnName( "DateModified" ).IsOptional();
            this.Property( x => x.Active ).HasColumnName( "Active" );
            this.Property( x => x.Visible ).HasColumnName( "Visible" );

            //segment mapping
            //this.HasRequired( x => x.StaffSegment )
            //    .WithMany( x => x.StaffDatapoints )
            //    .HasForeignKey( x => x.SegmentID );
        }
    }
}
