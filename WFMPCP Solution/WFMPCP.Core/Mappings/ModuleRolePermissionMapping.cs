using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;

using WFMPCP.Data.Entities;

namespace WFMPCP.Core.Mappings
{
    public class ModuleRolePermissionMapping : EntityTypeConfiguration<ModuleRolePermission>
    {
        public ModuleRolePermissionMapping()
        {
            this.ToTable( "ModuleRolePermission" )
                .HasKey( x => x.ID );

            this.Property( p => p.ModuleID ).HasColumnName( "ModuleID" );
            this.Property( p => p.RoleID ).HasColumnName( "RoleID" );
            this.Property( p => p.PermissionID ).HasColumnName( "PermissionID" );
            this.Property( p => p.CreatedBy ).HasColumnName( "CreatedBy" );
            this.Property( p => p.ModifiedBy ).HasColumnName( "ModifiedBy" );
            this.Property( p => p.DateCreated ).HasColumnName( "DateCreated" );
            this.Property( p => p.DateModified ).HasColumnName( "DateModified" ).IsOptional();
            this.Property( p => p.Active ).HasColumnName( "Active" );

            //module mappping
            this.HasRequired( x => x.Module )
                .WithMany( x => x.ModuleRoleFunctions )
                .HasForeignKey( x => x.ModuleID );

            //role mapping
            this.HasRequired( x => x.Role )
                .WithMany( x => x.ModuleRoleFunctions )
                .HasForeignKey( x => x.RoleID );

            //functionality mapping
            this.HasRequired( x => x.Permission )
                .WithMany( x => x.ModuleRolePermission )
                .HasForeignKey( x => x.PermissionID );

        }
    }
}

