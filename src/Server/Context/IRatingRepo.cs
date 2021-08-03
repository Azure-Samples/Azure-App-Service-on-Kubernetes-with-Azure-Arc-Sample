using Ratings.Shared;
using System.Collections.Generic;

namespace Ratings.Server.Context
{
    public interface IRatingRepo
    {
        public void AddRating(RatingModel ratings);
        public List<RatingModel> GetRatings();
        public RatingModel GetRating(string id);
        public bool Exists(string id);
    }
}
