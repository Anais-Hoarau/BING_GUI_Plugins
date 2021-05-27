"""
Processes data for the button analysis
"""
import logging as log
import os
import csv
from collections import defaultdict
import math

from matplotlib import pyplot as plt
import numpy as np

from dirs import DIR_PROCESSED, DIR_DATA_SIMU
from sim2trip import EgoData
from utils import read_csv_line, clean_scenario_name
from split_raw_simu_data import str2time


# ADAS in the name

REACTION_PEDALS_SCENARIOS_PREFIX = [x.lower() for x in ["BAU", "Insert_R", "Intruder_L_Alt", "Panne"]]

ANALYSIS_STOP_TIME = {
    "bau": 2.5,
    "insert_r": 2.0,
    "intruder_l_alt": 3.5,
    "panne": 2.0
}


def moving_average(a, n=3) :
    ret = np.cumsum(a, dtype=float)
    ret[n:] = ret[n:] - ret[:-n]
    return ret[n - 1:] / n


def derivate(data, timecodes):
    r = []
    for dd, dt in zip(np.diff(data), np.diff(timecodes)):
        if dt == 0.:
            r.append(0)
        else:
            r.append(dd / dt)
    return np.array(r)


def main(steer_threshold):
    log.basicConfig(format='%(asctime)-15s [%(levelname)-10s]: %(message)s', level=log.INFO)

    brk_result = defaultdict(dict)
    acc_result = defaultdict(dict)
    steer_result = defaultdict(dict)

    for root, dirs, files in os.walk(DIR_DATA_SIMU):
        # Only ADAS scenarios
        is_sce_valid = False
        for valid_prefix in REACTION_PEDALS_SCENARIOS_PREFIX:
            if valid_prefix in root.lower():
                is_sce_valid = True

        if not is_sce_valid:
            continue

        # Getting scenario and subject
        _, scenario = os.path.split(root)
        _, subject = os.path.split(_)

        try:
            ego_data = EgoData.load(subject, scenario)
        except IOError:
            log.warning(f"Subject {subject} does not have data for scenario {scenario}")
            return

        if ego_data is None:
            log.warning(f"No ego data for subject {subject} in scenario {scenario}")
            return

        freeze_time_simu = ego_data[-1].timecode
        ego_data.reverse()

        # acc_data = []
        # brk_data = []
        # timecodes = []
        # We iterate over simu data starting from the back
        stop_acc_time = -1.
        start_brk_time = -1.
        start_steer_time = -1.
        stop_time = None
        for k, v in ANALYSIS_STOP_TIME.items():
            if k in scenario.lower():
                stop_time = v
                break
        if stop_time is None:
            log.warning(f"Couldn't find stop time for {scenario}")
        if scenario == "Insert_R_Reso2_crit2" and subject == "1075":
            a = 4
        for ego in ego_data:
            timecode = (freeze_time_simu - ego.timecode).total_seconds()
            if timecode > stop_time:
                if ego.acc == 0.:
                    stop_acc_time = stop_time
                if ego.brk != 0.:
                    start_brk_time = stop_time
                if abs(ego.steering) > steer_threshold:
                    start_steer_time = stop_time
                break
            if ego.acc == 0.:
                stop_acc_time = timecode
            if ego.brk != 0.:
                start_brk_time = timecode
            if abs(ego.steering) > steer_threshold:
                start_steer_time = timecode
        #     timecodes.append(timecode)
        #     acc_data.append(ego.acc)
        #     brk_data.append(ego.brk)

        brk_result[scenario][subject] = start_brk_time
        acc_result[scenario][subject] = stop_acc_time
        steer_result[scenario][subject] = start_steer_time

        #
        # acc = np.array(acc_data)
        # acc_clean = moving_average(acc_data)
        # acc_clean_timecodes = timecodes[1:-1]
        # acc_speed = derivate(acc_clean, acc_clean_timecodes)
        # acc_speed_clean = moving_average(acc_speed)
        # acc_speed_clean_timescodes = acc_clean_timecodes[2:-1]
        #
        # plt.plot(timecodes, acc,
        #          acc_clean_timecodes, acc_clean,
        #          acc_clean_timecodes[1:], acc_speed,
        #          acc_speed_clean_timescodes, acc_speed_clean
        #          )
        # plt.show()

    scenarios = list(acc_result.keys())
    subjects = list(acc_result[scenarios[0]].keys())

    header = ["subject"] + scenarios

    res_acc_fn = os.path.join(DIR_PROCESSED, "reaction_time_acc.csv")
    with open(res_acc_fn, 'w+') as acc_f:
        acc_res_writer = csv.writer(acc_f, delimiter=';', quotechar='|', quoting=csv.QUOTE_MINIMAL,
                                        lineterminator='\n')
        acc_res_writer.writerow(header)

        res_brk_fn = os.path.join(DIR_PROCESSED, "reaction_time_brk.csv")
        with open(res_brk_fn, 'w+') as brk_f:
            brk_res_writer = csv.writer(brk_f, delimiter=';', quotechar='|', quoting=csv.QUOTE_MINIMAL,
                                            lineterminator='\n')
            brk_res_writer.writerow(header)

            res_steer_fn = os.path.join(DIR_PROCESSED, f"reaction_time_steer_{steer_threshold}.csv")
            with open(res_steer_fn, 'w+') as steer_f:
                steer_res_writer = csv.writer(steer_f, delimiter=';', quotechar='|', quoting=csv.QUOTE_MINIMAL,
                                                lineterminator='\n')
                steer_res_writer.writerow(header)
                for subject in subjects:
                    line_acc = [subject]
                    line_brk = [subject]
                    line_steer = [subject]
                    for scenario in scenarios:
                        try:
                            stop_acc_time = acc_result[scenario][subject]
                        except KeyError:
                            stop_acc_time = math.nan
                        line_acc.append(stop_acc_time)

                        try:
                            start_brk_time = brk_result[scenario][subject]
                        except KeyError:
                            start_brk_time = math.nan
                        line_brk.append(start_brk_time)

                        try:
                            start_steer_time = steer_result[scenario][subject]
                        except KeyError:
                            start_steer_time = math.nan
                        line_steer.append(start_steer_time)

                    acc_res_writer.writerow(line_acc)
                    brk_res_writer.writerow(line_brk)
                    steer_res_writer.writerow(line_steer)

if __name__ == "__main__":
    main(0.01)
    main(0.02)
    main(0.05)
    main(0.1)
