from pynd import MetaVariableBaseType as T
from rec2trip.timestamper import Timestamper
from .pupil_labs_parser import PupilLabsParser
from .pupil_labs_sub_parser import SingleEltSubParser


class BlinksParser(PupilLabsParser):
    """
    Data parser for blinks data recorded with RTMaps from Pupil Labs headset
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper):
        PupilLabsParser.__init__(self, component, output, timestamper, 'blinks')
        self.add_pupil_subparser(SingleEltSubParser('timestamp',
                                                    [('timestamp', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('confidence',
                                                    [('confidence', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('base_data',
                                                    [('base_data', T.TEXT)]))
