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
insert into R
values (1, 2, 3, 4),
       (1, 3, 3, 4),
       (1, 4, 3, 4),
       (1, 5, 3, 4),
       (1, 6, 3, 4),
       (2, 7, 3, 5);

-- there should not be duplicates of any

