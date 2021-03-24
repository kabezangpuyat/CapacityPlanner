using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;

using WFMPCP.Data.Entities;

namespace WFMPCP.Core.Mappings
{
    public class StaffSegmentMapping : EntityTypeConfiguration<StaffSegment>
    {
        public StaffSegmentMapping()
        {
            this.ToTable( "StaffSegment" )
                .HasKey( x => x.ID );

            this.Property( x => x.ID ).HasColumnName( "ID" );
            this.Property( x => x.SegmentCategoryID ).HasColumnName( "SegmentCategoryID" ).IsOptional();
            this.Property( x => x.Name ).HasColumnName( "Name" );
            this.Property( x => x.SortOrder ).HasColumnName( "SortOrder" );
            this.Property( x => x.CreatedBy ).HasColumnName( "CreatedBy" );
            this.Property( x => x.ModifiedBy ).HasColumnName( "ModifiedBy" );
            this.Property( x => x.DateCreated ).HasColumnName( "DateCreated" );
            this.Property( x => x.DateModified ).HasColumnName( "DateModified" ).IsOptional();
            this.Property( x => x.Active ).HasColumnName( "Active" );
            this.Property( x => x.Visible ).HasColumnName( "Visible" );

            ////segment category mapping
            //this.HasOptional( x => x.SegmentCategory )
            //    .WithMany( x => x.Segments )
            //    .HasForeignKey( x => x.SegmentCategoryID );
        }
    }
}
