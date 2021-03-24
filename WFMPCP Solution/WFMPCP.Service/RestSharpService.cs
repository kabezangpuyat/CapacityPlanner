using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using RestSharp;
using WFMPCP.IService;

namespace WFMPCP.Service
{
    public class RestSharpService : IRestSharpService
    {
        public T Deserialize<T>( IRestResponse response ) where T : class
        {
            RestSharp.Deserializers.JsonDeserializer deserial = new RestSharp.Deserializers.JsonDeserializer();
            T returnValue = deserial.Deserialize<T>( response );

            return returnValue;
        }

        public IRestResponse Response(string url, Method method)
        {
            var client = new RestClient( url );
            var request = new RestRequest( method );
            IRestResponse response = client.Execute( request );

            return response;
        }

        public IRestResponse Response( string url, RestRequest request )
        {
            var client = new RestClient( url );
            IRestResponse response = client.Execute( request );

            return response;
        }
    }
}
