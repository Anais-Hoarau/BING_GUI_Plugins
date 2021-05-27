"""
Processes data for the button analysis on the LCB_B1_Long_Alt_ADAS scenario
"""
import logging as log
import os
import csv
import math
from collections import defaultdict

from dirs import DIR_PROCESSED, DIR_DATA_SIMU
from utils import read_csv_line
from split_raw_simu_data import str2time


def main():
    log.basicConfig(format='%(asctime)-15s [%(levelname)-8s]: %(message)s', level=log.INFO)
    results = defaultdict(list)
    buttons_map = {'down': 'brake',
                   'space': 'left',
                   'b': 'right'}
    for root, dirs, files in os.walk(DIR_DATA_SIMU):
        if "LCB_B1_Long_Alt_ADAS" not in root:
            continue

        # Getting scenario and subject
        _, scenario = os.path.split(root)
        _, subject = os.path.split(_)

        d = {'subject': subject, 'scenario': scenario}
        button_file_path = os.path.join(root, "keyboardvalues.csv")
        if not os.path.exists(button_file_path):
            log.warning(f"{subject} doesn't have button data")
            continue

        start_time = None
        wait_for_next_start = True
        for l in read_csv_line(button_file_path):
            action = l[1].lower()
            if action == 'start':
                start_time = str2time(l[0])
                wait_for_next_start = False
            elif wait_for_next_start:
                continue
            elif action == 'stop':
                if not wait_for_next_start:
                    # Found a stop without any prior press -> no reaction
                    results[subject].append(math.nan)
            elif action == 'down':
                reaction_time = (str2time(l[0]) - start_time).total_seconds()
                results[subject].append(reaction_time)
                wait_for_next_start = True
            elif action in buttons_map.keys():
                log.warning(f"{subject} pressed wrong action ({buttons_map[action]})")
                results[subject].append("wp")
                wait_for_next_start = True
            else:
                log.warning(f"{subject} pressed non-existing key ({action})")
                results[subject].append("wp")
                wait_for_next_start = True


        answers_count = len(results[subject])
        if answers_count != 23:
            log.warning(f"{subject} answered {answers_count} times instead of 23")
            results.pop(subject, None)
            continue

    res_fn = os.path.join(DIR_PROCESSED, "button_answers_b1.csv")
    with open(res_fn, 'w+') as subject_res:
        subject_res_writer = csv.writer(subject_res, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL,
                                        lineterminator='\n')
        for subject, answers in results.items():
            subject_res_writer.writerow([subject] + answers)


if __name__ == "__main__":
    main()
