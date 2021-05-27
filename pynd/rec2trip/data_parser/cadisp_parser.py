import json
import logging as log
from typing import List, Tuple, Any

from pynd import MetaVariableBaseType
from rec2trip.data_parser import DataParser
from rec2trip.timestamper import Timestamper
from rec2trip.ttm import EventTableManipulator


class CADispParser(DataParser):
    """
    Data parser for recording entries that contain a single unit of datum that can be converted to a basic trip type
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper, table_name: str=None):
        """

        :param component: Name of the RTMaps component that generated this data
        :param output: Name of the output of the RTMaps component that generated this data
        :param timestamper: Whether to use timestamp as timecode or time of issue or resample with sample rate
        :param table_name: Name of the trip table that the data will be inserted into. Defaults to component
        """
        DataParser.__init__(self, component, output, timestamper)
        self._ttm: EventTableManipulator = None
        self._table_name = table_name or self._component
        self._entries: List[Tuple[str, MetaVariableBaseType]] = []
        self._data: List[Tuple[float, List[Any]]] = []

    def start_parse(self) -> None:
        pass

    def parse_data(self, data: str, ts: float) -> None:
        data_json = json.loads(data)
        # pynd dislikes Nones, replace it with NaNs
        # TODO Let pynd accept None so we are not obliged to use NaN for missing data...
        for k, v in data_json.items():
            if v is None:
                data_json[k] = float('nan')
        # TODO What if json contains lists or dicts?
        if not self._entries:
            self._entries = [(k, MetaVariableBaseType.REAL if type(v) != str else MetaVariableBaseType.TEXT)
                             for k, v in data_json.items()]
        self._data.append((ts, data_json.values()))

    def end_parse(self) -> None:
        self._ttm = EventTableManipulator(self._trip)
        self._ttm.create_table(self._table_name)
        if not self._data:
            log.warning(f"No data to load for {self._component}.{self._output}")
            return

        for var_name, var_type in self._entries:
            meta_var = self._ttm.create_meta_variable(var_name, var_type, comment="Imported from rec file")
            self._ttm.add_variable(meta_var)

        timecode, data = zip(*self._data)
        for i, datum in enumerate(zip(*data)):
            datum_name = self._entries[i][0]
            self._ttm.set_batch_of_variable_pairs(datum_name, timecode, datum)
