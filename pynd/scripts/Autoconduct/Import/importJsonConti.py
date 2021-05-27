import os
import logging as log
from datetime import datetime as dt
import sys, re
import json

# Append pynd folder to the path
sys.path.append(os.path.abspath(os.path.join(os.getcwd(), os.pardir, os.pardir, os.pardir)))

from pynd import SQLiteTrip
from rec2trip import Rec2Trip
from scripts.Matt.mutiprocessing_log import LoggingPool


DIR_EXPE = r"I:\AUTOCONDUCT\WP5\Data\Tests"


def json_to_trip(json_file: str, trip_file: str):
    log.info(f"Importing json file : {json_file} in trip file : {trip_file}")

    with open(json_file) as f:
        data = json.load(f)
        for line in data['data']:
            timestamp = line['Timestamp']
            Body_Pose_Diagnostics_Pose = line['Body Pose Diagnostics']['Pose']
            Body_presence = line['Body presence']
            Feet_Data_Posture_of_both_leg = line['Feet Data']['Posture of both leg']
            Feet_Data_Distance_Right_Leg_Camera = line['Feet Data']['Distance Right Leg Camera']
            HSW_HSW_ON_3D = line['HSW']['HSW ON 3D']
            Body_Activity_Level_Level = line['Body Activity Level']['Level']
            Body_Gaze_Head_Direction = line['Body Gaze']['Head Direction']
            print(
                'timestamp: ' + str(timestamp) + ' | '
                'Body_Pose_Diagnostics_Pose: ' + str(Body_Pose_Diagnostics_Pose) + ' | '
                'Body_presence: ' + str(Body_presence) + ' | '
                'Feet_Data_Posture_of_both_leg: ' + str(Feet_Data_Posture_of_both_leg) + ' | '
                'Feet_Data_Distance_Right_Leg_Camera: ' + str(Feet_Data_Distance_Right_Leg_Camera) + ' | '
                'HSW_HSW_ON_3D: ' + str(HSW_HSW_ON_3D) + ' | '
                'Body_Activity_Level_Level: ' + str(Body_Activity_Level_Level) + ' | '
                'Body_Gaze_Head_Direction: ' + str(Body_Gaze_Head_Direction)
            )

    # try:
    #     importer.parse()
    # except Exception as e:
    #     log.error(f"Failed to import {json_file}")
    #     log.error(str(e))
    #     return

    with SQLiteTrip(trip_file, 0.04, False) as trip:
        trip.set_attribute("jsonFile_imported", "")
        # trip.add_data("data_JSONSub_Postures_1_newDiag")


def main():
    with LoggingPool('%(asctime)-15s (PID %(process)-5d) [%(levelname)-8s]: %(message)s', level=log.INFO,
                     filename='importJsonConti.log') as _:
        start_time = dt.now()
        count = 0
        with LoggingPool().make_pool(6) as pool:
            for root, dirs, files in os.walk(DIR_EXPE):
                if "unused" in root.lower():
                    continue
                if "rushes" in root:
                    continue
                for f in files:
                    if f.endswith(".trip"):
                        trip_file = os.path.join(root, f)
                    if not f.endswith(".json"):
                        continue
                    json_file = os.path.join(root, f)
                    count += 1
                    pool.apply_async(json_to_trip, (json_file, trip_file))
            pool.close()
            pool.join()
            log.info(f"Imported {count} trips in {dt.now() - start_time}")


if __name__ == '__main__':
    main()
