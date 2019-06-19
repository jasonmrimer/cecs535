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
select X,
       Y
    from
       R
    group by
       X,
       Y
    having
       count(*) > 1;

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
           select W     as Duplicate_Key
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


-- ### Part (c)
--
-- **_[5 points]_**
-- * $t_3[A] = t_1[A] = t_2[A]$
-- * $t_3[B] = t_1[B]$
-- * $t_3[R\setminus B] = t_2[R\setminus B]$
--
-- In this problem, write your query to check if the MVD $\{B\}\twoheadrightarrow \{D,E\}$ holds for a relation $S(A, B, C, D, E)$.
DROP TABLE IF EXISTS S;
CREATE TABLE S
(
    A INT,
    B INT,
    C INT,
    D INT,
    E INT
);
insert into S
values (8, 2, 8, 4, 5),
       (1, 2, 4, 6, 7),
       (1, 2, 3, 5, 7),
       (1, 2, 3, 5, 7),
       (3, 3, 5, 5, 6),
       (2, 3, 7, 6, 7),
       (3, 3, 5, 7, 7),
       (3, 4, 5, 6, 7),
       (3, 5, 5, 6, 7);

-- t[B] = u[B]
-- v[B] = t[B]
-- v[DE] = t[DE]
-- v[AC] = u[AC]

select A,
       B,
       C,
       D,
       E
    from
       S,
       (
           select B multi_b
               from S
               group by B
               having count(*) > 2
       )
    where
       S.B = multi_b;

select A,
       B,
       C,
       D,
       E
    from
       S,
       (
           select D multi_d,
                  E multi_e
               from
                  S
               group by
                  D,
                  E
               having
                  count(*) > 1
       )
    where
       S.D = multi_d;

-- get DE to match

select A,
       B,
       C,
       D,
       E
    from
       (
           select A,
                  B,
                  C,
                  D,
                  E
               from
                  S,
                  (
                      select B multi_b
                          from S
                          group by B
                          having count(*) > 2
                  )
               where
                  S.B = multi_b
       )
    group by
       D,
       E
    having
       count(*) > 1;

-- B & DE match
select S.A,
       S.B,
       S.C,
       S.D,
       S.E
    from
       S,
       (
           select B multi_b,
                  D multi_d,
                  E multi_e
               from
                  (
                      select B,
                             D,
                             E
                          from
                             S,
                             (
                                 select B multi_b
                                     from S
                                     group by B
                                     having count(*) > 2
                             )
                          where
                             S.B = multi_b
                  )
               group by
                  B,
                  D,
                  E
               having
                  count(*) > 1
       )
    where
       S.D = multi_d
           and S.E = multi_e
           and S.B = multi_b;

-- find if an B & AC match
select S.A,
       S.B,
       S.C,
       S.D,
       S.E
    from
       S,
       (
           select A multi_a,
                  B multi_b,
                  C multi_c
               from
                  (
                      select A,
                             B,
                             C
                          from
                             S,
                             (
                                 select B multi_b
                                     from S
                                     group by B
                                     having count(*) > 2
                             )
                          where
                             S.B = multi_b
                  )
               group by
                  A,
                  B,
                  C
               having
                  count(*) > 1
       )
    where
       S.A = multi_a
           and S.B = multi_b
           and S.C = multi_c;


-- opposite, returns empty set if there is NO MVD
select *
    from (
           select S.A,
                  S.B,
                  S.C,
                  S.D,
                  S.E
               from
                  S,
                  (
                      select A multi_a,
                             C multi_c
                          from
                             (
                                 select A,
                                        C
                                     from
                                        S,
                                        (
                                            select B multi_b
                                                from S
                                                group by B
                                                having count(*) > 2
                                        )
                                     where
                                        S.B = multi_b
                             )
                          group by
                             A,
                             C
                          having
                             count(*) > 1
                  )
               where
                  S.A = multi_a
                      and S.C = multi_c
       )
    where exists
           (
               select S.A,
                      S.B,
                      S.C,
                      S.D,
                      S.E
                   from
                      S,
                      (
                          select D,
                                 E
                              from
                                 (
                                     select A,
                                            B,
                                            C,
                                            D,
                                            E
                                         from
                                            S,
                                            (
                                                select B multi_b
                                                    from S
                                                    group by B
                                                    having count(*) > 2
                                            )
                                         where
                                            S.B = multi_b
                                 )
                              group by
                                 D,
                                 E
                              having
                                 count(*) > 1) multi
                   where
                      S.D = multi.D
                          and S.E = multi.E
           );


-- attempt 2
select *
    from (
           select S.A,
                  S.B,
                  S.C,
                  S.D,
                  S.E
               from
                  S,
                  (
                      select A multi_a,
                             B multi_b,
                             C multi_c
                          from
                             (
                                 select A,
                                        B,
                                        C
                                     from
                                        S,
                                        (
                                            select B multi_b
                                                from S
                                                group by B
                                                having count(*) > 2
                                        )
                                     where
                                        S.B = multi_b
                             )
                          group by
                             A,
                             B,
                             C
                          having
                             count(*) > 1
                  )
               where
                  S.A = multi_a
                      and S.B = multi_b
                      and S.C = multi_c
       )
    where exists
           (
               select S.A,
                      S.B,
                      S.C,
                      S.D,
                      S.E
                   from
                      S,
                      (
                          select B multi_b,
                                 D multi_d,
                                 E multi_e
                              from
                                 (
                                     select B,
                                            D,
                                            E
                                         from
                                            S,
                                            (
                                                select B multi_b
                                                    from S
                                                    group by B
                                                    having count(*) > 2
                                            )
                                         where
                                            S.B = multi_b
                                 )
                              group by
                                 B,
                                 D,
                                 E
                              having
                                 count(*) > 1
                      )
                   where
                      S.D = multi_d
                          and S.E = multi_e
                          and S.B = multi_b
           );

-- ### Part (b)
-- **_[10 points]_**
-- Consider a schema $T(A_1,...,A_n)$ which has FDs $\{A_i,A_{i+1}\}\rightarrow\{A_{i+2}\}$ for $i=1,...,n-2$.  Create an instance of $T$, for $n=4$, for which these FDs hold, and no other ones do- i.e. **all other FDs are violated.**
-- Use a series of `INSERT` statements below to populate the table `T`:
-- T(A,B,C,D)
-- AB -> C
-- BC -> D
-- AB+ = ABCD;
DROP TABLE IF EXISTS T;
CREATE TABLE T
(
    A int,
    B int,
    C int,
    D int
);
insert into T
values (1, 2, 5, 4),
       (1, 3, 5, 6),
       (2, 2, 5, 4),
       (2, 3, 5, 6);


-- 3
-- ### Part (a)
-- **_[10 points]_**
-- Create $A$, $B$ and $C$ such that each individual attribute is a key for $A$, but none of the individual attributes is a key for $B$ or $C$.  If you believe that $B$ and/or $C$ cannot be created, provide them as an empty table.
DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;
DROP TABLE IF EXISTS C;
create table A
(
    X int,
    Y int,
    Z int
);
create table B
(
    X int,
    Y int,
    Z int
);
create table C
(
    X int,
    Y int,
    Z int
);

insert into A
values (1, 4, 7),
       (2, 5, 8);

insert into C
values (1, 4, 7),
       (2, 5, 8),
       (1, 4, 8);

-- ### Part (b)
-- **_[10 points]_**
-- Create $A$, $B$ and $C$ such that ONLY the functional dependencies $\{Z\} \rightarrow \{Y\}$ and $\{X,Z\} \rightarrow \{Y\}$ hold on $B$, ONLY the functional dependency $\{X,Z\} \rightarrow \{Y\}$ holds on $A$ and NO functional dependencies hold on $C$. If you believe $B$ and/or $C$ cannot be created, provide them as an empty table.
-- A: X,Z -> Y
-- B: Z -> Y; X,Z -> Y
-- C: none
DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;
DROP TABLE IF EXISTS C;
create table A
(
    X int,
    Y int,
    Z int
);
create table B
(
    X int,
    Y int,
    Z int
);
create table C
(
    X int,
    Y int,
    Z int
);

insert into A
values (2, 4, 7),
       (2, 4, 8),
       (3, 4, 8);

insert into B
values (2, 4, 7),
       (2, 4, 8);

insert into C
values (2, 4, 7),
       (2, 4, 8),
       (3, 4, 8),
       (2, 5, 7);

-- ### Part (c)
-- **_[10 points]_**
-- Create $A$, $B$ and $C$ such that the MVD $Z\twoheadrightarrow X$ holds in $A$, but not in $B$ or $C$.  If you believe that $B$ and/or $C$ cannot be created, provide them as an empty table.
DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;
DROP TABLE IF EXISTS C;

DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;
DROP TABLE IF EXISTS C;
create table A
(
    X int,
    Y int,
    Z int
);
create table B
(
    X int,
    Y int,
    Z int
);
create table C
(
    X int,
    Y int,
    Z int
);

insert into A
values (1, 4, 7),
       (2, 5, 7),
       (2, 4, 7),
       (1, 5, 7);

insert into B
values (1, 4, 7),
       (2, 5, 7),
       (2, 4, 7);

insert into C
values (1, 4, 7),
       (2, 5, 7),
       (2, 4, 7),
       (1, 5, 7),
       (3, 4, 7);