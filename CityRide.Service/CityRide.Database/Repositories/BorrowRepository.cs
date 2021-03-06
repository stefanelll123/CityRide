﻿using System;
using System.Linq;
using CityRide.Database.Models;
using Dapper;

namespace CityRide.Database.Repositories
{
    public class BorrowRepository : DapperRepository
    {
        public BorrowRepository()
        {
            Connection.Open();
        }

        public bool BorrowBicycle(BorrowModel borrowModel)
        {
            var alreadyExists = Connection.QueryFirst<bool>($"select CITY_RIDE_BORROW_PACKAGE.check_borrow_bicycle({borrowModel.UserId}, \'{borrowModel.QrCode}\') from dual");
            if (alreadyExists)
            {
                return false;
            }

            var query = $"BEGIN CITY_RIDE_BORROW_PACKAGE.borrow_bicycle({borrowModel.UserId}, \'{borrowModel.QrCode}\'); END;";
            Connection.Query(query);

            var result = Connection.QueryFirst<bool>($"select CITY_RIDE_BORROW_PACKAGE.check_borrow_bicycle({borrowModel.UserId}, \'{borrowModel.QrCode}\') from dual");

            return result;
        }

        public bool BicycleExists(int userId)
        {
            var exists = Connection.QueryFirst<bool>($"select count(*) from borrow where user_id = {userId} and end_date is null");

            return exists;
        }

        public int GetBorrowPrice(int userId)
        {
            try
            {
                var borrowId =
                    Connection.QueryFirst<int>(
                        $"select id from borrow where user_id = {userId} and end_date is null and rownum = 1");
                var price = Connection.QueryFirst<int>($"select city_ride_package.calculates_paid({borrowId}) from dual");

                return price;
            }
            catch (Exception e)
            {
                return -1;
            }
        }

        public bool ReturnBicycle(ReturnModel returnModel)
        {
            var query = $"BEGIN CITY_RIDE_BORROW_PACKAGE.return_bicycle({returnModel.UserId}, {returnModel.PointId}); END;";
            Connection.Query(query);

            var result = Connection.QueryFirst<bool>($"select CITY_RIDE_BORROW_PACKAGE.check_return_bicycle({returnModel.UserId}) from dual");

            return !result;
        }
    }
}