ratings = LOAD '/user/maria_dev/ml-100k /u.data’ AS (userID:int, movieID:int, rating : int, ratingTime : int);

metadata = LOAD '/user/maria_dev/ml-100k/u.item’ USING Pigstorage (‘|’) 
   AS (movieID:int, movieTitle:chararray, releaseDate:chararray, videoRelease : chararray, imdbLink:chararray);

nameLookup = FOREACH metadata GENERATE movie!D, movieTitle,
                         ToUnixTime(ToDate (releaseDate, ‘dd-MMM-yyyy’)) AS releaseTime;

ratingsByMovie = GROUP ratings BY movie!D;

avgRatings = FOREACH ratingsByMovie GENERATE group AS movieID, AVG(ratings.rating) AS avgRating;

fiveStarMovies = FILTER avgRatings BY avgRating > 4.0;

fiveStarswithData = J0IN fiveStarMovies BY movieID, nameLookup BY movieID;

oldestFivestarMovies = ORDER fivestarswithData BY nameLookup :: releaseTime;

DUMP oldestFiveStarMovies;
