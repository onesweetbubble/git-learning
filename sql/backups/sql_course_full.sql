--
-- PostgreSQL database dump
--

\restrict 2feoPw3zUVByJlSTGOG9uUoZSMaMcvtqhYt5xLmehyFUQCYP3AhV9fQygnbHYv6

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    full_name text NOT NULL,
    birth_date date NOT NULL,
    city text NOT NULL,
    email text NOT NULL
);


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    price numeric(10,2) NOT NULL,
    CONSTRAINT chek_order_item_price_positive CHECK ((price >= (0)::numeric)),
    CONSTRAINT chek_order_item_quantity_positive CHECK ((quantity > 0))
);


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    customer_id integer,
    order_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    amount numeric(10,2) NOT NULL,
    order_status text DEFAULT 'new'::text NOT NULL,
    CONSTRAINT check_amount_positive CHECK ((amount >= (0)::numeric)),
    CONSTRAINT check_order_date CHECK ((order_date <= CURRENT_TIMESTAMP)),
    CONSTRAINT check_order_status CHECK ((order_status = ANY (ARRAY['new'::text, 'paid'::text, 'cancelled'::text])))
);


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    product_name text NOT NULL,
    price numeric(10,2) NOT NULL,
    category text NOT NULL,
    CONSTRAINT check_product_price_positive CHECK ((price >= (0)::numeric))
);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.customers (id, full_name, birth_date, city, email) FROM stdin;
6	Pavel Sokolov	1992-02-14	Sochi	mikhailov141@gmail.com
34	Kris Smirnov	2002-01-09	Moscow	mikhailov859@outlook.com
1	Ivan Petrov	1999-03-10	Moscow	ivanov628@outlook.com
4	Olga Sidorova	1988-11-22	Novosibirsk	sidorov256@yandex.ru
5	Matia Orlova	1995-08-17	Ekaterinburg	volkov969@mail.ru
22	Kris Petrov	1991-05-03	Kazan	smirnov137@outlook.com
23	Dmitrii Zhuravlev	1977-09-15	Moscow	novikov199@mail.ru
24	Alla Petrov	2000-11-22	Kazan	stepanov377@icloud.com
25	Dmitrii Drobishev	1983-01-19	Saint-Petersburg	petrov753@icloud.com
26	Alex Ivanov	1994-05-02	Novosibirsk	alekseev101@outlook.com
27	Alla Zhuravlev	1988-04-24	Moscow	mikhailov479@mail.ru
28	Mariy Bobkova	2003-07-27	Saint-Petersburg	kuznetsov370@mail.ru
29	Anna Litvinov	1985-05-27	Novosibirsk	volkov45@outlook.com
30	Alla Ivanov	2003-02-14	Moscow	kozlov822@icloud.com
31	Kris Drobishev	1983-07-15	Kazan	popov542@mail.ru
32	Oleg Bobkova	1984-07-25	Kazan	smirnov400@outlook.com
33	Dmitrii Litvinov	2007-02-21	Novosibirsk	sidorov924@yandex.ru
35	Alla Petrov	1983-10-07	Novosibirsk	pavlov39@yandex.ru
36	Oleg Litvinov	1976-02-19	Kazan	popov267@yandex.ru
3	Sergey Zhuravlev	1992-12-05	Moscow	nikolaev280@outlook.com
2	Anna Smirnova	1992-02-14	Kazan	vasiliev392@outlook.com
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_items (id, order_id, product_id, quantity, price) FROM stdin;
21	2	2	4	654.04
31	3	3	1	150.98
41	4	4	2	765.28
51	5	5	3	604.30
61	6	6	4	359.89
71	7	7	1	459.79
81	8	8	2	101.38
91	9	9	3	905.90
101	10	10	4	665.36
111	11	11	1	195.78
121	12	12	2	511.68
131	13	13	3	272.74
141	14	14	4	492.32
151	15	15	1	625.07
161	16	16	2	570.84
171	17	17	3	583.13
181	18	18	4	186.33
191	19	19	1	933.58
201	20	20	2	632.33
211	21	1	3	428.07
221	22	2	4	654.04
231	23	3	1	150.98
241	24	4	2	765.28
251	25	5	3	604.30
261	26	6	4	359.89
271	27	7	1	459.79
281	28	8	2	101.38
291	29	9	3	905.90
301	30	10	4	665.36
311	31	11	1	195.78
321	32	12	2	511.68
331	33	13	3	272.74
341	34	14	4	492.32
351	35	15	1	625.07
361	36	16	2	570.84
371	37	17	3	583.13
381	38	18	4	186.33
391	39	19	1	933.58
401	40	20	2	632.33
411	41	1	3	428.07
421	42	2	4	654.04
441	44	4	2	765.28
22	2	3	1	150.98
32	3	4	2	765.28
42	4	5	3	604.30
52	5	6	4	359.89
62	6	7	1	459.79
72	7	8	2	101.38
82	8	9	3	905.90
92	9	10	4	665.36
102	10	11	1	195.78
112	11	12	2	511.68
122	12	13	3	272.74
132	13	14	4	492.32
142	14	15	1	625.07
152	15	16	2	570.84
162	16	17	3	583.13
172	17	18	4	186.33
182	18	19	1	933.58
192	19	20	2	632.33
202	20	1	3	428.07
212	21	2	4	654.04
222	22	3	1	150.98
232	23	4	2	765.28
242	24	5	3	604.30
252	25	6	4	359.89
262	26	7	1	459.79
272	27	8	2	101.38
282	28	9	3	905.90
292	29	10	4	665.36
302	30	11	1	195.78
312	31	12	2	511.68
322	32	13	3	272.74
332	33	14	4	492.32
342	34	15	1	625.07
352	35	16	2	570.84
362	36	17	3	583.13
372	37	18	4	186.33
382	38	19	1	933.58
392	39	20	2	632.33
402	40	1	3	428.07
412	41	2	4	654.04
422	42	3	1	150.98
442	44	5	3	604.30
23	2	4	2	765.28
33	3	5	3	604.30
43	4	6	4	359.89
53	5	7	1	459.79
63	6	8	2	101.38
73	7	9	3	905.90
83	8	10	4	665.36
93	9	11	1	195.78
103	10	12	2	511.68
113	11	13	3	272.74
123	12	14	4	492.32
133	13	15	1	625.07
143	14	16	2	570.84
153	15	17	3	583.13
163	16	18	4	186.33
173	17	19	1	933.58
183	18	20	2	632.33
193	19	1	3	428.07
203	20	2	4	654.04
213	21	3	1	150.98
223	22	4	2	765.28
233	23	5	3	604.30
243	24	6	4	359.89
253	25	7	1	459.79
263	26	8	2	101.38
273	27	9	3	905.90
283	28	10	4	665.36
293	29	11	1	195.78
303	30	12	2	511.68
313	31	13	3	272.74
323	32	14	4	492.32
333	33	15	1	625.07
343	34	16	2	570.84
353	35	17	3	583.13
363	36	18	4	186.33
373	37	19	1	933.58
383	38	20	2	632.33
393	39	1	3	428.07
403	40	2	4	654.04
413	41	3	1	150.98
423	42	4	2	765.28
443	44	6	4	359.89
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orders (id, customer_id, order_date, amount, order_status) FROM stdin;
2	24	2026-02-01 14:56:33.069103	793.66	new
3	22	2026-03-01 22:22:43.892818	411.83	cancelled
4	35	2026-03-19 01:43:36.129632	932.17	new
5	29	2026-03-18 22:36:47.921185	562.73	paid
6	29	2026-01-03 23:55:01.610243	802.89	paid
7	5	2026-01-01 14:22:39.701791	170.88	new
8	36	2026-01-12 06:01:31.706222	388.92	paid
9	1	2026-03-09 09:00:30.891866	685.79	paid
10	4	2026-03-30 05:31:55.563143	243.76	paid
11	22	2026-02-25 15:30:42.43608	978.12	paid
12	3	2026-01-26 13:46:44.681424	135.64	cancelled
13	22	2026-01-25 17:06:54.583702	302.91	paid
14	35	2026-03-17 05:07:13.978884	290.18	cancelled
15	4	2026-04-08 06:38:25.735302	975.55	new
16	30	2026-01-25 04:24:53.536068	368.57	paid
17	27	2026-01-11 19:02:02.083933	938.30	paid
18	34	2026-02-08 05:48:18.1049	611.24	paid
19	36	2026-01-06 15:39:59.461202	118.66	new
20	23	2026-03-16 03:01:21.276361	862.93	cancelled
21	6	2026-02-24 16:50:14.004963	458.48	new
22	22	2026-01-13 12:55:16.225674	432.44	new
23	2	2026-04-07 14:06:19.90514	497.82	cancelled
24	22	2026-03-11 01:32:49.432139	185.99	paid
25	28	2026-02-01 18:25:32.999344	449.89	cancelled
26	24	2026-01-28 18:23:08.17988	169.98	paid
27	32	2026-04-05 22:32:38.63125	297.18	new
28	28	2026-01-13 22:13:49.880827	859.66	cancelled
29	31	2026-02-18 04:27:07.59561	865.10	paid
30	23	2026-01-13 05:31:20.66521	849.48	paid
31	32	2026-04-06 18:47:54.858006	595.54	cancelled
32	4	2026-01-08 15:03:32.280627	598.43	paid
33	2	2026-01-22 23:31:28.265171	639.98	paid
34	30	2026-02-12 12:50:47.357674	992.91	new
35	28	2026-03-06 07:19:04.974897	246.70	new
36	31	2026-01-28 06:38:52.639147	616.20	new
37	28	2026-04-05 17:45:38.235198	59.01	paid
38	4	2026-02-12 01:13:35.746595	735.06	cancelled
39	4	2026-04-09 17:05:37.688812	441.42	cancelled
40	22	2026-02-19 02:22:08.93098	209.00	cancelled
41	35	2026-01-17 23:09:36.687421	457.75	cancelled
42	2	2026-01-17 23:02:11.92091	1500.00	new
44	3	2026-05-07 19:46:06.731766	2750.50	paid
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, product_name, price, category) FROM stdin;
1	— ©	428.07	Ќ ЇЁвЄЁ
2	‘¬Ґв ­ 	654.04	Њ®«®з­лҐ Їа®¤гЄвл
3	‘®«м	150.98	Ѓ Є «Ґп
4	‘®Є	765.28	Ќ ЇЁвЄЁ
5	‘ла	604.30	Њ®«®з­лҐ Їа®¤гЄвл
6	•«ҐЎ	359.89	•«ҐЎ®Ўг«®з­лҐ Ё§¤Ґ«Ёп
7	Ѓ ­ ­л	459.79	”агЄвл
8	Ѓ в®­	101.38	•«ҐЎ®Ўг«®з­лҐ Ё§¤Ґ«Ёп
9	ѓ®ўп¤Ё­ 	905.90	Њпб®
10	ѓаҐзЄ 	665.36	ЉагЇл
11	ђЁб	195.78	ЉагЇл
12	ЂЇҐ«мбЁ­л	511.68	”агЄвл
13	ђлЎ­®Ґ дЁ«Ґ	272.74	ђлЎ 
14	Љ®дҐ	492.32	Ќ ЇЁвЄЁ
15	ЉгаЁ­®Ґ дЁ«Ґ	625.07	Њпб®
16	ЉҐдЁа	570.84	Њ®«®з­лҐ Їа®¤гЄвл
17	Њ Є а®­л	583.13	Ѓ Є «Ґп
18	ЊЁ­Ґа «м­ п ў®¤ 	186.33	Ќ ЇЁвЄЁ
19	Џ®¬Ё¤®ал	933.58	Ћў®йЁ
20	џЎ«®ЄЁ	632.33	”агЄвл
\.


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customers_id_seq', 36, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_id_seq', 46, true);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: customers unique_email; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT unique_email UNIQUE (email);


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict 2feoPw3zUVByJlSTGOG9uUoZSMaMcvtqhYt5xLmehyFUQCYP3AhV9fQygnbHYv6

