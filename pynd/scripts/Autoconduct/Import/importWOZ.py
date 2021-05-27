import os
import logging as log
from datetime import datetime as dt
import sys, re

# Append pynd folder to the path
sys.path.append(os.path.abspath(os.path.join(os.getcwd(), os.pardir, os.pardir, os.pardir)))

from pynd import SQLiteTrip
from rec2trip import Rec2Trip
from rec2trip.timestamper import TimestampTS, TimestampTSms, TimestampTScs, TimeOfIssueTS, TimeOfIssueTSms, TimeOfIssueTScs, ResamplingTS
from rec2trip.data_parser import FloatParser, IntParser, StringParser, VectorParser, VectorParserEntry, VideoParser, AudioParser
from scripts.Matt.mutiprocessing_log import LoggingPool


DIR_EXPE = r"I:\AUTOCONDUCT\WP5\Data\Tests"


def rec_to_trip(rec_file: str):
    root, f = os.path.split(rec_file)
    name, _ = os.path.splitext(f)
    trip_file = os.path.join(root, f"{name}.trip")

    split_path = os.path.normpath(rec_file).split(os.sep)
    split_name = name.split('_')
    scenario: str = split_name[0]
    participant: str = split_path[-3]

    log.info(f"Importing {scenario} scenario for participant {participant}")

    if os.path.exists(trip_file):
        # os.unlink(trip_file)
        return

    importer = Rec2Trip(rec_file, trip_file)
    if re.search('ACData', trip_file):
        mon_vector_parser = VectorParser("data_vectorizer_1", "o_data", TimestampTS())
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_1"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_2"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_3"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_4"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_5"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_6"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_7"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_8"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_9"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_10"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_11"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_12"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_13"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_14"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_15"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_16"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_17"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_18"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_19"))
        mon_vector_parser.add_vector_entry(VectorParserEntry("o_data_20"))
        importer.add_data_parser(mon_vector_parser)
        importer.add_data_parser(FloatParser("SmartEyeGDQ", "FilteredGazeDirectionQ", TimestampTS()))
        importer.add_data_parser(StringParser("DecoderSmartEye", "output", TimeOfIssueTS()))
        importer.add_data_parser(StringParser("UDP_FromSmartEye", "output", TimeOfIssueTS()))
        importer.add_data_parser(IntParser("JSONSub_Postures_1", "Body_Pose_Diagnostics_Pose", TimeOfIssueTSms()))
        importer.add_data_parser(IntParser("JSONSub_Postures_1", "Body_presence", TimeOfIssueTSms()))
        importer.add_data_parser(IntParser("JSONSub_Postures_1", "Feet_Data_Posture_of_both_leg", TimeOfIssueTSms()))
        importer.add_data_parser(IntParser("JSONSub_Postures_1", "Feet_Data_Distance_Right_Leg_Camera", TimeOfIssueTSms()))
        importer.add_data_parser(IntParser("JSONSub_Postures_1", "HSW_HSW_ON_3D", TimeOfIssueTSms()))
        importer.add_data_parser(IntParser("JSONSub_Postures_1", "Body_Activity_Level_Level", TimeOfIssueTSms()))
        importer.add_data_parser(IntParser("JSONSub_Postures_1", "Body_Gaze_Head_Direction", TimeOfIssueTSms()))
        importer.add_data_parser(IntParser("CANDecoder_1_1_2", "MABX_Diag_V_flag_x_CustomerHandsOnWheel", TimestampTScs()))
        importer.add_data_parser(IntParser("CANDecoder_1_1_2", "MABX_FeedBack_V_flag_x_DriverAccelSensor", TimestampTScs()))
        importer.add_data_parser(IntParser("CANDecoder_1_1_2", "MABX_FeedBack_V_flag_x_DriverBrakeSensor", TimestampTScs()))
        importer.add_data_parser(FloatParser("Biopac_Split_Data_1", "ecg", ResamplingTS(1000)))
        importer.add_data_parser(FloatParser("Biopac_Split_Data_1", "eda", ResamplingTS(1000)))
        importer.add_data_parser(FloatParser("Biopac_Split_Data_1", "resp", ResamplingTS(1000)))
        importer.add_data_parser(VideoParser("cam_AXIS_MJPG_QuadInterieur", "image", TimeOfIssueTS()))
        importer.add_data_parser(VideoParser("cam_AXIS_MJPG_Exterieur", "image", TimeOfIssueTS()))
        # importer.add_data_parser(AudioParser("AUDIO", "stereoOutput", TimestampTS()))
        if re.search('Entrainement_ACData', trip_file):
            importer.add_data_parser(IntParser("HMIController_pratique_1", "mode_de_marche", TimeOfIssueTSms()))
            importer.add_data_parser(IntParser("HMIController_pratique_1", "bouton_on_off_status", TimeOfIssueTSms()))
        else:
            importer.add_data_parser(IntParser("HMIController_1", "mode_de_marche", TimeOfIssueTSms()))
            importer.add_data_parser(IntParser("HMIController_1", "bouton_on_off_status", TimeOfIssueTSms()))

    elif re.search('ACFusion', trip_file):
        importer.add_data_parser(IntParser("ACFusion_1_1", "CONDUC_DISPO", TimeOfIssueTSms()))
        importer.add_data_parser(IntParser("ACFusion_1_1", "DIM", TimeOfIssueTSms()))
        importer.add_data_parser(IntParser("ACFusion_1_1", "REGARD", TimeOfIssueTSms()))
        importer.add_data_parser(IntParser("ACFusion_1_1", "PIEDS", TimeOfIssueTSms()))
        importer.add_data_parser(IntParser("ACFusion_1_1", "MAINS", TimeOfIssueTSms()))
        importer.add_data_parser(IntParser("ACFusion_1_1", "POSTURE", TimeOfIssueTSms()))
        importer.add_data_parser(StringParser("ACFusion_1_1", "errorMsgAll", TimeOfIssueTSms()))

    try:
        importer.parse()
    except Exception as e:
        log.error(f"Failed to import {rec_file}")
        log.error(str(e))
        return

    with SQLiteTrip(trip_file, 0.04, False) as trip:
        trip.set_attribute("imported_file", f)
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
                if "rushes" in root:
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
