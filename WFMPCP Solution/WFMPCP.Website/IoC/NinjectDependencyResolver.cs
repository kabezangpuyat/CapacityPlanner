using Ninject;
using System.Web.Http.Dependencies;

namespace WFMPCP.Website.IoC
{
	public class NinjectDependencyResolver : NinjectDependencyScope
		, System.Web.Http.Dependencies.IDependencyResolver
		, System.Web.Mvc.IDependencyResolver
	{
		public readonly IKernel _kernel;

		public NinjectDependencyResolver(IKernel kernel)
			: base(kernel)
		{
			_kernel = kernel;
		}

		public IDependencyScope BeginScope()
		{
			return new NinjectDependencyScope(_kernel.BeginBlock());
		}
	}
}