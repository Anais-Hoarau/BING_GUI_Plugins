import logging as log
from typing import List, Tuple, Any

from pynd import MetaVariableBaseType
from rec2trip.data_parser import DataParser
from rec2trip.timestamper import Timestamper
from rec2trip.ttm import DataTableManipulator


class VectorParserEntry:
    """
    This class holds information about a vector element
    """

    def __init__(self, data_name: str, unit: str=None, comment: str=None, do_import: bool=True):
        self.data_name: str = data_name
        self.unit: str = unit
        self.comment: str = comment
        self.do_import: bool = do_import


class VectorParser(DataParser):
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
        self._table_name = table_name or self._component
        self._data: List[Tuple[float, List[Any]]] = []
        self._entries: List[VectorParserEntry] = []
        self._ttm: DataTableManipulator = None

    def add_vector_entry(self, meta_data: VectorParserEntry) -> None:
        self._entries.append(meta_data)

    def start_parse(self) -> None:
        self._ttm = DataTableManipulator(self._trip)
        self._ttm.create_table(self._table_name)

        for entry in self._entries:
            if not entry.do_import:
                continue
            meta_var = self._ttm.create_meta_variable(entry.data_name,
                                                      MetaVariableBaseType.REAL,
                                                      entry.unit,
                                                      entry.comment)
            self._ttm.add_variable(meta_var)

    def parse_data(self, data: str, ts: float) -> None:
        data_list = data.split("\t")
        if len(data_list) != len(self._entries):
            log.warning(f"Different number of vector entries and read values for {self._component}.{self._output}, "
                        f"ignoring line")
            return
        self._data.append((ts, [float(x) for x in data_list]))

    def end_parse(self) -> None:
        if not self._data:
            log.warning(f"No data to load for {self._component}.{self._output}")
            return
        timecode, data = zip(*self._data)
        for i, datum in enumerate(zip(*data)):
            if not self._entries[i].do_import:
                continue
            data_name = self._entries[i].data_name
            self._ttm.set_batch_of_variable_pairs(data_name, timecode, datum)
