from rec2trip.data_parser import VectorParser, VectorParserEntry
from rec2trip.timestamper import Timestamper


class UEyeTimingsParser(VectorParser):
    """
    Data parser for IDS Camera uEye timings
    """

    def __init__(self, component: str, output: str, timestamper: Timestamper, table_name: str=None):
        VectorParser.__init__(self, component, output, timestamper, table_name)
        self.add_vector_entry(VectorParserEntry("uEye timestamp", "us"))
        self.add_vector_entry(VectorParserEntry("uEye frame number"))
        self.add_vector_entry(VectorParserEntry("Host process time", "us"))
