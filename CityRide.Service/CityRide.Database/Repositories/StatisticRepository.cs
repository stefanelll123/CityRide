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

        public ICollection<IssueModel> GetBicyclesIssues(int bicycleId)
        {
            var issueList = new List<IssueModel>();
            try
            {
                var issues =
                    Connection.Query<int>($"SELECT * FROM TABLE(get_bicycle_problems_reported({bicycleId}))");

                foreach (var id in issues)
                {
                    var result = Connection.QueryFirst<IssueModel>(
                        $"select * from issues where id = {id}");

                    issueList.Add(result);
                }
            }
            catch
            {
                return issueList;
            }

            return issueList;
        }

        public ICollection<BorrowHistoryModel> GetUserBorrowHistory(int userId)
        {
            var issueList = new List<BorrowHistoryModel>();
            try
            {
                issueList =
                    Connection.Query<BorrowHistoryModel>($"SELECT b.*, p.value || \' pe ora\' as price from borrow b join prices p on b.price_id = p.id where b.user_id = {userId} order by b.end_date").ToList();
            }
            catch
            {
                return issueList;
            }

            return issueList;
        }

        public ICollection<PriceHistoryModel> GetPriceHistory(DateTime startDate, DateTime endDate)
        {
            var pricesList = new List<PriceHistoryModel>();
            try
            {
                pricesList =
                    Connection.Query<PriceHistoryModel>($"SELECT * from prices where start_date > TO_DATE(\'{startDate.ToString("yyyy/MM/dd")}\', 'yyyy/mm/dd') and end_date < TO_DATE(\'{endDate.ToString("yyyy/MM/dd")}\', 'yyyy/mm/dd')").ToList();
            }
            catch(Exception exception)
            {
                return pricesList;
            }

            return pricesList;
        }

        public ICollection<ValueblePickupPointModel> GetValueble()
        {
            var pricesList = new List<ValueblePickupPointModel>();
            try
            {
                Connection.Query($"begin find_most_valueble_points; end;");
                pricesList =
                    Connection.Query<ValueblePickupPointModel>($"SELECT * FROM (SELECT * from Valueable_pickup_points ORDER BY value DESC) WHERE ROWNUM < 5").ToList();
            }
            catch
            {
                return pricesList;
            }

            return pricesList;
        }
    }
}
