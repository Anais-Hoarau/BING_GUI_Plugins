from typing import List

from rec2trip.data_parser import DataParser
from rec2trip.timestamper import Timestamper
from .dr2_entry import Dr2Entry, Dr2GenericEntry, Dr2VehicleEntry, Dr2PedestrianEntry, Dr2CommentEntry


class Dr2Parser(DataParser):
    """
    Data parser to record entries coming from DR2. The DR2 data is a string of semicolon separated values with their
    associated tag, the DR2 parser then uses the Dr2Entry elements to store those different data in different tables
    with different metadata.

    Data format example:
    Pas=1;Temps=00:00:00,60000;HeureGMT=09:40:05,69921;IndEssai=0;NumInst=0;vp:Route=14;vp:Voie=2000;vp:Cap=0,000;
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper):
        """

        :param component: Name of the RTMaps component that generated this data
        :param output: Name of the output of the RTMaps component that generated this data
        :param timestamper: Whether to use timestamp as timecode or time of issue or resample with sample rate
        """
        DataParser.__init__(self, component, output, timestamper)
        self._entries: List[Dr2Entry] = []

    def start_parse(self) -> None:
        pass

    def parse_data(self, data: str, ts: float) -> None:
        # A line contains more than one data element
        data_split = data.split(';')

        # The data line always end with a ";", so get rid of last empty part
        if data_split[-1] == '':
            data_split.pop()

        for elt in data_split:
            # Parsing piece of data
            var_name, value = elt.split('=')
            value = value.replace(',', '.')

            # Add data to the dedicated Dr2Entry, or create it if it does not exist yet
            for dr2entry in self._entries:
                if dr2entry.uuid() == var_name:
                    dr2entry.add_data(ts, value)
                    break
            else:
                dr2entry = self._dr2_entry_factory(var_name)
                dr2entry.add_data(ts, value)
                self._entries.append(dr2entry)

    def end_parse(self) -> None:
        for dr2entry in self._entries:
            dr2entry.add_to_trip()

    def _dr2_entry_factory(self, key: str) -> Dr2Entry:
        if 'V_' and ':' in key:
            return Dr2VehicleEntry(key, self._trip)
        elif 'P_' and ':' in key:
            return Dr2PedestrianEntry(key, self._trip)
        elif 'comment' in key:
            return Dr2CommentEntry(key, self._trip)
        else:
            return Dr2GenericEntry(key, self._trip)
