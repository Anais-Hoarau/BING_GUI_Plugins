"""
Processes data for the button analysis
"""
import logging as log
import os
import csv

from dirs import DIR_PROCESSED, DIR_DATA_SIMU
from utils import read_csv_line
from split_raw_simu_data import str2time


# ADAS in the name


def main():
    # log.basicConfig(format='%(asctime)-15s [%(levelname)-10s][%(subject)-10s][%(scenario)-50s]: %(message)s',
    #                 level=log.INFO)
    log.basicConfig(format='%(subject)s,%(scenario)s,%(message)s', level=log.INFO)
    results = []
    buttons_map = {'down': 'brake',
                   'space': 'left',
                   'b': 'right'}
    for root, dirs, files in os.walk(DIR_DATA_SIMU):
        # Only ADAS scenarios
        if not "adas" in root.lower():
            continue
        # No stop and go scenarios
        if "LCB_B1_Long_Alt" in root:
            continue

        # Getting scenario and subject
        _, scenario = os.path.split(root)
        _, subject = os.path.split(_)

        d = {'subject': subject, 'scenario': scenario}
        button_file_path = os.path.join(root, "keyboardvalues.csv")
        if not os.path.exists(button_file_path):
            log.warning("No button data".format(subject=subject, scenario=scenario), extra=d)
            continue

        button = None
        t = None
        start_time = None
        time_to_answer = None
        for l in read_csv_line(button_file_path):
            action = l[1].lower()
            if action == 'start':
                start_time = str2time(l[0])
            if action not in ['start', 'stop']:
                if action not in buttons_map:
                    log.warning("Pressed the unhandled button '{b}'".format(b=action), extra=d)
                    continue
                if button is None:
                    button = buttons_map[action]
                    t = str2time(l[0])
                    time_to_answer = (t - start_time).total_seconds()
                elif button != buttons_map[action]:
                    log.fatal(
                        "Pressed too many handled buttons ({b1}, {b2})".format(b1=button, b2=buttons_map[action]),
                        extra=d)
                    return

        if button is None:
            log.warning("Pressed no button", extra=d)
            button = "---"
            t = "---"
            time_to_answer = "---"

        results.append([scenario, subject, t, button, time_to_answer])

    header = ["scenario",
              "subject",
              "timecode",
              "answer",
              "time_to_answer",
              ]

    assert (len(header) == len(results[0]))

    res_fn = os.path.join(DIR_PROCESSED, "button_answers.csv")
    with open(res_fn, 'w+') as subject_res:
        subject_res_writer = csv.writer(subject_res, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL,
                                        lineterminator='\n')
        subject_res_writer.writerow(header)
        for r in results:
            subject_res_writer.writerow(r)


if __name__ == "__main__":
    main()
