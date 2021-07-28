using System;

namespace Ratings.Server
{
    public class AddRatingException : Exception
    {
        public AddRatingException(string message) : base(message)
        {
            
        }
    }
}
