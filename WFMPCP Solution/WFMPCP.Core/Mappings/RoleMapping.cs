using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;

using WFMPCP.Data.Entities;

namespace WFMPCP.Core.Mappings
{
    public class RoleMapping : EntityTypeConfiguration<Role>
    {
        public RoleMapping()
        {
            this.ToTable( "Role" )
                .HasKey( x => x.ID );

            this.Property( p => p.ID ).HasColumnName( "ID" );
            this.Property( p => p.Name ).HasColumnName( "Name" );
            this.Property( p => p.Code ).HasColumnName( "Code" );
            this.Property( p => p.Description ).HasColumnName( "Description" );
            this.Property( p => p.CreatedBy ).HasColumnName( "CreatedBy" );
            this.Property( p => p.ModifiedBy ).HasColumnName( "ModifiedBy" );
            this.Property( p => p.DateCreated ).HasColumnName( "DateCreated" );
            this.Property( p => p.DateModified ).HasColumnName( "DateModified" ).IsOptional();
            this.Property( p => p.Active ).HasColumnName( "Active" );
        }
    }
}
