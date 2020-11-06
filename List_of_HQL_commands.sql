
--1. 
CREATE TABLE october20 (
domain STRING,
title STRING,
views INT,
num INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

// Load Data

SELECT title, SUM(views) AS total_views
FROM october20
WHERE domain LIKE '%en%'
GROUP BY title
ORDER BY total_views DESC
LIMIT 10;

--*****************************************************************************
	
--2.
--Key Assumption--
--October 20 represents a typical day
--Takeaway
--We can take our data, times it by 30, and get data that represents a month
--Effect on Results
--Events that happened in september can have > 100% link rate

CREATE TABLE sept_click (
prev STRING,
curr STRING,
type STRING,
num INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

//Load Data

CREATE TABLE prev_clicks AS
SELECT prev,
SUM(CASE WHEN type = 'link' THEN num ELSE 0 END) AS link_occurences
FROM sept_click
GROUP BY prev;

CREATE TABLE one_day_views AS
SELECT title, SUM(views) AS num_views
FROM october20
WHERE domain LIKE '%en%'
GROUP BY title;

CREATE TABLE merged AS
SELECT one_day_views.title,
one_day_views.num_views,
prev_clicks.link_occurences,
(prev_clicks.link_occurences/(one_day_views.num_views * 30)) AS percentage
FROM one_day_views JOIN prev_clicks
ON (one_day_views.title = prev_clicks.prev)
ORDER BY percentage DESC;

SELECT * FROM merged WHERE num_views> 10000 LIMIT 10;

--*****************************************************************************

--3.
SELECT * FROM sept_click
WHERE type = 'link' AND prev LIKE 'Eagles_(box_set)'
SORT BY num DESC
LIMIT 1;


--Hotel_California 				->2222-> 
--Hotel_California_(Eagles_album) ->2127->
--The_Long_Run_(album) 			->1322->
--Eagles_Live 					->1136->
--Eagles_Greatest_Hits,_Vol._2	->996->
--The_Very_Best_of_the_Eagles		->892->
--Hell_Freezes_Over				->735->
--Selected_Works:_1972–1999		->705->
--The_Very_Best_Of_(Eagles_album)	->646->
--Eagles_(box_set)				->670->
--Long_Road_Out_of_Eden

--*****************************************************************************

--4.
--Key Assumptions--
--October 20th represents a typical day
--Each country is most active for six hours surrounding lunch/mid-afternoon
--Data will then be summed by country from 10:00 AM to 4:00 PM

--America (5 Hours behind)	->		15:00 - 20:00 (inclusive)
--UK is on time 				->		10:00 - 15:00 (inclusive)
--Australia (11 Hours ahead)	->		23:00 - 04:00 (inclusive)


-- Load data from following time periods into corresponding tables below
-- LOAD DATA LOCAL INPATH '/home/trevorbuck/project2/data/pageviews-20201020-??0000' INTO TABLE one_day_???;


CREATE TABLE one_day_usa(
domain STRING,
title STRING,
views INT,
response INT
)
ROW FORMAT DELIMITEd
FIELDS TERMINATED BY ' ';

CREATE TABLE one_day_uk(
domain STRING,
title STRING,
views INT,
response INT
)
ROW FORMAT DELIMITEd
FIELDS TERMINATED BY ' ';

CREATE TABLE one_day_aus(
domain STRING,
title STRING,
views INT,
response INT
)
ROW FORMAT DELIMITEd
FIELDS TERMINATED BY ' ';

-- Create merged tables

CREATE TABLE usa_uk AS
SELECT one_day_usa.domain, one_day_usa.title, one_day_usa.views AS views_usa, one_day_uk.views AS views_uk
FROM one_day_usa JOIN one_day_uk
ON (one_day_usa.title = one_day_uk.title AND one_day_usa.domain = one_day_uk.domain);

CREATE TABLE usa_aus AS
SELECT one_day_usa.domain, one_day_usa.title, one_day_usa.views AS views_usa, one_day_aus.views AS views_aus
FROM one_day_usa JOIN one_day_aus
ON (one_day_usa.title = one_day_aus.title AND one_day_usa.domain = one_day_aus.domain);

-- Select answer

SELECT title, SUM(views_usa) AS views_usa, SUM(views_uk) AS views_uk, SUM(views_uk - views_usa) AS diff
FROM usa_uk
WHERE domain LIKE '%en%'
GROUP BY title
ORDER BY diff DESC
LIMIT 20;

SELECT title, SUM(views_usa) AS views_usa, SUM(views_aus) AS views_aus, SUM(views_aus - views_usa) AS diff
FROM usa_aus
WHERE domain LIKE '%en%'
GROUP BY title
ORDER BY diff DESC
LIMIT 20;
-- NOT HAPPY WITH THIS RESULT -- MAYBE PLAY WITH THE HOURS A LITTLE BIT MORE

--*****************************************************************************

--5.
CREATE TABLE revisions (wiki_db STRING, 
event_entity STRING,
event_type STRING,
event_timestamp STRING,
event_comment STRING,
event_userid BIGINT,
event_usertexthistorical STRING,
event_usertext STRING,
event_userblockshistorical STRING,
event_userblocks ARRAY<STRING>,
event_usergoupshistorical ARRAY<STRING>,
event_usergroups ARRAY<STRING>,
event_user_is_bot_by_historical ARRAY<STRING>,
event_user_is_bot_by ARRAY<STRING>,
event_user_is_created_by_self BOOLEAN,
event_user_is_created_by_system BOOLEAN,
event_user_is_created_by_peer BOOLEAN,
event_user_is_anonymous BOOLEAN,
event_user_registration_timestamp STRING,
event_user_creation_timestamp STRING,
event_user_first_edit_timestamp STRING,
event_user_revision_count BIGINT,
event_user_seconds_since_previous_revision BIGINT,
page_id BIGINT,
page_title_historical STRING,
page_title STRING,
page_namespace_historical INT,
page_namespace_is_content_historical BOOLEAN,
page_namespace INT,
page_namespace_is_content BOOLEAN,
page_is_redirect BOOLEAN,
page_is_deleted BOOLEAN,
page_creation_timestamp STRING,
page_first_edit_timestamp STRING,
page_revision_count BIGINT,
page_seconds_since_previous_revision BIGINT,
user_id BIGINT,
user_text_historical STRING,
user_text STRING,
user_blocks_historical ARRAY<STRING>,
user_blocks ARRAY<STRING>,
user_groups_historical ARRAY<STRING>,
user_groups ARRAY<String>,
user_is_bot_by_historical ARRAY<STRING>,
user_is_bot_by Array<STRING>,
user_is_created_by_self BOOLEAN,
user_is_created_by_system BOOLEAN,
user_is_created_by_peer BOOLEAN,
user_is_anonymous BOOLEAN,
user_registration_timestamp STRING,
user_creation_timestamp STRING,
user_first_edit_timestamp STRING,
revision_id BIGINT,
revision_parent_id BIGINT,
revision_minor_edit BOOLEAN,
revision_deleted_parts ARRAY<STRING>,
revision_deleted_parts_are_suppressed BOOLEAN,
revision_text_bytes BIGINT,
revision_text_bytes_diff BIGINT,
revision_text_sha1 STRING,
revision_content_model STRING,
revision_content_format STRING,
revision_is_deleted_by_page_deletion BOOLEAN,
revision_deleted_by_page_deletion_timestamp STRING,
revision_is_identity_reverted BOOLEAN,
revision_first_identity_reverting_revision_id BIGINT,
revision_seconds_to_identity_revert BIGINT,
revision_is_identity_revert BOOLEAN,
revision_is_from_before_page_creation BOOLEAN,
revision_tags ARRAY<STRING>)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t';

-- Load Data
-- LOAD DATA LOCAL INPATH '/home/trevorbuck/project2/data/revisions/2020-10.enwiki.2020-10.tsv.bz2' INTO TABLE revisions;

CREATE TABLE revision_plus_views AS
SELECT revisions.page_title AS title, revisions.revision_seconds_to_identity_revert AS seconds_to_revert, october20.views AS views
FROM revisions JOIN october20
ON (revisions.page_title = october20.title);

SELECT AVG(seconds_to_revert) AS seconds_average, AVG(views) AS views_average_per_day
FROM revision_plus_views
WHERE seconds_to_revert > 0;

--Final Math

-- seconds_average * views_average_per_day *  (1 day / 86400 second)  = x views before edit

-- 65287.89730011033  *  28.415237131249395  /  86400  =  21.47188754147329 views before edit


--*****************************************************************************

--6. 
-- QUESTION:

-- Which English wikipedia article had the highest number of major edits(aka not minor)?
-- And what was the average number of bytes for those edits?

SELECT page_title, SUM(CASE revision_minor_edit when False then 1 else 0 end) AS num_major_edits, AVG(revision_text_bytes) AS avg_bytes
FROM revisions
GROUP BY page_title
ORDER BY num_major_edits DESC
LIMIT 10;

CREATE TABLE may (
prev STRING,
curr STRING,
type STRING,
num INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA LOCAL INPATH
'/home/trevorbuck/project2/data/months/clickstream-enwiki-2020-05.tsv.gz'
INTO TABLE may;

SELECT may.curr AS title, SUM(may.num - sept_click.num) AS diff
FROM may JOIN sept_click
ON (may.curr = sept_click.curr)
GROUP BY may.curr
ORDER BY diff DESC
LIMIT 10;
