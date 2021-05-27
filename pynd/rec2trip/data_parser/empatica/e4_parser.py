import re
import logging as log
from typing import List

from rec2trip.data_parser import DataParser
from rec2trip.timestamper import Timestamper
from .e4_entry import E4Entry, E4SingleDataEntry, E4SingleEventEntry, E4TripleDataEntry


class E4Parser(DataParser):
    """
    Data parser for recording entries that contain a single unit of datum that can be converted to a basic trip type
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper):
        """

        :param component: Name of the RTMaps component that generated this data
        :param output: Name of the output of the RTMaps component that generated this data
        :param timestamper: Whether to use timestamp as timecode or time of issue or resample with sample rate
        """
        DataParser.__init__(self, component, output, timestamper)
        self._entries: List[E4Entry] = []
        self._buffer: str = ''
        self._delta_time: float = None
        self._nb_miss_head = 0
        self._nb_miss_tail = 0
        self._nb_elts = 0

    def start_parse(self) -> None:
        pass

    def parse_data(self, data: str, ts: float) -> None:
        # We are not interested by rows starting with R (R device_connect, R device_subscribe) or M (Missing device ID)
        if data.startswith('R') or data.startswith('M'):
            return

        # Replace , with . to convert to float easily
        data = data.replace(',', '.')

        # For whatever reason, Empatica data sometimes start on one line of the *.rec file and end on the next line,
        # sometimes cutting a data element in half.
        # We tried to correct that by buffering the partial element at the end of a line to add it at the beginning of
        # the next line, but another problem occurred : probably due to a RTMaps FIFO sometimes too low, data lines
        # were (really rarely) lost, making it difficult or impossible to strap back partial elements while guaranteeing
        # data integrity (what happens if three lines in a row have a data element cut at the end, and we loose the
        # middle one ?)
        # Considering that lines with data elements cut in half represented less than 0.5% of recorded lines, we decided
        # to simply pop out cut elements

        # A line contains more than one data element
        data_split = data.split(r'\r\n')

        # Pop first data element if it is a "cut in half" one
        if not data.startswith('E'):
            data_split.pop(0)
            self._nb_miss_head += 1

        # Pop last data element if it is a "cut in half" one
        if not data.endswith(r'\n'):
            data_split.pop()
            self._nb_miss_tail += 1

        for elt in data_split:
            self._nb_elts += 1

            # Parsing piece of data
            m = re.search('E4_(?P<var_name>\w+)'
                          '\s(?P<timestamp>\d+\.\d+)'
                          '\s(?P<value>.*$)',
                          elt)

            if m is not None:
                var_name = m.group('var_name')
                timestamp = float(m.group('timestamp'))
                value = m.group('value')

                if self._delta_time is None:
                    self._delta_time = timestamp - ts

                # The clock speed used for all data will be the Empatica one, but reajusted to RTMaps timestamp reference
                # NOTE : Empatica timestamp is itself calculated with a reference timestamp (first datum) plus the frequency of the data
                t = timestamp - self._delta_time

                # NOTE : A questionable choice is made here not to keep data with a timestamp anterior to RTMaps start
                if t < 0:
                    continue

                # Add data to the dedicated E4Entry, or create it if it does not exist yet
                for e4entry in self._entries:
                    if e4entry.uuid() == var_name:
                        e4entry.add_data(t, value)
                        break
                else:
                    e4entry = self._e4_entry_factory(var_name)
                    e4entry.add_data(t, value)
                    self._entries.append(e4entry)

    def end_parse(self) -> None:
        log.debug(f"File:{self._rec_file}\tNb remaining elements:{self._nb_elts}\tNb missing head popped:{self._nb_miss_head}\tNb missing tail popped:{self._nb_miss_tail}")
        for e4entry in self._entries:
            e4entry.add_to_trip()

    def _e4_entry_factory(self, key: str) -> E4Entry:
        if key in ['Acc']:
            return E4TripleDataEntry(key, self._trip)
        elif key in ['Tag']:
            return E4SingleEventEntry(key, self._trip)
        else:
            return E4SingleDataEntry(key, self._trip)
