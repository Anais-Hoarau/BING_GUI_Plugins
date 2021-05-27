from rec2trip.data_parser import VectorParser, VectorParserEntry
from rec2trip.timestamper import Timestamper


class PsvCarObserverParser(VectorParser):
    """
    Data parser for Pro-SiVIC Car Observers
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper, table_name: str=None):
        VectorParser.__init__(self, component, output, timestamper, table_name)
        self.add_vector_entry(VectorParserEntry("Speed X", "m/s"))
        self.add_vector_entry(VectorParserEntry("Speed Y", "m/s"))
        self.add_vector_entry(VectorParserEntry("Speed Z", "m/s"))
        self.add_vector_entry(VectorParserEntry("Angle Speed X", "rad/s"))
        self.add_vector_entry(VectorParserEntry("Angle Speed Y", "rad/s"))
        self.add_vector_entry(VectorParserEntry("Angle Speed Z", "rad/s"))
        self.add_vector_entry(VectorParserEntry("Wheel Speed FrontLeft", "round/s", do_import=False))
        self.add_vector_entry(VectorParserEntry("Wheel Speed FrontRight", "round/s", do_import=False))
        self.add_vector_entry(VectorParserEntry("Wheel Speed RearLeft", "round/s", do_import=False))
        self.add_vector_entry(VectorParserEntry("Wheel Speed RearRight", "round/s", do_import=False))
        self.add_vector_entry(VectorParserEntry("Torque FrontLeft", "Newton.m", do_import=False))
        self.add_vector_entry(VectorParserEntry("Torque FrontRight", "Newton.m", do_import=False))
        self.add_vector_entry(VectorParserEntry("Torque RearLeft", "Newton.m", do_import=False))
        self.add_vector_entry(VectorParserEntry("Torque RearRight", "Newton.m", do_import=False))
        self.add_vector_entry(VectorParserEntry("Wheel Angle", "rad"))
        self.add_vector_entry(VectorParserEntry("Vehicle coordinate X", "m"))
        self.add_vector_entry(VectorParserEntry("Vehicle coordinate Y", "m"))
        self.add_vector_entry(VectorParserEntry("Vehicle coordinate Z", "m"))
        self.add_vector_entry(VectorParserEntry("Tire Force X FrontLeft", "Newton", do_import=False))
        self.add_vector_entry(VectorParserEntry("Tire Force Y FrontLeft", "Newton", do_import=False))
        self.add_vector_entry(VectorParserEntry("Tire Force Z FrontLeft", "Newton", do_import=False))
        self.add_vector_entry(VectorParserEntry("Tire Force X FrontRight", "Newton", do_import=False))
        self.add_vector_entry(VectorParserEntry("Tire Force Y FrontRight", "Newton", do_import=False))
        self.add_vector_entry(VectorParserEntry("Tire Force Z FrontRight", "Newton", do_import=False))
        self.add_vector_entry(VectorParserEntry("Tire Force X RearLeft", "Newton", do_import=False))
        self.add_vector_entry(VectorParserEntry("Tire Force Y RearLeft", "Newton", do_import=False))
        self.add_vector_entry(VectorParserEntry("Tire Force Z RearLeft", "Newton", do_import=False))
        self.add_vector_entry(VectorParserEntry("Tire Force X RearRight", "Newton", do_import=False))
        self.add_vector_entry(VectorParserEntry("Tire Force Y RearRight", "Newton", do_import=False))
        self.add_vector_entry(VectorParserEntry("Tire Force Z RearRight", "Newton", do_import=False))
        self.add_vector_entry(VectorParserEntry("Acceleration X", "m/s2"))
        self.add_vector_entry(VectorParserEntry("Acceleration Y", "m/s2"))
        self.add_vector_entry(VectorParserEntry("Acceleration Z", "m/s2"))
        self.add_vector_entry(VectorParserEntry("Wheel Radius FrontLeft", "m", do_import=False))
        self.add_vector_entry(VectorParserEntry("Wheel Radius FrontRight", "m", do_import=False))
        self.add_vector_entry(VectorParserEntry("Wheel Radius RearLeft", "m", do_import=False))
        self.add_vector_entry(VectorParserEntry("Wheel Radius RearRight", "m", do_import=False))
        self.add_vector_entry(VectorParserEntry("Angle X", "rad"))
        self.add_vector_entry(VectorParserEntry("Angle Y", "rad"))
        self.add_vector_entry(VectorParserEntry("Angle Z", "rad"))
