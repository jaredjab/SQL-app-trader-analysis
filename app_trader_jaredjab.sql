-- App Trader Project -- The Hackstreet Boys -- Jared Baker

-- Generates and formats information about app store apps
WITH app_store AS
(
SELECT name, 
    ROUND(AVG(price), 2) AS price,
    CASE WHEN ROUND(AVG(price), 2) <= 2.5 THEN 25000.00
         ELSE ROUND(AVG(price), 2) * 10000 
         END AS cost_of_rights,
    AVG(review_count::integer)::integer AS num_reviews,
    ROUND(COALESCE(AVG(rating), 0), 2) AS rating,
    12 + (ROUND(ROUND(COALESCE(AVG(rating), 0) * 4) / 4, 2) / 0.25)::integer * 6 AS lifespan_in_months,
    5000.00 AS monthly_revenue,
    MAX(CASE WHEN content_rating IN ('4+', '9+') THEN 'Everyone'
             WHEN content_rating  = '12+' THEN 'Teen'
             ELSE 'Mature'
        END) AS content_rating, 
    MAX(primary_genre) AS tags,
    TRUE AS in_app_store
FROM app_store_apps
GROUP BY name
ORDER BY name
)

-- Generates and formats information about play store apps
, play_store AS
(
SELECT name,
    ROUND(AVG(price::money::numeric), 2) AS price,
    CASE WHEN ROUND(AVG(price::money::numeric), 2) <= 2.5 THEN 25000.00
         ELSE ROUND(AVG(price::money::numeric), 2) * 10000 
         END AS cost_of_rights,
    AVG(review_count)::integer AS num_reviews,
    ROUND(COALESCE(AVG(rating), 0), 2) AS rating,
    12 + (ROUND(ROUND(COALESCE(AVG(rating), 0) * 4) / 4, 2) / 0.25)::integer * 6 AS lifespan_in_months,
    5000.00 AS monthly_revenue,
    MAX(CASE WHEN content_rating IN ('Unrated', 'Everyone', 'Everyone 10+') THEN 'Everyone'
             WHEN content_rating = 'Teen' THEN 'Teen'
             ELSE 'Mature'
        END) AS content_rating,
    CONCAT(MAX(category), ' ', MAX(genres)) AS tags,
    TRUE AS in_play_store
FROM play_store_apps
GROUP BY name
ORDER BY name
)

-- Performs final comparison calculations and formatting for all apps in both stores
SELECT name,
    (((a.lifespan_in_months + p.lifespan_in_months) / 2) * (a.monthly_revenue + p.monthly_revenue - 1000.00) - a.cost_of_rights - p.cost_of_rights)::money AS est_total_profit,
    ROUND((a.price + p.price) / 2, 2)::money AS avg_price,
    ROUND((a.rating + p.rating) / 2, 2) AS avg_rating,
    a.num_reviews + p.num_reviews AS total_reviews,
    (a.lifespan_in_months + p.lifespan_in_months) / 2 AS avg_lifespan_in_months,
    CASE WHEN a.content_rating = p.content_rating THEN a.content_rating
         ELSE CONCAT(a.content_rating, ' / ', p.content_rating) 
         END AS content_ratings,
    CONCAT(a.tags, ' | ', p.tags) AS tags
FROM app_store AS a
    FULL JOIN play_store AS p USING (name)
    WHERE (in_app_store AND in_play_store)
ORDER BY est_total_profit DESC, avg_rating DESC, total_reviews DESC;

-- DELIVERABLES --

-- a. Develop some general recommendations about the price range, genre, content rating, or any other app characteristics that the company should target.
    -- Target price: Free
        -- DON'T target: > $2.99
    -- Target genre: Games | Family, Casual, Arcade, Puzzle, Action, Strategy
        -- DON'T target: Travel, Lifestyle
    -- Target content rating: Everyone, Teen
        -- DON'T target: Mature

-- b. Develop a Top 10 List of the apps that App Trader should buy based on profitability/return on investment as the sole priority.
/*
1 - PewDiePie's Tuber Simulator	$1,111,000.00
2 - Domino's Pizza USA          $1,111,000.00
3 - Egg, Inc.                   $1,111,000.00
4 - Cytus                       $1,111,000.00
5 - The Guardian                $1,111,000.00
6 - ASOS                        $1,111,000.00
7 - Geometry Dash Lite          $1,084,000.00
NOT - H*nest Meditation         $1,084,000.00 only 200 reviews, unreliable
8 - Fernanfloo                  $1,057,000.00
9 - Bible                       $1,057,000.00
10- Toy Blast                   $1,057,000.00
*/


-- c. Develop a Top 4 list of the apps that App Trader should buy that are profitable but that also are thematically appropriate for the upcoming Halloween themed campaign.
/*
1 - Zombie Catchers            $1,057,000.00
2 - Five Nights at Freddy's 3  $1,047,200.00
3 - Earn to Die 2              $1,030,000.00
4 - Zombie Tsunami             $1,030,000.00
*/

-- d. Submit a report based on your findings. The report should include both of your lists of apps along with your analysis of their cost and potential profits. All analysis work must be done using PostgreSQL, however you may export query results to create charts in Excel for your report.