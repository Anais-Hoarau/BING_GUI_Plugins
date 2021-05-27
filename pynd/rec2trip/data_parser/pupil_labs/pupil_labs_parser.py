import json
import logging as log
from typing import Dict

from rec2trip.data_parser import DataParser
from rec2trip.timestamper import Timestamper
from rec2trip.ttm import DataTableManipulator
from .pupil_labs_sub_parser import PupilLabsSubParser


class PupilLabsParser(DataParser):
    """
    Data parser for recording entries that contain complex dictionary serialized in JSON coming from Pupil Labs headset.
    This dictionary can store data with different types amongst:
        - an integer
        - a float
        - a string
        - a list of two or three floats
        - a list of dictionaries
        - a dictionary, itself possibly containing data with different types amongst:
            * a float
            * a list of two or three floats
    To parse this dictionary, this class also uses the idea of subparsers, each of them being able to parse a specific
    entry of the dictionary.
    The structure of the dictionary and its keys depend on which output generated the data: pupil, gaze, fixations,
    blinks or surfaces, this class will thus be inherited by PupilParser, GazeParser, FixationsParser, BlinksParser and
    SurfacesParser.
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper, suffix_name: str):
        """

        :param component: Name of the RTMaps component that generated this data
        :param output: Name of the output of the RTMaps component that generated this data
        :param timestamper: Whether to use timestamp as timecode or time of issue or resample with sample rate
        :param suffix_name: Suffix use to name the trip table that the data will be inserted into.
        """
        DataParser.__init__(self, component, output, timestamper)
        self._ttm: DataTableManipulator = None
        self._table_name = 'PUPIL_GLASSES_' + suffix_name
        self._subparsers: Dict[str, PupilLabsSubParser] = {}
        self._delta_time: float = None

    def add_pupil_subparser(self, subparser: PupilLabsSubParser) -> None:
        """
        Add the given subparser to the list of subparsers that will be used to extract data from each dictionary value
        :param subparser: PupilLabsSubParser object able to parse a specific dictionary value
        """
        self._subparsers[subparser.uuid()] = subparser

    def start_parse(self) -> None:
        self._ttm = DataTableManipulator(self._trip)
        self._ttm.create_table(self._table_name)

        for subparser in self._subparsers.values():
            for var_name, var_type in subparser.entries:
                meta_var = self._ttm.create_meta_variable(var_name, var_type, comment="Imported from rec file")
                self._ttm.add_variable(meta_var)

    def parse_data(self, data: str, ts: float) -> None:
        try:
            data_json = json.loads(data)
        except json.decoder.JSONDecodeError:
            log.warning(f"JSON data from {self._component}.{self._output} at timestamp {ts} seems corrupted, ignoring line")
            return

        timestamp = data_json["timestamp"]
        if self._delta_time is None:
            self._delta_time = timestamp - ts

        # NOTE : pupil timestamp is calculated with a reference timestamp (first datum) plus the frequency of the data
        ts = timestamp - self._delta_time

        for key in data_json.keys():
            subparser_id = key
            subparser = self._subparsers.get(subparser_id, None)
            if subparser is None:
                # TODO Log something
                continue
            subparser.subparse_data(data_json[key], ts)

    def end_parse(self) -> None:
        for subparser in self._subparsers.values():
            if not subparser.data:
                log.warning(f"No data to load for {self._component}.{self._output}.{subparser.key}")
                return

            timecode, data = zip(*subparser.data)
            for i, datum in enumerate(zip(*data)):
                datum_name = subparser.entries[i][0]
                self._ttm.set_batch_of_variable_pairs(datum_name, timecode, datum)
