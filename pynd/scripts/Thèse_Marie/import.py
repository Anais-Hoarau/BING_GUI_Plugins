import os
import logging as log
from datetime import datetime as dt
import sys

# Append pynd folder to the path
sys.path.append(os.path.abspath(os.path.join(os.getcwd(), os.pardir, os.pardir, os.pardir)))

from pynd import SQLiteTrip
from rec2trip import Rec2Trip
from rec2trip.timestamper import TimestampTS, TimeOfIssueTS
from rec2trip.data_parser import CADispParser, VideoParser, AudioParser
from rec2trip.data_parser.simax import Dr2Parser
from scripts.Matt.mutiprocessing_log import LoggingPool


DIR_EXPE = r"\\vrlescot\THESE_MARIE\DonneesSimu_Bind"


def rec_to_trip(rec_file: str):
    root, f = os.path.split(rec_file)
    name, _ = os.path.splitext(f)
    trip_file = os.path.join(root, f"{name}.trip")

    split_path = os.path.normpath(rec_file).split(os.sep)
    scenario: str = split_path[-3]
    participant: str = split_path[-4]

    log.info(f"Importing {scenario} scenario for participant {participant}")

    # if os.path.exists(trip_file):
    #     os.unlink(trip_file)

    importer = Rec2Trip(rec_file, trip_file)
    importer.add_data_parser(Dr2Parser("DR2", "message", TimestampTS()))
    importer.add_data_parser(CADispParser("CADisp", "message", TimestampTS()))
    importer.add_data_parser(VideoParser("VIDEO_FRONT", "outputIplImage", TimeOfIssueTS(), "FrontView"))
    importer.add_data_parser(VideoParser("CAM_AXIS", "image", TimeOfIssueTS(), "QuadView"))
    importer.add_data_parser(AudioParser("AUDIO", "stereoOutput", TimestampTS(), "Audio"))
    try:
        importer.parse()
    except Exception as e:
        log.error(f"Failed to import {rec_file}")
        log.error(str(e))
        return

    with SQLiteTrip(trip_file, 0.04, False) as trip:
        trip.set_attribute("scenario", scenario)
        trip.set_attribute("participant_id", participant)


def main():
    with LoggingPool('%(asctime)-15s (PID %(process)-5d) [%(levelname)-8s]: %(message)s', level=log.INFO,
                     filename='import.log') as _:
        start_time = dt.now()
        count = 0
        with LoggingPool().make_pool(6) as pool:
            for root, dirs, files in os.walk(DIR_EXPE):
                if "unused" in root.lower():
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
