from pynd import MetaVariableBaseType as T
from rec2trip.timestamper import Timestamper
from .pupil_labs_parser import PupilLabsParser
from .pupil_labs_sub_parser import SingleEltSubParser, ListOfEltsSubParser, GazeDictSubParser


class GazeParser(PupilLabsParser):
    """
    Data parser for gaze data recorded with RTMaps from Pupil Labs headset
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper):
        PupilLabsParser.__init__(self, component, output, timestamper, 'gaze')
        self.add_pupil_subparser(SingleEltSubParser('timestamp',
                                                    [('timestamp', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('confidence',
                                                    [('confidence', T.REAL)]))
        self.add_pupil_subparser(ListOfEltsSubParser('norm_pos',
                                                     [('norm_pos_x', T.REAL),
                                                      ('norm_pos_y', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('base_data',
                                                    [('base_data', T.TEXT)]))
        self.add_pupil_subparser(ListOfEltsSubParser('gaze_point_3d',
                                                     [('gaze_point_3d_x', T.REAL),
                                                      ('gaze_point_3d_y', T.REAL),
                                                      ('gaze_point_3d_z', T.REAL)]))
        self.add_pupil_subparser(GazeDictSubParser('eye_centers_3d',
                                                   [('eye_center0_3d_x', T.REAL),
                                                    ('eye_center0_3d_y', T.REAL),
                                                    ('eye_center0_3d_z', T.REAL),
                                                    ('eye_center1_3d_x', T.REAL),
                                                    ('eye_center1_3d_y', T.REAL),
                                                    ('eye_center1_3d_z', T.REAL)]))
        self.add_pupil_subparser(GazeDictSubParser('gaze_normals_3d',
                                                   [('gaze_normal0_x', T.REAL),
                                                    ('gaze_normal0_y', T.REAL),
                                                    ('gaze_normal0_z', T.REAL),
                                                    ('gaze_normal1_x', T.REAL),
                                                    ('gaze_normal1_y', T.REAL),
                                                    ('gaze_normal1_z', T.REAL)]))
