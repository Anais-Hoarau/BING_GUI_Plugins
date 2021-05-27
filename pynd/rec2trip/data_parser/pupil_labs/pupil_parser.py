from pynd import MetaVariableBaseType as T
from rec2trip.timestamper import Timestamper
from .pupil_labs_parser import PupilLabsParser
from .pupil_labs_sub_parser import SingleEltSubParser, ListOfEltsSubParser, RecursiveDictSubParser


class PupilParser(PupilLabsParser):
    """
    Data parser for pupils data recorded with RTMaps from Pupil Labs headset
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper):
        PupilLabsParser.__init__(self, component, output, timestamper, 'pupil')
        self.add_pupil_subparser(SingleEltSubParser('timestamp',
                                                    [('timestamp', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('id',
                                                    [('id', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('confidence',
                                                    [('confidence', T.REAL)]))
        self.add_pupil_subparser(ListOfEltsSubParser('norm_pos',
                                                     [('norm_pos_x', T.REAL),
                                                      ('norm_pos_y', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('diameter',
                                                    [('diameter', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('method',
                                                    [('method', T.TEXT)]))

        # Construct the recursive dictionary parser for the "ellipse" key
        ellipse_parser = RecursiveDictSubParser('ellipse')
        ellipse_parser.add_subparser(ListOfEltsSubParser('center',
                                                         [('ellipse_center_x', T.REAL),
                                                          ('ellipse_center_y', T.REAL)]))
        ellipse_parser.add_subparser(ListOfEltsSubParser('axes',
                                                         [('ellipse_axis_a', T.REAL),
                                                          ('ellipse_axis_b', T.REAL)]))
        ellipse_parser.add_subparser(SingleEltSubParser('angle',
                                                        [('ellipse_angle', T.REAL)]))
        self.add_pupil_subparser(ellipse_parser)

        self.add_pupil_subparser(SingleEltSubParser('diameter_3d',
                                                    [('diameter_3d', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('model_confidence',
                                                    [('model_confidence', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('model_id',
                                                    [('model_id', T.REAL)]))

        # Construct the recursive dictionary parser for the "sphere" key
        sphere_parser = RecursiveDictSubParser('sphere')
        sphere_parser.add_subparser(ListOfEltsSubParser('center',
                                                        [('sphere_center_x', T.REAL),
                                                         ('sphere_center_y', T.REAL),
                                                         ('sphere_center_z', T.REAL)]))
        sphere_parser.add_subparser(SingleEltSubParser('radius',
                                                       [('sphere_radius', T.REAL)]))
        self.add_pupil_subparser(sphere_parser)

        # Construct the recursive dictionary parser for the "circle_3d" key
        circle_parser = RecursiveDictSubParser('circle_3d')
        circle_parser.add_subparser(ListOfEltsSubParser('center',
                                                        [('circle_3d_center_x', T.REAL),
                                                         ('circle_3d_center_y', T.REAL),
                                                         ('circle_3d_center_z', T.REAL)]))
        circle_parser.add_subparser(ListOfEltsSubParser('normal',
                                                        [('circle_3d_normal_x', T.REAL),
                                                         ('circle_3d_normal_y', T.REAL),
                                                         ('circle_3d_normal_z', T.REAL)]))
        circle_parser.add_subparser(SingleEltSubParser('radius',
                                                       [('circle_3d_radius', T.REAL)]))
        self.add_pupil_subparser(circle_parser)

        self.add_pupil_subparser(SingleEltSubParser('theta',
                                                    [('theta', T.REAL)]))
        self.add_pupil_subparser(SingleEltSubParser('phi',
                                                    [('phi', T.REAL)]))

        # Construct the recursive dictionary parser for the "projected_sphere" key
        projected_sphere_parser = RecursiveDictSubParser('projected_sphere')
        projected_sphere_parser.add_subparser(ListOfEltsSubParser('center',
                                                                  [('projected_sphere_center_x', T.REAL),
                                                                   ('projected_sphere_center_y', T.REAL)]))
        projected_sphere_parser.add_subparser(ListOfEltsSubParser('axes',
                                                                  [('projected_sphere_axis_a', T.REAL),
                                                                   ('projected_sphere_axis_b', T.REAL)]))
        projected_sphere_parser.add_subparser(SingleEltSubParser('angle',
                                                                 [('projected_sphere_angle', T.REAL)]))
        self.add_pupil_subparser(projected_sphere_parser)
