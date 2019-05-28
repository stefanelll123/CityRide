using System;

namespace CityRide.Database.Models
{
    public class BicycleModel
    {
        public int ID { get; set;}

        public string QR_CODE { get; set; }

        public DateTime REGISTER_DATE { get; set; }

        public string STATUS { get; set; }

        public int POINT_ID { get; set; }
    }
}
