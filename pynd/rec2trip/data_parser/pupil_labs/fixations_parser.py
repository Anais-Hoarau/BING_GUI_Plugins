from pynd import MetaVariableBaseType as T
from rec2trip.timestamper import Timestamper
from .pupil_labs_parser import PupilLabsParser
from .pupil_labs_sub_parser import SingleEltSubParser, ListOfEltsSubParser


class FixationsParser(PupilLabsParser):
    """
    Data parser for fixations data recorded with RTMaps from Pupil Labs headset
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper):
        PupilLabsParser.__init__(self, component, output, timestamper, 'fixations')
        self.add_pupil_subparser(SingleEltSubParser('id',
                                                    [('id', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('timestamp',
                                                    [('timestamp', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('duration',
                                                    [('duration', T.REAL)]))
        self.add_pupil_subparser(ListOfEltsSubParser('norm_pos',
                                                     [('norm_pos_x', T.REAL),
                                                      ('norm_pos_y', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('dispersion',
                                                    [('dispersion', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('confidence',
                                                    [('confidence', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('method',
                                                    [('method', T.TEXT)]))
        self.add_pupil_subparser(ListOfEltsSubParser('gaze_point_3d',
                                                     [('gaze_point_3d_x', T.REAL),
                                                      ('gaze_point_3d_y', T.REAL),
                                                      ('gaze_point_3d_z', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('base_data',
                                                    [('base_data', T.TEXT)]))
