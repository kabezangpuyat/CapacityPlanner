using System;
using System.Data.Entity;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using System.Data.Entity.ModelConfiguration;
using System.Collections.Generic;

namespace WFMPCP.Website.Models
{
    #region ApplicationUser
    public class ApplicationUser : IUser<long> //IdentityUser
    {
        public long Id { get; set; }
        public string UserName { get; set; }
        public string EmployeeID { get; set; }
        //public string FullName { get; set; }
        public long RoleID { get; set; }
        
        public bool Active { get; set; }
        //public string Password { get; set; }
        //public string Email { get; set; }
        public async Task<ClaimsIdentity> GenerateUserIdentityAsync( UserManager<ApplicationUser, long> manager )
        {
            // Note the authenticationType must match the one defined in CookieAuthenticationOptions.AuthenticationType
            var userIdentity = await manager.CreateIdentityAsync( this, DefaultAuthenticationTypes.ApplicationCookie );
            // Add custom user claims here
            //userIdentity.AddClaim( new Claim( "RoleID", RoleID.ToString() ) );
            //userIdentity.AddClaim( new Claim( "FirstName", this.FirstName ) );
            //userIdentity.AddClaim( new Claim( "LastName", this.LastName ) );
            return userIdentity;
        }
    }
    #endregion

    #region ApplicationDbContext & UserMapping
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext() : base( "WFMPCP.Connection" ) { }
        public ApplicationDbContext( string connectionString ) : base( connectionString ) { }
        protected override void OnModelCreating( DbModelBuilder modelBuilder )
        {
            modelBuilder.Configurations.Add( new UserMapping() );
            base.OnModelCreating( modelBuilder );
        }

        public DbSet<ApplicationUser> ApplicationUsers { get; set; }
    }

    public class UserMapping : EntityTypeConfiguration<ApplicationUser>
    {
        public UserMapping()
        {
            this.ToTable( "UserRole" );
            this.HasKey( x => x.Id ).Property( x => x.Id ).HasColumnName( "ID" );
            this.Property( x => x.UserName ).HasColumnName( "NTLogin" );
            this.Property( x => x.EmployeeID ).HasColumnName( "EmployeeID" );
            this.Property( x => x.Active ).HasColumnName( "Active" );
            this.Property( x => x.RoleID ).HasColumnName( "RoleID" );
        }
    }
    #endregion

    #region ApplicationUserStore
    public class ApplicationUserStore : IUserStore<ApplicationUser, long>, IUserPasswordStore<ApplicationUser, long>
        , IUserLoginStore<ApplicationUser, long>
    {
        private ApplicationDbContext _dbContext;

        public ApplicationUserStore()
        {
            _dbContext = new ApplicationDbContext();
        }

        public Task UpdateAsync( ApplicationUser user )
        {
            throw new NotImplementedException();
        }

        public void Dispose()
        {
            _dbContext.Dispose();
        }

        public Task CreateAsync( ApplicationUser user )
        {
            throw new NotImplementedException();
        }

        public Task DeleteAsync( ApplicationUser user )
        {
            throw new NotImplementedException();
        }

        public async Task<ApplicationUser> FindByIdAsync( long userId )
        {
            ApplicationUser user = await _dbContext.ApplicationUsers
                .Where( x => x.Id == userId )
                .FirstOrDefaultAsync();
            return user;
        }
        public async Task<ApplicationUser> FindAsync( string username, string password )
        {
            //ApplicationUser user = new ApplicationUser()
            //{
            //    UserName = username,
            //    Password = password
            //};

            //return await Task.FromResult( user );
            //NOTE: Since authentication will be in Active directory, we just need to get data by employeeid
            ApplicationUser user = await _dbContext.ApplicationUsers
                .Where( x => x.UserName == username && x.EmployeeID == password )
                .FirstOrDefaultAsync();
            return user;
        }
        public async Task<ApplicationUser> FindByNameAsync( string userName )
        {
            ApplicationUser user = await _dbContext.ApplicationUsers
                .Where( x => x.UserName == userName )
                .FirstOrDefaultAsync();
            return user;
            //throw new NotImplementedException();
        }

        public Task<string> GetPasswordHashAsync( ApplicationUser user )
        {
            if( user == null )
            {
                throw new ArgumentNullException( "user is null" );
            }
            PasswordHasher hasher = new PasswordHasher();
            return Task.FromResult( hasher.HashPassword( user.EmployeeID ) );
        }

        public Task<bool> HasPasswordAsync( ApplicationUser user )
        {
            return Task.FromResult( user.EmployeeID != null );
        }

        public Task SetPasswordHashAsync( ApplicationUser user, string passwordHash )
        {
            throw new NotImplementedException();
        }

        public Task AddLoginAsync( ApplicationUser user, UserLoginInfo login )
        {
            throw new NotImplementedException();
        }

        public Task RemoveLoginAsync( ApplicationUser user, UserLoginInfo login )
        {
            throw new NotImplementedException();
        }

        public Task<IList<UserLoginInfo>> GetLoginsAsync( ApplicationUser user )
        {
            throw new NotImplementedException();
        }

        public async Task<ApplicationUser> FindAsync( UserLoginInfo login )
        {
            ApplicationUser user = await _dbContext.ApplicationUsers
                .Where( x => x.UserName == login.LoginProvider && x.EmployeeID == login.ProviderKey )
                .FirstOrDefaultAsync();
            return user;
        }
    }
    #endregion
}