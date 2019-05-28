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
            var wozConfs = Connection.Query<UserModel>($"SELECT * FROM USERS WHERE id = {userId}");

            return wozConfs.ToList().FirstOrDefault();
        }

        public bool CreateUser(UserCreateModel user)
        {
            var alreadyExists = Connection.QueryFirst<bool>($"SELECT count(*) FROM USERS WHERE EMAIL = \'{user.Email}\'");
            if (alreadyExists)
            {
                return false;
            }

            var query = $"BEGIN city_ride_login_package.create_account(" +
                        $"\'{user.First_name}\'," +
                        $"\'{user.Last_name}\'," +
                        $"\'{user.Email}\'," +
                        $"\'{user.Cnp}\'," +
                        $"\'{user.Address}\'," +
                        $"\'{user.Password}\'," +
                        $"\'{user.CARD_NUMBER}\'," +
                        $"TO_DATE(\'{user.EXPIRATION_DATE.ToString("yyyy/MM/dd")}\', 'yyyy/mm/dd')," +
                        $"{user.CVV}" +
                        $"); END;";
            Connection.Query(query);
            var success = Connection.QueryFirst<bool>($"SELECT count(*) FROM USERS WHERE EMAIL = \'{user.Email}\'");

            return success;
        }

        public int Login(LoginModel loginModel)
        {
            var query = $"select city_ride_login_package.login(\'{loginModel.Email}\', \'{loginModel.Password}\') from dual";
            var result = Connection.QueryFirst<int>(query);

            return result;
        }
    }
}