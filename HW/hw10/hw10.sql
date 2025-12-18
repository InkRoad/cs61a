CREATE TABLE parents AS
  SELECT "ace" AS parent, "bella" AS child UNION
  SELECT "ace"          , "charlie"        UNION
  SELECT "daisy"        , "hank"           UNION
  SELECT "finn"         , "ace"            UNION
  SELECT "finn"         , "daisy"          UNION
  SELECT "finn"         , "ginger"         UNION
  SELECT "ellie"        , "finn";

CREATE TABLE dogs AS
  SELECT "ace" AS name, "long" AS fur, 26 AS height UNION
  SELECT "bella"      , "short"      , 52           UNION
  SELECT "charlie"    , "long"       , 47           UNION
  SELECT "daisy"      , "long"       , 46           UNION
  SELECT "ellie"      , "short"      , 35           UNION
  SELECT "finn"       , "curly"      , 32           UNION
  SELECT "ginger"     , "short"      , 28           UNION
  SELECT "hank"       , "curly"      , 31;

CREATE TABLE sizes AS
  SELECT "toy" AS size, 24 AS min, 28 AS max UNION
  SELECT "mini"       , 28       , 35        UNION
  SELECT "medium"     , 35       , 45        UNION
  SELECT "standard"   , 45       , 60;


-- All dogs with parents ordered by decreasing height of their parent
CREATE TABLE by_parent_height AS
  SELECT b.child FROM dogs AS a,parents AS b where a.name = b.parent order by a.height DESC;


-- The size of each dog
CREATE TABLE size_of_dogs AS
  SELECT a.name,b.size FROM dogs AS a,sizes AS b where a.height > b.min AND a.height <= b.max;


-- [Optional] Filling out this helper table is recommended
CREATE TABLE siblings AS
  SELECT a.child AS left,b.child AS right FROM parents AS a,parents AS b WHERE a.parent = b.parent AND a.child <> b.child AND a.child < b.child; --最后小于号用于去重 ab ba，原理是利用字典序大小

-- Sentences about siblings that are the same size
CREATE TABLE sentences AS
  SELECT "The two siblings, "||a.left||" and "||a.right||", have the same size: "||s1.size FROM siblings AS a,size_of_dogs AS s1,size_of_dogs AS s2 WHERE a.left = s1.name and a.right = s2.name and s1.size = s2.size;  --一组的兄弟，分别找其在size表中的size比较相同否即可


-- Height range for each fur type where all of the heights differ by no more than 30% from the average height
CREATE TABLE low_variance AS
  --SELECT fur,max - min AS height_range FROM (SELECT fur,MAX(height) AS max, MIN(height) AS min,AVG(height) AS avg FROM dogs GROUP BY fur) where min >= avg*0.7 AND max <= avg*1.3 ; 这个解法是嵌套定义，先按组筛选出各自的最大最小和平均值后再按条件SELECT
  SELECT fur,MAX(a.height) - MIN(a.height) FROM dogs AS a where (SELECT MAX(height) FROM dogs where fur = a.fur) <= (SELECT AVG(height)*1.3 FROM dogs where fur = a.fur) AND (SELECT MIN(height) FROM dogs where fur = a.fur) >= (SELECT AVG(height)*0.7 FROM dogs where fur = a.fur) GROUP BY fur;
