
namespace Ratings.Server.Context
{
    public interface IContextInitialiser
    {
        void Initialise(RatingContext ratingContext);
    }
}
