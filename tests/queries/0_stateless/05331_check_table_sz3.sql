-- Tags: no-fasttest, no-random-settings
-- no-fasttest: needs sz3 library
-- no-random-settings: SZ3 requires compression block sizes aligned to the Float32 width

SET enable_sz3_codec = 1;

CREATE TABLE t_check_sz3_wide (x Float32 CODEC(SZ3)) ENGINE = MergeTree ORDER BY tuple()
    SETTINGS min_bytes_for_wide_part = 0, min_rows_for_wide_part = 0;
CREATE TABLE t_check_sz3_compact (x Float32 CODEC(SZ3)) ENGINE = MergeTree ORDER BY tuple()
    SETTINGS min_bytes_for_wide_part = 1000000000, min_rows_for_wide_part = 1000000000;
CREATE TABLE t_check_zstd_wide (x Float32 CODEC(ZSTD)) ENGINE = MergeTree ORDER BY tuple()
    SETTINGS min_bytes_for_wide_part = 0, min_rows_for_wide_part = 0;

INSERT INTO t_check_sz3_wide SELECT number / 7 FROM numbers(100000);
INSERT INTO t_check_sz3_compact SELECT number / 7 FROM numbers(100000);
INSERT INTO t_check_zstd_wide SELECT number / 7 FROM numbers(100000);

SELECT table, part_type
FROM system.parts
WHERE database = currentDatabase()
    AND table IN ('t_check_sz3_wide', 't_check_sz3_compact', 't_check_zstd_wide')
    AND active
ORDER BY table;

CHECK TABLE t_check_sz3_wide SETTINGS check_query_single_value_result = 1;
CHECK TABLE t_check_sz3_compact SETTINGS check_query_single_value_result = 1;
CHECK TABLE t_check_zstd_wide SETTINGS check_query_single_value_result = 1;

DROP TABLE t_check_sz3_wide;
DROP TABLE t_check_sz3_compact;
DROP TABLE t_check_zstd_wide;
