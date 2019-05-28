using System.Collections;
using System.Collections.Generic;
using System.Linq;
using CityRide.Database.Models;
using Dapper;

namespace CityRide.Database.Repositories
{
    public class StatisticRepository : DapperRepository
    {
        public StatisticRepository()
        {
            Connection.Open();
        }

        public ICollection<IssueModel> GetAllIssues()
        {
            var result = Connection.Query<IssueModel>($"SELECT * FROM ISSUES");

            return result.ToList();
        }

        public ICollection<BicycleModel> GetAllBicycle()
        {
            var result = Connection.Query<BicycleModel>($"SELECT * FROM BICYCLES");

            return result.ToList();
        }

        public ICollection<BicycleModel> GetAllBicycleByStatus(string status)
        {
            var result = Connection.Query<BicycleModel>($"SELECT * FROM BICYCLES where status = \'{status}\'");

            return result.ToList();
        }
    }
}
