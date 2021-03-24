using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;

using WFMPCP.Data.Entities;

namespace WFMPCP.Core.Mappings
{
    public class ModuleMapping : EntityTypeConfiguration<Module>
    {
        public ModuleMapping()
        {
            this.ToTable( "Module" )
                .HasKey( x => x.ID );

            this.Property( p => p.ID ).HasColumnName( "ID" );
            this.Property( p => p.ParentID ).HasColumnName( "ParentID" );
            this.Property( p => p.Name ).HasColumnName( "Name" );
            this.Property( p => p.Route ).HasColumnName( "Route" );
			this.Property( p => p.MenuIcon).HasColumnName("MenuIcon");
			this.Property(p => p.FontAwesome).HasColumnName("FontAwesome");
			this.Property( p => p.SortOrder ).HasColumnName( "SortOrder" );
            this.Property( p => p.CreatedBy ).HasColumnName( "CreatedBy" );
            this.Property( p => p.ModifiedBy ).HasColumnName( "ModifiedBy" );
            this.Property( p => p.DateCreated ).HasColumnName( "DateCreated" );
            this.Property( p => p.DateModified ).HasColumnName( "DateModified" ).IsOptional();
            this.Property( p => p.Active ).HasColumnName( "Active" );
        }
    }
}
