import os
import logging as log
from typing import Dict, List, Tuple, Any

from pynd import MetaVariableBaseType
from rec2trip.data_parser import DataParser
from rec2trip.timestamper import Timestamper
from rec2trip.ttm import EventTableManipulator


class AdeunisParser(DataParser):
    """
    Event parser for recording entries from the Adeunis radio buttons
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper, table_name: str=None,
                 column_name: str=None):
        """

        :param component: Name of the RTMaps component that generated this data
        :param output: Name of the output of the RTMaps component that generated this data
        :param timestamper: Whether to use timestamp as timecode or time of issue or resample with sample rate
        :param table_name: Name of the trip table that the data will be inserted into. Defaults to component
        :param column_name: Name of the trip column that the data will be inserted into. Defaults to output
        """
        DataParser.__init__(self, component, output, timestamper)
        self._ttm: EventTableManipulator = None
        self._table_name = table_name or self._component
        self._column_name = column_name or self._output
        self._data: List[Tuple[float, List[Any]]] = []
        self._inf_file: str = ''
        self._inf_file_content: Dict[int:List[int]] = {}

    def start_parse(self) -> None:
        self._parse_inf_file()

    def parse_data(self, data: str, ts: float) -> None:
        try:
            key = int(ts * 1e6)
            self._data.append((ts, self._inf_file_content[key][0]))
        except KeyError:
            log.warning(f"Key {key} not found for {self._component}.{self._output}")

    def end_parse(self) -> None:
        self._ttm = EventTableManipulator(self._trip)
        self._ttm.create_table(self._table_name)
        if not self._data:
            log.warning(f"No data to load for {self._component}.{self._output}")
            return

        meta_var = self._ttm.create_meta_variable(self._column_name, MetaVariableBaseType.REAL,
                                                  comment="Imported from rec file")
        self._ttm.add_variable(meta_var)

        timecode, datum = zip(*self._data)
        self._ttm.set_batch_of_variable_pairs(self._column_name, timecode, datum)

    def _parse_inf_file(self):
        # Build *.inf file name
        root, file = os.path.split(self._rec_file)
        filename, ext = os.path.splitext(file)
        self._inf_file = os.path.join(root, f"{filename}_{self._component}_{self._output}.inf")

        if os.path.isfile(self._inf_file):
            log.info(f"Starting to parse *.inf file for {self._component}.{self._output}...")
            with open(self._inf_file) as inf:
                for line in inf:
                    # Skip the first line with column names
                    if "Buton_ID" in line:
                        continue
                    line = line.strip()
                    buffer = [int(k) for k in line.split('\t')]
                    if buffer[0] in self._inf_file_content.keys():
                        self._inf_file_content[buffer[0]] += buffer[1:]
                    else:
                        self._inf_file_content[buffer[0]] = buffer[1:]
            log.info(f"Finished parsing *.inf file for {self._component}.{self._output}...")
        else:
            log.warning(f"File not found for {self._component}.{self._output}")
