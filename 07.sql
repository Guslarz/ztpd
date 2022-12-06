-- 1
--- A
CREATE TABLE a6_lrs
(
    geom SDO_GEOMETRY
);

--- B
INSERT INTO a6_lrs
SELECT sar.geom
FROM streets_and_railroads sar,
     major_cities mc
where SDO_WITHIN_DISTANCE(sar.geom, mc.geom, 'distance=10 unit=km') = 'TRUE'
  and mc.city_name = 'Koszalin';

--- C
select SDO_GEOM.SDO_LENGTH(geom, 1, 'unit=km') distance,
       ST_LINESTRING(geom).ST_NUMPOINTS()      st_numpoints
from a6_lrs;

--- D
update a6_lrs
set geom = SDO_LRS.CONVERT_TO_LRS_GEOM(GEOM, 0, 276.6813);

--- E
INSERT INTO user_sdo_geom_metadata
VALUES ('A6_LRS',
        'GEOM',
        MDSYS.SDO_DIM_ARRAY(
                MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
                MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1),
                MDSYS.SDO_DIM_ELEMENT('M', 0, 300, 1)
            ),
        8307);

--- F
CREATE INDEX a6_lrs_idx
    ON a6_lrs (geom)
    INDEXTYPE IS MDSYS.SPATIAL_INDEX;


-- 2
--- A
SELECT SDO_LRS.VALID_MEASURE(geom, 500) valid_500
FROM a6_lrs;

--- B
select SDO_LRS.GEOM_SEGMENT_END_PT(GEOM).GET_WKT() END_PT
from A6_LRS;

--- C
select SDO_LRS.LOCATE_PT(GEOM, 150, 0).Get_WKT() KM150
from A6_LRS;

--- D
select SDO_LRS.CLIP_GEOM_SEGMENT(GEOM, 120, 160).Get_WKT() CLIPPED
from A6_LRS;

--- E
select SDO_LRS.GET_NEXT_SHAPE_PT(a.geom, C.GEOM).Get_WKT() WJAZD_NA_A6
from A6_LRS a,
     MAJOR_CITIES C
where C.CITY_NAME = 'Slupsk';

--- F
select SDO_LRS.OFFSET_GEOM_SEGMENT(A6.GEOM, M.DIMINFO, 50, 200, 50,
                                   'unit=m arc_tolerance=0.05') KOSZT
from A6_LRS A6,
     USER_SDO_GEOM_METADATA M
where M.TABLE_NAME = 'A6_LRS'
  and M.COLUMN_NAME = 'GEOM';
