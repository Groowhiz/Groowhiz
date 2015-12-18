--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: 1; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "1";


--
-- Name: postgrest; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA postgrest;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = postgrest, pg_catalog;

--
-- Name: check_role_exists(); Type: FUNCTION; Schema: postgrest; Owner: -
--

CREATE FUNCTION check_role_exists() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      begin 
      if not exists (select 1 from pg_roles as r where r.rolname = new.rolname) then
         raise foreign_key_violation using message = 'Cannot create user with unknown role: ' || new.rolname;
         return null;
       end if;
       return new;
      end
      $$;


--
-- Name: create_api_user(); Type: FUNCTION; Schema: postgrest; Owner: -
--

CREATE FUNCTION create_api_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      INSERT INTO postgrest.auth (id, rolname, pass) VALUES (new.id::text, CASE WHEN new.admin THEN 'admin' ELSE 'web_user' END, public.crypt(new.authentication_token, public.gen_salt('bf')));
      return new;
    END;
    $$;


--
-- Name: delete_api_user(); Type: FUNCTION; Schema: postgrest; Owner: -
--

CREATE FUNCTION delete_api_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      DELETE FROM postgrest.auth WHERE id = old.id::text;
      return old;
    END;
    $$;


--
-- Name: update_api_user(); Type: FUNCTION; Schema: postgrest; Owner: -
--

CREATE FUNCTION update_api_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      UPDATE postgrest.auth SET 
        id = new.id::text,
        rolname = CASE WHEN new.admin THEN 'admin' ELSE 'web_user' END, 
        pass = CASE WHEN new.authentication_token <> old.authentication_token THEN public.crypt(new.authentication_token, public.gen_salt('bf')) ELSE pass END
      WHERE id = old.id::text;
      return new;
    END;
    $$;


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: contributions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contributions (
    id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    reward_id integer,
    value numeric NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    anonymous boolean DEFAULT false NOT NULL,
    notified_finish boolean DEFAULT false,
    payer_name text,
    payer_email text NOT NULL,
    payer_document text,
    address_street text,
    address_number text,
    address_complement text,
    address_neighbourhood text,
    address_zip_code text,
    address_city text,
    address_state text,
    address_phone_number text,
    payment_choice text,
    payment_service_fee numeric,
    referral_link text,
    country_id integer,
    deleted_at timestamp without time zone,
    CONSTRAINT backers_value_positive CHECK ((value >= (0)::numeric))
);


--
-- Name: can_refund(contributions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION can_refund(contributions) RETURNS boolean
    LANGUAGE sql
    AS $_$
      SELECT
        $1.was_confirmed AND
        EXISTS(
          SELECT true
          FROM projects p
          WHERE p.id = $1.project_id and p.state = 'failed'
        )
    $_$;


--
-- Name: confirmed_states(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION confirmed_states() RETURNS text[]
    LANGUAGE sql
    AS $$
      SELECT '{"paid", "pending_refund", "refunded"}'::text[];
    $$;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    name text NOT NULL,
    user_id integer NOT NULL,
    category_id integer NOT NULL,
    goal numeric,
    headline text,
    video_url text,
    short_url text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    about_html text,
    recommended boolean DEFAULT false,
    home_page_comment text,
    permalink text NOT NULL,
    video_thumbnail text,
    state character varying(255),
    online_days integer,
    online_date timestamp with time zone,
    more_links text,
    first_contributions text,
    uploaded_image character varying(255),
    video_embed_url character varying(255),
    referral_link text,
    sent_to_analysis_at timestamp without time zone,
    audited_user_name text,
    audited_user_cpf text,
    audited_user_moip_login text,
    audited_user_phone_number text,
    sent_to_draft_at timestamp without time zone,
    rejected_at timestamp without time zone,
    traffic_sources text,
    budget text,
    full_text_index tsvector,
    budget_html text,
    expires_at timestamp without time zone,
    tagline text,
    project_start_date timestamp without time zone,
    project_end_date timestamp without time zone,
    city_id integer,
    country_id integer,
    state_id integer,
    genre_id integer
);


--
-- Name: img_thumbnail(projects); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION img_thumbnail(projects) RETURNS text
    LANGUAGE sql STABLE
    AS $_$ 
    SELECT 
      'https://' || (SELECT value FROM settings WHERE name = 'aws_host') || 
      '/' || (SELECT value FROM settings WHERE name = 'aws_bucket') ||
      '/uploads/project/uploaded_image/' || $1.id::text ||
      '/project_thumb_small_' || $1.uploaded_image
    $_$;


--
-- Name: is_confirmed(contributions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION is_confirmed(contributions) RETURNS boolean
    LANGUAGE sql
    AS $_$
      SELECT EXISTS (
        SELECT true
        FROM 
          payments p 
        WHERE p.contribution_id = $1.id AND p.state = 'paid'
      );
    $_$;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payments (
    id integer NOT NULL,
    contribution_id integer NOT NULL,
    state text NOT NULL,
    key text NOT NULL,
    gateway text NOT NULL,
    gateway_id text,
    gateway_fee numeric,
    gateway_data json,
    payment_method text NOT NULL,
    value numeric NOT NULL,
    installments integer DEFAULT 1 NOT NULL,
    installment_value numeric,
    paid_at timestamp without time zone,
    refused_at timestamp without time zone,
    pending_refund_at timestamp without time zone,
    refunded_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    full_text_index tsvector,
    deleted_at timestamp without time zone,
    chargeback_at timestamp without time zone
);


--
-- Name: is_second_slip(payments); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION is_second_slip(payments) RETURNS boolean
    LANGUAGE sql STABLE
    AS $_$
          SELECT lower($1.payment_method) = 'boletobancario' and EXISTS (select true from payments p
               where p.contribution_id = $1.contribution_id
               and p.id < $1.id
               and lower(p.payment_method) = 'boletobancario')
        $_$;


--
-- Name: rewards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rewards (
    id integer NOT NULL,
    project_id integer NOT NULL,
    minimum_value numeric NOT NULL,
    maximum_contributions integer,
    description text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    row_order integer,
    last_changes text,
    deliver_at timestamp without time zone,
    CONSTRAINT rewards_maximum_backers_positive CHECK ((maximum_contributions >= 0)),
    CONSTRAINT rewards_minimum_value_positive CHECK ((minimum_value >= (0)::numeric))
);


--
-- Name: paid_count(rewards); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION paid_count(rewards) RETURNS bigint
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
      SELECT count(*) 
      FROM payments p join contributions c on c.id = p.contribution_id 
      WHERE p.state = 'paid' AND c.reward_id = $1.id
    $_$;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email text,
    name text,
    newsletter boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    admin boolean DEFAULT false,
    address_street text,
    address_number text,
    address_complement text,
    address_neighbourhood text,
    address_city text,
    address_state text,
    address_zip_code text,
    phone_number text,
    locale text DEFAULT 'pt'::text NOT NULL,
    cpf text,
    encrypted_password character varying(128) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    twitter character varying(255),
    facebook_link character varying(255),
    other_link character varying(255),
    uploaded_image text,
    moip_login character varying(255),
    state_inscription character varying(255),
    channel_id integer,
    deactivated_at timestamp without time zone,
    reactivate_token text,
    address_country text,
    country_id integer,
    authentication_token text DEFAULT md5(((random())::text || (clock_timestamp())::text)) NOT NULL,
    zero_credits boolean DEFAULT false,
    about_html text,
    cover_image text,
    permalink text,
    subscribed_to_project_posts boolean DEFAULT true
);


--
-- Name: profile_img_thumbnail(users); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION profile_img_thumbnail(users) RETURNS text
    LANGUAGE sql STABLE
    AS $_$ 
    SELECT 
      'https://' || (SELECT value FROM settings WHERE name = 'aws_host') || 
      '/' || (SELECT value FROM settings WHERE name = 'aws_bucket') ||
      '/uploads/user/uploaded_image/' || $1.id::text ||
      '/thumb_avatar_' || $1.uploaded_image
    
    $_$;


--
-- Name: update_full_text_index(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_full_text_index() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      new.full_text_index :=  setweight(to_tsvector('portuguese', unaccent(coalesce(NEW.name::text, ''))), 'A') || 
                              setweight(to_tsvector('portuguese', unaccent(coalesce(NEW.permalink::text, ''))), 'C') || 
                              setweight(to_tsvector('portuguese', unaccent(coalesce(NEW.headline::text, ''))), 'B');
      new.full_text_index :=  new.full_text_index || setweight(to_tsvector('portuguese', unaccent(coalesce((SELECT c.name_pt FROM categories c WHERE c.id = NEW.category_id)::text, ''))), 'B');
      RETURN NEW;
    END;
    $$;


--
-- Name: update_payments_full_text_index(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_payments_full_text_index() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
     DECLARE
       v_contribution contributions;
       v_name text;
     BEGIN
       SELECT * INTO v_contribution FROM contributions c WHERE c.id = NEW.contribution_id;
       SELECT u.name INTO v_name FROM users u WHERE u.id = v_contribution.user_id;
       NEW.full_text_index :=  setweight(to_tsvector(unaccent(coalesce(NEW.key::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(NEW.gateway::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(NEW.gateway_id::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(NEW.state::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce((NEW.gateway_data->>'acquirer_name'), ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce((NEW.gateway_data->>'card_brand'), ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce((NEW.gateway_data->>'tid'), ''))), 'C');
       NEW.full_text_index :=  NEW.full_text_index ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.payer_email::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.payer_document::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.referral_link::text, ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.user_id::text, ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.project_id::text, ''))), 'C');
       NEW.full_text_index :=  NEW.full_text_index || setweight(to_tsvector(unaccent(coalesce(v_name::text, ''))), 'A');
       NEW.full_text_index :=  NEW.full_text_index || (SELECT full_text_index FROM projects p WHERE p.id = v_contribution.project_id);
       RETURN NEW;
     END;
    $$;


--
-- Name: uses_credits(payments); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION uses_credits(payments) RETURNS boolean
    LANGUAGE sql
    AS $_$
        SELECT $1.gateway = 'Credits';
      $_$;


--
-- Name: waiting_payment(payments); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION waiting_payment(payments) RETURNS boolean
    LANGUAGE sql STABLE
    AS $_$
            SELECT
                     $1.state = 'pending'
                     AND
                     (
                       SELECT count(1) AS total_of_days
                       FROM generate_series($1.created_at::date, current_date, '1 day') day
                       WHERE extract(dow from day) not in (0,1)
                     )  <= 4
           $_$;


--
-- Name: waiting_payment_count(rewards); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION waiting_payment_count(rewards) RETURNS bigint
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $_$
      SELECT count(*) 
      FROM payments p join contributions c on c.id = p.contribution_id 
      WHERE p.waiting_payment AND c.reward_id = $1.id
    $_$;


--
-- Name: was_confirmed(contributions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION was_confirmed(contributions) RETURNS boolean
    LANGUAGE sql
    AS $_$
      SELECT EXISTS (
        SELECT true
        FROM 
          payments p 
        WHERE p.contribution_id = $1.id AND p.state = ANY(confirmed_states())
      );
    $_$;


SET search_path = "1", pg_catalog;

--
-- Name: reward_details; Type: VIEW; Schema: 1; Owner: -
--

CREATE VIEW reward_details AS
 SELECT r.id,
    r.description,
    r.minimum_value,
    r.maximum_contributions,
    r.deliver_at,
    r.updated_at,
    public.paid_count(r.*) AS paid_count,
    public.waiting_payment_count(r.*) AS waiting_payment_count
   FROM public.rewards r;


--
-- Name: contribution_details; Type: VIEW; Schema: 1; Owner: -
--

CREATE VIEW contribution_details AS
 SELECT pa.id,
    c.id AS contribution_id,
    pa.id AS payment_id,
    c.user_id,
    c.project_id,
    c.reward_id,
    p.permalink,
    p.name AS project_name,
    public.img_thumbnail(p.*) AS project_img,
    p.online_date AS project_online_date,
    p.expires_at AS project_expires_at,
    p.state AS project_state,
    u.name AS user_name,
    public.profile_img_thumbnail(u.*) AS user_profile_img,
    u.email,
    c.anonymous,
    c.payer_email,
    pa.key,
    pa.value,
    pa.installments,
    pa.installment_value,
    pa.state,
    public.is_second_slip(pa.*) AS is_second_slip,
    pa.gateway,
    pa.gateway_id,
    pa.gateway_fee,
    pa.gateway_data,
    pa.payment_method,
    pa.created_at,
    pa.created_at AS pending_at,
    pa.paid_at,
    pa.refused_at,
    pa.pending_refund_at,
    pa.refunded_at,
    pa.full_text_index,
    row_to_json(r.*) AS reward
   FROM ((((public.projects p
     JOIN public.contributions c ON ((c.project_id = p.id)))
     JOIN public.payments pa ON ((c.id = pa.contribution_id)))
     JOIN public.users u ON ((c.user_id = u.id)))
     LEFT JOIN reward_details r ON ((r.id = c.reward_id)));


--
-- Name: contribution_reports; Type: VIEW; Schema: 1; Owner: -
--

CREATE VIEW contribution_reports AS
 SELECT b.project_id,
    u.name,
    replace((b.value)::text, '.'::text, ','::text) AS value,
    replace((r.minimum_value)::text, '.'::text, ','::text) AS minimum_value,
    r.description,
    p.gateway,
    (p.gateway_data -> 'acquirer_name'::text) AS acquirer_name,
    (p.gateway_data -> 'tid'::text) AS acquirer_tid,
    p.payment_method,
    replace((p.gateway_fee)::text, '.'::text, ','::text) AS payment_service_fee,
    p.key,
    (b.created_at)::date AS created_at,
    (p.paid_at)::date AS confirmed_at,
    u.email,
    b.payer_email,
    b.payer_name,
    COALESCE(b.payer_document, u.cpf) AS cpf,
    u.address_street,
    u.address_complement,
    u.address_number,
    u.address_neighbourhood,
    u.address_city,
    u.address_state,
    u.address_zip_code,
    p.state
   FROM (((public.contributions b
     JOIN public.users u ON ((u.id = b.user_id)))
     JOIN public.payments p ON ((p.contribution_id = b.id)))
     LEFT JOIN public.rewards r ON ((r.id = b.reward_id)))
  WHERE (p.state = ANY (ARRAY[('paid'::character varying)::text, ('refunded'::character varying)::text, ('pending_refund'::character varying)::text]));


SET search_path = public, pg_catalog;

--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    name text NOT NULL,
    value text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    CONSTRAINT configurations_name_not_blank CHECK ((length(btrim(name)) > 0))
);


SET search_path = "1", pg_catalog;

--
-- Name: contribution_reports_for_project_owners; Type: VIEW; Schema: 1; Owner: -
--

CREATE VIEW contribution_reports_for_project_owners AS
 SELECT b.project_id,
    COALESCE(r.id, 0) AS reward_id,
    p.user_id AS project_owner_id,
    r.description AS reward_description,
    (r.deliver_at)::date AS deliver_at,
    (pa.paid_at)::date AS confirmed_at,
    pa.value AS contribution_value,
    (pa.value * ( SELECT (settings.value)::numeric AS value
           FROM public.settings
          WHERE (settings.name = 'catarse_fee'::text))) AS service_fee,
    u.email AS user_email,
    COALESCE(b.payer_document, u.cpf) AS cpf,
    u.name AS user_name,
    b.payer_email,
    pa.gateway,
    b.anonymous,
    pa.state,
    public.waiting_payment(pa.*) AS waiting_payment,
    COALESCE(u.address_street, b.address_street) AS street,
    COALESCE(u.address_complement, b.address_complement) AS complement,
    COALESCE(u.address_number, b.address_number) AS address_number,
    COALESCE(u.address_neighbourhood, b.address_neighbourhood) AS neighbourhood,
    COALESCE(u.address_city, b.address_city) AS city,
    COALESCE(u.address_state, b.address_state) AS address_state,
    COALESCE(u.address_zip_code, b.address_zip_code) AS zip_code
   FROM ((((public.contributions b
     JOIN public.users u ON ((u.id = b.user_id)))
     JOIN public.projects p ON ((b.project_id = p.id)))
     JOIN public.payments pa ON ((pa.contribution_id = b.id)))
     LEFT JOIN public.rewards r ON ((r.id = b.reward_id)))
  WHERE (pa.state = ANY (ARRAY[('paid'::character varying)::text, ('pending'::character varying)::text]));


--
-- Name: project_totals; Type: TABLE; Schema: 1; Owner: -; Tablespace: 
--

CREATE TABLE project_totals (
    project_id integer,
    pledged numeric,
    progress numeric,
    total_payment_service_fee numeric,
    total_contributions bigint
);

ALTER TABLE ONLY project_totals REPLICA IDENTITY NOTHING;


--
-- Name: recommendations; Type: VIEW; Schema: 1; Owner: -
--

CREATE VIEW recommendations AS
 SELECT recommendations.user_id,
    recommendations.project_id,
    (sum(recommendations.count))::bigint AS count
   FROM ( SELECT b.user_id,
            recommendations_1.id AS project_id,
            count(DISTINCT recommenders.user_id) AS count
           FROM (((public.contributions b
             JOIN public.contributions backers_same_projects USING (project_id))
             JOIN public.contributions recommenders ON ((recommenders.user_id = backers_same_projects.user_id)))
             JOIN public.projects recommendations_1 ON ((recommendations_1.id = recommenders.project_id)))
          WHERE ((((((((public.was_confirmed(b.*) AND public.was_confirmed(backers_same_projects.*)) AND public.was_confirmed(recommenders.*)) AND (b.updated_at > (now() - '6 mons'::interval))) AND (recommenders.updated_at > (now() - '2 mons'::interval))) AND ((recommendations_1.state)::text = 'online'::text)) AND (b.user_id <> backers_same_projects.user_id)) AND (recommendations_1.id <> b.project_id)) AND (NOT (EXISTS ( SELECT true AS bool
                   FROM public.contributions b2
                  WHERE ((public.was_confirmed(b2.*) AND (b2.user_id = b.user_id)) AND (b2.project_id = recommendations_1.id))))))
          GROUP BY b.user_id, recommendations_1.id
        UNION
         SELECT b.user_id,
            recommendations_1.id AS project_id,
            0 AS count
           FROM ((public.contributions b
             JOIN public.projects p ON ((b.project_id = p.id)))
             JOIN public.projects recommendations_1 ON ((recommendations_1.category_id = p.category_id)))
          WHERE (public.was_confirmed(b.*) AND ((recommendations_1.state)::text = 'online'::text))) recommendations
  WHERE (NOT (EXISTS ( SELECT true AS bool
           FROM public.contributions b2
          WHERE ((public.was_confirmed(b2.*) AND (b2.user_id = recommendations.user_id)) AND (b2.project_id = recommendations.project_id)))))
  GROUP BY recommendations.user_id, recommendations.project_id
  ORDER BY (sum(recommendations.count))::bigint DESC;


--
-- Name: statistics; Type: MATERIALIZED VIEW; Schema: 1; Owner: -; Tablespace: 
--

CREATE MATERIALIZED VIEW statistics AS
 SELECT ( SELECT count(*) AS count
           FROM public.users) AS total_users,
    contributions_totals.total_contributions,
    contributions_totals.total_contributors,
    contributions_totals.total_contributed,
    projects_totals.total_projects,
    projects_totals.total_projects_success,
    projects_totals.total_projects_online
   FROM ( SELECT count(DISTINCT c.id) AS total_contributions,
            count(DISTINCT c.user_id) AS total_contributors,
            sum(p.value) AS total_contributed
           FROM (public.contributions c
             JOIN public.payments p ON ((p.contribution_id = c.id)))
          WHERE (p.state = ANY (public.confirmed_states()))) contributions_totals,
    ( SELECT count(*) AS total_projects,
            count(
                CASE
                    WHEN ((projects.state)::text = 'successful'::text) THEN 1
                    ELSE NULL::integer
                END) AS total_projects_success,
            count(
                CASE
                    WHEN ((projects.state)::text = 'online'::text) THEN 1
                    ELSE NULL::integer
                END) AS total_projects_online
           FROM public.projects
          WHERE ((projects.state)::text <> ALL (ARRAY[('draft'::character varying)::text, ('rejected'::character varying)::text]))) projects_totals
  WITH NO DATA;


--
-- Name: user_totals; Type: MATERIALIZED VIEW; Schema: 1; Owner: -; Tablespace: 
--

CREATE MATERIALIZED VIEW user_totals AS
 SELECT b.user_id AS id,
    b.user_id,
    count(DISTINCT b.project_id) AS total_contributed_projects,
    sum(pa.value) AS sum,
    count(DISTINCT b.id) AS count,
    sum(
        CASE
            WHEN (((p.state)::text <> 'failed'::text) AND (NOT public.uses_credits(pa.*))) THEN (0)::numeric
            WHEN (((p.state)::text = 'failed'::text) AND public.uses_credits(pa.*)) THEN (0)::numeric
            WHEN (((p.state)::text = 'failed'::text) AND (((pa.state = ANY (ARRAY[('pending_refund'::character varying)::text, ('refunded'::character varying)::text])) AND (NOT public.uses_credits(pa.*))) OR (public.uses_credits(pa.*) AND (NOT (pa.state = ANY (ARRAY[('pending_refund'::character varying)::text, ('refunded'::character varying)::text])))))) THEN (0)::numeric
            WHEN ((((p.state)::text = 'failed'::text) AND (NOT public.uses_credits(pa.*))) AND (pa.state = 'paid'::text)) THEN pa.value
            ELSE (pa.value * ((-1))::numeric)
        END) AS credits
   FROM ((public.contributions b
     JOIN public.payments pa ON ((b.id = pa.contribution_id)))
     JOIN public.projects p ON ((b.project_id = p.id)))
  WHERE (pa.state = ANY (public.confirmed_states()))
  GROUP BY b.user_id
  WITH NO DATA;


SET search_path = postgrest, pg_catalog;

--
-- Name: auth; Type: TABLE; Schema: postgrest; Owner: -; Tablespace: 
--

CREATE TABLE auth (
    id text NOT NULL,
    rolname name NOT NULL,
    pass character(60) NOT NULL
);


SET search_path = public, pg_catalog;

--
-- Name: authorizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authorizations (
    id integer NOT NULL,
    oauth_provider_id integer NOT NULL,
    user_id integer NOT NULL,
    uid text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone
);


--
-- Name: authorizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authorizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authorizations_id_seq OWNED BY authorizations.id;


--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bank_accounts (
    id integer NOT NULL,
    user_id integer,
    account text NOT NULL,
    agency text NOT NULL,
    owner_name text NOT NULL,
    owner_document text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    account_digit text NOT NULL,
    agency_digit text,
    bank_id integer NOT NULL
);


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bank_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bank_accounts_id_seq OWNED BY bank_accounts.id;


--
-- Name: banks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE banks (
    id integer NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone
);


--
-- Name: banks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE banks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: banks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE banks_id_seq OWNED BY banks.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    name_pt text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    name_en character varying(255),
    name_fr character varying(255),
    CONSTRAINT categories_name_not_blank CHECK ((length(btrim(name_pt)) > 0))
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: category_followers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE category_followers (
    id integer NOT NULL,
    category_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone
);


--
-- Name: category_followers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE category_followers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: category_followers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE category_followers_id_seq OWNED BY category_followers.id;


--
-- Name: category_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE category_notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    category_id integer NOT NULL,
    from_email text NOT NULL,
    from_name text NOT NULL,
    template_name text NOT NULL,
    locale text NOT NULL,
    sent_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    deliver_at timestamp without time zone DEFAULT now()
);


--
-- Name: category_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE category_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: category_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE category_notifications_id_seq OWNED BY category_notifications.id;


--
-- Name: channel_partners; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channel_partners (
    id integer NOT NULL,
    url text NOT NULL,
    image text NOT NULL,
    channel_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone
);


--
-- Name: channel_partners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channel_partners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channel_partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channel_partners_id_seq OWNED BY channel_partners.id;


--
-- Name: channel_post_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channel_post_notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    channel_post_id integer NOT NULL,
    from_email text NOT NULL,
    from_name text NOT NULL,
    template_name text NOT NULL,
    locale text NOT NULL,
    sent_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    deliver_at timestamp without time zone DEFAULT now()
);


--
-- Name: channel_post_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channel_post_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channel_post_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channel_post_notifications_id_seq OWNED BY channel_post_notifications.id;


--
-- Name: channel_posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channel_posts (
    id integer NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    body_html text NOT NULL,
    channel_id integer NOT NULL,
    user_id integer NOT NULL,
    visible boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    published_at timestamp without time zone
);


--
-- Name: channel_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channel_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channel_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channel_posts_id_seq OWNED BY channel_posts.id;


--
-- Name: channels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channels (
    id integer NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    permalink text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    twitter text,
    facebook text,
    email text,
    image text,
    website text,
    video_url text,
    how_it_works text,
    how_it_works_html text,
    terms_url character varying(255),
    video_embed_url text,
    ga_code text
);


--
-- Name: channels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channels_id_seq OWNED BY channels.id;


--
-- Name: channels_projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channels_projects (
    id integer NOT NULL,
    channel_id integer,
    project_id integer
);


--
-- Name: channels_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channels_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channels_projects_id_seq OWNED BY channels_projects.id;


--
-- Name: channels_subscribers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channels_subscribers (
    id integer NOT NULL,
    user_id integer NOT NULL,
    channel_id integer NOT NULL
);


--
-- Name: channels_subscribers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channels_subscribers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_subscribers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channels_subscribers_id_seq OWNED BY channels_subscribers.id;


--
-- Name: cities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cities (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    acronym character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone
);


--
-- Name: cities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cities_id_seq OWNED BY cities.id;


--
-- Name: configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE configurations_id_seq OWNED BY settings.id;


--
-- Name: contribution_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contribution_notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    contribution_id integer NOT NULL,
    from_email text NOT NULL,
    from_name text NOT NULL,
    template_name text NOT NULL,
    locale text NOT NULL,
    sent_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    deliver_at timestamp without time zone DEFAULT now()
);


--
-- Name: contribution_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contribution_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contribution_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contribution_notifications_id_seq OWNED BY contribution_notifications.id;


--
-- Name: contributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contributions_id_seq OWNED BY contributions.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


--
-- Name: credit_cards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE credit_cards (
    id integer NOT NULL,
    user_id integer,
    last_digits text NOT NULL,
    card_brand text NOT NULL,
    subscription_id text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    card_key text
);


--
-- Name: credit_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE credit_cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: credit_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE credit_cards_id_seq OWNED BY credit_cards.id;


--
-- Name: dbhero_dataclips; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE dbhero_dataclips (
    id integer NOT NULL,
    description text NOT NULL,
    raw_query text NOT NULL,
    token text NOT NULL,
    "user" text,
    private boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: dbhero_dataclips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dbhero_dataclips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dbhero_dataclips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dbhero_dataclips_id_seq OWNED BY dbhero_dataclips.id;


--
-- Name: financial_reports; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW financial_reports AS
 SELECT p.name,
    u.moip_login,
    p.goal,
    p.expires_at,
    p.state
   FROM (projects p
     JOIN users u ON ((u.id = p.user_id)));


--
-- Name: genres; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE genres (
    id integer NOT NULL,
    name_pt text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    name_en character varying(255),
    name_fr character varying(255)
);


--
-- Name: genres_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE genres_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: genres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE genres_id_seq OWNED BY genres.id;


--
-- Name: job_perks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job_perks (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: job_perks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_perks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_perks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_perks_id_seq OWNED BY job_perks.id;


--
-- Name: job_rewards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job_rewards (
    id integer NOT NULL,
    job_reward_name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: job_rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_rewards_id_seq OWNED BY job_rewards.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE jobs (
    id integer NOT NULL,
    job_name character varying(255),
    project_id integer,
    category_id integer,
    job_description character varying(255),
    gender character varying(255),
    job_count integer,
    duration integer,
    status character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    permalink text,
    job_start_date timestamp without time zone,
    job_end_date timestamp without time zone,
    job_reward_id integer,
    row_order integer,
    last_changes text
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: oauth_providers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_providers (
    id integer NOT NULL,
    name text NOT NULL,
    key text NOT NULL,
    secret text NOT NULL,
    scope text,
    "order" integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    strategy text,
    path text,
    CONSTRAINT oauth_providers_key_not_blank CHECK ((length(btrim(key)) > 0)),
    CONSTRAINT oauth_providers_name_not_blank CHECK ((length(btrim(name)) > 0)),
    CONSTRAINT oauth_providers_secret_not_blank CHECK ((length(btrim(secret)) > 0))
);


--
-- Name: oauth_providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_providers_id_seq OWNED BY oauth_providers.id;


--
-- Name: payment_logs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payment_logs (
    id integer NOT NULL,
    gateway_id character varying(255) NOT NULL,
    data json NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: payment_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_logs_id_seq OWNED BY payment_logs.id;


--
-- Name: payment_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payment_notifications (
    id integer NOT NULL,
    contribution_id integer NOT NULL,
    extra_data text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    payment_id integer
);


--
-- Name: payment_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_notifications_id_seq OWNED BY payment_notifications.id;


--
-- Name: payment_transfers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payment_transfers (
    id integer NOT NULL,
    user_id integer NOT NULL,
    payment_id integer NOT NULL,
    transfer_id text NOT NULL,
    transfer_data json,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: payment_transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_transfers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_transfers_id_seq OWNED BY payment_transfers.id;


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payments_id_seq OWNED BY payments.id;


--
-- Name: paypal_payments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE paypal_payments (
    data text,
    hora text,
    fusohorario text,
    nome text,
    tipo text,
    status text,
    moeda text,
    valorbruto text,
    tarifa text,
    liquido text,
    doe_mail text,
    parae_mail text,
    iddatransacao text,
    statusdoequivalente text,
    statusdoendereco text,
    titulodoitem text,
    iddoitem text,
    valordoenvioemanuseio text,
    valordoseguro text,
    impostosobrevendas text,
    opcao1nome text,
    opcao1valor text,
    opcao2nome text,
    opcao2valor text,
    sitedoleilao text,
    iddocomprador text,
    urldoitem text,
    datadetermino text,
    iddaescritura text,
    iddafatura text,
    "idtxn_dereferência" text,
    numerodafatura text,
    numeropersonalizado text,
    iddorecibo text,
    saldo text,
    enderecolinha1 text,
    enderecolinha2_distrito_bairro text,
    cidade text,
    "estado_regiao_território_prefeitura_republica" text,
    cep text,
    pais text,
    numerodotelefoneparacontato text,
    extra text
);


--
-- Name: project_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_accounts (
    id integer NOT NULL,
    project_id integer NOT NULL,
    bank_id integer,
    email text NOT NULL,
    state_inscription text,
    address_street text NOT NULL,
    address_number text NOT NULL,
    address_complement text,
    address_city text NOT NULL,
    address_neighbourhood text NOT NULL,
    address_state text NOT NULL,
    address_zip_code text NOT NULL,
    phone_number text NOT NULL,
    agency text NOT NULL,
    agency_digit text NOT NULL,
    account text NOT NULL,
    account_digit text NOT NULL,
    owner_name text NOT NULL,
    owner_document text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    account_type text
);


--
-- Name: project_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_accounts_id_seq OWNED BY project_accounts.id;


--
-- Name: project_budgets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_budgets (
    id integer NOT NULL,
    project_id integer NOT NULL,
    name text NOT NULL,
    value numeric(8,2) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone
);


--
-- Name: project_budgets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_budgets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_budgets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_budgets_id_seq OWNED BY project_budgets.id;


--
-- Name: project_financials; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_financials AS
 WITH catarse_fee_percentage AS (
         SELECT (c.value)::numeric AS total,
            ((1)::numeric - (c.value)::numeric) AS complement
           FROM settings c
          WHERE (c.name = 'catarse_fee'::text)
        ), catarse_base_url AS (
         SELECT c.value
           FROM settings c
          WHERE (c.name = 'base_url'::text)
        )
 SELECT p.id AS project_id,
    p.name,
    u.moip_login AS moip,
    p.goal,
    pt.pledged AS reached,
    pt.total_payment_service_fee AS payment_tax,
    (cp.total * pt.pledged) AS catarse_fee,
    (pt.pledged * cp.complement) AS repass_value,
    to_char(timezone(COALESCE(( SELECT settings.value
           FROM settings
          WHERE (settings.name = 'timezone'::text)), 'America/Sao_Paulo'::text), p.expires_at), 'dd/mm/yyyy'::text) AS expires_at,
    ((catarse_base_url.value || '/admin/reports/contribution_reports.csv?project_id='::text) || p.id) AS contribution_report,
    p.state
   FROM ((((projects p
     JOIN users u ON ((u.id = p.user_id)))
     LEFT JOIN "1".project_totals pt ON ((pt.project_id = p.id)))
     CROSS JOIN catarse_fee_percentage cp)
     CROSS JOIN catarse_base_url);


--
-- Name: project_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer NOT NULL,
    from_email text NOT NULL,
    from_name text NOT NULL,
    template_name text NOT NULL,
    locale text NOT NULL,
    sent_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    deliver_at timestamp without time zone DEFAULT now()
);


--
-- Name: project_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_notifications_id_seq OWNED BY project_notifications.id;


--
-- Name: project_post_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_post_notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_post_id integer NOT NULL,
    from_email text NOT NULL,
    from_name text NOT NULL,
    template_name text NOT NULL,
    locale text NOT NULL,
    sent_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    deliver_at timestamp without time zone DEFAULT now()
);


--
-- Name: project_post_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_post_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_post_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_post_notifications_id_seq OWNED BY project_post_notifications.id;


--
-- Name: project_posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_posts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer NOT NULL,
    title text NOT NULL,
    comment_html text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    exclusive boolean DEFAULT false
);


--
-- Name: projects_for_home; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW projects_for_home AS
 WITH recommended_projects AS (
         SELECT 'recommended'::text AS origin,
            recommends.id,
            recommends.name,
            recommends.expires_at,
            recommends.user_id,
            recommends.category_id,
            recommends.goal,
            recommends.headline,
            recommends.video_url,
            recommends.short_url,
            recommends.created_at,
            recommends.updated_at,
            recommends.about_html,
            recommends.recommended,
            recommends.home_page_comment,
            recommends.permalink,
            recommends.video_thumbnail,
            recommends.state,
            recommends.online_days,
            recommends.online_date,
            recommends.traffic_sources,
            recommends.more_links,
            recommends.first_contributions AS first_backers,
            recommends.uploaded_image,
            recommends.video_embed_url
           FROM projects recommends
          WHERE (recommends.recommended AND ((recommends.state)::text = 'online'::text))
          ORDER BY random()
         LIMIT 3
        ), recents_projects AS (
         SELECT 'recents'::text AS origin,
            recents.id,
            recents.name,
            recents.expires_at,
            recents.user_id,
            recents.category_id,
            recents.goal,
            recents.headline,
            recents.video_url,
            recents.short_url,
            recents.created_at,
            recents.updated_at,
            recents.about_html,
            recents.recommended,
            recents.home_page_comment,
            recents.permalink,
            recents.video_thumbnail,
            recents.state,
            recents.online_days,
            recents.online_date,
            recents.traffic_sources,
            recents.more_links,
            recents.first_contributions AS first_backers,
            recents.uploaded_image,
            recents.video_embed_url
           FROM projects recents
          WHERE ((((recents.state)::text = 'online'::text) AND ((now() - recents.online_date) <= '5 days'::interval)) AND (NOT (recents.id IN ( SELECT recommends.id
                   FROM recommended_projects recommends))))
          ORDER BY random()
         LIMIT 3
        ), expiring_projects AS (
         SELECT 'expiring'::text AS origin,
            expiring.id,
            expiring.name,
            expiring.expires_at,
            expiring.user_id,
            expiring.category_id,
            expiring.goal,
            expiring.headline,
            expiring.video_url,
            expiring.short_url,
            expiring.created_at,
            expiring.updated_at,
            expiring.about_html,
            expiring.recommended,
            expiring.home_page_comment,
            expiring.permalink,
            expiring.video_thumbnail,
            expiring.state,
            expiring.online_days,
            expiring.online_date,
            expiring.traffic_sources,
            expiring.more_links,
            expiring.first_contributions AS first_backers,
            expiring.uploaded_image,
            expiring.video_embed_url
           FROM projects expiring
          WHERE ((((expiring.state)::text = 'online'::text) AND (expiring.expires_at <= (now() + '14 days'::interval))) AND (NOT (expiring.id IN ( SELECT recommends.id
                   FROM recommended_projects recommends
                UNION
                 SELECT recents.id
                   FROM recents_projects recents))))
          ORDER BY random()
         LIMIT 3
        )
 SELECT recommended_projects.origin,
    recommended_projects.id,
    recommended_projects.name,
    recommended_projects.expires_at,
    recommended_projects.user_id,
    recommended_projects.category_id,
    recommended_projects.goal,
    recommended_projects.headline,
    recommended_projects.video_url,
    recommended_projects.short_url,
    recommended_projects.created_at,
    recommended_projects.updated_at,
    recommended_projects.about_html,
    recommended_projects.recommended,
    recommended_projects.home_page_comment,
    recommended_projects.permalink,
    recommended_projects.video_thumbnail,
    recommended_projects.state,
    recommended_projects.online_days,
    recommended_projects.online_date,
    recommended_projects.traffic_sources,
    recommended_projects.more_links,
    recommended_projects.first_backers,
    recommended_projects.uploaded_image,
    recommended_projects.video_embed_url
   FROM recommended_projects
UNION
 SELECT recents_projects.origin,
    recents_projects.id,
    recents_projects.name,
    recents_projects.expires_at,
    recents_projects.user_id,
    recents_projects.category_id,
    recents_projects.goal,
    recents_projects.headline,
    recents_projects.video_url,
    recents_projects.short_url,
    recents_projects.created_at,
    recents_projects.updated_at,
    recents_projects.about_html,
    recents_projects.recommended,
    recents_projects.home_page_comment,
    recents_projects.permalink,
    recents_projects.video_thumbnail,
    recents_projects.state,
    recents_projects.online_days,
    recents_projects.online_date,
    recents_projects.traffic_sources,
    recents_projects.more_links,
    recents_projects.first_backers,
    recents_projects.uploaded_image,
    recents_projects.video_embed_url
   FROM recents_projects
UNION
 SELECT expiring_projects.origin,
    expiring_projects.id,
    expiring_projects.name,
    expiring_projects.expires_at,
    expiring_projects.user_id,
    expiring_projects.category_id,
    expiring_projects.goal,
    expiring_projects.headline,
    expiring_projects.video_url,
    expiring_projects.short_url,
    expiring_projects.created_at,
    expiring_projects.updated_at,
    expiring_projects.about_html,
    expiring_projects.recommended,
    expiring_projects.home_page_comment,
    expiring_projects.permalink,
    expiring_projects.video_thumbnail,
    expiring_projects.state,
    expiring_projects.online_days,
    expiring_projects.online_date,
    expiring_projects.traffic_sources,
    expiring_projects.more_links,
    expiring_projects.first_backers,
    expiring_projects.uploaded_image,
    expiring_projects.video_embed_url
   FROM expiring_projects;


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: projects_in_analysis_by_periods; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW projects_in_analysis_by_periods AS
 WITH weeks AS (
         SELECT to_char(current_year_1.current_year, 'yyyy-mm W'::text) AS current_year,
            to_char(last_year_1.last_year, 'yyyy-mm W'::text) AS last_year,
            current_year_1.current_year AS label
           FROM (generate_series((now() - '49 days'::interval), now(), '7 days'::interval) current_year_1(current_year)
             JOIN generate_series((now() - '1 year 49 days'::interval), (now() - '1 year'::interval), '7 days'::interval) last_year_1(last_year) ON ((to_char(last_year_1.last_year, 'mm W'::text) = to_char(current_year_1.current_year, 'mm W'::text))))
        ), current_year AS (
         SELECT w.label,
            count(*) AS current_year
           FROM (projects p
             JOIN weeks w ON ((w.current_year = to_char(p.sent_to_analysis_at, 'yyyy-mm W'::text))))
          GROUP BY w.label
        ), last_year AS (
         SELECT w.label,
            count(*) AS last_year
           FROM (projects p
             JOIN weeks w ON ((w.last_year = to_char(p.sent_to_analysis_at, 'yyyy-mm W'::text))))
          GROUP BY w.label
        )
 SELECT current_year.label,
    current_year.current_year,
    last_year.last_year
   FROM (current_year
     JOIN last_year USING (label));


--
-- Name: redactor_assets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE redactor_assets (
    id integer NOT NULL,
    user_id integer,
    data_file_name character varying(255) NOT NULL,
    data_content_type character varying(255),
    data_file_size integer,
    assetable_id integer,
    assetable_type character varying(30),
    type character varying(30),
    width integer,
    height integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone
);


--
-- Name: redactor_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE redactor_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: redactor_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE redactor_assets_id_seq OWNED BY redactor_assets.id;


--
-- Name: rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rewards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rewards_id_seq OWNED BY rewards.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE states (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    acronym character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    CONSTRAINT states_acronym_not_blank CHECK ((length(btrim((acronym)::text)) > 0)),
    CONSTRAINT states_name_not_blank CHECK ((length(btrim((name)::text)) > 0))
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE states_id_seq OWNED BY states.id;


--
-- Name: subscriber_reports; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW subscriber_reports AS
 SELECT u.id,
    cs.channel_id,
    u.name,
    u.email
   FROM (users u
     JOIN channels_subscribers cs ON ((cs.user_id = u.id)));


--
-- Name: talent_images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE talent_images (
    id integer NOT NULL,
    talent_id integer,
    user_id integer,
    image_url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: talent_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE talent_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: talent_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE talent_images_id_seq OWNED BY talent_images.id;


--
-- Name: talent_videos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE talent_videos (
    id integer NOT NULL,
    talent_id integer,
    user_id integer,
    video_url text,
    video_thumbnail text,
    video_embed_url character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: talent_videos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE talent_videos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: talent_videos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE talent_videos_id_seq OWNED BY talent_videos.id;


--
-- Name: talents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE talents (
    id integer NOT NULL,
    title character varying(255),
    description text,
    category_id integer,
    user_id integer,
    recommended boolean DEFAULT false,
    state character varying(255) DEFAULT 'published'::character varying,
    permalink character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    genre_id integer
);


--
-- Name: talents_for_home; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW talents_for_home AS
 WITH recommended_talents AS (
         SELECT 'recommended'::text AS origin,
            recommends.id,
            recommends.title,
            recommends.description,
            recommends.category_id,
            recommends.user_id,
            recommends.recommended,
            recommends.state,
            recommends.permalink,
            recommends.created_at,
            recommends.updated_at
           FROM talents recommends
          WHERE (recommends.recommended AND ((recommends.state)::text = 'published'::text))
          ORDER BY random()
         LIMIT 3
        ), recents_talents AS (
         SELECT 'recents'::text AS origin,
            recents.id,
            recents.title,
            recents.description,
            recents.category_id,
            recents.user_id,
            recents.recommended,
            recents.state,
            recents.permalink,
            recents.created_at,
            recents.updated_at
           FROM talents recents
          WHERE ((((recents.state)::text = 'published'::text) AND ((now() - (recents.created_at)::timestamp with time zone) <= '5 days'::interval)) AND (NOT (recents.id IN ( SELECT recommends.id
                   FROM recommended_talents recommends))))
          ORDER BY random()
         LIMIT 3
        )
 SELECT recommended_talents.origin,
    recommended_talents.id,
    recommended_talents.title,
    recommended_talents.description,
    recommended_talents.category_id,
    recommended_talents.user_id,
    recommended_talents.recommended,
    recommended_talents.state,
    recommended_talents.permalink,
    recommended_talents.created_at,
    recommended_talents.updated_at
   FROM recommended_talents
UNION
 SELECT recents_talents.origin,
    recents_talents.id,
    recents_talents.title,
    recents_talents.description,
    recents_talents.category_id,
    recents_talents.user_id,
    recents_talents.recommended,
    recents_talents.state,
    recents_talents.permalink,
    recents_talents.created_at,
    recents_talents.updated_at
   FROM recents_talents;


--
-- Name: talents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE talents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: talents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE talents_id_seq OWNED BY talents.id;


--
-- Name: total_backed_ranges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE total_backed_ranges (
    name text NOT NULL,
    lower numeric,
    upper numeric
);


--
-- Name: unsubscribes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE unsubscribes (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: unsubscribes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE unsubscribes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unsubscribes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE unsubscribes_id_seq OWNED BY unsubscribes.id;


--
-- Name: updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE updates_id_seq OWNED BY project_posts.id;


--
-- Name: user_links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_links (
    id integer NOT NULL,
    link text NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone
);


--
-- Name: user_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_links_id_seq OWNED BY user_links.id;


--
-- Name: user_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    from_email text NOT NULL,
    from_name text NOT NULL,
    template_name text NOT NULL,
    locale text NOT NULL,
    sent_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone,
    deliver_at timestamp without time zone DEFAULT now()
);


--
-- Name: user_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_notifications_id_seq OWNED BY user_notifications.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations ALTER COLUMN id SET DEFAULT nextval('authorizations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bank_accounts ALTER COLUMN id SET DEFAULT nextval('bank_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY banks ALTER COLUMN id SET DEFAULT nextval('banks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY category_followers ALTER COLUMN id SET DEFAULT nextval('category_followers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY category_notifications ALTER COLUMN id SET DEFAULT nextval('category_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channel_partners ALTER COLUMN id SET DEFAULT nextval('channel_partners_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channel_post_notifications ALTER COLUMN id SET DEFAULT nextval('channel_post_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channel_posts ALTER COLUMN id SET DEFAULT nextval('channel_posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels ALTER COLUMN id SET DEFAULT nextval('channels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_projects ALTER COLUMN id SET DEFAULT nextval('channels_projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_subscribers ALTER COLUMN id SET DEFAULT nextval('channels_subscribers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cities ALTER COLUMN id SET DEFAULT nextval('cities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contribution_notifications ALTER COLUMN id SET DEFAULT nextval('contribution_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions ALTER COLUMN id SET DEFAULT nextval('contributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY credit_cards ALTER COLUMN id SET DEFAULT nextval('credit_cards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dbhero_dataclips ALTER COLUMN id SET DEFAULT nextval('dbhero_dataclips_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY genres ALTER COLUMN id SET DEFAULT nextval('genres_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_perks ALTER COLUMN id SET DEFAULT nextval('job_perks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_rewards ALTER COLUMN id SET DEFAULT nextval('job_rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs ALTER COLUMN id SET DEFAULT nextval('jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_providers ALTER COLUMN id SET DEFAULT nextval('oauth_providers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_logs ALTER COLUMN id SET DEFAULT nextval('payment_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_notifications ALTER COLUMN id SET DEFAULT nextval('payment_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_transfers ALTER COLUMN id SET DEFAULT nextval('payment_transfers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments ALTER COLUMN id SET DEFAULT nextval('payments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_accounts ALTER COLUMN id SET DEFAULT nextval('project_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_budgets ALTER COLUMN id SET DEFAULT nextval('project_budgets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_notifications ALTER COLUMN id SET DEFAULT nextval('project_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_post_notifications ALTER COLUMN id SET DEFAULT nextval('project_post_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_posts ALTER COLUMN id SET DEFAULT nextval('updates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY redactor_assets ALTER COLUMN id SET DEFAULT nextval('redactor_assets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rewards ALTER COLUMN id SET DEFAULT nextval('rewards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('configurations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY talent_images ALTER COLUMN id SET DEFAULT nextval('talent_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY talent_videos ALTER COLUMN id SET DEFAULT nextval('talent_videos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY talents ALTER COLUMN id SET DEFAULT nextval('talents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY unsubscribes ALTER COLUMN id SET DEFAULT nextval('unsubscribes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_links ALTER COLUMN id SET DEFAULT nextval('user_links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_notifications ALTER COLUMN id SET DEFAULT nextval('user_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


SET search_path = postgrest, pg_catalog;

--
-- Name: auth_pkey; Type: CONSTRAINT; Schema: postgrest; Owner: -; Tablespace: 
--

ALTER TABLE ONLY auth
    ADD CONSTRAINT auth_pkey PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- Name: authorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT authorizations_pkey PRIMARY KEY (id);


--
-- Name: bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bank_accounts
    ADD CONSTRAINT bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: banks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY banks
    ADD CONSTRAINT banks_pkey PRIMARY KEY (id);


--
-- Name: categories_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_name_unique UNIQUE (name_pt);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: category_followers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY category_followers
    ADD CONSTRAINT category_followers_pkey PRIMARY KEY (id);


--
-- Name: category_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY category_notifications
    ADD CONSTRAINT category_notifications_pkey PRIMARY KEY (id);


--
-- Name: channel_partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channel_partners
    ADD CONSTRAINT channel_partners_pkey PRIMARY KEY (id);


--
-- Name: channel_post_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channel_post_notifications
    ADD CONSTRAINT channel_post_notifications_pkey PRIMARY KEY (id);


--
-- Name: channel_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channel_posts
    ADD CONSTRAINT channel_posts_pkey PRIMARY KEY (id);


--
-- Name: channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);


--
-- Name: channels_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channels_projects
    ADD CONSTRAINT channels_projects_pkey PRIMARY KEY (id);


--
-- Name: channels_subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channels_subscribers
    ADD CONSTRAINT channels_subscribers_pkey PRIMARY KEY (id);


--
-- Name: cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT configurations_pkey PRIMARY KEY (id);


--
-- Name: contribution_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contribution_notifications
    ADD CONSTRAINT contribution_notifications_pkey PRIMARY KEY (id);


--
-- Name: contributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT contributions_pkey PRIMARY KEY (id);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: credit_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY credit_cards
    ADD CONSTRAINT credit_cards_pkey PRIMARY KEY (id);


--
-- Name: dbhero_dataclips_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dbhero_dataclips
    ADD CONSTRAINT dbhero_dataclips_pkey PRIMARY KEY (id);


--
-- Name: genres_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY genres
    ADD CONSTRAINT genres_pkey PRIMARY KEY (id);


--
-- Name: job_perks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job_perks
    ADD CONSTRAINT job_perks_pkey PRIMARY KEY (id);


--
-- Name: job_rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job_rewards
    ADD CONSTRAINT job_rewards_pkey PRIMARY KEY (id);


--
-- Name: jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: oauth_providers_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_providers
    ADD CONSTRAINT oauth_providers_name_unique UNIQUE (name);


--
-- Name: oauth_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_providers
    ADD CONSTRAINT oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: payment_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payment_logs
    ADD CONSTRAINT payment_logs_pkey PRIMARY KEY (id);


--
-- Name: payment_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payment_notifications
    ADD CONSTRAINT payment_notifications_pkey PRIMARY KEY (id);


--
-- Name: payment_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payment_transfers
    ADD CONSTRAINT payment_transfers_pkey PRIMARY KEY (id);


--
-- Name: payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: project_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_accounts
    ADD CONSTRAINT project_accounts_pkey PRIMARY KEY (id);


--
-- Name: project_budgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_budgets
    ADD CONSTRAINT project_budgets_pkey PRIMARY KEY (id);


--
-- Name: project_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_notifications
    ADD CONSTRAINT project_notifications_pkey PRIMARY KEY (id);


--
-- Name: project_post_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_post_notifications
    ADD CONSTRAINT project_post_notifications_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: redactor_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY redactor_assets
    ADD CONSTRAINT redactor_assets_pkey PRIMARY KEY (id);


--
-- Name: rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: states_acronym_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_acronym_unique UNIQUE (acronym);


--
-- Name: states_name_unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_name_unique UNIQUE (name);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: talent_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY talent_images
    ADD CONSTRAINT talent_images_pkey PRIMARY KEY (id);


--
-- Name: talent_videos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY talent_videos
    ADD CONSTRAINT talent_videos_pkey PRIMARY KEY (id);


--
-- Name: talents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY talents
    ADD CONSTRAINT talents_pkey PRIMARY KEY (id);


--
-- Name: total_backed_ranges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY total_backed_ranges
    ADD CONSTRAINT total_backed_ranges_pkey PRIMARY KEY (name);


--
-- Name: unsubscribes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_pkey PRIMARY KEY (id);


--
-- Name: updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_posts
    ADD CONSTRAINT updates_pkey PRIMARY KEY (id);


--
-- Name: user_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_links
    ADD CONSTRAINT user_links_pkey PRIMARY KEY (id);


--
-- Name: user_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_notifications
    ADD CONSTRAINT user_notifications_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: cities_acronym_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX cities_acronym_unique ON cities USING btree (acronym);


--
-- Name: cities_name_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX cities_name_unique ON cities USING btree (name);


--
-- Name: fk__authorizations_oauth_provider_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__authorizations_oauth_provider_id ON authorizations USING btree (oauth_provider_id);


--
-- Name: fk__authorizations_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__authorizations_user_id ON authorizations USING btree (user_id);


--
-- Name: fk__bank_accounts_bank_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__bank_accounts_bank_id ON bank_accounts USING btree (bank_id);


--
-- Name: fk__category_notifications_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__category_notifications_category_id ON category_notifications USING btree (category_id);


--
-- Name: fk__category_notifications_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__category_notifications_user_id ON category_notifications USING btree (user_id);


--
-- Name: fk__channel_partners_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__channel_partners_channel_id ON channel_partners USING btree (channel_id);


--
-- Name: fk__channel_post_notifications_channel_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__channel_post_notifications_channel_post_id ON channel_post_notifications USING btree (channel_post_id);


--
-- Name: fk__channel_post_notifications_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__channel_post_notifications_user_id ON channel_post_notifications USING btree (user_id);


--
-- Name: fk__channels_subscribers_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__channels_subscribers_channel_id ON channels_subscribers USING btree (channel_id);


--
-- Name: fk__channels_subscribers_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__channels_subscribers_user_id ON channels_subscribers USING btree (user_id);


--
-- Name: fk__contribution_notifications_contribution_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__contribution_notifications_contribution_id ON contribution_notifications USING btree (contribution_id);


--
-- Name: fk__contribution_notifications_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__contribution_notifications_user_id ON contribution_notifications USING btree (user_id);


--
-- Name: fk__contributions_country_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__contributions_country_id ON contributions USING btree (country_id);


--
-- Name: fk__jobs_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__jobs_category_id ON jobs USING btree (category_id);


--
-- Name: fk__jobs_job_reward_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__jobs_job_reward_id ON jobs USING btree (job_reward_id);


--
-- Name: fk__jobs_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__jobs_project_id ON jobs USING btree (project_id);


--
-- Name: fk__payment_notifications_payment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__payment_notifications_payment_id ON payment_notifications USING btree (payment_id);


--
-- Name: fk__payment_transfers_payment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__payment_transfers_payment_id ON payment_transfers USING btree (payment_id);


--
-- Name: fk__payment_transfers_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__payment_transfers_user_id ON payment_transfers USING btree (user_id);


--
-- Name: fk__payments_contribution_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__payments_contribution_id ON payments USING btree (contribution_id);


--
-- Name: fk__project_accounts_bank_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__project_accounts_bank_id ON project_accounts USING btree (bank_id);


--
-- Name: fk__project_budgets_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__project_budgets_project_id ON project_budgets USING btree (project_id);


--
-- Name: fk__project_notifications_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__project_notifications_project_id ON project_notifications USING btree (project_id);


--
-- Name: fk__project_notifications_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__project_notifications_user_id ON project_notifications USING btree (user_id);


--
-- Name: fk__project_post_notifications_project_post_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__project_post_notifications_project_post_id ON project_post_notifications USING btree (project_post_id);


--
-- Name: fk__project_post_notifications_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__project_post_notifications_user_id ON project_post_notifications USING btree (user_id);


--
-- Name: fk__projects_city_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__projects_city_id ON projects USING btree (city_id);


--
-- Name: fk__projects_country_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__projects_country_id ON projects USING btree (country_id);


--
-- Name: fk__projects_genre_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__projects_genre_id ON projects USING btree (genre_id);


--
-- Name: fk__projects_state_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__projects_state_id ON projects USING btree (state_id);


--
-- Name: fk__redactor_assets_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__redactor_assets_user_id ON redactor_assets USING btree (user_id);


--
-- Name: fk__talent_images_talent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__talent_images_talent_id ON talent_images USING btree (talent_id);


--
-- Name: fk__talent_images_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__talent_images_user_id ON talent_images USING btree (user_id);


--
-- Name: fk__talent_videos_talent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__talent_videos_talent_id ON talent_videos USING btree (talent_id);


--
-- Name: fk__talent_videos_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__talent_videos_user_id ON talent_videos USING btree (user_id);


--
-- Name: fk__talents_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__talents_category_id ON talents USING btree (category_id);


--
-- Name: fk__talents_genre_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__talents_genre_id ON talents USING btree (genre_id);


--
-- Name: fk__talents_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__talents_user_id ON talents USING btree (user_id);


--
-- Name: fk__user_links_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__user_links_user_id ON user_links USING btree (user_id);


--
-- Name: fk__user_notifications_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__user_notifications_user_id ON user_notifications USING btree (user_id);


--
-- Name: fk__users_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__users_channel_id ON users USING btree (channel_id);


--
-- Name: fk__users_country_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk__users_country_id ON users USING btree (country_id);


--
-- Name: idx_redactor_assetable; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_redactor_assetable ON redactor_assets USING btree (assetable_type, assetable_id);


--
-- Name: idx_redactor_assetable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_redactor_assetable_type ON redactor_assets USING btree (assetable_type, type, assetable_id);


--
-- Name: index_authorizations_on_oauth_provider_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_authorizations_on_oauth_provider_id_and_user_id ON authorizations USING btree (oauth_provider_id, user_id);


--
-- Name: index_authorizations_on_uid_and_oauth_provider_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_authorizations_on_uid_and_oauth_provider_id ON authorizations USING btree (uid, oauth_provider_id);


--
-- Name: index_bank_accounts_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bank_accounts_on_user_id ON bank_accounts USING btree (user_id);


--
-- Name: index_banks_on_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_banks_on_code ON banks USING btree (code);


--
-- Name: index_categories_on_name_pt; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_categories_on_name_pt ON categories USING btree (name_pt);


--
-- Name: index_category_followers_on_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_category_followers_on_category_id ON category_followers USING btree (category_id);


--
-- Name: index_category_followers_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_category_followers_on_user_id ON category_followers USING btree (user_id);


--
-- Name: index_channel_posts_on_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_channel_posts_on_channel_id ON channel_posts USING btree (channel_id);


--
-- Name: index_channel_posts_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_channel_posts_on_user_id ON channel_posts USING btree (user_id);


--
-- Name: index_channels_on_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_on_permalink ON channels USING btree (permalink);


--
-- Name: index_channels_projects_on_channel_id_and_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_projects_on_channel_id_and_project_id ON channels_projects USING btree (channel_id, project_id);


--
-- Name: index_channels_projects_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_channels_projects_on_project_id ON channels_projects USING btree (project_id);


--
-- Name: index_channels_subscribers_on_user_id_and_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channels_subscribers_on_user_id_and_channel_id ON channels_subscribers USING btree (user_id, channel_id);


--
-- Name: index_configurations_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_configurations_on_name ON settings USING btree (name);


--
-- Name: index_contributions_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contributions_on_created_at ON contributions USING btree (created_at);


--
-- Name: index_contributions_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contributions_on_project_id ON contributions USING btree (project_id);


--
-- Name: index_contributions_on_reward_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contributions_on_reward_id ON contributions USING btree (reward_id);


--
-- Name: index_contributions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contributions_on_user_id ON contributions USING btree (user_id);


--
-- Name: index_credit_cards_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_credit_cards_on_user_id ON credit_cards USING btree (user_id);


--
-- Name: index_dbhero_dataclips_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_dbhero_dataclips_on_token ON dbhero_dataclips USING btree (token);


--
-- Name: index_dbhero_dataclips_on_user; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_dbhero_dataclips_on_user ON dbhero_dataclips USING btree ("user");


--
-- Name: index_genres_on_name_pt; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_genres_on_name_pt ON genres USING btree (name_pt);


--
-- Name: index_jobs_on_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_jobs_on_permalink ON jobs USING btree (permalink);


--
-- Name: index_payment_notifications_on_contribution_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payment_notifications_on_contribution_id ON payment_notifications USING btree (contribution_id);


--
-- Name: index_project_accounts_on_bank_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_accounts_on_bank_id ON project_accounts USING btree (bank_id);


--
-- Name: index_project_accounts_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_accounts_on_project_id ON project_accounts USING btree (project_id);


--
-- Name: index_projects_on_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_category_id ON projects USING btree (category_id);


--
-- Name: index_projects_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_name ON projects USING btree (name);


--
-- Name: index_projects_on_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_projects_on_permalink ON projects USING btree (lower(permalink));


--
-- Name: index_projects_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_projects_on_user_id ON projects USING btree (user_id);


--
-- Name: index_rewards_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rewards_on_project_id ON rewards USING btree (project_id);


--
-- Name: index_unsubscribes_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_unsubscribes_on_project_id ON unsubscribes USING btree (project_id);


--
-- Name: index_unsubscribes_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_unsubscribes_on_user_id ON unsubscribes USING btree (user_id);


--
-- Name: index_updates_on_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_updates_on_project_id ON project_posts USING btree (project_id);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_name ON users USING btree (name);


--
-- Name: index_users_on_permalink; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_permalink ON users USING btree (permalink);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: payments_full_text_index_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX payments_full_text_index_ix ON payments USING gin (full_text_index);


--
-- Name: projects_full_text_index_ix; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX projects_full_text_index_ix ON projects USING gin (full_text_index);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = "1", pg_catalog;

--
-- Name: _RETURN; Type: RULE; Schema: 1; Owner: -
--

CREATE RULE "_RETURN" AS
    ON SELECT TO project_totals DO INSTEAD  SELECT c.project_id,
    sum(p.value) AS pledged,
    ((sum(p.value) / projects.goal) * (100)::numeric) AS progress,
    sum(p.gateway_fee) AS total_payment_service_fee,
    count(DISTINCT c.id) AS total_contributions
   FROM ((public.contributions c
     JOIN public.projects ON ((c.project_id = projects.id)))
     JOIN public.payments p ON ((p.contribution_id = c.id)))
  WHERE (p.state = ANY (public.confirmed_states()))
  GROUP BY c.project_id, projects.id;


SET search_path = postgrest, pg_catalog;

--
-- Name: ensure_auth_role_exists; Type: TRIGGER; Schema: postgrest; Owner: -
--

CREATE CONSTRAINT TRIGGER ensure_auth_role_exists AFTER INSERT OR UPDATE ON auth NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE check_role_exists();


SET search_path = public, pg_catalog;

--
-- Name: create_api_user; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER create_api_user AFTER INSERT ON users FOR EACH ROW EXECUTE PROCEDURE postgrest.create_api_user();


--
-- Name: delete_api_user; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delete_api_user AFTER DELETE ON users FOR EACH ROW EXECUTE PROCEDURE postgrest.delete_api_user();


--
-- Name: update_api_user; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_api_user AFTER UPDATE OF id, admin, authentication_token ON users FOR EACH ROW EXECUTE PROCEDURE postgrest.update_api_user();


--
-- Name: update_full_text_index; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_full_text_index BEFORE INSERT OR UPDATE OF name, permalink, headline ON projects FOR EACH ROW EXECUTE PROCEDURE update_full_text_index();


--
-- Name: update_payments_full_text_index; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_payments_full_text_index BEFORE INSERT OR UPDATE OF key, gateway, gateway_id, gateway_data, state ON payments FOR EACH ROW EXECUTE PROCEDURE update_payments_full_text_index();


--
-- Name: contributions_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT contributions_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: contributions_reward_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT contributions_reward_id_reference FOREIGN KEY (reward_id) REFERENCES rewards(id);


--
-- Name: contributions_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT contributions_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_authorizations_oauth_provider_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT fk_authorizations_oauth_provider_id FOREIGN KEY (oauth_provider_id) REFERENCES oauth_providers(id);


--
-- Name: fk_authorizations_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorizations
    ADD CONSTRAINT fk_authorizations_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_bank_accounts_bank_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bank_accounts
    ADD CONSTRAINT fk_bank_accounts_bank_id FOREIGN KEY (bank_id) REFERENCES banks(id);


--
-- Name: fk_bank_accounts_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bank_accounts
    ADD CONSTRAINT fk_bank_accounts_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_category_followers_category_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY category_followers
    ADD CONSTRAINT fk_category_followers_category_id FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: fk_category_followers_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY category_followers
    ADD CONSTRAINT fk_category_followers_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_category_notifications_category_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY category_notifications
    ADD CONSTRAINT fk_category_notifications_category_id FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: fk_category_notifications_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY category_notifications
    ADD CONSTRAINT fk_category_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_channel_partners_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channel_partners
    ADD CONSTRAINT fk_channel_partners_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channel_post_notifications_channel_post_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channel_post_notifications
    ADD CONSTRAINT fk_channel_post_notifications_channel_post_id FOREIGN KEY (channel_post_id) REFERENCES channel_posts(id);


--
-- Name: fk_channel_post_notifications_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channel_post_notifications
    ADD CONSTRAINT fk_channel_post_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_channel_posts_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channel_posts
    ADD CONSTRAINT fk_channel_posts_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channel_posts_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channel_posts
    ADD CONSTRAINT fk_channel_posts_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_channels_projects_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_projects
    ADD CONSTRAINT fk_channels_projects_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channels_projects_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_projects
    ADD CONSTRAINT fk_channels_projects_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_channels_subscribers_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_subscribers
    ADD CONSTRAINT fk_channels_subscribers_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_channels_subscribers_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels_subscribers
    ADD CONSTRAINT fk_channels_subscribers_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_contribution_notifications_contribution_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contribution_notifications
    ADD CONSTRAINT fk_contribution_notifications_contribution_id FOREIGN KEY (contribution_id) REFERENCES contributions(id);


--
-- Name: fk_contribution_notifications_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contribution_notifications
    ADD CONSTRAINT fk_contribution_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_contributions_country_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contributions
    ADD CONSTRAINT fk_contributions_country_id FOREIGN KEY (country_id) REFERENCES countries(id);


--
-- Name: fk_credit_cards_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY credit_cards
    ADD CONSTRAINT fk_credit_cards_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_jobs_category_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT fk_jobs_category_id FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: fk_jobs_job_reward_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT fk_jobs_job_reward_id FOREIGN KEY (job_reward_id) REFERENCES job_rewards(id);


--
-- Name: fk_jobs_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT fk_jobs_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_payment_notifications_payment_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_notifications
    ADD CONSTRAINT fk_payment_notifications_payment_id FOREIGN KEY (payment_id) REFERENCES payments(id);


--
-- Name: fk_payment_transfers_payment_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_transfers
    ADD CONSTRAINT fk_payment_transfers_payment_id FOREIGN KEY (payment_id) REFERENCES payments(id);


--
-- Name: fk_payment_transfers_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_transfers
    ADD CONSTRAINT fk_payment_transfers_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_payments_contribution_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT fk_payments_contribution_id FOREIGN KEY (contribution_id) REFERENCES contributions(id);


--
-- Name: fk_project_accounts_bank_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_accounts
    ADD CONSTRAINT fk_project_accounts_bank_id FOREIGN KEY (bank_id) REFERENCES banks(id);


--
-- Name: fk_project_accounts_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_accounts
    ADD CONSTRAINT fk_project_accounts_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_project_budgets_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_budgets
    ADD CONSTRAINT fk_project_budgets_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_project_notifications_project_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_notifications
    ADD CONSTRAINT fk_project_notifications_project_id FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_project_notifications_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_notifications
    ADD CONSTRAINT fk_project_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_project_post_notifications_project_post_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_post_notifications
    ADD CONSTRAINT fk_project_post_notifications_project_post_id FOREIGN KEY (project_post_id) REFERENCES project_posts(id);


--
-- Name: fk_project_post_notifications_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_post_notifications
    ADD CONSTRAINT fk_project_post_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_projects_city_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT fk_projects_city_id FOREIGN KEY (city_id) REFERENCES cities(id);


--
-- Name: fk_projects_country_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT fk_projects_country_id FOREIGN KEY (country_id) REFERENCES countries(id);


--
-- Name: fk_projects_genre_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT fk_projects_genre_id FOREIGN KEY (genre_id) REFERENCES genres(id);


--
-- Name: fk_projects_state_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT fk_projects_state_id FOREIGN KEY (state_id) REFERENCES states(id);


--
-- Name: fk_redactor_assets_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY redactor_assets
    ADD CONSTRAINT fk_redactor_assets_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_talent_images_talent_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY talent_images
    ADD CONSTRAINT fk_talent_images_talent_id FOREIGN KEY (talent_id) REFERENCES talents(id);


--
-- Name: fk_talent_images_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY talent_images
    ADD CONSTRAINT fk_talent_images_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_talent_videos_talent_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY talent_videos
    ADD CONSTRAINT fk_talent_videos_talent_id FOREIGN KEY (talent_id) REFERENCES talents(id);


--
-- Name: fk_talent_videos_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY talent_videos
    ADD CONSTRAINT fk_talent_videos_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_talents_category_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY talents
    ADD CONSTRAINT fk_talents_category_id FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: fk_talents_genre_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY talents
    ADD CONSTRAINT fk_talents_genre_id FOREIGN KEY (genre_id) REFERENCES genres(id);


--
-- Name: fk_talents_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY talents
    ADD CONSTRAINT fk_talents_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_user_links_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_links
    ADD CONSTRAINT fk_user_links_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_user_notifications_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_notifications
    ADD CONSTRAINT fk_user_notifications_user_id FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_users_channel_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_users_channel_id FOREIGN KEY (channel_id) REFERENCES channels(id);


--
-- Name: fk_users_country_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_users_country_id FOREIGN KEY (country_id) REFERENCES countries(id);


--
-- Name: payment_notifications_backer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_notifications
    ADD CONSTRAINT payment_notifications_backer_id_fk FOREIGN KEY (contribution_id) REFERENCES contributions(id);


--
-- Name: projects_category_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_category_id_reference FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: projects_user_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_user_id_reference FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: rewards_project_id_reference; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rewards
    ADD CONSTRAINT rewards_project_id_reference FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: unsubscribes_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: unsubscribes_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY unsubscribes
    ADD CONSTRAINT unsubscribes_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: updates_project_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_posts
    ADD CONSTRAINT updates_project_id_fk FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: updates_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_posts
    ADD CONSTRAINT updates_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO public, pg_catalog;

INSERT INTO schema_migrations (version) VALUES ('20121226120921');

INSERT INTO schema_migrations (version) VALUES ('20121227012003');

INSERT INTO schema_migrations (version) VALUES ('20121227012324');

INSERT INTO schema_migrations (version) VALUES ('20121230111351');

INSERT INTO schema_migrations (version) VALUES ('20130102180139');

INSERT INTO schema_migrations (version) VALUES ('20130104005632');

INSERT INTO schema_migrations (version) VALUES ('20130104104501');

INSERT INTO schema_migrations (version) VALUES ('20130105123546');

INSERT INTO schema_migrations (version) VALUES ('20130110191750');

INSERT INTO schema_migrations (version) VALUES ('20130117205659');

INSERT INTO schema_migrations (version) VALUES ('20130118193907');

INSERT INTO schema_migrations (version) VALUES ('20130121162447');

INSERT INTO schema_migrations (version) VALUES ('20130121204224');

INSERT INTO schema_migrations (version) VALUES ('20130121212325');

INSERT INTO schema_migrations (version) VALUES ('20130131121553');

INSERT INTO schema_migrations (version) VALUES ('20130201200604');

INSERT INTO schema_migrations (version) VALUES ('20130201202648');

INSERT INTO schema_migrations (version) VALUES ('20130201202829');

INSERT INTO schema_migrations (version) VALUES ('20130201205659');

INSERT INTO schema_migrations (version) VALUES ('20130204192704');

INSERT INTO schema_migrations (version) VALUES ('20130205143533');

INSERT INTO schema_migrations (version) VALUES ('20130206121758');

INSERT INTO schema_migrations (version) VALUES ('20130211174609');

INSERT INTO schema_migrations (version) VALUES ('20130212145115');

INSERT INTO schema_migrations (version) VALUES ('20130213184141');

INSERT INTO schema_migrations (version) VALUES ('20130218201312');

INSERT INTO schema_migrations (version) VALUES ('20130218201751');

INSERT INTO schema_migrations (version) VALUES ('20130221171018');

INSERT INTO schema_migrations (version) VALUES ('20130221172840');

INSERT INTO schema_migrations (version) VALUES ('20130221175717');

INSERT INTO schema_migrations (version) VALUES ('20130221184144');

INSERT INTO schema_migrations (version) VALUES ('20130221185532');

INSERT INTO schema_migrations (version) VALUES ('20130221201732');

INSERT INTO schema_migrations (version) VALUES ('20130222163633');

INSERT INTO schema_migrations (version) VALUES ('20130225135512');

INSERT INTO schema_migrations (version) VALUES ('20130225141802');

INSERT INTO schema_migrations (version) VALUES ('20130228141234');

INSERT INTO schema_migrations (version) VALUES ('20130304193806');

INSERT INTO schema_migrations (version) VALUES ('20130307074614');

INSERT INTO schema_migrations (version) VALUES ('20130307090153');

INSERT INTO schema_migrations (version) VALUES ('20130308200907');

INSERT INTO schema_migrations (version) VALUES ('20130311191444');

INSERT INTO schema_migrations (version) VALUES ('20130311192846');

INSERT INTO schema_migrations (version) VALUES ('20130312001021');

INSERT INTO schema_migrations (version) VALUES ('20130313032607');

INSERT INTO schema_migrations (version) VALUES ('20130313034356');

INSERT INTO schema_migrations (version) VALUES ('20130319131919');

INSERT INTO schema_migrations (version) VALUES ('20130410181958');

INSERT INTO schema_migrations (version) VALUES ('20130410190247');

INSERT INTO schema_migrations (version) VALUES ('20130410191240');

INSERT INTO schema_migrations (version) VALUES ('20130411193016');

INSERT INTO schema_migrations (version) VALUES ('20130419184530');

INSERT INTO schema_migrations (version) VALUES ('20130422071805');

INSERT INTO schema_migrations (version) VALUES ('20130422072051');

INSERT INTO schema_migrations (version) VALUES ('20130423162359');

INSERT INTO schema_migrations (version) VALUES ('20130424173128');

INSERT INTO schema_migrations (version) VALUES ('20130426204503');

INSERT INTO schema_migrations (version) VALUES ('20130429142823');

INSERT INTO schema_migrations (version) VALUES ('20130429144749');

INSERT INTO schema_migrations (version) VALUES ('20130429153115');

INSERT INTO schema_migrations (version) VALUES ('20130430203333');

INSERT INTO schema_migrations (version) VALUES ('20130502175814');

INSERT INTO schema_migrations (version) VALUES ('20130505013655');

INSERT INTO schema_migrations (version) VALUES ('20130506191243');

INSERT INTO schema_migrations (version) VALUES ('20130506191508');

INSERT INTO schema_migrations (version) VALUES ('20130514132519');

INSERT INTO schema_migrations (version) VALUES ('20130514185010');

INSERT INTO schema_migrations (version) VALUES ('20130514185116');

INSERT INTO schema_migrations (version) VALUES ('20130514185926');

INSERT INTO schema_migrations (version) VALUES ('20130515192404');

INSERT INTO schema_migrations (version) VALUES ('20130523144013');

INSERT INTO schema_migrations (version) VALUES ('20130523173609');

INSERT INTO schema_migrations (version) VALUES ('20130527204639');

INSERT INTO schema_migrations (version) VALUES ('20130529171845');

INSERT INTO schema_migrations (version) VALUES ('20130604171730');

INSERT INTO schema_migrations (version) VALUES ('20130604172253');

INSERT INTO schema_migrations (version) VALUES ('20130604175953');

INSERT INTO schema_migrations (version) VALUES ('20130604180503');

INSERT INTO schema_migrations (version) VALUES ('20130607222330');

INSERT INTO schema_migrations (version) VALUES ('20130617175402');

INSERT INTO schema_migrations (version) VALUES ('20130618175432');

INSERT INTO schema_migrations (version) VALUES ('20130626122439');

INSERT INTO schema_migrations (version) VALUES ('20130626124055');

INSERT INTO schema_migrations (version) VALUES ('20130702192659');

INSERT INTO schema_migrations (version) VALUES ('20130703171547');

INSERT INTO schema_migrations (version) VALUES ('20130705131825');

INSERT INTO schema_migrations (version) VALUES ('20130705184845');

INSERT INTO schema_migrations (version) VALUES ('20130710122804');

INSERT INTO schema_migrations (version) VALUES ('20130722222945');

INSERT INTO schema_migrations (version) VALUES ('20130730232043');

INSERT INTO schema_migrations (version) VALUES ('20130805230126');

INSERT INTO schema_migrations (version) VALUES ('20130812191450');

INSERT INTO schema_migrations (version) VALUES ('20130814174329');

INSERT INTO schema_migrations (version) VALUES ('20130815161926');

INSERT INTO schema_migrations (version) VALUES ('20130818015857');

INSERT INTO schema_migrations (version) VALUES ('20130822215532');

INSERT INTO schema_migrations (version) VALUES ('20130827210414');

INSERT INTO schema_migrations (version) VALUES ('20130828160026');

INSERT INTO schema_migrations (version) VALUES ('20130829180232');

INSERT INTO schema_migrations (version) VALUES ('20130905153553');

INSERT INTO schema_migrations (version) VALUES ('20130911180657');

INSERT INTO schema_migrations (version) VALUES ('20130918191809');

INSERT INTO schema_migrations (version) VALUES ('20130926185207');

INSERT INTO schema_migrations (version) VALUES ('20131008190648');

INSERT INTO schema_migrations (version) VALUES ('20131010193936');

INSERT INTO schema_migrations (version) VALUES ('20131010194006');

INSERT INTO schema_migrations (version) VALUES ('20131010194345');

INSERT INTO schema_migrations (version) VALUES ('20131010194500');

INSERT INTO schema_migrations (version) VALUES ('20131010194521');

INSERT INTO schema_migrations (version) VALUES ('20131014201229');

INSERT INTO schema_migrations (version) VALUES ('20131016193346');

INSERT INTO schema_migrations (version) VALUES ('20131016214955');

INSERT INTO schema_migrations (version) VALUES ('20131016231130');

INSERT INTO schema_migrations (version) VALUES ('20131018170211');

INSERT INTO schema_migrations (version) VALUES ('20131020215932');

INSERT INTO schema_migrations (version) VALUES ('20131021190108');

INSERT INTO schema_migrations (version) VALUES ('20131022154220');

INSERT INTO schema_migrations (version) VALUES ('20131023031539');

INSERT INTO schema_migrations (version) VALUES ('20131023032325');

INSERT INTO schema_migrations (version) VALUES ('20131107143439');

INSERT INTO schema_migrations (version) VALUES ('20131107143512');

INSERT INTO schema_migrations (version) VALUES ('20131107143537');

INSERT INTO schema_migrations (version) VALUES ('20131107143832');

INSERT INTO schema_migrations (version) VALUES ('20131107145351');

INSERT INTO schema_migrations (version) VALUES ('20131107161918');

INSERT INTO schema_migrations (version) VALUES ('20131112113608');

INSERT INTO schema_migrations (version) VALUES ('20131113145601');

INSERT INTO schema_migrations (version) VALUES ('20131114154112');

INSERT INTO schema_migrations (version) VALUES ('20131127132159');

INSERT INTO schema_migrations (version) VALUES ('20131128142533');

INSERT INTO schema_migrations (version) VALUES ('20131230171126');

INSERT INTO schema_migrations (version) VALUES ('20131230172840');

INSERT INTO schema_migrations (version) VALUES ('20140102125037');

INSERT INTO schema_migrations (version) VALUES ('20140115110512');

INSERT INTO schema_migrations (version) VALUES ('20140117115326');

INSERT INTO schema_migrations (version) VALUES ('20140120195335');

INSERT INTO schema_migrations (version) VALUES ('20140120201216');

INSERT INTO schema_migrations (version) VALUES ('20140121114718');

INSERT INTO schema_migrations (version) VALUES ('20140121124230');

INSERT INTO schema_migrations (version) VALUES ('20140121124646');

INSERT INTO schema_migrations (version) VALUES ('20140121124840');

INSERT INTO schema_migrations (version) VALUES ('20140121125256');

INSERT INTO schema_migrations (version) VALUES ('20140121130341');

INSERT INTO schema_migrations (version) VALUES ('20140121171044');

INSERT INTO schema_migrations (version) VALUES ('20140207160934');

INSERT INTO schema_migrations (version) VALUES ('20140210233516');

INSERT INTO schema_migrations (version) VALUES ('20140219192513');

INSERT INTO schema_migrations (version) VALUES ('20140219192658');

INSERT INTO schema_migrations (version) VALUES ('20140310200601');

INSERT INTO schema_migrations (version) VALUES ('20140310201238');

INSERT INTO schema_migrations (version) VALUES ('20140319121007');

INSERT INTO schema_migrations (version) VALUES ('20140325150844');

INSERT INTO schema_migrations (version) VALUES ('20140331204618');

INSERT INTO schema_migrations (version) VALUES ('20140331215022');

INSERT INTO schema_migrations (version) VALUES ('20140401144727');

INSERT INTO schema_migrations (version) VALUES ('20140401145136');

INSERT INTO schema_migrations (version) VALUES ('20140410175400');

INSERT INTO schema_migrations (version) VALUES ('20140410184603');

INSERT INTO schema_migrations (version) VALUES ('20140414164640');

INSERT INTO schema_migrations (version) VALUES ('20140424171245');

INSERT INTO schema_migrations (version) VALUES ('20140502192210');

INSERT INTO schema_migrations (version) VALUES ('20140506011533');

INSERT INTO schema_migrations (version) VALUES ('20140506152503');

INSERT INTO schema_migrations (version) VALUES ('20140514125258');

INSERT INTO schema_migrations (version) VALUES ('20140523163153');

INSERT INTO schema_migrations (version) VALUES ('20140527162918');

INSERT INTO schema_migrations (version) VALUES ('20140527164648');

INSERT INTO schema_migrations (version) VALUES ('20140605174230');

INSERT INTO schema_migrations (version) VALUES ('20140624154532');

INSERT INTO schema_migrations (version) VALUES ('20140627210356');

INSERT INTO schema_migrations (version) VALUES ('20140627210828');

INSERT INTO schema_migrations (version) VALUES ('20140703172107');

INSERT INTO schema_migrations (version) VALUES ('20140709163624');

INSERT INTO schema_migrations (version) VALUES ('20140710202411');

INSERT INTO schema_migrations (version) VALUES ('20140711170405');

INSERT INTO schema_migrations (version) VALUES ('20140711193130');

INSERT INTO schema_migrations (version) VALUES ('20140711195616');

INSERT INTO schema_migrations (version) VALUES ('20140711211348');

INSERT INTO schema_migrations (version) VALUES ('20140711212158');

INSERT INTO schema_migrations (version) VALUES ('20140711212618');

INSERT INTO schema_migrations (version) VALUES ('20140711214139');

INSERT INTO schema_migrations (version) VALUES ('20140711214945');

INSERT INTO schema_migrations (version) VALUES ('20140711220046');

INSERT INTO schema_migrations (version) VALUES ('20140715165543');

INSERT INTO schema_migrations (version) VALUES ('20140715175737');

INSERT INTO schema_migrations (version) VALUES ('20140722205814');

INSERT INTO schema_migrations (version) VALUES ('20140722210129');

INSERT INTO schema_migrations (version) VALUES ('20140722210820');

INSERT INTO schema_migrations (version) VALUES ('20140724165254');

INSERT INTO schema_migrations (version) VALUES ('20140728133749');

INSERT INTO schema_migrations (version) VALUES ('20140729163857');

INSERT INTO schema_migrations (version) VALUES ('20140731163219');

INSERT INTO schema_migrations (version) VALUES ('20140818184048');

INSERT INTO schema_migrations (version) VALUES ('20140820174053');

INSERT INTO schema_migrations (version) VALUES ('20140821192042');

INSERT INTO schema_migrations (version) VALUES ('20140821192107');

INSERT INTO schema_migrations (version) VALUES ('20140822202511');

INSERT INTO schema_migrations (version) VALUES ('20140825140231');

INSERT INTO schema_migrations (version) VALUES ('20140902231758');

INSERT INTO schema_migrations (version) VALUES ('20140902233410');

INSERT INTO schema_migrations (version) VALUES ('20140902233427');

INSERT INTO schema_migrations (version) VALUES ('20140918163741');

INSERT INTO schema_migrations (version) VALUES ('20140918192213');

INSERT INTO schema_migrations (version) VALUES ('20140922161604');

INSERT INTO schema_migrations (version) VALUES ('20140930133827');

INSERT INTO schema_migrations (version) VALUES ('20140930140654');

INSERT INTO schema_migrations (version) VALUES ('20140930141246');

INSERT INTO schema_migrations (version) VALUES ('20140930144910');

INSERT INTO schema_migrations (version) VALUES ('20141010140644');

INSERT INTO schema_migrations (version) VALUES ('20141010195710');

INSERT INTO schema_migrations (version) VALUES ('20141013221051');

INSERT INTO schema_migrations (version) VALUES ('20141014213748');

INSERT INTO schema_migrations (version) VALUES ('20141015005248');

INSERT INTO schema_migrations (version) VALUES ('20141016184006');

INSERT INTO schema_migrations (version) VALUES ('20141017211215');

INSERT INTO schema_migrations (version) VALUES ('20141020150821');

INSERT INTO schema_migrations (version) VALUES ('20141020154325');

INSERT INTO schema_migrations (version) VALUES ('20141021163107');

INSERT INTO schema_migrations (version) VALUES ('20141022161050');

INSERT INTO schema_migrations (version) VALUES ('20141105145528');

INSERT INTO schema_migrations (version) VALUES ('20141124194951');

INSERT INTO schema_migrations (version) VALUES ('20141126182211');

INSERT INTO schema_migrations (version) VALUES ('20141127215219');

INSERT INTO schema_migrations (version) VALUES ('20141201132605');

INSERT INTO schema_migrations (version) VALUES ('20141215153054');

INSERT INTO schema_migrations (version) VALUES ('20141215171306');

INSERT INTO schema_migrations (version) VALUES ('20141222180815');

INSERT INTO schema_migrations (version) VALUES ('20141223144205');

INSERT INTO schema_migrations (version) VALUES ('20150107173250');

INSERT INTO schema_migrations (version) VALUES ('20150112121053');

INSERT INTO schema_migrations (version) VALUES ('20150114194835');

INSERT INTO schema_migrations (version) VALUES ('20150119151029');

INSERT INTO schema_migrations (version) VALUES ('20150121155841');

INSERT INTO schema_migrations (version) VALUES ('20150122153621');

INSERT INTO schema_migrations (version) VALUES ('20150127023738');

INSERT INTO schema_migrations (version) VALUES ('20150127034613');

INSERT INTO schema_migrations (version) VALUES ('20150127043459');

INSERT INTO schema_migrations (version) VALUES ('20150128024748');

INSERT INTO schema_migrations (version) VALUES ('20150202222147');

INSERT INTO schema_migrations (version) VALUES ('20150204200139');

INSERT INTO schema_migrations (version) VALUES ('20150210141644');

INSERT INTO schema_migrations (version) VALUES ('20150211141507');

INSERT INTO schema_migrations (version) VALUES ('20150213120420');

INSERT INTO schema_migrations (version) VALUES ('20150217203920');

INSERT INTO schema_migrations (version) VALUES ('20150218194719');

INSERT INTO schema_migrations (version) VALUES ('20150218194824');

INSERT INTO schema_migrations (version) VALUES ('20150218203123');

INSERT INTO schema_migrations (version) VALUES ('20150219193410');

INSERT INTO schema_migrations (version) VALUES ('20150221160747');

INSERT INTO schema_migrations (version) VALUES ('20150305162209');

INSERT INTO schema_migrations (version) VALUES ('20150305210654');

INSERT INTO schema_migrations (version) VALUES ('20150306163559');

INSERT INTO schema_migrations (version) VALUES ('20150306165758');

INSERT INTO schema_migrations (version) VALUES ('20150306170412');

INSERT INTO schema_migrations (version) VALUES ('20150309130152');

INSERT INTO schema_migrations (version) VALUES ('20150310134924');

INSERT INTO schema_migrations (version) VALUES ('20150317203333');

INSERT INTO schema_migrations (version) VALUES ('20150317203743');

INSERT INTO schema_migrations (version) VALUES ('20150317230642');

INSERT INTO schema_migrations (version) VALUES ('20150318155437');

INSERT INTO schema_migrations (version) VALUES ('20150319042359');

INSERT INTO schema_migrations (version) VALUES ('20150320133058');

INSERT INTO schema_migrations (version) VALUES ('20150320135444');

INSERT INTO schema_migrations (version) VALUES ('20150320135621');

INSERT INTO schema_migrations (version) VALUES ('20150322232709');

INSERT INTO schema_migrations (version) VALUES ('20150324235028');

INSERT INTO schema_migrations (version) VALUES ('20150325135455');

INSERT INTO schema_migrations (version) VALUES ('20150326160558');

INSERT INTO schema_migrations (version) VALUES ('20150326180807');

INSERT INTO schema_migrations (version) VALUES ('20150326183059');

INSERT INTO schema_migrations (version) VALUES ('20150330180921');

INSERT INTO schema_migrations (version) VALUES ('20150408154506');

INSERT INTO schema_migrations (version) VALUES ('20150409173450');

INSERT INTO schema_migrations (version) VALUES ('20150415142035');

INSERT INTO schema_migrations (version) VALUES ('20150415165652');

INSERT INTO schema_migrations (version) VALUES ('20150420204243');

INSERT INTO schema_migrations (version) VALUES ('20150423142646');

INSERT INTO schema_migrations (version) VALUES ('20150423180704');

INSERT INTO schema_migrations (version) VALUES ('20150427164636');

INSERT INTO schema_migrations (version) VALUES ('20150507022419');

INSERT INTO schema_migrations (version) VALUES ('20150507141628');

INSERT INTO schema_migrations (version) VALUES ('20150514133948');

INSERT INTO schema_migrations (version) VALUES ('20150518182232');

INSERT INTO schema_migrations (version) VALUES ('20150519154030');

INSERT INTO schema_migrations (version) VALUES ('20150519154711');

INSERT INTO schema_migrations (version) VALUES ('20150519172925');

INSERT INTO schema_migrations (version) VALUES ('20150519202619');

INSERT INTO schema_migrations (version) VALUES ('20150519202707');

INSERT INTO schema_migrations (version) VALUES ('20150519203123');

INSERT INTO schema_migrations (version) VALUES ('20150519214945');

INSERT INTO schema_migrations (version) VALUES ('20150521193439');

INSERT INTO schema_migrations (version) VALUES ('20150525140009');

INSERT INTO schema_migrations (version) VALUES ('20150602201705');

INSERT INTO schema_migrations (version) VALUES ('20150602201957');

INSERT INTO schema_migrations (version) VALUES ('20150604044427');

INSERT INTO schema_migrations (version) VALUES ('20150604143801');

INSERT INTO schema_migrations (version) VALUES ('20150605153541');

INSERT INTO schema_migrations (version) VALUES ('20150605192639');

INSERT INTO schema_migrations (version) VALUES ('20150605214509');

INSERT INTO schema_migrations (version) VALUES ('20150605215906');

INSERT INTO schema_migrations (version) VALUES ('20150605220249');

INSERT INTO schema_migrations (version) VALUES ('20150608202210');

INSERT INTO schema_migrations (version) VALUES ('20150624172046');

INSERT INTO schema_migrations (version) VALUES ('20150629204701');

INSERT INTO schema_migrations (version) VALUES ('20150706190911');

INSERT INTO schema_migrations (version) VALUES ('20150707154308');

INSERT INTO schema_migrations (version) VALUES ('20150713153329');

INSERT INTO schema_migrations (version) VALUES ('20150713153732');

INSERT INTO schema_migrations (version) VALUES ('20150713154753');

INSERT INTO schema_migrations (version) VALUES ('20150713210123');

INSERT INTO schema_migrations (version) VALUES ('20150714190441');

INSERT INTO schema_migrations (version) VALUES ('20150717151336');

INSERT INTO schema_migrations (version) VALUES ('20150717154642');

INSERT INTO schema_migrations (version) VALUES ('20150724142700');

INSERT INTO schema_migrations (version) VALUES ('20150724154819');

INSERT INTO schema_migrations (version) VALUES ('20150724171045');

INSERT INTO schema_migrations (version) VALUES ('20150724171145');

INSERT INTO schema_migrations (version) VALUES ('20150728150417');

INSERT INTO schema_migrations (version) VALUES ('20150728150418');

INSERT INTO schema_migrations (version) VALUES ('20150728170415');

INSERT INTO schema_migrations (version) VALUES ('20151001102610');

INSERT INTO schema_migrations (version) VALUES ('20151003180757');

INSERT INTO schema_migrations (version) VALUES ('20151004042229');

INSERT INTO schema_migrations (version) VALUES ('20151213114928');

INSERT INTO schema_migrations (version) VALUES ('20151213183607');

INSERT INTO schema_migrations (version) VALUES ('20151215134713');

INSERT INTO schema_migrations (version) VALUES ('20151215145045');

INSERT INTO schema_migrations (version) VALUES ('20151215145134');

INSERT INTO schema_migrations (version) VALUES ('20151215150004');

INSERT INTO schema_migrations (version) VALUES ('20151215151212');

INSERT INTO schema_migrations (version) VALUES ('20151215151228');

INSERT INTO schema_migrations (version) VALUES ('20151216070000');

INSERT INTO schema_migrations (version) VALUES ('20151216070855');

INSERT INTO schema_migrations (version) VALUES ('20151216073621');

INSERT INTO schema_migrations (version) VALUES ('20151216073747');

INSERT INTO schema_migrations (version) VALUES ('20151216073949');

INSERT INTO schema_migrations (version) VALUES ('20151216085249');

INSERT INTO schema_migrations (version) VALUES ('20151216194826');

INSERT INTO schema_migrations (version) VALUES ('20151217070609');

INSERT INTO schema_migrations (version) VALUES ('20151217070642');

