using System;
using System.Linq;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class DatapointService : IDatapointService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public DatapointService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region Method(s)

		public IQueryable<DatapointViewModel> GetAll()
		{
			var data = _context.AsQueryable<Data.Entities.Datapoint>()
				.Select(x => new DatapointViewModel()
				{
					ID = x.ID,
					SegmentID = x.SegmentID,
					//ReferenceID = x.ReferenceID,
					Name = x.Name,
					Datatype = x.Datatype,
					SortOrder = x.SortOrder,
					CreatedBy = x.CreatedBy,
					ModifiedBy = x.ModifiedBy,
					DateCreated = x.DateCreated,
					DateModified = x.DateModified,
					Active = x.Active,
					Visible = x.Visible,

					#region DatapointCategoryVM

					SegmentVM = new SegmentViewModel()
					{
						ID = x.Segment.ID,
						SegmentCategoryID = (int)x.Segment.SegmentCategoryID,
						Name = x.Segment.Name,
						SortOrder = x.Segment.SortOrder,
						CreatedBy = x.Segment.CreatedBy,
						ModifiedBy = x.Segment.ModifiedBy,
						DateCreated  = x.Segment.DateCreated,
						DateModified = x.Segment.DateModified,
						Active = x.Segment.Active,
						Visible = x.Segment.Visible,
						SegmentCategoryVM = new SegmentCategoryViewModel()
						{
							ID = x.Segment.SegmentCategory.ID,
							Name = x.Segment.SegmentCategory.Name,
							SortOrder = x.Segment.SegmentCategory.SortOrder,
							CreatedBy = x.Segment.SegmentCategory.CreatedBy,
							ModifiedBy = x.Segment.SegmentCategory.ModifiedBy,
							DateCreated = x.Segment.SegmentCategory.DateCreated,
							DateModified = x.Segment.SegmentCategory.DateModified,
							Active = x.Segment.SegmentCategory.Active,
							Visible = x.Segment.SegmentCategory.Visible,
						}
					}

					#endregion DatapointCategoryVM
				}).AsQueryable();

			return data;
		}

		public IQueryable<DatapointViewModel> GetAll(bool? active, bool? visible)
		{
			return this.GetAll().Where(x => ((x.Active == active) || (active == null)) && ((x.Visible == visible) || (visible == null))).AsQueryable();
		}

		public DatapointViewModel GetByID(long id)
		{
			return this.GetByID(id, null, null);
		}

		public DatapointViewModel GetByID(long id, bool? active, bool? visible)
		{
			return this.GetAll(active, visible).Where(x => x.ID == id).FirstOrDefault();
		}

		public void Deactivate(long id, string ntLogin)
		{
			var data = _context.AsQueryable<Data.Entities.Datapoint>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Active = false;
			data.DateModified = DateTime.Now;
			data.ModifiedBy = ntLogin;

			_context.Update<Data.Entities.Datapoint>(data);
			_context.SaveChanges();
		}

		public void Hide(long id, string ntLogin)
		{
			this.HideShow(id, false, ntLogin);
		}

		public void Show(long id, string ntLogin)
		{
			this.HideShow(id, true, ntLogin);
		}

		public void Update(DatapointViewModel model)
		{
			var data = _context.AsQueryable<Data.Entities.Datapoint>().Where(x => x.ID == model.ID).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			//check if lob already exists
			if (data.Name != model.Name || data.SegmentID != model.SegmentID)
			{
				var dataExists = _context.AsQueryable<Data.Entities.Datapoint>().Where(x => x.Name == model.Name && x.SegmentID == model.SegmentID && x.Active == true).FirstOrDefault();
				if (dataExists != null)
					throw new ArgumentException("Datapoint name already exists in Segment.");
			}

			data.Name = model.Name ?? data.Name;
			data.Datatype = model.Datatype ?? data.Datatype;
			data.SegmentID = model.SegmentID;
			data.SortOrder = model.SortOrder ?? data.SortOrder;
			data.ModifiedBy = model.ModifiedBy;
			data.DateModified = model.DateModified ?? DateTime.Now;
			data.Active = model.Active ?? data.Active;
			data.Visible = model.Visible ?? data.Visible;

			_context.Update<Data.Entities.Datapoint>(data);
			_context.SaveChanges();
		}

		public DatapointViewModel Create(DatapointViewModel model)
		{
			var dataExists = _context.AsQueryable<Data.Entities.Datapoint>().Where(x => x.Name == model.Name && x.Active == true && x.SegmentID == model.SegmentID).FirstOrDefault();
			if (dataExists != null)
				throw new ArgumentException("Datapoint name already exists in segment.");

			var sortOrder = 0;
			var lastData = _context.AsQueryable<Data.Entities.Datapoint>().Where(x => x.Active == true && x.SegmentID == model.SegmentID).OrderByDescending(x => x.SortOrder).FirstOrDefault();
			if (lastData != null)
				sortOrder = lastData.SortOrder + 1;

			var data = new Data.Entities.Datapoint()
			{
				Name = model.Name,
				Datatype = model.Datatype,
				SegmentID = model.SegmentID,
				SortOrder = sortOrder,
				CreatedBy = model.CreatedBy,
				ModifiedBy = null,
				DateCreated = model.DateCreated ?? DateTime.Now,
				DateModified = null,
				Active = model.Active ?? true,
				Visible = model.Visible ?? true
			};

			_context.Add<Data.Entities.Datapoint>(data);
			_context.SaveChanges();

			model.ID = data.ID;
			model.Active = data.Active;
			model.Visible = data.Visible;
			return model;
		}

		#endregion Method(s)

		#region Private

		private void HideShow(long id, bool visible, string ntLogin)
		{
			var data = _context.AsQueryable<Data.Entities.Datapoint>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Visible = visible;
			data.DateModified = DateTime.Now;
			data.ModifiedBy = ntLogin;

			_context.Update<Data.Entities.Datapoint>(data);
			_context.SaveChanges();
		}

		#endregion Private
	}
}