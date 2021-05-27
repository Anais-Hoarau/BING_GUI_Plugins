import logging as log
from typing import List, Tuple, Any, Type
from abc import abstractmethod

from pynd import MetaVariableBaseType
from rec2trip.data_parser import DataParser
from rec2trip.timestamper import Timestamper
from rec2trip.ttm import TripTableManipulator, DataTableManipulator


class UniqueDataParser(DataParser):
    """
    Data parser for recording entries that contain a single unit of datum that can be converted to a basic trip type
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper, unit: str=None, comment: str=None,
                 table_name: str=None, column_name: str=None,
                 ttm_type: Type[TripTableManipulator]=DataTableManipulator):
        """

        :param component: Name of the RTMaps component that generated this data
        :param output: Name of the output of the RTMaps component that generated this data
        :param timestamper: Whether to use timestamp as timecode or time of issue or resample with sample rate
        :param unit:
        :param comment:
        :param table_name: Name of the trip table that the data will be inserted into. Defaults to component
        :param column_name: Name of the trip column that the data will be inserted into. Defaults to output
        """
        DataParser.__init__(self, component, output, timestamper)
        self._ttm: TripTableManipulator = None
        self._ttm_type: Type[TripTableManipulator] = ttm_type
        self._unit = unit or ''
        self._comment = comment or 'Imported from rec file'
        self._table_name = table_name or self._component
        self._column_name = column_name or self._output
        self._data: List[Tuple[float, Any]] = []

    def start_parse(self) -> None:
        self._ttm = self._ttm_type(self._trip)
        self._ttm.create_table(self._table_name)
        meta_var = self._ttm.create_meta_variable(self._column_name, self._trip_type(), self._unit, self._comment)
        self._ttm.add_variable(meta_var)

    def parse_data(self, data: str, ts: float) -> None:
        self._data.append((ts, self._convert_to_trip_type(data)))

    def end_parse(self) -> None:
        if not self._data:
            log.warning(f"No data to load for {self._component}.{self._output}")
            return
        timecode, datum = zip(*self._data)
        self._ttm.set_batch_of_variable_pairs(self._column_name, timecode, datum)

    @abstractmethod
    def _trip_type(self) -> MetaVariableBaseType:
        pass

    @abstractmethod
    def _convert_to_trip_type(self, data) -> Any:
        pass
