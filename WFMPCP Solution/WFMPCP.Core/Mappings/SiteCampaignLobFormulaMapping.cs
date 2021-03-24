using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;

using WFMPCP.Data.Entities;

namespace WFMPCP.Core.Mappings
{
	public class SiteCampaignLobFormulaMapping : EntityTypeConfiguration<SiteCampaignLobFormula>
	{
		public SiteCampaignLobFormulaMapping()
		{
			this.ToTable("SiteCampaignLobFormula")
				.HasKey(x => x.ID);

			this.Property(x => x.ID).HasColumnName("ID");
			this.Property(x => x.SiteID).HasColumnName("SiteID");
			this.Property(x => x.CampaignID).HasColumnName("CampaignID");
			this.Property(x => x.LoBID).HasColumnName("LoBID");
			this.Property(x => x.DynamicFormulaID).HasColumnName("DynamicFormulaID");
			this.Property(x => x.Active).HasColumnName("Active");
			this.Property(x => x.DateCreated).HasColumnName("DateCreated");
			this.Property(x => x.DateModified).HasColumnName("DateModified");

			//Site 
			this.HasRequired(x => x.Site)
				.WithMany(x => x.SiteCampaignLoBFormulas)
				.HasForeignKey(x => x.SiteID);

			//Campaign
			this.HasRequired(x => x.Campaign)
				.WithMany(x => x.SiteCampaignLoBFormulas)
				.HasForeignKey(x => x.CampaignID);

			//Lob
			this.HasRequired(x => x.LoB)
				.WithMany(x => x.SiteCampaignLoBFormulas)
				.HasForeignKey(x => x.LoBID);

			//Dynamic Formula
			this.HasRequired(x => x.DynamicFormula)
				.WithMany(x => x.SiteCampaignLoBFormulas)
				.HasForeignKey(x => x.DynamicFormulaID);
		}
	}
}
