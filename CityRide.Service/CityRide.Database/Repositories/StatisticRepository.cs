using System;
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

        public bool FindOldBicycles()
        {
            var query = $"BEGIN city_ride_package.find_old_bicycles(); END;";
            Connection.Query(query);

            var succes =
                Connection.QueryFirst<bool>($"select count(*) from issues where DESCRIPTION like \'%batrana%\'");

            return succes;
        }

        public ICollection<IssueModel> GetOldBicyclesIssues()
        {
            try
            {
                var result =
                    Connection.Query<IssueModel>($"select * from issues where DESCRIPTION like \'%batrana%\'");

                return result.ToList();
            }
            catch
            {
                return new List<IssueModel>();
            }
        }

        public bool FindMaintananceBicycles()
        {
            var query = $"BEGIN city_ride_package.find_bicycles_maintenance(); END;";
            Connection.Query(query);

            var succes =
                Connection.QueryFirst<bool>($"select count(*) from issues where DESCRIPTION like \'%revizie%\'");

            return succes;
        }

        public ICollection<IssueModel> GetMaintananceBicyclesIssues()
        {
            try
            {
                var result =
                    Connection.Query<IssueModel>($"select * from issues where DESCRIPTION like \'%revizie%\'");

                return result.ToList();
            }
            catch
            {
                return new List<IssueModel>();
            }
        }

        public ICollection<OverdueModel> GetOverdueBicyclesIssues()
        {
            var overdueList = new List<OverdueModel>();
            try
            {
                var borrows =
                    Connection.Query<int>($"SELECT * FROM TABLE(find_overdue_borrows)");

                foreach (var borrow in borrows)
                {
                    var bicycleId = Connection.QueryFirst<int>($"select bicycle_id from BORROW where id = {borrow}");
                    var userId = Connection.QueryFirst<int>($"select user_id from BORROW where id = {borrow}");
                    var overdue = Connection.QueryFirst<OverdueModel>(
                        $"select b.*, u.first_name || ' ' || u.last_name as BorrowBy from bicycles b, users u where b.id = {bicycleId} and u.id = {userId}");

                    overdueList.Add(overdue);
                }
            }
            catch
            {
                return overdueList;
            }

            return overdueList;
        }
    }
}
