-- public.address definition

-- Drop table

-- DROP TABLE public.address;

CREATE TABLE public.address (
	id uuid NOT NULL,
	first_name varchar NULL,
	last_name varchar NULL,
	country varchar NOT NULL,
	country_code varchar(2) NOT NULL,
	province varchar NULL,
	province_code varchar NULL,
	city varchar NOT NULL,
	zip varchar NOT NULL,
	address_1 varchar NOT NULL,
	address_2 varchar NULL,
	company varchar NULL,
	phone varchar NULL,
	latitude float8 NULL,
	longitude float8 NULL,
	"VAT_number" varchar NULL,
	title varchar NULL,
	contact_person varchar NULL,
	department varchar NULL,
	sub_department varchar NULL,
	address_type public."address_type_enum" NULL,
	creation_date timestamp DEFAULT '2010-01-01 00:00:00'::timestamp without time zone NULL,
	updated_date timestamp DEFAULT '2010-01-01 00:00:00'::timestamp without time zone NULL,
	CONSTRAINT pk_address PRIMARY KEY (id)
);
CREATE INDEX address_creation_date_idx ON public.address USING btree (creation_date) WHERE (creation_date > '2010-01-01 00:00:00'::timestamp without time zone);
CREATE INDEX address_updated_date_idx ON public.address USING btree (updated_date) WHERE (updated_date > '2010-01-01 00:00:00'::timestamp without time zone);


-- public.alembic_version definition

-- Drop table

-- DROP TABLE public.alembic_version;

CREATE TABLE public.alembic_version (
	version_num varchar(32) NOT NULL,
	CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);


-- public.async_fallback_queue definition

-- Drop table

-- DROP TABLE public.async_fallback_queue;

CREATE TABLE public.async_fallback_queue (
	id uuid NOT NULL,
	task_name varchar(255) NOT NULL,
	args jsonb NULL,
	kwargs jsonb NULL,
	apply_async_attributes jsonb NOT NULL,
	shop_id uuid NULL,
	warehouse_id uuid NULL,
	action_type varchar NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	CONSTRAINT pk_async_fallback_queue PRIMARY KEY (id)
);
CREATE INDEX async_fallback_queue_creation_date_idx ON public.async_fallback_queue USING btree (creation_date);


-- public.awsdms_apply_exceptions definition

-- Drop table

-- DROP TABLE public.awsdms_apply_exceptions;

CREATE TABLE public.awsdms_apply_exceptions (
	"TASK_NAME" varchar(128) NOT NULL,
	"TABLE_OWNER" varchar(128) NOT NULL,
	"TABLE_NAME" varchar(128) NOT NULL,
	"ERROR_TIME" timestamp NOT NULL,
	"STATEMENT" text NOT NULL,
	"ERROR" text NOT NULL
);


-- public.awsdms_ddl_audit definition

-- Drop table

-- DROP TABLE public.awsdms_ddl_audit;

CREATE TABLE public.awsdms_ddl_audit (
	c_key bigserial NOT NULL,
	c_time timestamp NULL,
	c_user varchar(64) NULL,
	c_txn varchar(16) NULL,
	c_tag varchar(24) NULL,
	c_oid int4 NULL,
	c_name varchar(64) NULL,
	c_schema varchar(64) NULL,
	c_ddlqry text NULL,
	CONSTRAINT awsdms_ddl_audit_pkey PRIMARY KEY (c_key)
);


-- public.awsdms_history definition

-- Drop table

-- DROP TABLE public.awsdms_history;

CREATE TABLE public.awsdms_history (
	server_name varchar(128) NOT NULL,
	task_name varchar(128) NOT NULL,
	timeslot_type varchar(32) NOT NULL,
	timeslot timestamp NOT NULL,
	timeslot_duration int8 NULL,
	timeslot_latency int8 NULL,
	timeslot_records int8 NULL,
	timeslot_volume int8 NULL
);
CREATE UNIQUE INDEX awsdms_history_task_history_index ON public.awsdms_history USING btree (server_name, task_name, timeslot_type, timeslot);


-- public.awsdms_status definition

-- Drop table

-- DROP TABLE public.awsdms_status;

CREATE TABLE public.awsdms_status (
	server_name varchar(128) NOT NULL,
	task_name varchar(128) NOT NULL,
	task_status varchar(32) NULL,
	status_time timestamp NULL,
	pending_changes int8 NULL,
	disk_swap_size int8 NULL,
	task_memory int8 NULL,
	source_current_position varchar(128) NULL,
	source_current_timestamp timestamp NULL,
	source_tail_position varchar(128) NULL,
	source_tail_timestamp timestamp NULL,
	source_timestamp_applied timestamp NULL
);
CREATE UNIQUE INDEX awsdms_status_task_status_index ON public.awsdms_status USING btree (server_name, task_name);


-- public.awsdms_suspended_tables definition

-- Drop table

-- DROP TABLE public.awsdms_suspended_tables;

CREATE TABLE public.awsdms_suspended_tables (
	server_name varchar(128) NOT NULL,
	task_name varchar(128) NOT NULL,
	table_owner varchar(128) NOT NULL,
	table_name varchar(128) NOT NULL,
	suspend_reason varchar(32) NULL,
	suspend_timestamp timestamp NULL
);
CREATE UNIQUE INDEX awsdms_suspended_tables_task_suspended_tables_index ON public.awsdms_suspended_tables USING btree (server_name, task_name, table_owner, table_name);


-- public.awsdms_txn_state definition

-- Drop table

-- DROP TABLE public.awsdms_txn_state;

CREATE TABLE public.awsdms_txn_state (
	"SERVER_NAME" varchar(128) NOT NULL,
	"TASK_NAME" varchar(128) NOT NULL,
	"STATE_TIME" timestamp NOT NULL,
	"CHECKPOINT" varchar(1024) NOT NULL
);
CREATE UNIQUE INDEX awsdms_txn_state_task_recovery_index ON public.awsdms_txn_state USING btree ("SERVER_NAME", "TASK_NAME");


-- public.awsdms_validation_failures_v1 definition

-- Drop table

-- DROP TABLE public.awsdms_validation_failures_v1;

CREATE TABLE public.awsdms_validation_failures_v1 (
	"TASK_NAME" varchar(128) NOT NULL,
	"TABLE_OWNER" varchar(128) NOT NULL,
	"TABLE_NAME" varchar(128) NOT NULL,
	"FAILURE_TIME" timestamp NOT NULL,
	"KEY_TYPE" varchar(128) NOT NULL,
	"KEY" varchar(7800) NOT NULL,
	"FAILURE_TYPE" varchar(128) NOT NULL,
	"DETAILS" varchar(7800) NOT NULL
);


-- public.batch definition

-- Drop table

-- DROP TABLE public.batch;

CREATE TABLE public.batch (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	batch varchar NOT NULL,
	expiration_date timestamp NULL,
	expiration_dates _timestamp DEFAULT '{}'::timestamp without time zone[] NOT NULL,
	CONSTRAINT pk_batch PRIMARY KEY (id)
);


-- public.bulk_stock_update definition

-- Drop table

-- DROP TABLE public.bulk_stock_update;

CREATE TABLE public.bulk_stock_update (
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	id uuid NOT NULL,
	internal_sequence_identifier bigserial NOT NULL,
	external_sequence_identifier timestamp NULL,
	raw_data_link text NULL,
	transformed_data_link text NULL,
	status public."bulk_stock_update_status_enum" NOT NULL,
	shop_id uuid NOT NULL,
	warehouse_id uuid NOT NULL,
	full_stock_update bool NOT NULL,
	full_sku_update bool NOT NULL,
	initial_number_of_stocks int4 NOT NULL,
	total_number_of_stocks int4 NOT NULL,
	"comment" text NULL,
	errors text NULL,
	CONSTRAINT pk_bulk_stock_update PRIMARY KEY (id),
	CONSTRAINT uq_bulk_stock_update_internal_sequence_identifier UNIQUE (internal_sequence_identifier)
);
CREATE INDEX idx_bsu_creation_date ON public.bulk_stock_update USING btree (creation_date);
CREATE INDEX idx_bsu_external_sequence_identifier ON public.bulk_stock_update USING btree (external_sequence_identifier);
CREATE INDEX idx_bsu_internal_sequence_identifier ON public.bulk_stock_update USING btree (internal_sequence_identifier);
CREATE INDEX idx_bsu_shop_id ON public.bulk_stock_update USING btree (shop_id);
CREATE INDEX idx_bsu_warehouse_id ON public.bulk_stock_update USING btree (warehouse_id);


-- public.celery_taskmeta definition

-- Drop table

-- DROP TABLE public.celery_taskmeta;

CREATE TABLE public.celery_taskmeta (
	id int8 NOT NULL,
	task_id varchar(155) NULL,
	status varchar(50) NULL,
	"result" bytea NULL,
	date_done timestamp NULL,
	traceback text NULL,
	"name" varchar(155) NULL,
	args bytea NULL,
	kwargs bytea NULL,
	worker varchar(155) NULL,
	retries int4 NULL,
	queue varchar(155) NULL,
	id_bigint int8 NULL,
	CONSTRAINT celery_taskmeta_new_pkey PRIMARY KEY (id),
	CONSTRAINT celery_taskmeta_new_task_id_key UNIQUE (task_id)
);
CREATE INDEX idx_date_done_new ON public.celery_taskmeta USING btree (date_done);
CREATE INDEX idx_task_id_new ON public.celery_taskmeta USING btree (task_id);


-- public.celery_tasksetmeta definition

-- Drop table

-- DROP TABLE public.celery_tasksetmeta;

CREATE TABLE public.celery_tasksetmeta (
	id int4 NOT NULL,
	taskset_id varchar(155) NULL,
	"result" bytea NULL,
	date_done timestamp NULL,
	CONSTRAINT celery_tasksetmeta_pkey PRIMARY KEY (id),
	CONSTRAINT celery_tasksetmeta_taskset_id_key UNIQUE (taskset_id)
);


-- public.everstox_qm__export_http definition

-- Drop table

-- DROP TABLE public.everstox_qm__export_http;

CREATE TABLE public.everstox_qm__export_http (
	id uuid NOT NULL,
	url varchar NOT NULL,
	"method" varchar NOT NULL,
	headers jsonb NULL,
	body jsonb NULL,
	state public."everstox_qm__export_state_enum" NOT NULL,
	handler_fn_path varchar NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	context jsonb NULL,
	errors jsonb NOT NULL,
	response_body jsonb NULL,
	response_code int4 NULL,
	resolved bool NULL,
	resolved_by_user_id uuid NULL,
	resolved_comment text NULL,
	resolved_date timestamp NULL,
	shop_id uuid NULL,
	shop_instance_id uuid NULL,
	warehouse_id uuid NULL,
	tags public."hstore" NULL,
	last_retry_date timestamp NULL,
	retry_count int4 NULL,
	pre_processor_path varchar NULL,
	CONSTRAINT pk_everstox_qm__export_http PRIMARY KEY (id)
);
CREATE INDEX everstox_qm__export_http__search_gin ON public.everstox_qm__export_http USING gin (url gin_trgm_ops);
CREATE INDEX everstox_qm__export_http_i_tags_order_number ON public.everstox_qm__export_http USING btree (((tags -> 'order_number'::text)));
CREATE INDEX everstox_qm__export_http_i_tags_return_reference ON public.everstox_qm__export_http USING btree (creation_date, id, ((tags -> 'return_reference'::text)));
CREATE INDEX everstox_qm__export_http_i_tags_sku ON public.everstox_qm__export_http USING btree (((tags -> 'sku'::text)));
CREATE INDEX everstox_qm__export_http_i_tags_transfer_number ON public.everstox_qm__export_http USING btree (((tags -> 'transfer_number'::text)));
CREATE INDEX everstox_qm__export_resolved_idx ON public.everstox_qm__export_http USING btree (resolved);
CREATE INDEX everstox_qm__export_state_idx ON public.everstox_qm__export_http USING btree (state);
CREATE INDEX ix_everstox_qm__export_http_creation_date ON public.everstox_qm__export_http USING btree (creation_date);
CREATE INDEX ix_everstox_qm__export_http_tags_gdpr ON public.everstox_qm__export_http USING btree (((tags -> 'action_type'::text)), ((tags -> 'gdpr_request_id'::text)), url);


-- public.everstox_settings definition

-- Drop table

-- DROP TABLE public.everstox_settings;

CREATE TABLE public.everstox_settings (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	parcel_tracking jsonb NULL,
	CONSTRAINT pk_everstox_settings PRIMARY KEY (id)
);


-- public.feature_flag_group definition

-- Drop table

-- DROP TABLE public.feature_flag_group;

CREATE TABLE public.feature_flag_group (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	"name" public."feature_flag_group_name_enum" NOT NULL,
	description varchar NOT NULL,
	CONSTRAINT pk_feature_flag_group PRIMARY KEY (id)
);
CREATE UNIQUE INDEX ix_feature_flag_group_name ON public.feature_flag_group USING btree (name);


-- public.injecthor_config definition

-- Drop table

-- DROP TABLE public.injecthor_config;

CREATE TABLE public.injecthor_config (
	id uuid NOT NULL,
	"name" varchar NOT NULL,
	environment varchar NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	CONSTRAINT pk_injecthor_config PRIMARY KEY (id)
);


-- public."lock" definition

-- Drop table

-- DROP TABLE public."lock";

CREATE TABLE public."lock" (
	id uuid NOT NULL,
	identifier varchar NOT NULL,
	state public."lock_state_enum" NOT NULL,
	released_date timestamp NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	expiration_date timestamp NULL,
	CONSTRAINT pk_lock PRIMARY KEY (id)
);
CREATE UNIQUE INDEX ix_unique_active_identifier ON public.lock USING btree (identifier) WHERE (state = 'active'::lock_state_enum);


-- public.log definition

-- Drop table

-- DROP TABLE public.log;

CREATE TABLE public.log (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	item_id uuid NOT NULL,
	item_type varchar NOT NULL,
	logs _jsonb NOT NULL,
	"configuration" jsonb NOT NULL,
	CONSTRAINT pk_log PRIMARY KEY (id),
	CONSTRAINT unique_item_id_item_type UNIQUE (item_id, item_type)
);
CREATE UNIQUE INDEX item_id_item_type_index ON public.log USING btree (item_id, item_type);


-- public.notification_action definition

-- Drop table

-- DROP TABLE public.notification_action;

CREATE TABLE public.notification_action (
	id uuid NOT NULL,
	"name" varchar(255) NOT NULL,
	description text NULL,
	CONSTRAINT pk_notification_action PRIMARY KEY (id)
);


-- public.notification_type definition

-- Drop table

-- DROP TABLE public.notification_type;

CREATE TABLE public.notification_type (
	id uuid NOT NULL,
	"name" varchar(255) NOT NULL,
	description text NULL,
	CONSTRAINT pk_notification_type PRIMARY KEY (id),
	CONSTRAINT uq_notification_type_name UNIQUE (name)
);


-- public.order_type definition

-- Drop table

-- DROP TABLE public.order_type;

CREATE TABLE public.order_type (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	"name" varchar NOT NULL,
	CONSTRAINT pk_order_type PRIMARY KEY (id),
	CONSTRAINT uq_order_type_name UNIQUE (name)
);


-- public.requesthor_incoming_request definition

-- Drop table

-- DROP TABLE public.requesthor_incoming_request;

CREATE TABLE public.requesthor_incoming_request (
	id uuid NOT NULL,
	"source" varchar NULL,
	http_method public."http_method_enum" NULL,
	"path" varchar NULL,
	idempotency_key varchar NULL,
	request_headers varchar NULL,
	request_body text NULL,
	response_headers varchar NULL,
	response_code varchar NULL,
	response_body text NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	CONSTRAINT pk_requesthor_incoming_request PRIMARY KEY (id)
);
CREATE UNIQUE INDEX ix_unique_idempotency_key_not_server_error ON public.requesthor_incoming_request USING btree (idempotency_key) WHERE (((response_code)::text !~~ '5%'::text) OR (response_code IS NULL));
CREATE INDEX requesthor_incoming_request_creation_date_idx ON public.requesthor_incoming_request USING btree (creation_date);
CREATE INDEX requesthor_incoming_request_http_method_idx ON public.requesthor_incoming_request USING btree (http_method);
CREATE INDEX requesthor_incoming_request_path_idx ON public.requesthor_incoming_request USING btree (path);
CREATE INDEX requesthor_incoming_request_response_code_idx ON public.requesthor_incoming_request USING btree (response_code);


-- public.shop_connector definition

-- Drop table

-- DROP TABLE public.shop_connector;

CREATE TABLE public.shop_connector (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	"name" varchar NOT NULL,
	url varchar NOT NULL,
	core_to_connector_token varchar NOT NULL,
	CONSTRAINT pk_shop_connector PRIMARY KEY (id),
	CONSTRAINT shop_connector_name_min_length CHECK ((length((name)::text) >= 1)),
	CONSTRAINT unique_shop_connector_name UNIQUE (name)
);


-- public.shop_group definition

-- Drop table

-- DROP TABLE public.shop_group;

CREATE TABLE public.shop_group (
	id uuid NOT NULL,
	"name" varchar NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	CONSTRAINT pk_shop_group PRIMARY KEY (id)
);


-- public.state_machine_log definition

-- Drop table

-- DROP TABLE public.state_machine_log;

CREATE TABLE public.state_machine_log (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	item_id uuid NOT NULL,
	item_table varchar NOT NULL,
	state_machine_class varchar NOT NULL,
	old_state varchar NULL,
	old_errors _text NULL,
	new_state varchar NOT NULL,
	new_errors _text NULL,
	"trigger" varchar NULL,
	CONSTRAINT pk_state_machine_log PRIMARY KEY (id)
);
CREATE INDEX idx_state_machine_log_creation_date ON public.state_machine_log USING btree (creation_date);
CREATE INDEX item_id_new_state_index ON public.state_machine_log USING btree (item_id, new_state);


-- public.tmp_cancellation_copy definition

-- Drop table

-- DROP TABLE public.tmp_cancellation_copy;

CREATE TABLE public.tmp_cancellation_copy (
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	id uuid NULL,
	fulfillment_id uuid NULL,
	email varchar NULL,
	state public."cancellation_status_enum" NULL
);


-- public.tmp_dis_13404_data definition

-- Drop table

-- DROP TABLE public.tmp_dis_13404_data;

CREATE TABLE public.tmp_dis_13404_data (
	id uuid NULL,
	request_creation_date timestamp NULL,
	request_updated_date timestamp NULL,
	shipment_id uuid NULL,
	tracking_number varchar NULL,
	all_events jsonb NULL
);


-- public.tmp_fh_import_stats definition

-- Drop table

-- DROP TABLE public.tmp_fh_import_stats;

CREATE TABLE public.tmp_fh_import_stats (
	creation_date_week timestamp NULL,
	"type" varchar NULL,
	item_type varchar NULL,
	total_count int8 NULL
);


-- public.validation definition

-- Drop table

-- DROP TABLE public.validation;

CREATE TABLE public.validation (
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	id uuid NOT NULL,
	"type" varchar NOT NULL,
	state public."validation_state_enum" NULL,
	"result" jsonb NULL,
	CONSTRAINT pk_validation PRIMARY KEY (id)
);


-- public.warehouse_connector definition

-- Drop table

-- DROP TABLE public.warehouse_connector;

CREATE TABLE public.warehouse_connector (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	"name" varchar NOT NULL,
	url varchar NOT NULL,
	core_to_connector_token varchar NOT NULL,
	CONSTRAINT ck_warehouse_connector_warehouse_connector_name_min_length CHECK ((char_length((name)::text) > 1)),
	CONSTRAINT pk_warehouse_connector PRIMARY KEY (id),
	CONSTRAINT unique_warehouse_connector_name UNIQUE (name)
);


-- public.warehouse_group definition

-- Drop table

-- DROP TABLE public.warehouse_group;

CREATE TABLE public.warehouse_group (
	id uuid NOT NULL,
	"name" varchar NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	CONSTRAINT pk_warehouse_group PRIMARY KEY (id)
);


-- public.warehouse_webhook definition

-- Drop table

-- DROP TABLE public.warehouse_webhook;

CREATE TABLE public.warehouse_webhook (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	"name" varchar NOT NULL,
	api_token varchar NOT NULL,
	"configuration" jsonb NULL,
	CONSTRAINT pk_warehouse_webhook PRIMARY KEY (id)
);


-- public.address_validation definition

-- Drop table

-- DROP TABLE public.address_validation;

CREATE TABLE public.address_validation (
	id uuid NOT NULL,
	address_id uuid NOT NULL,
	new_address_suggestion jsonb NULL,
	time_of_last_check timestamp NULL,
	"version" int4 NULL,
	CONSTRAINT pk_address_validation PRIMARY KEY (id),
	CONSTRAINT fk_address_validation_address_id_address FOREIGN KEY (address_id) REFERENCES public.address(id),
	CONSTRAINT fk_address_validation_id_validation FOREIGN KEY (id) REFERENCES public.validation(id)
);
CREATE INDEX address_validation_address_id_idx ON public.address_validation USING btree (address_id);


-- public.async_fallback_config definition

-- Drop table

-- DROP TABLE public.async_fallback_config;

CREATE TABLE public.async_fallback_config (
	id serial4 NOT NULL,
	should_run bool NOT NULL,
	page_size int4 NOT NULL,
	blacklisted_export_types public._export_type_enum NOT NULL,
	last_submitted_export_id uuid NULL,
	CONSTRAINT ck_async_fallback_config_only_one_row_in_async_fallback_c24f CHECK ((id = 1)),
	CONSTRAINT pk_async_fallback_config PRIMARY KEY (id),
	CONSTRAINT fk_async_fallback_config_last_submitted_export_id_evers_04d9 FOREIGN KEY (last_submitted_export_id) REFERENCES public.everstox_qm__export_http(id)
);


-- public.everstox_qm__import definition

-- Drop table

-- DROP TABLE public.everstox_qm__import;

CREATE TABLE public.everstox_qm__import (
	id uuid NOT NULL,
	"type" varchar NOT NULL,
	item_id uuid NULL,
	item_type varchar NULL,
	data_in text NOT NULL,
	handler_fn_path varchar NOT NULL,
	response_code int4 NULL,
	response_body jsonb NULL,
	state public."everstox_qm__import_state_enum" NOT NULL,
	errors jsonb NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	history jsonb NULL,
	parent_id uuid NULL,
	resolved bool NULL,
	resolved_by_user_id uuid NULL,
	resolved_comment text NULL,
	resolved_date timestamp NULL,
	shop_id uuid NULL,
	shop_instance_id uuid NULL,
	warehouse_id uuid NULL,
	tags public."hstore" NULL,
	"exception" bool DEFAULT false NOT NULL,
	validator_fn_path varchar NULL,
	logistics_partner_id uuid NULL,
	CONSTRAINT pk_everstox_qm__import PRIMARY KEY (id),
	CONSTRAINT fk_everstox_qm__import_parent FOREIGN KEY (parent_id) REFERENCES public.everstox_qm__import(id)
)
WITH (
	autovacuum_vacuum_scale_factor=0.008,
	autovacuum_enabled=false
);
CREATE INDEX everstox_qm__import__i_creation_date_parent_id_not_null ON public.everstox_qm__import USING btree (creation_date) WHERE (parent_id IS NOT NULL);
CREATE INDEX everstox_qm__import__partial_lp_id_closed ON public.everstox_qm__import USING btree (logistics_partner_id, item_type, creation_date) WHERE ((logistics_partner_id IS NOT NULL) AND (parent_id IS NULL));
CREATE INDEX everstox_qm__import__partial_lp_id_error_open ON public.everstox_qm__import USING btree (logistics_partner_id, state, creation_date) WHERE ((logistics_partner_id IS NOT NULL) AND (parent_id IS NULL) AND (state <> ALL (ARRAY['imported'::everstox_qm__import_state_enum, 'async_imported'::everstox_qm__import_state_enum])));
CREATE INDEX everstox_qm__import__resolved_idx ON public.everstox_qm__import USING btree (resolved);
CREATE INDEX everstox_qm__import_i_creation_date_id_tags_return_reference ON public.everstox_qm__import USING btree (creation_date, id, ((tags -> 'return_reference'::text)));
CREATE INDEX everstox_qm__import_i_item_type ON public.everstox_qm__import USING btree (item_type);
CREATE INDEX everstox_qm__import_i_parent_id ON public.everstox_qm__import USING btree (parent_id);
CREATE INDEX everstox_qm__import_i_shop_id_shop_instance_id ON public.everstox_qm__import USING btree (shop_id, shop_instance_id);
CREATE INDEX everstox_qm__import_i_shop_id_type ON public.everstox_qm__import USING btree (shop_id, item_type);
CREATE INDEX everstox_qm__import_i_shop_id_warehouse_id ON public.everstox_qm__import USING btree (shop_id, warehouse_id);
CREATE INDEX everstox_qm__import_i_tags_fulfillment_id ON public.everstox_qm__import USING btree (((tags -> 'fulfillment_id'::text)));
CREATE INDEX everstox_qm__import_i_tags_order_number ON public.everstox_qm__import USING btree (((tags -> 'order_number'::text)));
CREATE INDEX everstox_qm__import_i_tags_sku ON public.everstox_qm__import USING btree (((tags -> 'sku'::text)));
CREATE INDEX everstox_qm__import_i_tags_transfer_number ON public.everstox_qm__import USING btree (((tags -> 'transfer_number'::text)));
CREATE INDEX everstox_qm__import_i_type ON public.everstox_qm__import USING btree (type);
CREATE INDEX everstox_qm__import_item_type_shop_id_creation_date_idx ON public.everstox_qm__import USING btree (item_type, shop_id, creation_date);
CREATE INDEX everstox_qm__import_item_type_shop_id_state_creation_date_idx ON public.everstox_qm__import USING btree (item_type, shop_id, state, creation_date);
CREATE INDEX everstox_qm__import_shop_item_type_error_states_or_idx ON public.everstox_qm__import USING btree (shop_id, item_type) WHERE ((state = 'error'::everstox_qm__import_state_enum) OR (state = 'async_error'::everstox_qm__import_state_enum));
CREATE INDEX everstox_qm__import_shop_item_type_open_states_idx ON public.everstox_qm__import USING btree (shop_id, item_type) WHERE (state = ANY (ARRAY['in_progress'::everstox_qm__import_state_enum, 'async_in_progress'::everstox_qm__import_state_enum, 'async_new'::everstox_qm__import_state_enum]));
CREATE INDEX everstox_qm__import_state_warehouse_id_creation_date_idx ON public.everstox_qm__import USING btree (state, warehouse_id, creation_date DESC);
CREATE INDEX qm__import_creation_date_shop_closed_states_resolved_idx ON public.everstox_qm__import USING btree (creation_date DESC, shop_id) WHERE ((state = ANY (ARRAY['imported'::everstox_qm__import_state_enum, 'skipped'::everstox_qm__import_state_enum, 'async_imported'::everstox_qm__import_state_enum, 'async_skipped'::everstox_qm__import_state_enum])) OR (resolved IS TRUE));
CREATE INDEX qm__import_shop_item_type_creation_date_error_states_idx ON public.everstox_qm__import USING btree (shop_id, item_type, creation_date) WHERE (state = ANY (ARRAY['error'::everstox_qm__import_state_enum, 'async_error'::everstox_qm__import_state_enum]));


-- public.export_http_history definition

-- Drop table

-- DROP TABLE public.export_http_history;

CREATE TABLE public.export_http_history (
	id uuid NOT NULL,
	export_id uuid NOT NULL,
	modified_by_user_id uuid NULL,
	body jsonb NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	CONSTRAINT pk_export_http_history PRIMARY KEY (id),
	CONSTRAINT fk_export_http_history_export_id_everstox_qm__export_http FOREIGN KEY (export_id) REFERENCES public.everstox_qm__export_http(id) ON DELETE CASCADE
);


-- public.feature_flag definition

-- Drop table

-- DROP TABLE public.feature_flag;

CREATE TABLE public.feature_flag (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	"name" public."feature_flag_name_enum" NOT NULL,
	description varchar NOT NULL,
	feature_flag_type public."feature_flag_type_enum" NOT NULL,
	human_readable_name varchar NOT NULL,
	feature_flag_group_id uuid NULL,
	platform_type public."feature_flag_platform_type_enum" NOT NULL,
	value_schema jsonb NULL,
	supported_warehouse_group_ids _varchar NULL,
	CONSTRAINT pk_feature_flag PRIMARY KEY (id),
	CONSTRAINT fk_feature_flag_feature_flag_group_id_feature_flag_group FOREIGN KEY (feature_flag_group_id) REFERENCES public.feature_flag_group(id) ON DELETE CASCADE
);
CREATE INDEX ix_feature_flag_feature_flag_group_id ON public.feature_flag USING btree (feature_flag_group_id);
CREATE INDEX ix_feature_flag_feature_flag_type ON public.feature_flag USING btree (feature_flag_type);
CREATE UNIQUE INDEX ix_feature_flag_name ON public.feature_flag USING btree (name);
CREATE INDEX ix_feature_flag_platform_type ON public.feature_flag USING btree (platform_type);


-- public.import_history definition

-- Drop table

-- DROP TABLE public.import_history;

CREATE TABLE public.import_history (
	id uuid NOT NULL,
	import_id uuid NOT NULL,
	modified_by_user_id uuid NULL,
	"data" text NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	CONSTRAINT pk_import_history PRIMARY KEY (id),
	CONSTRAINT fk_import_history_import_id_everstox_qm__import FOREIGN KEY (import_id) REFERENCES public.everstox_qm__import(id) ON DELETE CASCADE
);


-- public.warehouse definition

-- Drop table

-- DROP TABLE public.warehouse;

CREATE TABLE public.warehouse (
	id uuid NOT NULL,
	"name" varchar NULL,
	cut_off_time time NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	cut_off_window int4 NULL,
	cut_off_type public."cut_off_type_enum" NOT NULL,
	empty_shipments_items_behavior public."empty_shipments_items_behavior_enum" NOT NULL,
	auto_create_product bool NOT NULL,
	connector_to_core_token uuid NOT NULL,
	internal_reference varchar NULL,
	supports_bundle_calculations bool NOT NULL,
	collect_stock_discrepancy bool NOT NULL,
	onboarding bool DEFAULT false NOT NULL,
	logistics_partner_id uuid NULL,
	updating_batch_exp_date_strategy public."updating_batch_exp_date_strategy_enum" NOT NULL,
	warehouse_connector_id uuid NULL,
	shop_explode_bundles bool NOT NULL,
	lp_display_name varchar NULL,
	stock_update_quantity_field_behavior public."stock_update_quantity_field_behavior_enum" NOT NULL,
	warehouse_webhook_id uuid NULL,
	integration_type public."warehouse_integration_type_enum" NULL,
	CONSTRAINT pk_warehouse PRIMARY KEY (id),
	CONSTRAINT uq_warehouse_connector_to_core_token UNIQUE (connector_to_core_token),
	CONSTRAINT fk_warehouse_logistics_partner_id_warehouse_group FOREIGN KEY (logistics_partner_id) REFERENCES public.warehouse_group(id),
	CONSTRAINT fk_warehouse_warehouse_connector_id_warehouse_connector FOREIGN KEY (warehouse_connector_id) REFERENCES public.warehouse_connector(id),
	CONSTRAINT fk_warehouse_warehouse_webhook_id_warehouse_webhook FOREIGN KEY (warehouse_webhook_id) REFERENCES public.warehouse_webhook(id)
);
CREATE INDEX ix_logistics_partner_id ON public.warehouse USING btree (logistics_partner_id);


-- public.stock_update_metric definition

-- Drop table

-- DROP TABLE public.stock_update_metric;

CREATE TABLE public.stock_update_metric (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	sku varchar NOT NULL,
	warehouse_id uuid NOT NULL,
	discrepancy int4 NOT NULL,
	CONSTRAINT pk_stock_update_metric PRIMARY KEY (id),
	CONSTRAINT fk_stock_update_metric_warehouse_id_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id)
);


-- public.action_counter definition

-- Drop table

-- DROP TABLE public.action_counter;

CREATE TABLE public.action_counter (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	"action" varchar NOT NULL,
	user_id uuid NOT NULL,
	count int2 NOT NULL,
	CONSTRAINT pk_action_counter PRIMARY KEY (id),
	CONSTRAINT unique_action_user_id UNIQUE (action, user_id)
);


-- public.async_execution_config definition

-- Drop table

-- DROP TABLE public.async_execution_config;

CREATE TABLE public.async_execution_config (
	id uuid NOT NULL,
	shop_id uuid NULL,
	action_type varchar NOT NULL,
	active bool NOT NULL,
	queue_priority int4 NOT NULL,
	in_queue_priority int4 NOT NULL,
	enable_fallback_queue bool DEFAULT false NOT NULL,
	additional_config json NULL,
	CONSTRAINT in_queue_priority_in_range CHECK (((queue_priority > 0) AND (queue_priority < 11))),
	CONSTRAINT pk_async_execution_config PRIMARY KEY (id),
	CONSTRAINT queue_priority_in_range CHECK (((queue_priority > 0) AND (queue_priority < 11)))
);
CREATE INDEX ix_async_execution_config_shop_id ON public.async_execution_config USING btree (shop_id);
CREATE UNIQUE INDEX ix_unique_shop_id_action_type ON public.async_execution_config USING btree (action_type) WHERE (shop_id IS NULL);
CREATE UNIQUE INDEX ix_unique_shop_id_action_type_none ON public.async_execution_config USING btree (shop_id, action_type) WHERE (shop_id IS NOT NULL);


-- public.auth_token definition

-- Drop table

-- DROP TABLE public.auth_token;

CREATE TABLE public.auth_token (
	id uuid NOT NULL,
	"token" varchar(500) NOT NULL,
	user_id uuid NOT NULL,
	state varchar NOT NULL,
	expiration_date timestamp NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	token_type public."token_type_enum" DEFAULT 'access_token'::token_type_enum NOT NULL,
	session_id uuid NULL,
	CONSTRAINT pk_auth_token PRIMARY KEY (id),
	CONSTRAINT uq_auth_token_token UNIQUE (token)
);


-- public.blocked_module_log definition

-- Drop table

-- DROP TABLE public.blocked_module_log;

CREATE TABLE public.blocked_module_log (
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	id uuid NOT NULL,
	order_id uuid NOT NULL,
	module_name varchar NOT NULL,
	status public."blocked_module_log_status_enum" NOT NULL,
	"result" varchar NULL,
	pipeline_id uuid NOT NULL,
	module_position int4 NOT NULL,
	module_internal_state varchar NULL,
	CONSTRAINT pk_blocked_module_log PRIMARY KEY (id),
	CONSTRAINT unique_order_id_pipeline_id_module_name UNIQUE (order_id, pipeline_id, module_name)
);
CREATE INDEX blocked_module_log_status_internal_state_partial_idx ON public.blocked_module_log USING btree (status, module_internal_state) WHERE (status = ANY (ARRAY['blocked'::blocked_module_log_status_enum, 'failed'::blocked_module_log_status_enum]));
CREATE INDEX blocked_module_log_status_module_name_partial_idx ON public.blocked_module_log USING btree (status, module_name) WHERE (status = ANY (ARRAY['blocked'::blocked_module_log_status_enum, 'failed'::blocked_module_log_status_enum]));
CREATE UNIQUE INDEX ix_blocked_module_log_id ON public.blocked_module_log USING btree (id);
CREATE INDEX ix_blocked_module_log_order_id ON public.blocked_module_log USING btree (order_id);


-- public.cancellation definition

-- Drop table

-- DROP TABLE public.cancellation;

CREATE TABLE public.cancellation (
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	id uuid NOT NULL,
	fulfillment_id uuid NOT NULL,
	email varchar NOT NULL,
	state public."cancellation_status_enum" NOT NULL,
	CONSTRAINT pk_cancellation PRIMARY KEY (id)
);
CREATE INDEX cancellation_idx_fulfillment_id ON public.cancellation USING btree (fulfillment_id);
CREATE INDEX ix_cancellation_state ON public.cancellation USING btree (state);


-- public.carrier definition

-- Drop table

-- DROP TABLE public.carrier;

CREATE TABLE public.carrier (
	id uuid NOT NULL,
	"name" varchar NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	status varchar NOT NULL,
	shop_id uuid NULL,
	tracking_url_template varchar NULL,
	dummy_tr_generator varchar NULL,
	parcel_perform_reference varchar NULL,
	CONSTRAINT pk_carrier PRIMARY KEY (id)
);
CREATE INDEX carrier_name_idx ON public.carrier USING btree (name);


-- public.error_log definition

-- Drop table

-- DROP TABLE public.error_log;

CREATE TABLE public.error_log (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	from_service varchar NOT NULL,
	entity_id uuid NULL,
	entity_type public."entity_type_enum" NULL,
	error_message text NULL,
	"comments" text NULL,
	history _jsonb NULL,
	error_code _varchar NOT NULL,
	export_id uuid NULL,
	import_id uuid NULL,
	acknowledged_by_id uuid NULL,
	acknowledged_comment text NULL,
	acknowledged_date timestamp NULL,
	CONSTRAINT pk_error_log PRIMARY KEY (id)
);
CREATE INDEX error_log_creation_date_idx ON public.error_log USING btree (creation_date DESC);
CREATE INDEX error_log_entity_type_idx ON public.error_log USING btree (entity_type);
CREATE INDEX error_log_export_idx ON public.error_log USING btree (creation_date DESC, from_service) WHERE (entity_type = 'export'::entity_type_enum);
CREATE INDEX error_log_from_service_idx ON public.error_log USING btree (from_service);
CREATE INDEX error_log_import_idx ON public.error_log USING btree (creation_date DESC, from_service) WHERE (entity_type = 'import'::entity_type_enum);
CREATE INDEX error_log_search_gin ON public.error_log USING gin (error_message gin_trgm_ops, comments gin_trgm_ops);
CREATE INDEX ix_error_log_export_id ON public.error_log USING btree (export_id);
CREATE INDEX ix_error_log_import_id ON public.error_log USING btree (import_id);


-- public."event" definition

-- Drop table

-- DROP TABLE public."event";

CREATE TABLE public."event" (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shop_id uuid NULL,
	warehouse_id uuid NULL,
	item_id uuid NULL,
	item_type varchar NULL,
	event_type varchar NOT NULL,
	event_subject varchar NOT NULL,
	event_message text NOT NULL,
	CONSTRAINT pk_event PRIMARY KEY (id)
);
CREATE INDEX ix_event_event_type ON public.event USING btree (event_type);
CREATE INDEX ix_event_shop_id ON public.event USING btree (shop_id);
CREATE INDEX ix_event_warehouse_id ON public.event USING btree (warehouse_id);


-- public.feature_flag_history definition

-- Drop table

-- DROP TABLE public.feature_flag_history;

CREATE TABLE public.feature_flag_history (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	"action" bool NOT NULL,
	shop_x_feature_flag_id uuid NULL,
	exec_by_user_id uuid NOT NULL,
	value jsonb NULL,
	CONSTRAINT pk_feature_flag_history PRIMARY KEY (id)
);
CREATE INDEX ix_feature_flag_history_shop_x_feature_flag_id ON public.feature_flag_history USING btree (shop_x_feature_flag_id);


-- public.fulfillment definition

-- Drop table

-- DROP TABLE public.fulfillment;

CREATE TABLE public.fulfillment (
	id uuid NOT NULL,
	order_id uuid NULL,
	warehouse_id uuid NULL,
	state varchar DEFAULT 'new'::character varying NULL,
	errors _text NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	hours_late int4 NOT NULL,
	out_of_stock_hours int4 NOT NULL,
	warehouse_late_hours int4 NOT NULL,
	completed_date timestamp NULL,
	shipping_address_id uuid NOT NULL,
	billing_address_id uuid NOT NULL,
	cancellation_type public."cancellation_type_enum" NULL,
	fulfillment_priority int2 NULL,
	logistics_partner_id uuid NULL,
	shop_id uuid NOT NULL,
	CONSTRAINT pk_fulfillment PRIMARY KEY (id)
);
CREATE INDEX fulfillment_id_warehouse ON public.fulfillment USING btree (warehouse_id);
CREATE INDEX fulfillment_idx_warehouse_id_id ON public.fulfillment USING btree (warehouse_id, id);
CREATE INDEX fulfillment_shop_id_completed_date_idx ON public.fulfillment USING btree (shop_id, completed_date);
CREATE INDEX fulfillment_warehouse_id_state_idx ON public.fulfillment USING btree (warehouse_id, state);
CREATE INDEX ix_fulfillment_completed_date ON public.fulfillment USING btree (completed_date);
CREATE INDEX ix_fulfillment_id_creation_date ON public.fulfillment USING btree (id, creation_date);
CREATE INDEX ix_fulfillment_order_id ON public.fulfillment USING btree (order_id);
CREATE INDEX ix_fulfillment_state ON public.fulfillment USING btree (state);


-- public.fulfillment_item definition

-- Drop table

-- DROP TABLE public.fulfillment_item;

CREATE TABLE public.fulfillment_item (
	id uuid NOT NULL,
	fulfillment_id uuid NOT NULL,
	order_item_id uuid NOT NULL,
	quantity int4 NOT NULL,
	state varchar DEFAULT 'new'::character varying NULL,
	errors _text NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	out_of_stock_hours int4 NOT NULL,
	CONSTRAINT pk_fulfillment_item PRIMARY KEY (id)
);
CREATE INDEX fulfillment_item_id_covering_order_item_id_idx ON public.fulfillment_item USING btree (id) INCLUDE (order_item_id);
CREATE INDEX fulfillment_item_idx_order_id_creation_date ON public.fulfillment_item USING btree (order_item_id, creation_date);
CREATE INDEX fulfillment_item_state_idx ON public.fulfillment_item USING btree (state);
CREATE INDEX ix_fulfillment_item_fulfillment_id ON public.fulfillment_item USING btree (fulfillment_id);


-- public.fulfillment_item_price definition

-- Drop table

-- DROP TABLE public.fulfillment_item_price;

CREATE TABLE public.fulfillment_item_price (
	id uuid NOT NULL,
	currency varchar NOT NULL,
	price_net_after_discount numeric NOT NULL,
	tax_amount numeric NOT NULL,
	discount_gross numeric NOT NULL,
	quantity int4 NOT NULL,
	fulfillment_item_id uuid NOT NULL,
	order_item_price_id uuid NOT NULL,
	tax_rate numeric NULL,
	creation_date timestamp DEFAULT '2010-01-01 00:00:00'::timestamp without time zone NULL,
	updated_date timestamp DEFAULT '2010-01-01 00:00:00'::timestamp without time zone NULL,
	CONSTRAINT pk_fulfillment_item_price PRIMARY KEY (id)
);
CREATE INDEX fulfillment_item_price_creation_date_idx ON public.fulfillment_item_price USING btree (creation_date) WHERE (creation_date > '2010-01-01 00:00:00'::timestamp without time zone);
CREATE INDEX fulfillment_item_price_updated_date_idx ON public.fulfillment_item_price USING btree (updated_date) WHERE (updated_date > '2010-01-01 00:00:00'::timestamp without time zone);
CREATE INDEX ix_fulfillment_item_price_fulfillment_item_id ON public.fulfillment_item_price USING btree (fulfillment_item_id);


-- public.fulfillment_update_request definition

-- Drop table

-- DROP TABLE public.fulfillment_update_request;

CREATE TABLE public.fulfillment_update_request (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	state public."entity_update_request_status_enum" NOT NULL,
	body jsonb NOT NULL,
	created_by uuid NULL,
	fulfillment_id uuid NOT NULL,
	parent_id uuid NULL,
	CONSTRAINT pk_fulfillment_update_request PRIMARY KEY (id)
);
CREATE INDEX ix_fulfillment_update_request_creation_date ON public.fulfillment_update_request USING btree (creation_date);
CREATE INDEX ix_fulfillment_update_request_fulfillment_id ON public.fulfillment_update_request USING btree (fulfillment_id);
CREATE INDEX ix_fulfillment_update_request_state ON public.fulfillment_update_request USING btree (state);


-- public.gdpr_request definition

-- Drop table

-- DROP TABLE public.gdpr_request;

CREATE TABLE public.gdpr_request (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shop_id uuid NOT NULL,
	email varchar NOT NULL,
	state varchar NOT NULL,
	errors jsonb NULL,
	core_anonymized bool NOT NULL,
	shop_connector_anonymized bool NOT NULL,
	CONSTRAINT pk_gdpr_request PRIMARY KEY (id),
	CONSTRAINT uq_gdpr_request_shop_email UNIQUE (shop_id, email)
);
CREATE INDEX idx_gdpr_request_creation_date ON public.gdpr_request USING btree (creation_date);
CREATE INDEX idx_gdpr_request_shop_id ON public.gdpr_request USING btree (shop_id);
CREATE INDEX idx_gdpr_request_state ON public.gdpr_request USING btree (state);


-- public.maintenance_script_history definition

-- Drop table

-- DROP TABLE public.maintenance_script_history;

CREATE TABLE public.maintenance_script_history (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	exec_by_user_id uuid NOT NULL,
	body text NULL,
	response text NULL,
	response_code text NULL,
	script_name text NOT NULL,
	CONSTRAINT pk_maintenance_script_history PRIMARY KEY (id)
);


-- public.notification definition

-- Drop table

-- DROP TABLE public.notification;

CREATE TABLE public.notification (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	event_id uuid NOT NULL,
	user_id uuid NOT NULL,
	notification_type public."notification_type_enum" NOT NULL,
	state public."notification_state_enum" NOT NULL,
	read_datetime timestamp NULL,
	CONSTRAINT pk_notification PRIMARY KEY (id)
);
CREATE INDEX ix_notification_notification_type ON public.notification USING btree (notification_type);
CREATE INDEX ix_notification_state ON public.notification USING btree (state);
CREATE INDEX ix_notification_user_id ON public.notification USING btree (user_id);


-- public.notification_message definition

-- Drop table

-- DROP TABLE public.notification_message;

CREATE TABLE public.notification_message (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	"source" varchar(255) NOT NULL,
	entity varchar(255) NULL,
	item_id uuid NULL,
	title varchar(255) NOT NULL,
	message text NOT NULL,
	"level" public."notification_level_enum" NOT NULL,
	notification_type_id uuid NOT NULL,
	shop_id uuid NULL,
	warehouse_id uuid NULL,
	CONSTRAINT pk_notification_message PRIMARY KEY (id)
);


-- public."order" definition

-- Drop table

-- DROP TABLE public."order";

CREATE TABLE public."order" (
	id uuid NOT NULL,
	shop_id uuid NULL,
	shipping_address_id uuid NOT NULL,
	billing_address_id uuid NOT NULL,
	payment_method_id uuid NULL,
	order_date timestamp NOT NULL,
	state varchar DEFAULT 'new'::character varying NULL,
	errors _text NOT NULL,
	order_number varchar(255) NOT NULL,
	customer_email varchar(255) NULL,
	financial_status public."financial_status_enum" NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	hours_late int4 NOT NULL,
	shop_instance_id uuid NOT NULL,
	out_of_stock_hours int4 NOT NULL,
	warehouse_late_hours int4 NOT NULL,
	requested_delivery_date timestamp NULL,
	order_priority int2 NULL,
	requested_warehouse_id uuid NULL,
	picking_date timestamp NULL,
	picking_hint varchar NULL,
	packing_hint varchar NULL,
	print_return_label bool NULL,
	order_type varchar DEFAULT 'Regular'::character varying NOT NULL,
	CONSTRAINT pk_order PRIMARY KEY (id),
	CONSTRAINT unique_shop_instance_id_order_number UNIQUE (shop_instance_id, order_number)
);
CREATE INDEX ix_order_creation_date ON public."order" USING btree (creation_date);
CREATE INDEX ix_order_customer_email ON public."order" USING btree (customer_email);
CREATE INDEX ix_order_shop_id_customer_email_lower ON public."order" USING btree (shop_id, lower((customer_email)::text));
CREATE INDEX order_customer_email_gin ON public."order" USING gin (customer_email gin_trgm_ops);
CREATE INDEX order_idx_id_order_date ON public."order" USING btree (id, order_date);
CREATE INDEX order_idx_shop_id_shop_id ON public."order" USING btree (shop_id, shop_instance_id);
CREATE INDEX order_order_number_gin ON public."order" USING gin (order_number gin_trgm_ops);
CREATE INDEX order_order_number_idx ON public."order" USING btree (order_number);
CREATE INDEX order_shop_id_creation_date_id_idx ON public."order" USING btree (shop_id, creation_date, id);
CREATE INDEX order_shop_id_not_closed_state_idx ON public."order" USING btree (shop_id, state) WHERE ((state)::text <> ALL (ARRAY[('canceled'::character varying)::text, ('completed'::character varying)::text, ('rejected'::character varying)::text]));
CREATE INDEX order_shop_id_order_number_idx ON public."order" USING btree (shop_id, order_number);
CREATE INDEX order_shop_id_trimmed_order_number_idx ON public."order" USING btree (shop_id, btrim((order_number)::text));
CREATE INDEX order_shop_id_updated_date_idx ON public."order" USING btree (shop_id, updated_date);
CREATE INDEX order_state_order_date_idx ON public."order" USING btree (state, order_date);
CREATE INDEX tmp_fh_20251029_order_shop_order_date_desc_id_idx ON public."order" USING btree (shop_id, shop_instance_id, order_date DESC, id DESC);


-- public.order_attachment definition

-- Drop table

-- DROP TABLE public.order_attachment;

CREATE TABLE public.order_attachment (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	order_id uuid NOT NULL,
	attachment_type varchar NOT NULL,
	url varchar NOT NULL,
	"external" bool NOT NULL,
	CONSTRAINT pk_order_attachment PRIMARY KEY (id)
);
CREATE INDEX ix_order_attachment_order_id ON public.order_attachment USING btree (order_id);


-- public.order_custom_attribute definition

-- Drop table

-- DROP TABLE public.order_custom_attribute;

CREATE TABLE public.order_custom_attribute (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	attribute_key varchar NOT NULL,
	attribute_value varchar NOT NULL,
	order_id uuid NOT NULL,
	CONSTRAINT pk_order_custom_attribute PRIMARY KEY (id),
	CONSTRAINT unique_custom_attribute_order_id_key UNIQUE (order_id, attribute_key)
);


-- public.order_item definition

-- Drop table

-- DROP TABLE public.order_item;

CREATE TABLE public.order_item (
	id uuid NOT NULL,
	order_id uuid NOT NULL,
	product_id uuid NULL,
	quantity int4 NOT NULL,
	state varchar DEFAULT 'new'::character varying NULL,
	errors _text NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	requested_batch varchar NULL,
	requested_batch_expiration_date timestamp NULL,
	picking_hint varchar NULL,
	packing_hint varchar NULL,
	CONSTRAINT pk_order_item PRIMARY KEY (id)
);
CREATE INDEX ix_order_item_order_id ON public.order_item USING btree (order_id);
CREATE INDEX order_item_id_covering_product_id_idx ON public.order_item USING btree (id) INCLUDE (product_id);
CREATE INDEX order_item_idx_order_id_id ON public.order_item USING btree (order_id, id);
CREATE INDEX order_item_idx_product_id_order_id ON public.order_item USING btree (product_id, order_id);


-- public.order_item_custom_attribute definition

-- Drop table

-- DROP TABLE public.order_item_custom_attribute;

CREATE TABLE public.order_item_custom_attribute (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	order_item_id uuid NOT NULL,
	attribute_key varchar NOT NULL,
	attribute_value varchar NOT NULL,
	CONSTRAINT pk_order_item_custom_attribute PRIMARY KEY (id),
	CONSTRAINT unique_custom_attribute_order_item_id_key UNIQUE (order_item_id, attribute_key)
);


-- public.order_item_price definition

-- Drop table

-- DROP TABLE public.order_item_price;

CREATE TABLE public.order_item_price (
	id uuid NOT NULL,
	currency varchar NOT NULL,
	price_net_after_discount numeric NOT NULL,
	tax_amount numeric NOT NULL,
	discount_gross numeric NOT NULL,
	quantity int4 NOT NULL,
	order_item_id uuid NOT NULL,
	tax_rate numeric NULL,
	creation_date timestamp DEFAULT '2010-01-01 00:00:00'::timestamp without time zone NULL,
	updated_date timestamp DEFAULT '2010-01-01 00:00:00'::timestamp without time zone NULL,
	CONSTRAINT pk_order_item_price PRIMARY KEY (id)
);
CREATE INDEX ix_order_item_price_order_item_id ON public.order_item_price USING btree (order_item_id);
CREATE INDEX order_item_price_creation_date_idx ON public.order_item_price USING btree (creation_date) WHERE (creation_date > '2010-01-01 00:00:00'::timestamp without time zone);
CREATE INDEX order_item_price_updated_date_idx ON public.order_item_price USING btree (updated_date) WHERE (updated_date > '2010-01-01 00:00:00'::timestamp without time zone);


-- public.otp definition

-- Drop table

-- DROP TABLE public.otp;

CREATE TABLE public.otp (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	otp int4 NOT NULL,
	user_id uuid NOT NULL,
	issue_timestamp timestamp NOT NULL,
	CONSTRAINT pk_otp PRIMARY KEY (id)
);


-- public.parcel_event definition

-- Drop table

-- DROP TABLE public.parcel_event;

CREATE TABLE public.parcel_event (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shipment_id uuid NOT NULL,
	tracking_number varchar NOT NULL,
	event_time timestamp NULL,
	event_name varchar NULL,
	event_key varchar NULL,
	phase_key varchar NULL,
	carrier_name varchar NULL,
	additional_info jsonb NULL,
	"location" jsonb NULL,
	phase varchar NULL,
	event_status varchar NULL,
	CONSTRAINT pk_parcel_event PRIMARY KEY (id)
);
CREATE INDEX ix_parcel_event_shipment_id_event_time_desc ON public.parcel_event USING btree (shipment_id, event_time DESC);
CREATE INDEX ix_parcel_event_tracking_number ON public.parcel_event USING btree (tracking_number);


-- public.payment_method definition

-- Drop table

-- DROP TABLE public.payment_method;

CREATE TABLE public.payment_method (
	id uuid NOT NULL,
	"name" varchar NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	status varchar NOT NULL,
	shop_id uuid NULL,
	CONSTRAINT pk_payment_method PRIMARY KEY (id)
);


-- public.pipeline definition

-- Drop table

-- DROP TABLE public.pipeline;

CREATE TABLE public.pipeline (
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	id uuid NOT NULL,
	shop_id uuid NOT NULL,
	"name" varchar NOT NULL,
	description varchar NULL,
	is_active bool DEFAULT false NOT NULL,
	CONSTRAINT pk_pipeline PRIMARY KEY (id),
	CONSTRAINT unique_shop_id_pipeline_name UNIQUE (shop_id, name)
);
CREATE UNIQUE INDEX ix_pipeline_id ON public.pipeline USING btree (id);
CREATE INDEX ix_pipeline_shop_id ON public.pipeline USING btree (shop_id);


-- public.pipeline_decision_config definition

-- Drop table

-- DROP TABLE public.pipeline_decision_config;

CREATE TABLE public.pipeline_decision_config (
	id uuid NOT NULL,
	shop_id uuid NOT NULL,
	"configuration" jsonb NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	CONSTRAINT pk_pipeline_decision_config PRIMARY KEY (id)
);
CREATE UNIQUE INDEX pipeline_decision_config_shop_id_idx ON public.pipeline_decision_config USING btree (shop_id);


-- public.pipeline_x_module definition

-- Drop table

-- DROP TABLE public.pipeline_x_module;

CREATE TABLE public.pipeline_x_module (
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	id uuid NOT NULL,
	pipeline_id uuid NOT NULL,
	module_name varchar NOT NULL,
	"position" int4 NOT NULL,
	is_active bool DEFAULT false NOT NULL,
	config jsonb NULL,
	CONSTRAINT pk_pipeline_x_module PRIMARY KEY (id)
);
CREATE UNIQUE INDEX ix_pipeline_x_module_id ON public.pipeline_x_module USING btree (id);
CREATE INDEX ix_pipeline_x_module_pipeline_id ON public.pipeline_x_module USING btree (pipeline_id);


-- public.product definition

-- Drop table

-- DROP TABLE public.product;

CREATE TABLE public.product (
	id uuid NOT NULL,
	shop_id uuid NOT NULL,
	"name" varchar NOT NULL,
	sku varchar NOT NULL,
	status public."product_status_enum" NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	batch_product bool NOT NULL,
	ignore_during_import bool NOT NULL,
	color varchar(30) NULL,
	country_of_origin varchar NULL,
	customs_code varchar NULL,
	image_urls _jsonb NOT NULL,
	"size" varchar(30) NULL,
	bundle_product bool NOT NULL,
	customs_description varchar NULL,
	ignore_during_shipment bool NOT NULL,
	batch_date_type public."batch_date_type_enum" NULL,
	CONSTRAINT pk_product PRIMARY KEY (id),
	CONSTRAINT unique_shop_id_sku UNIQUE (shop_id, sku)
);
CREATE INDEX idx_product_shop_composite ON public.product USING btree (shop_id, id);
CREATE INDEX ix_product_sku ON public.product USING btree (sku);
CREATE INDEX manual_product_idx_name ON public.product USING btree (name);
CREATE INDEX manual_product_idx_shop_id_status_name ON public.product USING btree (shop_id, status, name);
CREATE INDEX product_id_covering_sku_idx ON public.product USING btree (id) INCLUDE (sku);


-- public.product_bundle definition

-- Drop table

-- DROP TABLE public.product_bundle;

CREATE TABLE public.product_bundle (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	quantity int4 NOT NULL,
	bundle_product_id uuid NOT NULL,
	product_id uuid NOT NULL,
	CONSTRAINT pk_product_bundle PRIMARY KEY (id)
);
CREATE INDEX idx_product_bundle_product_id ON public.product_bundle USING btree (product_id);
CREATE INDEX product_bundle_idx_bundle_product_id ON public.product_bundle USING btree (bundle_product_id);


-- public.product_custom_attribute definition

-- Drop table

-- DROP TABLE public.product_custom_attribute;

CREATE TABLE public.product_custom_attribute (
	id uuid NOT NULL,
	product_id uuid NOT NULL,
	attribute_key varchar NOT NULL,
	attribute_value varchar NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	CONSTRAINT pk_product_custom_attribute PRIMARY KEY (id),
	CONSTRAINT unique_custom_attribute_product_id_key UNIQUE (product_id, attribute_key)
);


-- public.product_unit definition

-- Drop table

-- DROP TABLE public.product_unit;

CREATE TABLE public.product_unit (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	product_id uuid NOT NULL,
	base_unit_id uuid NULL,
	"name" varchar NOT NULL,
	default_unit bool NOT NULL,
	quantity_of_base_unit numeric NOT NULL,
	gtin varchar NULL,
	weight_net_in_kg numeric NULL,
	weight_gross_in_kg numeric NULL,
	height_in_cm numeric NULL,
	width_in_cm numeric NULL,
	length_in_cm numeric NULL,
	CONSTRAINT pk_product_unit PRIMARY KEY (id),
	CONSTRAINT unique_product_id_name UNIQUE (product_id, name)
);
CREATE INDEX ix_product_unit_product_id ON public.product_unit USING btree (product_id);
CREATE INDEX product_unit_base_unit_id_idx ON public.product_unit USING btree (base_unit_id);


-- public.product_unit_barcode definition

-- Drop table

-- DROP TABLE public.product_unit_barcode;

CREATE TABLE public.product_unit_barcode (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	product_unit_id uuid NOT NULL,
	barcode_name varchar NOT NULL,
	barcode_value varchar NOT NULL,
	CONSTRAINT pk_product_unit_barcode PRIMARY KEY (id),
	CONSTRAINT unique_barcode_name_product_unit_id UNIQUE (product_unit_id, barcode_name)
);
CREATE INDEX idx_product_unit_id ON public.product_unit_barcode USING btree (product_unit_id);
CREATE INDEX ix_product_unit_barcode_product_unit_id ON public.product_unit_barcode USING btree (product_unit_id);


-- public.report definition

-- Drop table

-- DROP TABLE public.report;

CREATE TABLE public.report (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	"type" varchar NOT NULL,
	args jsonb NOT NULL,
	filename varchar NULL,
	content_type varchar NULL,
	url varchar NULL,
	shop_id uuid NOT NULL,
	user_id uuid NULL,
	status public."report_status_enum" NULL,
	CONSTRAINT pk_report PRIMARY KEY (id)
);
CREATE INDEX report_type_status_creation_date_idx ON public.report USING btree (type, status, creation_date);


-- public."return" definition

-- Drop table

-- DROP TABLE public."return";

CREATE TABLE public."return" (
	id uuid NOT NULL,
	return_reference varchar NULL,
	shop_id uuid NOT NULL,
	order_id uuid NULL,
	warehouse_id uuid NULL,
	return_date timestamp NULL,
	state varchar DEFAULT 'new'::character varying NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	rma_num varchar NULL,
	return_reason varchar DEFAULT 'Customer Returned'::character varying NULL,
	return_reason_code varchar DEFAULT ''::character varying NULL,
	return_announcement_creation_date timestamp NULL,
	logistics_partner_id uuid NULL,
	external_order_reference varchar NULL,
	CONSTRAINT pk_return PRIMARY KEY (id),
	CONSTRAINT unique_shop_id_return_reference UNIQUE (shop_id, return_reference)
);
CREATE INDEX return_creation_date_idx ON public.return USING btree (creation_date);
CREATE INDEX return_external_order_reference_idx ON public.return USING btree (external_order_reference);
CREATE INDEX return_idx_order_id ON public.return USING btree (order_id);
CREATE INDEX return_return_date_idx ON public.return USING btree (return_date);
CREATE INDEX return_shop_id_external_order_reference_idx ON public.return USING btree (shop_id, external_order_reference);


-- public.return_custom_attribute definition

-- Drop table

-- DROP TABLE public.return_custom_attribute;

CREATE TABLE public.return_custom_attribute (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	attribute_key varchar NOT NULL,
	attribute_value varchar NOT NULL,
	return_id uuid NOT NULL,
	CONSTRAINT pk_return_custom_attribute PRIMARY KEY (id),
	CONSTRAINT unique_custom_attribute_return_id_key UNIQUE (return_id, attribute_key)
);


-- public.return_customer_information definition

-- Drop table

-- DROP TABLE public.return_customer_information;

CREATE TABLE public.return_customer_information (
	id uuid NOT NULL,
	return_v2_id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	first_name varchar NULL,
	last_name varchar NULL,
	company varchar NULL,
	email varchar NULL,
	phone varchar NULL,
	address_1 varchar NULL,
	address_2 varchar NULL,
	city varchar NULL,
	country varchar NULL,
	country_code varchar NULL,
	postal_code varchar NULL,
	state_or_province varchar NULL,
	CONSTRAINT pk_return_customer_information PRIMARY KEY (id)
);
CREATE INDEX ix_return_customer_information_email ON public.return_customer_information USING btree (email);


-- public.return_item definition

-- Drop table

-- DROP TABLE public.return_item;

CREATE TABLE public.return_item (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	quantity numeric NULL,
	return_id uuid NULL,
	product_id uuid NULL,
	customer_service_state public."return_item_customer_service_state_enum" NOT NULL,
	stock_state public."return_item_stock_state_enum" NOT NULL,
	return_reason varchar NULL,
	return_reason_code varchar NULL,
	serial_numbers _varchar NULL,
	quantity_announced int4 NULL,
	serial_numbers_announced _varchar NULL,
	stock_state_announced public."return_item_stock_state_enum" NULL,
	CONSTRAINT pk_return_item PRIMARY KEY (id)
);


-- public.return_item_batch definition

-- Drop table

-- DROP TABLE public.return_item_batch;

CREATE TABLE public.return_item_batch (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	expiration_date timestamp NULL,
	quantity int4 NOT NULL,
	batch_id uuid NULL,
	return_item_id uuid NOT NULL,
	CONSTRAINT pk_return_item_batch PRIMARY KEY (id)
);


-- public.return_item_v2 definition

-- Drop table

-- DROP TABLE public.return_item_v2;

CREATE TABLE public.return_item_v2 (
	id uuid NOT NULL,
	return_v2_id uuid NOT NULL,
	product_id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	state varchar NOT NULL,
	CONSTRAINT pk_return_item_v2 PRIMARY KEY (id)
);


-- public.return_item_v2_batch definition

-- Drop table

-- DROP TABLE public.return_item_v2_batch;

CREATE TABLE public.return_item_v2_batch (
	id uuid NOT NULL,
	return_item_v2_element_id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	expiration_date timestamp NULL,
	quantity int4 NOT NULL,
	batch varchar NULL,
	CONSTRAINT pk_return_item_v2_batch PRIMARY KEY (id)
);


-- public.return_item_v2_element definition

-- Drop table

-- DROP TABLE public.return_item_v2_element;

CREATE TABLE public.return_item_v2_element (
	id uuid NOT NULL,
	return_item_v2_id uuid NOT NULL,
	return_parcel_id uuid NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	quantity int4 NOT NULL,
	element_return_type public."return_item_v2_element_type_enum" NOT NULL,
	refund_method varchar NULL,
	return_reason varchar NULL,
	return_code varchar NULL,
	"condition" varchar NULL,
	images _varchar NULL,
	attachments _varchar NULL,
	serial_numbers _varchar NULL,
	return_shipment_id uuid NULL,
	CONSTRAINT pk_return_item_v2_element PRIMARY KEY (id)
);
CREATE INDEX return_item_v2_element_return_item_v2_id_idx ON public.return_item_v2_element USING btree (return_item_v2_id);
CREATE INDEX return_item_v2_element_return_parcel_id_idx ON public.return_item_v2_element USING btree (return_parcel_id);
CREATE INDEX return_item_v2_element_return_shipment_id_idx ON public.return_item_v2_element USING btree (return_shipment_id);


-- public.return_v2 definition

-- Drop table

-- DROP TABLE public.return_v2;

CREATE TABLE public.return_v2 (
	id uuid NOT NULL,
	shop_id uuid NOT NULL,
	warehouse_id uuid NULL,
	logistics_partner_id uuid NULL,
	order_id uuid NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	announced_date timestamp NULL,
	completion_date timestamp NULL,
	return_reviewed bool DEFAULT false NOT NULL,
	state varchar NOT NULL,
	rma_num varchar NULL,
	order_number varchar NULL,
	carrier_name varchar NULL,
	internal_notes varchar NULL,
	external_announcement_id varchar NULL,
	instructions_to_warehouse varchar NULL,
	announced_return_reason varchar NULL,
	announced_return_code varchar NULL,
	announced_images _varchar NULL,
	announced_attachments _varchar NULL,
	is_announced bool NOT NULL,
	CONSTRAINT pk_return_v2 PRIMARY KEY (id),
	CONSTRAINT unique_shop_id_external_announcement_id_v2 UNIQUE (shop_id, external_announcement_id),
	CONSTRAINT unique_shop_id_rma_num_v2 UNIQUE (shop_id, rma_num)
);
CREATE INDEX return_v2_shop_id_announced_date_idx ON public.return_v2 USING btree (shop_id, announced_date);
CREATE INDEX return_v2_shop_id_completion_date_idx ON public.return_v2 USING btree (shop_id, completion_date);
CREATE INDEX return_v2_shop_id_creation_date_idx ON public.return_v2 USING btree (shop_id, creation_date);
CREATE INDEX return_v2_shop_id_external_announcement_id_idx ON public.return_v2 USING btree (shop_id, external_announcement_id);
CREATE INDEX return_v2_shop_id_is_announced_idx ON public.return_v2 USING btree (shop_id, is_announced);
CREATE INDEX return_v2_shop_id_order_number_idx ON public.return_v2 USING btree (shop_id, order_number);
CREATE INDEX return_v2_shop_id_return_reviewed_idx ON public.return_v2 USING btree (shop_id, return_reviewed);
CREATE INDEX return_v2_shop_id_state_idx ON public.return_v2 USING btree (shop_id, state);
CREATE INDEX return_v2_shop_id_updated_date_idx ON public.return_v2 USING btree (shop_id, updated_date);
CREATE INDEX return_v2_shop_id_warehouse_id_idx ON public.return_v2 USING btree (shop_id, warehouse_id);
CREATE INDEX return_v2_warehouse_id_announced_date_idx ON public.return_v2 USING btree (warehouse_id, announced_date);
CREATE INDEX return_v2_warehouse_id_completion_date_idx ON public.return_v2 USING btree (warehouse_id, completion_date);
CREATE INDEX return_v2_warehouse_id_creation_date_idx ON public.return_v2 USING btree (warehouse_id, creation_date);
CREATE INDEX return_v2_warehouse_id_order_number_idx ON public.return_v2 USING btree (warehouse_id, order_number);
CREATE INDEX return_v2_warehouse_id_rma_num_idx ON public.return_v2 USING btree (warehouse_id, rma_num);
CREATE INDEX return_v2_warehouse_id_state_idx ON public.return_v2 USING btree (warehouse_id, state);


-- public.return_v2_parcel definition

-- Drop table

-- DROP TABLE public.return_v2_parcel;

CREATE TABLE public.return_v2_parcel (
	id uuid NOT NULL,
	return_v2_id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	state varchar NULL,
	external_parcel_reference varchar NOT NULL,
	tracking_code varchar NULL,
	carrier_name varchar NULL,
	CONSTRAINT pk_return_v2_parcel PRIMARY KEY (id)
);


-- public.return_v2_shipment definition

-- Drop table

-- DROP TABLE public.return_v2_shipment;

CREATE TABLE public.return_v2_shipment (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shop_id uuid NULL,
	warehouse_id uuid NULL,
	return_v2_id uuid NULL,
	return_reference varchar NULL,
	received_date timestamp NULL,
	received_return_reason varchar NULL,
	received_return_code varchar NULL,
	received_images _varchar NULL,
	received_attachments _varchar NULL,
	CONSTRAINT pk_return_v2_shipment PRIMARY KEY (id),
	CONSTRAINT return_v2_shipment_shop_id_return_reference_idx UNIQUE (shop_id, return_reference)
);
CREATE INDEX return_v2_shipment_return_v2_id_idx ON public.return_v2_shipment USING btree (return_v2_id);
CREATE INDEX return_v2_shipment_shop_id_creation_date_idx ON public.return_v2_shipment USING btree (shop_id, creation_date);
CREATE INDEX return_v2_shipment_shop_id_received_date_idx ON public.return_v2_shipment USING btree (shop_id, received_date);
CREATE INDEX return_v2_shipment_warehouse_id_return_reference_idx ON public.return_v2_shipment USING btree (warehouse_id, return_reference);


-- public.shipment definition

-- Drop table

-- DROP TABLE public.shipment;

CREATE TABLE public.shipment (
	id uuid NOT NULL,
	fulfillment_id uuid NOT NULL,
	carrier_id uuid NULL,
	shipment_date timestamp NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	forwarded_to_shop bool NULL,
	tracking_codes _varchar NULL,
	tracking_urls _varchar NOT NULL,
	return_tracking_codes _varchar NULL,
	rma_num varchar DEFAULT ''::character varying NULL,
	shop_id uuid NULL,
	CONSTRAINT pk_shipment PRIMARY KEY (id)
);
CREATE INDEX ix_shipment_fulfillment_id ON public.shipment USING btree (fulfillment_id);
CREATE INDEX ix_shipment_shipment_date ON public.shipment USING btree (shipment_date);
CREATE INDEX shipment_creation_date_idx ON public.shipment USING btree (creation_date);
CREATE INDEX shipment_idx_forwarded_shop_fulfillment_id ON public.shipment USING btree (forwarded_to_shop, fulfillment_id);
CREATE INDEX shipment_shop_id_carrier_id_shipment_date_idx ON public.shipment USING btree (shop_id, carrier_id, shipment_date);
CREATE INDEX shipment_shop_id_shipment_date_id_idx ON public.shipment USING btree (shop_id, shipment_date, id);
CREATE INDEX tmp_fh_20251029_ix_shipment_fulfillment_forwarded_covering ON public.shipment USING btree (fulfillment_id, forwarded_to_shop) WHERE (forwarded_to_shop = false);


-- public.shipment_custom_attribute definition

-- Drop table

-- DROP TABLE public.shipment_custom_attribute;

CREATE TABLE public.shipment_custom_attribute (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shipment_id uuid NOT NULL,
	attribute_key varchar NOT NULL,
	attribute_value varchar NOT NULL,
	CONSTRAINT pk_shipment_custom_attribute PRIMARY KEY (id)
);


-- public.shipment_event definition

-- Drop table

-- DROP TABLE public.shipment_event;

CREATE TABLE public.shipment_event (
	id uuid NOT NULL,
	shipment_id uuid NULL,
	state varchar NULL,
	errors _text NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	CONSTRAINT pk_shipment_event PRIMARY KEY (id)
);


-- public.shipment_item definition

-- Drop table

-- DROP TABLE public.shipment_item;

CREATE TABLE public.shipment_item (
	id uuid NOT NULL,
	shipment_id uuid NULL,
	fulfillment_item_id uuid NULL,
	quantity int4 NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	serial_numbers _varchar NULL,
	CONSTRAINT pk_shipment_item PRIMARY KEY (id)
);
CREATE INDEX ix_shipment_item_fulfillment_item_id ON public.shipment_item USING btree (fulfillment_item_id);
CREATE INDEX ix_shipment_item_shipment_id ON public.shipment_item USING btree (shipment_id);


-- public.shipment_option definition

-- Drop table

-- DROP TABLE public.shipment_option;

CREATE TABLE public.shipment_option (
	id uuid NOT NULL,
	"name" varchar NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	status varchar NOT NULL,
	shop_id uuid NULL,
	ignored bool NOT NULL,
	external_identifier varchar NULL,
	CONSTRAINT pk_shipment_option PRIMARY KEY (id)
);


-- public.shipment_option_alias definition

-- Drop table

-- DROP TABLE public.shipment_option_alias;

CREATE TABLE public.shipment_option_alias (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shop_id uuid NOT NULL,
	shipment_option_id uuid NOT NULL,
	"name" varchar NOT NULL,
	CONSTRAINT pk_shipment_option_alias PRIMARY KEY (id),
	CONSTRAINT unique_shipment_otption_alias_shop_id_name UNIQUE (shop_id, name)
);
CREATE INDEX shipment_option_al_idx_shipment_id ON public.shipment_option_alias USING btree (shipment_option_id);
CREATE INDEX shipment_option_al_idx_shop_id_shipment_id ON public.shipment_option_alias USING btree (shop_id, shipment_option_id);


-- public.shipment_option_rule definition

-- Drop table

-- DROP TABLE public.shipment_option_rule;

CREATE TABLE public.shipment_option_rule (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	"name" varchar NOT NULL,
	shop_id uuid NOT NULL,
	description varchar NULL,
	"configuration" jsonb NOT NULL,
	is_active bool NOT NULL,
	CONSTRAINT ck_shipment_option_rule_shipment_option_rule_name_min_length CHECK ((char_length((name)::text) > 0)),
	CONSTRAINT pk_shipment_option_rule PRIMARY KEY (id),
	CONSTRAINT unique_shop_id_shipment_option_rule_name UNIQUE (shop_id, name)
);


-- public.shipment_option_x_carrier definition

-- Drop table

-- DROP TABLE public.shipment_option_x_carrier;

CREATE TABLE public.shipment_option_x_carrier (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shipment_option_id uuid NULL,
	carrier_id uuid NULL,
	CONSTRAINT pk_shipment_option_x_carrier PRIMARY KEY (id)
);


-- public.shipment_option_x_order_item definition

-- Drop table

-- DROP TABLE public.shipment_option_x_order_item;

CREATE TABLE public.shipment_option_x_order_item (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shipment_option_id uuid NULL,
	order_item_id uuid NULL,
	CONSTRAINT pk_shipment_option_x_order_item PRIMARY KEY (id)
);
CREATE INDEX ix_shipment_option_x_order_item_order_item_id ON public.shipment_option_x_order_item USING btree (order_item_id);


-- public.shipment_option_x_shop_x_warehouse definition

-- Drop table

-- DROP TABLE public.shipment_option_x_shop_x_warehouse;

CREATE TABLE public.shipment_option_x_shop_x_warehouse (
	id uuid NOT NULL,
	shop_id uuid NULL,
	shipment_option_id uuid NULL,
	warehouse_id uuid NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	priority int2 NULL,
	CONSTRAINT pk_shipment_option_x_shop_x_warehouse PRIMARY KEY (id),
	CONSTRAINT unique_shipment_option_id_shop_id_warehouse_id UNIQUE (shop_id, shipment_option_id, warehouse_id)
);
CREATE INDEX shipment_option_x__idx_shop_id_shipment_id ON public.shipment_option_x_shop_x_warehouse USING btree (shop_id, shipment_option_id);


-- public.shipment_parcel definition

-- Drop table

-- DROP TABLE public.shipment_parcel;

CREATE TABLE public.shipment_parcel (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shipment_id uuid NOT NULL,
	tracking_code varchar NOT NULL,
	shipment_uuid uuid NULL,
	order_uuid uuid NULL,
	tracking_url varchar NULL,
	CONSTRAINT pk_shipment_parcel PRIMARY KEY (id),
	CONSTRAINT unique_shipment_id_tracking_code UNIQUE (shipment_id, tracking_code),
	CONSTRAINT uq_shipment_parcel_shipment_uuid UNIQUE (shipment_uuid)
);
CREATE INDEX ix_shipment_parcel_shipment_id ON public.shipment_parcel USING btree (shipment_id);
CREATE INDEX ix_shipment_parcel_tracking_code ON public.shipment_parcel USING btree (tracking_code);


-- public.shipped_batch definition

-- Drop table

-- DROP TABLE public.shipped_batch;

CREATE TABLE public.shipped_batch (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shipment_item_id uuid NULL,
	quantity int4 NOT NULL,
	batch varchar NULL,
	sku varchar NULL,
	expiration_date timestamp NULL,
	CONSTRAINT pk_shipped_batch PRIMARY KEY (id)
);
CREATE INDEX shipped_batch_idx_shipment_id ON public.shipped_batch USING btree (shipment_item_id);
CREATE INDEX shipped_batch_item_id_covering_sku_quantity_batch_exp_date_idx ON public.shipped_batch USING btree (shipment_item_id) INCLUDE (sku, quantity, batch, expiration_date);


-- public.shipping_price definition

-- Drop table

-- DROP TABLE public.shipping_price;

CREATE TABLE public.shipping_price (
	id uuid NOT NULL,
	currency varchar NOT NULL,
	price_net_after_discount numeric NOT NULL,
	tax_amount numeric NOT NULL,
	discount_gross numeric NOT NULL,
	order_id uuid NOT NULL,
	tax_rate numeric NULL,
	creation_date timestamp DEFAULT '2010-01-01 00:00:00'::timestamp without time zone NULL,
	updated_date timestamp DEFAULT '2010-01-01 00:00:00'::timestamp without time zone NULL,
	CONSTRAINT pk_shipping_price PRIMARY KEY (id)
);
CREATE INDEX ix_shipping_price_order_id ON public.shipping_price USING btree (order_id);
CREATE INDEX shipping_price_creation_date_idx ON public.shipping_price USING btree (creation_date) WHERE (creation_date > '2010-01-01 00:00:00'::timestamp without time zone);
CREATE INDEX shipping_price_updated_date_idx ON public.shipping_price USING btree (updated_date) WHERE (updated_date > '2010-01-01 00:00:00'::timestamp without time zone);


-- public.shop definition

-- Drop table

-- DROP TABLE public.shop;

CREATE TABLE public.shop (
	id uuid NOT NULL,
	shop_group_id uuid NULL,
	"name" varchar NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	default_shipment_option_id uuid NULL,
	feature_flags jsonb NULL,
	reported_stock_type public."reported_stock_type_enum" NOT NULL,
	order_types _varchar DEFAULT '{Regular}'::character varying[] NOT NULL,
	CONSTRAINT pk_shop PRIMARY KEY (id)
);


-- public.shop_instance definition

-- Drop table

-- DROP TABLE public.shop_instance;

CREATE TABLE public.shop_instance (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shop_id uuid NULL,
	"name" varchar NOT NULL,
	warehouse_assignment_strategy_id uuid NULL,
	requires_tracking_forwarding bool NOT NULL,
	connector_to_core_token uuid NOT NULL,
	stock_update_warehouse_ids _varchar NULL,
	tracking_forwarding_max_allowed_delay_hours int4 DEFAULT 2 NOT NULL,
	shipment_option_rule_id uuid NULL,
	onboarding bool DEFAULT false NOT NULL,
	shop_connector_id uuid NULL,
	is_dashboard_instance bool DEFAULT false NOT NULL,
	validate_shipping_addresses bool DEFAULT false NOT NULL,
	default_order_type varchar DEFAULT 'Regular'::character varying NOT NULL,
	CONSTRAINT pk_shop_instance PRIMARY KEY (id),
	CONSTRAINT uq_shop_instance_connector_to_core_token UNIQUE (connector_to_core_token)
);
CREATE INDEX idx_shop_instance_shop_id ON public.shop_instance USING btree (shop_id);


-- public.shop_instance_webhooks_subscription definition

-- Drop table

-- DROP TABLE public.shop_instance_webhooks_subscription;

CREATE TABLE public.shop_instance_webhooks_subscription (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shop_instance_id uuid NOT NULL,
	topic public."shop_instance_topic_enum" NOT NULL,
	route varchar NULL,
	custom_base_url varchar NULL,
	custom_token varchar NULL,
	topic_config jsonb NULL,
	custom_token_header varchar NULL,
	enabled bool NOT NULL,
	"comment" text NULL,
	CONSTRAINT pk_shop_instance_webhooks_subscription PRIMARY KEY (id)
);
CREATE INDEX idx_shop_instance_webhooks_enabled ON public.shop_instance_webhooks_subscription USING btree (enabled);
CREATE INDEX idx_shop_instance_webhooks_topic ON public.shop_instance_webhooks_subscription USING btree (topic);


-- public.shop_x_feature_flag definition

-- Drop table

-- DROP TABLE public.shop_x_feature_flag;

CREATE TABLE public.shop_x_feature_flag (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shop_id uuid NOT NULL,
	is_active bool NOT NULL,
	shop_instance_id uuid NULL,
	warehouse_id uuid NULL,
	feature_flag_id uuid NOT NULL,
	value jsonb NULL,
	CONSTRAINT pk_shop_x_feature_flag PRIMARY KEY (id)
);
CREATE INDEX ix_shop_x_feature_flag_feature_flag_id ON public.shop_x_feature_flag USING btree (feature_flag_id);
CREATE INDEX ix_shop_x_feature_flag_shop_id ON public.shop_x_feature_flag USING btree (shop_id);
CREATE INDEX ix_shop_x_feature_flag_shop_instance_id ON public.shop_x_feature_flag USING btree (shop_instance_id);
CREATE INDEX ix_shop_x_feature_flag_warehouse_id ON public.shop_x_feature_flag USING btree (warehouse_id);


-- public.shop_x_payment_method definition

-- Drop table

-- DROP TABLE public.shop_x_payment_method;

CREATE TABLE public.shop_x_payment_method (
	id uuid NOT NULL,
	shop_id uuid NOT NULL,
	payment_method_id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	CONSTRAINT pk_shop_x_payment_method PRIMARY KEY (id),
	CONSTRAINT unique_payment_method_per_shop UNIQUE (shop_id, payment_method_id)
);


-- public.shop_x_warehouse definition

-- Drop table

-- DROP TABLE public.shop_x_warehouse;

CREATE TABLE public.shop_x_warehouse (
	id uuid NOT NULL,
	shop_id uuid NOT NULL,
	warehouse_id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	CONSTRAINT pk_shop_x_warehouse PRIMARY KEY (id)
);


-- public.stock definition

-- Drop table

-- DROP TABLE public.stock;

CREATE TABLE public.stock (
	id uuid NOT NULL,
	warehouse_id uuid NOT NULL,
	product_id uuid NOT NULL,
	quantity int4 NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	out_of_stock_behaviour public."out_of_stock_behaviour_enum" NOT NULL,
	out_of_stock_priority int4 NOT NULL,
	stock_runway float8 NULL,
	batch_id uuid NULL,
	deleted bool NOT NULL,
	latest_stock_update timestamp NULL,
	CONSTRAINT pk_stock PRIMARY KEY (id)
);
CREATE INDEX idx_stock_product_id_id ON public.stock USING btree (product_id, id);
CREATE INDEX idx_stock_warehouse_id ON public.stock USING btree (warehouse_id);
CREATE INDEX ix_stock_product_id ON public.stock USING btree (product_id);
CREATE INDEX manual_stock_idx_product_id_warehouse_id ON public.stock USING btree (product_id, warehouse_id);


-- public.stock_alert definition

-- Drop table

-- DROP TABLE public.stock_alert;

CREATE TABLE public.stock_alert (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	threshold int4 NOT NULL,
	enabled bool NOT NULL,
	product_id uuid NOT NULL,
	warehouse_id uuid NOT NULL,
	CONSTRAINT pk_stock_alert PRIMARY KEY (id)
);
CREATE INDEX ix_stock_alert_product_id ON public.stock_alert USING btree (product_id);
CREATE INDEX ix_stock_alert_warehouse_id ON public.stock_alert USING btree (warehouse_id);
CREATE UNIQUE INDEX ix_unique_product_id_warehouse_id ON public.stock_alert USING btree (product_id, warehouse_id);


-- public.stock_allocation definition

-- Drop table

-- DROP TABLE public.stock_allocation;

CREATE TABLE public.stock_allocation (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	stock_id uuid NOT NULL,
	quantity int4 NOT NULL,
	purpose text NULL,
	deleted bool NOT NULL,
	created_by_entity_type public."stock_allocation_entity_type_enum" NOT NULL,
	created_by_id uuid NULL,
	CONSTRAINT pk_blocked_stocks PRIMARY KEY (id)
);
CREATE INDEX idx_stock_id ON public.stock_allocation USING btree (stock_id);


-- public.stock_quantity definition

-- Drop table

-- DROP TABLE public.stock_quantity;

CREATE TABLE public.stock_quantity (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	stock_id uuid NOT NULL,
	quantity int4 NOT NULL,
	stock_type public."stock_type_enum" NOT NULL,
	CONSTRAINT pk_stock_quantity PRIMARY KEY (id),
	CONSTRAINT unique_stock_id_stock_type UNIQUE (stock_id, stock_type)
);
CREATE INDEX idx_stock_quantity_composite ON public.stock_quantity USING btree (stock_id, stock_type, updated_date);
CREATE INDEX idx_stock_quantity_stock_id_stock_type_updated_date ON public.stock_quantity USING btree (stock_id, updated_date, stock_type);
CREATE INDEX stock_quantity_stock_type_updated_date_idx ON public.stock_quantity USING btree (stock_type, updated_date);


-- public.stock_reservation_update definition

-- Drop table

-- DROP TABLE public.stock_reservation_update;

CREATE TABLE public.stock_reservation_update (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	stock_id uuid NOT NULL,
	stock_reservation_datetime timestamp NULL,
	fulfillment_item_id uuid NULL,
	action_type public."stock_reservation_update_action_type_enum" NOT NULL,
	reason_code public."stock_reservation_reason_code_enum" NOT NULL,
	quantity_reserved int4 NULL,
	CONSTRAINT pk_stock_reservation_update PRIMARY KEY (id)
);
CREATE INDEX idx_stock_reservation_update_stock_id_creation_date ON public.stock_reservation_update USING btree (creation_date, stock_id);
CREATE INDEX ix_stock_reservation_update_creation_date ON public.stock_reservation_update USING btree (creation_date);
CREATE INDEX ix_stock_reservation_update_fulfillment_item_id ON public.stock_reservation_update USING btree (fulfillment_item_id);
CREATE INDEX ix_stock_reservation_update_stock_id ON public.stock_reservation_update USING btree (stock_id);


-- public.stock_sequence definition

-- Drop table

-- DROP TABLE public.stock_sequence;

CREATE TABLE public.stock_sequence (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	internal_sequence_identifier int8 NOT NULL,
	external_sequence_identifier timestamp NULL,
	stock_id uuid NOT NULL,
	CONSTRAINT pk_stock_sequence PRIMARY KEY (id),
	CONSTRAINT uq_stock_sequence_stock_id UNIQUE (stock_id)
)
WITH (
	fillfactor=70,
	autovacuum_vacuum_scale_factor=0.01,
	autovacuum_vacuum_threshold=500,
	autovacuum_analyze_scale_factor=0.02,
	autovacuum_analyze_threshold=500
);


-- public.stock_update definition

-- Drop table

-- DROP TABLE public.stock_update;

CREATE TABLE public.stock_update (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	stock_id uuid NULL,
	update_datetime timestamp NULL,
	new_quantity int4 NULL,
	action_type public."stock_update_action_type_enum" NOT NULL,
	quantity_correction int4 NULL,
	product_id uuid NULL,
	sku varchar NULL,
	batch varchar NULL,
	expiration_date varchar NULL,
	internal_sequence_identifier int8 NULL,
	shop_id uuid NULL,
	warehouse_id uuid NULL,
	processing_state public."stock_update_processing_state_enum" NOT NULL,
	received_quantity int4 NULL,
	received_quantity_blocked int4 NULL,
	received_quantity_on_hand int4 NULL,
	received_quantity_ordered int4 NULL,
	received_quantity_sellable int4 NULL,
	errors jsonb NULL,
	CONSTRAINT pk_stock_update PRIMARY KEY (id)
);
CREATE INDEX idx_stock_update_datetime_desc ON public.stock_update USING btree (update_datetime DESC);
CREATE INDEX idx_stock_update_shop_creation_date_rollup ON public.stock_update USING btree (shop_id, creation_date) WHERE ((stock_id IS NOT NULL) AND (processing_state = ANY (ARRAY['updated'::stock_update_processing_state_enum, 'unchanged'::stock_update_processing_state_enum])) AND (errors IS NULL));
CREATE INDEX idx_stock_update_stock_id ON public.stock_update USING btree (stock_id);
CREATE INDEX idx_stock_update_su_dt ON public.stock_update USING btree (update_datetime) INCLUDE (id) WHERE (processing_state = ANY (ARRAY['skipped'::stock_update_processing_state_enum, 'unchanged'::stock_update_processing_state_enum]));
CREATE INDEX ix_stock_update_shop_sku_dt_desc ON public.stock_update USING btree (shop_id, sku, update_datetime DESC) WHERE ((shop_id IS NOT NULL) AND (sku IS NOT NULL));
CREATE INDEX ix_stock_update_shop_sku_wh_dt_desc ON public.stock_update USING btree (shop_id, sku, warehouse_id, update_datetime DESC) WHERE ((shop_id IS NOT NULL) AND (sku IS NOT NULL) AND (warehouse_id IS NOT NULL));
CREATE INDEX ix_stock_update_stock_id_creation_date ON public.stock_update USING btree (stock_id, creation_date DESC);
CREATE INDEX stock_update_stock_id ON public.stock_update USING btree (stock_id);


-- public.stock_update_rollup definition

-- Drop table

-- DROP TABLE public.stock_update_rollup;

CREATE TABLE public.stock_update_rollup (
	stock_id uuid NOT NULL,
	update_date date NOT NULL,
	new_quantity int4 NULL,
	CONSTRAINT pk_stock_update_rollup PRIMARY KEY (stock_id, update_date)
);
CREATE INDEX ix_update_rollup_stock_id ON public.stock_update_rollup USING btree (stock_id);


-- public.transfer definition

-- Drop table

-- DROP TABLE public.transfer;

CREATE TABLE public.transfer (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shop_id uuid NOT NULL,
	destination uuid NOT NULL,
	transfer_number varchar(255) NOT NULL,
	"ETA" timestamp NOT NULL,
	"source" varchar NULL,
	state public."transfer_state_enum" NOT NULL,
	transfer_packing_type varchar NULL,
	logistics_partner_id uuid NULL,
	CONSTRAINT pk_transfer PRIMARY KEY (id),
	CONSTRAINT unique_shop_id_transfer_number UNIQUE (shop_id, transfer_number)
);


-- public.transfer_custom_attribute definition

-- Drop table

-- DROP TABLE public.transfer_custom_attribute;

CREATE TABLE public.transfer_custom_attribute (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	attribute_key varchar NOT NULL,
	attribute_value varchar NOT NULL,
	transfer_id uuid NOT NULL,
	CONSTRAINT pk_transfer_custom_attribute PRIMARY KEY (id),
	CONSTRAINT unique_custom_attribute_transfer_id_key UNIQUE (transfer_id, attribute_key)
);


-- public.transfer_item definition

-- Drop table

-- DROP TABLE public.transfer_item;

CREATE TABLE public.transfer_item (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	transfer_id uuid NOT NULL,
	quantity_announced int4 NOT NULL,
	quantity_received int4 NOT NULL,
	quantity_stocked int4 NOT NULL,
	state public."transfer_item_state_enum" NOT NULL,
	product_id uuid NOT NULL,
	quantity_quarantined int4 NOT NULL,
	CONSTRAINT pk_transfer_item PRIMARY KEY (id)
);


-- public.transfer_item_custom_attribute definition

-- Drop table

-- DROP TABLE public.transfer_item_custom_attribute;

CREATE TABLE public.transfer_item_custom_attribute (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	attribute_key varchar NOT NULL,
	attribute_value varchar NOT NULL,
	transfer_item_id uuid NOT NULL,
	CONSTRAINT pk_transfer_item_custom_attribute PRIMARY KEY (id),
	CONSTRAINT unique_custom_attribute_transfer_item_id_key UNIQUE (transfer_item_id, attribute_key)
);


-- public.transfer_item_shipped_batch definition

-- Drop table

-- DROP TABLE public.transfer_item_shipped_batch;

CREATE TABLE public.transfer_item_shipped_batch (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	transfer_item_id uuid NULL,
	batch varchar NOT NULL,
	expiration_date timestamp NULL,
	quantity_announced int4 NOT NULL,
	quantity_received int4 NOT NULL,
	quantity_stocked int4 NOT NULL,
	quantity_quarantined int4 NOT NULL,
	CONSTRAINT ck_transfer_item_shipped_batch_quantity_announced_positive CHECK ((quantity_announced >= 0)),
	CONSTRAINT ck_transfer_item_shipped_batch_quantity_received_positive CHECK ((quantity_received >= 0)),
	CONSTRAINT ck_transfer_item_shipped_batch_quantity_stocked_positive CHECK ((quantity_stocked >= 0)),
	CONSTRAINT pk_transfer_item_shipped_batch PRIMARY KEY (id),
	CONSTRAINT unique_transfer_item_shipped_batch UNIQUE (transfer_item_id, batch)
);


-- public.transfer_shipment definition

-- Drop table

-- DROP TABLE public.transfer_shipment;

CREATE TABLE public.transfer_shipment (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	shipment_received_date timestamp NOT NULL,
	transfer_id uuid NOT NULL,
	forwarded_to_shop bool DEFAULT false NOT NULL,
	CONSTRAINT pk_transfer_shipment PRIMARY KEY (id)
);


-- public.transfer_shipment_item definition

-- Drop table

-- DROP TABLE public.transfer_shipment_item;

CREATE TABLE public.transfer_shipment_item (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	quantity_received int4 NOT NULL,
	quantity_stocked int4 NOT NULL,
	sku varchar NOT NULL,
	transfer_shipment_id uuid NOT NULL,
	transfer_item_id uuid NULL,
	quantity_quarantined int4 NOT NULL,
	CONSTRAINT pk_transfer_shipment_item PRIMARY KEY (id)
);
CREATE INDEX transfer_shipment_item_transfer_shipment_id_idx ON public.transfer_shipment_item USING btree (transfer_shipment_id);


-- public.transfer_shipment_item_batch definition

-- Drop table

-- DROP TABLE public.transfer_shipment_item_batch;

CREATE TABLE public.transfer_shipment_item_batch (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	batch varchar NULL,
	expiration_date varchar NULL,
	quantity_received int4 NOT NULL,
	quantity_stocked int4 NOT NULL,
	transfer_shipment_item_id uuid NOT NULL,
	quantity_quarantined int4 NOT NULL,
	CONSTRAINT pk_transfer_shipment_item_batch PRIMARY KEY (id)
);
CREATE INDEX transfer_shipment_item_batch_transfer_shipment_item_id_idx ON public.transfer_shipment_item_batch USING btree (transfer_shipment_item_id);


-- public.transfer_update_request definition

-- Drop table

-- DROP TABLE public.transfer_update_request;

CREATE TABLE public.transfer_update_request (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	state public."entity_update_request_status_enum" NOT NULL,
	body jsonb NOT NULL,
	created_by uuid NULL,
	transfer_id uuid NOT NULL,
	parent_id uuid NULL,
	CONSTRAINT pk_transfer_update_request PRIMARY KEY (id)
);
CREATE INDEX ix_transfer_update_request_state ON public.transfer_update_request USING btree (state);
CREATE INDEX ix_transfer_update_request_transfer_id ON public.transfer_update_request USING btree (transfer_id);


-- public."user" definition

-- Drop table

-- DROP TABLE public."user";

CREATE TABLE public."user" (
	id uuid NOT NULL,
	shop_id uuid NULL,
	first_name varchar NOT NULL,
	last_name varchar NOT NULL,
	phone varchar NOT NULL,
	email varchar NOT NULL,
	password_hash varchar NOT NULL,
	status varchar NOT NULL,
	password_reset_token varchar NULL,
	reset_token_expiry_date timestamp NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	"role" public."roles_enum" NULL,
	lp_id uuid NULL,
	CONSTRAINT pk_user PRIMARY KEY (id),
	CONSTRAINT uq_user_email UNIQUE (email)
);


-- public.warehouse_assignment_strategy definition

-- Drop table

-- DROP TABLE public.warehouse_assignment_strategy;

CREATE TABLE public.warehouse_assignment_strategy (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	strategy_type public."warehouse_assignment_strategy_type_enum" NOT NULL,
	"configuration" jsonb NULL,
	shop_id uuid NOT NULL,
	"name" varchar NOT NULL,
	description varchar NULL,
	CONSTRAINT pk_warehouse_assignment_strategy PRIMARY KEY (id),
	CONSTRAINT unique_shop_id_name UNIQUE (shop_id, name),
	CONSTRAINT whas_name_min_length CHECK ((length((name)::text) >= 1))
);


-- public.warehouse_assignment_strategy_history definition

-- Drop table

-- DROP TABLE public.warehouse_assignment_strategy_history;

CREATE TABLE public.warehouse_assignment_strategy_history (
	id uuid NOT NULL,
	creation_date timestamp NULL,
	updated_date timestamp NULL,
	warehouse_assignment_strategy_id uuid NOT NULL,
	strategy_type varchar NOT NULL,
	"configuration" jsonb NULL,
	shop_id uuid NOT NULL,
	"name" varchar NOT NULL,
	description varchar NULL,
	modification_reason varchar NULL,
	modified_by varchar NULL,
	CONSTRAINT pk_warehouse_assignment_strategy_history PRIMARY KEY (id)
);
CREATE INDEX whas_history_whas_id_idx ON public.warehouse_assignment_strategy_history USING btree (warehouse_assignment_strategy_id);


-- public.action_counter foreign keys

ALTER TABLE public.action_counter ADD CONSTRAINT fk_action_counter_user_id_user FOREIGN KEY (user_id) REFERENCES public."user"(id);


-- public.async_execution_config foreign keys

ALTER TABLE public.async_execution_config ADD CONSTRAINT fk_async_execution_config_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.auth_token foreign keys

ALTER TABLE public.auth_token ADD CONSTRAINT fk_auth_token_user_id_user FOREIGN KEY (user_id) REFERENCES public."user"(id);


-- public.blocked_module_log foreign keys

ALTER TABLE public.blocked_module_log ADD CONSTRAINT fk_blocked_module_log_order_id_order FOREIGN KEY (order_id) REFERENCES public."order"(id);
ALTER TABLE public.blocked_module_log ADD CONSTRAINT fk_blocked_module_log_pipeline_id_pipeline FOREIGN KEY (pipeline_id) REFERENCES public.pipeline(id);


-- public.cancellation foreign keys

ALTER TABLE public.cancellation ADD CONSTRAINT fk_cancellation_fulfillment_id_fulfillment FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id);


-- public.carrier foreign keys

ALTER TABLE public.carrier ADD CONSTRAINT fk_carrier_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.error_log foreign keys

ALTER TABLE public.error_log ADD CONSTRAINT fk_error_log_acknowledged_by_id_user FOREIGN KEY (acknowledged_by_id) REFERENCES public."user"(id);


-- public."event" foreign keys

ALTER TABLE public."event" ADD CONSTRAINT fk_event_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);
ALTER TABLE public."event" ADD CONSTRAINT fk_event_warehouse_id_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id);


-- public.feature_flag_history foreign keys

ALTER TABLE public.feature_flag_history ADD CONSTRAINT fk_feature_flag_history_exec_by_user_id_user FOREIGN KEY (exec_by_user_id) REFERENCES public."user"(id);
ALTER TABLE public.feature_flag_history ADD CONSTRAINT fk_feature_flag_history_shop_x_feature_flag_id_shop_x_f_e953 FOREIGN KEY (shop_x_feature_flag_id) REFERENCES public.shop_x_feature_flag(id);


-- public.fulfillment foreign keys

ALTER TABLE public.fulfillment ADD CONSTRAINT fk_fulfillment_billing_address_id_address FOREIGN KEY (billing_address_id) REFERENCES public.address(id);
ALTER TABLE public.fulfillment ADD CONSTRAINT fk_fulfillment_logistics_partner_id_warehouse_group FOREIGN KEY (logistics_partner_id) REFERENCES public.warehouse_group(id);
ALTER TABLE public.fulfillment ADD CONSTRAINT fk_fulfillment_order_id_order FOREIGN KEY (order_id) REFERENCES public."order"(id);
ALTER TABLE public.fulfillment ADD CONSTRAINT fk_fulfillment_shipping_address_id_address FOREIGN KEY (shipping_address_id) REFERENCES public.address(id);
ALTER TABLE public.fulfillment ADD CONSTRAINT fk_fulfillment_warehouse_id_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id);


-- public.fulfillment_item foreign keys

ALTER TABLE public.fulfillment_item ADD CONSTRAINT fk_fulfillment_item_fulfillment_id_fulfillment FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id);
ALTER TABLE public.fulfillment_item ADD CONSTRAINT fk_fulfillment_item_order_item_id_order_item FOREIGN KEY (order_item_id) REFERENCES public.order_item(id);


-- public.fulfillment_item_price foreign keys

ALTER TABLE public.fulfillment_item_price ADD CONSTRAINT fk_fulfillment_item_price_fulfillment_item_id_fulfillment_item FOREIGN KEY (fulfillment_item_id) REFERENCES public.fulfillment_item(id);
ALTER TABLE public.fulfillment_item_price ADD CONSTRAINT fk_fulfillment_item_price_order_item_price_id_order_item_price FOREIGN KEY (order_item_price_id) REFERENCES public.order_item_price(id);


-- public.fulfillment_update_request foreign keys

ALTER TABLE public.fulfillment_update_request ADD CONSTRAINT fk_fulfillment_update_request_fulfillment_id_fulfillment FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id);
ALTER TABLE public.fulfillment_update_request ADD CONSTRAINT fk_fulfillment_update_request_parent_id_fulfillment_upd_08df FOREIGN KEY (parent_id) REFERENCES public.fulfillment_update_request(id);


-- public.gdpr_request foreign keys

ALTER TABLE public.gdpr_request ADD CONSTRAINT fk_gdpr_request_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.maintenance_script_history foreign keys

ALTER TABLE public.maintenance_script_history ADD CONSTRAINT fk_maintenance_script_history_exec_by_user_id_user FOREIGN KEY (exec_by_user_id) REFERENCES public."user"(id);


-- public.notification foreign keys

ALTER TABLE public.notification ADD CONSTRAINT fk_notification_event_id_event FOREIGN KEY (event_id) REFERENCES public."event"(id);
ALTER TABLE public.notification ADD CONSTRAINT fk_notification_user_id_user FOREIGN KEY (user_id) REFERENCES public."user"(id);


-- public.notification_message foreign keys

ALTER TABLE public.notification_message ADD CONSTRAINT fk_notification_message_notification_type_id_notification_type FOREIGN KEY (notification_type_id) REFERENCES public.notification_type(id);
ALTER TABLE public.notification_message ADD CONSTRAINT fk_notification_message_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);
ALTER TABLE public.notification_message ADD CONSTRAINT fk_notification_message_warehouse_id_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id);


-- public."order" foreign keys

ALTER TABLE public."order" ADD CONSTRAINT fk_order_billing_address_id_address FOREIGN KEY (billing_address_id) REFERENCES public.address(id);
ALTER TABLE public."order" ADD CONSTRAINT fk_order_payment_method_id_payment_method FOREIGN KEY (payment_method_id) REFERENCES public.payment_method(id);
ALTER TABLE public."order" ADD CONSTRAINT fk_order_requested_warehouse_id_warehouse FOREIGN KEY (requested_warehouse_id) REFERENCES public.warehouse(id);
ALTER TABLE public."order" ADD CONSTRAINT fk_order_shipping_address_id_address FOREIGN KEY (shipping_address_id) REFERENCES public.address(id);
ALTER TABLE public."order" ADD CONSTRAINT fk_order_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);
ALTER TABLE public."order" ADD CONSTRAINT fk_order_shop_instance_id_shop_instance FOREIGN KEY (shop_instance_id) REFERENCES public.shop_instance(id);


-- public.order_attachment foreign keys

ALTER TABLE public.order_attachment ADD CONSTRAINT fk_order_attachment_order_id_order FOREIGN KEY (order_id) REFERENCES public."order"(id);


-- public.order_custom_attribute foreign keys

ALTER TABLE public.order_custom_attribute ADD CONSTRAINT fk_order_custom_attribute_order_id_order FOREIGN KEY (order_id) REFERENCES public."order"(id);


-- public.order_item foreign keys

ALTER TABLE public.order_item ADD CONSTRAINT fk_order_item_order_id_order FOREIGN KEY (order_id) REFERENCES public."order"(id);
ALTER TABLE public.order_item ADD CONSTRAINT fk_order_item_product_id_product FOREIGN KEY (product_id) REFERENCES public.product(id);


-- public.order_item_custom_attribute foreign keys

ALTER TABLE public.order_item_custom_attribute ADD CONSTRAINT fk_order_item_custom_attribute_order_item_id_order_item FOREIGN KEY (order_item_id) REFERENCES public.order_item(id) ON DELETE CASCADE;


-- public.order_item_price foreign keys

ALTER TABLE public.order_item_price ADD CONSTRAINT fk_order_item_price_order_item_id_order_item FOREIGN KEY (order_item_id) REFERENCES public.order_item(id);


-- public.otp foreign keys

ALTER TABLE public.otp ADD CONSTRAINT fk_otp_user_id_user FOREIGN KEY (user_id) REFERENCES public."user"(id);


-- public.parcel_event foreign keys

ALTER TABLE public.parcel_event ADD CONSTRAINT fk_parcel_event_shipment_id_shipment FOREIGN KEY (shipment_id) REFERENCES public.shipment(id);


-- public.payment_method foreign keys

ALTER TABLE public.payment_method ADD CONSTRAINT fk_payment_method_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.pipeline foreign keys

ALTER TABLE public.pipeline ADD CONSTRAINT fk_pipeline_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.pipeline_decision_config foreign keys

ALTER TABLE public.pipeline_decision_config ADD CONSTRAINT fk_pipeline_decision_config_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.pipeline_x_module foreign keys

ALTER TABLE public.pipeline_x_module ADD CONSTRAINT fk_pipeline_x_module_pipeline_id_pipeline FOREIGN KEY (pipeline_id) REFERENCES public.pipeline(id) ON DELETE CASCADE;


-- public.product foreign keys

ALTER TABLE public.product ADD CONSTRAINT fk_product_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.product_bundle foreign keys

ALTER TABLE public.product_bundle ADD CONSTRAINT fk_product_bundle_bundle_product_id_product FOREIGN KEY (bundle_product_id) REFERENCES public.product(id) ON DELETE CASCADE;
ALTER TABLE public.product_bundle ADD CONSTRAINT fk_product_bundle_product_id_product FOREIGN KEY (product_id) REFERENCES public.product(id);


-- public.product_custom_attribute foreign keys

ALTER TABLE public.product_custom_attribute ADD CONSTRAINT fk_product_custom_attribute_product_id_product FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


-- public.product_unit foreign keys

ALTER TABLE public.product_unit ADD CONSTRAINT fk_product_unit_base_unit_id_product_unit FOREIGN KEY (base_unit_id) REFERENCES public.product_unit(id);
ALTER TABLE public.product_unit ADD CONSTRAINT fk_product_unit_product_id_product FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


-- public.product_unit_barcode foreign keys

ALTER TABLE public.product_unit_barcode ADD CONSTRAINT fk_product_unit_barcode_product_unit_id_product_unit FOREIGN KEY (product_unit_id) REFERENCES public.product_unit(id) ON DELETE CASCADE;


-- public.report foreign keys

ALTER TABLE public.report ADD CONSTRAINT fk_report_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);
ALTER TABLE public.report ADD CONSTRAINT report_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


-- public."return" foreign keys

ALTER TABLE public."return" ADD CONSTRAINT fk_return_logistics_partner_id_warehouse_group FOREIGN KEY (logistics_partner_id) REFERENCES public.warehouse_group(id);
ALTER TABLE public."return" ADD CONSTRAINT fk_return_order_id_order FOREIGN KEY (order_id) REFERENCES public."order"(id);
ALTER TABLE public."return" ADD CONSTRAINT fk_return_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);
ALTER TABLE public."return" ADD CONSTRAINT fk_return_warehouse_id_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id);


-- public.return_custom_attribute foreign keys

ALTER TABLE public.return_custom_attribute ADD CONSTRAINT fk_return_custom_attribute_return_id_return FOREIGN KEY (return_id) REFERENCES public."return"(id);


-- public.return_customer_information foreign keys

ALTER TABLE public.return_customer_information ADD CONSTRAINT fk_return_customer_information_return_v2_id_return_v2 FOREIGN KEY (return_v2_id) REFERENCES public.return_v2(id) ON DELETE CASCADE;


-- public.return_item foreign keys

ALTER TABLE public.return_item ADD CONSTRAINT fk_return_item_product_id_product FOREIGN KEY (product_id) REFERENCES public.product(id);
ALTER TABLE public.return_item ADD CONSTRAINT fk_return_item_return_id_return FOREIGN KEY (return_id) REFERENCES public."return"(id);


-- public.return_item_batch foreign keys

ALTER TABLE public.return_item_batch ADD CONSTRAINT fk_return_item_batch_batch_id_batch FOREIGN KEY (batch_id) REFERENCES public.batch(id);
ALTER TABLE public.return_item_batch ADD CONSTRAINT fk_return_item_batch_return_item_id_return_item FOREIGN KEY (return_item_id) REFERENCES public.return_item(id);


-- public.return_item_v2 foreign keys

ALTER TABLE public.return_item_v2 ADD CONSTRAINT fk_return_item_v2_product_id_product FOREIGN KEY (product_id) REFERENCES public.product(id);
ALTER TABLE public.return_item_v2 ADD CONSTRAINT fk_return_item_v2_return_v2_id_return_v2 FOREIGN KEY (return_v2_id) REFERENCES public.return_v2(id) ON DELETE CASCADE;


-- public.return_item_v2_batch foreign keys

ALTER TABLE public.return_item_v2_batch ADD CONSTRAINT fk_return_item_v2_batch_return_item_v2_element_id_retur_aae2 FOREIGN KEY (return_item_v2_element_id) REFERENCES public.return_item_v2_element(id) ON DELETE CASCADE;


-- public.return_item_v2_element foreign keys

ALTER TABLE public.return_item_v2_element ADD CONSTRAINT fk_return_item_v2_element_return_item_v2_id_return_item_v2 FOREIGN KEY (return_item_v2_id) REFERENCES public.return_item_v2(id) ON DELETE CASCADE;
ALTER TABLE public.return_item_v2_element ADD CONSTRAINT fk_return_item_v2_element_return_parcel_id_return_v2_parcel FOREIGN KEY (return_parcel_id) REFERENCES public.return_v2_parcel(id) ON DELETE CASCADE;
ALTER TABLE public.return_item_v2_element ADD CONSTRAINT fk_return_item_v2_element_return_shipment_id_return_v2_shipment FOREIGN KEY (return_shipment_id) REFERENCES public.return_v2_shipment(id);


-- public.return_v2 foreign keys

ALTER TABLE public.return_v2 ADD CONSTRAINT fk_return_v2_id_order FOREIGN KEY (order_id) REFERENCES public."order"(id);
ALTER TABLE public.return_v2 ADD CONSTRAINT fk_return_v2_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);
ALTER TABLE public.return_v2 ADD CONSTRAINT fk_return_v2_id_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id);
ALTER TABLE public.return_v2 ADD CONSTRAINT fk_return_v2_id_warehouse_group FOREIGN KEY (logistics_partner_id) REFERENCES public.warehouse_group(id);


-- public.return_v2_parcel foreign keys

ALTER TABLE public.return_v2_parcel ADD CONSTRAINT fk_return_v2_parcel_return_v2_id_return_v2 FOREIGN KEY (return_v2_id) REFERENCES public.return_v2(id) ON DELETE CASCADE;


-- public.return_v2_shipment foreign keys

ALTER TABLE public.return_v2_shipment ADD CONSTRAINT fk_return_v2_shipment_return_v2_id_return_v2 FOREIGN KEY (return_v2_id) REFERENCES public.return_v2(id) ON DELETE CASCADE;
ALTER TABLE public.return_v2_shipment ADD CONSTRAINT fk_return_v2_shipment_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);
ALTER TABLE public.return_v2_shipment ADD CONSTRAINT fk_return_v2_shipment_warehouse_id_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id);


-- public.shipment foreign keys

ALTER TABLE public.shipment ADD CONSTRAINT fk_shipment_carrier_id_carrier FOREIGN KEY (carrier_id) REFERENCES public.carrier(id);
ALTER TABLE public.shipment ADD CONSTRAINT fk_shipment_fulfillment_id_fulfillment FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id);
ALTER TABLE public.shipment ADD CONSTRAINT fk_shipment_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.shipment_custom_attribute foreign keys

ALTER TABLE public.shipment_custom_attribute ADD CONSTRAINT fk_shipment_custom_attribute_shipment_id_shipment FOREIGN KEY (shipment_id) REFERENCES public.shipment(id) ON DELETE CASCADE;


-- public.shipment_event foreign keys

ALTER TABLE public.shipment_event ADD CONSTRAINT fk_shipment_event_shipment_id_shipment FOREIGN KEY (shipment_id) REFERENCES public.shipment(id);


-- public.shipment_item foreign keys

ALTER TABLE public.shipment_item ADD CONSTRAINT fk_shipment_item_fulfillment_item_id_fulfillment_item FOREIGN KEY (fulfillment_item_id) REFERENCES public.fulfillment_item(id);
ALTER TABLE public.shipment_item ADD CONSTRAINT fk_shipment_item_shipment_id_shipment FOREIGN KEY (shipment_id) REFERENCES public.shipment(id);


-- public.shipment_option foreign keys

ALTER TABLE public.shipment_option ADD CONSTRAINT fk_shipment_option_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.shipment_option_alias foreign keys

ALTER TABLE public.shipment_option_alias ADD CONSTRAINT fk_shipment_option_alias_shipment_option_id_shipment_option FOREIGN KEY (shipment_option_id) REFERENCES public.shipment_option(id);
ALTER TABLE public.shipment_option_alias ADD CONSTRAINT fk_shipment_option_alias_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.shipment_option_rule foreign keys

ALTER TABLE public.shipment_option_rule ADD CONSTRAINT fk_shipment_option_rule_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.shipment_option_x_carrier foreign keys

ALTER TABLE public.shipment_option_x_carrier ADD CONSTRAINT fk_shipment_option_x_carrier_carrier_id_carrier FOREIGN KEY (carrier_id) REFERENCES public.carrier(id);
ALTER TABLE public.shipment_option_x_carrier ADD CONSTRAINT fk_shipment_option_x_carrier_shipment_option_id_shipment_option FOREIGN KEY (shipment_option_id) REFERENCES public.shipment_option(id);


-- public.shipment_option_x_order_item foreign keys

ALTER TABLE public.shipment_option_x_order_item ADD CONSTRAINT fk_shipment_option_x_order_item_order_item_id_order_item FOREIGN KEY (order_item_id) REFERENCES public.order_item(id);
ALTER TABLE public.shipment_option_x_order_item ADD CONSTRAINT fk_shipment_option_x_order_item_shipment_option_id_ship_49a3 FOREIGN KEY (shipment_option_id) REFERENCES public.shipment_option(id);


-- public.shipment_option_x_shop_x_warehouse foreign keys

ALTER TABLE public.shipment_option_x_shop_x_warehouse ADD CONSTRAINT fk_shipment_option_x_shop_x_warehouse_shipment_option_i_356a FOREIGN KEY (shipment_option_id) REFERENCES public.shipment_option(id);
ALTER TABLE public.shipment_option_x_shop_x_warehouse ADD CONSTRAINT fk_shipment_option_x_shop_x_warehouse_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);
ALTER TABLE public.shipment_option_x_shop_x_warehouse ADD CONSTRAINT fk_shipment_option_x_shop_x_warehouse_warehouse_id_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id) ON DELETE RESTRICT;


-- public.shipment_parcel foreign keys

ALTER TABLE public.shipment_parcel ADD CONSTRAINT fk_shipment_parcel_shipment_id_shipment FOREIGN KEY (shipment_id) REFERENCES public.shipment(id);


-- public.shipped_batch foreign keys

ALTER TABLE public.shipped_batch ADD CONSTRAINT fk_shipped_batch_shipment_item_id_shipment_item FOREIGN KEY (shipment_item_id) REFERENCES public.shipment_item(id);


-- public.shipping_price foreign keys

ALTER TABLE public.shipping_price ADD CONSTRAINT fk_shipping_price_order_id_order FOREIGN KEY (order_id) REFERENCES public."order"(id);


-- public.shop foreign keys

ALTER TABLE public.shop ADD CONSTRAINT fk_shop_default_shipment_option_id_shipment_option FOREIGN KEY (default_shipment_option_id) REFERENCES public.shipment_option(id);
ALTER TABLE public.shop ADD CONSTRAINT fk_shop_shop_group_id_shop_group FOREIGN KEY (shop_group_id) REFERENCES public.shop_group(id);


-- public.shop_instance foreign keys

ALTER TABLE public.shop_instance ADD CONSTRAINT fk_shop_instance_shipment_option_rule_id_shipment_option_rule FOREIGN KEY (shipment_option_rule_id) REFERENCES public.shipment_option_rule(id);
ALTER TABLE public.shop_instance ADD CONSTRAINT fk_shop_instance_shop_connector_id_shop_connector FOREIGN KEY (shop_connector_id) REFERENCES public.shop_connector(id);
ALTER TABLE public.shop_instance ADD CONSTRAINT fk_shop_instance_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);
ALTER TABLE public.shop_instance ADD CONSTRAINT fk_shop_instance_warehouse_assignment_strategy_id_wareh_7b46 FOREIGN KEY (warehouse_assignment_strategy_id) REFERENCES public.warehouse_assignment_strategy(id);


-- public.shop_instance_webhooks_subscription foreign keys

ALTER TABLE public.shop_instance_webhooks_subscription ADD CONSTRAINT fk_shop_instance_webhooks_subscription_shop_instance_id_12a3 FOREIGN KEY (shop_instance_id) REFERENCES public.shop_instance(id);


-- public.shop_x_feature_flag foreign keys

ALTER TABLE public.shop_x_feature_flag ADD CONSTRAINT fk_shop_x_feature_flag_feature_flag_id_feature_flag FOREIGN KEY (feature_flag_id) REFERENCES public.feature_flag(id);
ALTER TABLE public.shop_x_feature_flag ADD CONSTRAINT fk_shop_x_feature_flag_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);
ALTER TABLE public.shop_x_feature_flag ADD CONSTRAINT fk_shop_x_feature_flag_shop_instance_id_shop_instance FOREIGN KEY (shop_instance_id) REFERENCES public.shop_instance(id);
ALTER TABLE public.shop_x_feature_flag ADD CONSTRAINT fk_shop_x_feature_flag_warehouse_id_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id);


-- public.shop_x_payment_method foreign keys

ALTER TABLE public.shop_x_payment_method ADD CONSTRAINT fk_shop_x_payment_method_payment_method_id_payment_method FOREIGN KEY (payment_method_id) REFERENCES public.payment_method(id);
ALTER TABLE public.shop_x_payment_method ADD CONSTRAINT fk_shop_x_payment_method_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.shop_x_warehouse foreign keys

ALTER TABLE public.shop_x_warehouse ADD CONSTRAINT fk_shop_x_warehouse_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);
ALTER TABLE public.shop_x_warehouse ADD CONSTRAINT fk_shop_x_warehouse_warehouse_id_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id) ON DELETE RESTRICT;


-- public.stock foreign keys

ALTER TABLE public.stock ADD CONSTRAINT fk_stock_batch_id_batch FOREIGN KEY (batch_id) REFERENCES public.batch(id);
ALTER TABLE public.stock ADD CONSTRAINT fk_stock_product_id_product FOREIGN KEY (product_id) REFERENCES public.product(id);
ALTER TABLE public.stock ADD CONSTRAINT fk_stock_warehouse_id_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id);


-- public.stock_alert foreign keys

ALTER TABLE public.stock_alert ADD CONSTRAINT fk_stock_alert_product_id_product FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;
ALTER TABLE public.stock_alert ADD CONSTRAINT fk_stock_alert_warehouse_id_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id) ON DELETE CASCADE;


-- public.stock_allocation foreign keys

ALTER TABLE public.stock_allocation ADD CONSTRAINT fk_stock_allocation_stock_id_stock FOREIGN KEY (stock_id) REFERENCES public.stock(id);


-- public.stock_quantity foreign keys

ALTER TABLE public.stock_quantity ADD CONSTRAINT fk_stock_quantity_stock_id_stock FOREIGN KEY (stock_id) REFERENCES public.stock(id);


-- public.stock_reservation_update foreign keys

ALTER TABLE public.stock_reservation_update ADD CONSTRAINT fk_stock_reservation_update_fulfillment_item_id_fulfill_f73d FOREIGN KEY (fulfillment_item_id) REFERENCES public.fulfillment_item(id);
ALTER TABLE public.stock_reservation_update ADD CONSTRAINT fk_stock_reservation_update_stock_id_stock FOREIGN KEY (stock_id) REFERENCES public.stock(id);


-- public.stock_sequence foreign keys

ALTER TABLE public.stock_sequence ADD CONSTRAINT fk_stock_sequence_stock_id_stock FOREIGN KEY (stock_id) REFERENCES public.stock(id) ON DELETE CASCADE;


-- public.stock_update foreign keys

ALTER TABLE public.stock_update ADD CONSTRAINT fk_stock_update_internal_sequence_identifier_bulk_stock_update FOREIGN KEY (internal_sequence_identifier) REFERENCES public.bulk_stock_update(internal_sequence_identifier);
ALTER TABLE public.stock_update ADD CONSTRAINT fk_stock_update_product_id_product FOREIGN KEY (product_id) REFERENCES public.product(id);
ALTER TABLE public.stock_update ADD CONSTRAINT fk_stock_update_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);
ALTER TABLE public.stock_update ADD CONSTRAINT fk_stock_update_stock_id_stock FOREIGN KEY (stock_id) REFERENCES public.stock(id);
ALTER TABLE public.stock_update ADD CONSTRAINT fk_stock_update_warehouse_id_warehouse FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id);


-- public.stock_update_rollup foreign keys

ALTER TABLE public.stock_update_rollup ADD CONSTRAINT fk_stock_update_rollup_stock_id_stock FOREIGN KEY (stock_id) REFERENCES public.stock(id);


-- public.transfer foreign keys

ALTER TABLE public.transfer ADD CONSTRAINT fk_transfer_destination_warehouse FOREIGN KEY (destination) REFERENCES public.warehouse(id);
ALTER TABLE public.transfer ADD CONSTRAINT fk_transfer_logistics_partner_id_warehouse_group FOREIGN KEY (logistics_partner_id) REFERENCES public.warehouse_group(id);
ALTER TABLE public.transfer ADD CONSTRAINT fk_transfer_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.transfer_custom_attribute foreign keys

ALTER TABLE public.transfer_custom_attribute ADD CONSTRAINT fk_transfer_custom_attribute_transfer_id_transfer FOREIGN KEY (transfer_id) REFERENCES public.transfer(id);


-- public.transfer_item foreign keys

ALTER TABLE public.transfer_item ADD CONSTRAINT fk_transfer_item_product_id_product FOREIGN KEY (product_id) REFERENCES public.product(id);
ALTER TABLE public.transfer_item ADD CONSTRAINT fk_transfer_item_transfer_id_transfer FOREIGN KEY (transfer_id) REFERENCES public.transfer(id);


-- public.transfer_item_custom_attribute foreign keys

ALTER TABLE public.transfer_item_custom_attribute ADD CONSTRAINT fk_transfer_item_custom_attribute_transfer_item_id_tran_6e6f FOREIGN KEY (transfer_item_id) REFERENCES public.transfer_item(id);


-- public.transfer_item_shipped_batch foreign keys

ALTER TABLE public.transfer_item_shipped_batch ADD CONSTRAINT fk_transfer_item_shipped_batch_transfer_item_id_transfer_item FOREIGN KEY (transfer_item_id) REFERENCES public.transfer_item(id);


-- public.transfer_shipment foreign keys

ALTER TABLE public.transfer_shipment ADD CONSTRAINT fk_transfer_shipment_transfer_id_transfer FOREIGN KEY (transfer_id) REFERENCES public.transfer(id);


-- public.transfer_shipment_item foreign keys

ALTER TABLE public.transfer_shipment_item ADD CONSTRAINT fk_transfer_shipment_item_transfer_item_id_transfer_item FOREIGN KEY (transfer_item_id) REFERENCES public.transfer_item(id);
ALTER TABLE public.transfer_shipment_item ADD CONSTRAINT fk_transfer_shipment_item_transfer_shipment_id_transfer_890c FOREIGN KEY (transfer_shipment_id) REFERENCES public.transfer_shipment(id);


-- public.transfer_shipment_item_batch foreign keys

ALTER TABLE public.transfer_shipment_item_batch ADD CONSTRAINT fk_transfer_shipment_item_batch_transfer_shipment_item__baed FOREIGN KEY (transfer_shipment_item_id) REFERENCES public.transfer_shipment_item(id);


-- public.transfer_update_request foreign keys

ALTER TABLE public.transfer_update_request ADD CONSTRAINT fk_transfer_update_request_parent_id_transfer_update_request FOREIGN KEY (parent_id) REFERENCES public.transfer_update_request(id);
ALTER TABLE public.transfer_update_request ADD CONSTRAINT fk_transfer_update_request_transfer_id_transfer FOREIGN KEY (transfer_id) REFERENCES public.transfer(id);


-- public."user" foreign keys

ALTER TABLE public."user" ADD CONSTRAINT fk_user_lp_id_warehouse_group FOREIGN KEY (lp_id) REFERENCES public.warehouse_group(id);
ALTER TABLE public."user" ADD CONSTRAINT fk_user_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.warehouse_assignment_strategy foreign keys

ALTER TABLE public.warehouse_assignment_strategy ADD CONSTRAINT fk_warehouse_assignment_strategy_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);


-- public.warehouse_assignment_strategy_history foreign keys

ALTER TABLE public.warehouse_assignment_strategy_history ADD CONSTRAINT fk_warehouse_assignment_strategy_history_shop_id_shop FOREIGN KEY (shop_id) REFERENCES public.shop(id);
ALTER TABLE public.warehouse_assignment_strategy_history ADD CONSTRAINT fk_whas_history_whas_id_whas FOREIGN KEY (warehouse_assignment_strategy_id) REFERENCES public.warehouse_assignment_strategy(id);