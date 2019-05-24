using System.Linq;
using CityRide.Database.Models;
using Dapper;

namespace CityRide.Database.Repositories
{
    public class UserRepository : DapperRepository
    {
        public UserRepository()
        {
            Connection.Open();
        }

        public UserModel GetUser(int userId)
        {
            // var wozConfs = Connection.Query<string>("BEGIN return_text(); END;", CommandType.StoredProcedure);
            //var wozConfs = Connection.Query<string>("select city_ride_package.get_next_id('USERS') from dual");
            var wozConfs = Connection.Query<UserModel>($"SELECT * FROM USERS WHERE id = {userId}");

            return wozConfs.ToList().FirstOrDefault();
        }
    }
}