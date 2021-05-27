from abc import ABC, abstractmethod
import logging as log
from typing import Tuple

from pynd import SQLiteTrip
from rec2trip.timestamper import Timestamper


class DataParser(ABC):

    def __init__(self, component: str, output: str, timestamper: Timestamper):
        self._component: str = component
        self._output: str = output
        self._trip: SQLiteTrip = None
        self._last_idx: int = None
        # Rec file path, needed to extract path to external data files
        self._rec_file: str = None
        self._timestamper: Timestamper = timestamper

    def uuid(self) -> Tuple[str, str]:
        return self._component, self._output

    def check_idx(self, idx: int) -> None:
        """
        Checks that the given data index matches the previous received index
        :param idx: Currently parsed data index
        :return:
        """
        # TODO Either make a custom logging format, or raise Exceptions
        if self._last_idx is None:
            if idx != 0:
                log.error(f"{self._component}.{self._output}: First parsed index is {idx}, expected 0")
        elif self._last_idx + 1 != idx:
            log.error(f"{self._component}.{self._output}: Parsed index is {idx}, expected {self._last_idx + 1}")
        self._last_idx = idx

    def set_trip(self, trip: SQLiteTrip) -> None:
        self._trip = trip

    def set_rec_file(self, rec_file: str) -> None:
        self._rec_file = rec_file

    def parse_line_common(self, time_of_issue: float, idx: int, data: str, timestamp: float=None) -> None:
        self.check_idx(idx)
        ts = self._timestamper.timestamp(time_of_issue, idx, data, timestamp)
        self.parse_data(data, ts)

    @abstractmethod
    def start_parse(self) -> None:
        pass

    @abstractmethod
    def parse_data(self, data: str, ts: float) -> None:
        pass

    @abstractmethod
    def end_parse(self) -> None:
        pass
