import os

from rec2trip import Rec2Trip
from rec2trip.data_parser import IntParser, StringParser, FloatParser
from rec2trip.timestamper import TimestampTS

TRIP_FILE = "import_recording.trip"
REC_FILE = "Recording/Recording.rec"


def main():
    # Deleting previous Example trip
    if os.path.exists(TRIP_FILE):
        os.unlink(TRIP_FILE)

    importer = Rec2Trip(REC_FILE, TRIP_FILE)
    importer.add_data_parser(IntParser("Randint_1", "outputInteger", TimestampTS(),
                                       table_name="bananas", column_name="count",
                                       unit="unit", comment="Bananas count"))
    importer.add_data_parser(FloatParser("Randint_1", "outputFloat", TimestampTS(),
                                         table_name="bananas", column_name="speed",
                                         unit="m/s", comment="Bananas speed"))
    importer.add_data_parser(StringParser("String_constant_generator_1", "stringValue", TimestampTS(),
                                          table_name="something", column_name="name",
                                          unit="none", comment="Bananas names"))
    importer.parse()


if __name__ == '__main__':
    main()
