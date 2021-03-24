using System;
using System.Linq;
using WFMPCP.ICore;
using WFMPCP.IService;
using WFMPCP.Model;

namespace WFMPCP.Service
{
	public class SegmentService : ISegmentService
	{
		private readonly IWFMPCPContext _context;

		#region Constructor(s)

		public SegmentService(IWFMPCPContext context)
		{
			this._context = context;
		}

		#endregion Constructor(s)

		#region Method(s)

		public IQueryable<SegmentViewModel> GetAll()
		{
			var data = _context.AsQueryable<Data.Entities.Segment>()
				.Select(x => new SegmentViewModel()
				{
					ID = x.ID,
					SegmentCategoryID = (int)x.SegmentCategoryID,
					Name = x.Name,
					SortOrder = x.SortOrder,
					CreatedBy = x.CreatedBy,
					ModifiedBy = x.ModifiedBy,
					DateCreated = x.DateCreated,
					DateModified = x.DateModified,
					Active = x.Active,
					Visible = x.Visible,

					#region SegmentCategoryVM

					SegmentCategoryVM = x.SegmentCategoryID == null ? null : new SegmentCategoryViewModel()
					{
						ID = x.SegmentCategory.ID,
						Name = x.SegmentCategory.Name,
						SortOrder = x.SegmentCategory.SortOrder,
						CreatedBy = x.SegmentCategory.CreatedBy,
						ModifiedBy = x.SegmentCategory.ModifiedBy,
						DateCreated  = x.SegmentCategory.DateCreated,
						DateModified = x.SegmentCategory.DateModified,
						Active = x.SegmentCategory.Active,
						Visible = x.SegmentCategory.Visible
					}

					#endregion SegmentCategoryVM
				}).AsQueryable();

			return data;
		}

		public IQueryable<SegmentViewModel> GetAll(bool? active, bool? visible)
		{
			return this.GetAll().Where(x => ((x.Active == active) || (active == null)) && ((x.Visible == visible) || (visible == null))).AsQueryable();
		}

		public SegmentViewModel GetByID(long id)
		{
			return this.GetByID(id, null, null);
		}

		public SegmentViewModel GetByID(long id, bool? active, bool? visible)
		{
			return this.GetAll(active, visible).Where(x => x.ID == id).FirstOrDefault();
		}

		public void Deactivate(long id, string ntLogin)
		{
			var data = _context.AsQueryable<Data.Entities.Segment>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Active = false;
			data.DateModified = DateTime.Now;
			data.ModifiedBy = ntLogin;

			_context.Update<Data.Entities.Segment>(data);
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

		public void Update(SegmentViewModel model)
		{
			var data = _context.AsQueryable<Data.Entities.Segment>().Where(x => x.ID == model.ID).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			//check if lob already exists
			if (data.Name != model.Name || data.SegmentCategoryID != model.SegmentCategoryID)
			{
				var dataExists = _context.AsQueryable<Data.Entities.Segment>().Where(x => x.Name == model.Name && x.SegmentCategoryID == model.SegmentCategoryID && x.Active == true).FirstOrDefault();
				if (dataExists != null)
					throw new ArgumentException("Segment name already exists in Segment Category.");
			}

			data.Name = model.Name ?? data.Name;
			data.SegmentCategoryID = model.SegmentCategoryID;
			data.SortOrder = model.SortOrder ?? data.SortOrder;
			data.ModifiedBy = model.ModifiedBy;
			data.DateModified = model.DateModified ?? DateTime.Now;
			data.Active = model.Active ?? data.Active;
			data.Visible = model.Visible ?? data.Visible;

			_context.Update<Data.Entities.Segment>(data);
			_context.SaveChanges();
		}

		public SegmentViewModel Create(SegmentViewModel model)
		{
			var dataExists = _context.AsQueryable<Data.Entities.Segment>().Where(x => x.Name == model.Name && x.Active == true && x.SegmentCategoryID == model.SegmentCategoryID).FirstOrDefault();
			if (dataExists != null)
				throw new ArgumentException("Segment name already exists in segment category.");

			var sortOrder = 0;
			var lastData = _context.AsQueryable<Data.Entities.Segment>().Where(x => x.Active == true && x.SegmentCategoryID == model.SegmentCategoryID).OrderByDescending(x => x.SortOrder).FirstOrDefault();
			if (lastData != null)
				sortOrder = lastData.SortOrder + 1;

			var data = new Data.Entities.Segment()
			{
				Name = model.Name,
				SegmentCategoryID = model.SegmentCategoryID,
				SortOrder = sortOrder,
				CreatedBy = model.CreatedBy,
				ModifiedBy = null,
				DateCreated = model.DateCreated ?? DateTime.Now,
				DateModified = null,
				Active = model.Active ?? true,
				Visible = model.Visible ?? true
			};

			_context.Add<Data.Entities.Segment>(data);
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
			var data = _context.AsQueryable<Data.Entities.Segment>().Where(x => x.ID == id).FirstOrDefault();
			if (data == null)
				throw new ArgumentException("Data does not exists.");

			data.Visible = visible;
			data.DateModified = DateTime.Now;
			data.ModifiedBy = ntLogin;

			_context.Update<Data.Entities.Segment>(data);
			_context.SaveChanges();
		}

		#endregion Private
	}
}