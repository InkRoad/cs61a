CREATE TABLE finals AS
  SELECT "RSF" AS hall, "61A" as course UNION
  SELECT "Wheeler"    , "61A"           UNION
  SELECT "Pimentel"   , "61A"           UNION
  SELECT "Li Ka Shing", "61A"           UNION
  SELECT "Stanley"    , "61A"           UNION
  SELECT "RSF"        , "61B"           UNION
  SELECT "Wheeler"    , "61B"           UNION
  SELECT "Morgan"     , "61B"           UNION
  SELECT "Wheeler"    , "61C"           UNION
  SELECT "Pimentel"   , "61C"           UNION
  SELECT "Soda 310"   , "61C"           UNION
  SELECT "Soda 306"   , "10"            UNION
  SELECT "RSF"        , "70";

CREATE TABLE sizes AS
  SELECT "RSF" AS room, 900 as seats    UNION
  SELECT "Wheeler"    , 700             UNION
  SELECT "Pimentel"   , 500             UNION
  SELECT "Li Ka Shing", 300             UNION
  SELECT "Stanley"    , 300             UNION
  SELECT "Morgan"     , 100             UNION
  SELECT "Soda 306"   , 80              UNION
  SELECT "Soda 310"   , 40              UNION
  SELECT "Soda 320"   , 30;

CREATE TABLE sharing AS
  --SELECT course,COUNT(DISTINCT hall) FROM(SELECT a.hall,a.course FROM finals AS a,finals AS b WHERE a.hall = b.hall AND a.course <> b.course ) GROUP BY course;--这种嵌套构造的本质是也是约束构造，可以转换为非嵌套形式
  SELECT a.course,COUNT(DISTINCT a.hall) FROM finals AS a,finals AS b WHERE a.hall = b.hall AND a.course <> b.course GROUP BY a.course;
CREATE TABLE pairs AS
  SELECT a.room || " and " || b.room || " together have " || (a.seats + b.seats) || " seats" AS rooms FROM sizes AS a,sizes AS b WHERE a.room < b.room AND a.seats + b.seats >= 1000; --字符串连接时表达式要加括号

CREATE TABLE big AS
  --SELECT course FROM (SELECT a.course,SUM(b.seats) AS total FROM finals AS a,sizes AS b WHERE a.hall = b.room GROUP BY a.course) WHERE total >= 1000;
  SELECT course FROM finals,sizes WHERE hall = room GROUP BY course HAVING SUM(seats) >= 1000; --HAVING关键字可以在筛选后再筛选
  --建议记忆上面的语法，常用于关联两个表相同项后进行操作 (SELECT * FROM sizes WHERE room = a.hall)只会找a.hall一个(传入时，其是一行的数据，也就是静态的)，而不是course中每个对应的hall都找

CREATE TABLE remaining AS
  --SELECT course, total - max AS remaining FROM(SELECT a.course,SUM(b.seats) AS total,MAX(b.seats) AS max FROM finals AS a,sizes AS b WHERE a.hall = b.room GROUP BY a.course);
  SELECT course,SUM(seats) - MAX(seats) AS remaining FROM finals,sizes WHERE hall = room GROUP BY course;
