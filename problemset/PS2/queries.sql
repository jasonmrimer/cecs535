-- 1.
-- ### Part (a)
-- **_[5 points]_**
-- $\{X, Y\}$ is a **superkey** for a relation $R(W,X,Y,Z)$.
DROP TABLE IF EXISTS R;
CREATE TABLE R
(
    W INT,
    X INT,
    Y INT,
    Z INT
);

insert into R
values (1, 2, 3, 4),
       (1, 3, 3, 4),
       (1, 4, 3, 4),
       (1, 5, 3, 4),
       (1, 6, 3, 4),
       (2, 7, 3, 5);

-- x,y would fail to be a superkey if any tuple repeats
select X, Y
from R
group by X, Y
having count(*) > 1;

-- ### Part (b)
-- **_[5 points]_**
-- The individual attributes of a relation $R(W,X,Y,Z)$ are each keys.
DROP TABLE IF EXISTS R;
CREATE TABLE R
(
    W INT,
    X INT,
    Y INT,
    Z INT
);

insert into R
values (1, 2, 1, 2),
       (2, 3, 2, 3),
       (3, 4, 3, 4),
       (4, 5, 4, 5),
       (5, 6, 5, 6),
       (6, 7, 6, 7);

-- there should not be duplicates of any
select *
from (
         select W as Duplicate_Key
         from R
         group by W
         having count(*) > 1
         union
         select X as Duplicate_Key
         from R
         group by X
         having count(*) > 1
         union
         select Y as Duplicate_Key
         from R
         group by Y
         having count(*) > 1
         union
         select Z as Duplicate_Key
         from R
         group by Z
         having count(*) > 1
     );



