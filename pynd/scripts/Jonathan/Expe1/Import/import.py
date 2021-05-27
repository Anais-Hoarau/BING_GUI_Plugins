import os
import logging as log
from datetime import datetime as dt

from rec2trip import Rec2Trip
from rec2trip.data_parser import FloatParser, VideoParser, AudioParser, StringParser
from rec2trip.data_parser.prosivic import PsvCarObserverParser, PsvObjectObserverParser
from rec2trip.data_parser.pupil_labs import GazeParser
from rec2trip.timestamper import TimeOfIssueTS, TimestampTS
from rec2trip.ttm import EventTableManipulator
from pynd import SQLiteTrip
from scripts.Matt.mutiprocessing_log import LoggingPool


DIR_EXPE = r"\\vrlescot\EQUIPE_SIGMA\These_Jonathan\Experiment_data"


def rec_to_trip(rec_file: str):
    root, f = os.path.split(rec_file)
    name, _ = os.path.splitext(f)
    trip_file = os.path.join(root, f"{name}.trip")

    split_path = os.path.normpath(rec_file).split(os.sep)
    gap_dir, rec_dir = os.path.split(root)
    gap = split_path[-3]
    scenario = split_path[-4]
    participant = split_path[-5]
    scenario = "auto" if "auto" in scenario else "manual"
    passages = [x for x in os.listdir(gap_dir) if "RecFile" in x]

    # For the 3 extra scenarios based on performance, it's in a different folder
    if "Extra" in rec_file:
        num_passage = "Extra"
        scenario = "manual"
        participant = split_path[-6]
    elif len(passages) == 3:
        num_passage = sorted(passages).index(rec_dir) + 1
    else:
        log.warning(f"3 passages expected, got {len(passages)} for scenario {scenario} with {gap} gap for participant "
                    f"{participant}")
        return

    log.info(f"Importing {scenario} scenario with {gap} gap for participant {participant} (passage {num_passage})")

    if os.path.exists(trip_file):
        # os.unlink(trip_file)
        log.info(f"{rec_file} already imported, skipping")
        return

    # cars = ["Ego", "GapCloser", "GapOpener", "Lead"] + [f"Filler{i}" for i in range(1, 13)]
    cars = ["Ego", "GapCloser", "GapOpener", "Lead"]
    importer = Rec2Trip(rec_file, trip_file)
    ts = TimestampTS()
    toi = TimeOfIssueTS()
    for car in cars:
        importer.add_data_parser(PsvCarObserverParser(f"{car}_Car", "oData", toi))
        importer.add_data_parser(PsvObjectObserverParser(f"{car}_Chassis", "oData", toi))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_Speed", ts))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_Acceleration", ts))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_to_GO_thw", ts))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_to_GO_ttc", ts))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_to_GO_ettc", ts))
    importer.add_data_parser(FloatParser("Computed_values", "GC_to_Ego_thw", ts))
    importer.add_data_parser(FloatParser("Computed_values", "GC_to_Ego_ttc", ts))
    importer.add_data_parser(FloatParser("Computed_values", "GC_to_Ego_ettc", ts))
    importer.add_data_parser(FloatParser("Computed_values", "Gap_Length_real", ts))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_blinker_right", ts))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_blinker_left", ts))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_accel_pedal", ts))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_brake_pedal", ts))
    importer.add_data_parser(FloatParser("Computed_values", "Ego_steer_angle", ts))
    importer.add_data_parser(VideoParser("sensoray_2255_1", "outputMAPSImage_1", toi))
    importer.add_data_parser(AudioParser("Sound_Capture_DShow_1", "stereoOutput", ts))
    importer.add_data_parser(StringParser("EventDebug_1", "Scenario_stage", ts, ttm_type=EventTableManipulator))
    importer.add_data_parser(GazeParser("python_v2_1", "gaze", toi))
    try:
        importer.parse()
    except Exception as e:
        log.error(f"Failed to import {rec_file}")
        log.error(str(e))
        return

    with SQLiteTrip(trip_file, 0.04, False) as trip:
        trip.set_attribute("gap", str(gap))
        trip.set_attribute("scenario", scenario)
        trip.set_attribute("participant_id", str(participant))
        trip.set_attribute("num_passage", str(num_passage))


def main():
    with LoggingPool('%(asctime)-15s (PID %(process)-5d) [%(levelname)-8s]: %(message)s', level=log.INFO, filename='import.log') as _:
        start_time = dt.now()
        count = 0
        with LoggingPool().make_pool() as pool:
            for root, dirs, files in os.walk(DIR_EXPE):
                if "Deprecated" in root:
                    continue
                if "Trainings" in root:
                    continue
                for f in files:
                    if not f.endswith(".rec"):
                        continue
                    rec_file = os.path.join(root, f)
                    count += 1
                    pool.apply_async(rec_to_trip, (rec_file,))
            pool.close()
            pool.join()
            log.info(f"Imported {count} trips in {dt.now() - start_time}")


if __name__ == '__main__':
    main()
