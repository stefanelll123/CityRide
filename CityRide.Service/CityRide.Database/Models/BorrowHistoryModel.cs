using System;

namespace CityRide.Database.Models
{
    public class BorrowHistoryModel
    {
        public int ID { get; set; }

        public int  BICYCLE_ID { get; set; }

        public DateTime BORROW_DATE { get; set; }

        public DateTime END_DATE { get; set; }

        public string PRICE { get; set; }
    }
}
