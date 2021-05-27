import os
import logging as log
from datetime import datetime as dt
import sys

# Append pynd folder to the path
sys.path.append(os.path.abspath(os.path.join(os.getcwd(), os.pardir, os.pardir, os.pardir)))

from pynd import SQLiteTrip
from rec2trip import Rec2Trip
from rec2trip.timestamper import TimestampTS, TimeOfIssueTS, ResamplingTS
from rec2trip.data_parser import FloatParser, IntParser, VectorParser, VectorParserEntry
from scripts.Matt.mutiprocessing_log import LoggingPool


DIR_EXPE = r"\\vrlescot\these_adolphe\PIMPON\DATA"


def rec_to_trip(rec_file: str):
    root, f = os.path.split(rec_file)
    name, _ = os.path.splitext(f)
    trip_file = os.path.join(root, f"{name}.trip")

    split_path = os.path.normpath(rec_file).split(os.sep)
    scenario: str = split_path[-3]
    participant: str = split_path[-4]

    log.info(f"Importing {scenario} scenario for participant {participant}")

    if os.path.exists(trip_file):
        log.info(f"Trip : "+trip_file+" already exists")
        # os.unlink(trip_file)
        return

    importer = Rec2Trip(rec_file, trip_file)
    importer.add_data_parser(FloatParser("Biopac_deinterleaver_1", "RESP", ResamplingTS(1000)))
    importer.add_data_parser(FloatParser("Biopac_deinterleaver_1", "ECG", ResamplingTS(1000)))
    importer.add_data_parser(FloatParser("Biopac_deinterleaver_1", "EDA", ResamplingTS(1000)))
    trigger_vect = VectorParser("Trigger_vect", "o_data", TimestampTS(), table_name="triggers")
    trigger_vect.add_vector_entry(VectorParserEntry("F1"))
    trigger_vect.add_vector_entry(VectorParserEntry("F2"))
    trigger_vect.add_vector_entry(VectorParserEntry("F3"))
    trigger_vect.add_vector_entry(VectorParserEntry("F4"))
    importer.add_data_parser(trigger_vect)
    scenario_vect = VectorParser("Scenario_vect", "o_data", TimestampTS(), table_name="scenario")
    scenario_vect.add_vector_entry(VectorParserEntry("bloc"))
    scenario_vect.add_vector_entry(VectorParserEntry("biofeedback_type"))
    importer.add_data_parser(scenario_vect)
    performance_vect = VectorParser("Performance_vect", "o_data", TimestampTS(), table_name="performance")
    performance_vect.add_vector_entry(VectorParserEntry("duration"))
    performance_vect.add_vector_entry(VectorParserEntry("result"))
    performance_vect.add_vector_entry(VectorParserEntry("score"))
    performance_vect.add_vector_entry(VectorParserEntry("pattern_length"))
    importer.add_data_parser(performance_vect)
    biofeedback_vect = VectorParser("Biofeedback_vect", "o_data", TimestampTS(), table_name="biofeedback")
    biofeedback_vect.add_vector_entry(VectorParserEntry("peak_TC"))
    biofeedback_vect.add_vector_entry(VectorParserEntry("stim_TC"))
    biofeedback_vect.add_vector_entry(VectorParserEntry("diff_peak-stim"))
    biofeedback_vect.add_vector_entry(VectorParserEntry("RR_interval"))
    biofeedback_vect.add_vector_entry(VectorParserEntry("heart_rate"))
    importer.add_data_parser(biofeedback_vect)

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
