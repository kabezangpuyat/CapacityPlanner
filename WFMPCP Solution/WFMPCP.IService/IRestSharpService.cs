using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using RestSharp;
namespace WFMPCP.IService
{
    public interface IRestSharpService
    {
        T Deserialize<T>( IRestResponse response ) where T : class;
        IRestResponse Response( string url, Method method );
        IRestResponse Response( string url, RestRequest request );
    }
}
