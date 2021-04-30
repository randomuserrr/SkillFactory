-- Задание 4.1
-- База данных содержит список аэропортов практически всех крупных городов России.
-- В большинстве городов есть только один аэропорт. Исключение составляет:

SELECT a.city,
       count(*) AS count_airport
  FROM dst_project.airports AS a
 GROUP BY 1
HAVING count(*) > 1

-- Задание 4.2.1
-- Таблица рейсов содержит всю информацию о прошлых, текущих и запланированных рейсах.
-- Сколько всего статусов для рейсов определено в таблице?

SELECT count(DISTINCT f.status)
  FROM dst_project.flights AS f

-- Задание 4.2.2
-- Какое количество самолетов находятся в воздухе на момент среза в базе (статус рейса «самолёт уже вылетел и находится в воздухе»).

SELECT count(*)
  FROM dst_project.flights AS f
 WHERE f.status = 'Departed'

-- Задание 4.2.3
-- Места определяют схему салона каждой модели. Сколько мест имеет самолет модели  (Boeing 777-300)?

SELECT count(*)
  FROM dst_project.aircrafts AS a
           LEFT JOIN dst_project.seats AS s ON a.aircraft_code = s.aircraft_code
 WHERE a.model = 'Boeing 777-300'


-- Задание 4.2.4
-- Сколько состоявшихся (фактических) рейсов было совершено между 1 апреля 2017 года и 1 сентября 2017 года?

SELECT count(*)
  FROM dst_project.flights AS f
 WHERE f.actual_arrival BETWEEN '2017-04-01' AND '2017-09-01'
   AND f.status = 'Arrived'

-- Задание 4.3.1
-- Сколько всего рейсов было отменено по данным базы?

SELECT count(*)
  FROM dst_project.flights AS f
 WHERE f.status = 'Cancelled'

-- Задание 4.3.2
-- Сколько самолетов моделей типа Boeing, Sukhoi Superjet, Airbus находится в базе авиаперевозок?

  WITH boeing         AS
           (SELECT count(*) AS boeing
              FROM dst_project.aircrafts AS a
             WHERE a.model LIKE 'Boeing%'),
       sukoi_superjet AS
           (SELECT count(*) AS superjet
              FROM dst_project.aircrafts AS a
             WHERE a.model LIKE 'Sukhoi Superjet%'),
       airbus         AS
           (SELECT count(*) AS airbus
              FROM dst_project.aircrafts AS a
             WHERE a.model LIKE 'Airbus%')

SELECT *
  FROM boeing,
       sukoi_superjet,
       airbus

-- Задание 4.3.3
-- В какой части (частях) света находится больше аэропортов?

  WITH europe_airports AS
           (SELECT count(*) AS europe
              FROM dst_project.airports AS a
             WHERE a.timezone LIKE 'Europe%'),

       asia_airports   AS
           (SELECT count(*) AS asia
              FROM dst_project.airports AS a
             WHERE a.timezone LIKE 'Asia%')
SELECT *
  FROM europe_airports,
       asia_airports

-- Задание 4.3.4
-- У какого рейса была самая большая задержка прибытия за все время сбора данных? Введите id рейса (flight_id).

SELECT f.flight_id
  FROM dst_project.flights AS f
 WHERE f.status = 'Arrived'
 ORDER BY f.actual_arrival - f.scheduled_arrival DESC
 LIMIT 1

-- Задание 4.4.1
-- Когда был запланирован самый первый вылет, сохраненный в базе данных?

SELECT f.scheduled_departure::date
  FROM dst_project.flights AS f
 ORDER BY 1
 LIMIT 1

-- Задание 4.4.2
-- Сколько минут составляет запланированное время полета в самом длительном рейсе?

SELECT EXTRACT(HOUR FROM (f.scheduled_arrival - f.scheduled_departure)) * 60 +
       EXTRACT(MINUTE FROM (f.scheduled_arrival - f.scheduled_departure)) AS flight_time
  FROM dst_project.flights AS f

-- Задание 4.4.3
-- Между какими аэропортами пролегает самый длительный по времени запланированный рейс?

SELECT f.departure_airport,
       f.arrival_airport,
       EXTRACT(HOUR FROM (f.scheduled_arrival - f.scheduled_departure)) * 60 +
       EXTRACT(MINUTE FROM (f.scheduled_arrival - f.scheduled_departure)) AS flight_time
  FROM dst_project.flights AS f
 ORDER BY 3 DESC
 LIMIT 1

-- Задание 4.4.4
-- Сколько составляет средняя дальность полета среди всех самолетов в минутах?
-- Секунды округляются в меньшую сторону (отбрасываются до минут).

SELECT avg(EXTRACT(HOUR FROM (f.scheduled_arrival - f.scheduled_departure)) * 60 +
           EXTRACT(MINUTE FROM (f.scheduled_arrival - f.scheduled_departure)))::int AS avg_flight_time
  FROM dst_project.flights AS f

-- Задание 4.5.1
-- Мест какого класса у SU9 больше всего?

SELECT s.fare_conditions,
       count(*)
  FROM dst_project.aircrafts AS a
           LEFT JOIN dst_project.seats AS s ON a.aircraft_code = s.aircraft_code
 WHERE a.aircraft_code = 'SU9'
 GROUP BY 1

-- Задание 4.5.2
-- Какую самую минимальную стоимость составило бронирование за всю историю?

SELECT min(t.total_amount)
  FROM dst_project.bookings AS t

-- Задание 4.5.3
-- Какой номер места был у пассажира с id = 4313 788533?

SELECT b.seat_no
  FROM dst_project.tickets AS t
           LEFT JOIN dst_project.boarding_passes AS b ON t.ticket_no = b.ticket_no
 WHERE t.passenger_id = '4313 788533'

-- Задание 5.1.1
-- Анапа — курортный город на юге России. Сколько рейсов прибыло в Анапу за 2017 год?

SELECT count(*)
  FROM dst_project.airports AS a
           LEFT JOIN dst_project.flights AS f ON a.airport_code = f.arrival_airport
 WHERE a.city = 'Anapa'
   AND f.status = 'Arrived'
   AND extract(YEAR FROM f.actual_arrival) = 2017

-- Задание 5.1.2
-- Сколько рейсов из Анапы вылетело зимой 2017 года?

SELECT count(*)
  FROM dst_project.airports AS a
           LEFT JOIN dst_project.flights AS f ON a.airport_code = f.departure_airport
 WHERE a.city = 'Anapa'
   AND (date_trunc('month', f.actual_departure) IN ('2017-01-01', '2017-02-01', '2017-12-01'))
   AND f.status != 'Cancelled'

-- Задание 5.1.3
-- Посчитайте количество отмененных рейсов из Анапы за все время.

SELECT *
  FROM dst_project.airports AS a
           LEFT JOIN dst_project.flights AS f ON a.airport_code = f.departure_airport
 WHERE a.city = 'Anapa'
   AND f.status = 'Cancelled'

-- Задание 5.1.4
-- Сколько рейсов из Анапы не летают в Москву?

SELECT count(*)
  FROM dst_project.flights AS f
           LEFT JOIN dst_project.airports AS a ON f.arrival_airport = a.airport_code
 WHERE f.departure_airport = 'AAQ'
   AND a.city != 'Moscow'

-- Задание 5.1.5
-- Какая модель самолета летящего на рейсах из Анапы имеет больше всего мест?

  WITH count_seats_aircraft AS
           (SELECT s.aircraft_code,
                   count(*) AS count_seats
              FROM dst_project.seats AS s
             GROUP BY 1)

SELECT DISTINCT f.aircraft_code,
                a.model,
                c.count_seats
  FROM dst_project.flights AS f
           LEFT JOIN count_seats_aircraft AS c ON c.aircraft_code = f.aircraft_code
           LEFT JOIN dst_project.aircrafts AS a ON f.aircraft_code = a.aircraft_code
 WHERE f.departure_airport = 'AAQ'

-- ТАблица для анализа нерентабильных рейсов Анапы зимой 2017 г.

  WITH main_table       AS -- вылеты из Анапы (зима 2017)
           (SELECT f.flight_id,
                   f.flight_no,
                   f.arrival_airport,
                   f.aircraft_code,
                   f.actual_departure,
                   f.actual_arrival,
                   EXTRACT(HOUR FROM (f.actual_arrival - f.actual_departure)) * 60 +
                   EXTRACT(MINUTE FROM (f.actual_arrival - f.actual_departure)) AS flight_time
              FROM dst_project.flights AS f
             WHERE departure_airport = 'AAQ'
               AND (date_trunc('month', scheduled_departure) IN ('2017-01-01', '2017-02-01', '2017-12-01'))
               AND status NOT IN ('Cancelled')),

       count_seats      AS -- таблица с кол-вом мест в каждом классе
           (SELECT s.aircraft_code,
                   count(CASE WHEN s.fare_conditions = 'Economy' THEN s.fare_conditions END)  AS seat_economy,
                   count(CASE WHEN s.fare_conditions = 'Comfort' THEN s.fare_conditions END)  AS seat_comfort,
                   count(CASE WHEN s.fare_conditions = 'Business' THEN s.fare_conditions END) AS seat_bisiness,
                   count(*)                                                                   AS seat_total
              FROM dst_project.seats AS s
             GROUP BY 1),

       sold_tickets     AS -- таблица проданных билетов
           (SELECT tf.flight_id,
                   count(CASE WHEN tf.fare_conditions = 'Economy' THEN tf.fare_conditions END)  AS sold_economy,
                   count(CASE WHEN tf.fare_conditions = 'Comfort' THEN tf.fare_conditions END)  AS sold_comfort,
                   count(CASE WHEN tf.fare_conditions = 'Business' THEN tf.fare_conditions END) AS sold_bisiness,
                   count(*)                                                                     AS sold_total,
                   sum(CASE WHEN tf.fare_conditions = 'Economy' THEN tf.amount END)             AS amount_economy,
                   sum(CASE WHEN tf.fare_conditions = 'Comfort' THEN tf.amount END)             AS amount_comfort,
                   sum(CASE WHEN tf.fare_conditions = 'Business' THEN tf.amount END)            AS amount_bisiness,
                   sum(tf.amount)                                                               AS amount_total
              FROM dst_project.ticket_flights AS tf
             GROUP BY 1),
       fuel_consumption AS
           (SELECT 'Boeing 737-300' AS model,
                   2400             AS fuel_consum_kg_hr
             UNION
            SELECT 'Sukhoi Superjet-100' AS model,
                   1700                  AS fuel_consum_kg_hr)

SELECT mt.flight_id,
       mt.flight_no,
       mt.arrival_airport,
       ap.city,
       mt.actual_departure,
       mt.actual_arrival,
       mt.flight_time,
       a.model,
       fc.fuel_consum_kg_hr,
       ct.*,
       st.*
  FROM main_table AS mt
           LEFT JOIN dst_project.aircrafts AS a ON mt.aircraft_code = a.aircraft_code
           LEFT JOIN fuel_consumption AS fc ON fc.model = a.model
           LEFT JOIN dst_project.airports AS ap ON ap.airport_code = mt.arrival_airport
           LEFT JOIN count_seats AS ct ON ct.aircraft_code = mt.aircraft_code
           LEFT JOIN sold_tickets AS st ON st.flight_id = mt.flight_id








