from typing import Dict, Tuple
import logging as log
from datetime import datetime
import re

from pynd import SQLiteTrip
from .data_parser import DataParser


class Rec2Trip:
    """
    The Rec2Trip class parses an RTMaps recording file (*.rec) and imports all of its data into a BIND trip file
    (*.trip)
    """

    __DEFAULT_DATE = datetime.strptime("00:00.000000", "%M:%S.%f")

    def __init__(self, rec_file: str, trip_file: str):
        """

        :param rec_file: Full path to the RTMaps recording file (*.rec)
        :param trip_file:  Full path to the BIND trip (*.trip)
        """
        self._rec_file: str = rec_file
        self._trip_file: str = trip_file
        self._parsers: Dict[Tuple[str, str], DataParser] = {}
        log.basicConfig(format='%(asctime)-15s [%(levelname)-8s]: %(message)s', level=log.DEBUG)

    def add_data_parser(self, parser: DataParser) -> None:
        """
        Add the given parser to the list of parser that will be used to convert the recording to a trip
        :param parser:
        :return:
        """
        self._parsers[parser.uuid()] = parser

    def _rec_time_2_seconds(self, time: str) -> float:
        """
        Converts an RTMaps time in its raw string format to seconds
        :param time:
        :return:
        """
        return (datetime.strptime(time, "%M:%S.%f") - self.__DEFAULT_DATE).total_seconds()

    def parse(self) -> None:
        """
        Parses the recording and generates the trip
        :return:
        """
        log.info(f"Starting parsing process for {self._rec_file}")
        with SQLiteTrip(self._trip_file, 0.04, True) as trip:
            # Validate parser
            if not self._check_enough_parser():
                pass

            # Start parse
            log.info("Initializing parsers")
            for parser in self._parsers.values():
                parser.set_trip(trip)
                parser.set_rec_file(self._rec_file)
                parser.start_parse()

            # Parse
            log.info("Starting to parse...")
            with open(self._rec_file, "r") as rec:
                for l in rec:
                    # Parsing diagram launch time
                    if l.startswith("Launched at"):
                        if "UTC" in l:
                            t_str = l.split("Launched at ")[1].split(" UTC")[0]
                        else:
                            t_str = l.split("Launched at ")[1]
                        t = datetime.strptime(t_str.strip(), "%H:%M:%S.%f (%d/%m/%Y)")
                        trip.set_attribute("recording_start_time", str(t))
                        trip.set_attribute("import_time", str(datetime.now()))
                        continue

                    # Parsing regular data
                    m = re.search('(?P<time_of_issue>\d+:\d{2}.\d{6}) / '
                                  '(?P<component>\w+)\.'
                                  '(?P<output>\w+)#'
                                  '(?P<idx>\d+)(?:[a-zA-Z0-9-]+)?'
                                  '(?:@(?P<timestamp>\d+:\d{2}.\d{6})(?:[A-Z0-9;]+)?)?'
                                  '(?:=(?P<data>.*))?$',
                                  l)
                    if not m:
                        continue
                    time_of_issue = self._rec_time_2_seconds(m.group('time_of_issue'))
                    component = m.group('component')
                    output = m.group('output')
                    idx = int(m.group('idx'))
                    data = m.group('data')
                    if m.group('timestamp') is None:
                        timestamp = None
                    else:
                        timestamp = self._rec_time_2_seconds(m.group('timestamp'))

                    parser_id = (component, output)
                    parser = self._parsers.get(parser_id, None)
                    if parser is None:
                        # log.warning(f"No parser for {component}.{output}, ignoring data")
                        continue
                    parser.parse_line_common(time_of_issue, idx, data, timestamp)

            # End parse
            log.info("Finished parsing, ending parsers (e.g. loading data to trip)")
            for parser in self._parsers.values():
                parser.end_parse()

            # Set everything as isBase
            meta_info = trip.get_meta_informations()
            for data in meta_info.get_datas_list():
                trip.set_is_base_data(data.get_name(), True)
            for event in meta_info.get_events_list():
                trip.set_is_base_event(event.get_name(), True)
            log.info("Import finished")

    def _check_enough_parser(self) -> bool:
        """
        Checks that enough parsers have been set for all data present in the recording
        :return:
        """
        ret = True
        with open(self._rec_file.replace(".rec", ".idy"), "r") as idy:
            for l in idy:
                # Parsing regular data
                m = re.search('(?P<time_of_issue>\d+:\d{2}.\d{6}) @ Record '
                              '(?P<component>\w+)\.'
                              '(?P<output>\w+)\(',
                              l)
                if not m:
                    continue
                component = m.group('component')
                output = m.group('output')
                if (component, output) not in self._parsers:
                    log.warning(f"No parser set for {component}.{output}")
                    ret = False
        return ret
