import os

from rec2trip import Rec2Trip
from rec2trip.data_parser import FloatParser, PsvCarObserverParser, PsvObjectObserverParser, VideoParser, AudioParser
from rec2trip.timestamper import TimeOfIssueTS, TimestampTS

TRIP_FILE = "test.trip"
REC_FILE = r"Y:\These_Jonathan\Pre_experiment_data\Simu_RTMaps\200\Scenario_prototype_2\1.600000s\20180730_100553_RecFile_2\RecFile_2_20180730_100553.rec"


def main():
    # Deleting previous Example trip
    if os.path.exists(TRIP_FILE):
        os.unlink(TRIP_FILE)

    cars = ["Ego", "GapCloser", "GapOpener", "Lead"] + [f"Filler{i}" for i in range(1, 13)]
    importer = Rec2Trip(REC_FILE, TRIP_FILE)
    toi = TimestampTS()
    tor = TimeOfIssueTS()
    for car in cars:
        importer.add_data_parser(PsvCarObserverParser(f"{car}_Car", "oData", toi))
        importer.add_data_parser(PsvObjectObserverParser(f"{car}_Chassis", "oData", toi))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_to_GO_ttc", tor))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_Acceleration", tor))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_blinker_left", tor))
    importer.add_data_parser(FloatParser("Computed_values", "GC_to_Ego_ttc", tor))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_to_GO_thw", tor))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_Speed", tor))
    importer.add_data_parser(FloatParser("Computed_values", "GC_to_Ego_thw", tor))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_blinker_right", tor))
    importer.add_data_parser(FloatParser("Computed_values", "Gap_Length_real", tor))
    importer.add_data_parser(VideoParser("sensoray_2255_1", "outputMAPSImage_1", tor))
    importer.add_data_parser(AudioParser("Sound_Capture_DShow_1", "stereoOutput", toi))
    importer.parse()


if __name__ == '__main__':
    main()
