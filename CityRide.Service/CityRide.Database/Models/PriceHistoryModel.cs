using System;

namespace CityRide.Database.Models
{
    public class PriceHistoryModel
    {
        public int Value { get; set; }

        public DateTime Start_date { get; set; }

        public DateTime End_date { get; set; }
    }
}
