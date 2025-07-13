--Задание 1. Вывести сумму, дату и день недели для каждой оплаты
--(получится новая строковая колонка - “4.99 - 21.03.2006 - Пятница”).
SELECT
   TO_CHAR(p.amount, '0.00') || ' - ' ||
   TO_CHAR(p.payment_date, 'DD.MM.YYYY') || ' - ' ||
   CASE EXTRACT(ISODOW FROM payment_date)::int
       WHEN 1 THEN 'Понедельник'
       WHEN 2 THEN 'Вторник'
       WHEN 3 THEN 'Среда'
       WHEN 4 THEN 'Четверг'
       WHEN 5 THEN 'Пятница'
       WHEN 6 THEN 'Суббота'
       WHEN 7 THEN 'Воскресенье'
   END AS day_of_week
FROM
   payment p;


--Задание 2. Распределить фильмы в три категории по длительности: "Короткие": менее 70 мин, "Средние": 70 (вкл) - 130 (не вкл),
--"Длинные": больше или равно 130 мин. Рассчитать количество прокатов и количество фильмов в каждой такой категории. Если
--прокатов у фильма не было, не включать его в расчеты количества фильмов в категории (подумать над типом джоина). (Подсказка:
--количество фильмов и количество прокатов не будут одинаковыми, ведь фильм берут напрокат много раз)
SELECT
   CASE
       WHEN f.length < 70 THEN 'Короткие'
       WHEN f.length >= 70 AND f.length < 130 THEN 'Средние'
       ELSE 'Длинные'
   END AS duration_category,
  
   COUNT(r.rental_id) AS rental_count,
   COUNT(DISTINCT f.film_id) AS film_count
FROM
   film f
JOIN
   inventory i ON f.film_id = i.film_id
JOIN
   rental r ON i.inventory_id = r.inventory_id
GROUP BY
   duration_category




--Задание 3. (Оконная функция)
--Рассчитать во сколько раз данный фильм берут чаще, чем фильмы из той же категории в среднем.


--Сортировка по жанровым категориям:
SELECT
   f.title AS film_title,
   c.name AS category,
   COUNT(r.rental_id) AS rental_count,
   AVG(COUNT(r.rental_id)) OVER (PARTITION BY c.category_id) AS avg_category_rentals,
   ROUND(
       COUNT(r.rental_id) /
       AVG(COUNT(r.rental_id)) OVER (PARTITION BY c.category_id),
       2
   ) AS ratio
FROM
   film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY
   f.film_id, c.category_id, c.name
ORDER BY
   c.name ASC,          -- сначала сортируем по названию категории
   ratio DESC;          -- внутри категории — от самых популярных фильмов


--Сортировка по временным категориям:
SELECT
    f.title AS film_title,
    CASE
        WHEN f.length < 70 THEN 'Короткие'
        WHEN f.length >= 70 AND f.length < 130 THEN 'Средние'
        ELSE 'Длинные'
    END AS duration_category,
    COUNT(r.rental_id) AS rental_count,
    ROUND(
        AVG(COUNT(r.rental_id)) OVER (PARTITION BY 
            CASE
                WHEN f.length < 70 THEN 'Короткие'
                WHEN f.length >= 70 AND f.length < 130 THEN 'Средние'
                ELSE 'Длинные'
            END
        ),
        2
    ) AS avg_rentals_in_category,
    ROUND(
        COUNT(r.rental_id) / 
        AVG(COUNT(r.rental_id)) OVER (PARTITION BY 
            CASE
                WHEN f.length < 70 THEN 'Короткие'
                WHEN f.length >= 70 AND f.length < 130 THEN 'Средние'
                ELSE 'Длинные'
            END
        ),
        2
    ) AS ratio
FROM
    film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY
    f.film_id, f.title, f.length
ORDER BY
    duration_category ASC,
    ratio DESC;

--Задание 1. Вывести сумму, дату и день недели для каждой оплаты
--(получится новая строковая колонка - “4.99 - 21.03.2006 - Пятница”).
SELECT
   TO_CHAR(p.amount, '0.00') || ' - ' ||
   TO_CHAR(p.payment_date, 'DD.MM.YYYY') || ' - ' ||
   CASE EXTRACT(ISODOW FROM payment_date)::int
       WHEN 1 THEN 'Понедельник'
       WHEN 2 THEN 'Вторник'
       WHEN 3 THEN 'Среда'
       WHEN 4 THEN 'Четверг'
       WHEN 5 THEN 'Пятница'
       WHEN 6 THEN 'Суббота'
       WHEN 7 THEN 'Воскресенье'
   END AS day_of_week
FROM
   payment p;


