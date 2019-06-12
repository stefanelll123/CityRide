using System.Data;
using Oracle.ManagedDataAccess.Client;

namespace CityRide.Database
{
    public abstract class DapperRepository
    {
        private const string DbConnectionString =
            @"User Id=CITYRIDE;Password=CITYRIDE;Data Source=10.20.0.14:1521/ORCL;";

        internal IDbConnection Connection => new OracleConnection(DbConnectionString);
    }
}
