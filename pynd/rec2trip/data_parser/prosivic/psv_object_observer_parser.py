from rec2trip.data_parser import VectorParser, VectorParserEntry
from rec2trip.timestamper import Timestamper


class PsvObjectObserverParser(VectorParser):
    """
    Data parser for Pro-SiVIC Object Observers
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper, table_name: str=None):
        VectorParser.__init__(self, component, output, timestamper, table_name)
        self.add_vector_entry(VectorParserEntry("Object coordinate  X", do_import=False))
        self.add_vector_entry(VectorParserEntry("Object coordinate  Y", do_import=False))
        self.add_vector_entry(VectorParserEntry("Object coordinate  Z", do_import=False))
        self.add_vector_entry(VectorParserEntry("Angle X", "rad", do_import=False))
        self.add_vector_entry(VectorParserEntry("Angle Y", "rad", do_import=False))
        self.add_vector_entry(VectorParserEntry("Angle Z", "rad", do_import=False))
        self.add_vector_entry(VectorParserEntry("Speed", "m/s"))
        self.add_vector_entry(VectorParserEntry("Direction X"))
        self.add_vector_entry(VectorParserEntry("Direction Y"))
        self.add_vector_entry(VectorParserEntry("Direction Z"))
