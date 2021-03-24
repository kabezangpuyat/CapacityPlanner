using System.Data;
using System.Linq;
using WFMPCP.Data.Entities;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
    public class StagingWeeklyDatapointService : IStagingWeeklyDatapointService
    {
        private readonly IWFMPCPContext _context;
       
        #region Constructor(s)
        public StagingWeeklyDatapointService(IWFMPCPContext context )
        {
            this._context = context;
        }

        #endregion

        #region IWeeklyDatapointService
        public IQueryable<WeeklyDatapointViewModel> GetAll()
        {
            var data = _context.AsQueryable<StagingWeeklyDatapoint>()
                        .Select( x => new WeeklyDatapointViewModel()
                        {
                            ID = x.ID,
                            CampaignID = x.CampaignID,
                            LoBID = x.LoBID,
                            DatapointID = x.DatapointID,
                            Week = x.Week,
                            Data = x.Data,
                            //Datatype = x.Datatype,
                            Date = x.Date,
                            CreatedBy = x.CreatedBy,
                            ModifiedBy  = x.ModifiedBy,
                            DateCreated = x.DateCreated,
                            DateModified = x.DateModified,
                            //#region CampaignVM
                            //CampaignVM = x.CampaignID == null ? null : new CampaignViewModel ()
                            //{
                            //    ID = x.Campaign.ID,
                            //    SiteID = x.Campaign.SiteID,
                            //    Name = x.Campaign.Name,
                            //    Code = x.Campaign.Code,
                            //    Description = x.Campaign.Description,
                            //    CreatedBy = x.Campaign.CreatedBy,
                            //    ModifiedBy = x.Campaign.ModifiedBy,
                            //    DateCreated = x.Campaign.DateCreated,
                            //    DateModified = x.Campaign.DateModified,
                            //    Active = x.Campaign.Active,
                            //    #region SiteVM 
                            //    SiteVM = new SiteViewModel()
                            //    {
                            //        ID = x.Campaign.Site.ID,
                            //        Name = x.Campaign.Site.Name,
                            //        Code = x.Campaign.Site.Code,
                            //        Description = x.Campaign.Site.Description,
                            //        CreatedBy = x.Campaign.Site.CreatedBy,
                            //        ModifiedBy = x.Campaign.Site.ModifiedBy,
                            //        DateCreated = x.Campaign.Site.DateCreated,
                            //        DateModified = x.Campaign.Site.DateModified,
                            //        Active = x.Campaign.Site.Active
                            //    }
                            //    #endregion
                            //},
                            //#endregion
                            //#region LobVM
                            //LoBVM = x.LoBID == null ? null : new LoBViewModel()
                            //{
                            //    ID = x.LoB.ID,
                            //    CampaignID = x.LoB.CampaignID,
                            //    Name = x.LoB.Name,
                            //    Code = x.LoB.Code,
                            //    Description = x.LoB.Description,
                            //    CreatedBy = x.LoB.CreatedBy,
                            //    ModifiedBy = x.LoB.ModifiedBy,
                            //    DateCreated = x.LoB.DateCreated,
                            //    DateModified = x.LoB.DateModified,
                            //    Active = x.LoB.Active,
                            //    #region CampaignVM
                            //    CampaignVM = new CampaignViewModel()
                            //    {
                            //        ID = x.LoB.Campaign.ID,
                            //        SiteID = x.LoB.Campaign.SiteID,
                            //        Name = x.LoB.Campaign.Name,
                            //        Code = x.LoB.Campaign.Code,
                            //        Description = x.LoB.Campaign.Description,
                            //        CreatedBy = x.LoB.Campaign.CreatedBy,
                            //        ModifiedBy = x.LoB.Campaign.ModifiedBy,
                            //        DateCreated = x.LoB.Campaign.DateCreated,
                            //        DateModified = x.LoB.Campaign.DateModified,
                            //        Active = x.LoB.Campaign.Active,
                            //        #region SiteVM 
                            //        SiteVM = new SiteViewModel()
                            //        {
                            //            ID = x.LoB.Campaign.Site.ID,
                            //            Name = x.LoB.Campaign.Site.Name,
                            //            Code = x.LoB.Campaign.Site.Code,
                            //            Description = x.LoB.Campaign.Site.Description,
                            //            CreatedBy = x.LoB.Campaign.Site.CreatedBy,
                            //            ModifiedBy = x.LoB.Campaign.Site.ModifiedBy,
                            //            DateCreated = x.LoB.Campaign.Site.DateCreated,
                            //            DateModified = x.LoB.Campaign.Site.DateModified,
                            //            Active = x.LoB.Campaign.Site.Active
                            //        }
                            //        #endregion
                            //    }
                            //    #endregion
                            //},
                            //#endregion
                            //#region DatapointVM
                            //DatapointVM = new DatapointViewModel()
                            //{
                            //    ID = x.Datapoint.ID,
                            //    SegmentID = x.Datapoint.SegmentID,
                            //    Name = x.Datapoint.Name,
                            //    SortOrder = x.Datapoint.SortOrder,
                            //    CreatedBy = x.Datapoint.CreatedBy,
                            //    ModifiedBy = x.Datapoint.ModifiedBy,
                            //    DateCreated = x.Datapoint.DateCreated,
                            //    DateModified = x.Datapoint.DateModified,
                            //    Active = x.Datapoint.Active,
                            //    Visible = x.Datapoint.Visible,
                            //    #region DatapointCategoryVM
                            //    SegmentVM = new SegmentViewModel()
                            //    {
                            //        ID = x.Datapoint.Segment.ID,
                            //        Name = x.Datapoint.Segment.Name,
                            //        SortOrder = x.Datapoint.Segment.SortOrder,
                            //        CreatedBy = x.Datapoint.Segment.CreatedBy,
                            //        ModifiedBy = x.Datapoint.Segment.ModifiedBy,
                            //        DateCreated = x.Datapoint.Segment.DateCreated,
                            //        DateModified = x.Datapoint.Segment.DateModified,
                            //        Active = x.Datapoint.Segment.Active,
                            //        Visible = x.Datapoint.Segment.Visible
                            //    }
                            //    #endregion
                            //}
                            //#endregion
                        } ).AsQueryable();

            return data;
        }

        public void Save( WeeklyDatapointViewModel model )
        {
            //check data if exists
            var orig = _context.AsQueryable<StagingWeeklyDatapoint>()
                .Where( x => x.Date == model.Date && x.DatapointID == model.DatapointID
                        && x.SiteID == model.SiteID && x.CampaignID == model.CampaignID && x.LoBID == model.LoBID )
                .FirstOrDefault();

            StagingWeeklyDatapoint data = new StagingWeeklyDatapoint();

            if( orig != null)
            {
                orig.Data = model.Data;
                orig.ModifiedBy = model.ModifiedBy;
                orig.DateModified = model.DateModified;

                _context.Update<StagingWeeklyDatapoint>( orig );
                _context.SaveChanges();
            }
            else
            {
                data = new StagingWeeklyDatapoint()
                {
                    SiteID = model.SiteID,
                    CampaignID = model.CampaignID,
                    LoBID = model.LoBID,
                    DatapointID = model.DatapointID,
                    Week = model.Week,
                    Data = model.Data,
                    Date = model.Date,
                    CreatedBy = model.CreatedBy,
                    ModifiedBy = null,
                    DateCreated = model.DateCreated,
                    DateModified = null
                };

                _context.Add( data );
                _context.SaveChanges();
            }
            
        }
        #endregion
    }
}
