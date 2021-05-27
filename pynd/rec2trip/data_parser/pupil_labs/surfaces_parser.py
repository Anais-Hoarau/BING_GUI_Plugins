import logging as log
from typing import List, Tuple, Any, Dict
import json
from collections import defaultdict

from pynd import MetaVariableBaseType
from rec2trip.data_parser import DataParser
from rec2trip.timestamper import TimestampTS
from rec2trip.ttm import DataTableManipulator


class SurfacesParser(DataParser):

    def __init__(self, component: str, output: str):
        DataParser.__init__(self, component, output, TimestampTS())
        # Key is the name of the surface we import
        self._data: Dict[str, List[Tuple[float, Any]]] = defaultdict(list)

    def start_parse(self) -> None:
        pass

    def parse_data(self, data: str, ts: float) -> None:
        j = json.loads(data)
        surf_name = j["name"]
        for g in j["gaze_on_srf"]:
            timecode = g["timestamp"]
            if abs(timecode - ts) > 1:
                log.warning(f"SurfacesParser (@{ts}) has a too big timedelta between RTMaps and Pupil clocks")
                return
            pos = tuple(g["norm_pos"])
            on_srf = g["on_srf"]
            confidence = g["confidence"]
            topics = g["topic"].split(".")
            if len(topics) != 4:
                log.warning(f"SurfacesParser (@{ts}) can't handle a topic without 4 elements")
                return
            eyes_01 = topics[2]
            # Eyes data is represented as a string containing 0 and 1 for left and right eyes
            eyes = ('0' in eyes_01, '1' in eyes_01)
            self._data[surf_name].append((timecode, [pos[0], pos[1], eyes[0], eyes[1], confidence, on_srf]))

    def end_parse(self) -> None:
        for surf_name, surf_data in self._data.items():
            ttm = DataTableManipulator(self._trip)
            table_name = f"pupil_surface_{surf_name}"
            ttm.create_table(table_name)

            meta_vars = [
                ttm.create_meta_variable("pos_x", MetaVariableBaseType.REAL, "[0..1]", "Gaze X coordinate on surface"),
                ttm.create_meta_variable("pos_y", MetaVariableBaseType.REAL, "[0..1]", "Gaze Y coordinate on surface"),
                ttm.create_meta_variable("eye_left", MetaVariableBaseType.REAL, "bool", "Whether the left eye was used to generate this data"),
                ttm.create_meta_variable("eye_right", MetaVariableBaseType.REAL, "bool", "Whether the right eye was used to generate this data"),
                ttm.create_meta_variable("confidence", MetaVariableBaseType.REAL, "[0..1]", "Confidence in gaze position"),
                ttm.create_meta_variable("on_srf", MetaVariableBaseType.REAL, "bool", "Whether gaze was on surface or not"),
            ]

            timecode, data = zip(*surf_data)
            for meta_var, datum in zip(meta_vars, zip(*data)):
                ttm.add_variable(meta_var)
                ttm.set_batch_of_variable_pairs(meta_var.get_name(), timecode, datum)
