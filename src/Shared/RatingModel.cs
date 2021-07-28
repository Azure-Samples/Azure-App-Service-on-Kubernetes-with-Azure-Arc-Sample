
namespace Ratings.Shared
{
    public class RatingModel
    {
        public RatingModel()
        {

        }

        public RatingModel(string id, int rating, string userNotes)
        {
            this.Id = id;
            this.Rating = rating;
            this.UserNotes = userNotes;
        }

        public string Id { get; set; }
        public int Rating { get; set; }
        public string UserNotes { get; set; }
    }
}